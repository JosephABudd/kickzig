const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    panel_names: [][]const u8,
    panel_names_index: usize,
    use_messenger: bool,

    pub fn init(allocator: std.mem.Allocator, use_messenger: bool) !*Template {
        var self: *Template = try allocator.create(Template);
        self.panel_names = try allocator.alloc([]const u8, 5);
        errdefer {
            allocator.destroy(self);
        }
        errdefer {
            allocator.free(self.panel_names);
            allocator.destroy(self);
        }
        self.panel_names_index = 0;
        self.allocator = allocator;
        self.use_messenger = use_messenger;
        return self;
    }

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
        var lines: std.ArrayList(u8) = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        var line: []const u8 = undefined;
        const names: [][]const u8 = self.panel_names[0..self.panel_names_index];

        // line_start_?
        try lines.appendSlice(line_start_1);

        if (self.use_messenger) {
            try lines.appendSlice(line_start_1_messenger);
        }

        try lines.appendSlice(line_start_2);

        // panel imports.
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_import_panel_f, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_panel_tags_start);

        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_panel_tag_f, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_panel_tags_end_panels_struct_start);

        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_panels_struct_panel_member_f, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_panels_struct_end_deinit_start);

        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_panel_deinit_f, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_deinit_end_framecurrent_start);

        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_frame_panel_f, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        {
            line = try fmt.allocPrint(self.allocator, line_frame_default_panel_f, .{names[0]});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_framecurrent_end_refresh_start);

        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_panel_refresh_f, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        {
            line = try fmt.allocPrint(self.allocator, line_refresh_end_f, .{names[0]});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_panel_set_current_f, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_set_container_start);

        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_set_panel_container_f, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line_set_container_end);

        try lines.appendSlice(line_init_start_1);

        if (self.use_messenger) {
            try lines.appendSlice(line_init_start_1_messenger);
        }
        try lines.appendSlice(line_init_start_2);

        for (names) |name| {
            {
                line = try fmt.allocPrint(self.allocator, line_panel_init_start_f, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
            if (self.use_messenger) {
                try lines.appendSlice(line_panel_init_messenger);
            }
            try lines.appendSlice(line_panel_init_end);
        }

        try lines.appendSlice(line_init_end);

        return try lines.toOwnedSlice();
    }
};

const line_start_1: []const u8 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const Container = @import("various").Container;
    \\const ExitFn = @import("various").ExitFn;
    \\
;

const line_start_1_messenger: []const u8 =
    \\const Messenger = @import("view/messenger.zig").Messenger;
    \\
;

const line_start_2: []const u8 =
    \\const MainView = @import("framers").MainView;
    \\const ScreenOptions = @import("screen.zig").Options;
    \\
    \\
;

/// {0s} panel_name
const line_import_panel_f: []const u8 =
    \\const {0s}Panel = @import("{0s}.zig").Panel;
    \\
;

const line_panel_tags_start: []const u8 =
    \\
    \\const PanelTags = enum {
    \\
;

/// {0s} panel_name
const line_panel_tag_f: []const u8 =
    \\    {s0},
    \\
;

const line_panel_tags_end_panels_struct_start: []const u8 =
    \\    none,
    \\};
    \\
    \\pub const Panels = struct {
    \\    allocator: std.mem.Allocator,
    \\
;

/// {0s} panel_name
const line_panels_struct_panel_member_f: []const u8 =
    \\    {0s}: ?*{0s}Panel,
    \\
;
const line_panels_struct_end_deinit_start: []const u8 =
    \\    current_panel_tag: PanelTags,
    \\
    \\    pub fn deinit(self: *Panels) void {
    \\
;
/// {0s} panel_name
const line_panel_deinit_f: []const u8 =
    \\        if (self.{0s}) |member| {{
    \\            member.deinit();
    \\        }}
    \\
;
const line_deinit_end_framecurrent_start: []const u8 =
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    pub fn frameCurrent(self: *Panels, allocator: std.mem.Allocator) !void {
    \\        return switch (self.current_panel_tag) {
    \\
;
/// {0s} panel_name
const line_frame_panel_f: []const u8 =
    \\            .{0s} => self.{0s}.?.view.?.frame(allocator),
    \\
;
/// {0s} panel_name
const line_frame_default_panel_f: []const u8 =
    \\            .none => self.{0s}.?.view.?.frame(allocator),
    \\
;
const line_framecurrent_end_refresh_start: []const u8 =
    \\        };
    \\    }
    \\
    \\    pub fn refresh(self: *Panels) void {
    \\        switch (self.current_panel_tag) {
    \\
;
/// {0s} panel_name
const line_panel_refresh_f: []const u8 =
    \\            .{0s} => self.{0s}.?.view.?.refresh(),
    \\
;
/// {0s} panel_name
const line_refresh_end_f: []const u8 =
    \\            .none => self.{0s}.?.view.?.refresh(),
    \\        }}
    \\    }}
    \\
;

/// {0s} panel_name
const line_panel_set_current_f: []const u8 =
    \\
    \\    pub fn setCurrentTo{0s}(self: *Panels) void {{
    \\        self.current_panel_tag = PanelTags.{0s};
    \\    }}
    \\
;

const line_set_container_start: []const u8 =
    \\
    \\    pub fn setContainer(self: *Panels, container: *Container) !void {
    \\
;
/// {0s} panel_name
const line_set_panel_container_f: []const u8 =
    \\        try self.{0s}.?.view.?.setContainer(container);
    \\
;
const line_set_container_end: []const u8 =
    \\    }
    \\
;

const line_init_start_1: []const u8 =
    \\
    \\    pub fn init(
    \\        allocator: std.mem.Allocator,
    \\        main_view: *MainView,
    \\
;

const line_init_start_1_messenger: []const u8 =
    \\        messenger: *Messenger,
    \\
;

const line_init_start_2: []const u8 =
    \\        exit: ExitFn,
    \\        window: *dvui.Window,
    \\        container: ?*Container,
    \\        screen_options: ScreenOptions,
    \\    ) !*Panels {
    \\        var panels: *Panels = try allocator.create(Panels);
    \\        panels.allocator = allocator;
    \\
;
/// {0s} panel_name
const line_panel_init_start_f: []const u8 =
    \\
    \\        panels.{0s} = try {0s}Panel.init(
    \\            allocator,
    \\            window,
    \\            main_view,
    \\            panels,
    \\
;
const line_panel_init_messenger: []const u8 =
    \\            messenger,
    \\
;
const line_panel_init_end: []const u8 =
    \\            exit,
    \\            container,
    \\            screen_options,
    \\        );
    \\        errdefer panels.deinit();
    \\
;

const line_init_end: []const u8 =
    \\
    \\        return panels;
    \\    }
    \\};
    \\
;
