const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");
const filenames = @import("filenames");
const api_template = @import("api_template.zig");
const tabbar_template = @import("tabbar_template.zig");

pub fn create(allocator: std.mem.Allocator) !void {
    // Open the write folder.
    var folders = try paths.folders();
    defer folders.deinit();
    var dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_widget.?, .{});
    defer dir.close();

    {
        // api.zig
        var template: *api_template.Template = try api_template.init(allocator);
        defer template.deinit();
        var content: []const u8 = try template.content();
        defer allocator.free(content);
        var ofile: std.fs.File = try dir.createFile(filenames.api_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(content);
    }

    {
        // tabbar.zig
        var ofile: std.fs.File = try dir.createFile(filenames.tabbar_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(tabbar_template.content);
    }
}
