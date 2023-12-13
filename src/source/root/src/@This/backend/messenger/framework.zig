/// This file builds the backend/messenger/ part of the framework.
/// fn create adds:
/// - backend/messenger/api.zig
/// - backend/messenger/src/Initialize.zig
/// - backend/messenger/src/<< message name >>.zig
const std = @import("std");
const fspath = std.fs.path;
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");
const _any_template_ = @import("any_template.zig");
const _initialize_template_ = @import("initialize_template.zig");
const initialize_message_name: []const u8 = "Initialize";

pub fn create(allocator: std.mem.Allocator) !void {
    // Add the initialize message handler.
    try addInitialize(allocator);
    // Build api.zig with the initialize message handler.
    try buildApiZig(allocator);
}

pub fn add(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Add the new message handler.
    try addMessenger(allocator, message_name);
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
    var current_message_names: [][]const u8 = try _filenames_.allBackendMessageHandlerNames(allocator);
    defer {
        for (current_message_names) |name| {
            allocator.free(name);
        }
        allocator.free(current_message_names);
    }
    for (current_message_names) |name| {
        try template.addName(name);
    }
    var content: []const u8 = try template.content();
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

pub fn addInitialize(allocator: std.mem.Allocator) !void {
    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_backend_messenger.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    var file_name: []const u8 = try _filenames_.backendMessageHandlerFileName(allocator, initialize_message_name);
    var ofile = try messenger_dir.createFile(file_name, .{});
    defer ofile.close();
    try ofile.writeAll(_initialize_template_.content);
}

fn addMessenger(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Build the data for the template.
    var template: *_any_template_.Template = try _any_template_.Data.init(allocator, message_name);
    defer template.deinit();
    var content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_backend_messenger.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    var file_name: []const u8 = try _filenames_.backendMessageHandlerFileName(allocator, message_name);
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
    var file_name: []const u8 = try _filenames_.backendMessageHandlerFileName(allocator, message_name);
    try messenger_dir.deleteFile(file_name);
}
