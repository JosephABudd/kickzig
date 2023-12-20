const std = @import("std");
const _paths_ = @import("paths");
const _stdout_ = @import("stdout");
const _source_ = @import("source");
const _filenames_ = @import("filenames");
const _src_this_backend_messenger_ = _source_.backend.messenger;
const _src_this_deps_ = @import("source_deps");

const _warning_ = @import("warning");
const _usage_ = @import("usage");

pub const command: []const u8 = "message";
pub const verb_help: []const u8 = "help";
pub const verb_list: []const u8 = "list";
pub const verb_add: []const u8 = "add";
pub const verb_remove: []const u8 = "remove";

pub fn handleCommand(allocator: std.mem.Allocator, cli_name: []const u8, app_name: []const u8, remaining_args: [][]u8) !void {
    _ = app_name;
    var folder_paths: *_paths_.FolderPaths = try _paths_.folders();
    defer folder_paths.deinit();
    switch (remaining_args.len) {
        0 => {
            var message_usage: []u8 = try _usage_.message(allocator, cli_name);
            defer allocator.free(message_usage);
            try _stdout_.print(message_usage);
            return;
        },
        1 => {
            if (std.mem.eql(u8, remaining_args[0], verb_help)) {
                // User input is "message help".
                try help(allocator, cli_name);
                return;
            }
            if (std.mem.eql(u8, remaining_args[0], verb_list)) {
                // User input is "message list".
                try list(allocator);
                return;
            } else {
                // Unknown.
                try help(allocator, cli_name);
                return;
            }
        },
        2 => {
            if (std.mem.eql(u8, remaining_args[0], verb_add)) {
                // User input is "message add EditContact".
                try _src_this_backend_messenger_.add(allocator, remaining_args[1]);
                try _src_this_deps_.addMessage(allocator, remaining_args[1]);
                return;
            } else if (std.mem.eql(u8, remaining_args[0], verb_remove)) {
                // User input is "message remove EditContact".
                try _src_this_backend_messenger_.remove(allocator, remaining_args[1]);
                try _src_this_deps_.removeMessage(allocator, remaining_args[1]);
                return;
            } else {
                // Unknown.
                try help(allocator, cli_name);
                return;
            }
        },
        else => {
            try help(allocator, cli_name);
            return;
        },
    }
}

fn help(allocator: std.mem.Allocator, cli_name: []const u8) !void {
    var message_usage: []u8 = try _usage_.message(allocator, cli_name);
    defer allocator.free(message_usage);
    try _stdout_.print(message_usage);
}

fn list(allocator: std.mem.Allocator) !void {
    var message_names: [][]const u8 = try _filenames_.allDepsMessageNames(allocator);
    try printMessageNamesHeading(allocator, message_names.len);
    try printMessageNames(allocator, message_names);
}

fn usage(allocator: std.mem.Allocator, cli_name: []const u8) !void {
    var message_usage: []u8 = try _usage_.message(allocator, cli_name);
    defer allocator.free(message_usage);
    try _stdout_.print(message_usage);
}

fn printMessageNamesHeading(allocator: std.mem.Allocator, count_screens: usize) !void {
    var heading: []const u8 = try std.fmt.allocPrint(allocator, "There are {d} messages.\n", .{count_screens});
    defer allocator.free(heading);
    try _stdout_.print(heading);
}

fn printMessageNames(allocator: std.mem.Allocator, message_names: [][]const u8) !void {
    if (message_names.len > 0) {
        // List
        var line: []u8 = try std.mem.join(allocator, "\n", message_names);
        defer allocator.free(line);
        try _stdout_.print(line);
    }
    // Margin.
    try _stdout_.print("\n\n");
}
