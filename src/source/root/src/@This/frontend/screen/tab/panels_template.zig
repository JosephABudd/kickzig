const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    panel_names: [][]const u8,
    panel_names_index: usize,

    pub fn deinit(self: *Template) void {
        for (self.panel_names, 0..) |name, i| {
            if (i == self.panel_names_index) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self.panel_names);
        self.allocator.destroy(self);
    }

    pub fn addName(self: *Template, new_name: []const u8) !void {
        if (self.panel_names_index == self.panel_names.len) {
            // Full list so create a new bigger one.
            var new_panel_names: [][]const u8 = try self.allocator.alloc([]const u8, (self.panel_names.len + 5));
            for (self.panel_names, 0..) |name, i| {
                new_panel_names[i] = name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self.panel_names);
            self.panel_names = new_panel_names;
        }
        self.panel_names[self.panel_names_index] = try self.allocator.alloc(u8, new_name.len);
        @memcpy(@constCast(self.panel_names[self.panel_names_index]), new_name);
        self.panel_names_index += 1;
    }

    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        var line: []u8 = undefined;
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        const names: [][]const u8 = self.panel_names[0..self.panel_names_index];

        try lines.appendSlice(line_start);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_tag, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line_end);

        return try lines.toOwnedSlice();
    }
};

pub fn init(allocator: std.mem.Allocator) !*Template {
    var data: *Template = try allocator.create(Template);
    data.panel_names = try allocator.alloc([]const u8, 5);
    errdefer {
        allocator.destroy(data);
    }
    errdefer {
        allocator.free(data.panel_names);
        allocator.destroy(data);
    }
    data.panel_names_index = 0;
    data.allocator = allocator;
    return data;
}

const line_start =
    \\pub const PanelTags = enum {
    \\
;
const line_tag =
    \\    {0s},
    \\
;
const line_end =
    \\    none,
    \\};
    \\
    \\
;
