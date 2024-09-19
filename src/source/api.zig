const std = @import("std");
pub const _root_ = @import("root/framework.zig");

pub fn recreate(allocator: std.mem.Allocator, app_name: []const u8, use_messenger: bool) !void {
    try _root_.recreate(allocator, app_name, use_messenger);
}

pub fn create(allocator: std.mem.Allocator, app_name: []const u8, use_messenger: bool) !void {
    try _root_.create(allocator, app_name, use_messenger);
}
