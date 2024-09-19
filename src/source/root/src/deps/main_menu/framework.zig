/// This file builds the backend/messenger/ part of the framework.
/// fn create adds:
/// - backend/messenger/api.zig
/// - backend/messenger/src/<< message name >>.zig
const std = @import("std");
const fspath = std.fs.path;
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");

pub fn create() !void {
    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var main_menu_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_main_menu.?, .{});
    defer main_menu_dir.close();

    // Open, write and close the file.
    var ofile = try main_menu_dir.createFile(_filenames_.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(_api_template_.content);
}
