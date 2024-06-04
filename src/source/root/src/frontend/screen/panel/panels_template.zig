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
        const names: [][]const u8 = self.panel_names[0..self.panel_names_index];

        try lines.appendSlice(line_import_start);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_import_panel, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_panel_tags_start);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_panel_tag, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_panel_tags_end_panels_struct_start);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_panels_struct_panel_member, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line_panels_struct_end_deinit_start);
        for (names) |name| {
            {
                line = try fmt.allocPrint(self.allocator, line_panel_deinit, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }

        try lines.appendSlice(line_deinit_end_framecurrent_start);
        for (names) |name| {
            {
                line = try fmt.allocPrint(self.allocator, line_frame_panel, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        {
            line = try fmt.allocPrint(self.allocator, line_frame_default_panel, .{names[0]});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_framecurrent_end_refresh_start);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_panel_refresh, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        {
            line = try fmt.allocPrint(self.allocator, line_refresh_end, .{names[0]});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_panel_set_current, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_set_container_start);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_set_panel_container, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line_set_container_end);

        try lines.appendSlice(line_init_start);
        for (names) |name| {
            {
                line = try fmt.allocPrint(self.allocator, line_panel_init, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }

        try lines.appendSlice(line_panel_init_end);
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

const line_import_start =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const _framers_ = @import("framers");
    \\const _messenger_ = @import("messenger.zig");
    \\const _various_ = @import("various");
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\
;
const line_import_panel =
    \\const _{0s}_ = @import("{0s}_panel.zig");
    \\
;

const line_panel_tags_start =
    \\
    \\const PanelTags = enum {
    \\
;
const line_panel_tag =
    \\    {s0},
    \\
;

const line_panel_tags_end_panels_struct_start =
    \\    none,
    \\};
    \\
    \\pub const Panels = struct {
    \\    allocator: std.mem.Allocator,
    \\
;
const line_panels_struct_panel_member =
    \\    {0s}: ?*_{0s}_.Panel,
    \\
;
const line_panels_struct_end_deinit_start =
    \\    current_panel_tag: PanelTags,
    \\
    \\    pub fn deinit(self: *Panels) void {
    \\
;
const line_panel_deinit =
    \\        if (self.{0s}) |{0s}| {{
    \\            {0s}.deinit();
    \\        }}
    \\
;
const line_deinit_end_framecurrent_start =
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    pub fn frameCurrent(self: *Panels, allocator: std.mem.Allocator) !void {
    \\        return switch (self.current_panel_tag) {
    \\
;
const line_frame_panel =
    \\            .{0s} => self.{0s}.?.frame(allocator),
    \\
;
const line_frame_default_panel =
    \\            .none => self.{0s}.?.frame(allocator),
    \\
;
const line_framecurrent_end_refresh_start =
    \\        };
    \\    }
    \\
    \\    pub fn refresh(self: *Panels) void {
    \\        switch (self.current_panel_tag) {
    \\
;
const line_panel_refresh =
    \\            .{0s} => self.{0s}.?.refresh(),
    \\
;
const line_refresh_end =
    \\            .none => self.{0s}.?.refresh(),
    \\        }}
    \\    }}
    \\
;

const line_panel_set_current =
    \\
    \\    pub fn setCurrentTo{0s}(self: *Panels) void {{
    \\        self.current_panel_tag = PanelTags.{0s};
    \\    }}
    \\
;
const line_set_container_start =
    \\
    \\    pub fn setContainer(self: *Panels, container: *_various_.Container) void {
    \\
;
const line_set_panel_container =
    \\        self.{0s}.?.setContainer(container);
    \\
;
const line_set_container_end =
    \\    }
    \\};
    \\
;
const line_init_start =
    \\
    \\pub fn init(allocator: std.mem.Allocator, main_view: *MainView, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panels {
    \\    var panels: *Panels = try allocator.create(Panels);
    \\    panels.allocator = allocator;
    \\
;
const line_panel_init =
    \\    panels.{0s} = try _{0s}_.init(allocator, main_view, panels, messenger, exit, window);
    \\    errdefer panels.deinit();
    \\
;
const line_panel_init_end =
    \\
    \\    return panels;
    \\}
    \\
;
