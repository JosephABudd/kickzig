const std = @import("std");
const paths = @import("paths");

/// Returns the names of each panel/ screen.
/// The caller owns the return value;
pub fn allPanelFolders(allocator: std.mem.Allocator) ![][]const u8 {
    var folders = try paths.folders();
    var folder_names = std.ArrayList([]const u8).init(allocator);
    defer folder_names.deinit();

    var dir = try std.fs.openIterableDirAbsolute(folders.root_src_this_frontend_screen_panel.?, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .directory) {
            try folder_names.append(file.name);
        }
    }
    var slice = try folder_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, slice.len);
    for (slice, 0..) |name, i| {
        var new_name: []const u8 = try allocator.alloc(u8, name.len);
        @memcpy(@constCast(new_name), name);
        names[i] = new_name;
    }
    return names;
}

/// Returns the names of each htab/ screen.
/// The caller owns the return value;
pub fn allHTabFolders(allocator: std.mem.Allocator) ![][]const u8 {
    var folders = try paths.folders();
    var folder_names = std.ArrayList([]const u8).init(allocator);
    defer folder_names.deinit();

    var dir = try std.fs.openIterableDirAbsolute(folders.root_src_this_frontend_screen_htab.?, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .directory) {
            try folder_names.append(file.name);
        }
    }
    var slice = try folder_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, slice.len);
    for (slice, 0..) |name, i| {
        var new_name: []const u8 = try allocator.alloc(u8, name.len);
        @memcpy(@constCast(new_name), name);
        names[i] = new_name;
    }
    return names;
}

/// Returns the names of each vtab/ screen.
/// The caller owns the return value;
pub fn allVTabFolders(allocator: std.mem.Allocator) ![][]const u8 {
    var folders = try paths.folders();
    var folder_names = std.ArrayList([]const u8).init(allocator);
    defer folder_names.deinit();

    var dir = try std.fs.openIterableDirAbsolute(folders.root_src_this_frontend_screen_vtab.?, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .directory) {
            try folder_names.append(file.name);
        }
    }
    var slice = try folder_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, slice.len);
    for (slice, 0..) |name, i| {
        var new_name: []const u8 = try allocator.alloc(u8, name.len);
        @memcpy(@constCast(new_name), name);
        names[i] = new_name;
    }
    return names;
}

/// Returns the names of each modal/ screen.
/// The caller owns the return value;
pub fn allModalFolders(allocator: std.mem.Allocator) ![][]const u8 {
    var folders = try paths.folders();
    var folder_names = std.ArrayList([]const u8).init(allocator);
    defer folder_names.deinit();

    var dir = try std.fs.openIterableDirAbsolute(folders.root_src_this_frontend_screen_modal.?, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .directory) {
            try folder_names.append(file.name);
        }
    }
    var slice = try folder_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, slice.len);
    for (slice, 0..) |name, i| {
        var new_name: []const u8 = try allocator.alloc(u8, name.len);
        @memcpy(@constCast(new_name), name);
        names[i] = new_name;
    }
    return names;
}

/// allPanelScreenFileNames returns the names of each file in a panel-screen's folder.
/// The caller owns the return value.
pub fn allPanelScreenFileNames(allocator: std.mem.Allocator, screen_name: []const u8) ![][]const u8 {
    var folders = try paths.folders();
    var folder_names = std.ArrayList([]const u8).init(allocator);
    defer folder_names.deinit();

    // The screen's folder path.
    try folder_names.append(folders.root_src_this_frontend_screen_panel.?);
    try folder_names.append(screen_name);
    var folder_path: []const []const u8 = try folder_names.toOwnedSlice();
    defer allocator.free(folder_path);
    var dir_path: []const u8 = try std.fs.path.join(allocator, folder_path);
    defer allocator.free(dir_path);
    var dir = try std.fs.openIterableDirAbsolute(dir_path, .{});
    defer dir.close();

    // The files.
    var file_names = std.ArrayList([]const u8).init(allocator);
    defer file_names.deinit();
    var iterator = dir.iterate();
    // iterator.reset();
    while (try iterator.next()) |file| {
        if (file.kind == .file) {
            try file_names.append(file.name);
        }
    }

    // A slice that the caller owns.
    var slice = try file_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, slice.len);
    for (slice, 0..) |name, i| {
        var new_name: []const u8 = try allocator.alloc(u8, name.len);
        @memcpy(@constCast(new_name), name);
        names[i] = new_name;
    }
    return names;
}

