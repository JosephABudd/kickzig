const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    message_name: []const u8,

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.message_name);
        self.allocator.destroy(self);
    }

    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        // Replace {{ message_name }} with the message name.
        const replacement_size: usize = std.mem.replacementSize(u8, template, "{{ message_name }}", self.message_name);
        const with_message_name: []u8 = try self.allocator.alloc(u8, replacement_size);
        _ = std.mem.replace(u8, template, "{{ message_name }}", self.message_name, with_message_name);
        return with_message_name;
    }
};

// The caller owns the returned value.
pub fn init(allocator: std.mem.Allocator, name: []const u8) !*Template {
    var data: *Template = try allocator.create(Template);
    data.message_name = try allocator.alloc(u8, name.len);
    errdefer allocator.destroy(data);
    @memcpy(@constCast(data.message_name), name);
    data.allocator = allocator;
    return data;
}

const template =
    \\/// This is the back-end's "{{ message_name }}" message handler.
    \\/// 1 This messenger can receive the "{{ message_name }}" message from the front-end.
    \\///     and then if needed, send the "{{ message_name }}" message back to the front-end.
    \\/// 2 This messenger can also be triggered to send a default "{{ message_name }}" message to the front-end.
    \\/// The "{{ message_name }}" message is at deps/message/src/{{ message_name }}.zig.
    \\/// This file was generated by kickzig when you added the "{{ message_name }}" message.
    \\/// This file will be removed by kickzig when you remove the "{{ message_name }}" message.
    \\/// KICKZIG TODO: Customize fn receiveFn.
    \\const std = @import("std");
    \\
    \\const _channel_ = @import("channel");
    \\const _message_ = @import("message");
    \\const _startup_ = @import("startup");
    \\
    \\pub const Messenger = struct {
    \\    allocator: std.mem.Allocator,
    \\    send_channels: *_channel_.BackendToFrontend,
    \\    receive_channels: *_channel_.FrontendToBackend,
    \\    exit: *const fn (user_message: []const u8) void,
    \\
    \\    pub fn deinit(self: *Messenger) void {
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// receive{{ message_name }}Fn receives the "{{ message_name }}" message from the front-end.
    \\    /// It implements _channel_.FrontendToBackend.{{ message_name }}.Behavior.receiveFn found in deps/channel/fronttoback/{{ message_name }}.zig.
    \\    /// The receive{{ message_name }}Fn owns the message it receives.
    \\    pub fn receive{{ message_name }}Fn(implementor: *anyopaque, message: *_message_.{{ message_name }}.Message) ?anyerror {
    \\        var self: *Messenger = @alignCast(@ptrCast(implementor));
    \\        defer message.deinit();
    \\
    \\        self.receiveJob(message) catch |err| {
    \\            // Fatal error.
    \\            self.exit(@errorName(err));
    \\            return err;
    \\        };
    \\        // Send the send the reply to the front-end if required.
    \\        self.send_channels.{{ message_name }}.send(message) catch |err| {
    \\            // Fatal error.
    \\            self.exit(@errorName(err));
    \\            return err;
    \\        };
    \\
    \\        // No errors so return null;
    \\        return null;
    \\    }
    \\
    \\    /// trigger{{ message_name }}Fn builds and sends the "{{ message_name }}" message to the front-end.
    \\    /// It implements _channel_.trigger.{{ message_name }}.Behavior.triggerFn found in deps/channel/trigger/{{ message_name }}.zig.
    \\    pub fn trigger{{ message_name }}Fn(implementor: *anyopaque) ?anyerror {
    \\        var self: *Messenger = @alignCast(@ptrCast(implementor));
    \\
    \\        var message: *_message_.{{ message_name }}.Message = self.triggerJob() catch |err| {
    \\            // Fatal error.
    \\            self.exit(@errorName(err));
    \\            return err;
    \\        };
    \\        // Send the message back to the front-end.
    \\        // The sender owns the message so never deinit the message.
    \\        self.send_channels.{{ message_name }}.send(message) catch |err| {
    \\            // Fatal error.
    \\            self.exit(@errorName(err));
    \\            return err;
    \\        };
    \\        // No errors so return null;
    \\        return null;
    \\    }
    \\
    \\    /// triggerJob creates message to send to the front-end.
    \\    /// Returns the processed message or an error.
    \\    /// KICKZIG TODO: Add the required functionality.
    \\    fn triggerJob(self: *Messenger) !*_message_.{{ message_name }}.Message {
    \\        _ = self;
    \\        // Create a message for the front-end.
    \\        // Set the message.backend_payload accordingly.
    \\        return error.KICKZIG_TODO_ADD_FUNCTIONALITY;
    \\    }
    \\
    \\    /// receiveJob fullfills the front-end's request.
    \\    /// Returns nothing or an error.
    \\    /// KICKZIG TODO: Add the required functionality.
    \\    fn receiveJob(self: *Messenger, message: *_message_.{{ message_name }}.Message) !void {
    \\        _ = self;
    \\        _ = message;
    \\        // Do something for the front-end.
    \\        // Set the message.backend_payload accordingly.
    \\        return error.KICKZIG_TODO_ADD_FUNCTIONALITY;
    \\    }
    \\};
    \\
    \\pub fn init(startup: _startup_.Backend) !*Messenger {
    \\    var messenger: *Messenger = try startup.allocator.create(Messenger);
    \\    messenger.allocator = startup.allocator;
    \\    messenger.send_channels = startup.send_channels;
    \\    messenger.receive_channels = startup.receive_channels;
    \\    var receive_behavior = try startup.receive_channels.{{ message_name }}.initBehavior();
    \\    errdefer {
    \\        messenger.deinit();
    \\    }
    \\    receive_behavior.implementor = messenger;
    \\    receive_behavior.receiveFn = &Messenger.receive{{ message_name }}Fn;
    \\    try startup.receive_channels.{{ message_name }}.subscribe(receive_behavior);
    \\    errdefer {
    \\        messenger.deinit();
    \\    }
    \\    var trigger_behavior = try startup.triggers.{{ message_name }}.initBehavior();
    \\    errdefer {
    \\        messenger.deinit();
    \\    }
    \\    trigger_behavior.implementor = messenger;
    \\    trigger_behavior.triggerFn = &Messenger.trigger{{ message_name }}Fn;
    \\    try startup.triggers.{{ message_name }}.subscribe(trigger_behavior);
    \\    errdefer {
    \\        messenger.deinit();
    \\    }
    \\    messenger.exit = startup.exit;
    \\    return messenger;
    \\}
    \\
;
