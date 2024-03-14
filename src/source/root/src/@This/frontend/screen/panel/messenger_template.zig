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
        const size: usize = std.mem.replacementSize(u8, template, "{{screen_name}}", self.screen_name);
        const with_screen_name: []u8 = try self.allocator.alloc(u8, size);
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
    \\const _channel_ = @import("channel");
    \\const _message_ = @import("message");
    \\const _modal_params_ = @import("modal_params");
    \\const _panels_ = @import("panels.zig");
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\
    \\pub const Messenger = struct {
    \\    allocator: std.mem.Allocator,
    \\
    \\    main_view: *MainView,
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
    \\    // // receiveAddContact is provided as an example.
    \\    // // It receives the AddContact message.
    \\    // // It implements a behavior required by receive_channels.AddContact.
    \\    // pub fn receiveAddContact(implementor: *anyopaque, message: *_message_.AddContact.Message) ?anyerror {
    \\    //     var self: *Messenger = @alignCast(@ptrCast(implementor));
    \\    //     defer message.deinit();
    \\    //     _ = self;
    \\    //
    \\    //     // No error so return null;
    \\    //     return null;
    \\    // }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, main_view: *MainView, send_channels: *_channel_.FrontendToBackend, receive_channels: *_channel_.BackendToFrontend, exit: ExitFn) !*Messenger {
    \\    var messenger: *Messenger = try allocator.create(Messenger);
    \\    messenger.allocator = allocator;
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
