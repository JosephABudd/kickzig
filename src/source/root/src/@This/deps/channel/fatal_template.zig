pub const content =
    \\/// This channel dispatches the "fatal" message.
    \\/// The "fatal" message is only sent by the back-end to the front-end.
    \\/// Any back-end messenger can send the "fatal" message to the back-end by calling send.
    \\/// If the back-end sends a fatal message to the front end, then the front-end will initialize a gracefull shutdown of the entire app.
    \\/// This file was generated by kickzig when you initialized the framework.
    \\/// DO NOT EDIT THIS FILE.
    \\const std = @import("std");
    \\
    \\pub const _message_ = @import("message").Fatal;
    \\
    \\/// Behavior is call-backs and state.
    \\/// .implementor implements the recieveFn.
    \\/// .receiveFn is a call-back, a function that receives the message.
    \\pub const Behavior = struct {
    \\    implementor: *anyopaque,
    \\    receiveFn: *const fn (implementor: *anyopaque, message: *_message_.Message) void,
    \\};
    \\
    \\pub const Group = struct {
    \\    allocator: std.mem.Allocator = undefined,
    \\    members: std.AutoHashMap(*anyopaque, *Behavior),
    \\    _sent: bool,
    \\    _message: *_message_.Message,
    \\
    \\    pub fn initBehavior(self: *Group) !*Behavior {
    \\        return self.allocator.create(Behavior);
    \\    }
    \\
    \\    pub fn deinit(self: *Group) void {
    \\        // deint each Behavior.
    \\        var iterator = self.members.iterator();
    \\        while (iterator.next()) |entry| {
    \\            var behavior: *Behavior = @ptrCast(entry.value_ptr.*);
    \\            self.allocator.destroy(behavior);
    \\        }
    \\        self.members.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// subscribe adds a Behavior that will receiver the message to the Group.
    \\    /// Group owns the Behavior not the caller.
    \\    /// So if there is an error the Behavior is destroyed.
    \\    pub fn subscribe(self: *Group, behavior: *Behavior) !void {
    \\        self.members.put(behavior.implementor, behavior) catch |err| {
    \\            self.allocator.destroy(behavior);
    \\            return err;
    \\        };
    \\    }
    \\
    \\    /// unsubscribe removes a Behavior from the Group.
    \\    /// It also destroys the Behavior.
    \\    /// Returns true if anything was removed.
    \\    pub fn unsubscribe(self: *Group, caller: *anyopaque) bool {
    \\        if (self.members.getEntry(caller)) |entry| {
    \\            var behavior: *Behavior = @ptrCast(entry.value_ptr.*);
    \\            self.allocator.destroy(behavior);
    \\            return self.members.remove(caller);
    \\        }
    \\    }
    \\
    \\    /// sendError dispatches the error in a message to the subscribers in Group.
    \\    /// It takes control of the message and deinits it after the last receive fn returns.
    \\    /// It does not take control of err which is allocated on the stack.
    \\    pub fn sendError(self: *Group, err: anyerror) void {
    \\        if (self._sent) {
    \\            return;
    \\        }
    \\        self._sent = true;
    \\        var message: *_message_.Message = self._message;
    \\        message.setError(err);
    \\        dispatchDeinit(self.members, message);
    \\    }
    \\
    \\    fn dispatchNoThread(self: *Group, message: *_message_.Message) !void {
    \\        dispatchDeinit(self.members, message);
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
    \\    channel._message = try _message_.init(allocator, error.Null);
    \\    errdefer {
    \\        channel.members.deinit();
    \\        allocator.destroy(channel);
    \\    }
    \\    channel._sent = false;
    \\    return channel;
    \\}
    \\
    \\fn dispatchDeinit(members: std.AutoHashMap(*anyopaque, *Behavior), message: *_message_.Message) void {
    \\    message.reinit();
    \\    defer message.deinit();
    \\
    \\    var iterator = members.iterator();
    \\    while (iterator.next()) |entry| {
    \\        var behavior: *Behavior = entry.value_ptr.*;
    \\        behavior.receiveFn(behavior.implementor, message);
    \\    }
    \\}
    \\
;
