pub const content: []const u8 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const _channel_ = @import("channel");
    \\const _startup_ = @import("startup");
    \\
    \\const MainView = @import("framers").MainView;
    \\const Messenger = @import("view/messenger.zig").Messenger;
    \\const ModalParams = @import("modal_params").EOJ;
    \\const Panels = @import("panels.zig").Panels;
    \\
    \\pub const Screen = struct {
    \\    allocator: std.mem.Allocator,
    \\    main_view: *MainView,
    \\    all_panels: ?*Panels,
    \\    messenger: ?*Messenger,
    \\    send_channels: *_channel_.FrontendToBackend,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\
    \\    /// init constructs this screen, subscribes it to startup.main_view and returns the error.
    \\    pub fn init(startup: _startup_.Frontend) !*Screen {
    \\        var self: *Screen = try startup.allocator.create(Screen);
    \\        self.allocator = startup.allocator;
    \\        self.main_view = startup.main_view;
    \\        self.receive_channels = startup.receive_channels;
    \\        self.send_channels = startup.send_channels;
    \\
    \\        // The messenger.
    \\        self.messenger = try Messenger.init(startup.allocator, startup.main_view, startup.send_channels, startup.receive_channels, startup.exit);
    \\        errdefer {
    \\            self.deinit();
    \\        }
    \\
    \\        // All of the panels.
    \\        self.all_panels = try Panels.init(startup.allocator, startup.main_view, self.messenger.?, startup.exit, startup.window, startup.theme);
    \\        errdefer {
    \\            self.deinit();
    \\        }
    \\        self.messenger.?.all_panels = self.all_panels.?;
    \\        // The EOJ panel is the default.
    \\        self.all_panels.?.setCurrentToEOJ();
    \\        return self;
    \\    }
    \\
    \\    pub fn deinit(self: *Screen) void {
    \\        if (self.messenger) |member| {
    \\            member.deinit();
    \\        }
    \\        if (self.all_panels) |member| {
    \\            member.deinit();
    \\        }
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// The caller owns the returned value.
    \\    pub fn label(_: *Screen, allocator: std.mem.Allocator) ![]const u8 {
    \\        const screen_name: []const u8 = "EOJ";
    \\        const container_label: []const u8 = try allocator.alloc(u8, screen_name.len);
    \\        @memcpy(@constCast(container_label), screen_name);
    \\        return container_label;
    \\    }
    \\
    \\    pub fn frame(self: *Screen, arena: std.mem.Allocator) !void {
    \\        // The modal border.
    \\        const padding_options = .{
    \\            .expand = .both,
    \\            .margin = dvui.Rect.all(0),
    \\            .border = dvui.Rect.all(10),
    \\            .padding = dvui.Rect.all(10),
    \\            .corner_radius = dvui.Rect.all(5),
    \\            .color_border = self.all_panels.?.borderColorCurrent(),
    \\        };
    \\        var padding: *dvui.BoxWidget = try dvui.box(@src(), .vertical, padding_options);
    \\        defer padding.deinit();
    \\
    \\        try self.all_panels.?.frameCurrent(arena);
    \\    }
    \\
    \\    /// setState sets the state for this modal screen.
    \\    pub fn setState(self: *Screen, modal_params: *ModalParams) !void {
    \\        try self.all_panels.?.presetModal(modal_params);
    \\    }
    \\};
    \\
;