/// allModalScreenFileNames returns the names of each file in a modal-screen's folder.
/// The caller owns the return value.
pub fn allModalScreenFileNames(allocator: std.mem.Allocator, screen_name: []const u8) ![][]const u8 {
    var folders = try paths.folders();
    var folder_names = std.ArrayList([]const u8).init(allocator);
    defer folder_names.deinit();

    // The screen's folder path.
    try folder_names.append(folders.root_src_this_frontend_screen_modal.?);
    try folder_names.append(screen_name);
    var folder_path: []const []const u8 = folder_names.toOwnedSlice();
    defer allocator.free(folder_path);
    var dir_path: []const u8 = try std.fs.path.join(allocator, folder_path);
    defer allocator.free(dir_path);
    var dir = try std.fs.openIterableDirAbsolute(dir_path, .{});
    defer dir.close();

    // The files.
    var file_names = std.ArrayList([]const u8).init(allocator);
    defer file_names.deinit();
    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .file) {
            try file_names.append(file.name);
        }
    }

    // A slice that the caller owns.
    var slice = try folder_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, slice.len);
    for (slice, 0..) |name, i| {
        var new_name: []const u8 = try allocator.alloc(u8, name.len);
        @memcpy(@constCast(new_name), name);
        names[i] = new_name;
    }
    return names;
}

/// allVTabScreenFileNames returns the names of each file in a vtab-screen's folder.
/// The caller owns the return value.
pub fn allVTabScreenFileNames(allocator: std.mem.Allocator, screen_name: []const u8) ![][]const u8 {
    var folders = try paths.folders();
    var folder_names = std.ArrayList([]const u8).init(allocator);
    defer folder_names.deinit();

    // The screen's folder path.
    try folder_names.append(folders.root_src_this_frontend_screen_vtab.?);
    try folder_names.append(screen_name);
    var folder_path: []const []const u8 = folder_names.toOwnedSlice();
    defer allocator.free(folder_path);
    var dir_path: []const u8 = try std.fs.path.join(allocator, folder_path);
    defer allocator.free(dir_path);
    var dir = try std.fs.openIterableDirAbsolute(dir_path, .{});
    defer dir.close();

    // The files.
    var file_names = std.ArrayList([]const u8).init(allocator);
    defer file_names.deinit();
    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .file) {
            try file_names.append(file.name);
        }
    }

    // A slice that the caller owns.
    var slice = try folder_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, slice.len);
    for (slice, 0..) |name, i| {
        var new_name: []const u8 = try allocator.alloc(u8, name.len);
        @memcpy(@constCast(new_name), name);
        names[i] = new_name;
    }
    return names;
}

/// allHTabScreenFileNames returns the names of each file in a vtab-screen's folder.
/// The caller owns the return value.
pub fn allHTabScreenFileNames(allocator: std.mem.Allocator, screen_name: []const u8) ![][]const u8 {
    var folders = try paths.folders();
    var folder_names = std.ArrayList([]const u8).init(allocator);
    defer folder_names.deinit();

    // The screen's folder path.
    try folder_names.append(folders.root_src_this_frontend_screen_htab.?);
    try folder_names.append(screen_name);
    var folder_path: []const []const u8 = folder_names.toOwnedSlice();
    defer allocator.free(folder_path);
    var dir_path: []const u8 = try std.fs.path.join(allocator, folder_path);
    defer allocator.free(dir_path);
    var dir = try std.fs.openIterableDirAbsolute(dir_path, .{});
    defer dir.close();

    // The files.
    var file_names = std.ArrayList([]const u8).init(allocator);
    defer file_names.deinit();
    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .file) {
            try file_names.append(file.name);
        }
    }

    // A slice that the caller owns.
    var slice = try folder_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, slice.len);
    for (slice, 0..) |name, i| {
        var new_name: []const u8 = try allocator.alloc(u8, name.len);
        @memcpy(@constCast(new_name), name);
        names[i] = new_name;
    }
    return names;
}
