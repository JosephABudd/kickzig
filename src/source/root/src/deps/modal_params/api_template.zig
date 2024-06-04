const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    modal_param_names: [][]const u8,
    modal_param_names_index: usize,

    pub fn init(allocator: std.mem.Allocator) !*Template {
        var data: *Template = try allocator.create(Template);
        data.modal_param_names = try allocator.alloc([]const u8, 5);
        errdefer {
            allocator.destroy(data);
        }
        data.modal_param_names_index = 0;
        data.allocator = allocator;
        return data;
    }

    pub fn deinit(self: *Template) void {
        for (self.modal_param_names, 0..) |name, i| {
            if (i == self.modal_param_names_index) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self.modal_param_names);
        self.allocator.destroy(self);
    }

    pub fn addName(self: *Template, new_name: []const u8) !void {
        var newmodal_param_names: [][]const u8 = undefined;
        if (self.modal_param_names_index == self.modal_param_names.len) {
            // Full list so create a new bigger one.
            newmodal_param_names = try self.allocator.alloc([]const u8, (self.modal_param_names.len + 5));
            for (self.modal_param_names, 0..) |name, i| {
                newmodal_param_names[i] = name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self.modal_param_names);
            self.modal_param_names = newmodal_param_names;
        }
        self.modal_param_names[self.modal_param_names_index] = try self.allocator.alloc(u8, new_name.len);
        @memcpy(@constCast(self.modal_param_names[self.modal_param_names_index]), new_name);
        self.modal_param_names_index += 1;
    }

    pub fn content(self: *Template) ![]const u8 {
        var line: []u8 = undefined;
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        try lines.appendSlice(line_start);
        const names: [][]const u8 = self.modal_param_names[0..self.modal_param_names_index];
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_import, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line_end);
        return try lines.toOwnedSlice();
    }
};

const line_start =
    \\pub const OK = @import("OK.zig").Params;
    \\pub const YesNo = @import("YesNo.zig").Params;
    \\pub const EOJ = @import("EOJ.zig").Params;
    \\
;

const line_import =
    \\pub const {0s} = @import("{0s}.zig").Params;
    \\
;

const line_end =
    \\
    \\
;
