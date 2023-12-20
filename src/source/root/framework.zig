const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");
const _filenames_ = @import("filenames");
const _build_template_ = @import("build_template.zig");
const _build_zon_template_ = @import("build_zon_template.zig");
const _standalone_template_ = @import("standalone_template.zig");
const _src_this_backend_ = @import("src/@This/backend/framework.zig");
const _src_this_frontend_ = @import("src/@This/frontend/framework.zig");
const _src_this_deps_ = @import("source_deps");

pub const frontend = _src_this_frontend_;
pub const backend = _src_this_backend_;
pub const deps = _src_this_deps_;

/// recreate rebuilds root/src/@This/ entirely.
pub fn recreate(allocator: std.mem.Allocator, app_name: []const u8) !void {
    try _src_this_backend_.create(allocator);
    try _src_this_frontend_.create(allocator, app_name);
    try _src_this_deps_.create(allocator);
}

pub fn create(allocator: std.mem.Allocator, app_name: []const u8) !void {
    // Open the write folder.
    var folders = try paths.folders();
    defer folders.deinit();
    var root_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root.?, .{});
    defer root_dir.close();
    var ofile: std.fs.File = undefined;

    {
        // build.zig
        ofile = try root_dir.createFile(_filenames_.build_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(_build_template_.content);
    }

    {
        // build.zon.zig
        ofile = try root_dir.createFile(_filenames_.build_zon_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(_build_zon_template_.content);
    }

    {
        // standalone-sdl.zig
        // Build the data for the template.
        var template: *_standalone_template_.Template = try _standalone_template_.Template.init(allocator, app_name);
        defer template.deinit();
        var content: []const u8 = try template.content();
        defer allocator.free(content);

        // Open, write and close the file.
        ofile = try root_dir.createFile(_filenames_.standalone_sdl_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(content);
    }

    try _src_this_backend_.create(allocator);
    try _src_this_frontend_.create(allocator, app_name);
    try _src_this_deps_.create(allocator);
}
