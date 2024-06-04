/// This file builds manages panel screens.
const std = @import("std");
const fspath = std.fs.path;
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");
const _panels_template_ = @import("panels_template.zig");
const _any_panel_template_ = @import("any_panel_template.zig");
const _messenger_template_ = @import("messenger_template.zig");
const _screen_template_ = @import("screen_template.zig");
const _helloworld_screen_template_ = @import("helloworld_screen_template.zig");
const _helloworld_panel_template_ = @import("helloworld_panel_template.zig");
const _helloworld_messenger_template_ = @import("helloworld_messenger_template.zig");

/// createAnyPackage creates the panel screen folder.
/// The folder only contains:
/// * The screen.zig file.
/// * The messenger.zig file.
/// The folder does not contain:
/// * Any panel files. See addAnyPanel and removePanel.
/// * The panels.zig file. See rebuildPanelsZig.
pub fn createAnyPackage(allocator: std.mem.Allocator, screen_name: []const u8, panel_names: [][]const u8, only_frame_in_container: bool) !void {
    // Open/Create the screen package folder.
    var package_dir: std.fs.Dir = try directory(screen_name);
    defer package_dir.close();
    // Add the screen.zig file.
    try addScreenFile(allocator, package_dir, screen_name, panel_names[0], only_frame_in_container);
    // Add the messenger file.
    try addMessengerFile(allocator, package_dir, screen_name);
    // Add each panel file.
    for (panel_names) |panel_name| {
        try addAnyPanel(allocator, package_dir, screen_name, panel_name);
    }
    // rebuildPanelsZig builds panels.zig with the names of each panel.
    try rebuildPanelsZig(allocator, package_dir, screen_name);
}

pub fn create(allocator: std.mem.Allocator) !void {
    // All of the screens can be removed from this folder.
    // So it needs a git keep file.
    var package_dir: std.fs.Dir = try directory(null);
    defer package_dir.close();
    try _filenames_.addGitKeepFile(package_dir);
    return createHelloWorldPackage(allocator);
}

/// createHelloWorldPackage adds the complete Example screen folder and package.
fn createHelloWorldPackage(allocator: std.mem.Allocator) !void {
    // Open/Create the screen package folder.
    var package_dir: std.fs.Dir = try directory("HelloWorld");
    defer package_dir.close();

    // The hello world panel file.
    try addHelloWorldPanel(allocator, package_dir);
    // Add the screen.zig file.
    try addHelloWorldScreenFile(package_dir);
    // Add the example messenger file.
    try addHelloWorldMessengerFile(package_dir);
    // rebuildPanelsZig builds panels.zig with the names of each panel.
    try rebuildPanelsZig(allocator, package_dir, "HelloWorld");
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

/// addHelloWorldPanel the HelloWorld panel file to the HelloWorld screen.
pub fn addHelloWorldPanel(allocator: std.mem.Allocator, package_dir: std.fs.Dir) !void {
    // Open, write and close the file.
    const fname: []const u8 = try _filenames_.frontendScreenPanelFileName(allocator, "HelloWorld");
    defer allocator.free(fname);
    var ofile = try package_dir.createFile(fname, .{});
    defer ofile.close();
    try ofile.writeAll(_helloworld_panel_template_.content);
}

/// addAnyPanel adds a single panel file to a screen.
/// It does not rewrite the package's panels.zig file.
/// Caller must call rebuildPanelsZig after all panels are added.
pub fn addAnyPanel(allocator: std.mem.Allocator, package_dir: std.fs.Dir, screen_name: []const u8, panel_name: []const u8) !void {
    var template: *_any_panel_template_.Template = try _any_panel_template_.init(allocator, screen_name, panel_name);
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

/// removePanel removes a single panel file from a screen.
/// It does not rewrite the package's panels.zig file.
/// Caller must call rebuildPanelsZig after all panels are removed.
pub fn removePanel(allocator: std.mem.Allocator, screen_name: []const u8, panel_name: []const u8) !void {
    // Open the folder.
    var screen_dir: std.fs.Dir = try directory(screen_name);
    defer screen_dir.close();
    const fname: []const u8 = try _filenames_.frontendScreenPanelFileName(allocator, panel_name);
    defer allocator.free(fname);
    try screen_dir.deleteFile(fname);
}

// rebuildPanelsZig rebuilds the panels.zig file.
// It rebuilds using the names of each panel file in the screen package.
// Call this after panels are added or removed.
pub fn rebuildPanelsZig(allocator: std.mem.Allocator, package_dir: std.fs.Dir, screen_name: []const u8) !void {
    // Build the template and the content.
    const template: *_panels_template_.Template = try _panels_template_.init(allocator);
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
fn addMessengerFile(allocator: std.mem.Allocator, package_dir: std.fs.Dir, screen_name: []const u8) !void {
    var template: *_messenger_template_.Template = try _messenger_template_.init(allocator, screen_name);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open, write and close the file.
    var ofile = try package_dir.createFile(_filenames_.screen_messenger_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

/// addHelloWorldMessengerFile adds the messenger.zig to the Example screen package.
fn addHelloWorldMessengerFile(package_dir: std.fs.Dir) !void {
    // Open, write and close the file.
    var ofile = try package_dir.createFile(_filenames_.screen_messenger_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(_helloworld_messenger_template_.content);
}

// addScreenFile adds the screen.zig file to any screen.
fn addScreenFile(allocator: std.mem.Allocator, package_dir: std.fs.Dir, screen_name: []const u8, default_panel_name: []const u8, only_frame_in_container: bool) !void {
    var template: *_screen_template_.Template = try _screen_template_.init(allocator, screen_name, default_panel_name, only_frame_in_container);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open, write and close the file.
    var ofile = try package_dir.createFile(_filenames_.screen_screen_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

// addHelloWorldScreenFile adds the screen.zig file to the Example screen.
fn addHelloWorldScreenFile(package_dir: std.fs.Dir) !void {
    // Open, write and close the file.
    var ofile = try package_dir.createFile(_filenames_.screen_screen_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(_helloworld_screen_template_.content);
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
