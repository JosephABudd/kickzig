const std = @import("std");
const _paths_ = @import("paths");
const _stdout_ = @import("stdout");
const _source_ = @import("source");

const _warning_ = @import("warning");
const _usage_ = @import("usage");

pub const command: []const u8 = "framework";
pub const verb_help: []const u8 = "help";
pub const verb_add_messages: []const u8 = "add-messages";
pub fn handleCommand(allocator: std.mem.Allocator, cli_name: []const u8, remaining_args: [][]u8) !void {
    // Use of messenger files defaults to true;
    var add_messages: bool = false;

    var folder_paths: *_paths_.FolderPaths = try _paths_.folders();
    defer folder_paths.deinit();

    if (remaining_args.len > 0) {
        // Read the remaining args.
        for (remaining_args) |remaining_arg| {
            if (std.mem.eql(u8, remaining_arg, verb_add_messages)) {
                add_messages = true;
            } else if (std.mem.eql(u8, remaining_args[0], verb_help)) {
                try help(allocator, cli_name);
                return;
            }
        }
    }

    // User input is "framework".
    // Create the framework if possible.
    if (folder_paths.isBuiltWithMessages()) {
        // The framework was already built with messages added.
        try _stdout_.print(_warning_.already_built_with_messages);
        return;
    }
    if (folder_paths.isBuilt()) {
        // The framework was already built.
        try _stdout_.print(_warning_.already_built_without_messages);
        return;
    }

    // Create the framework folders.
    try folder_paths.build(add_messages);

    // Create the framework.
    _source_.create(allocator, _paths_.app_name.?, add_messages) catch |create_err| {
        // Have input so make the error message.
        const msg: []const u8 = _warning_.fatal(allocator, create_err, command) catch {
            return create_err;
        };
        try _stdout_.print(msg);
        allocator.free(msg);
        return create_err;
    };
}

fn syntaxError(allocator: std.mem.Allocator, cli_name: []const u8) !void {
    const message: []const u8 = try _warning_.syntaxError(allocator, cli_name, command, verb_help);
    defer allocator.free(message);
    try _stdout_.print(message);
}

fn help(allocator: std.mem.Allocator, cli_name: []const u8) !void {
    const framework_usage: []u8 = try _usage_.framework(allocator, cli_name);
    defer allocator.free(framework_usage);
    try _stdout_.print(framework_usage);
}
