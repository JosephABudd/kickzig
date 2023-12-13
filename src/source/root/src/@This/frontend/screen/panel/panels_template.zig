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

    pub fn content(self: *Template) ![]const u8 {
        var line: []u8 = undefined;
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        var names: [][]const u8 = self.panel_names[0..self.panel_names_index];

        try lines.appendSlice(line1a);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, "const _{0s}_ = @import(\"{0s}_panel.zig\");\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line1b);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, "    {0s},\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line2);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, "    {0s}: ?*_{0s}_.Panel,\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line3);
        for (names) |name| {
            {
                line = try fmt.allocPrint(self.allocator, "        if (self.{0s}) |{0s}| {{\n", .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
            {
                line = try fmt.allocPrint(self.allocator, "            {0s}.deinit();\n", .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
            try lines.appendSlice("        }\n");
        }

        try lines.appendSlice(line4);
        for (names) |name| {
            {
                line = try fmt.allocPrint(self.allocator, "            .{0s} => self.{0s}.?.frame(allocator),\n", .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        if (names.len > 0) {
            line = try fmt.allocPrint(self.allocator, "            .none => self.{0s}.?.frame(allocator),\n", .{names[0]});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line5);
        for (names) |name| {
            try lines.appendSlice("\n");
            {
                line = try fmt.allocPrint(self.allocator, "    pub fn setCurrentTo{s}(self: *Panels) void {{\n", .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
            {
                line = try fmt.allocPrint(self.allocator, "        self.current_panel_tag = PanelTags.{s};\n", .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
            try lines.appendSlice("    }\n");
        }

        try lines.appendSlice(line6);
        if (names.len > 0) {
            for (names) |name| {
                try lines.appendSlice("\n");
                {
                    line = try fmt.allocPrint(self.allocator, "    panels.{0s} = try _{0s}_.init(allocator, all_screens, panels, messenger);\n", .{name});
                    defer self.allocator.free(line);
                    try lines.appendSlice(line);
                }
                try lines.appendSlice("    errdefer {\n");
                try lines.appendSlice("        panels.deinit();\n");
                try lines.appendSlice("    }\n");
            }
        } else {
            try lines.appendSlice("    _ = all_screens;\n");
            try lines.appendSlice("    _ = messenger;\n");
        }

        try lines.appendSlice(line7);
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

const line1a =
    \\const std = @import("std");
    \\const _framers_ = @import("framers");
    \\const _messenger_ = @import("messenger.zig");
    \\
;
// \\const _Home_ = @import("home_panel.zig");
// \\const _Other_ = @import("other_panel.zig");

const line1b =
    \\
    \\const PanelTags = enum {
    \\
;
// \\    home,
// \\    other,
// \\    none,

const line2 =
    \\    none,
    \\};
    \\
    \\pub const Panels = struct {
    \\    allocator: std.mem.Allocator,
    \\
;
// \\    home: ?*home_panel.Panel,
// \\    other: ?*other_panel.Panel,

const line3 =
    \\    current_panel_tag: PanelTags,
    \\
    \\    pub fn deinit(self: *Panels) void {
    \\
;
// \\        if (self.home) |home| {
// \\            home.deinit();
// \\        }
// \\        if (self.other) |other| {
// \\            other.deinit();
// \\        }

const line4 =
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    pub fn frameCurrent(self: *Panels, allocator: std.mem.Allocator) !void {
    \\        var result = switch (self.current_panel_tag) {
    \\
;
// \\            .home => self.home.?.frame(allocator),
// \\            .other => self.other.?.frame(allocator),

const line5 =
    \\        };
    \\        return result;
    \\    }
    \\
;
// \\    pub fn setCurrentToHome(self: *Panels) void {
// \\        self.current_panel_tag = PanelTags.home;
// \\    }
// \\
// \\    pub fn setCurrentToOther(self: *Panels) void {
// \\        self.current_panel_tag = PanelTags.other;
// \\    }

const line6 =
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, messenger: *_messenger_.Messenger) !*Panels {
    \\    var panels: *Panels = try allocator.create(Panels);
    \\    panels.allocator = allocator;
    \\
;
// \\
// \\    panels.home = try home_panel.init(allocator, all_screens, panels, messenger);
// \\    errdefer {
// \\        panels.deinit();
// \\    }
// \\    panels.other = try other_panel.init(allocator, all_screens, panels, messenger);
// \\    errdefer {
// \\        panels.deinit();
// \\    }

const line7 =
    \\
    \\    return panels;
    \\}
    \\
;
