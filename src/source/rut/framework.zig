const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");
const template = @import("template/api.zig");

pub fn create(allocator: std.mem.Allocator, app_name: []const u8) !void {
    var folders = try paths.folders();
    defer folders.deinit();
    var dir: std.fs.Dir = undefined;
    dir = try std.fs.openDirAbsolute(folders.app.?, .{});

    // build.zig
    var ofile = try dir.createFile(template.build.file_name, .{});
    var context: *template.build.Context = try template.build.initContext(allocator, app_name);
    try template.build.render(ofile, context);
    ofile.close();

    // main.zig
    ofile = try dir.createFile(template.main.file_name, .{});
    try template.main.render(ofile);
    ofile.close();

    // main-test.zig
    ofile = try dir.createFile(template.main_test.file_name, .{});
    try template.main_test.render(ofile);
    ofile.close();
}
