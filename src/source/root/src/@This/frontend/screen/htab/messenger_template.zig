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
    \\    send_channels: *_channel_.FrontendToBackend,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\    exit: *const fn (user_message: []const u8) void,
    \\
    \\    pub fn deinit(self: *Messenger) void {
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    // Below is an example of a receive function.
    \\    // // receiveAddContact is provided as an example.
    \\    // // It receives the AddContact message.
    \\    // // It implements a behavior required by receive_channels.AddContact.
    \\    // pub fn receiveAddContact(implementor: *anyopaque, message: *_message_.AddContact.Message) ?anyerror {
    \\    //     var self: *Messenger = @alignCast(@ptrCast(implementor));
    \\    //     _ = self;
    \\    //     _ = message;
    \\    //     // No error so return null;
    \\    //     return null;
    \\    // }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, send_channels: *_channel_.FrontendToBackend, receive_channels: *_channel_.BackendToFrontend, exit: *const fn (user_message: []const u8) void) !*Messenger {
    \\    var messenger: *Messenger = try allocator.create(Messenger);
    \\    messenger.allocator = allocator;
    \\    messenger.all_screens = all_screens;
    \\    messenger.send_channels = send_channels;
    \\    messenger.receive_channels = receive_channels;
    \\    messenger.exit = exit;
    \\
    \\    // For a messenger to receive a message, the messenger must:
    \\    // 1. implement the behavior of the message's channel.
    \\    // 2. subscribe to the message's channel.
    \\
    \\    // Below is an example of the messenger adding the behavior requried to receive the AddContact message.
    \\    // // The AddContact message.
    \\    // // * Define the required behavior.
    \\    // var addContactBehavior = try receive_channels.AddContact.initBehavior();
    \\    // errdefer {
    \\    //     allocator.destroy(messenger);
    \\    // }
    \\    // addContactBehavior.implementor = messenger;
    \\    // addContactBehavior.receiveFn = Messenger.receiveAddContact;
    \\    // // * Subscribe in order to receive the AddContact messages.
    \\    // try receive_channels.AddContact.subscribe(addContactBehavior);
    \\    // errdefer {
    \\    //     allocator.destroy(messenger);
    \\    // }
    \\
    \\    return messenger;
    \\}
    \\
;
