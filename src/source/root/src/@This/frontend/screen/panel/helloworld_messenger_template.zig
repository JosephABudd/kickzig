pub const content =
    \\const std = @import("std");
    \\
    \\const _message_ = @import("message");
    \\const _channel_ = @import("channel");
    \\const _framers_ = @import("framers");
    \\const _modal_params_ = @import("modal_params");
    \\const OKModalParams = _modal_params_.OK;
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
    \\    // Below is an example of a send function.
    \\    // sendFubar is provided as an example.
    \\    // It sends the Fubar message.
    \\    // pub fn sendFubar(self: *Messenger, some_text: []const u8) !void {
    \\    //     var message: *_message_.Fubar.Message = try _message_.Fubar.init(self.allocator);
    \\    //     try message.frontend_payload.set(.{.foobar = some_text});
    \\    //     try self.send_channels.Fubar.send(message);
    \\    // }
    \\
    \\    // Below is an example of a receive function.
    \\    // receiveFubar is provided as an example.
    \\    // It receives the Fubar message.
    \\    // It implements a behavior required by receive_channels.Fubar.
    \\    // pub fn receiveFubar(implementor: *anyopaque, message: *_message_.Fubar.Message) ?anyerror {
    \\    //     var self: *Messenger = @alignCast(@ptrCast(implementor));
    \\    //     _ = self;
    \\    //     _ = message;
    \\    //     // message.backend_payload is the struct holding the message from the backend.
    \\    //     if (message.backend_payload.error_message) |error_message| {
    \\    //         // There was an error so inform the user.
    \\    //         self.informError(error_message);
    \\    //         return error.receiveFubar;
    \\    //     }
    \\    //     // No error reported by the backend so process the message.
    \\    //     if (self.doSomething(message.something)) catch |err| {
    \\    //         self.exit(@errorName(err));
    \\    //         return error;
    \\    //     }
    \\    //     // No error so process the message.
    \\    //     self.panels.HelloWorld.setHeading(message.BackendPayload.something) catch |err| {
    \\    //         // An error while processing the message so exit.
    \\    //         self.exit(@errorName(err));
    \\    //         return err;
    \\    //     };
    \\    //     // No error so return null;
    \\    //     return null;
    \\    // }
    \\
    \\    fn informError(self: *Messenger, message: []const u8) void {
    \\        self.inform("Error", message);
    \\    }
    \\
    \\    fn informSuccess(self: *Messenger, message: []const u8) void {
    \\        self.inform("Success", message);
    \\    }
    \\
    \\    fn inform(self: *Messenger, title: []const u8, message: []const u8) void {
    \\        // Use the OK modal screen to inform the user.
    \\        var ok_modal = self.all_screens.get("OK") catch {
    \\            std.debug.print("The OK screen has gone missing!", .{});
    \\            return;
    \\        };
    \\        // Get the arguments for the OK modal screen.
    \\        const ok_args = try OKModalParams.init(
    \\            self.allocator,
    \\            title,
    \\            message,
    \\        ) catch |ok_args_err| {
    \\            std.debug.print("error OKModalParams.init {s}.", .{@errorName(ok_args_err)});
    \\            return;
    \\        };
    \\        // Open the OK modal screen.
    \\        if(ok_modal.goModalFn.?(ok_modal.implementor, ok_args)) |err| {
    \\            self.exit(@errorName(err));
    \\        }
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, all_panels: *_panels_.Panels, send_channels: *_channel_.FrontendToBackend, receive_channels: *_channel_.BackendToFrontend, exit: *const fn (user_message: []const u8) void) !*Messenger {
    \\    var messenger: *Messenger = try allocator.create(Messenger);
    \\    messenger.allocator = allocator;
    \\    messenger.all_screens = all_screens;
    \\    messenger.all_panels = all_panels;
    \\    messenger.send_channels = send_channels;
    \\    messenger.receive_channels = receive_channels;
    \\    messenger.exit = exit;
    \\
    \\    // For a messenger to receive a message, the messenger must:
    \\    //
    \\    // 1. Implement the behavior of the message's channel.
    \\    // var fubarBehavior = try receive_channels.Fubar.initBehavior();
    \\    // errdefer {
    \\    //     allocator.destroy(messenger);
    \\    // }
    \\    // fubarBehavior.implementor = messenger;
    \\    // fubarBehavior.receiveFn = Messenger.receiveFubar;
    \\    //
    \\    // 2. Subscribe to the Fubar channel in order to receive the Fubar messages.
    \\    // try receive_channels.Fubar.subscribe(fubarBehavior);
    \\    // errdefer {
    \\    //     allocator.destroy(messenger);
    \\    // }
    \\
    \\    return messenger;
    \\}
;
