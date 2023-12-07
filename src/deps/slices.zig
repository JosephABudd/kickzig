const std = @import("std");

/// pad left pads lines with spaces so that they are the same length.
/// Caller has control of returned value.
pub fn pad(allocator: std.mem.Allocator, src: [][]const u8) ![][]const u8 {
    var fixed_lines = std.ArrayList([]const u8).init(allocator);
    defer fixed_lines.deinit();

    // Find the longest line length;
    var max_len: usize = 0;
    for (src) |line| {
        max_len += line.len;
    }
    for (src) |line| {
        var padding: usize = max_len - line.len;
        var new_line = std.ArrayList(u8).init(allocator);
        for (0..padding) |_| {
            new_line.append(' ');
        }
        try new_line.appendSlice(line);
        var fixed_line = try new_line.toOwnedSlice();
        try fixed_lines.append(fixed_line);
    }
    return fixed_lines.toOwnedSlice();
}

/// prefixes lines with fix.
/// Caller has control of returned value.
pub fn prefix(allocator: std.mem.Allocator, src: [][]const u8, fix: []const u8) ![][]const u8 {
    var fixed_lines = std.ArrayList([]const u8).init(allocator);
    defer fixed_lines.deinit();
    for (src) |line| {
        var new_line = std.ArrayList(u8).init(allocator);
        try new_line.appendSlice(fix);
        try new_line.appendSlice(line);
        var fixed_line = try new_line.toOwnedSlice();
        try fixed_lines.append(fixed_line);
    }
    return fixed_lines.toOwnedSlice();
}

/// suffixes lines with fix.
/// Caller has control of returned value.
pub fn suffix(allocator: std.mem.Allocator, src: [][]const u8, fix: []const u8) ![][]const u8 {
    var fixed_lines = std.ArrayList([]const u8).init(allocator);
    defer fixed_lines.deinit();
    for (src) |line| {
        var new_line = std.ArrayList(u8).init(allocator);
        try new_line.appendSlice(line);
        try new_line.appendSlice(fix);
        var fixed_line = try new_line.toOwnedSlice();
        try fixed_lines.append(fixed_line);
    }
    return fixed_lines.toOwnedSlice();
}
