/// This file builds the backend/messenger/ part of the framework.
/// fn create adds:
/// - backend/messenger/api.zig
/// - backend/messenger/src/<< message name >>.zig
const std = @import("std");
const fspath = std.fs.path;
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");
const _bf_template_ = @import("bf_template.zig");
const _fbf_template_ = @import("fbf_template.zig");
const _bf_fbf_template_ = @import("bf_fbf_template.zig");
const _closedownjobs_template_ = @import("closedownjobs_template.zig");
const _stdout_ = @import("stdout");

pub fn create(allocator: std.mem.Allocator) !void {
    try addCloseDownJobsMessenger();
    // Build api.zig.
    try buildApiZig(allocator);
}

pub fn addBF(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Add the new message handler.
    try addBFMessenger(allocator, message_name);
    // Build api.zig with all of the message handlers.
    try buildApiZig(allocator);
}

pub fn addFBF(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Add the new message handler.
    try addFBFMessenger(allocator, message_name);
    // Build api.zig with all of the message handlers.
    try buildApiZig(allocator);
}

pub fn addBFFBF(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Add the new message handler.
    try addBFFBFMessenger(allocator, message_name);
    // Build api.zig with all of the message handlers.
    try buildApiZig(allocator);
}

pub fn remove(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Remove the message handler.
    try removeMessenger(allocator, message_name);
    // Build api.zig with all of the remaining message handlers.
    try buildApiZig(allocator);
}

fn buildApiZig(allocator: std.mem.Allocator) !void {
    // Build the template and the content.
    const template: *_api_template_.Template = try _api_template_.Template.init(allocator);
    defer template.deinit();
    // Get the names of each message handler and add them to the template.
    const current_message_names: [][]const u8 = try _filenames_.allBackendMessageHandlerNames(allocator);
    defer {
        for (current_message_names) |name| {
            allocator.free(name);
        }
        allocator.free(current_message_names);
    }
    for (current_message_names) |name| {
        try template.addName(name);
    }
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_backend_messenger.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    var ofile = try messenger_dir.createFile(_filenames_.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn addCloseDownJobsMessenger() !void {
    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_backend_messenger.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    var ofile = try messenger_dir.createFile(_filenames_.deps.closedownjobs_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(_closedownjobs_template_.content);
}

fn addBFMessenger(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Build the data for the template.
    var template: *_bf_template_.Template = try _bf_template_.init(allocator, message_name);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_backend_messenger.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    const file_name: []const u8 = try _filenames_.backendMessageHandlerFileName(allocator, message_name);
    var ofile = try messenger_dir.createFile(file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn addFBFMessenger(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Build the data for the template.
    var template: *_fbf_template_.Template = try _fbf_template_.init(allocator, message_name);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_backend_messenger.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    const file_name: []const u8 = try _filenames_.backendMessageHandlerFileName(allocator, message_name);
    var ofile = try messenger_dir.createFile(file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn addBFFBFMessenger(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Build the data for the template.
    var template: *_bf_fbf_template_.Template = try _bf_fbf_template_.init(allocator, message_name);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_backend_messenger.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    const file_name: []const u8 = try _filenames_.backendMessageHandlerFileName(allocator, message_name);
    var ofile = try messenger_dir.createFile(file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn removeMessenger(allocator: std.mem.Allocator, message_name: []const u8) !void {

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_backend_messenger.?, .{});
    defer messenger_dir.close();

    // Remove the file.
    const file_name: []const u8 = try _filenames_.backendMessageHandlerFileName(allocator, message_name);
    try messenger_dir.deleteFile(file_name);
}

pub fn listMessages(allocator: std.mem.Allocator) !void {
    {
        // Panel messages.
        const message_names: [][]const u8 = try _filenames_.allBackendMessageHandlerNames(allocator);
        defer allocator.free(message_names);
        // Heading
        try printMessageNamesHeading(allocator, message_names.len);
        // List
        try printMessageNames(allocator, message_names);
    }
}

fn printMessageNamesHeading(allocator: std.mem.Allocator, count_messages: usize) !void {
    return switch (count_messages) {
        0 => blk: {
            const heading: []const u8 = try std.fmt.allocPrint(allocator, "There are no messages.\n", .{});
            defer allocator.free(heading);
            break :blk try _stdout_.print(heading);
        },
        1 => blk: {
            const heading: []const u8 = try std.fmt.allocPrint(allocator, "There is 1 message.\n", .{});
            defer allocator.free(heading);
            break :blk try _stdout_.print(heading);
        },
        else => blk: {
            const heading: []const u8 = try std.fmt.allocPrint(allocator, "There are {d} messages.\n", .{count_messages});
            defer allocator.free(heading);
            break :blk try _stdout_.print(heading);
        },
    };
}

fn printMessageNames(allocator: std.mem.Allocator, messages: [][]const u8) !void {
    if (messages.len > 0) {
        // List
        const line: []u8 = try std.mem.join(allocator, "\n", messages);
        defer allocator.free(line);
        try _stdout_.print(line);
    }
    // Margin.
    try _stdout_.print("\n\n");
}
