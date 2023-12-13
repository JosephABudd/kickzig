const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    panel_names: [][]const u8,

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.screen_name);
        self.allocator.destroy(self);
    }

    // content builds and returns the content.
    // The caller owns the return value.
    pub fn content(self: *Template) ![]const u8 {
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        var size: usize = 0;
        var with_screen_name: []u8 = undefined;
        var with_default_panel_name: []u8 = undefined;
        var line: []u8 = undefined;
        var default_panel_name: []const u8 = self.panel_names[0];

        {
            // line1.
            // screen_name
            size = std.mem.replacementSize(u8, line1, "{{ screen_name }}", self.screen_name);
            with_screen_name = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_screen_name);
            _ = std.mem.replace(u8, line1, "{{ screen_name }}", self.screen_name, with_screen_name);
            // default_panel_name
            size = std.mem.replacementSize(u8, with_screen_name, "{{ default_panel_name }}", default_panel_name);
            with_default_panel_name = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_default_panel_name);
            _ = std.mem.replace(u8, with_screen_name, "{{ default_panel_name }}", default_panel_name, with_default_panel_name);
            try lines.appendSlice(with_default_panel_name);
        }

        for (self.panel_names) |panel_name| {
            line = try std.fmt.allocPrint(self.allocator, "        try self.all_panels.{s}.?.presetModal(setup_args);\n", .{panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        {
            // line2.
            // screen_name
            size = std.mem.replacementSize(u8, line2, "{{ screen_name }}", self.screen_name);
            with_screen_name = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_screen_name);
            _ = std.mem.replace(u8, line2, "{{ screen_name }}", self.screen_name, with_screen_name);
            // default_panel_name
            size = std.mem.replacementSize(u8, with_screen_name, "{{ default_panel_name }}", default_panel_name);
            with_default_panel_name = try self.allocator.alloc(u8, size);
            _ = std.mem.replace(u8, with_screen_name, "{{ default_panel_name }}", default_panel_name, with_default_panel_name);
            try lines.appendSlice(with_default_panel_name);
        }

        var temp: []const u8 = try lines.toOwnedSlice();
        line = try self.allocator.alloc(u8, temp.len);
        @memcpy(line, temp);
        return line;
    }
};

pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, panel_names: [][]const u8) !*Template {
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
    return self;
}

const line1 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const _channel_ = @import("channel");
    \\const _framers_ = @import("framers");
    \\const _panels_ = @import("panels.zig");
    \\const _messenger_ = @import("messenger.zig");
    \\const ModalParams = @import("modal_params").{{ screen_name }};
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
    \\
;

const line2 =
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
