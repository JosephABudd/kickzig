const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    menu_item_names: [][]const u8,
    menu_item_has_panel: []bool,

    pub fn deinit(self: *Template) void {
        for (self.menu_item_names) |tab_name| {
            self.allocator.free(tab_name);
        }
        self.allocator.free(self.menu_item_names);
        self.allocator.free(self.menu_item_has_panel);
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
        for (self.menu_item_names) |name| {
            line = try fmt.allocPrint(self.allocator, "    {0s},\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line2);
        for (self.menu_item_names) |name| {
            line = try fmt.allocPrint(self.allocator, "    const {0s}_label: []const u8 = \"{0s}\";\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        {
            line = try fmt.allocPrint(self.allocator, line3, .{self.screen_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        {
            line = try fmt.allocPrint(self.allocator, line3StartFirstMenuItem, .{self.menu_item_names[0]});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        if (self.menu_item_names.len == 1) {
            try lines.appendSlice(line3EndFirstMenuItem);
        } else {
            for (self.menu_item_names, 0..) |name, i| {
                if (i == 0) {
                    continue;
                }
                line = try fmt.allocPrint(self.allocator, line3StartAdditionalMenuItem, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        try lines.appendSlice(line3Close);
        try lines.appendSlice(line5);
        // line6local
        // line6separate
        for (self.menu_item_names, 0..) |name, i| {
            if (self.menu_item_has_panel[i] == true) {
                line = try fmt.allocPrint(self.allocator, line6local, .{name});
            } else {
                line = try fmt.allocPrint(self.allocator, line6separate, .{name});
            }
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line7);

        {
            line = try fmt.allocPrint(self.allocator, line8, .{ self.screen_name, self.menu_item_names[0] });
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        const temp: []const u8 = try lines.toOwnedSlice();
        line = try self.allocator.alloc(u8, temp.len);
        @memcpy(line, temp);
        return line;
    }
};

pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, menu_item_names: [][]const u8) !*Template {
    var self: *Template = try allocator.create(Template);
    // Screen name.
    self.screen_name = try allocator.alloc(u8, screen_name.len);
    errdefer {
        allocator.destroy(self);
    }
    @memcpy(@constCast(self.screen_name), screen_name);
    self.menu_item_names = try allocator.alloc([]const u8, menu_item_names.len);
    errdefer {
        allocator.free(self.screen_name);
        allocator.destroy(self);
    }
    self.menu_item_has_panel = try allocator.alloc(bool, menu_item_names.len);
    // Tab and Panel names.
    var panels_names = std.ArrayList([]const u8).init(allocator);
    defer panels_names.deinit();
    for (menu_item_names, 0..) |name, i| {
        var tab_name: []const u8 = undefined;
        var has_panel: bool = false;
        if (name[0] == '+') {
            tab_name = name[1..];
            has_panel = true;
        } else {
            tab_name = name;
            has_panel = false;
        }
        self.menu_item_names[i] = try allocator.alloc(u8, tab_name.len);
        errdefer {
            allocator.free(self.screen_name);
            allocator.destroy(self);
            const deinit_names: [][]const u8 = self.menu_item_names[0..i];
            for (deinit_names) |deinit_name| {
                self.allocator.free(deinit_name);
            }
            allocator.free(self.menu_item_names);
        }
        @memcpy(@constCast(self.menu_item_names[i]), tab_name);
        self.menu_item_has_panel[i] = has_panel;
    }
    self.allocator = allocator;
    return self;
}

const line1 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const _channel_ = @import("channel");
    \\const _framers_ = @import("framers");
    \\const _panels_ = @import("panels.zig");
    \\const _messenger_ = @import("messenger.zig");
    \\const _startup_ = @import("startup");
    \\const _various_ = @import("various");
    \\const MainView = @import("framers").MainView;
    \\
    \\/// Define each tab's enum.
    \\/// Always include none.
    \\const menu_items = enum {
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
    \\const Screen = struct {{
    \\    allocator: std.mem.Allocator,
    \\    all_screens: *_framers_.Screens,
    \\    all_panels: ?*_panels_.Panels,
    \\    messenger: ?*_messenger_.Messenger,
    \\    send_channels: *_channel_.FrontendToBackend,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\    container: ?*_various_.Container,
    \\
    \\    selected_menu_item: menu_items,
    \\
    \\    pub fn deinit(self: *Screen) void {{
    \\        if (self.container) |member| {{
    \\            member.deinit();
    \\        }}
    \\        if (self.messenger) |member| {{
    \\            member.deinit();
    \\        }}
    \\        if (self.all_panels) |member| {{
    \\            member.deinit();
    \\        }}
    \\        self.allocator.destroy(self);
    \\    }}
    \\
    \\    pub fn setContainer(self: *Screen, container: *_various_.Container) void {{
    \\        self.container = container;
    \\        self.all_panels.?.setContainer(container);
    \\    }}
    \\
    \\    /// KICKZIG TODO: If you need to, add your own logic here.
    \\    /// Otherwise this screen alway shows when framed.
    \\    pub fn willFrame(self: *Screen) bool {{
    \\        return true;
    \\    }}
    \\
    \\    /// The caller does not own the returned value.
    \\    /// KICKZIG TODO: You may want to edit the returned label.
    \\    /// The label is displayed in the main menu only.
    \\    pub fn label(_: *Screen) []const u8 {{
    \\        return "{0s}";
    \\    }}
    \\
    \\    pub fn frame(self: *Screen, arena: std.mem.Allocator) anyerror!void {{
    \\        var layout = try dvui.box(@src(), .horizontal, .{{ .expand = .both }});
    \\        defer layout.deinit();
    \\
    \\        // The menu screen has multiple panels which are selected from the menu.
    \\        // Like a tab-bar without the tabs.
    \\        // 1. Frame the menu.
    \\        // 2. Frame the content.
    \\
    \\        var m = try dvui.menu(@src(), .horizontal, .{{}});
    \\        defer m.deinit();
    \\
    \\        // Display the open book icon.
    \\        var r: ?dvui.Rect = try dvui.menuItemIcon(@src(), "open_book", dvui.entypo.open_book, .{{ .submenu = true }}, .{{ .expand = .none }});
    \\
    \\        if (r != null) {{
    \\            // The user clicked on the menu icon or it is open.
    \\            // Frame the menu.
    \\
    \\            var fw = try dvui.popup(@src(), dvui.Rect.fromPoint(dvui.Point{{ .x = r.?.x, .y = r.?.y + r.?.h }}), .{{}});
    \\            defer fw.deinit();
    \\
    \\
;

const line3StartFirstMenuItem =
    \\
    \\            if (try dvui.menuItemLabel(@src(), "{0s} Panel", .{{}}, .{{ .expand = .horizontal, .id_extra = 0 }}) != null) {{
    \\                // {0s} Panel.
    \\                // The user selected this tab.
    \\                self.selected_menu_item = menu_items.{0s};
    \\                m.close();
    \\
;

const line3EndFirstMenuItem =
    \\            }
    \\
    \\
;

const line3StartAdditionalMenuItem =
    \\            }} else if (try dvui.menuItemLabel(@src(), "{0s} Panel", .{{}}, .{{ .expand = .horizontal, .id_extra = 0 }}) != null) {{
    \\                // {0s} Panel.
    \\                m.close();
    \\                self.selected_menu_item = menu_items.{0s};
    \\
;

const line3Close =
    \\            } else if (try dvui.menuItemLabel(@src(), "Close Menu", .{}, .{ .expand = .horizontal, .id_extra = 4 }) != null) {
    \\                // Closer.
    \\                m.close();
    \\            }
    \\        }
    \\
    \\
;

const line5 =
    \\        {
    \\            // Display the selected menu item's content.
    \\            switch (self.selected_menu_item) {
    \\
;
const line6local =
    \\                .{0s} => {{
    \\                    try self.all_panels.?.{0s}.?.frame(arena);
    \\                }},
    \\
;

const line6separate =
    \\                .{0s} => {{
    \\                    var behavior: *_framers_.Behavior = try self.all_screens.get("{0s}");
    \\                    if(behavior.frame(behavior.implementor, arena) |err| {{
    \\                        return err;
    \\                    }}
    \\                }},
    \\
;

const line7 =
    \\                .none => {
    \\                    return;
    \\                },
    \\            }
    \\        }
    \\        return null;
    \\    }
    \\};
    \\
    \\/// init constructs this screen, subscribes it to all_screens and returns the error.
    \\pub fn init(startup: _startup_.Frontend) !void {
    \\    var screen: *Screen = try startup.allocator.create(Screen);
    \\    self.allocator = startup.allocator;
    \\    self.all_screens = startup.all_screens;
    \\    self.receive_channels = startup.receive_channels;
    \\    self.send_channels = startup.send_channels;
    \\    self.container = null;
    \\
    \\
;
const line8 =
    \\    // The {1s} tab is selected by default.
    \\    self.selected_menu_item = menu_items.{1s};
    \\
    \\    // The messenger.
    \\    self.messenger = try _messenger_.init(startup.allocator, startup.all_screens, startup.send_channels, startup.receive_channels, startup.exit);
    \\    errdefer {{
    \\        self.deinit();
    \\    }}
    \\
    \\    // All of the panels.
    \\    self.all_panels = try _panels_.init(startup.allocator, startup.all_screens, self.messenger.?, startup.exit, startup.window);
    \\    errdefer {{
    \\        self.deinit();
    \\    }}
    \\    self.messenger.?.all_panels = self.all_panels.?;
    \\
    \\    // Subscribe to all screens.
    \\    self.all_screens.{0s} = screen;
    \\    // screen is now owned by startup.all_screens.
;
