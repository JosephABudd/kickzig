const std = @import("std");
const _filenames_ = @import("filenames");
const _stdout_ = @import("stdout");

// List screens.

pub fn listScreens(allocator: std.mem.Allocator) !void {
    {
        // Panel screens.
        const screens: [][]const u8 = try _filenames_.frontend.allPanelFolders(allocator);
        defer allocator.free(screens);
        // Heading
        try printScreenNamesHeading(allocator, "Panel", screens.len);
        // List
        try printScreenNames(allocator, screens);
    }

    {
        // Tab screens.
        const screens: [][]const u8 = try _filenames_.frontend.allTabFolders(allocator);
        defer allocator.free(screens);
        // Heading
        try printScreenNamesHeading(allocator, "Tab", screens.len);
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
        const screens: [][]const u8 = try _filenames_.frontend.allModalFolders(allocator);
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
            const heading: []const u8 = try std.fmt.allocPrint(allocator, "There are no {s} screens.\n", .{screen_kind});
            defer allocator.free(heading);
            break :blk try _stdout_.print(heading);
        },
        1 => blk: {
            const heading: []const u8 = try std.fmt.allocPrint(allocator, "There is 1 {s} screen.\n", .{screen_kind});
            defer allocator.free(heading);
            break :blk try _stdout_.print(heading);
        },
        else => blk: {
            const heading: []const u8 = try std.fmt.allocPrint(allocator, "There are {d} {s} screens.\n", .{ count_screens, screen_kind });
            defer allocator.free(heading);
            break :blk try _stdout_.print(heading);
        },
    };
}

fn printScreenNames(allocator: std.mem.Allocator, screens: []const []const u8) !void {
    if (screens.len > 0) {
        // List
        const line: []u8 = try std.mem.join(allocator, "\n", screens);
        defer allocator.free(line);
        try _stdout_.print(line);
    }
    // Margin.
    try _stdout_.print("\n\n");
}
