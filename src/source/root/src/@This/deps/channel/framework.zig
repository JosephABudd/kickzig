/// This file builds the deps/channel/ part of the framework.
/// fn create adds:
/// - deps/channel/api.zig
/// - deps/channel/Initialize.zig
/// - deps/channel/<< message name >>.zig
const std = @import("std");
const fspath = std.fs.path;
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");
const _any_template_ = @import("any_template.zig");
const _initialize_template_ = @import("initialize_template.zig");
const _fatal_template_ = @import("fatal_template.zig");

pub fn create(allocator: std.mem.Allocator) !void {
    // Add the fatal channel.
    try addFatal();
    // Add the initialize channel.
    try addInitialize();
    // Build api.zig with the initialize channel.
    try buildApiZig(allocator);
}

pub fn add(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Add the new channel.
    try addChannel(allocator, message_name);
    // Build api.zig with all of the channels.
    try buildApiZig(allocator);
}

pub fn remove(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Remove the channel.
    try removeChannel(allocator, message_name);
    // Build api.zig with all of the remaining channels.
    try buildApiZig(allocator);
}

fn buildApiZig(allocator: std.mem.Allocator) !void {
    // Build the template and the content.
    const template: *_api_template_.Template = try _api_template_.Template.init(allocator);
    defer template.deinit();
    // Get the names of each channel and use them in the template.
    var custom_channel_names: [][]const u8 = try _filenames_.allCustomDepsChannelNames(allocator);
    defer {
        for (custom_channel_names) |name| {
            allocator.free(name);
        }
        allocator.free(custom_channel_names);
    }
    for (custom_channel_names) |name| {
        try template.addName(name);
    }
    var content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var channel_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_channel.?, .{});
    defer channel_dir.close();

    // Open, write and close the file.
    var ofile = try channel_dir.createFile(_filenames_.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn addFatal() !void {
    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var channel_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_channel.?, .{});
    defer channel_dir.close();

    // Open, write and close the file.
    var ofile = try channel_dir.createFile(_filenames_.fatal_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(_fatal_template_.content);
}

fn addInitialize() !void {
    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var channel_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_channel.?, .{});
    defer channel_dir.close();

    // Open, write and close the file.
    var ofile = try channel_dir.createFile(_filenames_.initialize_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(_initialize_template_.content);
}

fn addChannel(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Build the data for the template.
    var template: *_any_template_.Template = try _any_template_.Data.init(allocator, message_name);
    defer template.deinit();
    var content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var channel_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_channel.?, .{});
    defer channel_dir.close();

    // Open, write and close the file.
    var file_name: []const u8 = try _filenames_.depsChannelFileName(allocator, message_name);
    defer allocator.free(file_name);
    var ofile = try channel_dir.createFile(file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn removeChannel(allocator: std.mem.Allocator, message_name: []const u8) !void {

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var channel_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_channel.?, .{});
    defer channel_dir.close();

    // Remove the file.
    var file_name: []const u8 = try _filenames_.depsChannelFileName(allocator, message_name);
    try channel_dir.deleteFile(file_name);
}
