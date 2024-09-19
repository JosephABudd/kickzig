const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    channel_name: []const u8,

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.channel_name);
        self.allocator.destroy(self);
    }

    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        // Replace {{ channel_name }} with the message name.
        const replacement_size: usize = std.mem.replacementSize(u8, template, "{{ channel_name }}", self.channel_name);
        const with_channel_name: []u8 = try self.allocator.alloc(u8, replacement_size);
        _ = std.mem.replace(u8, template, "{{ channel_name }}", self.channel_name, with_channel_name);
        return with_channel_name;
    }
};

pub fn init(allocator: std.mem.Allocator, name: []const u8) !*Template {
    var data: *Template = try allocator.create(Template);
    data.channel_name = try allocator.alloc(u8, name.len);
    errdefer allocator.destroy(data);
    @memcpy(@constCast(data.channel_name), name);
    data.allocator = allocator;
    return data;
}

const template =
    \\/// Through this trigger interface:
    \\/// 1. Any back-end messengers can trigger the back-end {{ channel_name }} messengers to send its message.
    \\/// This file was generated by kickzig when you added the "{{ channel_name }}" message.
    \\/// It will be removed when you remove the "{{ channel_name }}" message.
    \\const std = @import("std");
    \\
    \\pub const _message_ = @import("message").{{ channel_name }};
    \\const ExitFn = @import("various").ExitFn;
    \\
    \\/// Behavior is an implementor and it's message trigger fn.
    \\/// The behavior is by default, only implemented by the back-end's {{ channel_name }} messenger.
    \\/// .implementor implements the triggerFn.
    \\/// .triggerFn
    \\/// - creates a {{ channel_name }} message.
    \\/// - sends that message to the front-end by calling self.send_channels.{{ channel_name }}.send(message);.
    \\/// - returns any errors.
    \\pub const Behavior = struct {
    \\    implementor: *anyopaque,
    \\    triggerFn: *const fn (implementor: *anyopaque) anyerror!void,
    \\};
    \\
    \\pub const Group = struct {
    \\    allocator: std.mem.Allocator = undefined,
    \\    members: std.AutoHashMap(*anyopaque, *Behavior),
    \\    exit: ExitFn,
    \\
    \\    /// initBehavior constructs an empty Behavior.
    \\    pub fn initBehavior(self: *Group) !*Behavior {
    \\        return self.allocator.create(Behavior);
    \\    }
    \\
    \\    pub fn init(allocator: std.mem.Allocator, exit: ExitFn) !*Group {
    \\        var channel: *Group = try allocator.create(Group);
    \\        channel.members = std.AutoHashMap(*anyopaque, *Behavior).init(allocator);
    \\        channel.allocator = allocator;
    \\        channel.exit = exit;
    \\        return channel;
    \\    }
    \\
    \\    pub fn deinit(self: *Group) void {
    \\        // deint each Behavior.
    \\        var iterator = self.members.iterator();
    \\        while (iterator.next()) |entry| {
    \\            const behavior: *Behavior = @ptrCast(entry.value_ptr.*);
    \\            self.allocator.destroy(behavior);
    \\        }
    \\        self.members.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// subscribe adds a back-end messenger's Behavior that will receiver the message to the Group.
    \\    /// Group owns the Behavior not the caller.
    \\    /// So if there is an error the Behavior is destroyed.
    \\    pub fn subscribe(self: *Group, behavior: *Behavior) !void {
    \\        self.members.put(behavior.implementor, behavior) catch |err| {
    \\            self.allocator.destroy(behavior);
    \\            return err;
    \\        };
    \\    }
    \\
    \\    /// unsubscribe removes a back-end messenger's Behavior from the Group.
    \\    /// It also destroys the Behavior.
    \\    /// Returns true if anything was removed.
    \\    pub fn unsubscribe(self: *Group, caller: *anyopaque) bool {
    \\        if (self.members.getEntry(caller)) |entry| {
    \\            const behavior: *Behavior = @ptrCast(entry.value_ptr.*);
    \\            self.allocator.destroy(behavior);
    \\            return self.members.remove(caller);
    \\        }
    \\    }
    \\
    \\    /// trigger causes back-end messenger's Behaviors in Group to send their version of {{ channel_name }} message to the front-end.
    \\    /// It dispatches the trigger in another thread.
    \\    /// It returns after spawning the thread while the thread runs.
    \\    pub fn trigger(self: *Group) !void {
    \\        const thread = try std.Thread.spawn(.{ .allocator = self.allocator }, Group.dispatchTrigger, .{self});
    \\        std.Thread.detach(thread);
    \\    }
    \\
    \\    fn dispatchTrigger(self: *Group) void {
    \\        var iterator = self.members.iterator();
    \\        while (iterator.next()) |entry| {
    \\            var behavior: *Behavior = entry.value_ptr.*;
    \\            // The triggerFn must handle it's own error.
    \\            // If the triggerFn returns an error then stop.
    \\            behavior.triggerFn(behavior.implementor) catch {
    \\                // Error: Stop dispatching.
    \\                return;
    \\            };
    \\        }
    \\    }
    \\};
    \\
;
