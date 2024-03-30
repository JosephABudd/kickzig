const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");
const _tabbar_api_template_ = @import("tabbar/api_template.zig");
const _tabbar_widget_template_ = @import("tabbar/tabbar_widget_template.zig");
const _tabbar_item_widget_template_ = @import("tabbar/tabbar_item_widget_template.zig");

pub fn create() !void {
    // Open the write folder.
    const folders = try paths.folders();
    defer folders.deinit();

    {
        var dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_widget.?, .{});
        defer dir.close();

        // api.zig
        var ofile: std.fs.File = try dir.createFile(_filenames_.api_file_name, .{});
        defer ofile.close();
        try ofile.writeAll(_api_template_.content);
    }

    // Tabbar widgets.

    {
        var dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_widget_tabbar.?, .{});
        defer dir.close();

        {
            // tabbar/api.zig
            var ofile: std.fs.File = try dir.createFile(_filenames_.api_file_name, .{});
            defer ofile.close();
            try ofile.writeAll(_tabbar_api_template_.content);
        }
        {
            // tabbar/TabBarWidget.zig
            var ofile: std.fs.File = try dir.createFile(_filenames_.deps.tabbar_widget_file_name, .{});
            defer ofile.close();
            try ofile.writeAll(_tabbar_widget_template_.content);
        }
        {
            // tabbar/TabBarItemWidget.zig
            var ofile: std.fs.File = try dir.createFile(_filenames_.deps.tabbar_item_widget_file_name, .{});
            defer ofile.close();
            try ofile.writeAll(_tabbar_item_widget_template_.content);
        }
    }
}
