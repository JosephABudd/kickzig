const std = @import("std");
const _paths_ = @import("paths");
const _stdout_ = @import("stdout");
const _source_ = @import("source").frontend;
const _warning_ = @import("warning");
const _usage_ = @import("usage");
const _strings_ = @import("strings");
const _filenames_ = @import("filenames");
const _verify_ = @import("verify");

pub const command: []const u8 = "screen";
pub const verb_help: []const u8 = "help";
pub const verb_add_panel: []const u8 = "add-panel";
pub const verb_add_vtab: []const u8 = "add-vtab";
pub const verb_add_htab: []const u8 = "add-htab";
pub const verb_add_book: []const u8 = "add-book";
pub const verb_add_modal: []const u8 = "add-modal";
pub const verb_remove: []const u8 = "remove";
pub const verb_list: []const u8 = "list";

pub fn handleCommand(allocator: std.mem.Allocator, cli_name: []const u8, app_name: []const u8, remaining_args: [][]const u8) !void {
    var folder_paths: *_paths_.FolderPaths = try _paths_.folders();
    defer folder_paths.deinit();
    std.debug.print("handleCommand: remaining_args.len:{d}\n", .{remaining_args.len});
    for (remaining_args) |arg| {
        std.debug.print("    {s}\n", .{arg});
    }
    return switch (remaining_args.len) {
        0 => blk: {
            // User input is "screen".
            // The user input is invalid so show the help.
            break :blk try help(allocator, cli_name);
        },
        1 => blk: {
            var verb: []const u8 = remaining_args[0];
            // User input is "screen help", "screen list" or "screen 💩".
            if (std.mem.eql(u8, verb, verb_help)) {
                // The user input is "screen help".
                break :blk try help(allocator, cli_name);
            }
            if (std.mem.eql(u8, verb, verb_list)) {
                // The user input is "screen list".
                break :blk try _source_.listScreens(allocator);
            }
            // "screen 💩"
            // The user input is invalid so show the help.
            break :blk try help(allocator, cli_name);
        },
        2 => blk: {
            // The user input is:
            // "screen remove screen-name" or "screen 💩 💩"
            var is_valid: bool = false;
            var verb: []const u8 = remaining_args[0];
            var screen_name: []const u8 = remaining_args[1];
            std.debug.print("2 -> blk: {s} {any}\n", .{ verb, screen_name });
            if (std.mem.eql(u8, verb, verb_remove)) {
                // Is the screen name valid for remove?
                // User input is "screen remove Edit".
                break :blk {
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
                    removed = try _source_.removeVTabScreen(allocator, app_name, screen_name);
                    if (!removed) {
                        removed = try _source_.removeHTabScreen(allocator, app_name, screen_name);
                    }
                    if (!removed) {
                        removed = try _source_.removePanelScreen(allocator, app_name, screen_name);
                    }
                    if (!removed) {
                        removed = try _source_.removeBookScreen(allocator, app_name, screen_name);
                    }
                    var msg: []const u8 = undefined;
                    if (removed) {
                        // Inform the user.
                        msg = try std.fmt.allocPrint(allocator, "The screen «{s}» has been removed.\n", .{screen_name});
                    } else {
                        // Inform the user.
                        msg = try std.fmt.allocPrint(allocator, "The screen «{s}» was not found.\n", .{remaining_args[1]});
                    }
                    try _stdout_.print(msg);
                };
            }
            // "screen 💩 💩"
            // The user input is invalid so show the help.
            break :blk try help(allocator, cli_name);
        },
        else => blk: {
            // The user input can be:
            // "screen add-panel Edit Select Edit"
            // "screen add-vtab Contacts +Add Edit Remove"
            // "screen add-htab Contacts +Add Edit Remove"
            // "screen add-book Story +Cover +Chapter1 +Chapter2 +Chapter3 +Chapter4 +Appendix"
            // "screen add-modal YesNo YesNo"
            // "screen 💩 💩 💩..."
            var is_valid: bool = false;
            var verb: []const u8 = remaining_args[0];
            var screen_name: []const u8 = remaining_args[1];
            if (std.mem.eql(u8, verb, verb_add_panel)) {
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
                var panel_names: [][]const u8 = remaining_args[2..];
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
                break :blk try _source_.addPanelScreen(allocator, app_name, screen_name, panel_names);
            }
            if (std.mem.eql(u8, verb, verb_add_vtab)) {
                // User input is "screen add-vtab Contacts +Add Edit Remove".
                // The screen name must be valid.
                is_valid = expectValidScreenName(allocator, screen_name) catch |err| {
                    break :blk err;
                };
                if (!is_valid) {
                    break :blk;
                }
                // The named screen must already exist.
                is_valid = expectNewScreenName(allocator, screen_name) catch |err| {
                    break :blk err;
                };
                if (!is_valid) {
                    break :blk;
                }
                var tab_names: [][]const u8 = remaining_args[2..];
                // The tab names must be valid.
                is_valid = true;
                for (tab_names) |tab_name| {
                    if (!try expectValidTabName(allocator, tab_name)) {
                        is_valid = false;
                    }
                }
                if (!is_valid) {
                    break :blk;
                }
                // The tab names must be unique.
                if (!try expectUniqueTabNames(allocator, tab_names)) {
                    break :blk;
                }
                // The user input is valid.
                // Add the vtab screen.
                break :blk try _source_.addVTabScreen(allocator, app_name, screen_name, tab_names);
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
                var menu_item_names: [][]const u8 = remaining_args[2..];
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
                break :blk try _source_.addBookScreen(allocator, app_name, screen_name, menu_item_names);
            }
            if (std.mem.eql(u8, verb, verb_add_htab)) {
                // User input is "screen add-htab Contacts +Add Edit Remove".
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
                var tab_names: [][]const u8 = remaining_args[2..];
                // The tab names must be valid.
                is_valid = true;
                for (tab_names) |tab_name| {
                    if (!try expectValidTabName(allocator, tab_name)) {
                        is_valid = false;
                    }
                }
                if (!is_valid) {
                    break :blk;
                }
                // The tab names must be unique.
                if (!try expectUniqueTabNames(allocator, tab_names)) {
                    break :blk;
                }
                // The user input is valid.
                // Add the htab screen.
                break :blk try _source_.addHTabScreen(allocator, app_name, screen_name, tab_names);
            }
            if (std.mem.eql(u8, verb, verb_add_modal)) {
                // "screen add-modal YesNo YesNo"
                break :blk try addModal(allocator, screen_name, remaining_args[2..]);
            }
            // "screen 💩 💩 💩..."
            // The user input is invalid so show the help.
            break :blk try help(allocator, cli_name);
        },
    };
}

