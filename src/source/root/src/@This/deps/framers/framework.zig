/// This file builds the deps/framers/ part of the framework.
/// fn create adds:
/// - deps/framers/api.zig
const std = @import("std");
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");

pub fn create() !void {
    // Build api.zig.
    try buildApiZig();
}

fn buildApiZig() !void {
    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var framework_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_framers.?, .{});
    defer framework_dir.close();

    // Open, write and close the file.
    var ofile: std.fs.File = try framework_dir.createFile(_filenames_.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(_api_template_.content);
}
