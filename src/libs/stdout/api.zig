const std = @import("std");

pub fn print(text: []const u8) !void {
    try std.io.getStdOut().writer().print("{s}", .{text});
}

pub fn printf(comptime format: []const u8, args: anytype) !void {
    try std.io.getStdOut().writer().print(format, args);
}