fn addHTab(allocator: std.mem.Allocator, screen_name: []const u8, tab_names: [][]const u8) !void {
    _ = tab_names;
    _ = screen_name;
    _ = allocator;
}

fn addModal(allocator: std.mem.Allocator, screen_name: []const u8, tab_names: [][]const u8) !void {
    _ = tab_names;
    _ = screen_name;
    _ = allocator;
}

fn remove(allocator: std.mem.Allocator, screen_name: []const u8) !void {
    _ = screen_name;
    _ = allocator;
}

fn help(allocator: std.mem.Allocator, cli_name: []const u8) !void {
    var usage: []u8 = try _usage_.screen(allocator, cli_name);
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
    var last: usize = names.len - 1;
    for (names, 0..) |name, i| {
        if (i == last) {
            // Skip the last name.
            break;
        }
        for (i + 1..last) |j| {
            if (std.mem.eql(u8, name, names[j])) {
                is_valid = false;
                var msg: []const u8 = try std.fmt.allocPrint(allocator, "{s} is not a unique panel name.\n", .{name});
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
        var msg: []const u8 = try std.fmt.allocPrint(allocator, "{s} is not a valid screen name.\n", .{screen_name});
        defer allocator.free(msg);
        try _stdout_.print(msg);
    }
    return is_valid;
}

fn expectValidPanelName(allocator: std.mem.Allocator, panel_name: []const u8) !bool {
    var is_valid: bool = _strings_.isValid(panel_name);
    if (!is_valid) {
        var msg: []const u8 = try std.fmt.allocPrint(allocator, "{s} is not a valid panel name.\n", .{panel_name});
        defer allocator.free(msg);
        try _stdout_.print(msg);
    }
    return is_valid;
}

fn expectExistingScreenName(allocator: std.mem.Allocator, screen_name: []const u8) !bool {
    var all_names: [][]const u8 = try _filenames_.allFrontendScreenNames(allocator);
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
    // Error: New screen name.
    var msg: []const u8 = try std.fmt.allocPrint(allocator, "{s} is not an existing screen name.\n", .{screen_name});
    defer allocator.free(msg);
    try _stdout_.print(msg);
    return false;
}

fn expectNewScreenName(allocator: std.mem.Allocator, screen_name: []const u8) !bool {
    var all_names: [][]const u8 = try _filenames_.allFrontendScreenNames(allocator);
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
        }
    }
    if (!is_new) {
        // Error: An existing screen.
        var msg: []const u8 = try std.fmt.allocPrint(allocator, "{s} is an existing screen name.\n", .{screen_name});
        defer allocator.free(msg);
        try _stdout_.print(msg);
    }
    return is_new;
}

