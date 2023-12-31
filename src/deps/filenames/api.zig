const std = @import("std");
const paths = @import("paths");
pub const frontend = @import("frontend.zig");
const zig_file_extension: []const u8 = ".zig";
const panel_file_suffix: []const u8 = "_panel.zig";

pub const build_file_name: []const u8 = "build.zig";
pub const build_zon_file_name: []const u8 = "build.zig.zon";
pub const standalone_sdl_file_name: []const u8 = "standalone-sdl.zig";
pub const api_file_name: []const u8 = "api.zig";
pub const ralativeFilePathSuffix: []const u8 = ":1:1";
pub const screen_screen_file_name: []const u8 = "screen.zig";
pub const screen_messenger_file_name: []const u8 = "messenger.zig";
pub const screen_panels_file_name: []const u8 = "panels.zig";
pub const frontent_main_menu_file_name: []const u8 = "main_menu.zig";
pub const initialize_file_name: []const u8 = "Initialize.zig";
pub const fatal_file_name: []const u8 = "Fatal.zig";
pub const ok_file_name: []const u8 = "OK.zig";
pub const yesno_file_name: []const u8 = "YesNo.zig";
pub const tabbar_file_name: []const u8 = "tabbar.zig";

// backend.

// backendMessageHandlerFileName returns the file name for a back-end message handler file.
// The caller owns the file name.
pub fn backendMessageHandlerFileName(allocator: std.mem.Allocator, message_name: []const u8) ![]const u8 {
    var file_name = std.ArrayList(u8).init(allocator);
    defer file_name.deinit();
    try file_name.appendSlice(message_name);
    try file_name.appendSlice(zig_file_extension);
    return try file_name.toOwnedSlice();
}

// backendMessageNameFromHandlerFileName returns the message name taken from a back-end message handler file name.
// The message name is a slice of file_name.
pub fn backendMessageNameFromHandlerFileName(file_name: []const u8) ?[]const u8 {
    if (std.mem.eql(u8, file_name, api_file_name)) {
        // "api.zig" is not a message file name.
        return null;
    }
    if (std.mem.endsWith(u8, file_name, zig_file_extension)) {
        var last: usize = file_name.len - zig_file_extension.len;
        if (last > 0) {
            return file_name[0..last];
        }
    }
    return null;
}

/// allBackendMessageHandlerNames returns the names of each message.
/// The caller owns the return value;
pub fn allBackendMessageHandlerNames(allocator: std.mem.Allocator) ![][]const u8 {
    var handler_names = std.ArrayList([]const u8).init(allocator);
    defer handler_names.deinit();
    var folders = try paths.folders();
    defer folders.deinit();

    var dir = try std.fs.openIterableDirAbsolute(folders.root_src_this_backend_messenger.?, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .file) {
            if (backendMessageNameFromHandlerFileName(file.name)) |message_name| {
                try handler_names.append(message_name);
            }
        }
    }
    // Return a slice that the caller owns.
    var unowned_slice: [][]const u8 = try handler_names.toOwnedSlice();
    return ownedSlice(allocator, unowned_slice);
}

// frontend.

/// frontendScreenPanelFileName returns the file name for a front-end screen panel file.
/// The caller owns the returned value.
pub fn frontendScreenPanelFileName(allocator: std.mem.Allocator, panel_name: []const u8) ![]const u8 {
    var file_name = std.ArrayList(u8).init(allocator);
    defer file_name.deinit();
    try file_name.appendSlice(panel_name);
    try file_name.appendSlice("_panel");
    try file_name.appendSlice(zig_file_extension);
    return try file_name.toOwnedSlice();
}

// frontendPanelNameFromPanelFileName returns the panel name taken from a front-end screen's panel file name.
// The panel name is a slice of file_name.
// The caller does not own the returned value.
pub fn frontendPanelNameFromPanelFileName(file_name: []const u8) ?[]const u8 {
    if (std.mem.endsWith(u8, file_name, panel_file_suffix)) {
        var last: usize = file_name.len - panel_file_suffix.len;
        if (last > 0) {
            return file_name[0..last];
        }
    }
    return null;
}

/// allFrontendPanelScreenPanelNames returns the names of each panel-file in a panel-screen.
pub fn allFrontendPanelScreenPanelNames(allocator: std.mem.Allocator, screen_name: []const u8) ![][]const u8 {
    var folder_file_names: [][]const u8 = try frontend.allPanelScreenFileNames(allocator, screen_name);
    defer allocator.free(folder_file_names);
    // Collect panel names from panel files.
    var panel_file_names = std.ArrayList([]const u8).init(allocator);
    defer panel_file_names.deinit();
    for (folder_file_names) |folder_file_name| {
        if (frontendPanelNameFromPanelFileName(folder_file_name)) |panel_file_name| {
            try panel_file_names.append(panel_file_name);
        }
    }
    // Return a slice that the caller owns.
    var unowned_slice: [][]const u8 = try panel_file_names.toOwnedSlice();
    return ownedSlice(allocator, unowned_slice);
}

