const std = @import("std");
const paths = @import("paths");
const frontend = @import("frontend.zig");
const zig_file_extension: []const u8 = ".zig";

pub const build_file_name: []const u8 = "build.zig";
pub const api_file_name: []const u8 = "api.zig";
pub const ralativeFilePathSuffix: []const u8 = ":1:1";
pub const screen_screen_file_name: []const u8 = "screen.zig";
pub const screen_messenger_file_name: []const u8 = "messenger.zig";
pub const screen_panels_file_name: []const u8 = "panels.zig";

// backend.

// backendMessageHandlerFileName returns the file name for a back-end message handler file.
// The caller owns the file name.
pub fn backendMessageHandlerFileName(allocator: std.mem.Allocator, message_name: []const u8) ![]const u8 {
    const file_name = std.ArrayList(u8).init(allocator);
    try file_name.appendSlice(message_name);
    try file_name.appendSlice(zig_file_extension);
    return try file_name.toOwnedSlice();
}

// backendMessageNameFromHandlerFileName returns the message name taken from a back-end message handler file name.
// The message name is a slice of file_name.
pub fn backendMessageNameFromHandlerFileName(file_name: []const u8) ?[]const u8 {
    if (std.mem.endsWith([]u8, file_name, zig_file_extension)) {
        var last: usize = file_name.len - zig_file_extension.len;
        return file_name[0..last];
    }
}

/// allBackendMessageHandlerNames returns the names of each message.
/// The caller owns the return value;
fn allBackendMessageHandlerNames(allocator: std.mem.Allocator) ![][]const u8 {
    var folders = try paths.folders();
    var names = std.ArrayList([]const u8).init(allocator);
    defer names.deinit();

    var dir = try std.fs.openIterableDirAbsolute(folders.app_src_backend_messenger, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .file) {
            if (backendMessageNameFromHandlerFileName(file.name)) |message_name| {
                names.append(message_name);
            }
        }
    }
    return names.toOwnedSlice();
}

// frontend.

/// frontendScreenPanelFileName returns the file name for a front-end screen panel file.
/// The caller owns the returned value.
pub fn frontendScreenPanelFileName(allocator: std.mem.Allocator, panel_name: []const u8) ![]const u8 {
    const fileName = std.ArrayList(u8).init(allocator);
    try fileName.appendSlice(panel_name);
    try fileName.appendSlice("_panel");
    try fileName.appendSlice(zig_file_extension);
    return try fileName.toOwnedSlice();
}

/// allFrontendScreenNames returns screen names taken from the screen folders.
/// The caller owns the returned value.
pub fn allFrontendScreenNames(allocator: std.mem.Allocator) ![][]const u8 {
    var all_folders = std.ArrayList([]const u8).init(allocator);
    defer all_folders.deinit();

    var some_folders: [][]const u8 = undefined;
    some_folders = try frontend.allPanelFolders(allocator);
    try all_folders.appendSlice(some_folders);
    defer {
        for (some_folders) |folder| {
            allocator.free(folder);
        }
        allocator.free(some_folders);
    }
    some_folders = try frontend.allTabFolders(allocator);
    try all_folders.appendSlice(some_folders);
    defer {
        for (some_folders) |folder| {
            allocator.free(folder);
        }
        allocator.free(some_folders);
    }

    return all_folders.toOwnedSlice();
}

// shared/.

// sharedMessageFileName returns the file name for a message.
// The caller owns the file name.
pub fn sharedMessageFileName(allocator: std.mem.Allocator, message_name: []const u8) ![]const u8 {
    const file_name = std.ArrayList(u8).init(allocator);
    try file_name.appendSlice(message_name);
    try file_name.appendSlice(zig_file_extension);
    return try file_name.toOwnedSlice();
}

// messageNameFromSharedMessageFileName returns the message name taken from a shared message file name.
// The message name is a slice of file_name.
pub fn messageNameFromSharedMessageFileName(file_name: []const u8) ?[]const u8 {
    if (std.mem.endsWith([]u8, file_name, zig_file_extension)) {
        var last: usize = file_name.len - zig_file_extension.len;
        return file_name[0..last];
    }
}

// sharedChannelFileName returns the file name for a channel.
// The caller owns the file name.
pub fn sharedChannelFileName(allocator: std.mem.Allocator, channel_name: []const u8) ![]const u8 {
    const file_name = std.ArrayList(u8).init(allocator);
    try file_name.appendSlice(channel_name);
    try file_name.appendSlice(zig_file_extension);
    return try file_name.toOwnedSlice();
}

// channelNameFromSharedChannelFileName returns the channel name taken from a shared channel file name.
// The channel name is a slice of file_name.
pub fn channelNameFromSharedChannelFileName(file_name: []const u8) ?[]const u8 {
    if (std.mem.endsWith([]u8, file_name, zig_file_extension)) {
        var last: usize = file_name.len - zig_file_extension.len;
        return file_name[0..last];
    }
}

/// allSharedMessageNames returns the names of each message in shared.
/// The caller owns the return value;
pub fn allSharedMessageNames(allocator: std.mem.Allocator) ![][]const u8 {
    var names = std.ArrayList([]const u8).init(allocator);
    defer names.deinit();

    var dir = try std.fs.openIterableDirAbsolute(paths.app_src_shared_message_src, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .file) {
            if (messageNameFromSharedMessageFileName(file.name)) |message_name| {
                names.append(message_name);
            }
        }
    }
    return names.toOwnedSlice();
}

/// allSharedChannelNames returns the names of each channel.
/// The caller owns the return value;
pub fn allSharedChannelNames(allocator: std.mem.Allocator) ![][]const u8 {
    var names = std.ArrayList([]const u8).init(allocator);
    defer names.deinit();

    var dir = try std.fs.openIterableDirAbsolute(paths.app_src_shared_channel_src, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .file) {
            if (channelNameFromSharedChannelFileName(file.name)) |channel_name| {
                names.append(channel_name);
            }
        }
    }
    return names.toOwnedSlice();
}
