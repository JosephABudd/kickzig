pub const content =
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
    \\    // // receiveInitialize is provided as an example.
    \\    // // It receives the Initialize message.
    \\    // // It implements a behavior required by receive_channels.Initialize.
    \\    // pub fn receiveInitialize(implementor: *anyopaque, message: *_message_.Initialize.Message) void {
    \\    //     var self: *Messenger = @alignCast(@ptrCast(implementor));
    \\    //     _ = self;
    \\    //     _ = message;
    \\    // }
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
    \\    // Below is an example of the messenger adding the behavior requried to receive the Initialize message.
    \\    // // The Initialize message.
    \\    // // * Define the required behavior.
    \\    // var initializeBehavior = try receive_channels.Initialize.initBehavior();
    \\    // errdefer {
    \\    //     allocator.destroy(messenger);
    \\    // }
    \\    // initializeBehavior.implementor = messenger;
    \\    // initializeBehavior.receiveFn = Messenger.receiveInitialize;
    \\    // // * Subscribe in order to receive the Initialize messages.
    \\    // try receive_channels.Initialize.subscribe(initializeBehavior);
    \\    // errdefer {
    \\    //     allocator.destroy(initializeBehavior);
    \\    //     allocator.destroy(messenger);
    \\    // }
    \\
    \\    return messenger;
    \\}
    \\
;
