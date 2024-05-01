const std = @import("std");
const paths = @import("paths");

pub const counter_file_name = "counter.zig";
pub const api_file_name = "api.zig";
pub const closedownjobs_file_name = "CloseDownJobs.zig";
pub const closedownjobs_message_name = "CloseDownJobs";
pub const eoj_file_name = "EOJ.zig";
pub const tabbar_widget_file_name = "TabBarWidget.zig";
pub const tabbar_item_widget_file_name = "TabBarItemWidget.zig";
pub const general_dispatcher_file_name = "general_dispatcher.zig";

pub fn allMessageNames(allocator: std.mem.Allocator) ![][]const u8 {
    const folders = try paths.folders();

    // The screen's folder path.
    var dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_message.?, .{ .iterate = true });
    defer dir.close();

    // The files.
    var file_names = std.ArrayList([]const u8).init(allocator);
    defer file_names.deinit();
    var iterator = dir.iterate();
    // iterator.reset();
    while (try iterator.next()) |file| {
        if (file.kind == .file) {
            if (std.mem.eql(u8, file.name, api_file_name)) {
                // Ignore "api.zig";
                continue;
            }
            if (std.mem.eql(u8, file.name, counter_file_name)) {
                // Ignore "counter.zig";
                continue;
            }
            try file_names.append(file.name);
        }
    }
    const slice: [][]const u8 = try file_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, slice.len);
    for (slice, 0..) |name, i| {
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

pub fn allCustomMessageNames(allocator: std.mem.Allocator) ![][]const u8 {
    const folders = try paths.folders();

    // The screen's folder path.
    var dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_message.?, .{ .iterate = true });
    defer dir.close();

    // The files.
    var file_names = std.ArrayList([]const u8).init(allocator);
    defer file_names.deinit();
    var iterator = dir.iterate();
    // iterator.reset();
    while (try iterator.next()) |file| {
        if (file.kind == .file) {
            if (std.mem.eql(u8, file.name, api_file_name)) {
                // Ignore "api.zig";
                continue;
            }
            if (std.mem.eql(u8, file.name, closedownjobs_file_name)) {
                // Ignore "CloseDownJobs.zig";
                continue;
            }
            try file_names.append(file.name);
        }
    }
    const slice: [][]const u8 = try file_names.toOwnedSlice();
    var names: [][]const u8 = try allocator.alloc([]const u8, slice.len);
    for (slice, 0..) |name, i| {
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
