const std = @import("std");

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

pub fn init(allocator: std.mem.Allocator, name: []const u8) !*Template {
    var data: *Template = try allocator.create(Template);
    data.message_name = try allocator.alloc(u8, name.len);
    errdefer allocator.destroy(data);
    @memcpy(@constCast(data.message_name), name);
    data.allocator = allocator;
    return data;
}

const template =
    \\/// This file was generated by kickzig when you added the "{{ message_name }}" message.
    \\/// This file will be removed by kickzig if you remove the "{{ message_name }}" message.
    \\/// The "{{ message_name }}" message is:
    \\/// * sent from the front-end to the back-end
    \\/// * with the back-end possibly returning the message back to the front-end.
    \\/// The front-end will:
    \\/// 1. init this message.
    \\/// 2. set the front-end payload.
    \\/// 3. send the message to the back-end.
    \\/// The back-end will:
    \\/// 1. receive the message and do something with the data in the front-end payload.
    \\/// 2. The back-end may also:
    \\///    i.   make a return copy.
    \\///    ii.  set the back-end payload.
    \\///    iii. send the return copy back to the front-end.
    \\/// The front-end upon receiving the returned message:
    \\///    i.  will process the data in the back-end payload.
    \\///    ii. WILL NOT RETURN THE MESSAGE TO THE BACK-END.
    \\const std = @import("std");
    \\const Counter = @import("counter").Counter;
    \\
    \\// FrontendPayload is the "{{ message_name }}" message from the front-end to the back-end.
    \\/// KICKZIG TODO: Add your own front-end payload fields and methods.
    \\/// KICKZIG TODO: Customize pub const Settings for your fields.
    \\/// KICKZIG TODO: Customize fn init(...), fn deinit(...) and pub fn set(...) for your fields.
    \\pub const FrontendPayload = struct {
    \\    allocator: std.mem.Allocator,
    \\    is_set: bool,
    \\
    \\    // The member foobar is presented as an example.
    \\    foobar: ?i64,
    \\
    \\    pub const Settings = struct {
    \\        foobar: ?i64,
    \\    };
    \\
    \\    fn init(allocator: std.mem.Allocator) !*FrontendPayload {
    \\        var self: *FrontendPayload = try allocator.create(FrontendPayload);
    \\        self.allocator = allocator;
    \\        self.is_set = false;
    \\        self.foobar = null;
    \\        return self;
    \\    }
    \\
    \\    fn deinit(self: *FrontendPayload) void {
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    // Returns an error if already set.
    \\    pub fn set(self: *FrontendPayload, values: Settings) !void {
    \\        if (self.is_set) {
    \\            return error.{{ message_name }}FrontendPayloadAlreadySet;
    \\        }
    \\        self.is_set = true;
    \\        if (values.foobar) |foobar| {
    \\            self.foobar = foobar;
    \\        }
    \\    }
    \\};
    \\
    \\// BackendPayload is the "{{ message_name }}" message from the back-end to the front-end.
    \\/// KICKZIG TODO: Add your own back-end payload fields and methods.
    \\/// KICKZIG TODO: Customize pub const Settings for your fields.
    \\/// KICKZIG TODO: Customize fn init(...), fn deinit(...) and pub fn set(...) for your fields.
    \\pub const BackendPayload = struct {
    \\    allocator: std.mem.Allocator = undefined,
    \\    is_set: bool,
    \\
    \\    // The member user_error_message is presented as an example.
    \\    user_error_message: ?[]const u8,
    \\
    \\    pub const Settings = struct {
    \\        user_error_message: ?[]const u8,
    \\    };
    \\
    \\    fn init(allocator: std.mem.Allocator) !*BackendPayload {
    \\        var self: *BackendPayload = try allocator.create(BackendPayload);
    \\        self.allocator = allocator;
    \\        self.user_error_message = null;
    \\        return self;
    \\    }
    \\
    \\    fn deinit(self: *BackendPayload) void {
    \\        if (self.user_error_message) |user_error_message| {
    \\            self.allocator.free(user_error_message);
    \\        }
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    // Returns an error if already set.
    \\    pub fn set(self: *BackendPayload, values: Settings) !void {
    \\        if (self.is_set) {
    \\            return error.{{ message_name }}BackendPayloadAlreadySet;
    \\        }
    \\        self.is_set = true;
    \\        if (values.user_error_message) |user_error_message| {
    \\            self.user_error_message = self.allocator.alloc(u8, user_error_message.len);
    \\            @memcpy(@constCast(self.user_error_message), user_error_message);
    \\        }
    \\    }
    \\};
    \\
    \\/// This is the "{{ message_name }}" message.
    \\pub const Message = struct {
    \\    allocator: std.mem.Allocator,
    \\    count_pointers: *Counter,
    \\    frontend_payload: *FrontendPayload,
    \\    backend_payload: *BackendPayload,
    \\
    \\    // deinit does not deinit until self is the final pointer to Message.
    \\    pub fn deinit(self: *Message) void {
    \\        std.log.debug(" == Init msg.deinit()", .{});
    \\        if (self.count_pointers.dec() > 0) {
    \\            // There are more pointers.
    \\            // See fn copy.
    \\            return;
    \\        }
    \\        // This is the last existing pointer.
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// KICKZIG TODO:
    \\    /// copy pretends to create and return a copy of the message.
    \\    /// The dispatcher sends a copy to each receiveFn.
    \\    /// Each receiveFn owns the message copy and must deinit it.
    \\    /// The back-end receiveFn must only send a copy to the front-end.
    \\    /// Back-end Messenger Example:
    \\    /// var return_copy = message.copy() catch |err| {
    \\    ///     self.exit(@errorName(err));
    \\    /// };
    \\    /// // Set the back-end payload.
    \\    /// return_copy.backend_payload.set(.{.name = record.name}) catch |err| {
    \\    ///     self.exit(@errorName(err));
    \\    /// };
    \\    /// // Send the message copy to the front-end.
    \\    /// // The channel's send function owns the copy and will deinit it.
    \\    /// self.send_channels.{{ message_name }}.send(message) catch |err| {
    \\    ///     self.exit(@errorName(err));
    \\    /// };
    \\    ///
    \\    /// In this case copy does not return a copy of itself.
    \\    /// In order to save memory space, it really only
    \\    /// * increments the count of the number of pointers to this message.
    \\    /// * returns self.
    \\    /// See deinit().
    \\    pub fn copy(self: *Message) !*Message {
    \\        _ = self.count_pointers.inc();
    \\        return self;
    \\    }
    \\};
    \\
    \\/// init creates an original message.
    \\pub fn init(allocator: std.mem.Allocator) !*Message {
    \\    var self: *Message = try allocator.create(Message);
    \\    self.frontend_payload = try FrontendPayload.init(allocator);
    \\    errdefer {
    \\        allocator.destroy(self);
    \\    }
    \\    self.backend_payload = try BackendPayload.init(allocator);
    \\    errdefer {
    \\        self.frontend_payload.deinit();
    \\        allocator.destroy(self);
    \\    }
    \\    self.count_pointers = try Counter.init(allocator);
    \\    errdefer {
    \\        self.backend_payload.deinit();
    \\        self.frontend_payload.deinit();
    \\        allocator.destroy(self);
    \\    }
    \\    _ = self.count_pointers.inc();
    \\    self.allocator = allocator;
    \\    return self;
    \\}
;
