const std = @import("std");
const fmt = std.fmt;
const strings = @import("strings");

pub const Template = struct {
    allocator: std.mem.Allocator,
    _modal_param_names: []*strings.UTF8,
    _modal_param_names_index: usize,

    pub fn init(allocator: std.mem.Allocator) !*Template {
        var data: *Template = try allocator.create(Template);
        data._modal_param_names = try allocator.alloc(*strings.UTF8, 5);
        errdefer {
            allocator.destroy(data);
        }
        data._modal_param_names_index = 0;
        data.allocator = allocator;
        return data;
    }

    pub fn deinit(self: *Template) void {
        for (self._modal_param_names, 0..) |name, i| {
            if (i == self._modal_param_names_index) {
                break;
            }
            name.deinit();
        }
        self.allocator.free(self._modal_param_names);
        self.allocator.destroy(self);
    }

    pub fn addName(self: *Template, new_name: []const u8) !void {
        var new_modal_param_names: []*strings.UTF8 = undefined;
        if (self._modal_param_names_index == self._modal_param_names.len) {
            // Full list so create a new bigger one.
            new_modal_param_names = try self.allocator.alloc(*strings.UTF8, (self._modal_param_names.len + 5));
            for (self._modal_param_names, 0..) |name, i| {
                new_modal_param_names[i] = name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self._modal_param_names);
            self._modal_param_names = new_modal_param_names;
        }
        var utf8: *strings.UTF8 = try strings.UTF8.init(self.allocator, new_name);
        self._modal_param_names[self._modal_param_names_index] = utf8;
        self._modal_param_names_index += 1;
    }

    pub fn content(self: *Template) ![]const u8 {
        var line: []u8 = undefined;
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        try lines.appendSlice(line1);
        var names: []*strings.UTF8 = self._modal_param_names[0..self._modal_param_names_index];
        var copy: []const u8 = undefined;
        for (names) |name| {
            {
                copy = try name.copy();
                defer self.allocator.free(copy);
                line = try fmt.allocPrint(self.allocator, "pub const {s} = @import(\"{s}.zig\").Args;\n", .{ copy, copy });
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        return try lines.toOwnedSlice();
    }
};

const line1 =
    \\pub const OK = @import("OK.zig").Params;
    \\
;
