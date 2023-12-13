/// This file builds the frontend/ part of the framework.
/// fn create adds:
/// - frontend/api.zig
/// - frontend/main_menu.zig
const std = @import("std");
const fspath = std.fs.path;
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");
const _main_menu_template_ = @import("main_menu_template.zig");
const _stdout_ = @import("stdout");
const _screen_ = @import("screen/framework.zig");
const _panel_screen_ = @import("screen/panel/framework.zig");
const _vtab_screen_ = @import("screen/vtab/framework.zig");
const _htab_screen_ = @import("screen/htab/framework.zig");
const _book_screen_ = @import("screen/book/framework.zig");
const _modal_screen_ = @import("screen/modal/framework.zig");
const _modal_params_ = @import("source_deps").modal_params;

pub fn create(allocator: std.mem.Allocator, app_name: []const u8) !void {
    // Add the main menu file which is a data file.
    // It sets the default landing screen.
    try rebuildMainMenu(allocator);
    // Add the default landing screen.
    // It contains lots of example code.
    try _panel_screen_.createHelloWorldPackage(allocator);
    // Add the OK modal screen.
    try _modal_screen_.create(allocator);
    // Build api.zig with the initialize channel.
    try rebuildApiZig(allocator, app_name);
}

// List screens.

pub fn listScreens(allocator: std.mem.Allocator) !void {
    return _screen_.listScreens(allocator);
}

// rebuildMainMenu builds frontend/main_menu.zig
fn rebuildMainMenu(allocator: std.mem.Allocator) !void {
    var template: *_main_menu_template_.Template = try _main_menu_template_.init(allocator);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var frontend_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_frontend.?, .{});
    defer frontend_dir.close();

    // Open, write and close the file.
    var ofile = try frontend_dir.createFile(_filenames_.frontent_main_menu_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

// rebuildApiZig builds frontent/api.zig.
fn rebuildApiZig(allocator: std.mem.Allocator, app_name: []const u8) !void {
    // Build the template and the content.
    const template: *_api_template_.Template = try _api_template_.init(allocator, app_name);
    defer template.deinit();

    // Add the names of each panel screen.
    var panel_screen_names: [][]const u8 = try _filenames_.frontend.allPanelFolders(allocator);
    defer {
        for (panel_screen_names) |panel_screen_name| {
            allocator.free(panel_screen_name);
        }
        allocator.free(panel_screen_names);
    }
    for (panel_screen_names) |panel_screen_name| {
        try template.addPanelScreenName(panel_screen_name);
    }
    // Add the names of each vtab screen.
    var vtab_screen_names: [][]const u8 = try _filenames_.frontend.allVTabFolders(allocator);
    defer {
        for (vtab_screen_names) |vtab_screen_name| {
            allocator.free(vtab_screen_name);
        }
        allocator.free(vtab_screen_names);
    }
    for (vtab_screen_names) |vtab_screen_name| {
        try template.addVTabScreenName(vtab_screen_name);
    }
    // Add the names of each htab screen.
    var htab_screen_names: [][]const u8 = try _filenames_.frontend.allHTabFolders(allocator);
    defer {
        for (htab_screen_names) |htab_screen_name| {
            allocator.free(htab_screen_name);
        }
        allocator.free(htab_screen_names);
    }
    for (htab_screen_names) |htab_screen_name| {
        try template.addHTabScreenName(htab_screen_name);
    }
    // Add the names of each book screen.
    var book_screen_names: [][]const u8 = try _filenames_.frontend.allBookFolders(allocator);
    defer {
        for (book_screen_names) |book_screen_name| {
            allocator.free(book_screen_name);
        }
        allocator.free(book_screen_names);
    }
    for (book_screen_names) |book_screen_name| {
        try template.addBookScreenName(book_screen_name);
    }
    // Add the names of each modal screen.
    var modal_screen_names: [][]const u8 = try _filenames_.frontend.allModalFolders(allocator);
    defer {
        for (modal_screen_names) |modal_screen_name| {
            allocator.free(modal_screen_name);
        }
        allocator.free(modal_screen_names);
    }
    for (modal_screen_names) |modal_screen_name| {
        try template.addModalScreenName(modal_screen_name);
    }

    var content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_frontend.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    var ofile = try messenger_dir.createFile(_filenames_.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

// Add or remove panel screens.

/// addPanelScreen creates a panel screen and adds rebuilds api.zig.
pub fn addPanelScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8, panel_names: [][]const u8) !void {
    try _panel_screen_.createAnyPackage(allocator, screen_name, panel_names);
    try rebuildApiZig(allocator, app_name);
}

/// removePanelScreen removes a screen folder and rebuilds api.zig.
pub fn removePanelScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8) !bool {
    var removed: bool = false;
    defer {
        if (removed) {}
    }
    removed = try _panel_screen_.remove(screen_name);
    if (removed) {
        // Removed a panel screen.
        try rebuildApiZig(allocator, app_name);
    }
    return removed;
}

// Add or remove vtab screens.

pub fn addVTabScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8, tab_names: [][]const u8) !void {
    try _vtab_screen_.add(allocator, screen_name, tab_names);
    try rebuildApiZig(allocator, app_name);
}

pub fn removeVTabScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8) !bool {
    var removed: bool = try _vtab_screen_.remove(screen_name);
    if (removed) {
        try rebuildApiZig(allocator, app_name);
    }
    return removed;
}

// Add or remove htab screens.

pub fn addHTabScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8, tab_names: [][]const u8) !void {
    try _htab_screen_.add(allocator, screen_name, tab_names);
    try rebuildApiZig(allocator, app_name);
}

pub fn removeHTabScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8) !bool {
    var removed: bool = try _htab_screen_.remove(screen_name);
    if (removed) {
        try rebuildApiZig(allocator, app_name);
    }
    return removed;
}

// Add or remove modal screens.
pub fn addModalScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8, panel_names: [][]const u8) !void {
    // Add the modal package.
    try _modal_screen_.createAnyPackage(allocator, screen_name, panel_names);
    // Build api.zig with the initialize channel.
    try rebuildApiZig(allocator, app_name);
    try _modal_params_.add(allocator, screen_name);
}

pub fn removeModalScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8) !bool {
    var removed: bool = try _modal_screen_.remove(screen_name);
    if (removed) {
        try rebuildApiZig(allocator, app_name);
    }
    return removed;
}

// Add or remove book screens.

pub fn addBookScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8, tab_names: [][]const u8) !void {
    try _book_screen_.add(allocator, screen_name, tab_names);
    try rebuildApiZig(allocator, app_name);
}

pub fn removeBookScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8) !bool {
    var removed: bool = try _book_screen_.remove(screen_name);
    if (removed) {
        try rebuildApiZig(allocator, app_name);
    }
    return removed;
}
