const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    app_name: []const u8,

    // The caller owns the returned value.
    pub fn init(allocator: std.mem.Allocator, app_name: []const u8) !*Template {
        var data: *Template = try allocator.create(Template);
        data.app_name = try allocator.alloc(u8, app_name.len);
        errdefer {
            allocator.destroy(data);
        }
        @memcpy(@constCast(data.app_name), app_name);
        data.allocator = allocator;
        return data;
    }

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.app_name);
        self.allocator.destroy(self);
    }

    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        // Replace {{ app_name }} with the app name.
        const replacement_size: usize = std.mem.replacementSize(u8, template, "{{ app_name }}", self.app_name);
        const with_app_name: []u8 = try self.allocator.alloc(u8, replacement_size);
        _ = std.mem.replace(u8, template, "{{ app_name }}", self.app_name, with_app_name);
        return with_app_name;
    }
};

const template =
    \\.{
    \\    .name = "{{ app_name }}",
    \\    .version = "0.0.0",
    \\    .dependencies = .{
    \\        .dvui = .{
    \\            .url = "https://github.com/david-vanderson/dvui/archive/27b59c5f25350ad4481110eecd0920b828e61a30.tar.gz",
    \\            .hash = "1220ed3bf40a032dc1d677d4663160ec7f4f18f4b5887d57b691ae7005335449f5d5",
    \\        },
    \\    },
    \\    // Specifies the set of files and directories that are included in this package.
    \\    // Only files and directories listed here are included in the `hash` that
    \\    // is computed for this package.
    \\    // Paths are relative to the build root. Use the empty string (`""`) to refer to
    \\    // the build root itself.
    \\    // A directory listed here means that all files within, recursively, are included.
    \\    .paths = .{
    \\        // This makes *all* files, recursively, included in this package. It is generally
    \\        // better to explicitly list the files and directories instead, to insure that
    \\        // fetching from tarballs, file system paths, and version control all result
    \\        // in the same contents hash.
    \\        "",
    \\        // For example...
    \\        //"build.zig",
    \\        //"build.zig.zon",
    \\        //"src",
    \\        //"LICENSE",
    \\        //"README.md",
    \\    },
    \\}
;
