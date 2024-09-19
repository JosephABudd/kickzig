const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");
const _filenames_ = @import("filenames");
const _main_template_ = @import("main_template.zig");
const _root_template_ = @import("root_template.zig");
const _src_backend_ = @import("backend/framework.zig");
const _src_frontend_ = @import("frontend/framework.zig");
const _src_deps_ = @import("source_deps");
const window_icon_png = @embedFile("zig-favicon.png");

pub const frontend = _src_frontend_;
pub const backend = _src_backend_;
pub const deps = _src_deps_;

/// recreate rebuilds root/ entirely.
pub fn recreate(allocator: std.mem.Allocator, app_name: []const u8, use_messenger: bool) !void {
    try create(allocator, app_name, use_messenger);
}

pub fn create(allocator: std.mem.Allocator, app_name: []const u8, use_messenger: bool) !void {
    // Open the write folder.
    const folders = try paths.folders();
    defer folders.deinit();
    var src_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src.?, .{});
    defer src_dir.close();
    var ofile: std.fs.File = undefined;

    {
        // main.zig
        // Build the data for the template.
        var template: *_main_template_.Template = try _main_template_.Template.init(allocator, app_name);
        defer template.deinit();
        const content: []const u8 = try template.content();
        defer allocator.free(content);

        // Open, write and close the file.
        ofile = try src_dir.createFile(_filenames_.main_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(content);
    }

    {
        // root.zig
        // Open, write and close the file.
        ofile = try src_dir.createFile(_filenames_.root_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(_root_template_.content);
    }

    {
        // zig-favicon.png
        // Open, write and close the file.
        ofile = try src_dir.createFile(_filenames_.favicon_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(window_icon_png);
    }

    try _src_backend_.create(allocator);
    try _src_frontend_.create(allocator, app_name, use_messenger);
    try _src_deps_.create(allocator);
}
