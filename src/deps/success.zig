const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");
const filenames = @import("filenames");

// Framework.

pub fn frameworkAdded(allocator: std.mem.Allocator, app_name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "The «{s}» framework has been added.\n", .{app_name});
}

// Screens.

pub fn screenRemoved(allocator: std.mem.Allocator, screen_name: []const u8) ![]const u8 {
    return std.fmt.allocPrint(allocator, "The screen «{s}» has been removed.\n", .{screen_name});
}

pub fn screenAddedBook(allocator: std.mem.Allocator, screen_name: []const u8) ![]const u8 {
    const folders: *paths.FolderPaths = try paths.folders();
    const params = [3][]const u8{ folders.root_src_frontend_screen_book.?, screen_name, filenames.screen_screen_file_name };
    const full_path = try fspath.join(allocator, &params);
    return try std.fmt.allocPrint(allocator, "Added the front-end «{s}» Book screen at {s}:1:1:\n", .{ screen_name, full_path });
}

pub fn screenAddedTab(allocator: std.mem.Allocator, screen_name: []const u8) ![]const u8 {
    const folders: *paths.FolderPaths = try paths.folders();
    const params = [3][]const u8{ folders.root_src_frontend_screen_tab.?, screen_name, filenames.screen_screen_file_name };
    const full_path = try fspath.join(allocator, &params);
    return try std.fmt.allocPrint(allocator, "Added the front-end «{s}» Tab screen at {s}:1:1:\n", .{ screen_name, full_path });
}

pub fn screenAddedPanel(allocator: std.mem.Allocator, screen_name: []const u8) ![]const u8 {
    const folders: *paths.FolderPaths = try paths.folders();
    const params = [3][]const u8{ folders.root_src_frontend_screen_panel.?, screen_name, filenames.screen_screen_file_name };
    const full_path = try fspath.join(allocator, &params);
    return try std.fmt.allocPrint(allocator, "Added the front-end «{s}» Panel screen at {s}:1:1:\n", .{ screen_name, full_path });
}

pub fn screenAddedContent(allocator: std.mem.Allocator, screen_name: []const u8) ![]const u8 {
    const folders: *paths.FolderPaths = try paths.folders();
    const params = [3][]const u8{ folders.root_src_frontend_screen_panel.?, screen_name, filenames.screen_screen_file_name };
    const full_path = try fspath.join(allocator, &params);
    return try std.fmt.allocPrint(allocator, "Added the front-end «{s}» Content screen at {s}:1:1:\n", .{ screen_name, full_path });
}

pub fn screenAddedModal(allocator: std.mem.Allocator, screen_name: []const u8) ![]const u8 {
    const folders: *paths.FolderPaths = try paths.folders();
    const screen_path_params = [3][]const u8{ folders.root_src_frontend_screen_modal.?, screen_name, filenames.screen_screen_file_name };
    const screen_path = try fspath.join(allocator, &screen_path_params);
    defer allocator.free(screen_path);
    const added_screen_line: []const u8 = try std.fmt.allocPrint(allocator, "Added the front-end «{s}» Modal screen at {s}:1:1:\n", .{ screen_name, screen_path });
    defer allocator.free(added_screen_line);
    const file_name = try filenames.depsModalParamsFileName(allocator, screen_name);
    defer allocator.free(file_name);
    const args_path_params = [2][]const u8{ folders.root_src_deps_modal_params.?, file_name };
    const args_path = try fspath.join(allocator, &args_path_params);
    defer allocator.free(args_path);
    const added_params_line: []const u8 = try std.fmt.allocPrint(allocator, "Added the deps «{s}» Modal Params at {s}:1:1:\n", .{ screen_name, args_path });
    defer allocator.free(added_params_line);
    const lines = [2][]const u8{ added_screen_line, added_params_line };
    return std.mem.concat(allocator, u8, &lines);
}

// Message.

pub fn backendMessageHandlerAdded(allocator: std.mem.Allocator, message_name: []const u8) ![]const u8 {
    const folders: *paths.FolderPaths = try paths.folders();
    const backend_path: []const u8 = try paths.backend.pathMessengerFolderMessage(allocator, message_name);
    defer allocator.free(backend_path);
    const params = [2][]const u8{ folders.root_src.?, backend_path };
    const path = try fspath.join(allocator, &params);
    return try std.fmt.allocPrint(allocator, "Added the back-end «{s}» messenger at {s}:1:1:\n", .{ message_name, path });
}

pub fn depsMessageAdded(allocator: std.mem.Allocator, message_name: []const u8) ![]const u8 {
    const folders: *paths.FolderPaths = try paths.folders();
    const deps_path: []const u8 = try paths.deps.pathMessengerFolderMessage(allocator, message_name);
    defer allocator.free(deps_path);
    const params = [2][]const u8{ folders.root_src.?, deps_path };
    const path = try fspath.join(allocator, &params);
    return try std.fmt.allocPrint(allocator, "Added the «{s}» message at {s}:1:1:\n", .{ message_name, path });
}

pub fn backendMessageHandlerRemoved(allocator: std.mem.Allocator, message_name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "Removed the back-end «{s}» messenger.\n", .{message_name});
}

pub fn depsMessageRemoved(allocator: std.mem.Allocator, message_name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "Removed the {s} message.\n", .{message_name});
}
