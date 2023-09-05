const std = @import("std");

pub fn print(comptime format: []const u8, args: anytype) !void {
    try std.io.getStdOut().writer().print(format, args);
}
