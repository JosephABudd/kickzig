pub const content: []const u8 =
    \\const std = @import("std");
    \\
    \\const Container = @import("container.zig").Container;
    \\const ContainerLabel = @import("container.zig").ContainerLabel;
    \\const Counter = @import("counter").Counter;
    \\
    \\pub const Content = struct {
    \\    allocator: std.mem.Allocator,
    \\    counter: *Counter,
    \\
    \\    implementor: *anyopaque,
    \\    deinit_fn: *const fn (implementor: *anyopaque) void,
    \\    will_frame_fn: *const fn (implementor: *anyopaque) bool,
    \\    frame_fn: *const fn (implementor: *anyopaque, arena: std.mem.Allocator) anyerror!void,
    \\    label_fn: *const fn (implementor: *anyopaque, arena: std.mem.Allocator) anyerror!*ContainerLabel,
    \\    set_container_fn: *const fn (implementor: *anyopaque, container: *Container) anyerror!void,
    \\
    \\    // param implementor is owned by the Content.
    \\    pub fn init(
    \\        allocator: std.mem.Allocator,
    \\        implementor: *anyopaque,
    \\        deinit_fn: *const fn (implementor: *anyopaque) void,
    \\        frame_fn: *const fn (implementor: *anyopaque, arena: std.mem.Allocator) anyerror!void,
    \\        label_fn: *const fn (implementor: *anyopaque, arena: std.mem.Allocator) anyerror!*ContainerLabel,
    \\        will_frame_fn: *const fn (implementor: *anyopaque) bool,
    \\        set_container_fn: *const fn (implementor: *anyopaque, container: *Container) anyerror!void,
    \\    ) !*Content {
    \\        var self: *Content = try allocator.create(Content);
    \\        self.counter = try Counter.init(allocator);
    \\        errdefer allocator.destroy(self);
    \\        _ = self.counter.inc();
    \\        self.allocator = allocator;
    \\
    \\        self.implementor = implementor;
    \\
    \\        self.deinit_fn = deinit_fn;
    \\        self.frame_fn = frame_fn;
    \\        self.label_fn = label_fn;
    \\        self.will_frame_fn = will_frame_fn;
    \\        self.set_container_fn = set_container_fn;
    \\
    \\        return self;
    \\    }
    \\
    \\    // deinit does not deinit self.implementor.
    \\    // Content does not own self.implementor.
    \\    // implementor must deinit itself.
    \\    pub fn deinit(self: *Content) void {
    \\        if (self.counter.dec() > 0) {
    \\            return;
    \\        }
    \\        self.counter.deinit();
    \\        self.deinit_fn(self.implementor);
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    pub fn frame(self: *Content, arena: std.mem.Allocator) anyerror!void {
    \\        return self.frame_fn(self.implementor, arena);
    \\    }
    \\    pub fn label(self: *Content, allocator: std.mem.Allocator) anyerror!*ContainerLabel {
    \\        return self.label_fn(self.implementor, allocator);
    \\    }
    \\    pub fn willFrame(self: *Content) bool {
    \\        return self.will_frame_fn(self.implementor);
    \\    }
    \\    pub fn setContainer(self: *Content, container: *Container) !void {
    \\        return self.set_container_fn(self.implementor, container);
    \\    }
    \\
    \\    pub fn copy(self: *Content) *Content {
    \\        _ = self.counter.inc();
    \\        return self;
    \\    }
    \\};
;
