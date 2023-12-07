const std = @import("std");
const fmt = std.fmt;
const strings = @import("strings");

pub const Template = struct {
    allocator: std.mem.Allocator,
    channel_name: *strings.UTF8,

    pub fn init(allocator: std.mem.Allocator, name: []const u8) !*Template {
        var data: *Template = try allocator.create(Template);
        data.channel_name = try allocator.alloc(u8, name.len);
        errdefer allocator.destroy(data);
        @memcpy(data.channel_name, name);
        data.allocator = allocator;
        return data;
    }

    pub fn deinit(self: *Template) void {
        self.channel_name.deinit();
        self.allocator.destroy(self);
    }

    pub fn content(self: *Template) ![]const u8 {
        // Replace {{copy}} with the message name.
        const copy: []const u8 = self.channel_name.copy();
        defer self.allocator.free(copy);
        var replacement_size: usize = try std.mem.replacementSize(u8, template, "{{copy}}", copy);
        var with_channel_name: []u8 = try self.allocator.alloc(replacement_size);
        std.mem.replace(u8, template, "{{copy}}", copy);
        return with_channel_name;
    }
};

const template =
    \\/// This channel dispatches the "{{copy}}" message to it's subscribers.
    \\/// Any messenger can send an "{{copy}}" message by calling .send.
    \\/// This file was generated by kickzig when you added the "{{copy}}" message.
    \\/// It will be removed when you remove the "{{copy}}" message.
    \\/// DO NOT EDIT THIS FILE.
    \\const std = @import("std");
    \\
    \\pub const _message_ = @import("message").{{copy}};
    \\
    \\/// Behavior is call-backs and state.
    \\/// .receiveFn is a call-back, a function that receives the message.
    \\/// .implementor implements the recieveFn.
    \\pub const Behavior = struct {
    \\    receiveFn: *const fn (implementor: *anyopaque, message: *_message_.Message) void,
    \\    implementor: *anyopaque,
    \\};
    \\
    \\pub const Group = struct {
    \\    allocator: std.mem.Allocator = undefined,
    \\    members: std.AutoHashMap(*anyopaque, *Behavior),
    \\
    \\    /// initBehavior constructs an empty Behavior.
    \\    pub fn initBehavior(self: *Group) !*Behavior {
    \\        return self.allocator.create(Behavior);
    \\    }
    \\
    \\    pub fn deinit(self: *Group) void {
    \\        self.members.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// subscribe adds a receiver of the message to the Group.
    \\    /// The receiver must implement Behavior.
    \\    pub fn subscribe(self: *Group, cb: *Behavior) !void {
    \\        try self.members.put(cb.implementor, cb);
    \\    }
    \\
    \\    /// unsubscribe removes a subscriber from the Group.
    \\    /// Returns true if anything was removed.
    \\    pub fn unsubscribe(self: *Group, caller: *anyopaque) bool {
    \\        if (self.members.getEntry(caller)) |entry| {
    \\            var behavior: *Behavior = @ptrCast(entry.value_ptr.*);
    \\            self.allocator.destroy(behavior);
    \\            return self.members.remove(caller);
    \\        }
    \\    }
    \\
    \\    /// send dispatches the message to the subscribers in Group.
    \\    /// It takes control of the message and deinits it.
    \\    /// Receivers can safely resend the same message.
    \\    pub fn send(self: *Group, message: *_message_.Message) !void {
    \\        return self.dispatchThread(message);
    \\    }
    \\
    \\    fn dispatchThread(self: *Group, message: *_message_.Message) !void {
    \\        var thread = try std.Thread.spawn(.{ .allocator = self.allocator }, dispatchDeinit, .{ self.members, message });
    \\        std.Thread.detach(thread);
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
    \\};
    \\
;