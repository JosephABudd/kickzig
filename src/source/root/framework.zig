const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");
const _filenames_ = @import("filenames");
const _build_template_ = @import("build_template.zig");
const _build_zon_template_ = @import("build_zon_template.zig");
pub const _src_ = @import("src/framework.zig");

/// recreate rebuilds root/src/ entirely.
pub fn recreate(allocator: std.mem.Allocator, app_name: []const u8) !void {
    try _src_.recreate(allocator, app_name);
}

pub fn create(allocator: std.mem.Allocator, app_name: []const u8) !void {
    // Open the write folder.
    const folders = try paths.folders();
    defer folders.deinit();
    var root_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root.?, .{});
    defer root_dir.close();
    var ofile: std.fs.File = undefined;

    {
        // build.zig
        // Build the data for the template.
        var template: *_build_template_.Template = try _build_template_.Template.init(allocator, app_name);
        defer template.deinit();
        const content: []const u8 = try template.content();
        defer allocator.free(content);

        ofile = try root_dir.createFile(_filenames_.build_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(content);
    }

    {
        // build.zon.zig
        // Build the data for the template.
        var template: *_build_zon_template_.Template = try _build_zon_template_.Template.init(allocator, app_name);
        defer template.deinit();
        const content: []const u8 = try template.content();
        defer allocator.free(content);

        ofile = try root_dir.createFile(_filenames_.build_zon_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(content);
    }

    try _src_.create(allocator, app_name);
}
