const std = @import("std");
const root = @import("rut/framework.zig");

pub fn create(allocator: std.mem.Allocator, app_name: []const u8) !void {
    try root.create(allocator, app_name);
}
