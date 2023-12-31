const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    default_panel_name: []const u8,

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.screen_name);
        self.allocator.destroy(self);
    }

    // content builds and returns the content.
    // The caller owns the return value.
    pub fn content(self: *Template) ![]const u8 {
        var size: usize = 0;
        // screen_name
        size = std.mem.replacementSize(u8, template, "{{ screen_name }}", self.screen_name);
        var with_screen_name: []u8 = try self.allocator.alloc(u8, size);
        defer self.allocator.free(with_screen_name);
        _ = std.mem.replace(u8, template, "{{ screen_name }}", self.screen_name, with_screen_name);
        // default_panel_name
        size = std.mem.replacementSize(u8, with_screen_name, "{{ default_panel_name }}", self.default_panel_name);
        var with_default_panel_name: []u8 = try self.allocator.alloc(u8, size);
        _ = std.mem.replace(u8, with_screen_name, "{{ default_panel_name }}", self.default_panel_name, with_default_panel_name);
        return with_default_panel_name;
    }
};

pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, default_panel_name: []const u8) !*Template {
    var self: *Template = try allocator.create(Template);
    self.screen_name = try allocator.alloc(u8, screen_name.len);
    errdefer {
        allocator.destroy(self);
    }
    @memcpy(@constCast(self.screen_name), screen_name);
    self.default_panel_name = try allocator.alloc(u8, default_panel_name.len);
    errdefer {
        allocator.free(self.screen_name);
        allocator.destroy(self);
    }
    @memcpy(@constCast(self.default_panel_name), default_panel_name);
    self.allocator = allocator;
    return self;
}

const template =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const _channel_ = @import("channel");
    \\const _framers_ = @import("framers");
    \\const _panels_ = @import("panels.zig");
    \\const _messenger_ = @import("messenger.zig");
    \\
    \\const Screen = struct {
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
    \\    fn frameFn(implementor: *anyopaque, arena: std.mem.Allocator) anyerror {
    \\        var self: *Screen = @alignCast(@ptrCast(implementor));
    \\        try self.all_panels.frameCurrent(arena);
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
    \\    screen.name = "{{ screen_name }}";
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
    \\    // The {{ default_panel_name }} panel is the default.
    \\    screen.all_panels.setCurrentTo{{ default_panel_name }}();
    \\
    \\    // Subscribe to all screens.
    \\    var behavior: *_framers_.Behavior = try all_screens.initBehavior(
    \\        screen,
    \\        Screen.deinitFn,
    \\        Screen.nameFn,
    \\        Screen.frameFn,
    \\        null,
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
