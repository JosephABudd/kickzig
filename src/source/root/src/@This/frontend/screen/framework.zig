const std = @import("std");
const fspath = std.fs.path;
const _panel_screen_ = @import("panel/framework.zig");
const _ok_modal_screen_ = @import("modal/ok/framework.zig");
const _filenames_ = @import("filenames");
const _stdout_ = @import("stdout");

// List screens.

pub fn listScreens(allocator: std.mem.Allocator) !void {
    {
        // Panel screens.
        var screens: [][]const u8 = try _filenames_.frontend.allPanelFolders(allocator);
        defer allocator.free(screens);
        // Heading
        try printScreenNamesHeading(allocator, "Panel", screens.len);
        // List
        try printScreenNames(allocator, screens);
    }

    {
        // HTab screens.
        var screens: [][]const u8 = try _filenames_.frontend.allHTabFolders(allocator);
        defer allocator.free(screens);
        // Heading
        try printScreenNamesHeading(allocator, "HTab", screens.len);
        // List
        try printScreenNames(allocator, screens);
    }

    {
        // VTab screens.
        var screens: [][]const u8 = try _filenames_.frontend.allVTabFolders(allocator);
        defer allocator.free(screens);
        // Heading
        try printScreenNamesHeading(allocator, "VTab", screens.len);
        // List
        try printScreenNames(allocator, screens);
    }

    // {
    //     // Book screens.
    //     var screens: [][]const u8 = try _filenames_.frontend.allBookFolders(allocator);
    //     defer allocator.free(screens);
    //     // Heading
    //     try printScreenNamesHeading(allocator, "Book", screens.len);
    //     // List
    //     try printScreenNames(allocator, screens);
    // }

    {
        // Modal screens.
        var screens: [][]const u8 = try _filenames_.frontend.allModalFolders(allocator);
        defer allocator.free(screens);
        // Heading
        try printScreenNamesHeading(allocator, "Modal", screens.len);
        // List
        try printScreenNames(allocator, screens);
    }
}

fn printScreenNamesHeading(allocator: std.mem.Allocator, screen_kind: []const u8, count_screens: usize) !void {
    return switch (count_screens) {
        0 => blk: {
            var heading: []const u8 = try std.fmt.allocPrint(allocator, "There are no {s} screens.\n", .{screen_kind});
            defer allocator.free(heading);
            break :blk try _stdout_.print(heading);
        },
        1 => blk: {
            var heading: []const u8 = try std.fmt.allocPrint(allocator, "There is 1 {s} screen.\n", .{screen_kind});
            defer allocator.free(heading);
            break :blk try _stdout_.print(heading);
        },
        else => blk: {
            var heading: []const u8 = try std.fmt.allocPrint(allocator, "There are {d} {s} screens.\n", .{ count_screens, screen_kind });
            defer allocator.free(heading);
            break :blk try _stdout_.print(heading);
        },
    };
}

fn printScreenNames(allocator: std.mem.Allocator, screens: []const []const u8) !void {
    if (screens.len > 0) {
        // List
        var line: []u8 = try std.mem.join(allocator, "\n", screens);
        defer allocator.free(line);
        try _stdout_.print(line);
    }
    // Margin.
    try _stdout_.print("\n\n");
}
