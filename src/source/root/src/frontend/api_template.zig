const std = @import("std");
const fmt = std.fmt;
const strings = @import("strings");

pub const Template = struct {
    allocator: std.mem.Allocator,

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

        // Start. Imports etc.
        try lines.appendSlice(line1);
        var line: []u8 = undefined;

        // tab screens.
        const tab_screen_names: [][]const u8 = self._tab_screen_names[0..self._tab_screen_names_index];
        for (tab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line1_not_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // panel screens.
        const panel_screen_names: [][]const u8 = self._panel_screen_names[0..self._panel_screen_names_index];
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line1_not_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // modal screens.
        const modal_screen_names: [][]const u8 = self._modal_screen_names[0..self._modal_screen_names_index];
        for (modal_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line1_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line2a);
        // All non modal screens: tab screens.
        // Will frame is a tab screen option.
        for (tab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_not_modal_will_frame, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // All non modal screens: panel screens.
        // Will frame is a panel screen option.
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_not_modal_will_frame, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line2b);
        // tab screens.
        for (tab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_label, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // panel screens.
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_label, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // modal screens.
        for (modal_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_label, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line3);

        // tab screens.
        for (tab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line3_not_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // panel screens.
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line3_not_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line4);

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
    \\const dvui = @import("dvui");
    \\
    \\const _main_menu_ = @import("main_menu");
    \\const _modal_params_ = @import("modal_params");
    \\const _startup_ = @import("startup");
    \\
    \\const MainView = @import("framers").MainView;
    \\const ScreenPointers = @import("screen_pointers").ScreenPointers;
    \\
    \\var allocator: std.mem.Allocator = undefined;
    \\var main_view: *MainView = undefined; // standalone-sdl will deinit.
    \\var screen_pointers: *ScreenPointers = undefined;
    \\
    \\pub fn init(startup: *_startup_.Frontend) !void {
    \\    // Set up each all screens.
    \\    allocator = startup.allocator;
    \\    main_view = startup.main_view;
    \\    screen_pointers = try ScreenPointers.init(startup.*);
    \\    startup.screen_pointers = screen_pointers;
    \\    try screen_pointers.init_screens(startup.*);
    \\    errdefer screen_pointers.deinit();
    \\
    \\    // Initialze the example demo window.
    \\    // KICKZIG TODO:
    \\    // When you no longer want to display the example demo window
    \\    //  you can comment the following line out.
    \\    dvui.Examples.show_demo_window = false;
    \\
    \\    // Set the default screen.
    \\    try main_view.show(_main_menu_.startup_screen_tag);
    \\}
    \\
    \\pub fn deinit() void {
    \\    screen_pointers.deinit();
    \\}
    \\
    \\pub fn frame(arena: std.mem.Allocator) !void {
    \\    if (main_view.currentTag()) |current_tag| {
    \\        switch (current_tag) {
    \\
;

const line1_not_modal: []const u8 =
    \\            .{0s} => {{
    \\                if (screen_pointers.{0s}.?.willFrame()) {{
    \\                    // The tab screen will frame.
    \\                    try frame_main_menu(arena);
    \\                    try screen_pointers.{0s}.?.frame(arena);
    \\                }} else {{
    \\                    // This tab screen will not frame.
    \\                    // Switch back to the startup screen.
    \\                    if (_main_menu_.startup_screen_tag != .{0s}) {{
    \\                        try main_view.show(_main_menu_.startup_screen_tag);
    \\                        try frame(arena);
    \\                    }}
    \\                }}
    \\            }},
    \\
;

const line1_modal: []const u8 =
    \\            .{0s} => {{
    \\                if (main_view.isNewModal()) {{
    \\                    const modal_args: *_modal_params_.{0s} = @alignCast(@ptrCast(main_view.modalArgs()));
    \\                    try screen_pointers.{0s}.?.setState(modal_args);
    \\                }}
    \\                try screen_pointers.{0s}.?.frame(arena);
    \\            }},
    \\
;

const line2a: []const u8 =
    \\        }
    \\    }
    \\}
    \\
    \\pub fn frame_main_menu(arena: std.mem.Allocator) !void {
    \\    if (!_main_menu_.show_main_menu) {
    \\        // Not showing the main menu in this app.
    \\        return;
    \\    }
    \\    var m = try dvui.menu(@src(), .horizontal, .{ .background = true, .expand = .horizontal });
    \\    defer m.deinit();
    \\
    \\    if (try dvui.menuItemIcon(@src(), "menu", dvui.entypo.menu, .{ .submenu = true }, .{ .expand = .none })) |r| {
    \\        var fw = try dvui.floatingMenu(@src(), dvui.Rect.fromPoint(dvui.Point{ .x = r.x, .y = r.y + r.h }), .{});
    \\        defer fw.deinit();
    \\
    \\        for (_main_menu_.sorted_main_menu_screen_tags, 0..) |screen_tag, id_extra| {
    \\            const will_frame: bool = switch (screen_tag) {
    \\
;
const line2_not_modal_will_frame: []const u8 =
    \\                .{0s} => blk: {{
    \\                    if (screen_pointers.{0s}) |screen| {{
    \\                        break :blk screen.willFrame();
    \\                    }} else {{
    \\                        break :blk false;
    \\                    }}
    \\                }},
;
const line2b: []const u8 =
    \\                else => false,
    \\            };
    \\            if (!will_frame) {
    \\                continue;
    \\            }
    \\
    \\            const label: []const u8 = switch (screen_tag) {
    \\
;
const line2_label: []const u8 =
    \\                .{0s} => try screen_pointers.{0s}.?.mainMenuLabel(arena),
    \\
;

const line3: []const u8 =
    \\            };
    \\            defer arena.free(label);
    \\
    \\            if (try dvui.menuItemLabel(@src(), label, .{}, .{ .expand = .horizontal, .id_extra = id_extra }) != null) {
    \\                m.close();
    \\
    \\                return switch (screen_tag) {
    \\
;

const line3_not_modal: []const u8 =
    \\                    .{0s} => main_view.show(screen_tag),
    \\
;

const line4: []const u8 =
    \\                    else => blk: {
    \\                        const yesno_args = try _modal_params_.OK.init(
    \\                            arena,
    \\                            "That won't work.",
    \\                            "Can not open modals from the main menu.",
    \\                        );
    \\                        break :blk main_view.showOK(yesno_args);
    \\                    },
    \\                };
    \\            }
    \\        }
    \\
    \\        // KICKZIG TODO:
    \\        // When you no longer want to display the developer menu items.
    \\        //  set _main_menu_.show_developer_menu_items to false.
    \\        // Developer menu items.
    \\        if (_main_menu_.show_developer_menu_items) {
    \\            if (try dvui.menuItemLabel(@src(), "DVUI Debug", .{}, .{ .expand = .horizontal }) != null) {
    \\                dvui.toggleDebugWindow();
    \\            }
    \\            if (dvui.Examples.show_demo_window) {
    \\                if (try dvui.menuItemLabel(@src(), "Hide the DVUI Demo", .{}, .{ .expand = .horizontal }) != null) {
    \\                    dvui.Examples.show_demo_window = false;
    \\                }
    \\            } else {
    \\                if (try dvui.menuItemLabel(@src(), "Show the DVUI Demo", .{}, .{ .expand = .horizontal }) != null) {
    \\                    dvui.Examples.show_demo_window = true;
    \\                }
    \\            }
    \\        }
    \\
    \\        if (try dvui.menuItemIcon(@src(), "close", dvui.entypo.align_top, .{ .submenu = false }, .{ .gravity_x = 0.5, .expand = .horizontal }) != null) {
    \\            m.close();
    \\            return;
    \\        }
    \\    }
    \\
    \\    // look at demo() for examples of dvui widgets, shows in a floating window
    \\    // KICKZIG TODO:
    \\    // When you no longer want to display the example demo window
    \\    //  you can comment the following line out.
    \\    try dvui.Examples.demo();
    \\}
;
