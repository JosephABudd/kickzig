const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    panel_names: [][]const u8,
    use_messenger: bool,

    pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, panel_names: [][]const u8, use_messenger: bool) !*Template {
        var self: *Template = try allocator.create(Template);
        self.screen_name = try allocator.alloc(u8, screen_name.len);
        errdefer {
            allocator.destroy(self);
        }
        @memcpy(@constCast(self.screen_name), screen_name);
        self.panel_names = try allocator.alloc([]const u8, panel_names.len);
        errdefer {
            allocator.free(self.screen_name);
            allocator.destroy(self);
        }
        for (panel_names, 0..) |panel_name, i| {
            self.panel_names[i] = try allocator.alloc(u8, panel_name.len);
            errdefer {
                for (self.panel_names, 0..) |deinit_panel_name, j| {
                    if (i == j) {
                        break;
                    }
                    allocator.free(deinit_panel_name);
                }
                allocator.free(self.screen_name);
                allocator.destroy(self);
            }
            @memcpy(@constCast(self.panel_names[i]), panel_name);
        }
        self.allocator = allocator;
        self.use_messenger = use_messenger;
        return self;
    }

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.screen_name);
        self.allocator.destroy(self);
    }

    // content builds and returns the content.
    // The caller owns the return value.
    pub fn content(self: *Template) ![]const u8 {
        var lines: std.ArrayList(u8) = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        var line: []const u8 = undefined;
        const default_panel_name: []const u8 = self.panel_names[0];

        try lines.appendSlice(line_1);

        if (self.use_messenger) {
            try lines.appendSlice(line_1_use_messenger);
        }

        try lines.appendSlice(line_2);

        if (self.use_messenger) {
            try lines.appendSlice(line_2_use_messenger);
        }

        {
            line = try std.fmt.allocPrint(self.allocator, line_3_f, .{self.screen_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        if (self.use_messenger) {
            try lines.appendSlice(line_3_use_messenger);
        }

        try lines.appendSlice(line_4);

        if (self.use_messenger) {
            line = try std.fmt.allocPrint(self.allocator, line_4_use_messenger_f, .{default_panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        } else {
            line = try std.fmt.allocPrint(self.allocator, line_4_dont_use_messenger_f, .{default_panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        {
            line = try std.fmt.allocPrint(self.allocator, line_5_f, .{self.screen_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        return try lines.toOwnedSlice();
    }
};

const line_1: []const u8 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
;

const line_1_use_messenger: []const u8 =
    \\
    \\const _channel_ = @import("channel");
    \\const _startup_ = @import("startup");
    \\
;

const line_2: []const u8 =
    \\
    \\const MainView = @import("framers").MainView;
    \\
;

const line_2_use_messenger: []const u8 =
    \\const Messenger = @import("view/messenger.zig").Messenger;
    \\
;

// screen name {0s}
const line_3_f: []const u8 =
    \\const ModalParams = @import("modal_params").{0s};
    \\const Panels = @import("panels.zig").Panels;
    \\
    \\pub const Screen = struct {{
    \\    allocator: std.mem.Allocator,
    \\    main_view: *MainView,
    \\    all_panels: ?*Panels,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\    send_channels: *_channel_.FrontendToBackend,
    \\
;

const line_3_use_messenger: []const u8 =
    \\    messenger: ?*Messenger,
    \\
;

const line_4: []const u8 =
    \\    modal_params: ?*ModalParams,
    \\
    \\    /// init constructs this screen, subscribes it to main_view and returns the error.
    \\    pub fn init(startup: _startup_.Frontend) !*Screen {
    \\        var self: *Screen = try startup.allocator.create(Screen);
    \\        self.allocator = startup.allocator;
    \\        self.main_view = startup.main_view;
    \\        self.modal_params = null;
    \\
;

/// default panel name {0s}
const line_4_use_messenger_f: []const u8 =
    \\        self.receive_channels = startup.receive_channels;
    \\        self.send_channels = startup.send_channels;
    \\
    \\        // The messenger.
    \\        self.messenger = try Messenger.init(startup.allocator, startup.main_view, startup.send_channels, startup.receive_channels, startup.exit);
    \\        errdefer {{
    \\            self.messenger = null;
    \\            self.deinit();
    \\        }}
    \\
    \\        // All of the panels.
    \\        self.all_panels = try Panels.init(startup.allocator, startup.main_view, self.messenger.?, startup.exit, startup.window, startup.theme);
    \\        errdefer {{
    \\            self.all_panels = null;
    \\            self.deinit();
    \\        }}
    \\        self.messenger.?.all_panels = self.all_panels.?;
    \\        // The {0s} panel is the default.
    \\        self.all_panels.?.setCurrentTo{0s}();
    \\        return self;
    \\    }}
    \\
;

/// default panel name {0s}
const line_4_dont_use_messenger_f: []const u8 =
    \\
    \\        // All of the panels.
    \\        self.all_panels = try Panels.init(startup.allocator, startup.main_view, startup.exit, startup.window);
    \\        errdefer {{
    \\            self.deinit();
    \\        }}
    \\        // The {0s} panel is the default.
    \\        self.all_panels.?.setCurrentTo{0s}();
    \\        return self;
    \\    }}
    \\
;

/// screen name {0s}
const line_5_f: []const u8 =
    \\
    \\    pub fn deinit(self: *Screen) void {{
    \\        if (self.all_panels) |member| {{
    \\            member.deinit();
    \\        }}
    \\        if (self.messenger) |member| {{
    \\            member.deinit();
    \\        }}
    \\        if (self.modal_params) |member| {{
    \\            member.deinit();
    \\        }}
    \\        self.allocator.destroy(self);
    \\    }}
    \\
    \\    /// The caller owns the returned value.
    \\    pub fn label(_: *Screen, allocator: std.mem.Allocator) ![]const u8 {{
    \\        const screen_name: []const u8 = "{0s}";
    \\        const container_label: []const u8 = try allocator.alloc(u8, screen_name.len);
    \\        @memcpy(@constCast(container_label), screen_name);
    \\        return container_label;
    \\    }}
    \\
    \\    pub fn frame(self: *Screen, arena: std.mem.Allocator) !void {{
    \\        // The modal border.
    \\        const padding_options = .{{
    \\            .expand = .both,
    \\            .margin = dvui.Rect.all(0),
    \\            .border = dvui.Rect.all(10),
    \\            .padding = dvui.Rect.all(10),
    \\            .corner_radius = dvui.Rect.all(5),
    \\            .color_border = self.all_panels.?.borderColorCurrent(),
    \\        }};
    \\        var padding: *dvui.BoxWidget = try dvui.box(@src(), .vertical, padding_options);
    \\        defer padding.deinit();
    \\
    \\        try self.all_panels.?.frameCurrent(arena);
    \\    }}
    \\
    \\    /// setState sets the state for this modal screen.
    \\    pub fn setState(self: *Screen, modal_params: *ModalParams) !void {{
    \\        if (self.modal_params) |params| {{
    \\            params.deinit();
    \\        }}
    \\        self.modal_params = modal_params;
    \\        try self.all_panels.?.presetModal(modal_params);
    \\    }}
    \\}};
    \\
;
