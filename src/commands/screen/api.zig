const std = @import("std");
const _paths_ = @import("paths");
const _stdout_ = @import("stdout");
const _warning_ = @import("warning");
const _usage_ = @import("usage");
const _success_ = @import("success");
const _strings_ = @import("strings");
const _filenames_ = @import("filenames");
const _verify_ = @import("verify");
const _src_frontend_ = @import("source")._root_._src_.frontend;
const _src_deps_ = @import("source")._root_._src_.deps;

pub const command: []const u8 = "screen";
pub const verb_help: []const u8 = "help";
pub const verb_add_panel: []const u8 = "add-panel";
pub const verb_add_content: []const u8 = "add-content";
pub const verb_add_tab: []const u8 = "add-tab";
pub const verb_add_book: []const u8 = "add-book";
pub const verb_add_modal: []const u8 = "add-modal";
pub const verb_remove: []const u8 = "remove";
pub const verb_list: []const u8 = "list";

pub fn handleCommand(allocator: std.mem.Allocator, cli_name: []const u8, remaining_args: [][]const u8) !void {
    var folder_paths: *_paths_.FolderPaths = try _paths_.folders();
    defer folder_paths.deinit();
    return switch (remaining_args.len) {
        0 => blk: {
            // User input is "screen".
            break :blk try syntaxError(allocator, cli_name);
        },
        1 => blk: {
            const verb: []const u8 = remaining_args[0];
            // User input is "screen help", "screen list" or "screen 💩".
            if (std.mem.eql(u8, verb, verb_help)) {
                // The user input is "screen help".
                break :blk try help(allocator, cli_name);
            }
            if (std.mem.eql(u8, verb, verb_list)) {
                // The user input is "screen list".
                break :blk try _src_frontend_.listScreens(allocator);
            }
            // The user input is screen 💩.
            break :blk try syntaxError(allocator, cli_name);
        },
        2 => blk: {
            // The user input is:
            // "screen remove screen-name" or "screen 💩 💩"
            var is_valid: bool = false;
            const verb: []const u8 = remaining_args[0];
            const screen_name: []const u8 = remaining_args[1];
            if (std.mem.eql(u8, verb, verb_remove)) {
                // Is the screen name valid for remove?
                // User input is "screen remove Edit".
                // break :blk {
                // The screen name must be valid.
                is_valid = expectValidScreenName(allocator, screen_name) catch |err| {
                    break :blk err;
                };
                if (!is_valid) {
                    break :blk;
                }
                // The named screen must already exist.
                is_valid = expectExistingScreenName(allocator, screen_name) catch |err| {
                    break :blk err;
                };
                if (!is_valid) {
                    break :blk;
                }
                var removed: bool = false;
                removed = try _src_frontend_.removeTabScreen(allocator, _paths_.app_name.?, screen_name);
                if (!removed) {
                    removed = try _src_frontend_.removePanelScreen(allocator, _paths_.app_name.?, screen_name);
                }
                if (!removed) {
                    removed = try _src_frontend_.removeModalScreen(allocator, _paths_.app_name.?, screen_name);
                }
                if (!removed) {
                    removed = try _src_frontend_.removeBookScreen(allocator, _paths_.app_name.?, screen_name);
                }
                if (!removed) {
                    // This should never happen.
                    const msg: []const u8 = try _warning_.notExistingScreenName(allocator, remaining_args[1]);
                    defer allocator.free(msg);
                    try _stdout_.print(msg);
                    break :blk;
                }
                // The screen was removed.
                // Rebuild deps/framers/api.zig
                try _src_deps_.rebuildForUpdatedScreens(allocator);
                // Inform the user.
                const msg: []const u8 = try _success_.screenRemoved(allocator, screen_name);
                defer allocator.free(msg);
                try _stdout_.print(msg);
                break :blk;
            }
            // The user input is screen 💩 💩.
            break :blk try syntaxError(allocator, cli_name);
        },
        else => blk: {
            // The user input can be:
            // , only_frame_in_container: bool
            // "screen add-content Edit Select Edit"
            // "screen add-panel Edit Select Edit"
            // "screen add-tab Contacts +Add Edit Remove"
            // "screen add-book Story +Cover +Chapter1 +Chapter2 +Chapter3 +Chapter4 +Appendix"
            // "screen add-modal YesNo YesNo"
            // "screen 💩 💩 💩..."
            var is_valid: bool = false;
            const verb: []const u8 = remaining_args[0];
            const screen_name: []const u8 = remaining_args[1];
            const adding_panel_screen: bool = std.mem.eql(u8, verb, verb_add_panel);
            const adding_content_screen: bool = std.mem.eql(u8, verb, verb_add_content);
            if (adding_panel_screen or adding_content_screen) {
                // User input is "screen add-panel Edit Select Edit".
                // The screen name must be valid.
                is_valid = expectValidScreenName(allocator, screen_name) catch |err| {
                    break :blk err;
                };
                if (!is_valid) {
                    break :blk;
                }
                // The named screen must not exist.
                is_valid = expectNewScreenName(allocator, screen_name) catch |err| {
                    break :blk err;
                };
                if (!is_valid) {
                    break :blk;
                }
                const panel_names: [][]const u8 = remaining_args[2..];
                // The panel names must be valid.
                is_valid = expectValidPanelNames(allocator, panel_names) catch |err| {
                    break :blk err;
                };
                if (!is_valid) {
                    break :blk;
                }
                // The panel names must be unique.
                is_valid = expectUniquePanelNames(allocator, panel_names) catch |err| {
                    break :blk err;
                };
                if (!is_valid) {
                    break :blk;
                }
                // The user input is valid.
                // Add the panel screen.
                try _src_frontend_.addPanelScreen(allocator, _paths_.app_name.?, screen_name, panel_names, adding_content_screen);

                // Rebuild deps/framers/api.zig
                try _src_deps_.rebuildForUpdatedScreens(allocator);

                // Inform the user.
                var msg: []const u8 = undefined;
                if (adding_panel_screen) {
                    msg = try _success_.screenAddedPanel(allocator, screen_name);
                } else {
                    msg = try _success_.screenAddedContent(allocator, screen_name);
                }
                defer allocator.free(msg);
                try _stdout_.print(msg);
                break :blk;
            }
            if (std.mem.eql(u8, verb, verb_add_tab)) {
                // User input is "screen add-tab Contacts +Add Edit Remove".
                // The screen name must be valid.
                is_valid = expectValidScreenName(allocator, screen_name) catch |err| {
                    break :blk err;
                };
                if (!is_valid) {
                    break :blk;
                }
                // The named screen must not exist.
                is_valid = expectNewScreenName(allocator, screen_name) catch |err| {
                    break :blk err;
                };
                if (!is_valid) {
                    break :blk;
                }
                const tab_names: [][]const u8 = remaining_args[2..];
                // The tab names must be valid.
                is_valid = true;
                for (tab_names) |tab_name| {
                    if (tab_name[0] == '*') {
                        if (!try expectValidTabName(allocator, tab_name[1..])) {
                            is_valid = false;
                        }
                    } else {
                        if (!try expectValidTabName(allocator, tab_name)) {
                            is_valid = false;
                        }
                    }
                }
                if (!is_valid) {
                    break :blk;
                }
                // The tab names must be unique.
                if (!try expectUniqueTabNames(allocator, tab_names)) {
                    break :blk;
                }
                // A tab name beginning with '*' use a panel-screen for content.
                // There fore it must be a panel-screen name.
                // The panel-screen must already exist.
                is_valid = true;
                for (tab_names) |tab_name| {
                    if (tab_name[0] == '*') {
                        if (!try expectTabNameIsExistingPanelScreenName(allocator, tab_name[1..])) {
                            is_valid = false;
                        }
                    }
                }
                if (!is_valid) {
                    break :blk;
                }
                // The user input is valid.
                // Add the tab screen.
                try _src_frontend_.addTabScreen(allocator, _paths_.app_name.?, screen_name, tab_names);

                // Rebuild deps/framers/api.zig
                try _src_deps_.rebuildForUpdatedScreens(allocator);

                // Inform the user.
                const msg: []const u8 = try _success_.screenAddedTab(allocator, screen_name);
                defer allocator.free(msg);
                try _stdout_.print(msg);
                break :blk;
            }
            if (std.mem.eql(u8, verb, verb_add_book)) {
                // User input is "screen add-book Story +Cover +Chapter1 +Chapter2 +Chapter3 +Chapter4 +Appendix".
                // The screen name must be valid.
                is_valid = expectValidScreenName(allocator, screen_name) catch |err| {
                    break :blk err;
                };
                if (!is_valid) {
                    break :blk;
                }
                // The named screen must not already exist.
                is_valid = expectNewScreenName(allocator, screen_name) catch |err| {
                    break :blk err;
                };
                if (!is_valid) {
                    break :blk;
                }
                const menu_item_names: [][]const u8 = remaining_args[2..];
                // The tab names must be valid.
                is_valid = true;
                for (menu_item_names) |menu_item_name| {
                    if (!try expectValidTabName(allocator, menu_item_name)) {
                        is_valid = false;
                    }
                }
                if (!is_valid) {
                    break :blk;
                }
                // The tab names must be unique.
                if (!try expectUniqueTabNames(allocator, menu_item_names)) {
                    break :blk;
                }
                // The user input is valid.
                // Add the book screen.
                try _src_frontend_.addBookScreen(allocator, _paths_.app_name.?, screen_name, menu_item_names);

                // Rebuild deps/framers/api.zig
                try _src_deps_.rebuildForUpdatedScreens(allocator);

                // Inform the user.
                const msg: []const u8 = try _success_.screenAddedBook(allocator, screen_name);
                defer allocator.free(msg);
                try _stdout_.print(msg);
                break :blk;
            }
            if (std.mem.eql(u8, verb, verb_add_modal)) {
                // User input is "screen add-modal YesNo YesNo".
                // The screen name must be valid.
                is_valid = expectValidScreenName(allocator, screen_name) catch |err| {
                    break :blk err;
                };
                if (!is_valid) {
                    break :blk;
                }
                // The named screen must not exist.
                is_valid = expectNewScreenName(allocator, screen_name) catch |err| {
                    break :blk err;
                };
                if (!is_valid) {
                    break :blk;
                }
                const panel_names: [][]const u8 = remaining_args[2..];
                // The panel names must be valid.
                is_valid = expectValidPanelNames(allocator, panel_names) catch |err| {
                    break :blk err;
                };
                if (!is_valid) {
                    break :blk;
                }
                // The panel names must be unique.
                is_valid = expectUniquePanelNames(allocator, panel_names) catch |err| {
                    break :blk err;
                };
                if (!is_valid) {
                    break :blk;
                }
                // The user input is valid.
                // Add the modal screen.
                try _src_frontend_.addModalScreen(allocator, _paths_.app_name.?, screen_name, panel_names);

                // Rebuild deps/framers/api.zig
                try _src_deps_.rebuildForUpdatedScreens(allocator);

                // Inform the user.
                const msg: []const u8 = try _success_.screenAddedModal(allocator, screen_name);
                defer allocator.free(msg);
                try _stdout_.print(msg);
                break :blk;
            }
            // "The user input is screen 💩 💩 💩..."
            break :blk try syntaxError(allocator, cli_name);
        },
    };
}

