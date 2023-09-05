const std = @import("std");
const fspath = std.fs.path;

pub const folder_name_backend: []const u8 = "backend";
pub const folder_name_messenger: []const u8 = "messenger";
pub const folder_name_store: []const u8 = "store";

/// returns the backend/messenger path.
/// The caller owns the returned value.
pub fn pathMessengerFolder(allocator: std.mem.Allocator) ![]const u8 {
    var path = try fspath.join(allocator, folder_name_backend, folder_name_messenger);
    return path;
}

/// returns the backend/store path.
/// The caller owns the returned value.
pub fn pathStoreFolder(allocator: std.mem.Allocator) ![]const u8 {
    var path = try fspath.join(allocator, folder_name_backend, folder_name_store);
    return path;
}
