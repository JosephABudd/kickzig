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
        return std.fmt.allocPrint(self.allocator, template, .{self.message_name});
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

/// message name {0s}
const template =
    \\/// This file was generated by kickzig when you added the "{0s}" message.
    \\/// This file will be removed by kickzig if you remove the "{0s}" message.
    \\/// The "{0s}" message is:
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
    \\/// The "{0s}" message is:
    \\/// * sent from the back-end to the front-end only.
    \\/// The back-end will:
    \\/// 1. init this message.
    \\/// 2. set the back-end payload.
    \\/// 3. send the message to the front-end.
    \\/// The front-end:
    \\/// 1. will receive the message and process the data in the back-end payload.
    \\/// 2. WILL NOT RETURN THE MESSAGE TO THE BACK-END.
    \\const std = @import("std");
    \\const Counter = @import("counter").Counter;
    \\const ScreenTags = @import("framers").ScreenTags;
    \\
    \\// FrontendPayload is the "{0s}" message from the front-end to the back-end.
    \\/// KICKZIG TODO: Add your own front-end payload fields and methods.
    \\/// KICKZIG TODO: Customize pub const Settings for your fields.
    \\/// KICKZIG TODO: Customize fn init(...), fn deinit(...) and pub fn set(...) for your fields.
    \\pub const FrontendPayload = struct {{
    \\    allocator: std.mem.Allocator,
    \\    is_set: bool,
    \\
    \\    // screen_tag is the sender's screen tag.
    \\    // When messengers from multiple screens can send and receive this message,
    \\    //  you will only want the sender handling things like messages to the user.
    \\    // For this reason all screen messengers import the const ScreenTags.
    \\    screen_tag: ?ScreenTags,
    \\
    \\    pub const Settings = struct {{
    \\        screen_tag: ?ScreenTags = null,
    \\    }};
    \\
    \\    fn init(allocator: std.mem.Allocator) !*FrontendPayload {{
    \\        var self: *FrontendPayload = try allocator.create(FrontendPayload);
    \\        self.allocator = allocator;
    \\        self.is_set = false;
    \\
    \\        self.screen_tag = null;
    \\
    \\        return self;
    \\    }}
    \\
    \\    fn deinit(self: *FrontendPayload) void {{
    \\        self.allocator.destroy(self);
    \\    }}
    \\
    \\    // Returns an error if already set.
    \\    pub fn set(self: *FrontendPayload, values: Settings) !void {{
    \\        if (self.is_set) {{
    \\            return error.{0s}FrontendPayloadAlreadySet;
    \\        }}
    \\        self.is_set = true;
    \\        if (values.screen_tag) |value| {{
    \\            self.screen_tag = value;
    \\        }}
    \\    }}
    \\}};
    \\
    \\// BackendPayload is the "{0s}" message from the back-end to the front-end.
    \\/// KICKZIG TODO: Add your own back-end payload fields and methods.
    \\/// KICKZIG TODO: Customize pub const Settings for your fields.
    \\/// KICKZIG TODO: Customize fn init(...), fn deinit(...) and pub fn set(...) for your fields.
    \\pub const BackendPayload = struct {{
    \\    allocator: std.mem.Allocator = undefined,
    \\    is_set: bool,
    \\
    \\    // The member user_error_message is presented as an example.
    \\    user_error_message: ?[]const u8 = null,
    \\
    \\    pub const Settings = struct {{
    \\        user_error_message: ?[]const u8 = null,
    \\    }};
    \\
    \\    fn init(allocator: std.mem.Allocator) !*BackendPayload {{
    \\        var self: *BackendPayload = try allocator.create(BackendPayload);
    \\        self.allocator = allocator;
    \\        self.user_error_message = null;
    \\        return self;
    \\    }}
    \\
    \\    fn deinit(self: *BackendPayload) void {{
    \\        if (self.user_error_message) |user_error_message| {{
    \\            self.allocator.free(user_error_message);
    \\        }}
    \\        self.allocator.destroy(self);
    \\    }}
    \\
    \\    // Returns an error if already set.
    \\    pub fn set(self: *BackendPayload, values: Settings) !void {{
    \\        if (self.is_set) {{
    \\            return error.{0s}BackendPayloadAlreadySet;
    \\        }}
    \\        self.is_set = true;
    \\        if (values.user_error_message) |user_error_message| {{
    \\            self.user_error_message = try self.allocator.alloc(u8, user_error_message.len);
    \\            @memcpy(@constCast(self.user_error_message.?), user_error_message);
    \\        }}
    \\    }}
    \\}};
    \\
    \\/// This is the "{0s}" message.
    \\pub const Message = struct {{
    \\    allocator: std.mem.Allocator,
    \\    count_pointers: *Counter,
    \\    frontend_payload: *FrontendPayload,
    \\    backend_payload: *BackendPayload,
    \\
    \\    /// init creates an original message.
    \\    pub fn init(allocator: std.mem.Allocator) !*Message {{
    \\        var self: *Message = try allocator.create(Message);
    \\        self.frontend_payload = try FrontendPayload.init(allocator);
    \\        errdefer {{
    \\            allocator.destroy(self);
    \\        }}
    \\        self.backend_payload = try BackendPayload.init(allocator);
    \\        errdefer {{
    \\            self.frontend_payload.deinit();
    \\            allocator.destroy(self);
    \\        }}
    \\        self.count_pointers = try Counter.init(allocator);
    \\        errdefer {{
    \\            self.backend_payload.deinit();
    \\            self.frontend_payload.deinit();
    \\            allocator.destroy(self);
    \\        }}
    \\        _ = self.count_pointers.inc();
    \\        self.allocator = allocator;
    \\        return self;
    \\    }}
    \\
    \\    // deinit does not deinit until self is the final pointer to Message.
    \\    pub fn deinit(self: *Message) void {{
    \\        if (self.count_pointers.dec() > 0) {{
    \\            // There are more pointers.
    \\            // See fn copy.
    \\            return;
    \\        }}
    \\        // This is the last existing pointer.
    \\        self.count_pointers.deinit();
    \\        self.allocator.destroy(self);
    \\    }}
    \\
    \\    /// KICKZIG TODO:
    \\    /// copy pretends to create and return a copy of the message.
    \\    /// The dispatcher sends a copy to each receiveFn.
    \\    /// Each receiveFn owns the message copy and must deinit it.
    \\    /// The back-end receiveFn must only send a copy to the front-end.
    \\    /// Back-end Messenger Example:
    \\    /// var return_copy = message.copy() catch |err| {{
    \\    ///     self.exit(@src(), err, "message.copy()");
    \\    /// }};
    \\    /// // Set the back-end payload.
    \\    /// return_copy.backend_payload.set(.{{.name = record.name}}) catch |err| {{
    \\    ///     self.exit(@src(), err, "return_copy.backend_payload.set(.{{.name = record.name}})");
    \\    /// }};
    \\    /// // Send the message copy to the front-end.
    \\    /// // The channel's send function owns the copy and will deinit it.
    \\    /// self.send_channels.{0s}.send(message) catch |err| {{
    \\    ///     self.exit(@src(), err, "self.send_channels.{0s}.send(message)");
    \\    /// }};
    \\    ///
    \\    /// In this case copy does not return a copy of itself.
    \\    /// In order to save memory space, it really only
    \\    /// * increments the count of the number of pointers to this message.
    \\    /// * returns self.
    \\    /// See deinit().
    \\    pub fn copy(self: *Message) !*Message {{
    \\        _ = self.count_pointers.inc();
    \\        return self;
    \\    }}
    \\}};
    \\
;
