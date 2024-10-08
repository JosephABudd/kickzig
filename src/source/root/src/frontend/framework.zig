/// This file builds the frontend/ part of the framework.
/// fn create adds:
/// - frontend/api.zig
/// - frontend/main_menu.zig
const std = @import("std");
const fspath = std.fs.path;
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");
const _screen_pointers_template_ = @import("screen_pointers_template.zig");
const _stdout_ = @import("stdout");
const _src_frontend_screen_ = @import("screen/framework.zig");
const _src_frontend_panel_screen_ = @import("screen/panel/framework.zig");
const _src_frontend_tab_screen_ = @import("screen/tab/framework.zig");
const _src_frontend_modal_screen_ = @import("screen/modal/framework.zig");
const _src_deps_modal_params_ = @import("source_deps").modal_params;

pub fn create(allocator: std.mem.Allocator, app_name: []const u8, use_messenger: bool) !void {
    // Add each panel screen and the folder's git keep file.
    try _src_frontend_panel_screen_.create(allocator, use_messenger);
    // Add each modal screen.
    try _src_frontend_modal_screen_.create(allocator);
    // Add the tab screen folder's git keep file.
    try _src_frontend_tab_screen_.create();
    // Build api.zig.
    try rebuild(allocator, app_name);
}

// List screens.

pub fn listScreens(allocator: std.mem.Allocator) !void {
    return _src_frontend_screen_.listScreens(allocator);
}

fn rebuild(allocator: std.mem.Allocator, app_name: []const u8) !void {

    // Add the names of each panel screen.
    const panel_screen_names: [][]const u8 = try _filenames_.frontend.allPanelFolders(allocator);
    defer {
        for (panel_screen_names) |panel_screen_name| {
            allocator.free(panel_screen_name);
        }
        allocator.free(panel_screen_names);
    }
    // Add the names of each tab screen.
    const tab_screen_names: [][]const u8 = try _filenames_.frontend.allTabFolders(allocator);
    defer {
        for (tab_screen_names) |tab_screen_name| {
            allocator.free(tab_screen_name);
        }
        allocator.free(tab_screen_names);
    }
    // Add the names of each modal screen.
    const modal_screen_names: [][]const u8 = try _filenames_.frontend.allModalFolders(allocator);
    defer {
        for (modal_screen_names) |modal_screen_name| {
            allocator.free(modal_screen_name);
        }
        allocator.free(modal_screen_names);
    }

    try rebuildApiZig(
        allocator,
        app_name,
        panel_screen_names,
        tab_screen_names,
        modal_screen_names,
    );
    try rebuildScreenPointersZig(
        allocator,
        app_name,
        panel_screen_names,
        tab_screen_names,
        modal_screen_names,
    );
}

// rebuildApiZig builds frontent/api.zig.
fn rebuildApiZig(
    allocator: std.mem.Allocator,
    app_name: []const u8,
    panel_screen_names: [][]const u8,
    tab_screen_names: [][]const u8,
    modal_screen_names: [][]const u8,
) !void {
    // Build the template and the content.
    const template: *_api_template_.Template = try _api_template_.init(allocator, app_name);
    defer template.deinit();

    for (panel_screen_names) |panel_screen_name| {
        try template.addPanelScreenName(panel_screen_name);
    }
    for (tab_screen_names) |tab_screen_name| {
        try template.addTabScreenName(tab_screen_name);
    }
    for (modal_screen_names) |modal_screen_name| {
        try template.addModalScreenName(modal_screen_name);
    }

    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_frontend.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    var ofile = try messenger_dir.createFile(_filenames_.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

// rebuildScreenPointersZig builds frontent/api.zig.
fn rebuildScreenPointersZig(
    allocator: std.mem.Allocator,
    app_name: []const u8,
    panel_screen_names: [][]const u8,
    tab_screen_names: [][]const u8,
    modal_screen_names: [][]const u8,
) !void {
    // Build the template and the content.
    const template: *_screen_pointers_template_.Template = try _screen_pointers_template_.init(allocator, app_name);
    defer template.deinit();

    for (panel_screen_names) |panel_screen_name| {
        try template.addPanelScreenName(panel_screen_name);
    }
    for (tab_screen_names) |tab_screen_name| {
        try template.addTabScreenName(tab_screen_name);
    }
    for (modal_screen_names) |modal_screen_name| {
        try template.addModalScreenName(modal_screen_name);
    }

    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_frontend.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    var ofile = try messenger_dir.createFile(_filenames_.screen_pointers_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

// Add or remove panel screens.

/// addPanelScreen creates a panel screen and adds rebuilds api.zig.
pub fn addPanelScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8, panel_names: [][]const u8, use_messenger: bool) !void {
    try _src_frontend_panel_screen_.createAnyPackage(allocator, screen_name, panel_names, use_messenger, false);
    try rebuild(allocator, app_name);
}

/// removePanelScreen removes a screen folder and rebuilds api.zig.
pub fn removePanelScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8) !bool {
    var removed: bool = false;
    defer {
        if (removed) {}
    }
    removed = try _src_frontend_panel_screen_.remove(screen_name);
    if (removed) {
        // Removed a panel screen.
        try rebuild(allocator, app_name);
    }
    return removed;
}

// Add or remove tab screens.

pub fn addTabScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8, tab_names: [][]const u8, use_messenger: bool) !void {
    try _src_frontend_tab_screen_.add(allocator, screen_name, tab_names, use_messenger);
    try rebuild(allocator, app_name);
}

pub fn removeTabScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8) !bool {
    const removed: bool = try _src_frontend_tab_screen_.remove(screen_name);
    if (removed) {
        try rebuild(allocator, app_name);
    }
    return removed;
}

// Add or remove modal screens.
pub fn addModalScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8, panel_names: [][]const u8, use_messenger: bool) !void {
    // Add the modal screen package.
    try _src_frontend_modal_screen_.createAnyPackage(allocator, screen_name, panel_names, use_messenger);
    // Build api.zig.
    try rebuild(allocator, app_name);
    // Add the modal params package.
    try _src_deps_modal_params_.add(allocator, screen_name);
}

pub fn removeModalScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8) !bool {
    const removed: bool = try _src_frontend_modal_screen_.remove(screen_name);
    if (removed) {
        try rebuild(allocator, app_name);
    }
    return removed;
}
