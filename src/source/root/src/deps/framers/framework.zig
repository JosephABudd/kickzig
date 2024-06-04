/// This file builds the deps/framers/ part of the framework.
/// It must be called after a screen is added or removed.
/// fn create adds:
/// - deps/framers/api.zig
const std = @import("std");
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");
const _screen_tags_template_ = @import("screen_tags_template.zig");

pub fn create(allocator: std.mem.Allocator) !void {
    try rebuild(allocator);
}

// rebuild builds api.zig and screen_tags.zig.
pub fn rebuild(allocator: std.mem.Allocator) !void {
    var panel_folder_names: [][]const u8 = undefined;
    var tab_folder_names: [][]const u8 = undefined;
    var modal_folder_names: [][]const u8 = undefined;

    panel_folder_names = try _filenames_.frontend.allPanelFolders(allocator);
    defer {
        for (panel_folder_names) |folder_name| {
            allocator.free(folder_name);
        }
        allocator.free(panel_folder_names);
    }
    tab_folder_names = try _filenames_.frontend.allTabFolders(allocator);
    defer {
        for (tab_folder_names) |folder_name| {
            allocator.free(folder_name);
        }
        allocator.free(tab_folder_names);
    }
    modal_folder_names = try _filenames_.frontend.allModalFolders(allocator);
    defer {
        for (modal_folder_names) |folder_name| {
            allocator.free(folder_name);
        }
        allocator.free(modal_folder_names);
    }

    try buildApiZig(
        allocator,
        tab_folder_names,
        panel_folder_names,
        modal_folder_names,
    );
    try buildScreenTagsZig(
        allocator,
        tab_folder_names,
        panel_folder_names,
        modal_folder_names,
    );
}

fn buildScreenTagsZig(
    allocator: std.mem.Allocator,
    tab_folder_names: [][]const u8,
    panel_folder_names: [][]const u8,
    modal_folder_names: [][]const u8,
) !void {
    var template: *_screen_tags_template_.Template = try _screen_tags_template_.Template.init(allocator);
    // Panel folders.
    for (panel_folder_names) |folder_name| {
        try template.addScreenName(folder_name);
    }
    // Tab folders.
    for (tab_folder_names) |folder_name| {
        try template.addScreenName(folder_name);
    }
    // Modal folders.
    for (modal_folder_names) |folder_name| {
        try template.addScreenName(folder_name);
    }
    const content: []const u8 = try template.content();

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var framework_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_framers.?, .{});
    defer framework_dir.close();

    // Open, write and close the file.
    var ofile: std.fs.File = try framework_dir.createFile(_filenames_.screen_tabs_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn buildApiZig(
    allocator: std.mem.Allocator,
    tab_folder_names: [][]const u8,
    panel_folder_names: [][]const u8,
    modal_folder_names: [][]const u8,
) !void {
    // Content.
    var template: *_api_template_.Template = try _api_template_.Template.init(allocator);
    // Panel folders.
    for (panel_folder_names) |folder_name| {
        try template.addNotModalScreenName(folder_name);
    }
    // Tab folders.
    for (tab_folder_names) |folder_name| {
        try template.addNotModalScreenName(folder_name);
    }
    // Modal folders.
    for (modal_folder_names) |folder_name| {
        try template.addModalScreenName(folder_name);
    }
    const content: []const u8 = try template.content();

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var framework_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_framers.?, .{});
    defer framework_dir.close();

    // Open, write and close the file.
    var ofile: std.fs.File = try framework_dir.createFile(_filenames_.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}
