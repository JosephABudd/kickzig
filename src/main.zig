const std = @import("std");
const stdout = @import("stdout");

pub fn main() !void {
    // Memory allocator.
    var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpa_instance.allocator();
    _ = gpa;

    // Current working directory.
    var cwd_buffer: []const u8 = [255]u8;
    var cwd: []const u8 = try std.os.getcwd(cwd_buffer);
    _ = cwd;

    // Is this folder built yet?
    var is_built: bool =

        // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
        std.debug.print("debug:  All your {s} are belong to us.\n", .{"codebase"});
    _ = is_built;
    try stdout.print("stdout: All your {s} are belong to us.\n", .{"codebase"});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
