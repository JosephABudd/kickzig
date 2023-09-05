const std = @import("std");
const paths = @import("paths");

/// Returns the names of each panel screen.
/// The caller owns the return value;
fn allPanelFolders(allocator: std.mem.Allocator) ![][]const u8 {
    var folders = try paths.folders();
    var files = std.ArrayList([]const u8).init(allocator);
    defer files.deinit();

    var dir = try std.fs.openIterableDirAbsolute(folders.app_src_frontend_screen_panel, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .directory) {
            files.append(file.name);
        }
    }
    return files.toOwnedSlice();
}

/// Returns the names of each tab screen.
/// The caller owns the return value;
fn allTabFolders(allocator: std.mem.Allocator) ![][]const u8 {
    var folders = try paths.folders();
    var files = std.ArrayList([]const u8).init(allocator);
    defer files.deinit();

    var dir = try std.fs.openIterableDirAbsolute(folders.app_src_frontend_screen_tab, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .directory) {
            files.append(file.name);
        }
    }
    return files.toOwnedSlice();
}
