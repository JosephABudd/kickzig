/// This file builds the deps/channel/ part of the framework.
/// fn create adds:
/// - deps/channel/api.zig
/// - deps/channel/<< message name >>.zig
const std = @import("std");
const fspath = std.fs.path;
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");
const _trigger_template_ = @import("trigger_template.zig");
const _bf_general_dispatcher_template_ = @import("bf_general_dispatcher_template.zig");
const _bf_any_send_channel_template_ = @import("bf_any_send_channel_template.zig");
const _fb_general_dispatcher_template_ = @import("fb_general_dispatcher_template.zig");
const _fb_any_send_channel_template_ = @import("fb_any_send_channel_template.zig");

/// create makes the framework files.
/// - adds a back-to-front CloseDownJobs channel.
/// - adds a front-to-back CloseDownJobs channel.
/// Then it rebuilds the api and both dispatchers.
pub fn create(allocator: std.mem.Allocator) !void {
    // The CloseDownJobs channels.
    try rebuildAPIDispatchers(allocator);
}

/// remove attempts to remove each of the following:
/// - a channel and trigger from back-to-front.
/// - a channel from front-to-back.
/// Then it rebuilds the api and both dispatchers.
pub fn remove(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Remove the channel.
    if (try removeChannel(allocator, message_name)) {
        try rebuildAPIDispatchers(allocator);
    }
}

/// adBF adds a back-to-front channel and trigger.
/// Then it rebuilds the api and both dispatchers.
pub fn addBF(allocator: std.mem.Allocator, message_name: []const u8) !void {
    try addBackToFrontChannel(allocator, message_name);
    try addTrigger(allocator, message_name);
    try rebuildAPIDispatchers(allocator);
}

/// addFBF adds a front-to-back channel and a back-to-front-channel.
/// Then it rebuilds the api and both dispatchers.
pub fn addFBF(allocator: std.mem.Allocator, message_name: []const u8) !void {
    try addFrontToBackChannel(allocator, message_name);
    try addBackToFrontChannel(allocator, message_name);
    try rebuildAPIDispatchers(allocator);
}

/// addBFFBF
/// - adds a back-to-front channel and trigger.
/// - adds a front-to-back channel.
/// Then it rebuilds the api and both dispatchers.
pub fn addBFFBF(allocator: std.mem.Allocator, message_name: []const u8) !void {
    // Back to front channel.
    try addBackToFrontChannel(allocator, message_name);
    try addTrigger(allocator, message_name);
    // Front to back channel.
    try addFrontToBackChannel(allocator, message_name);
    // API and front-to-back and back-to-front general dispatchers.
    try rebuildAPIDispatchers(allocator);
}

fn addFrontToBackChannel(allocator: std.mem.Allocator, message_name: []const u8) !void {
    var folders = try _paths_.folders();
    defer folders.deinit();
    var template: *_fb_any_send_channel_template_.Template = try _fb_any_send_channel_template_.Template.init(allocator, message_name);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);
    return addChannel(allocator, message_name, folders.root_src_deps_channel_fronttoback.?, content);
}

fn addBackToFrontChannel(allocator: std.mem.Allocator, message_name: []const u8) !void {
    var folders = try _paths_.folders();
    defer folders.deinit();
    var template: *_bf_any_send_channel_template_.Template = try _bf_any_send_channel_template_.Template.init(allocator, message_name);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);
    return addChannel(allocator, message_name, folders.root_src_deps_channel_backtofront.?, content);
}

fn addTrigger(allocator: std.mem.Allocator, message_name: []const u8) !void {
    var folders = try _paths_.folders();
    defer folders.deinit();
    var template: *_trigger_template_.Template = try _trigger_template_.init(allocator, message_name);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);
    return addChannel(allocator, message_name, folders.root_src_deps_channel_trigger.?, content);
}

