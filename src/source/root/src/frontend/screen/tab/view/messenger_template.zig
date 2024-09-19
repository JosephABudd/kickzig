const std = @import("std");

pub fn content(allocator: std.mem.Allocator, screen_name: []const u8, panel_name: []const u8) ![]const u8 {
    return std.fmt.allocPrint(allocator, template, .{ screen_name, panel_name });
}

// screen name {0s}
// any panel name {1s}
const template: []const u8 =
    \\const std = @import("std");
    \\
    \\const _channel_ = @import("channel");
    \\const _framers_ = @import("framers");
    \\const _message_ = @import("message");
    \\const _modal_params_ = @import("modal_params");
    \\const _panels_ = @import("../panels.zig");
    \\
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\const PanelTags = _panels_.PanelTags;
    \\const ScreenTags = @import("framers").ScreenTags;
    \\const ScreenOptions = @import("../screen.zig").Options;
    \\const Tab = @import("widget").Tab;
    \\const Tabs = @import("widget").Tabs;
    \\
    \\pub const Messenger = struct {{
    \\    allocator: std.mem.Allocator,
    \\
    \\    tabs: *Tabs,
    \\    main_view: *MainView,
    \\    send_channels: *_channel_.FrontendToBackend,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\    exit: ExitFn,
    \\
    \\    pub fn init(
    \\        allocator: std.mem.Allocator,
    \\        tabs: *Tabs,
    \\        main_view: *MainView,
    \\        send_channels: *_channel_.FrontendToBackend,
    \\        receive_channels: *_channel_.BackendToFrontend,
    \\        exit: ExitFn,
    \\        screen_options: ScreenOptions,
    \\    ) !*Messenger {{
    \\        var messenger: *Messenger = try allocator.create(Messenger);
    \\        messenger.allocator = allocator;
    \\        messenger.tabs = tabs;
    \\        messenger.main_view = main_view;
    \\        messenger.send_channels = send_channels;
    \\        messenger.receive_channels = receive_channels;
    \\        messenger.exit = exit;
    \\        // KICKZIG TODO:
    \\        // If you have added custom fields to Messenger,
    \\        //  then you may want to set them with screen_options.
    \\        _ = screen_options;
    \\    
    \\        // For a messenger to receive a message, the messenger must:
    \\        //
    \\        // 1. Implement the behavior of the message's channel.
    \\        // var fubarBehavior = try receive_channels.Fubar.initBehavior();
    \\        // errdefer {{
    \\        //     allocator.destroy(messenger);
    \\        // }}
    \\        // fubarBehavior.implementor = messenger;
    \\        // fubarBehavior.receiveFn = Messenger.receiveFubar;
    \\        //
    \\        // 2. Subscribe to the Fubar channel in order to receive the Fubar messages.
    \\        // try receive_channels.Fubar.subscribe(fubarBehavior);
    \\        // errdefer {{
    \\        //     allocator.destroy(messenger);
    \\        // }}
    \\    
    \\        return messenger;
    \\    }}
    \\
    \\    pub fn deinit(self: *Messenger) void {{
    \\        self.allocator.destroy(self);
    \\    }}
    \\
    \\    // Below is an example to send a Fubar message.
    \\    // For this example, the {1s} panel made this request.
    \\    // // sendFubar is called by a tab's panel.
    \\    // pub fn sendFubar(
    \\    //     self: *Messenger,
    \\    //     tab: *_tabs_.Tab,
    \\    //     panel: *anyopaque,
    \\    //     panel_tag: PanelTags,
    \\    //     stuff: []const u8,
    \\    //     other_stuff: usize,
    \\    // ) !void {{
    \\    //     var msg: *_message_.Fubar = _message_.Fubar.init(
    \\    //         self.allocator,
    \\    //
    \\    //         .{0s}, // This screen's _framers_.ScreenTag.
    \\    //         tab,   // The tab of the panel making this request.
    \\    //         panel, // The panel making this request.
    \\    //
    \\    //         stuff, // Stuff to send.
    \\    //         other_stuff, // more stuff to send.
    \\    //     ) catch |err| {{
    \\    //         self.exit(@src(), err, "unable to init a Fubar message");
    \\    //         return err;
    \\    //     }};
    \\    //
    \\    //     self.send_channels.Fubar.send(msg) catch |err| {{
    \\    //         self.exit(@src(), err, "{0s} unable to send a Fubar message");
    \\    //         return err;
    \\    //     }};
    \\    // }}
    \\
    \\    // Below is an example of a receive function.
    \\    // // receiveFubar receives the Fubar message.
    \\    // // This fn implements the behavior required by receive_channels.Fubar.
    \\    // pub fn receiveFubar(self: *Messenger, implementor: *anyopaque, message: *_message_.Fubar.Message) anyerror!void {{
    \\    //     var self: *Messenger = @alignCast(@ptrCast(implementor));
    \\    //     // A message receive function always owns the message.
    \\    //     defer message.deinit();
    \\    //
    \\    //     // message.frontend_payload is the struct holding data sent by this messenger to the backend.
    \\    //     // It include but is not limited to the screen_tag and the tab and its panel.
    \\    //
    \\    //     // Check the screen tag.
    \\    //     const screen_tag: ScreenTags = @enumFromInt(message.frontend_payload.screen_tag);
    \\    //     if (screen_tag != .{0s}) {{
    \\    //         // This message was sent by some other screen.
    \\    //         // I may not want to use it in this screen.
    \\    //         return;
    \\    //     }}
    \\    //
    \\    //     // Check the tab. It is a *anyopaque in the message.
    \\    //     // If the tab is no longer open then ignore this message.
    \\    //     // Also this tab could be from another instance of this screen.
    \\    //     const tab: *Tab = @alignCast(@ptrCast(message.frontend_payload.tab));
    \\    //     if (!self.tabs.hasTab(tab)) {{
    \\    //         return;
    \\    //     }}
    \\    //
    \\    //     // No user error.
    \\    //     // Pass on the information contained in the message to panels.
    \\    //     // The messenger needs to know what panel or panels need the information from the message.
    \\    //     // The message must have pointers to those panels since tabs and their panels are added and removed at any time.
    \\    //     // For this example, the {1s} panel made this request.
    \\    //     const panel: *_panels_.{1s} = @alignCast(@ptrCast(message.frontend_payload.panel));
    \\    //     // fn setState will handles the error correctly.
    \\    //     try self.panels.{1s}.setState(
    \\    //         {{
    \\    //             .something = message.BackendPayload.something,
    \\    //         }},
    \\    //     );
    \\    // }}
    \\}};
    \\
;
