const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    panel_names: [][]const u8,
    panel_names_index: usize,

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.screen_name);
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

    pub fn content(self: *Template, using_messenger: bool) ![]const u8 {
        var line: []u8 = undefined;
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        const names: [][]const u8 = self.panel_names[0..self.panel_names_index];
        var size: usize = 0;

        // line1a1-c
        {
            size = std.mem.replacementSize(u8, line1a1, "{{ screen_name }}", self.screen_name);
            const with_screen_name: []u8 = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_screen_name);
            _ = std.mem.replace(u8, line1a1, "{{ screen_name }}", self.screen_name, with_screen_name);
            try lines.appendSlice(with_screen_name);
        }
        if (using_messenger) {
            {
                size = std.mem.replacementSize(u8, line1a2, "{{ screen_name }}", self.screen_name);
                const with_screen_name: []u8 = try self.allocator.alloc(u8, size);
                defer self.allocator.free(with_screen_name);
                _ = std.mem.replace(u8, line1a2, "{{ screen_name }}", self.screen_name, with_screen_name);
                try lines.appendSlice(with_screen_name);
            }
        }
        {
            size = std.mem.replacementSize(u8, line1a3, "{{ screen_name }}", self.screen_name);
            const with_screen_name: []u8 = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_screen_name);
            _ = std.mem.replace(u8, line1a3, "{{ screen_name }}", self.screen_name, with_screen_name);
            try lines.appendSlice(with_screen_name);
        }
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
        try lines.appendSlice(line1c);

        // lines 2a-b
        try lines.appendSlice(line2a);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, "    {0s}: ?*_{0s}_.Panel,\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line2b);

        // lines 3a-b
        try lines.appendSlice(line3a);
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
        try lines.appendSlice(line3b);

        // lines 4a-b
        try lines.appendSlice(line4a);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, "            .{0s} => self.{0s}.?.frame(allocator),\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        if (names.len > 0) {
            line = try fmt.allocPrint(self.allocator, "            .none => self.{0s}.?.frame(allocator),\n", .{names[0]});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line4b);
        for (names) |name| {
            {
                try lines.appendSlice("\n");
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

        // line5a-b
        {
            size = std.mem.replacementSize(u8, line5a, "{{ screen_name }}", self.screen_name);
            const with_screen_name: []u8 = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_screen_name);
            _ = std.mem.replace(u8, line5a, "{{ screen_name }}", self.screen_name, with_screen_name);
            try lines.appendSlice(with_screen_name);
        }
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, "            try self.{0s}.presetModal(modal_params);\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line5b);

        if (using_messenger) {
            try lines.appendSlice(line6a);
        } else {
            try lines.appendSlice(line6b);
        }
        if (names.len > 0) {
            for (names) |name| {
                try lines.appendSlice("\n");
                {
                    if (using_messenger) {
                        line = try fmt.allocPrint(self.allocator, "    panels.{0s} = try _{0s}_.init(allocator, all_screens, panels, messenger, exit, window);\n", .{name});
                    } else {
                        line = try fmt.allocPrint(self.allocator, "    panels.{0s} = try _{0s}_.init(allocator, all_screens, panels, exit, window);\n", .{name});
                    }
                    defer self.allocator.free(line);
                    try lines.appendSlice(line);
                }
                try lines.appendSlice("    errdefer {\n");
                try lines.appendSlice("        panels.deinit();\n");
                try lines.appendSlice("    }\n");
            }
        } else {
            try lines.appendSlice("    _ = all_screens;\n");
            if (using_messenger) {
                try lines.appendSlice("    _ = messenger;\n");
            }
        }

        try lines.appendSlice(line7);
        const temp: []const u8 = try lines.toOwnedSlice();
        line = try self.allocator.alloc(u8, temp.len);
        @memcpy(line, temp);
        return line;
    }
};

pub fn init(allocator: std.mem.Allocator, screen_name: []const u8) !*Template {
    var data: *Template = try allocator.create(Template);
    data.panel_names = try allocator.alloc([]const u8, 5);
    errdefer {
        allocator.destroy(data);
    }
    errdefer {
        allocator.free(data.panel_names);
        allocator.destroy(data);
    }
    data.screen_name = try allocator.alloc(u8, screen_name.len);
    @memcpy(@constCast(data.screen_name), screen_name);
    errdefer {
        allocator.free(data.panel_names);
        allocator.destroy(data);
    }
    data.panel_names_index = 0;
    data.allocator = allocator;
    return data;
}

const line1a1 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const _framers_ = @import("framers");
    \\
;
const line1a2 =
    \\const _messenger_ = @import("messenger.zig");
    \\
;
const line1a3 =
    \\const {{ screen_name }}ModalParams = @import("modal_params").{{ screen_name }};
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

const line1c =
    \\    none,
    \\};
    \\
;

const line2a =
    \\
    \\pub const Panels = struct {
    \\    allocator: std.mem.Allocator,
    \\
;
// \\    home: ?*home_panel.Panel,
// \\    other: ?*other_panel.Panel,

const line2b =
    \\    current_panel_tag: PanelTags,
    \\
;

const line3a =
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

const line3b =
    \\        self.allocator.destroy(self);
    \\    }
    \\
;

const line4a =
    \\
    \\    pub fn frameCurrent(self: *Panels, allocator: std.mem.Allocator) !void {
    \\        const result = switch (self.current_panel_tag) {
    \\
;
// \\            .home => self.home.?.frame(allocator),
// \\            .other => self.other.?.frame(allocator),

const line4b =
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

const line5a =
    \\
    \\    pub fn presetModal(self: *Panels, modal_params: *{{ screen_name }}ModalParams) !void {
    \\
;
// \\            try self.home.presetModal(modal_params);
// \\            try self.other.presetModal(modal_params);

const line5b =
    \\    }
    \\
;

const line6a =
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, messenger: *_messenger_.Messenger, exit: *const fn (user_message: []const u8) void, window: *dvui.Window) !*Panels {
    \\    var panels: *Panels = try allocator.create(Panels);
    \\    panels.allocator = allocator;
    \\
;

const line6b =
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, exit: *const fn (user_message: []const u8) void, window: *dvui.Window) !*Panels {
    \\    var panels: *Panels = try allocator.create(Panels);
    \\    panels.allocator = allocator;
    \\
;
// \\
// \\    panels.home = try home_panel.init(allocator, all_screens, panels, messenger, exit);
// \\    errdefer {
// \\        panels.deinit();
// \\    }
// \\    panels.other = try other_panel.init(allocator, all_screens, panels, messenger, exit);
// \\    errdefer {
// \\        panels.deinit();
// \\    }

const line7 =
    \\
    \\    return panels;
    \\}
    \\
;
