/// This file builds the deps/startup/ part of the framework.
const std = @import("std");
const fspath = std.fs.path;
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");
const _container_template_ = @import("container_template.zig");
const _content_template_ = @import("content_template.zig");

/// create adds deps/startup/api.zig
pub fn create() !void {
    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var cont_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_cont.?, .{});
    defer cont_dir.close();

    {
        // Open, write and close the api file.
        var ofile = try cont_dir.createFile(_filenames_.api_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(_api_template_.content);
    }

    {
        // Open, write and close the container.zig file.
        var ofile = try cont_dir.createFile(_filenames_.deps.container_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(_container_template_.content);
    }

    {
        // Open, write and close the content.zig file.
        var ofile = try cont_dir.createFile(_filenames_.deps.content_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(_content_template_.content);
    }
}
