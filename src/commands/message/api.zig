const std = @import("std");
const _paths_ = @import("paths");
const _stdout_ = @import("stdout");
const _source_ = @import("source");
const _filenames_ = @import("filenames");
const _strings_ = @import("strings");
const _src_this_backend_messenger_ = _source_.backend.messenger;
const _src_this_deps_ = @import("source_deps");

const _warning_ = @import("warning");
const _success_ = @import("success");
const _usage_ = @import("usage");

pub const command: []const u8 = "message";
pub const verb_help: []const u8 = "help";
pub const verb_list: []const u8 = "list";
pub const verb_add_bf: []const u8 = "add-bf"; // back initializes, sends to front.
pub const verb_add_fbf: []const u8 = "add-fbf"; // front initializes & sends request to back, back sends response to front.
pub const verb_add_bf_fbf: []const u8 = "add-bf-fbf"; // front initializes & sends request to back, back sends response to front.
pub const verb_remove: []const u8 = "remove";

pub fn handleCommand(allocator: std.mem.Allocator, cli_name: []const u8, remaining_args: [][]u8) !void {
    var folder_paths: *_paths_.FolderPaths = try _paths_.folders();
    defer folder_paths.deinit();
    switch (remaining_args.len) {
        0 => {
            try syntaxError(allocator, cli_name);
            // const message_usage: []u8 = try _usage_.message(allocator, cli_name);
            // defer allocator.free(message_usage);
            // try _stdout_.print(message_usage);
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
                // User input is "message 💩".
                try syntaxError(allocator, cli_name);
                return;
            }
        },
        2 => {
            if (std.mem.eql(u8, remaining_args[0], verb_add_fbf)) {
                if (!try expectValidMessageName(allocator, remaining_args[1])) {
                    return;
                }
                if (!try expectNewMessageName(allocator, remaining_args[1])) {
                    return;
                }
                // User input is "message add-fbf UpdateList".
                try _src_this_backend_messenger_.addFBF(allocator, remaining_args[1]);
                try _src_this_deps_.addMessageFBF(allocator, remaining_args[1]);
                {
                    // Inform user added message.
                    const output: []const u8 = try _success_.depsMessageAdded(allocator, remaining_args[1]);
                    defer allocator.free(output);
                    try _stdout_.print(output);
                }
                {
                    // Inform user added handler.
                    const output: []const u8 = try _success_.backendMessageHandlerAdded(allocator, remaining_args[1]);
                    defer allocator.free(output);
                    try _stdout_.print(output);
                }
                return;
            } else if (std.mem.eql(u8, remaining_args[0], verb_add_bf)) {
                if (!try expectValidMessageName(allocator, remaining_args[1])) {
                    return;
                }
                if (!try expectNewMessageName(allocator, remaining_args[1])) {
                    return;
                }
                // User input is "message add-bf UpdateList".
                try _src_this_backend_messenger_.addBF(allocator, remaining_args[1]);
                try _src_this_deps_.addMessageBF(allocator, remaining_args[1]);
                {
                    // Inform user added message.
                    const output: []const u8 = try _success_.depsMessageAdded(allocator, remaining_args[1]);
                    defer allocator.free(output);
                    try _stdout_.print(output);
                }
                {
                    // Inform user added handler.
                    const output: []const u8 = try _success_.backendMessageHandlerAdded(allocator, remaining_args[1]);
                    defer allocator.free(output);
                    try _stdout_.print(output);
                }
                return;
            } else if (std.mem.eql(u8, remaining_args[0], verb_add_bf_fbf)) {
                if (!try expectValidMessageName(allocator, remaining_args[1])) {
                    return;
                }
                if (!try expectNewMessageName(allocator, remaining_args[1])) {
                    return;
                }
                // User input is "message add-bf-fbf UpdateList".
                try _src_this_backend_messenger_.addBFFBF(allocator, remaining_args[1]);
                try _src_this_deps_.addMessageBFFBF(allocator, remaining_args[1]);
                {
                    // Inform user added message.
                    const output: []const u8 = try _success_.depsMessageAdded(allocator, remaining_args[1]);
                    defer allocator.free(output);
                    try _stdout_.print(output);
                }
                {
                    // Inform user added handler.
                    const output: []const u8 = try _success_.backendMessageHandlerAdded(allocator, remaining_args[1]);
                    defer allocator.free(output);
                    try _stdout_.print(output);
                }
                return;
            } else if (std.mem.eql(u8, remaining_args[0], verb_remove)) {
                if (!try expectValidMessageName(allocator, remaining_args[1])) {
                    return;
                }
                if (!try expectExistingMessageName(allocator, remaining_args[1])) {
                    return;
                }
                // User input is "message remove EditContact".
                try _src_this_backend_messenger_.remove(allocator, remaining_args[1]);
                try _src_this_deps_.removeMessage(allocator, remaining_args[1]);
                {
                    // Inform user removed message.
                    const output: []const u8 = try _success_.depsMessageRemoved(allocator, remaining_args[1]);
                    defer allocator.free(output);
                    try _stdout_.print(output);
                }
                {
                    // Inform user removed handler.
                    const output: []const u8 = try _success_.backendMessageHandlerRemoved(allocator, remaining_args[1]);
                    defer allocator.free(output);
                    try _stdout_.print(output);
                }
                return;
            } else {
                // User input is "message 💩 💩".
                try syntaxError(allocator, cli_name);
            }
        },
        else => {
            // User input is "message 💩 💩 💩".
            try syntaxError(allocator, cli_name);
            return;
        },
    }
}

