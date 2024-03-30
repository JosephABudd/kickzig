pub const content =
    \\const std = @import("std");
    \\
    \\const _channel_ = @import("channel");
    \\const _framers_ = @import("framers");
    \\const _message_ = @import("message");
    \\const _modal_params_ = @import("modal_params");
    \\const _panels_ = @import("panels.zig");
    \\const Tabs = @import("widget").Tabs;
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\// const ScreenTags = @import("framers").ScreenTags;
    \\
    \\pub const Messenger = struct {
    \\    allocator: std.mem.Allocator,
    \\
    \\    main_view: *MainView,
    \\    tabs: *Tabs,
    \\    send_channels: *_channel_.FrontendToBackend,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\    exit: ExitFn,
    \\
    \\    pub fn deinit(self: *Messenger) void {
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    // Below is an example to send a Fubar message.
    \\    // // sendFubar is called by a tab's panel.
    \\    // pub fn sendFubar(self: *Messenger, tab *_tabs_.Tab, stuff: []const u8, other_stuff: usize) !void {
    \\    //     var msg: *_message_.Fubar = _message_.Fubar.init(
    \\    //         self.allocator,
    \\    //         .VTAB, // This screen's _framers_.ScreenTag.
    \\    //         tab, // The tab who's panel is making this request.
    \\    //         stuff,
    \\    //         other_stuff,
    \\    //     ) catch |err| {
    \\    //         self.exit(@src(), err, "unable to init a Fubar message");
    \\    //         return err;
    \\    //     };
    \\    //
    \\    //     self.send_channels.Fubar.send(msg) catch |err| {
    \\    //         self.exit(@src(), err, "unable to send a Fubar message");
    \\    //         return err;
    \\    //     };
    \\    // }
    \\
    \\    // Below is an example of a receive function.
    \\    // // receiveFubar receives the Fubar message.
    \\    // // This fn implements the behavior required by receive_channels.Fubar.
    \\    // pub fn receiveFubar(self: *Messenger, implementor: *anyopaque, message: *_message_.Fubar.Message) ?anyerror {
    \\    //     var self: *Messenger = @alignCast(@ptrCast(implementor));
    \\    //     defer message.deinit();
    \\    //     _ = self;
    \\    //
    \\    //     if (message.frontend_payload.screen_tag != .VTAB) {
    \\    //         // This message was sent by some other screen.
    \\    //         // I may not want to use it in this screen.
    \\    //         return;
    \\    //     }
    \\    //
    \\    //     // If the tab is no longer open then ignore this message.
    \\    //     if (!self.tabs.hasTab(message.frontend_payload.tab)) {
    \\    //         return;
    \\    //     }
    \\    //
    \\    //     // Figure out which panel the tab is using.
    \\    //     const panel_tag: _panels_.PanelTags = @enumFromInt(tab.panelTabAsInt());
    \\    //     switch (tab.panelTabAsInt()) {
    \\    //         .Add => {
    \\    //             // The tab uses the Add panel.
    \\    //
    \\    //             // Create a state to send to the Add panel.
    \\    //             const state: *panel.State = _Add_.Panel.State.init(
    \\    //                 self.allocator,
    \\    //                 message.tab_label,
    \\    //                 message.heading,
    \\    //                 message.message,
    \\    //             ) catch |err| {
    \\    //                 self.exit(@src(), err, "unable to make _Add_.Panel.State");
    \\    //                 return err;
    \\    //             };
    \\    //
    \\    //             // Set the Add panel's state.
    \\    //             tab.setState(state) catch |err| {
    \\    //                 self.exit(@src(), err, "unable to set tab's _Add_.Panel.State");
    \\    //                 return err;
    \\    //             };
    \\    //         },
    \\    //     }
    \\    //
    \\    //     // No error so return null;
    \\    //     return null;
    \\    // }
    \\};
    \\
    \\pub fn init(
    \\    allocator: std.mem.Allocator,
    \\    tabs: *Tabs,
    \\    main_view: *MainView,
    \\    send_channels: *_channel_.FrontendToBackend,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\    exit: ExitFn,
    \\) !*Messenger {
    \\    var messenger: *Messenger = try allocator.create(Messenger);
    \\    messenger.allocator = allocator;
    \\    messenger.tabs = tabs;
    \\    messenger.main_view = main_view;
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
