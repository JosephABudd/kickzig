/// This file builds the deps/ part of the framework.
/// fn create adds:
/// - deps/channel/api.zig
/// - deps/framers/api.zig
/// - deps/lock/api.zig
/// - deps/message/api.zig
/// - deps/widget/api.zig, tabbar.zig
const std = @import("std");
const _channel_ = @import("channel/framework.zig");
const _framers_ = @import("framers/framework.zig");
const _lock_ = @import("lock/framework.zig");
const _message_ = @import("message/framework.zig");
const _modal_params_ = @import("modal_params/framework.zig");
const _widget_ = @import("widget/framework.zig");

pub const modal_params = _modal_params_;

pub fn create(allocator: std.mem.Allocator) !void {
    try _channel_.create(allocator);
    try _framers_.create();
    try _lock_.create();
    try _message_.create(allocator);
    try _modal_params_.create(allocator);
    try _widget_.create(allocator);
}
