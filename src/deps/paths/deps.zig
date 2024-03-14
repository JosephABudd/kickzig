const std = @import("std");
const fspath = std.fs.path;

const folder_name_src: []const u8 = "src";
pub const folder_name_deps: []const u8 = "deps";

const folder_name_channel: []const u8 = "channel";
const folder_name_closer: []const u8 = "closer";
const folder_name_counter: []const u8 = "counter";
const folder_name_closedownjobs: []const u8 = "closedownjobs";
const folder_name_framers: []const u8 = "framers";
const folder_name_lock: []const u8 = "lock";
const folder_name_message: []const u8 = "message";
const folder_name_modal_params: []const u8 = "modal_params";
const folder_name_startup: []const u8 = "startup";
const folder_name_various: []const u8 = "various";
const folder_name_widget: []const u8 = "widget";
pub const folder_name_backtofront: []const u8 = "backtofront";
pub const folder_name_fronttoback: []const u8 = "fronttoback";
// pub const folder_name_root: []const u8 = "root";
pub const folder_name_bf: []const u8 = "bf";
pub const folder_name_bf_fbf: []const u8 = "bf_fbf";
pub const folder_name_fbf: []const u8 = "fbf";
pub const folder_name_trigger: []const u8 = "trigger";

/// returns the deps/channel/ path.
/// The caller owns the returned value.
pub fn pathChannelFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params = [2][]const u8{ folder_name_deps, folder_name_channel };
    const path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/channel/backtofront/ path.
/// The caller owns the returned value.
pub fn pathChannelBackToFrontFolder(allocator: std.mem.Allocator) ![]const u8 {
    const params = [3][]const u8{ folder_name_deps, folder_name_channel, folder_name_backtofront };
    const path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/channel/fronttoback/ path.
/// The caller owns the returned value.
pub fn pathChannelFrontToBackFolder(allocator: std.mem.Allocator) ![]const u8 {
    const params = [3][]const u8{ folder_name_deps, folder_name_channel, folder_name_fronttoback };
    const path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/channel/trigger/ path.
/// The caller owns the returned value.
pub fn pathChannelTriggerFolder(allocator: std.mem.Allocator) ![]const u8 {
    const params = [3][]const u8{ folder_name_deps, folder_name_channel, folder_name_trigger };
    const path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/closer/ path.
/// The caller owns the returned value.
pub fn pathCloserFolder(allocator: std.mem.Allocator) ![]const u8 {
    const params = [2][]const u8{ folder_name_deps, folder_name_closer };
    const path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/counter/ path.
/// The caller owns the returned value.
pub fn pathCounterFolder(allocator: std.mem.Allocator) ![]const u8 {
    const params = [2][]const u8{ folder_name_deps, folder_name_counter };
    const path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/closedownjobs/ path.
/// The caller owns the returned value.
pub fn pathCloseDownJobsFolder(allocator: std.mem.Allocator) ![]const u8 {
    const params = [2][]const u8{ folder_name_deps, folder_name_closedownjobs };
    const path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/framers/ path.
/// The caller owns the returned value.
pub fn pathFramersFolder(allocator: std.mem.Allocator) ![]const u8 {
    const params = [2][]const u8{ folder_name_deps, folder_name_framers };
    const path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/lock/ path.
/// The caller owns the returned value.
pub fn pathLockFolder(allocator: std.mem.Allocator) ![]const u8 {
    const params = [2][]const u8{ folder_name_deps, folder_name_lock };
    const path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/message/ path.
/// The caller owns the returned value.
pub fn pathMessageFolder(allocator: std.mem.Allocator) ![]const u8 {
    const params = [2][]const u8{ folder_name_deps, folder_name_message };
    const path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/message/message.zig path.
/// The caller owns the returned value.
pub fn pathMessengerFolderMessage(allocator: std.mem.Allocator, message_name: []const u8) ![]const u8 {
    const file_name: []const u8 = try std.fmt.allocPrint(allocator, "{s}.zig", .{message_name});
    defer allocator.free(file_name);
    const params = [3][]const u8{ folder_name_deps, folder_name_message, file_name };
    const path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/modal_params/ path.
/// The caller owns the returned value.
pub fn pathModalParamsFolder(allocator: std.mem.Allocator) ![]const u8 {
    const params = [2][]const u8{ folder_name_deps, folder_name_modal_params };
    const path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/startup/ path.
/// The caller owns the returned value.
pub fn pathStartupFolder(allocator: std.mem.Allocator) ![]const u8 {
    const params = [2][]const u8{ folder_name_deps, folder_name_startup };
    const path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/various/ path.
/// The caller owns the returned value.
pub fn pathVariousFolder(allocator: std.mem.Allocator) ![]const u8 {
    const params = [2][]const u8{ folder_name_deps, folder_name_various };
    const path = try fspath.join(allocator, &params);
    return path;
}

/// returns the deps/widget/ path.
/// The caller owns the returned value.
pub fn pathWidgetFolder(allocator: std.mem.Allocator) ![]const u8 {
    const params = [2][]const u8{ folder_name_deps, folder_name_widget };
    const path = try fspath.join(allocator, &params);
    return path;
}
