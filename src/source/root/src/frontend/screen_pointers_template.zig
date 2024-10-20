const std = @import("std");
const fmt = std.fmt;
const strings = @import("strings");

pub const Template = struct {
    allocator: std.mem.Allocator,

    _htab_screen_names: [][]const u8,
    _tab_screen_names: [][]const u8,
    _panel_screen_names: [][]const u8,
    _modal_screen_names: [][]const u8,

    _tab_screen_names_index: usize,
    _panel_screen_names_index: usize,
    _modal_screen_names_index: usize,

    _app_name: []const u8,

    pub fn deinit(self: *Template) void {
        for (self._tab_screen_names, 0..) |name, i| {
            if (i == self._tab_screen_names_index) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self._tab_screen_names);

        for (self._panel_screen_names, 0..) |name, i| {
            if (i == self._panel_screen_names_index) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self._panel_screen_names);

        for (self._modal_screen_names, 0..) |name, i| {
            if (i == self._modal_screen_names_index) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self._modal_screen_names);

        self.allocator.free(self._app_name);
        self.allocator.destroy(self);
    }

    pub fn addTabScreenName(self: *Template, new_screen_name: []const u8) !void {
        if (self._tab_screen_names_index == self._tab_screen_names.len) {
            // Full list so create a new bigger one.
            var new_screen_names: [][]const u8 = try self.allocator.alloc([]const u8, (self._tab_screen_names.len + 5));
            for (self._tab_screen_names, 0..) |tab_screen_name, i| {
                new_screen_names[i] = tab_screen_name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self._tab_screen_names);
            self._tab_screen_names = new_screen_names;
        }
        self._tab_screen_names[self._tab_screen_names_index] = try self.allocator.alloc(u8, new_screen_name.len);
        @memcpy(@constCast(self._tab_screen_names[self._tab_screen_names_index]), new_screen_name);
        self._tab_screen_names_index += 1;
    }

    pub fn addPanelScreenName(self: *Template, new_screen_name: []const u8) !void {
        if (self._panel_screen_names_index == self._panel_screen_names.len) {
            // Full list so create a new bigger one.
            var new_screen_names: [][]const u8 = try self.allocator.alloc([]const u8, (self._panel_screen_names.len + 5));
            for (self._panel_screen_names, 0..) |panel_screen_name, i| {
                new_screen_names[i] = panel_screen_name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self._panel_screen_names);
            self._panel_screen_names = new_screen_names;
        }
        self._panel_screen_names[self._panel_screen_names_index] = try self.allocator.alloc(u8, new_screen_name.len);
        @memcpy(@constCast(self._panel_screen_names[self._panel_screen_names_index]), new_screen_name);
        self._panel_screen_names_index += 1;
    }

    pub fn addModalScreenName(self: *Template, new_screen_name: []const u8) !void {
        if (self._modal_screen_names_index == self._modal_screen_names.len) {
            // Full list so create a new bigger one.
            var new_screen_names: [][]const u8 = try self.allocator.alloc([]const u8, (self._modal_screen_names.len + 5));
            for (self._modal_screen_names, 0..) |modal_screen_name, i| {
                new_screen_names[i] = modal_screen_name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self._modal_screen_names);
            self._modal_screen_names = new_screen_names;
        }
        self._modal_screen_names[self._modal_screen_names_index] = try self.allocator.alloc(u8, new_screen_name.len);
        @memcpy(@constCast(self._modal_screen_names[self._modal_screen_names_index]), new_screen_name);
        self._modal_screen_names_index += 1;
    }

    pub fn content(self: *Template) ![]const u8 {
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        var line: []u8 = undefined;

        // Start. Imports etc.
        try lines.appendSlice(line1);

        // tab screens.
        const tab_screen_names: [][]const u8 = self._tab_screen_names[0..self._tab_screen_names_index];
        for (tab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line1_import_tab, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // panel screens.
        const panel_screen_names: [][]const u8 = self._panel_screen_names[0..self._panel_screen_names_index];
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line1_import_panel, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // modal screens.
        const modal_screen_names: [][]const u8 = self._modal_screen_names[0..self._modal_screen_names_index];
        for (modal_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line1_import_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line2);

        // tab screens.
        for (tab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_member, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // panel screens.
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_member, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // modal screens.
        for (modal_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_member, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line3);

        // tab screens.
        for (tab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line3_deinit, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // panel screens.
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line3_deinit, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // modal screens.
        for (modal_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line3_deinit, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line4_deinit_end_init_start);
        // tab screens.
        for (tab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line4_null_member, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // panel screens.
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line4_null_member, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // modal screens.
        for (modal_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line4_null_member, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line4_deinit_end_init_screens_start);

        // tab screens.
        for (tab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line4_init_tab, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // panel screens.
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line4_init_not_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line4_init_switch_end_modals_start);
        // modal screens.
        for (modal_screen_names) |name| {
            if (std.mem.eql(u8, name, "OK")) {
                try lines.appendSlice(line4_init_ok_modal);
            } else {
                line = try fmt.allocPrint(self.allocator, line4_init_modal, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }

        try lines.appendSlice(line5);

        const temp: []const u8 = try lines.toOwnedSlice();
        line = try self.allocator.alloc(u8, temp.len);
        @memcpy(line, temp);
        return line;
    }
};

pub fn init(allocator: std.mem.Allocator, app_name: []const u8) !*Template {
    var self: *Template = try allocator.create(Template);
    self._app_name = try allocator.alloc(u8, app_name.len);
    errdefer {
        allocator.destroy(self);
    }
    @memcpy(@constCast(self._app_name), app_name);
    self.allocator = allocator;
    self._tab_screen_names = try allocator.alloc([]const u8, 5);
    self._panel_screen_names = try allocator.alloc([]const u8, 5);
    self._modal_screen_names = try allocator.alloc([]const u8, 5);
    self._tab_screen_names_index = 0;
    self._panel_screen_names_index = 0;
    self._modal_screen_names_index = 0;
    return self;
}

const line1: []const u8 =
    \\const std = @import("std");
    \\
    \\const _main_menu_ = @import("main_menu");
    \\const _startup_ = @import("startup");
    \\
    \\const Container = @import("cont").Container;
    \\const Content = @import("cont").Content;
    \\const ScreenTags = @import("framers").ScreenTags;
    \\
    \\
;

const line1_import_tab: []const u8 =
    \\pub const {0s} = @import("screen/tab/{0s}/screen.zig").Screen;
    \\
;

const line1_import_panel: []const u8 =
    \\pub const {0s} = @import("screen/panel/{0s}/screen.zig").Screen;
    \\
;

const line1_import_modal: []const u8 =
    \\pub const {0s} = @import("screen/modal/{0s}/screen.zig").Screen;
    \\
;

const line2: []const u8 =
    \\
    \\pub const ScreenPointers = struct {
    \\    allocator: std.mem.Allocator,
    \\
;

const line2_member: []const u8 =
    \\    {0s}: ?*{0s},
    \\
;

const line3: []const u8 =
    \\
    \\    pub fn deinit(self: *ScreenPointers) void {
    \\
;

const line3_deinit: []const u8 =
    \\        if (self.{0s}) |screen| {{
    \\            screen.deinit();
    \\        }}
    \\
;

const line4_deinit_end_init_start: []const u8 =
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    pub fn init(startup: _startup_.Frontend) !*ScreenPointers {
    \\        const self: *ScreenPointers = try startup.allocator.create(ScreenPointers);
    \\        self.allocator = startup.allocator;
    \\
;

const line4_null_member: []const u8 =
    \\        self.{0s} = null;
    \\
;

const line4_deinit_end_init_screens_start: []const u8 =
    \\        return self;
    \\    }
    \\
    \\    pub fn init_screens(self: *ScreenPointers, startup: _startup_.Frontend) !void {
    \\        const screen_tags: []ScreenTags = try _main_menu_.screenTagsForInitialization(self.allocator);
    \\        defer self.allocator.free(screen_tags);
    \\        for (screen_tags) |tag| {
    \\            switch (tag) {
    \\
    \\
;
const line4_init_tab: []const u8 =
    \\
    \\                .{0s} => {{
    \\                    // KICKZIG TODO: You can customize the init_options. See deps/widgets/tabbar/api.zig.
    \\                    const main_view_as_container: *Container = try startup.main_view.as{0s}Container();
    \\                    self.{0s} = try {0s}.init(
    \\                        startup,
    \\                        main_view_as_container,
    \\                        .{{
    \\                            // Tabs.Options.
    \\                            // KICKZIG TODO:
    \\                            // Use custom settings for the {0s} tab.
    \\
    \\                            //.direction = .horizontal,
    \\                            //.toggle_direction = true,
    \\                            //.tabs_movable = true,
    \\                            //.tabs_closable = true,
    \\                            //.toggle_vertical_bar_visibility = true,
    \\                            //.show_tab_close_icon = true,
    \\                            //.show_tab_move_icons = true,
    \\                            //.show_tab_context_menu = true,
    \\                        }},
    \\                        .{{
    \\                            // {0s} screen Options.
    \\                            // KICKZIG TODO:
    \\                            // Use custom settings for the {0s} screen.
    \\                            // See screen/tab/{0s}.zig Options.
    \\                        }},
    \\                    );
    \\                    errdefer main_view_as_container.deinit();
    \\                }},
    \\
;
const line4_init_not_modal: []const u8 =
    \\
    \\                .{0s} => {{
    \\                    const main_view_as_container: *Container = try startup.main_view.as{0s}Container();
    \\                    self.{0s} = try {0s}.init(
    \\                        startup,
    \\                        main_view_as_container,
    \\                        .{{
    \\                            // {0s} screen Options.
    \\                            // KICKZIG TODO:
    \\                            // Use custom settings for the {0s} screen.
    \\                            // See screen/tab/{0s}.zig Options.
    \\                        }},
    \\                    );
    \\                    errdefer main_view_as_container.deinit();
    \\                }},
    \\
;

const line4_init_switch_end_modals_start: []const u8 =
    \\                else => {
    \\                    // No modals here. They are below.
    \\                },
    \\            }
    \\        }
    \\
    \\        // Set up each modal screen.
    \\
    \\
;

const line4_init_ok_modal: []const u8 =
    \\        // The OK screen is a modal screen.
    \\        // Modal screens frame inside the main view.
    \\        // It is the only modal screen that can be used in the main menu.
    \\        self.OK = try OK.init(startup);
    \\        errdefer self.deinit();
    \\
;

const line4_init_modal: []const u8 =
    \\        // The {0s} screen is a modal screen.
    \\        // Modal screens frame inside the main view.
    \\        // The {0s} modal screen can not be used in the main menu.
    \\        self.{0s} = try {0s}.init(startup);
    \\        errdefer self.deinit();
    \\
;

const line5: []const u8 =
    \\    }
    \\};
    \\
;
