/// This file builds the backend/messenger/ part of the framework.
/// fn create adds:
/// - backend/messenger/api.zig
/// - backend/messenger/src/<< message name >>.zig
const std = @import("std");
const fspath = std.fs.path;
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");
pub const window_icon_png_content = @embedFile("zig-favicon.png");

pub fn create(allocator: std.mem.Allocator) !void {
    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var embed_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_embed.?, .{});
    defer embed_dir.close();

    {
        // Open, write and close the api.zig file.
        const content: []const u8 = try _api_template_.content(allocator);
        var ofile = try embed_dir.createFile(_filenames_.api_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(content);
    }

    {
        // Open, write and close the icon file.
        var ofile = try embed_dir.createFile(_filenames_.deps.window_icon_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(window_icon_png_content);
    }
}
