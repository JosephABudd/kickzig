pub const content =
    \\// This is the "Initialize" message.
    \\// The "Initialize" message is sent by the front-end to the back-end when the front-end is finally up and running.
    \\// It signals to the back-end that the front-end has started and is now ready to receive messages from the back-end.
    \\// This file was generated by kickzig when you initialized the framework.
    \\// DO NOT EDIT THIS FILE.
    \\const std = @import("std");
    \\
    \\pub const Message = struct {
    \\    _allocator: std.mem.Allocator = undefined,
    \\    _inits: i32 = 0,
    \\
    \\    pub fn deinit(self: *Message) void {
    \\        self._inits -= 1;
    \\        if (self._inits == 0) {
    \\            self._allocator.destroy(self);
    \\        }
    \\    }
    \\
    \\    pub fn reinit(self: *Message) void {
    \\        self._inits += 1;
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator) !*Message {
    \\    var message: *Message = try allocator.create(Message);
    \\    message._allocator = allocator;
    \\    message._inits = 0;
    \\    return message;
    \\}
    \\
;
