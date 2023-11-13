/// This file builds the frontend/screen/modal/OK/ files.
const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");
const filenames = @import("filenames");
const panels_template = @import("panels_template.zig");
const ok_panel_template = @import("ok_panel_template.zig");
const messenger_template = @import("messenger_template.zig");
const screen_template = @import("screen_template.zig");
const screen_name: []const u8 = paths.modal_folder_name_ok;

pub fn create(allocator: std.mem.Allocator) !void {
    // Add the OK_panel.zig file.
    try addOKPanel(allocator);
    // Add the screen.zig file.
    try addScreen();
    // Add the messenger file.
    try addMessenger();
    // Build panels.zig with the initialize channel.
    try addPanelsZig();
}

pub fn addOKPanel(allocator: std.mem.Allocator) !void {
    // Open the folder.
    var screen_dir: std.fs.Dir = try directory();
    defer screen_dir.close();

    // Open, write and close the file.
    // This panel file has the same name as the screen. "OK".
    const fname: []const u8 = try filenames.frontendScreenPanelFileName(allocator, screen_name);
    defer allocator.free(fname);
    var ofile = try screen_dir.createFile(fname, .{});
    defer ofile.close();
    try ofile.writeAll(ok_panel_template.content);
}

fn addPanelsZig() !void {
    // Open the folder.
    var screen_dir: std.fs.Dir = try directory();
    defer screen_dir.close();

    // Open, write and close the file.
    var ofile = try screen_dir.createFile(filenames.screen_panels_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(panels_template.content);
}

fn addMessenger() !void {
    // Open the folder.
    var screen_dir: std.fs.Dir = try directory();
    defer screen_dir.close();

    // Open, write and close the file.
    var ofile = try screen_dir.createFile(filenames.screen_messenger_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(messenger_template.content);
}

fn addScreen() !void {
    // Open the folder.
    var screen_dir: std.fs.Dir = try directory();
    defer screen_dir.close();

    // Open, write and close the file.
    var ofile = try screen_dir.createFile(filenames.screen_screen_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(screen_template.content);
}

// directory returns the screen's file system directory.
// The caller must close the returned directory.
fn directory() !std.fs.Dir {
    var folders: *paths.FolderPaths = try paths.folders();
    defer folders.deinit();
    return try std.fs.openDirAbsolute(folders.root_src_this_frontend_screen_modal_ok.?, .{});
}
