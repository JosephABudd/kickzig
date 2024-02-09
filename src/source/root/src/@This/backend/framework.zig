const std = @import("std");
const paths = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");
const _messenger_ = @import("messenger/framework.zig");

pub const messenger = _messenger_;

pub fn create(allocator: std.mem.Allocator) !void {
    // Open the folder.
    const folders = try paths.folders();
    defer folders.deinit();
    var backend_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_backend.?, .{});
    defer backend_dir.close();

    // Open, write and close the file.
    var ofile: std.fs.File = try backend_dir.createFile(_filenames_.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(_api_template_.content);

    // Create the files for the backend/messenger folder.
    try _messenger_.create(allocator);
}
