const std = @import("std");
const root = @import("root/framework.zig");

pub fn recreate(allocator: std.mem.Allocator, app_name: []const u8) !void {
    try root.recreate(allocator, app_name);
}

pub fn create(allocator: std.mem.Allocator, app_name: []const u8) !void {
    try root.create(allocator, app_name);
}
