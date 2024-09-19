const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    tab_names: [][]const u8,
    use_panels: bool,
    use_messenger: bool,

    pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, tab_names: [][]const u8, use_messenger: bool) !*Template {
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
        // Tab and Panel names.
        var panels_names = std.ArrayList([]const u8).init(allocator);
        defer panels_names.deinit();
        self.use_panels = false;
        for (tab_names, 0..) |name, i| {
            self.tab_names[i] = try allocator.alloc(u8, name.len);
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
            @memcpy(@constCast(self.tab_names[i]), name);
            // Check for self.use_panels.
            if (name[0] != '*') {
                // This tab uses a panel-screen for content.
                self.use_panels = true;
            }
        }
        self.allocator = allocator;
        self.use_messenger = use_messenger;
        return self;
    }

    pub fn deinit(self: *Template) void {
        for (self.tab_names) |tab_name| {
            self.allocator.free(tab_name);
        }
        self.allocator.free(self.tab_names);
        self.allocator.free(self.screen_name);
        self.allocator.destroy(self);
    }

    // content builds and returns the content.
    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        var lines: std.ArrayList(u8) = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        var line: []const u8 = undefined;

        // Imports.
        try lines.appendSlice(line_import_start);

        if (self.use_messenger) {
            try lines.appendSlice(line_import_messenger);
        }

        if (self.use_panels) {
            try lines.appendSlice(line_import_panels);
        }

        try lines.appendSlice(line_import_continued);

        for (self.tab_names) |name| {
            if (name[0] == 'p' or name[0] == 't') {
                line = try fmt.allocPrint(self.allocator, line_import_screen_f, .{name[1..]});
            } else {
                line = try fmt.allocPrint(self.allocator, line_import_panel_f, .{name});
            }
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        // Screen struct.
        {
            line = try fmt.allocPrint(self.allocator, line_screen_struct_start_f, .{self.screen_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        for (self.tab_names) |name| {
            if (name[0] == 'p') {
                line = try fmt.allocPrint(self.allocator, line_add_panel_screen_tab_f, .{name[1..]});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            } else if (name[0] == 't') {
                line = try fmt.allocPrint(self.allocator, line_add_tab_screen_tab_f, .{name[1..]});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            } else {
                {
                    line = try fmt.allocPrint(self.allocator, line_add_panel_tab_a_f, .{name});
                    defer self.allocator.free(line);
                    try lines.appendSlice(line);
                }
                if (self.use_messenger) {
                    try lines.appendSlice(line_add_panel_tab_messenger);
                }
                {
                    line = try fmt.allocPrint(self.allocator, line_add_panel_tab_b_f, .{name});
                    defer self.allocator.free(line);
                    try lines.appendSlice(line);
                }
            }
        }

        try lines.appendSlice(line_struct_init);

        // Init the example tabs.
        for (self.tab_names, 0..) |tab_name, i| {
            var name: []const u8 = undefined;
            if (tab_name[0] == 'p' or tab_name[0] == 't') {
                name = tab_name[1..];
            } else {
                name = tab_name;
            }
            line = try fmt.allocPrint(self.allocator, line_struct_init_screen_tab_f, .{ name, (i == 0) });
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        // Init the messenger.
        if (self.use_messenger) {
            try lines.appendSlice(line_struct_messenger);
        }

        // end of init.
        try lines.appendSlice(line_init_end);

        // Deinit.
        try lines.appendSlice(line_struct_deinit_start);

        if (self.use_messenger) {
            try lines.appendSlice(line_struct_deinit_messenger);
        }

        try lines.appendSlice(line_struct_deinit_end);

        return try lines.toOwnedSlice();
    }
};

// Imports.
const line_import_start: []const u8 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const _channel_ = @import("channel");
    \\const _screen_pointers_ = @import("../../../screen_pointers.zig");
    \\const _startup_ = @import("startup");
    \\
    \\
;
const line_import_messenger: []const u8 =
    \\const Messenger = @import("view/messenger.zig").Messenger;
    \\
;
const line_import_panels: []const u8 =
    \\const PanelTags = @import("panels.zig").PanelTags;
    \\
;
const line_import_continued: []const u8 =
    \\const Container = @import("various").Container;
    \\const Content = @import("various").Content;
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\const ScreenPointers = _screen_pointers_.ScreenPointers;
    \\const Tab = @import("widget").Tab;
    \\const Tabs = @import("widget").Tabs;
    \\
    \\
;
const line_import_panel_f: []const u8 =
    \\const {0s}Panel = @import("{0s}.zig").Panel;
    \\
;

const line_import_screen_f: []const u8 =
    \\const {0s}Screen = _screen_pointers_.{0s};
    \\
;

// Screen struct.
// screen name {0s}
const line_screen_struct_start_f: []const u8 =
    \\
    \\/// KICKZIG TODO:
    \\/// Options will need to be customized.
    \\/// Keep each value optional and set to null by default.
    \\//KICKZIG TODO: Customize Options to your requirements.
    \\pub const Options = struct {{
    \\    screen_name: ?[]const u8 = null, // Example field.
    \\
    \\    fn label(self: *Options, allocator: std.mem.Allocator) ![]const u8 {{
    \\        return try std.fmt.allocPrint(allocator, "{{s}}", .{{self.screen_name.?}});
    \\    }}
    \\
    \\    fn copyOf(values: Options, allocator: std.mem.Allocator) !*Options {{
    \\        var copy_of: *Options = try allocator.create(Options);
    \\        // Null optional members for fn reset.
    \\        copy_of.screen_name = null;
    \\        try copy_of.reset(allocator, values);
    \\        errdefer copy_of.deinit();
    \\        return copy_of;
    \\    }}
    \\
    \\    fn deinit(self: *Options, allocator: std.mem.Allocator) void {{
    \\        // Screen name.
    \\        if (self.screen_name) |member| {{
    \\            allocator.free(member);
    \\        }}
    \\        allocator.destroy(self);
    \\    }}
    \\
    \\    fn reset(
    \\        self: *Options,
    \\        allocator: std.mem.Allocator,
    \\        settings: Options,
    \\    ) !void {{
    \\        return self._reset(
    \\            allocator,
    \\            settings.screen_name,
    \\        );
    \\    }}
    \\
    \\    fn _reset(
    \\        self: *Options,
    \\        allocator: std.mem.Allocator,
    \\        screen_name: ?[]const u8,
    \\    ) !void {{
    \\        // Screen name.
    \\        if (screen_name) |reset_value| {{
    \\            if (self.screen_name) |value| {{
    \\                allocator.free(value);
    \\            }}
    \\            self.screen_name = try allocator.alloc(u8, reset_value.len);
    \\            errdefer {{
    \\                self.screen_name = null;
    \\                self.deinit();
    \\            }}
    \\            @memcpy(@constCast(self.screen_name.?), reset_value);
    \\        }}
    \\    }}
    \\}};
    \\
    \\/// Screen is content for the main view or a container.
    \\/// Screen is the container for Tabs.
    \\pub const Screen = struct {{
    \\    allocator: std.mem.Allocator,
    \\    window: *dvui.Window,
    \\    main_view: *MainView,
    \\    container: ?*Container,
    \\    tabs: ?*Tabs,
    \\    messenger: ?*Messenger,
    \\    exit: ExitFn,
    \\    send_channels: *_channel_.FrontendToBackend,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\    screen_pointers: *ScreenPointers,
    \\    startup: _startup_.Frontend,
    \\    state: ?*Options,
    \\
    \\    const default_settings = Options{{
    \\        .screen_name = "{0s}",
    \\    }};
    \\
;

// tab name {0s}
const line_add_panel_tab_a_f: []const u8 =
    \\
    \\    pub fn AddNew{0s}Tab(
    \\        self: *Screen,
    \\        selected: bool,
    \\    ) !void {{
    \\        // The {0s} tab uses this screen's {0s} panel for content.
    \\        const panel: *{0s}Panel = try {0s}Panel.init(
    \\            self.allocator,
    \\            self.window,
    \\            self.main_view,
    \\
;

const line_add_panel_tab_messenger: []const u8 =
    \\            self.messenger.?,
    \\
;

const line_add_panel_tab_b_f: []const u8 =
    \\            self.exit,
    \\            self.state.?.*,
    \\        );
    \\        const panel_as_content: *Content = try panel.asContent();
    \\        errdefer panel.deinit();
    \\        const tab: *Tab = try Tab.init(
    \\            self.tabs.?,
    \\            self.main_view,
    \\            panel_as_content,
    \\            .{{
    \\                // KICKZIG TODO:
    \\                // You can override the options for the {0s} tab.
    \\                //.closable = true,
    \\                //.movable = true,
    \\            }},
    \\        );
    \\        errdefer {{
    \\            panel_as_content.deinit();
    \\        }}
    \\        try self.tabs.?.appendTab(tab, selected);
    \\        errdefer {{
    \\            self.allocator.destroy(tab);
    \\            panel_as_content.deinit();
    \\        }}
    \\    }}
    \\
    \\
;

/// tab_name {0s}
/// A tab which uses a panel screen for content.
const line_add_panel_screen_tab_f: []const u8 =
    \\    pub fn AddNew{0s}Tab(
    \\        self: *Screen,
    \\        selected: bool,
    \\    ) !void {{
    \\        // The {0s} tab uses the {0s} screen for content.
    \\        // The {0s}Screen.init second param container, is null because Tab will set it.
    \\        // The {0s}Screen.init third param screen_options, is a the options for the {0s}Screen.
    \\        // * KICKZIG TODO: You may find setting some screen_options to be usesful.
    \\        // * Param screen_options has no members defined so the {0s}Screen will use it default settings.
    \\        // * See screen/panel/{0s}/screen.Options.
    \\        const screen: *{0s}Screen = try {0s}Screen.init(
    \\            self.startup,
    \\            null,
    \\            .{{}},
    \\        );
    \\        const screen_as_content: *Content = try screen.asContent();
    \\        errdefer screen.deinit();
    \\        // screen_as_content now owns screen.
    \\
    \\        const tab: *Tab = try Tab.init(
    \\            self.tabs.?,
    \\            self.main_view,
    \\            screen_as_content,
    \\            .{{
    \\                // KICKZIG TODO:
    \\                // You can override the options for the {0s} tab.
    \\                //.closable = true,
    \\                //.movable = true,
    \\            }},
    \\        );
    \\        errdefer {{
    \\            screen_as_content.deinit();
    \\        }}
    \\        try self.tabs.?.appendTab(tab, selected);
    \\        errdefer {{
    \\            tab.deinit(); // will deinit screen_as_content.
    \\        }}
    \\    }}
    \\
    \\
;

/// tab_name {0s}
/// A tab which uses a tab screen for content.
const line_add_tab_screen_tab_f: []const u8 =
    \\    pub fn AddNew{0s}Tab(
    \\        self: *Screen,
    \\        selected: bool,
    \\    ) !void {{
    \\        // The {0s} tab uses the {0s} screen for content.
    \\        // The {0s}Screen.init second param container, is null because Tab will set it.
    \\        // The {0s}Screen.init third param tabs_options, is the options for the {0s}Screen's tab-bar.
    \\        // * KICKZIG TODO: You may find setting some tabs_options to be usesful.
    \\        // * Param tab_options has no members defined so the tab-bar will use it's default settings.
    \\        // * See deps/widgets/tabbar/api.zig.
    \\        // The {0s}Screen.init fourth param screen_options, is a the options for the {0s}Screen.
    \\        // * KICKZIG TODO: You may find setting some screen_options to be usesful.
    \\        // * Param screen_options has no members defined so the {0s}Screen will use it default settings.
    \\        // * See screen/tab/{0s}/screen.Options.
    \\        // * See screen/tab/{0s}/Screen fn init to customize how the {0s}Screen uses this fourth param.
    \\        const screen: *{0s}Screen = try {0s}Screen.init(
    \\            self.startup,
    \\            null,
    \\            .{{}},
    \\            .{{}},
    \\        );
    \\        const screen_as_content: *Content = try screen.asContent();
    \\        errdefer screen.deinit();
    \\        // screen_as_content now owns screen.
    \\        const tab: *Tab = try Tab.init(
    \\            self.tabs.?,
    \\            self.main_view,
    \\            screen_as_content,
    \\            .{{
    \\                // KICKZIG TODO:
    \\                // You can override the options for the {0s} tab.
    \\                //.closable = true,
    \\                //.movable = true,
    \\            }},
    \\        );
    \\        errdefer {{
    \\            screen_as_content.deinit();
    \\        }}
    \\        try self.tabs.?.appendTab(tab, selected);
    \\        errdefer {{
    \\            tab.deinit(); // will deinit screen_as_content.
    \\        }}
    \\    }}
    \\
    \\
;
const line_struct_init: []const u8 =
    \\
    \\    /// init constructs this screen, subscribes it to all_screens and returns the error.
    \\    /// Param tabs_options is a Tabs.Options.
    \\    pub fn init(
    \\        startup: _startup_.Frontend,
    \\        container: ?*Container,
    \\        tabs_options: Tabs.Options,
    \\        screen_options: Options,
    \\    ) !*Screen {
    \\        var self: *Screen = try startup.allocator.create(Screen);
    \\        self.allocator = startup.allocator;
    \\        self.main_view = startup.main_view;
    \\        self.receive_channels = startup.receive_channels;
    \\        self.send_channels = startup.send_channels;
    \\        self.screen_pointers = startup.screen_pointers;
    \\        self.window = startup.window;
    \\        self.startup = startup;
    \\
    \\        self.state = Options.copyOf(default_settings, startup.allocator) catch |err| {
    \\            self.state = null;
    \\            self.deinit();
    \\            return err;
    \\        };
    \\        try self.state.?.reset(startup.allocator, screen_options);
    \\        errdefer self.deinit();
    \\
    \\        const self_as_container: *Container = try self.asContainer();
    \\        errdefer startup.allocator.destroy(self);
    \\
    \\        self.tabs = try Tabs.init(startup, self_as_container, tabs_options);
    \\        errdefer self.deinit();
    \\
    \\        // Create 1 of each type of tab.
    \\
;

// tab_name {0s}
// selected {1}
const line_struct_init_panel_tab_f: []const u8 =
    \\
    \\        {{
    \\            // KICKZIG TODO:
    \\            // Correct this to correspond to your definition of {0s}Panel.Options.
    \\            // {0s}Panel.Options is actually Options in view/{0s}.zig.
    \\            //const settings: {0s}Panel.Options = {0s}Panel.Options{{
    \\            //    .tab_label = "{0s}",
    \\            //    .screen_name = screen_name,
    \\            //    .panel_name = "{0s}",
    \\            //}};
    \\            try self.AddNew{0s}Tab({1});
    \\            errdefer self.deinit();
    \\        }}
    \\
;
// tab_name {0s}
// selected {1}
const line_struct_init_screen_tab_f: []const u8 =
    \\
    \\        try self.AddNew{0s}Tab({1});
    \\
;

const line_struct_messenger: []const u8 =
    \\
    \\        // Create the messenger.
    \\        self.messenger = try Messenger.init(
    \\            startup.allocator,
    \\            self.tabs.?,
    \\            startup.main_view,
    \\            startup.send_channels,
    \\            startup.receive_channels,
    \\            startup.exit,
    \\            self.state.?.*,
    \\        );
    \\
    \\        errdefer {
    \\            self.deinit();
    \\        }
    \\
    \\
;
const line_init_end: []const u8 =
    \\        self.container = container;
    \\        return self;
    \\    }
    \\
;
const line_struct_deinit_start: []const u8 =
    \\
    \\    pub fn willFrame(self: *Screen) bool {
    \\        return self.tabs.?.willFrame();
    \\    }
    \\
    \\    pub fn close(self: *Screen) bool {
    \\        _ = self;
    \\    }
    \\
    \\    pub fn deinit(self: *Screen) void {
    \\        // A screen is deinited by it's container or by a failed init.
    \\        // So don't deinit the container.
    \\
;
const line_struct_deinit_messenger: []const u8 =
    \\        if (self.messenger) |member| {
    \\            member.deinit();
    \\        }
    \\
;

const line_struct_deinit_end: []const u8 =
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// The caller owns the returned value.
    \\    pub fn label(self: *Screen, arena: std.mem.Allocator) ![]const u8 {
    \\        return self.state.?.label(arena);
    \\    }
    \\
    \\    pub fn frame(self: *Screen, arena: std.mem.Allocator) !void {
    \\        try self.tabs.?.frame(arena);
    \\    }
    \\
    \\    pub fn setContainer(self: *Screen, container: *Container) void {
    \\        self.container = container;
    \\    }
    \\
    \\    // Content interface functions.
    \\
    \\    /// Convert this Screen to a Content interface.
    \\    pub fn asContent(self: *Screen) !*Content {
    \\        return Content.init(
    \\            self.allocator,
    \\            self,
    \\
    \\            Screen.deinitContentFn,
    \\            Screen.frameContentFn,
    \\            Screen.labelContentFn,
    \\            Screen.willFrameContentFn,
    \\            Screen.setContainerContentFn,
    \\        );
    \\    }
    \\
    \\    /// setContainerContentFn is an implementation of the Content interface.
    \\    /// The Container calls this to set itself as this Content's Container.
    \\    pub fn setContainerContentFn(implementor: *anyopaque, container: *Container) !void {
    \\        var self: *Screen = @alignCast(@ptrCast(implementor));
    \\        return self.setContainer(container);
    \\    }
    \\
    \\    /// deinitContentFn is an implementation of the Content interface.
    \\    /// The Container calls this when it closes or deinits.
    \\    pub fn deinitContentFn(implementor: *anyopaque) void {
    \\        var self: *Screen = @alignCast(@ptrCast(implementor));
    \\        self.deinit();
    \\    }
    \\
    \\    /// willFrameContentFn is an implementation of the Content interface.
    \\    /// The Container calls this when it wants to frame.
    \\    /// Returns if this content will frame under it's current state.
    \\    pub fn willFrameContentFn(implementor: *anyopaque) bool {
    \\        var self: *Screen = @alignCast(@ptrCast(implementor));
    \\        return self.willFrame();
    \\    }
    \\
    \\    /// frameContentFn is an implementation of the Content interface.
    \\    /// The Container calls this when it frames.
    \\    pub fn frameContentFn(implementor: *anyopaque, arena: std.mem.Allocator) anyerror!void {
    \\        var self: *Screen = @alignCast(@ptrCast(implementor));
    \\        return self.frame(arena);
    \\    }
    \\
    \\    /// labelContentFn is an implementation of the Content interface.
    \\    /// The Container may call this when it refreshes.
    \\    pub fn labelContentFn(implementor: *anyopaque, arena: std.mem.Allocator) anyerror![]const u8 {
    \\        var self: *Screen = @alignCast(@ptrCast(implementor));
    \\        return self.label(arena);
    \\    }
    \\
    \\    // Container interface functions.
    \\
    \\    /// Convert this Screen to a Container interface.
    \\    pub fn asContainer(self: *Screen) anyerror!*Container {
    \\        return Container.init(
    \\            self.allocator,
    \\            self,
    \\            Screen.closeContainerFn,
    \\            Screen.refreshContainerFn,
    \\        );
    \\    }
    \\
    \\    /// Close the top container.
    \\    pub fn closeContainerFn(implementor: *anyopaque) void {
    \\        const self: *Screen = @alignCast(@ptrCast(implementor));
    \\        self.container.?.close();
    \\    }
    \\
    \\    /// Refresh a container up to dvui.window if visible.
    \\    pub fn refreshContainerFn(implementor: *anyopaque) void {
    \\        const self: *Screen = @alignCast(@ptrCast(implementor));
    \\        self.container.?.refresh();
    \\    }
    \\};
    \\
    \\
;
