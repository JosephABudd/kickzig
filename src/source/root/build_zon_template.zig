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
    \\    .version = "0.0.1",
    \\    .dependencies = .{
    \\        //.sdl = .{
    \\            //.url = "https://github.com/Beyley/SDL/archive/587205c11bfd88d515408209ca4b1c271e9f5db9.tar.gz",
    \\            //.hash = "1220da316edbe998b3ae807af6b22b4f8c713c0b77b72275a5bc358b115ee3ecec14",
    \\        //},
    \\        .freetype = .{
    \\            .url = "https://github.com/david-vanderson/freetype/archive/18a1df5a3ef8afa0782c419b153a21e9e160335f.tar.gz",
    \\            .hash = "1220b305af272ac3026704b8d7e13740350daf59a6a95e45dedb428c55933e3df925",
    \\        },
    \\        .stb_image = .{
    \\            .url = "https://github.com/david-vanderson/stb_image/archive/9a961327f5e67ec799bc9a6258d7abebb59d7028.tar.gz",
    \\            .hash = "1220e47cea6fd7a0098a1b0ac3e47a2c3b558dc3afb0a75c71d7b00e53936824287e",
    \\        },
    \\    },
    \\}
;
