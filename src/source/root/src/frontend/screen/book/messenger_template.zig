pub const content =
    \\const std = @import("std");
    \\
    \\const _channel_ = @import("channel");
    \\const _framers_ = @import("framers");
    \\const _message_ = @import("message");
    \\const _modal_params_ = @import("modal_params");
    \\const _panels_ = @import("panels.zig");
    \\const ExitFn = @import("various").ExitFn;
    \\
    \\pub const Messenger = struct {
    \\    allocator: std.mem.Allocator,
    \\    arena: std.mem.Allocator,
    \\    all_screens: *_framers_.Screens,
    \\    all_panels: *_panels_.Panels,
    \\    send_channels: *_channel_.FrontendToBackend,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\    exit: ExitFn,
    \\
    \\    pub fn deinit(self: *Messenger) void {
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    // Below is an example of a receive function.
    \\    // // receiveGetBook is provided as an example.
    \\    // // It receives the GetBook message.
    \\    // // It implements a behavior required by receive_channels.GetBook.
    \\    // pub fn receiveGetBook(implementor: *anyopaque, message: *_message_.GetBook.Message) anyerror!void {
    \\    //     var self: *Messenger = @alignCast(@ptrCast(implementor));
    \\    //     defer message.deinit();
    \\    //     _ = self;
    \\    // }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Screens, send_channels: *_channel_.FrontendToBackend, receive_channels: *_channel_.BackendToFrontend, exit: ExitFn) !*Messenger {
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
    \\    // Below is an example of the messenger adding the behavior requried to receive the GetBook message.
    \\    // // The GetBook message.
    \\    // // * Define the required behavior.
    \\    // var getBookBehavior = try receive_channels.GetBook.initBehavior();
    \\    // errdefer {
    \\    //     allocator.destroy(messenger);
    \\    // }
    \\    // getBookBehavior.implementor = messenger;
    \\    // getBookBehavior.receiveFn = Messenger.receiveGetBook;
    \\    // // * Subscribe in order to receive the GetBook messages.
    \\    // try receive_channels.GetBook.subscribe(getBookBehavior);
    \\    // errdefer {
    \\    //     allocator.destroy(messenger);
    \\    // }
    \\
    \\    return messenger;
    \\}
    \\
;
