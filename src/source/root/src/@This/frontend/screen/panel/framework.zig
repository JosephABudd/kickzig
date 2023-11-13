/// This file builds the frontend/screen/panel/<<screen_name>>/ files.
/// fn create adds:
/// - frontend/panels.zig
/// - frontend/main_menu.zig
const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");
const filenames = @import("filenames");
const panels_template = @import("panels_template.zig");
const any_panel_template = @import("any_panel_template.zig");
const example_panel_template = @import("example_panel_template.zig");
const messenger_template = @import("messenger_template.zig");
const example_messenger_template = @import("example_messenger_template.zig");
const screen_template = @import("screen_template.zig");
const example_screen_template = @import("example_screen_template.zig");

pub fn create(allocator: std.mem.Allocator, screen_name: []const u8) !void {
    // Add the screen.zig file.
    try addScreen(allocator, screen_name);
    // Add the messenger file.
    try addMessenger(allocator, screen_name);
    // Build panels.zig with the initialize channel.
    try buildPanelsZig(allocator, screen_name);
}

pub fn createExample(allocator: std.mem.Allocator, screen_name: []const u8) !void {
    // An example panel file.
    try addExamplePanel(allocator, screen_name);
    // Add the screen.zig file.
    try addExampleScreen(allocator, screen_name);
    // Add the example messenger file.
    try addExampleMessenger(allocator, screen_name);
    // Build panels.zig with the initialize channel.
    try buildPanelsZig(allocator, screen_name);
}

pub fn remove(allocator: std.mem.Allocator, screen_name: []const u8) !void {
    _ = allocator;
    var screen_dir: std.fs.Dir = try directory(null);
    defer screen_dir.close();
    return screen_dir.deleteDir(screen_name);
}

pub fn addExamplePanel(allocator: std.mem.Allocator, screen_name: []const u8) !void {
    var template: *example_panel_template.Template = try example_panel_template.init(allocator, screen_name);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var screen_dir: std.fs.Dir = try directory(screen_name);
    defer screen_dir.close();

    // Open, write and close the file.
    const fname: []const u8 = try filenames.frontendScreenPanelFileName(allocator, "Example");
    defer allocator.free(fname);
    var ofile = try screen_dir.createFile(fname, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

pub fn addAnyPanel(allocator: std.mem.Allocator, screen_name: []const u8, panel_name: []const u8) !void {
    var template: *any_panel_template.Template = try any_panel_template.init(allocator, screen_name, panel_name);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var screen_dir: std.fs.Dir = try directory(screen_name);
    defer screen_dir.close();

    // Open, write and close the file.
    const fname: []const u8 = try filenames.frontendScreenPanelFileName(allocator, panel_name);
    defer allocator.free(fname);
    var ofile = try screen_dir.createFile(fname, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

pub fn removePanel(allocator: std.mem.Allocator, screen_name: []const u8, panel_name: []const u8) !void {
    // Open the folder.
    var screen_dir: std.fs.Dir = try directory(screen_name);
    defer screen_dir.close();
    var fname: []const u8 = try filenames.frontendScreenPanelFileName(allocator, panel_name);
    defer allocator.free(fname);
    try screen_dir.deleteFile(fname);

    // Build panels.zig with all of the remaining panels.
    try buildPanelsZig(allocator, screen_name);
}

fn buildPanelsZig(allocator: std.mem.Allocator, screen_name: []const u8) !void {
    // Build the template and the content.
    const template: *panels_template.Template = try panels_template.init(allocator);
    defer template.deinit();
    // Get the names of each panel and use them in the template.
    var current_panel_names: [][]const u8 = try filenames.allFrontendPanelScreenPanelNames(allocator, screen_name);
    defer {
        for (current_panel_names) |name| {
            allocator.free(name);
        }
        allocator.free(current_panel_names);
    }
    for (current_panel_names) |name| {
        try template.addName(name);
    }
    var content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var screen_dir: std.fs.Dir = try directory(screen_name);
    defer screen_dir.close();

    // Open, write and close the file.
    var ofile = try screen_dir.createFile(filenames.screen_panels_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn addMessenger(allocator: std.mem.Allocator, screen_name: []const u8) !void {
    var template: *messenger_template.Template = try messenger_template.init(allocator, screen_name);
    defer template.deinit();
    var content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var screen_dir: std.fs.Dir = try directory(screen_name);
    defer screen_dir.close();

    // Open, write and close the file.
    var ofile = try screen_dir.createFile(filenames.screen_messenger_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn addExampleMessenger(allocator: std.mem.Allocator, screen_name: []const u8) !void {
    var template: *example_messenger_template.Template = try example_messenger_template.init(allocator, screen_name);
    defer template.deinit();
    var content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var screen_dir: std.fs.Dir = try directory(screen_name);
    defer screen_dir.close();

    // Open, write and close the file.
    var ofile = try screen_dir.createFile(filenames.screen_messenger_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn addScreen(allocator: std.mem.Allocator, screen_name: []const u8) !void {
    var template: *screen_template.Template = try screen_template.init(allocator, screen_name);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var screen_dir: std.fs.Dir = try directory(screen_name);
    defer screen_dir.close();

    // Open, write and close the file.
    var ofile = try screen_dir.createFile(filenames.screen_screen_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn addExampleScreen(allocator: std.mem.Allocator, screen_name: []const u8) !void {
    var template: *example_screen_template.Template = try example_screen_template.init(allocator, screen_name);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var screen_dir: std.fs.Dir = try directory(screen_name);
    defer screen_dir.close();

    // Open, write and close the file.
    var ofile = try screen_dir.createFile(filenames.screen_screen_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

// directory returns the screen's file system directory.
// The caller must close the returned directory.
fn directory(screen_name: ?[]const u8) !std.fs.Dir {
    var folders: *paths.FolderPaths = try paths.folders();
    defer folders.deinit();
    var panel_folder: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_frontend_screen_panel.?, .{});
    if (screen_name == null) {
        return panel_folder;
    }
    // Open the screen folder and return that.
    defer panel_folder.close();
    var screen_folder: std.fs.Dir = undefined;
    if (panel_folder.openDir(screen_name.?, .{})) |folder| {
        screen_folder = folder;
    } else |err| {
        if (err != error.FileNotFound) {
            return err;
        }
        // Screen folder not found so create the screen folder.
        try panel_folder.makeDir(screen_name.?);
        screen_folder = try panel_folder.openDir(screen_name.?, .{});
    }
    return screen_folder;
}
