const std = @import("std");
const _filenames_ = @import("filenames");

/// The caller owns the returned value.
pub fn content(allocator: std.mem.Allocator) ![]const u8 {
    return std.fmt.allocPrint(allocator, content_f, .{_filenames_.deps.window_icon_file_name});
}

/// {0s} is _filenames_.deps.window_icon_file_name.
const content_f: []const u8 =
    \\/// KICKZIG TODO:
    \\/// This file was created when you created the framework.
    \\/// You are free to edit this file.
    \\/// 1. Add the file to this folder.
    \\/// 2. Add the pub const here.
    \\
    \\pub const window_icon_png = @embedFile("{0s}");
    \\
;