fn expectValidTabName(allocator: std.mem.Allocator, tab_name: []const u8) !bool {
    var is_valid: bool = _verify_.isValidTabName(tab_name);
    if (!is_valid) {
        var msg: []const u8 = try std.fmt.allocPrint(allocator, "{s} is not a valid tab name.\n", .{tab_name});
        defer allocator.free(msg);
        try _stdout_.print(msg);
    }
    return is_valid;
}

fn expectUniqueTabNames(allocator: std.mem.Allocator, names: [][]const u8) !bool {
    var is_valid: bool = true;
    var last: usize = names.len - 1;
    for (names, 0..) |name, i| {
        if (i == last) {
            // Skip the last name.
            break;
        }
        for (i + 1..last) |j| {
            if (std.mem.eql(u8, name, names[j])) {
                is_valid = false;
                var tab_name: []const u8 = undefined;
                if (name[0] == '+') {
                    tab_name = name[1..];
                } else {
                    tab_name = name;
                }
                var msg: []const u8 = try std.fmt.allocPrint(allocator, "{s} is not a unique tab name.\n", .{tab_name});
                defer allocator.free(msg);
                try _stdout_.print(msg);
            }
        }
    }
    return is_valid;
}

fn expectNewTabName(allocator: std.mem.Allocator, screen_name: []const u8, tab_name: []const u8) !bool {
    var fixed_tab_name: []const u8 = undefined;
    if (tab_name[0] == '+') {
        fixed_tab_name = tab_name[1..];
    } else {
        fixed_tab_name = tab_name;
    }
    var panel_names: [][]const u8 = try _filenames_.allFrontendVTabScreenPanelNames(allocator, screen_name, tab_name);
    defer {
        for (panel_names) |panel_name| {
            allocator.free(panel_name);
        }
        allocator.free(panel_names);
    }
    // In a vtab and htab, a panel has the same name as its tab.
    for (panel_names) |panel_name| {
        if (std.mem.eql(u8, panel_name, fixed_tab_name)) {
            // The tab name is not a new tab name.
            var msg: []const u8 = try std.fmt.allocPrint(allocator, "{s} is not a unique tab name.\n", .{fixed_tab_name});
            defer allocator.free(msg);
            try _stdout_.print(msg);
            return false;
        }
    }
    return true;
}
