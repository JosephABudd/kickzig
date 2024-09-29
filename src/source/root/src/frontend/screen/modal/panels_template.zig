const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    panel_names: [][]const u8,
    panel_names_index: usize,
    using_messenger: bool,

    pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, using_messenger: bool) !*Template {
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
        data.using_messenger = using_messenger;
        return data;
    }

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

    pub fn content(self: *Template) ![]const u8 {
        var line: []u8 = undefined;
        var lines: std.ArrayList(u8) = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        const panel_names: [][]const u8 = self.panel_names[0..self.panel_names_index];
        const default_panel_name: []const u8 = panel_names[0];

        try lines.appendSlice(line_start);

        if (self.using_messenger) {
            try lines.appendSlice(line_messenger_import);
        }

        for (panel_names) |panel_name| {
            line = try fmt.allocPrint(self.allocator, line_panel_imports_f, .{panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        {
            line = try fmt.allocPrint(self.allocator, line_imports_panel_tags_f, .{self.screen_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        for (panel_names) |panel_name| {
            line = try fmt.allocPrint(self.allocator, line_panel_tag_f, .{panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_none_tag_panels_struct);

        for (panel_names) |panel_name| {
            line = try fmt.allocPrint(self.allocator, line2_panel_struct_member_f, .{panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_deinit);

        for (panel_names) |panel_name| {
            line = try fmt.allocPrint(self.allocator, line3_panel_deinit_f, .{panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_end_deinit_start_frameCurrent);

        for (panel_names) |panel_name| {
            line = try fmt.allocPrint(self.allocator, line_frame_panel_f, .{panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        {
            line = try fmt.allocPrint(self.allocator, line_frame_end_borderColorCurrent_start_f, .{default_panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        for (panel_names) |panel_name| {
            line = try fmt.allocPrint(self.allocator, line_border_color_panel_f, .{panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        {
            line = try fmt.allocPrint(self.allocator, line_border_color_end_f, .{default_panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        for (panel_names) |panel_name| {
            line = try fmt.allocPrint(self.allocator, line_set_current_to_f, .{panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_preset_modal_start);

        for (panel_names) |panel_name| {
            line = try fmt.allocPrint(self.allocator, line_panel_preset_modal_f, .{panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        if (self.using_messenger) {
            try lines.appendSlice(line_preset_modal_end_init_start_with_messenger);
            for (panel_names) |panel_name| {
                line = try fmt.allocPrint(self.allocator, line_panel_init_with_messenger_f, .{panel_name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        } else {
            try lines.appendSlice(line_preset_modal_end_init_start_without_messenger);
            for (panel_names) |panel_name| {
                line = try fmt.allocPrint(self.allocator, line_panel_init_without_messenger_f, .{panel_name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }

        try lines.appendSlice(line_last);

        return try lines.toOwnedSlice();
    }
};

const line_start: []const u8 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\
;

const line_messenger_import: []const u8 =
    \\const Messenger = @import("view/messenger.zig").Messenger;
    \\
;

// panel name {0s}
const line_panel_imports_f: []const u8 =
    \\const {0s}Panel = @import("{0s}.zig").Panel;
    \\
;

// screen name {0s}
const line_imports_panel_tags_f: []const u8 =
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\const ModalParams = @import("modal_params").{0s};
    \\
    \\const PanelTags = enum {{
    \\
;

// panel name {0s}
const line_panel_tag_f: []const u8 =
    \\    {0s},
    \\
;

const line_none_tag_panels_struct: []const u8 =
    \\    none,
    \\};
    \\
    \\pub const Panels = struct {
    \\    allocator: std.mem.Allocator,
    \\    current_panel_tag: PanelTags,
    \\
;

// panel name {0s}
const line2_panel_struct_member_f: []const u8 =
    \\    {0s}: ?*{0s}Panel,
    \\
;

const line_deinit: []const u8 =
    \\
    \\    pub fn deinit(self: *Panels) void {
    \\
;

// panel name {0s}
const line3_panel_deinit_f: []const u8 =
    \\        if (self.{0s}) |member| {{
    \\            member.deinit();
    \\        }}
    \\
;

const line_end_deinit_start_frameCurrent: []const u8 =
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    pub fn frameCurrent(self: *Panels, allocator: std.mem.Allocator) !void {
    \\        return switch (self.current_panel_tag) {
    \\
;

// panel name {0s}
const line_frame_panel_f: []const u8 =
    \\            .{0s} => self.{0s}.?.frame(allocator),
    \\
;

// default panel name {0s}
const line_frame_end_borderColorCurrent_start_f: []const u8 =
    \\            .none => self.{0s}.?.frame(allocator),
    \\        }};
    \\    }}
    \\
    \\    pub fn borderColorCurrent(self: *Panels) dvui.Options.ColorOrName {{
    \\        return switch (self.current_panel_tag) {{
    \\
;

// panel name {0s}
const line_border_color_panel_f: []const u8 =
    \\            .{0s} => self.{0s}.?.view.?.border_color,
    \\
;

// default panel name {0s}
const line_border_color_end_f: []const u8 =
    \\            .none => self.{0s}.?.view.?.border_color,
    \\        }};
    \\    }}
    \\
;

// panel name {0s}
const line_set_current_to_f: []const u8 =
    \\
    \\    pub fn setCurrentTo{0s}(self: *Panels) void {{
    \\        self.current_panel_tag = PanelTags.{0s};
    \\    }}
    \\
;

// const line_preset_modal_init =
const line_preset_modal_start: []const u8 =
    \\
    \\    pub fn presetModal(self: *Panels, modal_params: *ModalParams) !void {
    \\
;

// panel name {0s}
const line_panel_preset_modal_f: []const u8 =
    \\        try self.{0s}.?.presetModal(modal_params);
    \\
;

const line_preset_modal_end_init_start_with_messenger: []const u8 =
    \\    }
    \\
    \\    pub fn init(allocator: std.mem.Allocator, main_view: *MainView, messenger: *Messenger, exit: ExitFn, window: *dvui.Window, theme: *dvui.Theme) !*Panels {
    \\        var panels: *Panels = try allocator.create(Panels);
    \\        panels.allocator = allocator;
    \\
;

const line_preset_modal_end_init_start_without_messenger: []const u8 =
    \\    }
    \\
    \\    pub fn init(allocator: std.mem.Allocator, main_view: *MainView, exit: ExitFn, window: *dvui.Window, theme: *dvui.Theme) !*Panels {
    \\        var panels: *Panels = try allocator.create(Panels);
    \\        panels.allocator = allocator;
    \\
;

// panel name {0s}
const line_panel_init_with_messenger_f: []const u8 =
    \\
    \\        panels.{0s} = try {0s}Panel.init(allocator, main_view, panels, messenger, exit, window, theme);
    \\        errdefer panels.deinit();
    \\
;

// panel name {0s}
const line_panel_init_without_messenger_f: []const u8 =
    \\
    \\        panels.{0s} = try {0s}Panel.init(allocator, main_view, panels, exit, window, theme);
    \\        errdefer panels.deinit();
    \\
;

const line_last: []const u8 =
    \\
    \\        return panels;
    \\    }
    \\};
    \\
;
