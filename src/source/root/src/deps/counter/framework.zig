const std = @import("std");
const fspath = std.fs.path;
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");

pub fn create() !void {
    // Open the write folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_counter.?, .{});
    defer dir.close();

    // api.zig
    var ofile: std.fs.File = try dir.createFile(_filenames_.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(_api_template_.content);
}
