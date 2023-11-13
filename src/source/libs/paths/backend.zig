const std = @import("std");
const fspath = std.fs.path;

pub const folder_name_backend: []const u8 = "backend";
const folder_name_messenger: []const u8 = "messenger";
const folder_name_src: []const u8 = "src";

/// returns the backend/messenger/ path.
/// The caller owns the returned value.
pub fn pathMessengerFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params = [2][]const u8{ folder_name_backend, folder_name_messenger };
    var path = try fspath.join(allocator, &params);
    return path;
}
