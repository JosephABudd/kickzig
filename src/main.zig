const std = @import("std");
const _stdout_ = @import("stdout");
const _paths_ = @import("paths");
const _usage_ = @import("usage");
const _framework_commands_ = @import("commands/framework/api.zig");
const _screen_commands_ = @import("commands/screen/api.zig");
const _message_commands_ = @import("commands/message/api.zig");

pub fn main() !void {
    // Memory allocator.
    var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpa_instance.allocator();

    // Current working directory.
    var cwd_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const cwd_app_name: []const u8 = try std.os.getcwd(&cwd_buffer);

    // Init the paths module.
    try _paths_.init(gpa, cwd_app_name);

    // Process the args.
    var args: [][]u8 = try getProcessArgs(gpa);
    defer freeProcessArgs(gpa, args);
    const cli_name: []const u8 = std.fs.path.basename(args[0]);
    if (args.len == 1) {
        const use = try _usage_.application(gpa, cli_name);
        try _stdout_.print(use);
        return;
    }
    const command: []u8 = args[1];
    var remaining_args: [][]u8 = undefined;
    if (args.len > 2) {
        remaining_args = args[2..args.len];
    } else {
        remaining_args = args[0..0];
    }
    try handleCommand(gpa, cli_name, cwd_app_name, command, remaining_args);
}

/// handleCommand dispatches the user input to the proper handlers.
fn handleCommand(allocator: std.mem.Allocator, cli_name: []const u8, cwd_app_name: []const u8, command: []u8, remaining_args: [][]u8) !void {
    const app_name: []const u8 = std.fs.path.basename(cwd_app_name);

    // Process the command.

    // framework command.
    if (std.mem.eql(u8, command, _framework_commands_.command)) {
        try _framework_commands_.handleCommand(allocator, cli_name, app_name, remaining_args);
        return;
    }

    // screen command.
    if (std.mem.eql(u8, command, _screen_commands_.command)) {
        try _screen_commands_.handleCommand(allocator, cli_name, app_name, remaining_args);
        return;
    }

    // message command.
    if (std.mem.eql(u8, command, _message_commands_.command)) {
        try _message_commands_.handleCommand(allocator, cli_name, app_name, remaining_args);
        return;
    }

    // unknown user input.
    const application_usage: []const u8 = try _usage_.application(allocator, cli_name);
    defer allocator.free(application_usage);
    try _stdout_.print(application_usage);
}

fn getProcessArgs(allocator: std.mem.Allocator) ![][]u8 {
    const process_args: []const [:0]u8 = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, process_args);
    var fixed_args: [][]u8 = try allocator.alloc([]u8, process_args.len);
    for (process_args, 0..) |process_arg, i| {
        const fixedArg: []u8 = try allocator.alloc(u8, process_arg.len);
        errdefer {
            if (i > 0) {
                i -= 1;
                while (i >= 0) {
                    allocator.free(fixed_args[i]);
                }
            }
        }
        @memcpy(fixedArg, process_arg);
        fixed_args[i] = fixedArg;
    }
    return fixed_args;
}

fn freeProcessArgs(allocator: std.mem.Allocator, fixed_args: [][]u8) void {
    for (fixed_args) |arg| {
        allocator.free(arg);
    }
    allocator.free(fixed_args);
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
