const std = @import("std");
const paths = @import("paths");

/// Returns the name of a panel file.
/// The caller owns the return value;
pub fn screen_panel_file_name(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    var line: []const u8 = try std.fmt.allocPrint(allocator, "{s}_panel.zig", .{name});
    return line;
}
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
    var owned: [][]const u8 = try folder_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, owned.len);
    for (owned, 0..) |name, i| {
        names[i] = try allocator.alloc(u8, name.len);
        errdefer {
            for (names, 0..) |deinit_name, j| {
                if (j == i) break;
                allocator.free(deinit_name);
            }
            allocator.free(names);
        }
        @memcpy(@constCast(names[i]), name);
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
    var owned: [][]const u8 = try folder_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, owned.len);
    for (owned, 0..) |name, i| {
        names[i] = try allocator.alloc(u8, name.len);
        errdefer {
            for (names, 0..) |deinit_name, j| {
                if (j == i) break;
                allocator.free(deinit_name);
            }
            allocator.free(names);
        }
        @memcpy(@constCast(names[i]), name);
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
    var owned: [][]const u8 = try folder_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, owned.len);
    for (owned, 0..) |name, i| {
        names[i] = try allocator.alloc(u8, name.len);
        errdefer {
            for (names, 0..) |deinit_name, j| {
                if (j == i) break;
                allocator.free(deinit_name);
            }
            allocator.free(names);
        }
        @memcpy(@constCast(names[i]), name);
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
    var owned: [][]const u8 = try folder_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, owned.len);
    for (owned, 0..) |name, i| {
        names[i] = try allocator.alloc(u8, name.len);
        errdefer {
            for (names, 0..) |deinit_name, j| {
                if (j == i) break;
                allocator.free(deinit_name);
            }
            allocator.free(names);
        }
        @memcpy(@constCast(names[i]), name);
    }
    return names;
}

/// Returns the names of each book/ screen.
/// The caller owns the return value;
pub fn allBookFolders(allocator: std.mem.Allocator) ![][]const u8 {
    var folders = try paths.folders();
    var folder_names = std.ArrayList([]const u8).init(allocator);
    defer folder_names.deinit();

    var dir = try std.fs.openIterableDirAbsolute(folders.root_src_this_frontend_screen_book.?, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .directory) {
            try folder_names.append(file.name);
        }
    }
    var owned: [][]const u8 = try folder_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, owned.len);
    for (owned, 0..) |name, i| {
        names[i] = try allocator.alloc(u8, name.len);
        errdefer {
            for (names, 0..) |deinit_name, j| {
                if (j == i) break;
                allocator.free(deinit_name);
            }
            allocator.free(names);
        }
        @memcpy(@constCast(names[i]), name);
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
    std.debug.print("dir_path is {s}\n", .{dir_path});
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
    var owned: [][]const u8 = try file_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, owned.len);
    for (owned, 0..) |name, i| {
        names[i] = try allocator.alloc(u8, name.len);
        errdefer {
            for (names, 0..) |deinit_name, j| {
                if (j == i) break;
                allocator.free(deinit_name);
            }
            allocator.free(names);
        }
        @memcpy(@constCast(names[i]), name);
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
    while (try iterator.next()) |file| {
        if (file.kind == .file) {
            try file_names.append(file.name);
        }
    }
    var owned: [][]const u8 = try file_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, owned.len);
    for (owned, 0..) |name, i| {
        names[i] = try allocator.alloc(u8, name.len);
        errdefer {
            for (names, 0..) |deinit_name, j| {
                if (j == i) break;
                allocator.free(deinit_name);
            }
            allocator.free(names);
        }
        @memcpy(@constCast(names[i]), name);
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
    var folder_path: [][]const u8 = try folder_names.toOwnedSlice();
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
    var owned: [][]const u8 = try file_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, owned.len);
    for (owned, 0..) |name, i| {
        names[i] = try allocator.alloc(u8, name.len);
        errdefer {
            for (names, 0..) |deinit_name, j| {
                if (j == i) break;
                allocator.free(deinit_name);
            }
            allocator.free(names);
        }
        @memcpy(@constCast(names[i]), name);
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
    var folder_path: [][]const u8 = try folder_names.toOwnedSlice();
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
    var owned: [][]const u8 = try file_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, owned.len);
    for (owned, 0..) |name, i| {
        names[i] = try allocator.alloc(u8, name.len);
        errdefer {
            for (names, 0..) |deinit_name, j| {
                if (j == i) break;
                allocator.free(deinit_name);
            }
            allocator.free(names);
        }
        @memcpy(@constCast(names[i]), name);
    }
    return names;
}

/// allBookScreenFileNames returns the names of each file in a book-screen's folder.
/// The caller owns the return value.
pub fn allBookScreenFileNames(allocator: std.mem.Allocator, screen_name: []const u8) ![][]const u8 {
    var folders = try paths.folders();
    var folder_names = std.ArrayList([]const u8).init(allocator);
    defer folder_names.deinit();

    // The screen's folder path.
    try folder_names.append(folders.root_src_this_frontend_screen_book.?);
    try folder_names.append(screen_name);
    var folder_path: [][]const u8 = try folder_names.toOwnedSlice();
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
    var owned: [][]const u8 = try file_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, owned.len);
    for (owned, 0..) |name, i| {
        names[i] = try allocator.alloc(u8, name.len);
        errdefer {
            for (names, 0..) |deinit_name, j| {
                if (j == i) break;
                allocator.free(deinit_name);
            }
            allocator.free(names);
        }
        @memcpy(@constCast(names[i]), name);
    }
    return names;
}
