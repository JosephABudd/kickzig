const std = @import("std");
const fmt = std.fmt;
const _strings_ = @import("strings");

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    tab_names: []*_strings_.UTF8,
    tab_has_panel: []bool,

    pub fn deinit(self: *Template) void {
        for (self.tab_names) |tab_name| {
            tab_name.deinit();
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
        var copy: []const u8 = undefined;

        try lines.appendSlice(line1);
        for (self.tab_names) |name| {
            copy = try name.copy();
            defer self.allocator.free(copy);
            line = try fmt.allocPrint(self.allocator, "    {s},\n", .{copy});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line2);
        for (self.tab_names) |name| {
            copy = try name.copy();
            defer self.allocator.free(copy);
            line = try fmt.allocPrint(self.allocator, "    const {0s}_label: []const u8 = \"{0s}\";\n", .{copy});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line3);
        for (self.tab_names) |name| {
            copy = try name.copy();
            defer self.allocator.free(copy);
            line = try fmt.allocPrint(self.allocator, line4, .{copy});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line5);
        // line6local
        // line6separate
        for (self.tab_names, 0..) |name, i| {
            copy = try name.copy();
            defer self.allocator.free(copy);
            if (i == 0) {
                if (self.tab_has_panel[i] == true) {
                    line = try fmt.allocPrint(self.allocator, line6FirstNoneLocal, .{copy});
                } else {
                    line = try fmt.allocPrint(self.allocator, line6FirstNoneSeparate, .{copy});
                }
            } else {
                if (self.tab_has_panel[i] == true) {
                    line = try fmt.allocPrint(self.allocator, line6local, .{copy});
                } else {
                    line = try fmt.allocPrint(self.allocator, line6separate, .{copy});
                }
            }
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        {
            line = try fmt.allocPrint(self.allocator, line7, .{self.screen_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        {
            copy = try self.tab_names[0].copy(); // Default tab name.
            line = try fmt.allocPrint(self.allocator, line8, .{copy});
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
    self.tab_names = try allocator.alloc(*_strings_.UTF8, tab_names.len);
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
        self.tab_names[i] = try _strings_.UTF8.init(allocator, tab_name);
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
        self.tab_has_panel[i] = has_panel;
    }
    self.allocator = allocator;
    return self;
}

const line1 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const _channel_ = @import("channel");
    \\const _framers_ = @import("framers");
    \\const _tabbar_ = @import("widget").tabbar;
    \\const _panels_ = @import("panels.zig");
    \\const _messenger_ = @import("messenger.zig");
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

const line3 =
    \\
    \\const Screen = struct {
    \\    allocator: std.mem.Allocator,
    \\    all_screens: *_framers_.Group,
    \\    all_panels: *_panels_.Panels,
    \\    send_channels: *_channel_.Channels,
    \\    receive_channels: *_channel_.Channels,
    \\    name: []const u8,
    \\
    \\    selected_tab: tabs,
    \\
    \\    pub fn deinit(self: *Screen) void {
    \\        self.all_panels.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    // The caller owns the returned value.
    \\    // If the len of returned value is 0 then do not free.
    \\    // 0 len == error.
    \\    fn nameFn(self_ptr: *anyopaque) []const u8 {
    \\        var self: *Screen = @alignCast(@ptrCast(self_ptr));
    \\        var name: []const u8 = self.allocator.alloc(u8, self.name.len) catch {
    \\            return "";
    \\        };
    \\        @memcpy(@constCast(name), self.name);
    \\        return name;
    \\    }
    \\
    \\    /// deinitFn is an implementation of _framers_.Behavior.
    \\    fn deinitFn(self_ptr: *anyopaque) void {
    \\        var self: *Screen = @alignCast(@ptrCast(self_ptr));
    \\        self.all_panels.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    fn frameFn(self_ptr: *anyopaque, arena: std.mem.Allocator) anyerror {
    \\        var self: *Screen = @alignCast(@ptrCast(self_ptr));
    \\        var layout = try dvui.box(@src(), .vertical, .{ .expand = .both });
    \\        defer layout.deinit();
    \\
    \\        {
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

const line4 =
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
    \\            switch (self.selected_tab) {
    \\
;

const line6FirstNoneLocal =
    \\                .{0s}, .none => {{
    \\                    try self.all_panels.{0s}.?.frame(arena);
    \\                }},
    \\
;

const line6FirstNoneSeparate =
    \\                .{0s}, .none => {{
    \\                    var behavior: *_framers_.Behavior = try self.all_screens.get("{0s}");
    \\                    var err = behavior.frameFn(behavior.implementor, arena);
    \\                    if (err != error.Null) {{
    \\                        return err;
    \\                    }}
    \\                }},
    \\
;

const line6local =
    \\                .{0s} => {{
    \\                    try self.all_panels.{0s}.?.frame(arena);
    \\                }},
    \\
;

const line6separate =
    \\                .{0s} => {{
    \\                    var behavior: *_framers_.Behavior = try self.all_screens.get("{0s}");
    \\                    var err = behavior.frameFn(behavior.implementor, arena);
    \\                    if (err != error.Null) {{
    \\                        return err;
    \\                    }}
    \\                }},
    \\
;

const line7 =
    \\            }}
    \\        }}
    \\        return error.Null;
    \\    }}
    \\}};
    \\
    \\/// init constructs this screen, subscribes it to all_screens and returns the error.
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, send_channels: *_channel_.Channels, receive_channels: *_channel_.Channels) !void {{
    \\    var screen: *Screen = try allocator.create(Screen);
    \\    screen.allocator = allocator;
    \\    screen.all_screens = all_screens;
    \\    screen.receive_channels = receive_channels;
    \\    screen.send_channels = send_channels;
    \\    screen.name = "{s}";
    \\
    \\
;
const line8 =
    \\    // The {0s} tab is selected by default.
    \\    screen.selected_tab = tabs.{0s};
    \\
    \\    // The messenger.
    \\    var messenger: *_messenger_.Messenger = try _messenger_.init(allocator, all_screens, screen.all_panels, send_channels, receive_channels);
    \\    errdefer {{
    \\        screen.deinit();
    \\    }}
    \\
    \\    // All of the panels.
    \\    screen.all_panels = try _panels_.init(allocator, all_screens, messenger);
    \\    errdefer {{
    \\        messenger.deinit();
    \\        screen.deinit();
    \\    }}
    \\
    \\    // Subscribe to all screens.
    \\    var behavior: *_framers_.Behavior = try all_screens.initBehavior(
    \\        screen,
    \\        Screen.deinitFn,
    \\        Screen.nameFn,
    \\        Screen.frameFn,
    \\        null,
    \\    );
    \\    errdefer {{
    \\        screen.all_panels.deinit();
    \\        messenger.deinit();
    \\        screen.deinit();
    \\    }}
    \\    try all_screens.subscribe(behavior);
    \\    errdefer {{
    \\        behavior.deinit();
    \\        screen.all_panels.deinit();
    \\        messenger.deinit();
    \\        screen.deinit();
    \\    }}
    \\    // screen is now controlled by all_screens.
    \\}}
    \\
;
