const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");
const filenames = @import("filenames");
const api_template = @import("api_template.zig");

pub fn create() !void {
    // Open the write folder.
    var folders = try paths.folders();
    defer folders.deinit();
    var dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_lock.?, .{});
    defer dir.close();

    // api.zig
    var ofile: std.fs.File = try dir.createFile(filenames.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(api_template.content);
}
