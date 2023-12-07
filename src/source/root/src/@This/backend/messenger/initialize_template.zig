pub const content =
    \\/// This is the back-end's "initialize" message handler.
    \\/// It receives and processes the "initialize" message.
    \\/// The "initialize" message is at deps/message/src/initialize.zig.
    \\/// This file was generated by kickzig when you initialized this framework.
    \\/// KICKZIG TODO: Customize fn receiveFn.
    \\const std = @import("std");
    \\
    \\const _channel_ = @import("channel");
    \\const _message_ = @import("message");
    \\
    \\pub const Messenger = struct {
    \\    allocator: std.mem.Allocator,
    \\    send_channels: *_channel_.Channels,
    \\
    \\    pub fn deinit(self: *Messenger) void {
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// receiveFn receives an "initialize" message from the front-end.
    \\    /// It implements _channel_.Channels.initialize.Behavior.receiveFn found in deps/channel/src/initialize.zig.
    \\    /// receiveFn does not control param initialize_message because only message dispatchers control messages.
    \\    /// For that reason:
    \\    /// * data from param initialize_message must be copied to be preserved.
    \\    /// * param initialize_message can safely be sent back to the front-end.
    \\    pub fn receiveFn(self_ptr: *anyopaque, initialize_message: *_message_.Initialize.Message) void {
    \\        var self: *Messenger = @alignCast(@ptrCast(self_ptr));
    \\        _ = self;
    \\        _ = initialize_message;
    \\
    \\        // KICKZIG TODO: If your app requires, send startup messages to the frontend.
    \\        // Example:
    \\        //
    \\        // var important_startup_message: *_message_.Important.Message = _message_.Important.init(self.allocator) catch |err| {
    \\        //     self.send_channels.Fatal.sendError(err);
    \\        //     return;
    \\        // };
    \\        // defer important_startup_message.deinit();
    \\        // self.send_channels.Important.send(important_startup_message) catch |err| {
    \\        //     self.send_channels.Fatal.sendError(err);
    \\        //     return;
    \\        // };
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, send_channels: *_channel_.Channels, receive_channels: *_channel_.Channels) !*Messenger {
    \\    var messenger: *Messenger = try allocator.create(Messenger);
    \\    messenger.allocator = allocator;
    \\    messenger.send_channels = send_channels;
    \\    var behavior = try receive_channels.Initialize.initBehavior();
    \\    errdefer {
    \\        messenger.deinit();
    \\    }
    \\    behavior.implementor = messenger;
    \\    behavior.receiveFn = &Messenger.receiveFn;
    \\    try receive_channels.Initialize.subscribe(behavior);
    \\    errdefer {
    \\        messenger.deinit();
    \\    }
    \\    return messenger;
    \\}
    \\
;
