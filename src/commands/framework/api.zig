const std = @import("std");
const _paths_ = @import("paths");
const _stdout_ = @import("stdout");
const _source_ = @import("source");

const _warning_ = @import("warning");
const _usage_ = @import("usage");

pub const command: []const u8 = "framework";
pub const verb_help: []const u8 = "help";
pub const verb_restart: []const u8 = "restart";

pub fn handleCommand(allocator: std.mem.Allocator, cli_name: []const u8, remaining_args: [][]u8) !void {
    var folder_paths: *_paths_.FolderPaths = try _paths_.folders();
    defer folder_paths.deinit();
    if (remaining_args.len > 0) {
        if (std.mem.eql(u8, remaining_args[0], verb_help)) {
            // User input is "framework help".
            try help(allocator, cli_name);
            return;
        }
        if (std.mem.eql(u8, remaining_args[0], verb_restart)) {
            // User input is "framework restart".
            // Remove and then create a new root/src/@This/.
            folder_paths.reBuild() catch |restart_err| {
                var user_input: []const u8 = undefined;
                user_input = std.fmt.allocPrint(allocator, "{s} {s}", .{ command, verb_restart }) catch {
                    return restart_err;
                };
                defer allocator.free(user_input);
                // Have input so make the error message.
                const msg: []const u8 = _warning_.fatal(allocator, restart_err, user_input) catch {
                    return restart_err;
                };
                try _stdout_.print(msg);
                allocator.free(msg);
            };
            // Create the framework.
            _source_.recreate(allocator, _paths_.app_name.?) catch |create_err| {
                // Have input so make the error message.
                const user_command: []const u8 = try std.fmt.allocPrint(allocator, "{s} {s}", .{ command, verb_restart });
                defer allocator.free(user_command);
                const msg: []const u8 = _warning_.fatal(allocator, create_err, user_command) catch {
                    return create_err;
                };
                try _stdout_.print(msg);
                allocator.free(msg);
                return create_err;
            };
        } else {
            // User input is "framework ????".
            try syntaxError(allocator, cli_name);
        }
    } else {
        // User input is "framework".
        // Create the framework if possible.
        if (folder_paths.isBuilt()) {
            // The framework was already built.
            try _stdout_.print(_warning_.already_built);
            return;
        }
        // Create the framework folders.
        try folder_paths.build();

        // Create the framework.
        _source_.create(allocator, _paths_.app_name.?) catch |create_err| {
            // Have input so make the error message.
            const msg: []const u8 = _warning_.fatal(allocator, create_err, command) catch {
                return create_err;
            };
            try _stdout_.print(msg);
            allocator.free(msg);
            return create_err;
        };
    }
}

fn syntaxError(allocator: std.mem.Allocator, cli_name: []const u8) !void {
    const message: []const u8 = try _warning_.syntaxError(allocator, cli_name, command, verb_help);
    defer allocator.free(message);
    try _stdout_.print(message);
}

fn help(allocator: std.mem.Allocator, cli_name: []const u8) !void {
    const framework_usage: []u8 = try _usage_.screen(allocator, cli_name);
    defer allocator.free(framework_usage);
    try _stdout_.print(framework_usage);
}
