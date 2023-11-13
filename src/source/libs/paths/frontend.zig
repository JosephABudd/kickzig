const std = @import("std");
const fspath = std.fs.path;

pub const folder_name_frontend: []const u8 = "frontend";
const folder_name_screen: []const u8 = "screen";
const folder_name_panel: []const u8 = "panel";
const folder_name_vtab: []const u8 = "vtab";
const folder_name_htab: []const u8 = "htab";
const folder_name_modal: []const u8 = "modal";
const folder_name_setup: []const u8 = "setup";
pub const folder_name_ok: []const u8 = "OK";

/// returns the frontend/screen/ path.
/// The caller owns the returned value.
pub fn pathScreenFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params = [2][]const u8{ folder_name_frontend, folder_name_screen };
    var path = try fspath.join(allocator, &params);
    return path;
}

/// returns the frontend/screen/panel/ path.
/// The caller owns the returned value.
pub fn pathScreenPanelFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params = [3][]const u8{ folder_name_frontend, folder_name_screen, folder_name_panel };
    var path = try fspath.join(allocator, &params);
    return path;
}

/// returns the frontend/screen/htab/ path.
/// The caller owns the returned value.
pub fn pathScreenHTabFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params = [3][]const u8{ folder_name_frontend, folder_name_screen, folder_name_htab };
    var path = try fspath.join(allocator, &params);
    return path;
}

/// returns the frontend/screen/vtab/ path.
/// The caller owns the returned value.
pub fn pathScreenVTabFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params = [3][]const u8{ folder_name_frontend, folder_name_screen, folder_name_vtab };
    var path = try fspath.join(allocator, &params);
    return path;
}

/// returns the frontend/screen/modal/ path.
/// The caller owns the returned value.
pub fn pathScreenModalFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params = [3][]const u8{ folder_name_frontend, folder_name_screen, folder_name_modal };
    var path = try fspath.join(allocator, &params);
    return path;
}

/// returns the frontend/screen/modal/OK/ path.
/// The caller owns the returned value.
pub fn pathScreenModalOKFolder(allocator: std.mem.Allocator) ![]const u8 {
    var params = [4][]const u8{ folder_name_frontend, folder_name_screen, folder_name_modal, folder_name_ok };
    var path = try fspath.join(allocator, &params);
    return path;
}
