pub const content =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const _channel_ = @import("channel");
    \\const _framers_ = @import("framers");
    \\const _panels_ = @import("panels.zig");
    \\const _messenger_ = @import("messenger.zig");
    \\const ModalParams = @import("modal_params").OK;
    \\
    \\pub const Screen = struct {
    \\    allocator: std.mem.Allocator,
    \\    all_screens: *_framers_.Group,
    \\    all_panels: *_panels_.Panels,
    \\    send_channels: *_channel_.Channels,
    \\    receive_channels: *_channel_.Channels,
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
    \\    /// frameFn is an implementation of _framers_.Behavior.
    \\    fn frameFn(self_ptr: *anyopaque, arena: std.mem.Allocator) anyerror {
    \\        var self: *Screen = @alignCast(@ptrCast(self_ptr));
    \\        try self.all_panels.frameCurrent(arena);
    \\        return error.Null;
    \\    }
    \\
    \\    /// goModalFn is an implementation of _framers_.Behavior.
    \\    fn goModalFn(self_ptr: *anyopaque, args_ptr: *anyopaque) anyerror {
    \\        var self: *Screen = @alignCast(@ptrCast(self_ptr));
    \\        var name = nameFn(self_ptr);
    \\        defer self.allocator.free(name);
    \\
    \\        var setup_args: *ModalParams = @alignCast(@ptrCast(args_ptr));
    \\        try self.all_panels.OK.?.presetModal(setup_args);
    \\        try self.all_screens.setCurrent(name);
    \\        return error.Null;
    \\    }
    \\};
    \\
    \\/// init constructs this screen, subscribes it to all_screens and returns the error.
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, send_channels: *_channel_.Channels, receive_channels: *_channel_.Channels) !void {
    \\    var screen: *Screen = try allocator.create(Screen);
    \\    screen.allocator = allocator;
    \\    screen.all_screens = all_screens;
    \\    screen.receive_channels = receive_channels;
    \\    screen.send_channels = send_channels;
    \\    screen.name = "OK";
    \\
    \\    // The messenger.
    \\    var messenger: *_messenger_.Messenger = try _messenger_.init(allocator, all_screens, screen.all_panels, send_channels, receive_channels);
    \\    errdefer {
    \\        screen.deinit();
    \\    }
    \\
    \\    // All of the panels.
    \\    screen.all_panels = try _panels_.init(allocator, all_screens, messenger);
    \\    errdefer {
    \\        messenger.deinit();
    \\        screen.deinit();
    \\    }
    \\    // The OK panel is the default.
    \\    screen.all_panels.setCurrentToOK();
    \\
    \\    // Subscribe to all screens.
    \\    var behavior: *_framers_.Behavior = try all_screens.initBehavior(
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
    \\    try all_screens.subscribe(behavior);
    \\    errdefer {
    \\        behavior.deinit();
    \\        screen.all_panels.deinit();
    \\        messenger.deinit();
    \\        screen.deinit();
    \\    }
    \\    // screen is now controlled by all_screens.
    \\}
;