fn syntaxError(allocator: std.mem.Allocator, cli_name: []const u8) !void {
    const message: []const u8 = try _warning_.syntaxError(allocator, cli_name, command, verb_help);
    defer allocator.free(message);
    try _stdout_.print(message);
}

fn help(allocator: std.mem.Allocator, cli_name: []const u8) !void {
    const usage: []u8 = try _usage_.screen(allocator, cli_name);
    defer allocator.free(usage);
    try _stdout_.print(usage);
}

// Expects

fn expectValidPanelNames(allocator: std.mem.Allocator, names: [][]const u8) !bool {
    var is_valid: bool = true;
    for (names) |name| {
        if (!try expectValidPanelName(allocator, name)) {
            is_valid = false;
        }
    }
    return is_valid;
}

fn expectUniquePanelNames(allocator: std.mem.Allocator, names: [][]const u8) !bool {
    var is_valid: bool = true;
    const last: usize = names.len - 1;
    for (names, 0..) |name, i| {
        if (i == last) {
            // Skip the last name.
            break;
        }
        for (i + 1..last) |j| {
            if (std.mem.eql(u8, name, names[j])) {
                is_valid = false;
                const msg: []const u8 = try _warning_.notUniqueScreenName(allocator, name);
                defer allocator.free(msg);
                try _stdout_.print(msg);
            }
        }
    }
    return is_valid;
}

