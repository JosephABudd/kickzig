const std = @import("std");
const fspath = std.fs.path;

pub const folder_name_shared: []const u8 = "shared";
pub const folder_name_channel: []const u8 = "channel";
pub const folder_name_message: []const u8 = "message";
pub const folder_name_record: []const u8 = "record";
pub const folder_name_src: []const u8 = "src";

/// returns the shared/channel path.
/// The caller owns the returned value.
pub fn pathChannelFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params: [][]const u8 = try allocator.alloc([]const u8, 2);
    defer allocator.free(params);
    params[0] = folder_name_shared;
    params[1] = folder_name_channel;
    var path = try fspath.join(allocator, params);
    return path;
}

/// returns the shared/channel/src path.
/// The caller owns the returned value.
pub fn pathChannelSrcFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params: [][]const u8 = try allocator.alloc([]const u8, 3);
    defer allocator.free(params);
    params[0] = folder_name_shared;
    params[1] = folder_name_channel;
    params[2] = folder_name_src;
    var path = try fspath.join(allocator, params);
    return path;
}

/// returns the shared/message path.
/// The caller owns the returned value.
pub fn pathMessageFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params: [][]const u8 = try allocator.alloc([]const u8, 2);
    defer allocator.free(params);
    params[0] = folder_name_shared;
    params[1] = folder_name_message;
    var path = try fspath.join(allocator, params);
    return path;
}

/// returns the shared/message/src path.
/// The caller owns the returned value.
pub fn pathMessageSrcFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params: [][]const u8 = try allocator.alloc([]const u8, 3);
    defer allocator.free(params);
    params[0] = folder_name_shared;
    params[1] = folder_name_message;
    params[2] = folder_name_src;
    var path = try fspath.join(allocator, params);
    return path;
}

/// returns the shared/record path.
/// The caller owns the returned value.
pub fn pathRecordFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params: [][]const u8 = try allocator.alloc([]const u8, 2);
    defer allocator.free(params);
    params[0] = folder_name_shared;
    params[1] = folder_name_record;
    var path = try fspath.join(allocator, params);
    return path;
}
