pub const content =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const _channel_ = @import("channel");
    \\const _panels_ = @import("panels.zig");
    \\const _startup_ = @import("startup");
    \\const MainView = @import("framers").MainView;
    \\const ModalParams = @import("modal_params").OK;
    \\
    \\pub const Screen = struct {
    \\    allocator: std.mem.Allocator,
    \\    main_view: *MainView,
    \\    all_panels: *_panels_.Panels,
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
    \\        // All of the panels.
    \\        self.all_panels = try _panels_.init(startup.allocator, startup.main_view, startup.exit, startup.window);
    \\        errdefer {
    \\            self.deinit();
    \\        }
    \\        // The OK panel is the default.
    \\        self.all_panels.setCurrentToOK();
    \\        return self;
    \\    }
    \\
    \\    pub fn deinit(self: *Screen) void {
    \\        self.all_panels.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// The caller does not own the returned value.
    \\    pub fn label(_: *Screen) []const u8 {
    \\        return "OK";
    \\    }
    \\
    \\    pub fn frame(self: *Screen, arena: std.mem.Allocator) !void {
    \\        try self.all_panels.frameCurrent(arena);
    \\    }
    \\
    \\    /// setState sets the state for this modal screen.
    \\    pub fn setState(self: *Screen, setup_args: *ModalParams) !void {
    \\        try self.all_panels.OK.?.presetModal(setup_args);
    \\    }
    \\};
;
