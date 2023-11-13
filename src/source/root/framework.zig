const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");
const filenames = @import("filenames");
const build_template = @import("build_template.zig");
const build_zon_template = @import("build_zon_template.zig");
const standalone_template = @import("standalone_template.zig");
const src_this_backend = @import("src/@This/backend/framework.zig");
const src_this_frontend = @import("src/@This/frontend/framework.zig");
const src_this_deps = @import("src/@This/deps/framework.zig");

/// recreate rebuilds root/src/@This/ entirely.
pub fn recreate(allocator: std.mem.Allocator, app_name: []const u8) !void {
    try src_this_backend.create(allocator);
    try src_this_frontend.create(allocator, app_name);
    try src_this_deps.create(allocator);
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
        ofile = try root_dir.createFile(filenames.build_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(build_template.content);
    }

    {
        // build.zon.zig
        ofile = try root_dir.createFile(filenames.build_zon_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(build_zon_template.content);
    }

    {
        // standalone-sdl.zig
        // Build the data for the template.
        var template: *standalone_template.Template = try standalone_template.Template.init(allocator, paths.folder_name_this);
        defer template.deinit();
        var content: []const u8 = try template.content();
        defer allocator.free(content);

        // Open, write and close the file.
        ofile = try root_dir.createFile(filenames.standalone_sdl_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(content);
    }

    try src_this_backend.create(allocator);
    try src_this_frontend.create(allocator, app_name);
    try src_this_deps.create(allocator);
}
