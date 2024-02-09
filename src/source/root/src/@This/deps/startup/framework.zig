/// This file builds the deps/startup/ part of the framework.
const std = @import("std");
const fspath = std.fs.path;
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");

/// create adds deps/startup/api.zig
pub fn create() !void {
    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var startup_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_startup.?, .{});
    defer startup_dir.close();

    // Open, write and close the api file.
    var ofile = try startup_dir.createFile(_filenames_.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(_api_template_.content);
}
