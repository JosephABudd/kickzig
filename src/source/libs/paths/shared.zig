const std = @import("std");
const fspath = std.fs.path;

const folder_name_shared: []const u8 = "shared";
const folder_name_channel: []const u8 = "channel";
const folder_name_message: []const u8 = "message";
const folder_name_record: []const u8 = "record";
const folder_name_src: []const u8 = "src";

/// returns the shared/channel path.
/// The caller owns the returned value.
pub fn pathChannelFolder(allocator: std.mem.Allocator) ![]const u8 {
    var path = try fspath.join(allocator, folder_name_shared, folder_name_channel);
    return path;
}

/// returns the shared/channel/src path.
/// The caller owns the returned value.
pub fn pathChannelSrcFolder(allocator: std.mem.Allocator) ![]const u8 {
    var path = try fspath.join(allocator, folder_name_shared, folder_name_channel, folder_name_src);
    return path;
}

/// returns the shared/message path.
/// The caller owns the returned value.
pub fn pathMessageFolder(allocator: std.mem.Allocator) ![]const u8 {
    var path = try fspath.join(allocator, folder_name_shared, folder_name_message);
    return path;
}

/// returns the shared/message/src path.
/// The caller owns the returned value.
pub fn pathMessageSrcFolder(allocator: std.mem.Allocator) ![]const u8 {
    var path = try fspath.join(allocator, folder_name_shared, folder_name_message, folder_name_src);
    return path;
}

/// returns the shared/record path.
/// The caller owns the returned value.
pub fn pathRecordFolder(allocator: std.mem.Allocator) ![]const u8 {
    var path = try fspath.join(allocator, folder_name_shared, folder_name_record);
    return path;
}