fn expectValidScreenName(allocator: std.mem.Allocator, screen_name: []const u8) !bool {
    var is_valid: bool = _strings_.isValid(screen_name);
    if (!is_valid) {
        const msg: []const u8 = try _warning_.notValidScreenName(allocator, screen_name);
        defer allocator.free(msg);
        try _stdout_.print(msg);
    }
    is_valid = !_filenames_.isFrameworkScreenName(screen_name);
    if (!is_valid) {
        const msg: []const u8 = try _warning_.partOfFrameworkScreenName(allocator, screen_name);
        defer allocator.free(msg);
        try _stdout_.print(msg);
    }
    return is_valid;
}

fn expectValidPanelName(allocator: std.mem.Allocator, panel_name: []const u8) !bool {
    const is_valid: bool = _strings_.isValid(panel_name);
    if (!is_valid) {
        const msg: []const u8 = try _warning_.notValidPanelName(allocator, panel_name);
        defer allocator.free(msg);
        try _stdout_.print(msg);
    }
    return is_valid;
}

fn expectExistingScreenName(allocator: std.mem.Allocator, screen_name: []const u8) !bool {
    const all_names: [][]const u8 = try _filenames_.allFrontendScreenNames(allocator);
    defer {
        for (all_names) |name| {
            allocator.free(name);
        }
        allocator.free(all_names);
    }
    for (all_names) |name| {
        if (std.mem.eql(u8, name, screen_name)) {
            return true;
        }
    }
    // Error: This is a new screen name.
    const msg: []const u8 = try _warning_.notExistingScreenName(allocator, screen_name);
    defer allocator.free(msg);
    try _stdout_.print(msg);
    return false;
}

