const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.screen_name);
        self.allocator.destroy(self);
    }

    // content builds and returns the content.
    // The caller owns the return value.
    pub fn content(self: *Template) ![]const u8 {
        // screen_name
        var size: usize = std.mem.replacementSize(u8, template, "{{screen_name}}", self.screen_name);
        var with_screen_name: []u8 = try self.allocator.alloc(u8, size);
        _ = std.mem.replace(u8, template, "{{screen_name}}", self.screen_name, with_screen_name);
        return with_screen_name;
    }
};

pub fn init(allocator: std.mem.Allocator, screen_name: []const u8) !*Template {
    var self: *Template = try allocator.create(Template);
    self.screen_name = try allocator.alloc(u8, screen_name.len);
    errdefer {
        allocator.destroy(self);
    }
    @memcpy(@constCast(self.screen_name), screen_name);
    self.allocator = allocator;
    return self;
}

const template =
    \\const std = @import("std");
    \\
    \\const _message_ = @import("message");
    \\const _channel_ = @import("channel");
    \\const _framers_ = @import("framers");
    \\
    \\const _panels_ = @import("panels.zig");
    \\
    \\pub const Messenger = struct {
    \\    allocator: std.mem.Allocator,
    \\    arena: std.mem.Allocator,
    \\
    \\    all_screens: *_framers_.Group,
    \\    all_panels: *_panels_.Panels,
    \\    send_channels: *_channel_.Channels,
    \\    receive_channels: *_channel_.Channels,
    \\
    \\    pub fn deinit(self: *Messenger) void {
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    // Below is an example of a receive function.
    \\    // receiveInitialize is provided as an example.
    \\    // It receives the Initialize message.
    \\    // It implements a behavior required by receive_channels.Initialize.
    \\    pub fn receiveInitialize(self_ptr: *anyopaque, message: *_message_.Initialize.Message) void {
    \\        var self: *Messenger = @alignCast(@ptrCast(self_ptr));
    \\        _ = self;
    \\        _ = message;
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, all_panels: *_panels_.Panels, send_channels: *_channel_.Channels, receive_channels: *_channel_.Channels) !*Messenger {
    \\    var messenger: *Messenger = try allocator.create(Messenger);
    \\    messenger.allocator = allocator;
    \\    messenger.all_screens = all_screens;
    \\    messenger.all_panels = all_panels;
    \\    messenger.send_channels = send_channels;
    \\    messenger.receive_channels = receive_channels;
    \\
    \\    // For a messenger to receive a message, the messenger must:
    \\    // 1. implement the behavior of the message's channel.
    \\    // 2. subscribe to the message's channel.
    \\
    \\    // The Initialize message.
    \\    // Define the required behavior.
    \\    var initializeBehavior = try receive_channels.Initialize.initBehavior();
    \\    errdefer {
    \\        allocator.destroy(messenger);
    \\    }
    \\    initializeBehavior.self = messenger;
    \\    initializeBehavior.receiveFn = Messenger.receiveInitialize;
    \\    // Subscribe in order to receive the Initialize messages.
    \\    try receive_channels.Initialize.subscribe(initializeBehavior);
    \\    errdefer {
    \\        allocator.destroy(initializeBehavior);
    \\        allocator.destroy(messenger);
    \\    }
    \\
    \\    return messenger;
    \\}
;
