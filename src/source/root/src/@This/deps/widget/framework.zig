const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");
const _tabbar_template_ = @import("tabbar_template.zig");

pub fn create(allocator: std.mem.Allocator) !void {
    // Open the write folder.
    var folders = try paths.folders();
    defer folders.deinit();
    var dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_widget.?, .{});
    defer dir.close();

    {
        // api.zig
        var template: *_api_template_.Template = try _api_template_.init(allocator);
        defer template.deinit();
        var content: []const u8 = try template.content();
        defer allocator.free(content);
        var ofile: std.fs.File = try dir.createFile(_filenames_.api_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(content);
    }

    {
        // tabbar.zig
        var ofile: std.fs.File = try dir.createFile(_filenames_.tabbar_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(_tabbar_template_.content);
    }
}
