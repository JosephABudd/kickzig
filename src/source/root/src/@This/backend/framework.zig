const std = @import("std");
const paths = @import("paths");
const filenames = @import("filenames");
const api_template = @import("api_template.zig");
const messenger = @import("messenger/framework.zig");

pub fn create(allocator: std.mem.Allocator) !void {
    // Open the folder.
    var folders = try paths.folders();
    defer folders.deinit();
    var backend_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_backend.?, .{});
    defer backend_dir.close();

    // Open, write and close the file.
    var ofile: std.fs.File = try backend_dir.createFile(filenames.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(api_template.content);

    // Create the files for the backend/messenger folder.
    try messenger.create(allocator);
}
