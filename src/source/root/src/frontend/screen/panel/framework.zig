/// This file builds manages panel screens.
const std = @import("std");
const fspath = std.fs.path;
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");
const _panels_template_ = @import("panels_template.zig");
const _any_panel_template_ = @import("any_panel_template.zig");
const _any_view_template_ = @import("view/any_view_template.zig");
const _messenger_template_ = @import("view/messenger_template.zig");
const _screen_template_ = @import("screen_template.zig");

/// createAnyPackage creates the panel screen folder.
/// The folder only contains:
/// * The screen.zig file.
/// * The panels.zig file. See buildPanelsZig.
/// * The panel files.
/// * Each panel's view file in view/.
/// * The view/messenger.zig file.
pub fn createAnyPackage(allocator: std.mem.Allocator, screen_name: []const u8, panel_names: [][]const u8, use_messenger: bool, use_extra_examples: bool) !void {
    // Open/Create the screen package folder.
    var package_dir: std.fs.Dir = try directory(screen_name);
    defer package_dir.close();
    var package_view_dir: std.fs.Dir = try viewDirectory(screen_name);
    defer package_view_dir.close();

    // Add the screen.zig file.
    try addScreenFile(allocator, package_dir, screen_name, panel_names[0], use_messenger, use_extra_examples);
    // Add each panel file and each panel's view file in view/.
    for (panel_names) |panel_name| {
        try addAnyPanel(allocator, package_dir, screen_name, panel_name, use_messenger);
        try addAnyView(allocator, package_view_dir, screen_name, panel_name, panel_names, use_messenger, use_extra_examples);
    }
    // buildPanelsZig builds panels.zig with the names of each panel.
    try buildPanelsZig(allocator, package_dir, screen_name, use_messenger);
    if (use_messenger) {
        // Add the messenger file.
        try addMessengerFile(allocator, package_view_dir, screen_name, panel_names);
    }
}

pub fn create(allocator: std.mem.Allocator, use_messenger: bool) !void {
    // All of the panel screens can be removed from the frontend/screens/panel/ folder.
    // So it needs a git keep file.
    var panel_screens_dir: std.fs.Dir = try directory(null);
    defer panel_screens_dir.close();
    try _filenames_.addGitKeepFile(panel_screens_dir);
    // Add the hello world panel screen.
    try createAnyPackage(allocator, _paths_.folder_name_helloworld, @constCast(&[_][]const u8{_paths_.folder_name_helloworld}), use_messenger, true);
}

/// remove removes a panel screen package folder and files.
/// Returns if the screen is a panel screen and was removed.
pub fn remove(screen_name: []const u8) !bool {
    var dir: std.fs.Dir = directory(null) catch {
        return false;
    };
    defer dir.close();
    // Does the screen's folder exist?
    var sub_dir: std.fs.Dir = dir.openDir(screen_name, .{}) catch {
        // No  the screen's folder does not exist.
        return false;
    };
    // Yes the screen's folder exists so close it.
    sub_dir.close();
    // Delete the screen's folder.
    dir.deleteTree(screen_name) catch {
        return false;
    };
    return true;
}

/// addAnyPanel adds a single panel file to a screen.
pub fn addAnyPanel(allocator: std.mem.Allocator, package_dir: std.fs.Dir, screen_name: []const u8, panel_name: []const u8, use_messenger: bool) !void {
    var template: *_any_panel_template_.Template = try _any_panel_template_.Template.init(allocator, screen_name, panel_name, use_messenger);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open, write and close the file.
    const fname: []const u8 = try _filenames_.frontendScreenPanelFileName(allocator, panel_name);
    defer allocator.free(fname);
    var ofile = try package_dir.createFile(fname, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

/// addAnyView adds a single panel file to a screen.
pub fn addAnyView(allocator: std.mem.Allocator, package_view_dir: std.fs.Dir, screen_name: []const u8, panel_name: []const u8, panel_names: [][]const u8, use_messenger: bool, use_extra_examples: bool) !void {
    var template: *_any_view_template_.Template = try _any_view_template_.Template.init(allocator, screen_name, panel_name, panel_names, use_messenger, use_extra_examples);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open, write and close the file.
    const fname: []const u8 = try _filenames_.frontendScreenPanelFileName(allocator, panel_name);
    defer allocator.free(fname);
    var ofile = try package_view_dir.createFile(fname, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

// buildPanelsZig builds the panels.zig file.
// It rebuilds using the names of each panel file in the screen package.
// Call this after panels are added or removed.
pub fn buildPanelsZig(allocator: std.mem.Allocator, package_dir: std.fs.Dir, screen_name: []const u8, use_messenger: bool) !void {
    // Build the template and the content.
    const template: *_panels_template_.Template = try _panels_template_.Template.init(allocator, use_messenger);
    defer template.deinit();
    // Get the names of each panel and use them in the template.
    const current_panel_names: [][]const u8 = try _filenames_.allFrontendPanelScreenPanelNames(allocator, screen_name);
    defer {
        for (current_panel_names) |name| {
            allocator.free(name);
        }
        allocator.free(current_panel_names);
    }
    for (current_panel_names) |name| {
        try template.addName(name);
    }
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open, write and close the file.
    var ofile = try package_dir.createFile(_filenames_.screen_panels_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

/// addMessengerFile adds the messenger.zig to a screen package.
fn addMessengerFile(allocator: std.mem.Allocator, package_view_dir: std.fs.Dir, screen_name: []const u8, panel_names: [][]const u8) !void {
    // Open, write and close the file.
    const content: []const u8 = try _messenger_template_.content(allocator, screen_name, panel_names[0]);
    defer allocator.free(content);
    var ofile = try package_view_dir.createFile(_filenames_.screen_messenger_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

// addScreenFile adds the screen.zig file to any screen.
fn addScreenFile(allocator: std.mem.Allocator, package_dir: std.fs.Dir, screen_name: []const u8, default_panel_name: []const u8, use_messenger: bool, use_extra_examples: bool) !void {
    var template: *_screen_template_.Template = try _screen_template_.Template.init(allocator, screen_name, default_panel_name, use_messenger, use_extra_examples);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open, write and close the file.
    var ofile = try package_dir.createFile(_filenames_.screen_screen_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

// directory returns the screen's file system directory.
// The caller must close the returned directory.
fn directory(screen_name: ?[]const u8) !std.fs.Dir {
    const folders: *_paths_.FolderPaths = try _paths_.folders();
    defer folders.deinit();
    var panel_folder: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_frontend_screen_panel.?, .{});
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

// directory returns the screen's file system directory.
// The caller must close the returned directory.
fn viewDirectory(screen_name: ?[]const u8) !std.fs.Dir {
    var screen_folder: std.fs.Dir = try directory(screen_name);
    defer screen_folder.close();
    // Screen folder not found so create the screen folder.
    var view_folder: std.fs.Dir = undefined;
    try screen_folder.makeDir(_paths_.folder_name_view);
    view_folder = try screen_folder.openDir(_paths_.folder_name_view, .{});
    return view_folder;
}
