pub const content =
    \\const std = @import("std");
    \\const _startup_ = @import("startup");
    \\
    \\/// Behavior defines a behavior that must be implemented by members of Group.
    \\pub const Behavior = struct {
    \\    allocator: std.mem.Allocator,
    \\    // implementor is a pointer to the implementor of the Behavior.
    \\    implementor: *anyopaque,
    \\
    \\    // deinitFn deinits the implementor.
    \\    deinitFn: *const fn (implementor: *anyopaque) void,
    \\
    \\    // nameFn returns a framer's unique name.
    \\    nameFn: *const fn (self: *anyopaque) []const u8,
    \\
    \\    // goModalFn opens this screen as a modal view.
    \\    // It is called after the modal behavior is returned by fn Group.get(...).
    \\    // It is called before the modal Behavior is made current by fn Group.setCurrentBehavior(...).
    \\    goModalFn: ?*const fn (self: *anyopaque, args: *anyopaque) ?anyerror,
    \\
    \\    // frameFn implements a gui frame.
    \\    // It is called during the gui's framing event.
    \\    frameFn: *const fn (self: *anyopaque, allocator: std.mem.Allocator) ?anyerror,
    \\
    \\    // deinit the implementor and self.
    \\    pub fn deinit(self: *Behavior) void {
    \\        self.deinitFn(self.implementor);
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    pub fn isModal(self: *Behavior) bool {
    \\        if (self.goModalFn) |_| {
    \\            return true;
    \\        } else {
    \\            return false;
    \\        }
    \\    }
    \\};
    \\
    \\/// Group is a collection of Behavior implementations.
    \\pub const Group = struct {
    \\    allocator: std.mem.Allocator,
    \\    current: ?*Behavior,
    \\    members: std.StringHashMap(*Behavior),
    \\    behavior_stack: *BehaviorStack,
    \\    behavior_stack_index: usize,
    \\    exit: *const fn (user_message: []const u8) void,
    \\
    \\    /// initBehavior constructs a Behavior.
    \\    /// The Group has control over the Bahavior after subscribed.
    \\    pub fn initBehavior(
    \\        self: *Group,
    \\        implementor: *anyopaque,
    \\        deinitFn: *const fn (implementor: *anyopaque) void,
    \\        nameFn: *const fn (self: *anyopaque) []const u8,
    \\        frameFn: *const fn (self: *anyopaque, allocator: std.mem.Allocator) ?anyerror,
    \\        goModalFn: ?*const fn (self: *anyopaque, args: *anyopaque) ?anyerror,
    \\    ) !*Behavior {
    \\        var behavior: *Behavior = try self.allocator.create(Behavior);
    \\        behavior.allocator = self.allocator;
    \\        behavior.implementor = implementor;
    \\        behavior.deinitFn = deinitFn;
    \\        behavior.nameFn = nameFn;
    \\        behavior.frameFn = frameFn;
    \\        behavior.goModalFn = goModalFn;
    \\        return behavior;
    \\    }
    \\
    \\    pub fn deinit(self: *Group) void {
    \\        var iter = self.members.iterator();
    \\        while (iter.next()) |member| {
    \\            member.value_ptr.*.deinit();
    \\        }
    \\        self.members.deinit();
    \\        self.behavior_stack.deinit();
    \\    }
    \\
    \\    pub fn frame(self: *Group, arena: std.mem.Allocator) !void {
    \\        if (self.current) |current| {
    \\            if (current.frameFn(current.implementor, arena)) |err| {
    \\                return err;
    \\            }
    \\        }
    \\    }
    \\
    \\    /// subscribe adds a Behavior to the group.
    \\    /// Group has complete control of behavior and will deinit it.
    \\    pub fn subscribe(self: *Group, behavior: *Behavior) !void {
    \\        var name = behavior.nameFn(behavior.implementor);
    \\        if (name.len == 0) {
    \\            return error.BehaviorNameEmpty;
    \\        }
    \\        try self.members.put(name, behavior);
    \\    }
    \\
    \\    /// unsubscribe removes a named Behavior from Group.
    \\    /// Group has complete control of behavior and will deinit it.
    \\    pub fn unsubscribe(self: *Group, name: []const u8) !void {
    \\        var behavior: *Behavior = try self.get(name);
    \\        self.members.remove(name);
    \\        behavior.deinit();
    \\    }
    \\
    \\    /// get returns a Behavior.
    \\    pub fn get(self: *Group, name: []const u8) !*Behavior {
    \\        if (self.members.get(name)) |behavior| {
    \\            return behavior;
    \\        } else {
    \\            std.log.debug("BehaviorNameNotFound get: {s}", .{name});
    \\            return error.BehaviorNameNotFound;
    \\        }
    \\    }
    \\
    \\    /// setCurrent sets the current behavior.
    \\    /// Param name is the name of the Behavior.
    \\    /// The Behavior will frame in the next frame.
    \\    pub fn setCurrent(self: *Group, name: []const u8) !void {
    \\        if (self.members.get(name)) |behavior| {
    \\            try self.setCurrentBehavior(behavior);
    \\        } else {
    \\            std.log.debug("BehaviorNameNotFound set: {s}", .{name});
    \\            return error.BehaviorNameNotFound;
    \\        }
    \\    }
    \\
    \\    // isModal returns if the current Behavior is modal.
    \\    pub fn isModal(self: *Group) bool {
    \\        if (self.current) |current| {
    \\            return current.isModal();
    \\        } else {
    \\            return false;
    \\        }
    \\    }
    \\
    \\    /// setCurrentBehavior sets the current behavior.
    \\    /// Param behavior is the Behavior.
    \\    /// The Behavior will frame in the next frame.
    \\    pub fn setCurrentBehavior(self: *Group, behavior: *Behavior) !void {
    \\        if (self.current == null) {
    \\            // There is no current behavior.
    \\            if (behavior.isModal()) {
    \\                // Can't start with a modal behavior.
    \\                return error.CanStartWithModalBehavior;
    \\            }
    \\            // Set the current behavior.
    \\            self.current = behavior;
    \\        } else if (self.current.?.isModal()) {
    \\            // The user is currently viewing a modal screen.
    \\            // Replace the last behavior pushed onto the stack.
    \\            try self.behavior_stack.replacePush(behavior);
    \\        } else {
    \\            // Replace the current behavior.
    \\            if (behavior.isModal()) {
    \\                // Save the current Behavior onto the stack.
    \\                if (self.current) |current| {
    \\                    try self.behavior_stack.push(current);
    \\                }
    \\            }
    \\            self.current = behavior;
    \\        }
    \\    }
    \\
    \\    /// getCurrent returns the current Behavior.
    \\    pub fn getCurrent(self: *Group) ?*Behavior {
    \\        return self.current;
    \\    }
    \\
    \\    /// popCurrent
    \\    /// 1. Pops the previous Behavior from the stack.
    \\    /// 2. Sets the previous Behavior as the new current Behavior.
    \\    /// The Behavior will frame in the next frame.
    \\    pub fn popCurrent(self: *Group) !void {
    \\        // Try to get the previous current behavior.
    \\        self.current = try self.behavior_stack.pop();
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, exit: *const fn (user_message: []const u8) void) !*Group {
    \\    var group: *Group = try allocator.create(Group);
    \\    group.behavior_stack = try BehaviorStack.init(allocator);
    \\    errdefer allocator.destroy(group);
    \\    group.allocator = allocator;
    \\    group.members = std.StringHashMap(*Behavior).init(allocator);
    \\    group.behavior_stack_index = 0;
    \\    group.current = null;
    \\    group.exit = exit;
    \\    return group;
    \\}
    \\
    \\const BehaviorStackCap: usize = 5;
    \\
    \\const BehaviorStack = struct {
    \\    allocator: std.mem.Allocator,
    \\    list: []*Behavior,
    \\    list_index: usize,
    \\
    \\    fn init(allocator: std.mem.Allocator) !*BehaviorStack {
    \\        var behavior_stack: *BehaviorStack = try allocator.create(BehaviorStack);
    \\        behavior_stack.list = try allocator.alloc(*Behavior, 5);
    \\        errdefer allocator.destroy(behavior_stack);
    \\        behavior_stack.allocator = allocator;
    \\        behavior_stack.list_index = 0;
    \\        return behavior_stack;
    \\    }
    \\
    \\    fn deinit(self: *BehaviorStack) void {
    \\        // The BehaviorStack does not control the behaviors.
    \\        // They are controlled by the Group.
    \\        self.allocator.free(self.list);
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    fn inc_cap(self: *BehaviorStack) !void {
    \\        const cap: usize = self.list.len + BehaviorStackCap;
    \\        var new_list = try self.allocator.alloc(*Behavior, cap);
    \\        for (self.list, 0..) |behavior, i| {
    \\            new_list[i] = behavior;
    \\        }
    \\        self.allocator.free(self.list);
    \\        self.list = new_list;
    \\    }
    \\
    \\    fn push(self: *BehaviorStack, behavior: *Behavior) !void {
    \\        if (self.list_index == self.list.len) {
    \\            try self.inc_cap();
    \\        }
    \\        self.list[self.list_index] = behavior;
    \\        self.list_index += 1;
    \\    }
    \\
    \\    fn replacePush(self: *BehaviorStack, behavior: *Behavior) !void {
    \\        if (self.list_index > 0) {
    \\            self.list[self.list_index - 1] = behavior;
    \\        }
    \\    }
    \\
    \\    fn pop(self: *BehaviorStack) !*Behavior {
    \\        if (self.list_index == 0) {
    \\            return error.EmptyStack;
    \\        }
    \\        self.list_index -= 1;
    \\        var behavior: *Behavior = self.list[self.list_index];
    \\        return behavior;
    \\    }
    \\};
;
