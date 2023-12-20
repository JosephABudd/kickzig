const std = @import("std");
const _root_ = @import("root/framework.zig");

pub const frontend = _root_.frontend;
pub const backend = _root_.backend;

pub fn recreate(allocator: std.mem.Allocator, app_name: []const u8) !void {
    try _root_.recreate(allocator, app_name);
}

pub fn create(allocator: std.mem.Allocator, app_name: []const u8) !void {
    try _root_.create(allocator, app_name);
}
