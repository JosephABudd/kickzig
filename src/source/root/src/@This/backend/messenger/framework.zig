/// This file builds the backend/messenger/ part of the framework.
/// fn create adds:
/// - backend/messenger/api.zig
/// - backend/messenger/src/Initialize.zig
/// - backend/messenger/src/<< message name >>.zig
const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");
const filenames = @import("filenames");
const api_template = @import("api_template.zig");
const any_template = @import("any_template.zig");
const initialize_template = @import("initialize_template.zig");
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
    const template: *api_template.Template = try api_template.Template.init(allocator);
    defer template.deinit();
    // Get the names of each message handler and add them to the template.
    var current_message_names: [][]const u8 = try filenames.allBackendMessageHandlerNames(allocator);
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
    var folders = try paths.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_backend_messenger.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    var ofile = try messenger_dir.createFile(filenames.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

pub fn addInitialize(allocator: std.mem.Allocator) !void {
    // Open the folder.
    var folders = try paths.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_backend_messenger.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    var file_name: []const u8 = try filenames.backendMessageHandlerFileName(allocator, initialize_message_name);
    var ofile = try messenger_dir.createFile(file_name, .{});
    defer ofile.close();
    try ofile.writeAll(initialize_template.content);
}

fn addMessenger(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Build the data for the template.
    var template: *any_template.Template = try any_template.Data.init(allocator, message_name);
    defer template.deinit();
    var content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try paths.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_backend_messenger.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    var file_name: []const u8 = try filenames.backendMessageHandlerFileName(allocator, message_name);
    var ofile = try messenger_dir.createFile(file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn removeMessenger(allocator: std.mem.Allocator, message_name: []const u8) !void {

    // Open the folder.
    var folders = try paths.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_backend_messenger.?, .{});
    defer messenger_dir.close();

    // Remove the file.
    var file_name: []const u8 = try filenames.backendMessageHandlerFileName(allocator, message_name);
    try messenger_dir.deleteFile(file_name);
}
