const std = @import("std");
const fspath = std.fs.path;

pub const folder_name_backend: []const u8 = "backend";
pub const folder_name_messenger: []const u8 = "messenger";
const folder_name_src: []const u8 = "src";

/// returns the backend/messenger/ path.
/// The caller owns the returned value.
pub fn pathMessengerFolder(allocator: std.mem.Allocator) ![]const u8 {
    const params = [2][]const u8{ folder_name_backend, folder_name_messenger };
    const path = try fspath.join(allocator, &params);
    return path;
}

/// returns the backend/messenger/message.zig path.
/// The caller owns the returned value.
pub fn pathMessengerFolderMessage(allocator: std.mem.Allocator, message_name: []const u8) ![]const u8 {
    const file_name: []const u8 = try std.fmt.allocPrint(allocator, "{s}.zig", .{message_name});
    defer allocator.free(file_name);
    const params = [3][]const u8{ folder_name_backend, folder_name_messenger, file_name };
    const path = try fspath.join(allocator, &params);
    return path;
}
