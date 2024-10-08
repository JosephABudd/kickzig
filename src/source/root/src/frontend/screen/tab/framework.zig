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

// create adds the .git_keep_this_folder file.
pub fn create() !void {
    // All of the screens can be removed from this folder.
    // So it needs a git keep file.
    var package_dir: std.fs.Dir = try directory(null);
    defer package_dir.close();
    try _filenames_.addGitKeepFile(package_dir);
}

/// add creates a tab screen folder and package.
pub fn add(allocator: std.mem.Allocator, screen_name: []const u8, tab_names: [][]const u8, use_messenger: bool) !void {
    // Open/Create the screen package folder.
    var package_dir: std.fs.Dir = try directory(screen_name);
    defer package_dir.close();
    var package_view_dir: std.fs.Dir = try viewDirectory(screen_name);
    defer package_view_dir.close();

    // Add the screen.zig file.
    try addScreenFile(allocator, package_dir, screen_name, tab_names, use_messenger);
    // Add the panel files.
    // Tab names not prefixed with 'p' or 't' (formerly '*') use a package panel and it's view.
    var count_panels: usize = 0;
    for (tab_names) |tab_name| {
        if (tab_name[0] != 'p' and tab_name[0] != 't') {
            count_panels += 1;
            try addAnyPanel(allocator, package_dir, screen_name, tab_name, use_messenger);
            try addAnyView(allocator, package_view_dir, screen_name, tab_name, use_messenger);
        }
    }
    if (use_messenger) {
        // Add the messenger file.
        try addMessengerFile(allocator, package_view_dir, screen_name, tab_names);
    }
    try rebuildPanelsZig(allocator, package_dir, screen_name);
}

/// remove removes a tab screen package folder and files.
/// Returns if the screen is a tab screen and was removed.
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
/// It does not rewrite the package's panels.zig file.
/// Caller must call rebuildPanelsZig after all panels are added.
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
pub fn addAnyView(allocator: std.mem.Allocator, package_view_dir: std.fs.Dir, screen_name: []const u8, panel_name: []const u8, use_messenger: bool) !void {
    var template: *_any_view_template_.Template = try _any_view_template_.Template.init(allocator, screen_name, panel_name, use_messenger);
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

// rebuildPanelsZig rebuilds the panels.zig file.
// It rebuilds using the names of each panel file in the screen package.
// Call this after panels are added or removed.
pub fn rebuildPanelsZig(allocator: std.mem.Allocator, package_dir: std.fs.Dir, screen_name: []const u8) !void {
    // Build the template and the content.
    const template: *_panels_template_.Template = try _panels_template_.init(allocator);
    defer template.deinit();
    // Get the names of each panel and use them in the template.
    const current_panel_names: [][]const u8 = try _filenames_.allFrontendTabScreenPanelNames(allocator, screen_name);
    defer {
        for (current_panel_names, 0..) |name, i| {
            _ = i;
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
fn addMessengerFile(allocator: std.mem.Allocator, package_view_dir: std.fs.Dir, screen_name: []const u8, tab_names: [][]const u8) !void {
    var panel_name: []const u8 = "Pretend";
    for (tab_names) |tab_name| {
        if (tab_name[0] != 'p' and tab_name[0] != 't') {
            panel_name = tab_name;
            break;
        }
    }
    // Open, write and close the file.
    const content: []const u8 = try _messenger_template_.content(allocator, screen_name, panel_name);
    defer allocator.free(content);
    var ofile = try package_view_dir.createFile(_filenames_.screen_messenger_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

// addScreenFile adds the screen.zig file to any tab screen.
fn addScreenFile(allocator: std.mem.Allocator, package_dir: std.fs.Dir, screen_name: []const u8, tab_names: [][]const u8, use_messenger: bool) !void {
    var template: *_screen_template_.Template = try _screen_template_.Template.init(allocator, screen_name, tab_names, use_messenger);
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
    var tab_folder: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_frontend_screen_tab.?, .{});
    if (screen_name == null) {
        return tab_folder;
    }
    // Open the screen folder and return that.
    defer tab_folder.close();
    var screen_folder: std.fs.Dir = undefined;
    if (tab_folder.openDir(screen_name.?, .{})) |folder| {
        screen_folder = folder;
    } else |err| {
        if (err != error.FileNotFound) {
            return err;
        }
        // Screen folder not found so create the screen folder.
        try tab_folder.makeDir(screen_name.?);
        screen_folder = try tab_folder.openDir(screen_name.?, .{});
    }
    return screen_folder;
}

// directory returns the screen's view/ file system directory.
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
