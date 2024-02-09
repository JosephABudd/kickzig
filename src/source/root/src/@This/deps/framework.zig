/// This file builds the deps/ part of the framework.
/// fn create adds:
/// - deps/channel/api.zig
/// - deps/framers/api.zig
/// - deps/lock/api.zig
/// - deps/message/api.zig
/// - deps/widget/api.zig, tabbar.zig
const std = @import("std");
const _channel_ = @import("channel/framework.zig");
const _counter_ = @import("counter/framework.zig");
const _framers_ = @import("framers/framework.zig");
const _lock_ = @import("lock/framework.zig");
const _message_ = @import("message/framework.zig");
const _modal_params_ = @import("modal_params/framework.zig");
const _widget_ = @import("widget/framework.zig");
const _startup_ = @import("startup/framework.zig");
const _closer_ = @import("closer/framework.zig");
const _closedownjobs_ = @import("closedownjobs/framework.zig");

pub const modal_params = _modal_params_;

pub fn create(allocator: std.mem.Allocator) !void {
    try _channel_.create(allocator);
    try _counter_.create();
    try _framers_.create();
    try _lock_.create();
    try _message_.create(allocator);
    try _modal_params_.create(allocator);
    try _startup_.create();
    try _widget_.create(allocator);
    try _closer_.create();
    try _closedownjobs_.create();
}

pub fn addMessageBF(allocator: std.mem.Allocator, message_name: []const u8) !void {
    try _message_.addBF(allocator, message_name);
    try _channel_.addBF(allocator, message_name);
}

pub fn addMessageFBF(allocator: std.mem.Allocator, message_name: []const u8) !void {
    try _message_.addFBF(allocator, message_name);
    try _channel_.addFBF(allocator, message_name);
}

pub fn addMessageBFFBF(allocator: std.mem.Allocator, message_name: []const u8) !void {
    try _message_.addBFFBF(allocator, message_name);
    try _channel_.addBFFBF(allocator, message_name);
}

pub fn removeMessage(allocator: std.mem.Allocator, message_name: []const u8) !void {
    try _message_.remove(allocator, message_name);
    try _channel_.remove(allocator, message_name);
}
