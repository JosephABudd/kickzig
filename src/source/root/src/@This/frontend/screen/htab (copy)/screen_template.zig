const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    tab_names: [][]const u8,
    tab_has_panel: []bool,

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

        try lines.appendSlice(line1);
        for (self.tab_names) |name| {
            line = try fmt.allocPrint(self.allocator, "    {0s},\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line2);
        for (self.tab_names) |name| {
            line = try fmt.allocPrint(self.allocator, "    const {0s}_label: []const u8 = \"{0s}\";\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        {
            line = try fmt.allocPrint(self.allocator, line_struct_start, .{ self.screen_name, self.tab_names[0] });
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        for (self.tab_names) |name| {
            line = try fmt.allocPrint(self.allocator, line_frame_tab, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line5);
        // line_frame_next_tab_local_content
        // line_frame_next_tab_separate_content
        for (self.tab_names, 0..) |name, i| {
            if (i == 0) {
                if (self.tab_has_panel[i] == true) {
                    line = try fmt.allocPrint(self.allocator, line_frame_first_tab_local_content, .{name});
                } else {
                    line = try fmt.allocPrint(self.allocator, line_frame_first_tab_separate_content, .{name});
                }
            } else {
                if (self.tab_has_panel[i] == true) {
                    line = try fmt.allocPrint(self.allocator, line_frame_next_tab_local_content, .{name});
                } else {
                    line = try fmt.allocPrint(self.allocator, line_frame_next_tab_separate_content, .{name});
                }
            }
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_struct_end);

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
        var has_panel: bool = false;
        if (name[0] == '+') {
            tab_name = name[1..];
            has_panel = true;
        } else {
            tab_name = name;
            has_panel = false;
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
        self.tab_has_panel[i] = has_panel;
    }
    self.allocator = allocator;
    return self;
}

const line1 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const _channel_ = @import("channel");
    \\const _messenger_ = @import("messenger.zig");
    \\const _panels_ = @import("panels.zig");
    \\const _startup_ = @import("startup");
    \\const _tabbar_ = @import("widget").tabbar;
    \\const MainView = @import("framers").MainView;
    \\
    \\/// Define each tab's enum.
    \\/// Always include none.
    \\const tabs = enum {
    \\
;
// \\    +Select,
// \\    Edit,

const line2 =
    \\    none,
    \\};
    \\
    \\/// KICKZIG TODO:
    \\/// Define each tab's label.
    \\
;

// \\// const {{ tab_name }}_label: []const u8 = "{{ tab_name }}";
// \\// const separate_screen_label: []const u8 = "Separate Screen Content";

const line_struct_start =
    \\
    \\pub const Screen = struct {{
    \\    allocator: std.mem.Allocator,
    \\    main_view: *MainView,
    \\    all_panels: *_panels_.Panels,
    \\    send_channels: *_channel_.FrontendToBackend,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\
    \\    selected_tab: tabs,
    \\
    \\    /// init constructs this screen, subscribes it to all_screens and returns the error.
    \\    pub fn init(startup: _startup_.Frontend) !void {{
    \\        var self: *Screen = try startup.allocator.create(Screen);
    \\        self.allocator = startup.allocator;
    \\        self.main_view = startup.main_view;
    \\        self.receive_channels = startup.receive_channels;
    \\        self.send_channels = startup.send_channels;
    \\    
    \\    
    \\        // The {1s} tab is selected by default.
    \\        self.selected_tab = tabs.{1s};
    \\    
    \\        // The messenger.
    \\        var messenger: *_messenger_.Messenger = try _messenger_.init(startup.allocator, startup.main_view, startup.send_channels, startup.receive_channels, startup.exit);
    \\        errdefer {{
    \\            self.deinit();
    \\        }}
    \\
    \\        // All of the panels.
    \\        self.all_panels = try _panels_.init(startup.allocator, startup.main_view, messenger, startup.exit, startup.window);
    \\        errdefer {{
    \\            messenger.deinit();
    \\            self.deinit();
    \\        }}
    \\        messenger.all_panels = self.all_panels;
    \\        // The {1s} panel is the default.
    \\        self.all_panels.setCurrentTo{1s}();
    \\        return self;
    \\    }}
    \\
    \\    pub fn deinit(self: *Screen) void {{
    \\        self.all_panels.deinit();
    \\        self.allocator.destroy(self);
    \\    }}
    \\
    \\    /// The caller does not own the returned value.
    \\    /// KICKZIG TODO: You may want to edit the returned label.
    \\    pub fn label(_: *Screen) []const u8 {{
    \\        return "{0s}";
    \\    }}
    \\
    \\    pub fn frame(self: *Screen, arena: std.mem.Allocator) ?anyerror {{
    \\        var layout = try dvui.box(@src(), .vertical, .{{ .expand = .both }});
    \\        defer layout.deinit();
    \\
    \\        {{
    \\            // The horizontal row.
    \\            var row = try _tabbar_.horizontalTabBarRow(@src());
    \\            defer row.deinit();
    \\
    \\            // The horizontal scroller.
    \\            var scroller = try _tabbar_.horizontalTabScroller(@src());
    \\            defer scroller.deinit();
    \\
    \\            // The tab bar.
    \\            var tabbar = try _tabbar_.horizontalTabBar(@src());
    \\            defer tabbar.deinit();
    \\
    \\            var selected: bool = false;
    \\            var tab: ?dvui.Rect = null;
    \\
    \\
;

const line_frame_tab =
    \\            // The {0s} tab.
    \\            selected = self.selected_tab == tabs.{0s};
    \\            tab = try _tabbar_.horizontalTabBarItemLabel(@src(), {0s}_label, selected);
    \\            if (tab != null) {{
    \\                // The user selected this tab.
    \\                if (!selected) {{
    \\                    self.selected_tab = tabs.{0s};
    \\                }}
    \\            }}
    \\
    \\
;

const line5 =
    \\        }
    \\
    \\        {
    \\            // The content area for a tab's content.
    \\            // Display the selected tab's content.
    \\
    \\            // KICKZIG TODO:
    \\            // Display your selected tab's content.
    \\            switch (self.selected_tab) {
    \\
;

const line_frame_first_tab_local_content =
    \\                .{0s}, .none => {{
    \\                    try self.all_panels.{0s}.?.frame(arena);
    \\                }},
    \\
;

const line_frame_first_tab_separate_content =
    \\                .{0s}, .none => {{
    \\                    var behavior: *_framers_.Behavior = try self.all_screens.get("{0s}");
    \\                    if(behavior.frame(behavior.implementor, arena)) |err| {{
    \\                        return err;
    \\                    }}
    \\                }},
    \\
;

const line_frame_next_tab_local_content =
    \\                .{0s} => {{
    \\                    try self.all_panels.{0s}.?.frame(arena);
    \\                }},
    \\
;

const line_frame_next_tab_separate_content =
    \\                .{0s} => {{
    \\                    var behavior: *_framers_.Behavior = try self.all_screens.get("{0s}");
    \\                    if (behavior.frame(behavior.implementor, arena)) |err| {{
    \\                        return err;
    \\                    }}
    \\                }},
    \\
;

const line_struct_end =
    \\            }}
    \\        }}
    \\        return null;
    \\    }}
    \\}};
    \\
;