fn expectNewScreenName(allocator: std.mem.Allocator, screen_name: []const u8) !bool {
    const all_names: [][]const u8 = try _filenames_.allFrontendScreenNames(allocator);
    defer {
        for (all_names) |name| {
            allocator.free(name);
        }
        allocator.free(all_names);
    }
    var is_new: bool = true;
    for (all_names) |name| {
        if (std.mem.eql(u8, name, screen_name)) {
            is_new = false;
            break;
        }
    }
    if (!is_new) {
        // Error: This is a current screen.
        const msg: []const u8 = try _warning_.notNewScreenName(allocator, screen_name);
        defer allocator.free(msg);
        try _stdout_.print(msg);
    }
    return is_new;
}

fn expectValidTabName(allocator: std.mem.Allocator, tab_name: []const u8) !bool {
    const is_valid: bool = _verify_.isValidTabName(tab_name);
    if (!is_valid) {
        const msg: []const u8 = try _warning_.notValidScreenTabName(allocator, tab_name);
        defer allocator.free(msg);
        try _stdout_.print(msg);
    }
    return is_valid;
}

fn expectUniqueTabNames(allocator: std.mem.Allocator, names: [][]const u8) !bool {
    var is_valid: bool = true;
    const last: usize = names.len - 1;
    for (names, 0..) |name, i| {
        if (i == last) {
            // Skip the last name.
            break;
        }
        for (i + 1..last) |j| {
            if (std.mem.eql(u8, name, names[j])) {
                // This is a duplicate tab name.
                is_valid = false;
                var tab_name: []const u8 = undefined;
                if (name[0] == '*') {
                    tab_name = name[1..];
                } else {
                    tab_name = name;
                }
                const msg: []const u8 = try _warning_.notUniqueTabName(allocator, tab_name);
                defer allocator.free(msg);
                try _stdout_.print(msg);
            }
        }
    }
    return is_valid;
}

fn expectTabNameIsExistingPanelScreenName(allocator: std.mem.Allocator, tab_name: []const u8) !bool {
    const panel_screen_names: [][]const u8 = try _filenames_.allFrontendPanelScreenNames(allocator);
    defer {
        for (panel_screen_names) |panel_screen_name| {
            allocator.free(panel_screen_name);
        }
        allocator.free(panel_screen_names);
    }
    // In a tab, a screen-tab name must be an existing panel-screen name.
    for (panel_screen_names) |panel_screen_name| {
        if (std.mem.eql(u8, panel_screen_name, tab_name)) {
            return true;
        }
    }
    // The tab name is not a panel-screen name.
    const msg: []const u8 = try _warning_.notValidScreenTabName(allocator, tab_name);
    defer allocator.free(msg);
    try _stdout_.print(msg);
    return false;
}
