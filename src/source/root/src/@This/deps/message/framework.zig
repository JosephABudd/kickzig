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
const _fatal_template_ = @import("fatal_template.zig");
const initialize_message_name: []const u8 = "Initialize";
const fatal_message_name: []const u8 = "Fatal";

pub fn create(allocator: std.mem.Allocator) !void {
    // Add the fatal message handler.
    try addFatal(allocator);
    // Add the initialize message handler.
    try addInitialize(allocator);
    // Build api.zig with the initialize message handler.
    try buildApiZig(allocator);
}

pub fn add(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Add the new message handler.
    try addMessage(allocator, message_name);
    // Build api.zig with all of the message handlers.
    try buildApiZig(allocator);
}

pub fn remove(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Remove the message handler.
    try removeMessage(allocator, message_name);
    // Build api.zig with all of the remaining message handlers.
    try buildApiZig(allocator);
}

fn buildApiZig(allocator: std.mem.Allocator) !void {
    // Build the template and the content.
    const template: *_api_template_.Template = try _api_template_.Template.init(allocator);
    defer template.deinit();
    // Get the names of each message and use them in the template.
    var current_message_names: [][]const u8 = try _filenames_.allDepsMessageNames(allocator);
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
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_message.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    var ofile = try messenger_dir.createFile(_filenames_.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn addFatal(allocator: std.mem.Allocator) !void {
    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_message.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    var file_name: []const u8 = try _filenames_.depsMessageFileName(allocator, fatal_message_name);
    var ofile = try messenger_dir.createFile(file_name, .{});
    defer ofile.close();
    try ofile.writeAll(_fatal_template_.content);
}

fn addInitialize(allocator: std.mem.Allocator) !void {
    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_message.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    var file_name: []const u8 = try _filenames_.depsMessageFileName(allocator, initialize_message_name);
    var ofile = try messenger_dir.createFile(file_name, .{});
    defer ofile.close();
    try ofile.writeAll(_initialize_template_.content);
}

fn addMessage(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Build the data for the template.
    var template: *_any_template_.Template = try _any_template_.init(allocator, message_name);
    defer template.deinit();
    var content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the deps/message folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_message.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    var file_name: []const u8 = try _filenames_.depsMessageFileName(allocator, message_name);
    var ofile = try messenger_dir.createFile(file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn removeMessage(allocator: std.mem.Allocator, message_name: []const u8) !void {

    // Open the deps/message folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_message.?, .{});
    defer messenger_dir.close();

    // Remove the file.
    var file_name: []const u8 = try _filenames_.depsMessageFileName(allocator, message_name);
    try messenger_dir.deleteFile(file_name);
}
