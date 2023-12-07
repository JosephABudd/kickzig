/// This file builds the deps/ part of the framework.
/// fn create adds:
/// - deps/channel/api.zig
/// - deps/framers/api.zig
/// - deps/lock/api.zig
/// - deps/message/api.zig
/// - deps/widget/api.zig, tabbar.zig
const std = @import("std");
const channel = @import("channel/framework.zig");
const framers = @import("framers/framework.zig");
const lock = @import("lock/framework.zig");
const message = @import("message/framework.zig");
const modal_params = @import("modal_params/framework.zig");
const widget = @import("widget/framework.zig");

pub fn create(allocator: std.mem.Allocator) !void {
    try channel.create(allocator);
    try framers.create();
    try lock.create();
    try message.create(allocator);
    try modal_params.create(allocator);
    try widget.create(allocator);
}
