pub const content =
    \\// This channel dispatches the initialize message.
    \\// The initialize message is sent by the front-end to the back-end when the front-end is finally up and running.
    \\// It signals to the back-end that the front-end has started and is now ready to receive messages from the back-end.
    \\// This file was generated by kickzig when you initialized the framework.
    \\// DO NOT EDIT THIS FILE.
    \\const std = @import("std");
    \\
    \\pub const _message_ = @import("message").Initialize;
    \\
    \\// Behavior is call-backs and state.
    \\// .receiveFn is a call-back, a function that receives the message.
    \\// .self is the state required for the call-back. It is the implementor of the recieveFn.
    \\pub const Behavior = struct {
    \\    receiveFn: *const fn (self: *anyopaque, message: *_message_.Message) void,
    \\    self: *anyopaque,
    \\};
    \\
    \\pub const Group = struct {
    \\    allocator: std.mem.Allocator = undefined,
    \\    members: std.AutoHashMap(*anyopaque, *Behavior),
    \\    _sent: bool,
    \\    _message: *_message_.Message,
    \\
    \\    // initBehavior constructs an empty Behavior.
    \\    pub fn initBehavior(self: *Group) !*Behavior {
    \\        return self.allocator.create(Behavior);
    \\    }
    \\
    \\    pub fn deinit(self: *Group) void {
    \\        self._message.deinit();
    \\        self.members.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    // subscribe adds a receiver of the message to the Group.
    \\    // The receiver must implement Behavior.
    \\    pub fn subscribe(self: *Group, cb: *Behavior) !void {
    \\        try self.members.put(cb.self, cb);
    \\    }
    \\
    \\    // unsubscribe removes a subscriber from the Group.
    \\    // Returns true if anything was removed.
    \\    pub fn unsubscribe(self: *Group, caller: *anyopaque) bool {
    \\        if (self.members.getEntry(caller)) |entry| {
    \\            var behavior: *Behavior = @ptrCast(entry.value_ptr.*);
    \\            self.allocator.destroy(behavior);
    \\            return self.members.remove(caller);
    \\        }
    \\    }
    \\
    \\    // send dispatches the message to the subscribers in Group.
    \\    // It takes control of the message and deinits it.
    \\    pub fn send(self: *Group) void {
    \\        if (self._sent) {
    \\            return;
    \\        }
    \\        self._sent = true;
    \\        var iterator = self.members.iterator();
    \\        while (iterator.next()) |entry| {
    \\            var behavior: *Behavior = entry.value_ptr.*;
    \\            behavior.receiveFn(behavior.self, self._message);
    \\        }
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator) !*Group {
    \\    var channel: *Group = try allocator.create(Group);
    \\    channel.allocator = allocator;
    \\    channel.members = std.AutoHashMap(*anyopaque, *Behavior).init(allocator);
    \\    errdefer {
    \\        allocator.destroy(channel);
    \\    }
    \\    channel._message = try _message_.init(allocator);
    \\    errdefer {
    \\        channel.members.deinit();
    \\        allocator.destroy(channel);
    \\    }
    \\    channel._sent = false;
    \\    return channel;
    \\}
    \\
;