/// allFrontendModalScreenPanelNames returns the names of each panel-file in a modal-screen.
pub fn allFrontendModalScreenPanelNames(allocator: std.mem.Allocator, screen_name: []const u8) ![][]const u8 {
    var folder_file_names: [][]const u8 = try frontend.allModalScreenFileNames(allocator, screen_name);
    defer allocator.free(folder_file_names);
    // Collect panel names from panel files.
    var panel_file_names = std.ArrayList([]const u8).init(allocator);
    defer panel_file_names.deinit();
    for (folder_file_names) |folder_file_name| {
        if (frontendPanelNameFromPanelFileName(folder_file_name)) |panel_file_name| {
            try panel_file_names.append(panel_file_name);
        }
    }
    // Return a slice that the caller owns.
    var unowned_slice: [][]const u8 = try panel_file_names.toOwnedSlice();
    return ownedSlice(allocator, unowned_slice);
}

/// allFrontendVTabScreenPanelNames returns the names of each panel-file in a vtab-screen.
pub fn allFrontendVTabScreenPanelNames(allocator: std.mem.Allocator, screen_name: []const u8) ![][]const u8 {
    var folder_file_names: [][]const u8 = try frontend.allVTabScreenFileNames(allocator, screen_name);
    defer allocator.free(folder_file_names);
    // Collect panel names from panel files.
    var panel_file_names = std.ArrayList([]const u8).init(allocator);
    defer panel_file_names.deinit();
    for (folder_file_names) |folder_file_name| {
        if (frontendPanelNameFromPanelFileName(folder_file_name)) |panel_file_name| {
            try panel_file_names.append(panel_file_name);
        }
    }
    // Return a slice that the caller owns.
    var unowned_slice: [][]const u8 = try panel_file_names.toOwnedSlice();
    return ownedSlice(allocator, unowned_slice);
}

/// allFrontendHTabScreenPanelNames returns the names of each panel-file in a htab-screen.
pub fn allFrontendHTabScreenPanelNames(allocator: std.mem.Allocator, screen_name: []const u8) ![][]const u8 {
    var folder_file_names: [][]const u8 = try frontend.allHTabScreenFileNames(allocator, screen_name);
    defer allocator.free(folder_file_names);
    // Collect panel names from panel files.
    var panel_file_names = std.ArrayList([]const u8).init(allocator);
    defer panel_file_names.deinit();
    for (folder_file_names) |folder_file_name| {
        if (frontendPanelNameFromPanelFileName(folder_file_name)) |panel_file_name| {
            try panel_file_names.append(panel_file_name);
        }
    }
    // Return a slice that the caller owns.
    var unowned_slice: [][]const u8 = try panel_file_names.toOwnedSlice();
    return ownedSlice(allocator, unowned_slice);
}

/// allFrontendBookScreenPanelNames returns the names of each panel-file in a book-screen.
pub fn allFrontendBookScreenPanelNames(allocator: std.mem.Allocator, screen_name: []const u8) ![][]const u8 {
    var folder_file_names: [][]const u8 = try frontend.allBookScreenFileNames(allocator, screen_name);
    defer allocator.free(folder_file_names);
    // Collect panel names from panel files.
    var panel_file_names = std.ArrayList([]const u8).init(allocator);
    defer panel_file_names.deinit();
    for (folder_file_names) |folder_file_name| {
        if (frontendPanelNameFromPanelFileName(folder_file_name)) |panel_file_name| {
            try panel_file_names.append(panel_file_name);
        }
    }
    // Return a slice that the caller owns.
    var unowned_slice: [][]const u8 = try panel_file_names.toOwnedSlice();
    return ownedSlice(allocator, unowned_slice);
}

