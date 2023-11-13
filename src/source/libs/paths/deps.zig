const std = @import("std");
const fspath = std.fs.path;

pub const folder_name_deps: []const u8 = "deps";
const folder_name_channel: []const u8 = "channel";
const folder_name_message: []const u8 = "message";
const folder_name_framers: []const u8 = "framers";
const folder_name_lock: []const u8 = "lock";
const folder_name_src: []const u8 = "src";
const folder_name_modal_params: []const u8 = "modal_params";

/// returns the deps/channel/ path.
/// The caller owns the returned value.
pub fn pathChannelFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params = [2][]const u8{ folder_name_deps, folder_name_channel };
    var path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/message/ path.
/// The caller owns the returned value.
pub fn pathMessageFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params = [2][]const u8{ folder_name_deps, folder_name_message };
    var path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/framers/ path.
/// The caller owns the returned value.
pub fn pathFramersFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params = [2][]const u8{ folder_name_deps, folder_name_framers };
    var path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/lock/ path.
/// The caller owns the returned value.
pub fn pathLockFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params = [2][]const u8{ folder_name_deps, folder_name_lock };
    var path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/modal_params/ path.
/// The caller owns the returned value.
pub fn pathModalParamsFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params = [2][]const u8{ folder_name_deps, folder_name_modal_params };
    var path = try fspath.join(allocator, &params);
    return path;
}
