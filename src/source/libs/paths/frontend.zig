const std = @import("std");
const fspath = std.fs.path;

pub const folder_name_frontend: []const u8 = "frontend";
pub const folder_name_screen: []const u8 = "screen";
pub const folder_name_screen_panel: []const u8 = "panel";
pub const folder_name_screen_tab: []const u8 = "tab";
pub const folder_name_lib: []const u8 = "lib";
pub const folder_name_framers: []const u8 = "framers";

/// returns the frontend/lib path.
/// The caller owns the returned value.
pub fn pathLibFolder(allocator: std.mem.Allocator) ![]const u8 {
    var path = try fspath.join(allocator, folder_name_frontend, folder_name_lib);
    return path;
}

/// returns the frontend/lib/framers path.
/// The caller owns the returned value.
pub fn pathLibFramersFolder(allocator: std.mem.Allocator) ![]const u8 {
    var path = try fspath.join(allocator, folder_name_frontend, folder_name_lib, folder_name_framers);
    return path;
}

/// returns the frontend/screen path.
/// The caller owns the returned value.
pub fn pathScreenFolder(allocator: std.mem.Allocator) ![]const u8 {
    var path = try fspath.join(allocator, folder_name_frontend, folder_name_screen);
    return path;
}

/// returns the frontend/screen/panel path.
/// The caller owns the returned value.
pub fn pathScreenPanelFolder(allocator: std.mem.Allocator) ![]const u8 {
    var path = try fspath.join(allocator, folder_name_frontend, folder_name_screen, folder_name_screen_panel);
    return path;
}

/// returns the frontend/screen/tab path.
/// The caller owns the returned value.
pub fn pathScreenTabFolder(allocator: std.mem.Allocator) ![]const u8 {
    var path = try fspath.join(allocator, folder_name_frontend, folder_name_screen, folder_name_screen_tab);
    return path;
}