fn syntaxError(allocator: std.mem.Allocator, cli_name: []const u8) !void {
    const message: []const u8 = try _warning_.syntaxError(allocator, cli_name, command, verb_help);
    defer allocator.free(message);
    try _stdout_.print(message);
}

fn help(allocator: std.mem.Allocator, cli_name: []const u8) !void {
    const message: []u8 = try _usage_.message(allocator, cli_name);
    defer allocator.free(message);
    try _stdout_.print(message);
}

fn list(allocator: std.mem.Allocator) !void {
    const message_names: [][]const u8 = try _filenames_.allDepsMessageNames(allocator);
    try printMessageNamesHeading(allocator, message_names.len);
    try printMessageNames(allocator, message_names);
}

fn usage(allocator: std.mem.Allocator, cli_name: []const u8) !void {
    const message_usage: []u8 = try _usage_.message(allocator, cli_name);
    defer allocator.free(message_usage);
    try _stdout_.print(message_usage);
}

fn printMessageNamesHeading(allocator: std.mem.Allocator, count_screens: usize) !void {
    const heading: []const u8 = try std.fmt.allocPrint(allocator, "There are {d} messages.\n", .{count_screens});
    defer allocator.free(heading);
    try _stdout_.print(heading);
}

fn printMessageNames(allocator: std.mem.Allocator, message_names: [][]const u8) !void {
    if (message_names.len > 0) {
        // List
        const line: []u8 = try std.mem.join(allocator, "\n", message_names);
        defer allocator.free(line);
        try _stdout_.print(line);
    }
    // Margin.
    try _stdout_.print("\n\n");
}

// Expects

fn expectValidMessageName(allocator: std.mem.Allocator, message_name: []const u8) !bool {
    var is_valid: bool = _strings_.isValid(message_name);
    if (!is_valid) {
        const msg: []const u8 = try std.fmt.allocPrint(allocator, "«{s}» is not a valid message name.\n", .{message_name});
        defer allocator.free(msg);
        try _stdout_.print(msg);
        return is_valid;
    }
    is_valid = !_filenames_.isFrameworkMessageName(message_name);
    if (!is_valid) {
        const msg: []const u8 = try std.fmt.allocPrint(allocator, "«{s}» is a framework message name.\n", .{message_name});
        defer allocator.free(msg);
        try _stdout_.print(msg);
    }
    return is_valid;
}

fn expectExistingMessageName(allocator: std.mem.Allocator, message_name: []const u8) !bool {
    const all_names: [][]const u8 = try _filenames_.allDepsMessageNames(allocator);
    defer {
        for (all_names) |name| {
            allocator.free(name);
        }
        allocator.free(all_names);
    }
    for (all_names) |name| {
        if (std.mem.eql(u8, name, message_name)) {
            return true;
        }
    }
    // Error: New message name.
    const msg: []const u8 = try std.fmt.allocPrint(allocator, "«{s}» is not an existing message name.\n", .{message_name});
    defer allocator.free(msg);
    try _stdout_.print(msg);
    return false;
}

fn expectNewMessageName(allocator: std.mem.Allocator, message_name: []const u8) !bool {
    const all_names: [][]const u8 = try _filenames_.allDepsMessageNames(allocator);
    defer {
        for (all_names) |name| {
            allocator.free(name);
        }
        allocator.free(all_names);
    }
    for (all_names) |name| {
        if (std.mem.eql(u8, name, message_name)) {
            // Error: New message name.
            const msg: []const u8 = try std.fmt.allocPrint(allocator, "«{s}» is not a new message name.\n", .{message_name});
            defer allocator.free(msg);
            try _stdout_.print(msg);
            return false;
        }
    }
    return true;
}
