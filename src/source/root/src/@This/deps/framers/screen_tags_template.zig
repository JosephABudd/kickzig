const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_names: [][]const u8,
    screen_names_index: usize,

    pub fn init(allocator: std.mem.Allocator) !*Template {
        var data: *Template = try allocator.create(Template);
        data.screen_names = try allocator.alloc([]const u8, 5);
        errdefer {
            allocator.destroy(data);
        }
        data.screen_names_index = 0;
        data.allocator = allocator;
        return data;
    }

    pub fn deinit(self: *Template) void {
        for (self.screen_names, 0..) |name, i| {
            if (i == self.screen_names_index) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self.screen_names);
        self.allocator.destroy(self);
    }

    pub fn addScreenName(self: *Template, new_name: []const u8) !void {
        var new_screen_names: [][]const u8 = undefined;
        if (self.screen_names_index == self.screen_names.len) {
            // Full list so create a new bigger one.
            new_screen_names = try self.allocator.alloc([]const u8, (self.screen_names.len + 5));
            for (self.screen_names, 0..) |name, i| {
                new_screen_names[i] = name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self.screen_names);
            self.screen_names = new_screen_names;
        }
        self.screen_names[self.screen_names_index] = try self.allocator.alloc(u8, new_name.len);
        @memcpy(@constCast(self.screen_names[self.screen_names_index]), new_name);
        self.screen_names_index += 1;
    }

    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        const screen_names: ?[][]const u8 = switch (self.screen_names_index) {
            0 => null,
            else => self.screen_names[0..self.screen_names_index],
        };

        var line: []u8 = undefined;
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();

        // Build the content.
        try lines.appendSlice(line1);

        // Tag each screen.
        if (screen_names) |names| {
            for (names) |name| {
                // Replace {{ screen_name }} with the message name.
                const replacement_size: usize = std.mem.replacementSize(u8, line_tag, "{{ screen_name }}", name);
                line = try self.allocator.alloc(u8, replacement_size);
                defer self.allocator.free(line);
                _ = std.mem.replace(u8, line_tag, "{{ screen_name }}", name, line);
                try lines.appendSlice(line);
            }
        }

        try lines.appendSlice(line2);

        const temp: []const u8 = try lines.toOwnedSlice();
        line = try self.allocator.alloc(u8, temp.len);
        @memcpy(line, temp);
        return line;
    }
};

const line1 =
    \\pub const ScreenTags = enum {
    \\
;

const line_tag =
    \\    {{ screen_name }},
    \\
;

const line2 =
    \\};
    \\
;
