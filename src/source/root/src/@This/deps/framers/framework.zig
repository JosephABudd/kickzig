/// This file builds the deps/framers/ part of the framework.
/// fn create adds:
/// - deps/framers/api.zig
const std = @import("std");
const paths = @import("paths");
const filenames = @import("filenames");
const api_template = @import("api_template.zig");

pub fn create() !void {
    // Build api.zig with the initialize channel.
    try buildApiZig();
}

fn buildApiZig() !void {
    // Open the folder.
    var folders = try paths.folders();
    defer folders.deinit();
    var framework_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_framers.?, .{});
    defer framework_dir.close();

    // Open, write and close the file.
    var ofile: std.fs.File = try framework_dir.createFile(filenames.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(api_template.content);
}
