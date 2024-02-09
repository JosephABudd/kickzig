const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");

// Framework.

pub fn frameworkAdded(allocator: std.mem.Allocator, app_name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "The «{s}» framework has been added.\n", .{app_name});
}

// Screens.

pub fn screenRemoved(allocator: std.mem.Allocator, screen_name: []const u8) ![]const u8 {
    return std.fmt.allocPrint(allocator, "The screen «{s}» has been removed.\n", .{screen_name});
}

// Message.

pub fn backendMessageHandlerAdded(allocator: std.mem.Allocator, message_name: []const u8) ![]const u8 {
    const folders: *paths.FolderPaths = try paths.folders();
    const backend_path: []const u8 = try paths.backend.pathMessengerFolderMessage(allocator, message_name);
    defer allocator.free(backend_path);
    const params = [2][]const u8{ folders.root_src_this.?, backend_path };
    const path = try fspath.join(allocator, &params);
    return try std.fmt.allocPrint(allocator, "Added the back-end «{s}» messenger at {s}:1:1:\n", .{ message_name, path });
}

pub fn depsMessageAdded(allocator: std.mem.Allocator, message_name: []const u8) ![]const u8 {
    const folders: *paths.FolderPaths = try paths.folders();
    const deps_path: []const u8 = try paths.deps.pathMessengerFolderMessage(allocator, message_name);
    defer allocator.free(deps_path);
    const params = [2][]const u8{ folders.root_src_this.?, deps_path };
    const path = try fspath.join(allocator, &params);
    return try std.fmt.allocPrint(allocator, "Added the «{s}» message at {s}:1:1:\n", .{ message_name, path });
}

pub fn backendMessageHandlerRemoved(allocator: std.mem.Allocator, message_name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "Removed the back-end «{s}» message handler.\n", .{message_name});
}

pub fn depsMessageRemoved(allocator: std.mem.Allocator, message_name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "Removed the {s} message.\n", .{message_name});
}