/// allFrontendScreenNames returns screen names taken from the screen folders.
/// The caller owns the returned value.
pub fn allFrontendScreenNames(allocator: std.mem.Allocator) ![][]const u8 {
    var all_folders = std.ArrayList([]const u8).init(allocator);
    defer all_folders.deinit();

    // Panel screens.
    var panel_folders: [][]const u8 = try frontend.allPanelFolders(allocator);
    defer {
        for (panel_folders) |folder| {
            allocator.free(folder);
        }
        allocator.free(panel_folders);
    }
    try all_folders.appendSlice(panel_folders);

    // HTab screens.
    var htab_folders: [][]const u8 = try frontend.allHTabFolders(allocator);
    defer {
        for (htab_folders) |folder| {
            allocator.free(folder);
        }
        allocator.free(htab_folders);
    }
    try all_folders.appendSlice(htab_folders);

    // VTab screens.
    var vtab_folders: [][]const u8 = try frontend.allVTabFolders(allocator);
    defer {
        for (vtab_folders) |folder| {
            allocator.free(folder);
        }
        allocator.free(vtab_folders);
    }
    try all_folders.appendSlice(vtab_folders);

    // Book screens.
    var book_folders: [][]const u8 = try frontend.allBookFolders(allocator);
    defer {
        for (book_folders) |folder| {
            allocator.free(folder);
        }
        allocator.free(book_folders);
    }
    try all_folders.appendSlice(book_folders);

    // Modal screens.
    var modal_folders: [][]const u8 = try frontend.allModalFolders(allocator);
    defer {
        for (modal_folders) |folder| {
            allocator.free(folder);
        }
        allocator.free(modal_folders);
    }
    try all_folders.appendSlice(modal_folders);
    // Return a slice that the caller owns.
    var unowned_slice: [][]const u8 = try all_folders.toOwnedSlice();
    return ownedSlice(allocator, unowned_slice);
}

// deps/.

// depsModalParamsFileName returns the file name for a modal params file.
// The caller owns the file name.
pub fn depsModalParamsFileName(allocator: std.mem.Allocator, modal_params_name: []const u8) ![]const u8 {
    var file_name = std.ArrayList(u8).init(allocator);
    defer file_name.deinit();
    try file_name.appendSlice(modal_params_name);
    try file_name.appendSlice(zig_file_extension);
    return try file_name.toOwnedSlice();
}

// modalParamsNameFromDepsModalParamsFileName returns the modal params name taken from a deps modal params file name.
// The modal params name is a slice of file_name.
fn modalParamsNameFromDepsModalParamsFileName(file_name: []const u8) ?[]const u8 {
    if (std.mem.eql(u8, file_name, api_file_name)) {
        // "api.zig" is not a message file name.
        return null;
    }
    if (std.mem.endsWith(u8, file_name, zig_file_extension)) {
        var last: usize = file_name.len - zig_file_extension.len;
        if (last > 0) {
            return file_name[0..last];
        }
    }
    return null;
}

// depsMessageFileName returns the file name for a message.
// The caller owns the file name.
pub fn depsMessageFileName(allocator: std.mem.Allocator, message_name: []const u8) ![]const u8 {
    var file_name = std.ArrayList(u8).init(allocator);
    defer file_name.deinit();
    try file_name.appendSlice(message_name);
    try file_name.appendSlice(zig_file_extension);
    return try file_name.toOwnedSlice();
}

// messageNameFromMessageFileName returns the message name taken from a deps message file name.
// The message name is a slice of file_name.
pub fn messageNameFromMessageFileName(file_name: []const u8) ?[]const u8 {
    if (std.mem.eql(u8, file_name, api_file_name)) {
        // "api.zig" is not a message file name.
        return null;
    }
    if (std.mem.endsWith(u8, file_name, zig_file_extension)) {
        var last: usize = file_name.len - zig_file_extension.len;
        if (last > 0) {
            return file_name[0..last];
        }
    }
    return null;
}

// The caller owns the returned value;
fn allDepsMessageFileNames(allocator: std.mem.Allocator) ![][]const u8 {
    var folders = try paths.folders();
    var file_names = std.ArrayList([]const u8).init(allocator);
    defer file_names.deinit();

    var dir = try std.fs.openIterableDirAbsolute(folders.root_src_this_deps_message.?, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .file) {
            try file_names.append(file.name);
        }
    }
    // Return a slice that the caller owns.
    var unowned_slice: [][]const u8 = try file_names.toOwnedSlice();
    return ownedSlice(allocator, unowned_slice);
}

// depsChannelFileName returns the file name for a channel.
// The caller owns the file name.
pub fn depsChannelFileName(allocator: std.mem.Allocator, channel_name: []const u8) ![]const u8 {
    var file_name = std.ArrayList(u8).init(allocator);
    defer file_name.deinit();
    try file_name.appendSlice(channel_name);
    try file_name.appendSlice(zig_file_extension);
    return try file_name.toOwnedSlice();
}

// channelNameFromDepsChannelFileName returns the channel name taken from a deps channel file name.
// The channel name is a slice of file_name.
fn channelNameFromDepsChannelFileName(file_name: []const u8) ?[]const u8 {
    if (std.mem.eql(u8, file_name, api_file_name)) {
        // "api.zig" is not a message file name.
        return null;
    }
    if (std.mem.endsWith(u8, file_name, zig_file_extension)) {
        var last: usize = file_name.len - zig_file_extension.len;
        if (last > 0) {
            return file_name[0..last];
        }
    }
    return null;
}

