const std = @import("std");
const fspath = std.fs.path;

pub const folder_name_backend: []const u8 = "backend";
pub const folder_name_messenger: []const u8 = "messenger";
pub const folder_name_store: []const u8 = "store";

/// returns the backend/messenger path.
/// The caller owns the returned value.
pub fn pathMessengerFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params: [][]const u8 = try allocator.alloc([]const u8, 2);
    defer allocator.free(params);
    params[0] = folder_name_backend;
    params[1] = folder_name_messenger;
    var path = try fspath.join(allocator, params);
    return path;
}

/// returns the backend/store path.
/// The caller owns the returned value.
pub fn pathStoreFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params: [][]const u8 = try allocator.alloc([]const u8, 2);
    defer allocator.free(params);
    params[0] = folder_name_backend;
    params[1] = folder_name_store;
    var path = try fspath.join(allocator, params);
    return path;
}
