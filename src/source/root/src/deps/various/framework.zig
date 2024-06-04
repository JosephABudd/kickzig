const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");

pub fn create() !void {
    // Open the write folder.
    const folders = try paths.folders();
    defer folders.deinit();
    var dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_various.?, .{});
    defer dir.close();

    {
        // api.zig
        var ofile: std.fs.File = try dir.createFile(_filenames_.api_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(_api_template_.content);
    }
}