fn addChannel(allocator: std.mem.Allocator, message_name: []const u8, folder_path: []const u8, content: []const u8) !void {
    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var channel_dir: std.fs.Dir = try std.fs.openDirAbsolute(folder_path, .{});
    defer channel_dir.close();

    // Open, write and close the file.
    const file_name: []const u8 = try _filenames_.depsChannelFileName(allocator, message_name);
    defer allocator.free(file_name);
    var ofile = try channel_dir.createFile(file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn removeChannel(allocator: std.mem.Allocator, message_name: []const u8) !bool {
    var folders = try _paths_.folders();
    defer folders.deinit();
    var found: bool = false;

    var channel_names: [][]const u8 = undefined;
    {
        // trigger/ channel names.
        channel_names = try _filenames_.allDepsChannelTriggerNames(allocator);
        defer {
            for (channel_names) |channel_name| {
                allocator.free(channel_name);
            }
            allocator.free(channel_names);
        }
        for (channel_names) |channel_name| {
            if (std.mem.eql(u8, channel_name, message_name)) {
                var channel_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_channel_trigger.?, .{});
                defer channel_dir.close();
                // Remove the file.
                const file_name: []const u8 = try _filenames_.depsChannelFileName(allocator, message_name);
                try channel_dir.deleteFile(file_name);
                found = true;
            }
        }
    }
    {
        // backtofront/ channel names.
        channel_names = try _filenames_.allDepsChannelBackToFrontNames(allocator);
        defer {
            for (channel_names) |channel_name| {
                allocator.free(channel_name);
            }
            allocator.free(channel_names);
        }
        for (channel_names) |channel_name| {
            if (std.mem.eql(u8, channel_name, message_name)) {
                var channel_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_channel_backtofront.?, .{});
                defer channel_dir.close();
                // Remove the file.
                const file_name: []const u8 = try _filenames_.depsChannelFileName(allocator, message_name);
                try channel_dir.deleteFile(file_name);
                found = true;
            }
        }
    }
    {
        // fronttoback/ channel names.
        channel_names = try _filenames_.allDepsChannelFrontToBackNames(allocator);
        defer {
            for (channel_names) |name| {
                allocator.free(name);
            }
            allocator.free(channel_names);
        }
        for (channel_names) |channel_name| {
            if (std.mem.eql(u8, channel_name, message_name)) {
                var channel_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_channel_fronttoback.?, .{});
                defer channel_dir.close();
                // Remove the file.
                const file_name: []const u8 = try _filenames_.depsChannelFileName(allocator, message_name);
                try channel_dir.deleteFile(file_name);
                found = true;
            }
        }
    }
    return found;
}

fn rebuildAPIDispatchers(allocator: std.mem.Allocator) !void {
    // Back to front general dispatcher.
    try buildBFGeneralDispatcher(allocator);
    // Front to back general dispatcher.
    try buildFBGeneralDispatcher(allocator);
    // Build api.zig.
    try buildApiZig(allocator);
}

pub fn buildBFGeneralDispatcher(allocator: std.mem.Allocator) !void {
    var template: *_bf_general_dispatcher_template_.Template = try _bf_general_dispatcher_template_.Template.init(allocator);
    defer template.deinit();
    var channel_names: [][]const u8 = undefined;
    // backend to frontend channel names.
    channel_names = try _filenames_.allDepsChannelBackToFrontNames(allocator);
    defer {
        for (channel_names) |name| {
            allocator.free(name);
        }
        allocator.free(channel_names);
    }
    for (channel_names) |name| {
        try template.addBackToFrontChannelName(name);
    }

    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var channel_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_channel_backtofront.?, .{});
    defer channel_dir.close();

    // Open, write and close the file.
    var ofile = try channel_dir.createFile(_filenames_.deps.general_dispatcher_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

pub fn buildFBGeneralDispatcher(allocator: std.mem.Allocator) !void {
    var template: *_fb_general_dispatcher_template_.Template = try _fb_general_dispatcher_template_.Template.init(allocator);
    defer template.deinit();
    var channel_names: [][]const u8 = undefined;
    // backend to frontend channel names.
    channel_names = try _filenames_.allDepsChannelFrontToBackNames(allocator);
    defer {
        for (channel_names) |name| {
            allocator.free(name);
        }
        allocator.free(channel_names);
    }
    for (channel_names) |name| {
        try template.addFrontToBackChannelName(name);
    }

    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var channel_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_channel_fronttoback.?, .{});
    defer channel_dir.close();

    // Open, write and close the file.
    var ofile = try channel_dir.createFile(_filenames_.deps.general_dispatcher_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn buildApiZig(allocator: std.mem.Allocator) !void {
    // Build the template and the content.
    const template: *_api_template_.Template = try _api_template_.Template.init(allocator);
    defer template.deinit();
    var channel_names: [][]const u8 = undefined;
    {
        // backend to frontend channel names.
        channel_names = try _filenames_.allDepsChannelBackToFrontNames(allocator);
        defer {
            for (channel_names) |name| {
                allocator.free(name);
            }
            allocator.free(channel_names);
        }
        for (channel_names) |name| {
            try template.addBackToFrontChannelName(name);
        }
    }
    {
        // frontend to backend channel names.
        channel_names = try _filenames_.allDepsChannelFrontToBackNames(allocator);
        defer {
            for (channel_names) |name| {
                allocator.free(name);
            }
            allocator.free(channel_names);
        }
        for (channel_names) |name| {
            try template.addFrontToBackChannelName(name);
        }
    }
    {
        // trigger names.
        channel_names = try _filenames_.allDepsChannelTriggerNames(allocator);
        defer {
            for (channel_names) |name| {
                allocator.free(name);
            }
            allocator.free(channel_names);
        }
        for (channel_names) |name| {
            try template.addBackendTriggerName(name);
        }
    }

    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var channel_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_channel.?, .{});
    defer channel_dir.close();

    // Open, write and close the file.
    var ofile = try channel_dir.createFile(_filenames_.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}
