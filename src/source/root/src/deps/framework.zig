/// This file builds the deps/ part of the framework.
/// fn create adds:
/// - deps/channel/api.zig
/// - deps/framers/api.zig
/// - deps/message/api.zig
/// - deps/widget/api.zig, tabbar.zig
const std = @import("std");
const _channel_ = @import("channel/framework.zig");
const _counter_ = @import("counter/framework.zig");
const _framers_ = @import("framers/framework.zig");
const _main_menu_ = @import("main_menu/framework.zig");
const _message_ = @import("message/framework.zig");
const _modal_params_ = @import("modal_params/framework.zig");
const _widget_ = @import("widget/framework.zig");
const _startup_ = @import("startup/framework.zig");
const _closer_ = @import("closer/framework.zig");
const _closedownjobs_ = @import("closedownjobs/framework.zig");
const _various_ = @import("various/framework.zig");

pub const modal_params = _modal_params_;

pub fn create(allocator: std.mem.Allocator, use_messenger: bool) !void {
    if (use_messenger) {
        try _channel_.create(allocator);
        try _message_.create(allocator);
    }
    try _counter_.create();
    try _framers_.create(allocator);
    try _main_menu_.create();
    try _modal_params_.create(allocator);
    try _startup_.create(allocator, use_messenger);
    try _widget_.create();
    try _closer_.create();
    try _closedownjobs_.create();
    try _various_.create();
}

pub fn rebuildForUpdatedScreens(allocator: std.mem.Allocator) !void {
    try _framers_.rebuild(allocator);
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
