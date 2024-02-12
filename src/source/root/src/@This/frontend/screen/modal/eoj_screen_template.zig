pub const content =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const _channel_ = @import("channel");
    \\const _framers_ = @import("framers");
    \\const _panels_ = @import("panels.zig");
    \\const _messenger_ = @import("messenger.zig");
    \\const _startup_ = @import("startup");
    \\const ModalParams = @import("modal_params").EOJ;
    \\
    \\pub const Screen = struct {
    \\    allocator: std.mem.Allocator,
    \\    all_screens: *_framers_.Group,
    \\    all_panels: *_panels_.Panels,
    \\    send_channels: *_channel_.FrontendToBackend,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\    name: []const u8,
    \\
    \\    pub fn deinit(self: *Screen) void {
    \\        self.all_panels.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    // The caller owns the returned value.
    \\    // If the len of returned value is 0 then do not free.
    \\    // 0 len == error.
    \\    fn nameFn(implementor: *anyopaque) []const u8 {
    \\        var self: *Screen = @alignCast(@ptrCast(implementor));
    \\        var name: []const u8 = self.allocator.alloc(u8, self.name.len) catch {
    \\            return "";
    \\        };
    \\        @memcpy(@constCast(name), self.name);
    \\        return name;
    \\    }
    \\
    \\    /// deinitFn is an implementation of _framers_.Behavior.
    \\    fn deinitFn(implementor: *anyopaque) void {
    \\        var self: *Screen = @alignCast(@ptrCast(implementor));
    \\        self.all_panels.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// frameFn is an implementation of _framers_.Behavior.
    \\    fn frameFn(implementor: *anyopaque, arena: std.mem.Allocator) ?anyerror {
    \\        var self: *Screen = @alignCast(@ptrCast(implementor));
    \\        try self.all_panels.frameCurrent(arena);
    \\        return null;
    \\    }
    \\
    \\    /// goModalFn is an implementation of _framers_.Behavior.
    \\    fn goModalFn(implementor: *anyopaque, args_ptr: *anyopaque) ?anyerror {
    \\        var self: *Screen = @alignCast(@ptrCast(implementor));
    \\        var name = nameFn(implementor);
    \\        defer self.allocator.free(name);
    \\
    \\        var setup_args: *ModalParams = @alignCast(@ptrCast(args_ptr));
    \\        try self.all_panels.EOJ.?.presetModal(setup_args);
    \\        try self.all_screens.setCurrent(name);
    \\        return null;
    \\    }
    \\};
    \\
    \\/// init constructs this screen, subscribes it to startup.all_screens and returns the error.
    \\pub fn init(startup: _startup_.Frontend) !void {
    \\    var screen: *Screen = try startup.allocator.create(Screen);
    \\    screen.allocator = startup.allocator;
    \\    screen.all_screens = startup.all_screens;
    \\    screen.receive_channels = startup.receive_channels;
    \\    screen.send_channels = startup.send_channels;
    \\    screen.name = "EOJ";
    \\
    \\    // The messenger.
    \\    var messenger: *_messenger_.Messenger = try _messenger_.init(startup.allocator, startup.all_screens, startup.send_channels, startup.receive_channels, startup.exit);
    \\    errdefer {
    \\        screen.deinit();
    \\    }
    \\
    \\    // All of the panels.
    \\    screen.all_panels = try _panels_.init(startup.allocator, startup.all_screens, messenger, startup.exit, startup.window);
    \\    errdefer {
    \\        messenger.deinit();
    \\        screen.deinit();
    \\    }
    \\    messenger.all_panels = screen.all_panels;
    \\    // The EOJ panel is the default.
    \\    screen.all_panels.setCurrentToEOJ();
    \\
    \\    // Subscribe to all screens.
    \\    var behavior: *_framers_.Behavior = try startup.all_screens.initBehavior(
    \\        screen,
    \\        Screen.deinitFn,
    \\        Screen.nameFn,
    \\        Screen.frameFn,
    \\        Screen.goModalFn,
    \\    );
    \\    errdefer {
    \\        screen.all_panels.deinit();
    \\        messenger.deinit();
    \\        screen.deinit();
    \\    }
    \\    try startup.all_screens.subscribe(behavior);
    \\    errdefer {
    \\        behavior.deinit();
    \\        screen.all_panels.deinit();
    \\        messenger.deinit();
    \\        screen.deinit();
    \\    }
    \\    // screen is now controlled by startup.all_screens.
    \\}
;