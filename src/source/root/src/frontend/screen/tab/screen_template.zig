const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    tab_names: [][]const u8,
    tab_has_panel: []bool,
    tab_panel_count: u8 = 0,

    pub fn deinit(self: *Template) void {
        for (self.tab_names) |tab_name| {
            self.allocator.free(tab_name);
        }
        self.allocator.free(self.tab_names);
        self.allocator.free(self.tab_has_panel);
        self.allocator.free(self.screen_name);
        self.allocator.destroy(self);
    }

    // content builds and returns the content.
    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        var line: []u8 = undefined;
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();

        // Imports.
        try lines.appendSlice(line_import_start);
        if (self.tab_panel_count > 0) {
            try lines.appendSlice(line_import_messenger_panels);
        }
        try lines.appendSlice(line_import_continued);
        for (self.tab_names, 0..) |name, i| {
            if (self.tab_has_panel[i]) {
                line = try fmt.allocPrint(self.allocator, line_import_panel, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }

        // Screen struct.
        try lines.appendSlice(line_screen_struct_start);
        for (self.tab_names, 0..) |name, i| {
            if (self.tab_has_panel[i]) {
                line = try fmt.allocPrint(self.allocator, line_add_panel_tab, .{ self.screen_name, name });
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            } else {
                line = try fmt.allocPrint(self.allocator, line_add_screen_tab, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }

        try lines.appendSlice(line_struct_init);
        // Init the example tabs.
        for (self.tab_names, 0..) |name, i| {
            if (self.tab_has_panel[i]) {
                line = try fmt.allocPrint(self.allocator, line_struct_init_panel_tab, .{ self.screen_name, name, (i == 0) });
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            } else {
                line = try fmt.allocPrint(self.allocator, line_struct_init_screen_tab, .{ name, (i == 0) });
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        // Init the messenger.
        if (self.tab_panel_count > 0) {
            try lines.appendSlice(line_struct_messenger);
        }
        // end of init.
        try lines.appendSlice(line_init_end);
        // Deinit.
        try lines.appendSlice(line_struct_deinit_start);
        if (self.tab_panel_count > 0) {
            try lines.appendSlice(line_struct_deinit_messenger);
        }
        {
            line = try fmt.allocPrint(self.allocator, line_struct_deinit_end, .{self.screen_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        return try lines.toOwnedSlice();
    }
};

pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, tab_names: [][]const u8) !*Template {
    var self: *Template = try allocator.create(Template);
    // Screen name.
    self.screen_name = try allocator.alloc(u8, screen_name.len);
    errdefer {
        allocator.destroy(self);
    }
    @memcpy(@constCast(self.screen_name), screen_name);
    self.tab_names = try allocator.alloc([]const u8, tab_names.len);
    errdefer {
        allocator.free(self.screen_name);
        allocator.destroy(self);
    }
    self.tab_has_panel = try allocator.alloc(bool, tab_names.len);
    // Tab and Panel names.
    var panels_names = std.ArrayList([]const u8).init(allocator);
    defer panels_names.deinit();
    for (tab_names, 0..) |name, i| {
        var tab_name: []const u8 = undefined;
        if (name[0] == '*') {
            // This tab uses a panel-screen for content.
            tab_name = name[1..];
            self.tab_has_panel[i] = false;
        } else {
            // This tab needs a panel for content.
            tab_name = name;
            self.tab_has_panel[i] = true;
            self.tab_panel_count += 1;
        }
        self.tab_names[i] = try allocator.alloc(u8, tab_name.len);
        errdefer {
            allocator.free(self.screen_name);
            allocator.destroy(self);
            for (self.tab_names, 0..) |deinit_name, j| {
                if (j == i) {
                    break;
                }
                deinit_name.deinit();
            }
            allocator.free(self.tab_names);
        }
        @memcpy(@constCast(self.tab_names[i]), tab_name);
    }
    self.allocator = allocator;
    return self;
}

// Imports.
const line_import_start =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const _channel_ = @import("channel");
    \\
;
const line_import_messenger_panels =
    \\const _messenger_ = @import("messenger.zig");
    \\const _panels_ = @import("panels.zig");
    \\
;
const line_import_continued =
    \\const _widget_ = @import("widget");
    \\const _screen_pointers_ = @import("../../../screen_pointers.zig");
    \\const _startup_ = @import("startup");
    \\const _various_ = @import("various");
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\const ScreenPointers = _screen_pointers_.ScreenPointers;
    \\const Tab = _widget_.Tab;
    \\const Tabs = _widget_.Tabs;
    \\
    \\
;
const line_import_panel =
    \\const _{0s}_ = @import("{0s}_panel.zig");
    \\
;

// Screen struct.

const line_screen_struct_start =
    \\
    \\pub const Screen = struct {
    \\    allocator: std.mem.Allocator,
    \\    window: *dvui.Window,
    \\    main_view: *MainView,
    \\    tabs: ?*Tabs,
    \\    messenger: ?*_messenger_.Messenger,
    \\    exit: ExitFn,
    \\    send_channels: *_channel_.FrontendToBackend,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\    screen_pointers: *ScreenPointers,
    \\    startup: _startup_.Frontend,
    \\
;

const line_add_panel_tab =
    \\
    \\    // param panel_state is owned by this fn or by the new panel.
    \\    pub fn AddNew{1s}Tab(
    \\        self: *Screen,
    \\        panel_state: *_{1s}_.Panel.State,
    \\        selected: bool,
    \\    ) !void {{
    \\        const panel: *_{1s}_.Panel = try _{1s}_.init(
    \\            self.allocator,
    \\            panel_state,
    \\            self.main_view,
    \\            self.tabs.?,
    \\            self.messenger.?,
    \\            self.exit,
    \\            self.window,
    \\        );
    \\        errdefer {{
    \\            panel_state.deinit();
    \\        }}
    \\        const tab: *Tab = try Tab.initPanelTab(
    \\            self.tabs.?,
    \\            self.main_view,
    \\            panel,
    \\            _{1s}_.Panel.labelFn,
    \\            _{1s}_.Panel.setStateFn,
    \\            _{1s}_.Panel.frameFn,
    \\            _{1s}_.Panel.refreshFn,
    \\            _{1s}_.Panel.deinitFn,
    \\            @intFromEnum(_panels_.PanelTags.{1s}),
    \\            .{0s},
    \\            .{{
    \\                // KICKZIG TODO:
    \\                // You can override the Tabs options for the {0s} tab.
    \\                //.closable = true,
    \\                //.movable = true,
    \\            }},
    \\        );
    \\        errdefer {{
    \\            panel_state.deinit();
    \\            panel.deinit();
    \\        }}
    \\        try self.tabs.?.appendTab(tab, selected);
    \\        errdefer {{
    \\            self.allocator.destroy(tab);
    \\            panel_state.deinit();
    \\            panel.deinit();
    \\        }}
    \\        panel.tab = tab;
    \\    }}
    \\
    \\
;

const line_add_screen_tab =
    \\    pub fn AddNew{0s}Tab(
    \\        self: *Screen,
    \\        selected: bool,
    \\    ) !void {{
    \\        const screen: *_screen_pointers_.{0s} = try _screen_pointers_.{0s}.init(self.startup);
    \\        const tab: *Tab = try Tab.initScreenTab(
    \\            self.tabs.?,
    \\            self.main_view,
    \\            screen,
    \\            _screen_pointers_.{0s}.labelFn,
    \\            _screen_pointers_.{0s}.frameFn,
    \\            _screen_pointers_.{0s}.refreshFn,
    \\            _screen_pointers_.{0s}.deinitFn,
    \\            .{0s},
    \\            .{{
    \\                // KICKZIG TODO:
    \\                // You can override the Tabs options for the {0s} tab.
    \\                //.closable = true,
    \\                //.movable = true,
    \\            }},
    \\        );
    \\        errdefer {{
    \\            screen.deinit();
    \\        }}
    \\        const container: *_various_.Container = try tab.asContainer();
    \\        errdefer {{
    \\            self.allocator.destroy(tab);
    \\            screen.deinit();
    \\        }}
    \\        screen.setContainer(container);
    \\        try self.tabs.?.appendTab(tab, selected);
    \\        errdefer {{
    \\            tab.deinit();
    \\            screen.deinit(); // owns container.
    \\        }}
    \\    }}
    \\
    \\
;
const line_struct_init =
    \\
    \\    /// init constructs this screen, subscribes it to all_screens and returns the error.
    \\    pub fn init(startup: _startup_.Frontend) !*Screen {
    \\        var self: *Screen = try startup.allocator.create(Screen);
    \\        self.tabs = try Tabs.init(
    \\            startup,
    \\            .{
    \\                // KICKZIG TODO:
    \\                // Set your own Tabs options for the {0s} tab.
    \\                .direction = .horizontal,
    \\                .toggle_direction = true,
    \\                .tabs_movable = true,
    \\                .tabs_closable = true,
    \\            },
    \\        );
    \\        errdefer self.deinit();
    \\        self.allocator = startup.allocator;
    \\        self.main_view = startup.main_view;
    \\        self.receive_channels = startup.receive_channels;
    \\        self.send_channels = startup.send_channels;
    \\        self.screen_pointers = startup.screen_pointers;
    \\        self.window = startup.window;
    \\        self.startup = startup;
    \\
    \\        // Create 1 of each type of tab.
    \\
;
const line_struct_init_panel_tab =
    \\
    \\        {{
    \\            const state: *_{1s}_.Panel.State = try _{1s}_.Panel.State.init(
    \\                self.allocator,
    \\                "{1s}",
    \\                "{0s}",
    \\                "{1s}",
    \\            );
    \\            try self.AddNew{1s}Tab(
    \\                state,
    \\                {2},
    \\            );
    \\            errdefer {{
    \\                state.deinit();
    \\                self.deinit();
    \\            }}
    \\        }}
    \\
;
const line_struct_init_screen_tab =
    \\
    \\        try self.AddNew{0s}Tab({1});
    \\
;

const line_struct_messenger =
    \\
    \\        // Create the messenger.
    \\        self.messenger = try _messenger_.init(
    \\            startup.allocator,
    \\            self.tabs.?,
    \\            startup.main_view,
    \\            startup.send_channels,
    \\            startup.receive_channels,
    \\            startup.exit,
    \\        );
    \\        errdefer {
    \\            self.deinit();
    \\        }
    \\
    \\
;
const line_init_end =
    \\        return self;
    \\    }
    \\
;
const line_struct_deinit_start =
    \\
    \\    pub fn willFrame(self: *Screen) bool {
    \\        return self.tabs.?.will_frame();
    \\    }
    \\
    \\    pub fn deinit(self: *Screen) void {
    \\        if (self.tabs) |member| {
    \\            member.deinit();
    \\        }
    \\
;
const line_struct_deinit_messenger =
    \\        if (self.messenger) |member| {
    \\            member.deinit();
    \\        }
    \\
;
const line_struct_deinit_end =
    \\        self.allocator.destroy(self);
    \\    }}
    \\
    \\    /// The caller does not own the returned value.
    \\    /// KICKZIG TODO: You may want to edit the returned label.
    \\    pub fn label(_: *Screen) []const u8 {{
    \\        return "{0s}";
    \\    }}
    \\
    \\    pub fn frame(self: *Screen, arena: std.mem.Allocator) !void {{
    \\        try self.tabs.?.frame(arena);
    \\    }}
    \\}};
    \\
    \\
;
