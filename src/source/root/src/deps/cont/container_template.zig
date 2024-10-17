pub const content: []const u8 =
    \\const std = @import("std");
    \\
    \\const Counter = @import("counter").Counter;
    \\
    \\pub const ContainerLabel = struct {
    \\    allocator: std.mem.Allocator,
    \\    badge: ?[]const u8 = null,
    \\    text: ?[]const u8 = null,
    \\    icons: ?[]const *Icon = null,
    \\    menu_items: ?[]const *MenuItem = null,
    \\
    \\    pub const Icon = struct {
    \\        allocator: std.mem.Allocator,
    \\        label: ?[]const u8,
    \\        tvg_bytes: []const u8,
    \\        implementor: ?*anyopaque,
    \\        state: ?*anyopaque,
    \\        call_back: ?*const fn (implementor: ?*anyopaque, state: ?*anyopaque) anyerror!void,
    \\
    \\        pub fn init(
    \\            allocator: std.mem.Allocator,
    \\            label: []const u8,
    \\            tvg_bytes: []const u8,
    \\            implementor: ?*anyopaque,
    \\            state: ?*anyopaque,
    \\            call_back: ?*const fn (implementor: ?*anyopaque, state: ?*anyopaque) anyerror!void,
    \\        ) !*Icon {
    \\            var self: *Icon = try allocator.create(Icon);
    \\            self.allocator = allocator;
    \\
    \\            self.label = try allocator.alloc(u8, label.len);
    \\            errdefer {
    \\                self.label = null;
    \\                self.deinit();
    \\            }
    \\            @memcpy(@constCast(self.label.?), label);
    \\            self.tvg_bytes = tvg_bytes;
    \\            self.implementor = implementor;
    \\            self.state = state;
    \\            self.call_back = call_back;
    \\
    \\            return self;
    \\        }
    \\
    \\        pub fn deinit(self: *Icon) void {
    \\            if (self.label) |member| {
    \\                self.allocator.free(member);
    \\            }
    \\            self.allocator.destroy(self);
    \\        }
    \\    };
    \\
    \\    pub const MenuItem = struct {
    \\        allocator: std.mem.Allocator,
    \\        label: ?[]const u8,
    \\        implementor: ?*anyopaque,
    \\        state: ?*anyopaque,
    \\        call_back: *const fn (implementor: ?*anyopaque, state: ?*anyopaque) anyerror!void,
    \\
    \\        pub fn init(
    \\            allocator: std.mem.Allocator,
    \\            label: []const u8,
    \\            implementor: ?*anyopaque,
    \\            state: ?*anyopaque,
    \\            call_back: *const fn (implementor: ?*anyopaque, state: ?*anyopaque) anyerror!void,
    \\        ) !*MenuItem {
    \\            var self: *MenuItem = try allocator.create(MenuItem);
    \\            self.allocator = allocator;
    \\
    \\            self.label = try allocator.alloc(u8, label.len);
    \\            errdefer {
    \\                self.label = null;
    \\                self.deinit();
    \\            }
    \\            @memcpy(@constCast(self.label.?), label);
    \\            self.implementor = implementor;
    \\            self.state = state;
    \\            self.call_back = call_back;
    \\
    \\            return self;
    \\        }
    \\
    \\        pub fn deinit(self: *MenuItem) void {
    \\            if (self.label) |member| {
    \\                self.allocator.free(member);
    \\            }
    \\            self.allocator.destroy(self);
    \\        }
    \\    };
    \\
    \\    pub fn init(
    \\        allocator: std.mem.Allocator,
    \\        badge: ?[]const u8,
    \\        text: ?[]const u8,
    \\        icons: ?[]const *Icon,
    \\        menu_items: ?[]const *MenuItem,
    \\    ) !*ContainerLabel {
    \\        var self = try allocator.create(ContainerLabel);
    \\        self.allocator = allocator;
    \\        self.text = null;
    \\        self.icons = null;
    \\        self.menu_items = null;
    \\        if (text) |param| {
    \\            self.text = try allocator.alloc(u8, param.len);
    \\            errdefer self.deinit();
    \\            @memcpy(@constCast(self.text.?), param);
    \\        }
    \\        if (icons) |param| {
    \\            self.icons = try allocator.alloc(*Icon, param.len);
    \\            errdefer self.deinit();
    \\            @memcpy(@constCast(self.icons.?), param);
    \\        }
    \\        if (menu_items) |param| {
    \\            self.menu_items = try allocator.alloc(*MenuItem, param.len);
    \\            errdefer self.deinit();
    \\            @memcpy(@constCast(self.menu_items.?), param);
    \\        }
    \\        self.badge = badge;
    \\        return self;
    \\    }
    \\
    \\    pub fn deinit(self: *ContainerLabel) void {
    \\        if (self.text) |t| {
    \\            self.allocator.free(t);
    \\        }
    \\        if (self.icons) |icons| {
    \\            for (icons) |icon| {
    \\                icon.deinit();
    \\            }
    \\            self.allocator.free(icons);
    \\        }
    \\        if (self.menu_items) |menu_items| {
    \\            for (menu_items) |menu_item| {
    \\                menu_item.deinit();
    \\            }
    \\            self.allocator.free(menu_items);
    \\        }
    \\        self.allocator.destroy(self);
    \\    }
    \\};
    \\
    \\pub const Container = struct {
    \\    allocator: std.mem.Allocator,
    \\    counter: *Counter,
    \\
    \\    implementor: *anyopaque,
    \\
    \\    /// close_fn
    \\    /// if implementor == MainView:
    \\    ///   * close_fn is null because app will close and deinit the implementor when app ends.
    \\    /// if implementor == a screen_pointers.ScreenPointers.???:
    \\    ///   * close_fn will self.container.close() because MainView is container.
    \\    ///   * MainView is not closable until the app ends as stated above.
    \\    /// if implementor is an instance of a screen_pointers.???:
    \\    ///   * close_fn will self.container.close();
    \\    /// if implementor is an instance of a Tab:
    \\    ///   * close_fn will:
    \\    ///     * remove the implementor (Tab) from it's Tabs.
    \\    ///     * delete all of the implementor's (Tab's) content.
    \\    ///     * deinit the implementor (Tab).
    \\    close_fn: ?*const fn (implementor: *anyopaque) void,
    \\
    \\    /// refresh_fn
    \\    /// implementor must call self.container.refresh_fn.
    \\    refresh_fn: *const fn (implementor: *anyopaque) void,
    \\
    \\    /// param implementor is not owned by the Content.
    \\    /// implementor owns itself.
    \\    pub fn init(
    \\        allocator: std.mem.Allocator,
    \\        implementor: *anyopaque,
    \\        close_fn: ?*const fn (implementor: *anyopaque) void,
    \\        refresh_fn: *const fn (implementor: *anyopaque) void,
    \\    ) !*Container {
    \\        var self: *Container = try allocator.create(Container);
    \\        self.counter = try Counter.init(allocator);
    \\        errdefer allocator.destroy(self);
    \\        _ = self.counter.inc();
    \\        self.allocator = allocator;
    \\
    \\        self.implementor = implementor;
    \\        self.close_fn = close_fn;
    \\        self.refresh_fn = refresh_fn;
    \\
    \\        return self;
    \\    }
    \\
    \\    /// deinit this Container only.
    \\    pub fn deinit(self: *Container) void {
    \\        if (self.counter.dec() > 0) {
    \\            return;
    \\        }
    \\        self.counter.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    pub fn container(self: *Container) *anyopaque {
    \\        return self.implementor;
    \\    }
    \\
    \\    pub fn isCloseable(self: *Container) bool {
    \\        return (self.close_fn != null);
    \\    }
    \\
    \\    /// closes this container or calls it's container's fn close.
    \\    /// If this container closes it will:
    \\    /// * remove itself.
    \\    /// * deinit it's content.
    \\    /// * deinit itself.
    \\    /// else it will call it's container's close.
    \\    pub fn close(self: *Container) void {
    \\        if (self.close_fn) |f| {
    \\            f(self.implementor);
    \\        }
    \\    }
    \\
    \\    // refresh refreshes the container's container.
    \\    pub fn refresh(self: *Container) void {
    \\        return self.refresh_fn(self.implementor);
    \\    }
    \\
    \\    pub fn copy(self: *Container) *Container {
    \\        _ = self.counter.inc();
    \\        return self;
    \\    }
    \\};
;
