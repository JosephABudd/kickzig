/// This file builds the frontend/ part of the framework.
/// fn create adds:
/// - frontend/api.zig
/// - frontend/main_menu.zig
const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");
const filenames = @import("filenames");
const api_template = @import("api_template.zig");
const main_menu_template = @import("main_menu_template.zig");
const panel_screen = @import("screen/panel/framework.zig");
const ok_modal_screen = @import("screen/modal/ok/framework.zig");

pub fn create(allocator: std.mem.Allocator, app_name: []const u8) !void {
    // Add the main menu file which is a data file.
    // It sets the default landing screen.
    try addMainMenu(allocator);
    // Add the default landing screen.
    // It contains lots of example code.
    try panel_screen.createExample(allocator, main_menu_template.default_landing_screen_name);
    // Add the OK modal screen.
    try ok_modal_screen.create(allocator);
    // Build api.zig with the initialize channel.
    try buildApiZig(allocator, app_name);
}

// Add or remove panel screens.

pub fn addPanelScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8) !void {
    try panel_screen.create(allocator, screen_name);
    try buildApiZig(allocator, app_name);
}

pub fn removePanelScreen(allocator: std.mem.Allocator, app_name: []const u8, screen_name: []const u8) !void {
    try panel_screen.remove(allocator, screen_name);
    try buildApiZig(allocator, app_name);
}

fn addMainMenu(allocator: std.mem.Allocator) !void {
    var template: *main_menu_template.Template = try main_menu_template.init(allocator);
    defer template.deinit();
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try paths.folders();
    defer folders.deinit();
    var frontend_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_frontend.?, .{});
    defer frontend_dir.close();

    // Open, write and close the file.
    var ofile = try frontend_dir.createFile(filenames.frontent_main_menu_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn buildApiZig(allocator: std.mem.Allocator, app_name: []const u8) !void {
    // Build the template and the content.
    const template: *api_template.Template = try api_template.init(allocator, app_name);
    defer template.deinit();

    // Add the names of each vtab screen.
    var vtab_screen_names: [][]const u8 = try filenames.frontend.allVTabFolders(allocator);
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
    var htab_screen_names: [][]const u8 = try filenames.frontend.allHTabFolders(allocator);
    defer {
        for (htab_screen_names) |htab_screen_name| {
            allocator.free(htab_screen_name);
        }
        allocator.free(htab_screen_names);
    }
    for (htab_screen_names) |htab_screen_name| {
        try template.addHTabScreenName(htab_screen_name);
    }
    // Add the names of each panel screen.
    var panel_screen_names: [][]const u8 = try filenames.frontend.allPanelFolders(allocator);
    defer {
        for (panel_screen_names) |panel_screen_name| {
            allocator.free(panel_screen_name);
        }
        allocator.free(panel_screen_names);
    }
    for (panel_screen_names) |panel_screen_name| {
        try template.addPanelScreenName(panel_screen_name);
    }
    // Add the names of each modal screen.
    var modal_screen_names: [][]const u8 = try filenames.frontend.allModalFolders(allocator);
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
    var folders = try paths.folders();
    defer folders.deinit();
    var messenger_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_frontend.?, .{});
    defer messenger_dir.close();

    // Open, write and close the file.
    var ofile = try messenger_dir.createFile(filenames.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}