/// allDepsMessageNames returns the names of each message in deps.
/// The caller owns the return value;
pub fn allDepsMessageNames(allocator: std.mem.Allocator) ![][]const u8 {
    var file_names: [][]const u8 = try allDepsMessageFileNames(allocator);
    defer allocator.free(file_names);
    var message_names = std.ArrayList([]const u8).init(allocator);
    for (file_names) |file_name| {
        if (messageNameFromMessageFileName(file_name)) |message_name| {
            try message_names.append(message_name);
        }
    }
    // Return a slice that the caller owns.
    var unowned_slice: [][]const u8 = try message_names.toOwnedSlice();
    return ownedSlice(allocator, unowned_slice);
}

/// allDepsChannelNames returns the names of each channel.
/// The caller owns the return value;
pub fn allDepsChannelNames(allocator: std.mem.Allocator) ![][]const u8 {
    var channel_names = std.ArrayList([]const u8).init(allocator);
    defer channel_names.deinit();
    var folders = try paths.folders();
    defer folders.deinit();

    var dir = try std.fs.openIterableDirAbsolute(folders.root_src_this_deps_channel.?, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .file) {
            if (channelNameFromDepsChannelFileName(file.name)) |channel_name| {
                try channel_names.append(channel_name);
            }
        }
    }
    // Return a slice that the caller owns.
    var unowned_slice: [][]const u8 = try channel_names.toOwnedSlice();
    return ownedSlice(allocator, unowned_slice);
}

/// allCustomDepsChannelNames returns the names of each custom channel.
/// Does not return the names "Initialize" or "Fatal".
/// The caller owns the return value;
pub fn allCustomDepsChannelNames(allocator: std.mem.Allocator) ![][]const u8 {
    var channel_names = std.ArrayList([]const u8).init(allocator);
    defer channel_names.deinit();
    var folders = try paths.folders();
    defer folders.deinit();

    var dir = try std.fs.openIterableDirAbsolute(folders.root_src_this_deps_channel.?, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .file) {
            if (std.mem.eql(u8, file.name, initialize_file_name)) {
                continue;
            }
            if (std.mem.eql(u8, file.name, fatal_file_name)) {
                continue;
            }
            if (channelNameFromDepsChannelFileName(file.name)) |channel_name| {
                try channel_names.append(channel_name);
            }
        }
    }
    // Return a slice that the caller owns.
    var unowned_slice: [][]const u8 = try channel_names.toOwnedSlice();
    return ownedSlice(allocator, unowned_slice);
}

/// allDepsModalParamsNames returns the names of each modal params.
/// The caller owns the return value;
pub fn allDepsModalParamsNames(allocator: std.mem.Allocator) ![][]const u8 {
    var modal_params_names = std.ArrayList([]const u8).init(allocator);
    defer modal_params_names.deinit();
    var folders = try paths.folders();
    defer folders.deinit();

    var dir = try std.fs.openIterableDirAbsolute(folders.root_src_this_deps_modal_params.?, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |file| {
        if (file.kind == .file) {
            if (modalParamsNameFromDepsModalParamsFileName(file.name)) |modal_params_name| {
                try modal_params_names.append(modal_params_name);
            }
        }
    }
    // Return a slice that the caller owns.
    var unowned_slice: [][]const u8 = try modal_params_names.toOwnedSlice();
    return ownedSlice(allocator, unowned_slice);
}

/// allCustomDepsModalParamsNames returns the names of each custom modal_params.
/// Does not return the name "OK" or "YesNo".
/// The caller owns the return value;
pub fn allCustomDepsModalParamsNames(allocator: std.mem.Allocator) ![][]const u8 {
    var all_names: [][]const u8 = try allDepsModalParamsNames(allocator);
    defer allocator.free(all_names);
    var names: [][]const u8 = try allocator.alloc([]const u8, all_names.len - 2);
    if (names.len == 0) {
        return names;
    }
    var i: usize = 0;
    for (all_names) |name| {
        if (std.mem.eql(u8, name, "OK")) {
            continue;
        }
        if (std.mem.eql(u8, name, "YesNo")) {
            continue;
        }
        names[i] = try allocator.alloc(u8, name.len);
        errdefer {
            if (i > 0) {
                var deinit_names: [][]const u8 = names[0..i];
                for (deinit_names) |deinit_name| {
                    allocator.free(deinit_name);
                }
                allocator.free(names);
            }
        }
        @memcpy(@constCast(names[i]), name);
        i += 1;
    }
    return names;
}

fn ownedSlice(allocator: std.mem.Allocator, slices: [][]const u8) ![][]const u8 {
    var owned: [][]const u8 = try allocator.alloc([]const u8, slices.len);
    for (slices, 0..) |slice, i| {
        owned[i] = try allocator.alloc(u8, slice.len);
        errdefer {
            for (owned[0..i]) |deinit_owned| {
                allocator.free(deinit_owned);
            }
            allocator.free(owned);
        }
        @memcpy(@constCast(owned[i]), slice);
    }
    return owned;
}
