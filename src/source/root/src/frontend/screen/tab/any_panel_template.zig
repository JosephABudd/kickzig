const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    tab_name: []const u8,

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.screen_name);
        self.allocator.free(self.tab_name);
        self.allocator.destroy(self);
    }

    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        // screen_name
        var size: usize = std.mem.replacementSize(u8, template, "{{ screen_name }}", self.screen_name);
        const with_screen_name: []u8 = try self.allocator.alloc(u8, size);
        defer self.allocator.free(with_screen_name);
        _ = std.mem.replace(u8, template, "{{ screen_name }}", self.screen_name, with_screen_name);
        // tab_name
        size = std.mem.replacementSize(u8, with_screen_name, "{{ tab_name }}", self.tab_name);
        const with_tab_name: []u8 = try self.allocator.alloc(u8, size);
        _ = std.mem.replace(u8, with_screen_name, "{{ tab_name }}", self.tab_name, with_tab_name);
        return with_tab_name;
    }
};

pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, tab_name: []const u8) !*Template {
    var self: *Template = try allocator.create(Template);
    self.tab_name = try allocator.alloc(u8, tab_name.len);
    errdefer {
        allocator.destroy(self);
    }
    @memcpy(@constCast(self.tab_name), tab_name);
    self.screen_name = try allocator.alloc(u8, screen_name.len);
    errdefer {
        allocator.free(self.tab_name);
        allocator.destroy(self);
    }
    @memcpy(@constCast(self.screen_name), screen_name);
    self.allocator = allocator;
    return self;
}
const template =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const _lock_ = @import("lock");
    \\const _messenger_ = @import("messenger.zig");
    \\const _widget_ = @import("widget");
    \\const Tab = _widget_.Tab;
    \\const Tabs = _widget_.Tabs;
    \\const _various_ = @import("various");
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\
    \\// KICKZIG TODO:
    \\// Remember. Defers happen in reverse order.
    \\// When updating panel state.
    \\//     self.lock();
    \\//     defer self.unlock(); //  2nd defer: Unlocks.
    \\//     defer self.refresh(); // 1st defer: Refreshes the main view.
    \\//     // DO THE UPDATES.
    \\
    \\/// {{ tab_name }} panel.
    \\/// This panel is the content for the {{ tab_name }} tab.
    \\pub const Panel = struct {
    \\    allocator: std.mem.Allocator, // For persistant state data.
    \\    lock: *_lock_.ThreadLock, // For persistant state data.
    \\    window: *dvui.Window,
    \\    main_view: *MainView,
    \\    tabs: *Tabs,
    \\    tab: *Tab,
    \\    messenger: *_messenger_.Messenger,
    \\    exit: ExitFn,
    \\    container: ?*_various_.Container,
    \\
    \\    state: *State,
    \\
    \\    pub const State = struct {
    \\        allocator: std.mem.Allocator,
    \\
    \\        tab_label: ?[]const u8,
    \\        heading: ?[]const u8,
    \\        message: ?[]const u8,
    \\
    \\        pub fn init(
    \\            allocator: std.mem.Allocator,
    \\            tab_label: []const u8,
    \\            heading: ?[]const u8,
    \\            message: ?[]const u8,
    \\        ) !*State {
    \\            var self = try allocator.create(State);
    \\            self.allocator = allocator;
    \\
    \\            self.tab_label = null;
    \\            self.heading = null;
    \\            self.message = null;
    \\
    \\            try self.set(tab_label, heading, message);
    \\            errdefer self.deinit();
    \\            return self;
    \\        }
    \\
    \\        pub fn initFromState(
    \\            allocator: std.mem.Allocator,
    \\            from: *State,
    \\        ) !*State {
    \\            var label: []const u8 = undefined;
    \\            if (from.tab_label) |tab_label| {
    \\                label = tab_label;
    \\            } else {
    \\                label = "{{ tab_name }}";
    \\            }
    \\            return State.init(allocator, label, from.heading, from.message);
    \\        }
    \\
    \\        pub fn deinit(self: *State) void {
    \\            if (self.tab_label) |member| {
    \\                self.allocator.free(member);
    \\            }
    \\            if (self.heading) |member| {
    \\                self.allocator.free(member);
    \\            }
    \\            if (self.message) |member| {
    \\                self.allocator.free(member);
    \\            }
    \\            self.allocator.destroy(self);
    \\        }
    \\
    \\        pub fn setContainer(self: *State, container: ?*_various_.Container) void {
    \\            self.container = container;
    \\        }
    \\
    \\        pub fn setFromState(
    \\            self: *State,
    \\            from: *State,
    \\        ) !void {
    \\            return self.set(from.tab_label, from.heading, from.message);
    \\        }
    \\
    \\        pub fn set(
    \\            self: *State,
    \\            new_tab_label: ?[]const u8,
    \\            new_heading: ?[]const u8,
    \\            new_message: ?[]const u8,
    \\        ) !void {
    \\            if (new_tab_label) |tab_label| {
    \\                if (self.tab_label) |self_tab_label| {
    \\                    self.allocator.free(self_tab_label);
    \\                }
    \\                self.tab_label = try self.allocator.alloc(u8, tab_label.len);
    \\                errdefer self.tab_label = null;
    \\                @memcpy(@constCast(self.tab_label.?), tab_label);
    \\            }
    \\            if (new_heading) |heading| {
    \\                if (self.heading) |self_heading| {
    \\                    self.allocator.free(self_heading);
    \\                }
    \\                self.heading = try self.allocator.alloc(u8, heading.len);
    \\                errdefer self.heading = null;
    \\                @memcpy(@constCast(self.heading.?), heading);
    \\            }
    \\            if (new_message) |message| {
    \\                if (self.message) |self_message| {
    \\                    self.allocator.free(self_message);
    \\                }
    \\                self.message = try self.allocator.alloc(u8, message.len);
    \\                errdefer self.message = null;
    \\                @memcpy(@constCast(self.message.?), message);
    \\            }
    \\        }
    \\    };
    \\
    \\    /// labelFn returns the tab label.
    \\    /// The caller does not own the return value;
    \\    pub fn labelFn(implementor: *anyopaque) anyerror![]const u8 {
    \\        var self: *Panel = @alignCast(@ptrCast(implementor));
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        return self.state.tab_label.?;
    \\    }
    \\
    \\    /// setStateFn sets the panel's state.
    \\    pub fn setStateFn(implementor: *anyopaque, state_ptr: *anyopaque) anyerror!void {
    \\        var self: *Panel = @alignCast(@ptrCast(implementor));
    \\        const from_state: *State = @alignCast(@ptrCast(state_ptr));
    \\        return self.setState(from_state);
    \\    }
    \\
    \\    /// refresh only if this panel is showing and this screen is showing.
    \\    pub fn refreshFn(implementor: *anyopaque) void {
    \\        var self: *Panel = @alignCast(@ptrCast(implementor));
    \\        self.refresh();
    \\    }
    \\
    \\    pub fn deinitFn(implementor: *anyopaque) void {
    \\        var self: *Panel = @alignCast(@ptrCast(implementor));
    \\        return self.deinit();
    \\    }
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        self.lock.deinit();
    \\        self.state.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// frame this panel.
    \\    /// Layout, Draw, Handle user events.
    \\    /// The arena allocator is for building this frame. Not for state.
    \\    pub fn frameFn(implementor: *anyopaque, arena: std.mem.Allocator) anyerror!void {
    \\        var self: *Panel = @alignCast(@ptrCast(implementor));
    \\        _ = arena;
    \\
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        // The content area for a tab's content.
    \\        var scroll = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
    \\        defer scroll.deinit();
    \\
    \\        // Row 1 example: The screen's name.
    \\        try dvui.labelNoFmt(@src(), "{{ screen_name }} Screen.", .{ .font_style = .title });
    \\
    \\        // Row 2 example: This panel's name.
    \\        {
    \\            var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
    \\            defer row.deinit();
    \\
    \\            try dvui.labelNoFmt(@src(), "Panel Name: ", .{ .font_style = .heading });
    \\            try dvui.labelNoFmt(@src(), "{{ tab_name }}", .{});
    \\        }
    \\
    \\        // Row 3: A button which closes this tab.
    \\        if (try dvui.button(@src(), "Close.", .{}, .{})) {
    \\            try self.closeTab();
    \\        }
    \\
    \\        // Row 4: A button which opens another tab.
    \\        // if (try dvui.button(@src(), "OK Modal Screen.", .{}, .{})) {
    \\        //     const ok_args = try OKModalParams.init(self.allocator, "Hello World!", "This is the OK modal popped from the HelloWorld screen.");
    \\        //     self.main_view.showOK(ok_args);
    \\        // }
    \\
    \\    }
    \\
    \\    pub fn closeTab(self: *Panel) !void {
    \\        self.tabs.removeTab(self.tab);
    \\    }
    \\
    \\    /// refresh only if this panel is showing and this screen is showing.
    \\    pub fn refresh(self: *Panel) void {
    \\        if (self.tabs.isSelected(self.tab)) {
    \\            self.main_view.refresh{{ screen_name }}();
    \\        }
    \\    }
    \\
    \\    /// setState sets the panel's state.
    \\    pub fn setState(self: *Panel, from_state: *State) !void {
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        const changed: bool = std.mem.eql(u8, from_state.tab_label.?, self.state.tab_label.?);
    \\        try self.state.setFromState(from_state);
    \\        if (changed) {
    \\            self.tab.refresh();
    \\        }
    \\    }
    \\};
    \\
    \\/// The Panel owns param state.
    \\pub fn init(
    \\    allocator: std.mem.Allocator,
    \\    state: *Panel.State,
    \\    main_view: *MainView,
    \\    tabs: *Tabs,
    \\    messenger: *_messenger_.Messenger,
    \\    exit: ExitFn,
    \\    window: *dvui.Window,
    \\) !*Panel {
    \\    var panel: *Panel = try allocator.create(Panel);
    \\    panel.lock = try _lock_.init(allocator);
    \\    errdefer {
    \\        state.deinit();
    \\        allocator.destroy(panel);
    \\    }
    \\    panel.state = try Panel.State.initFromState(allocator, state);
    \\    errdefer {
    \\        panel.lock.deinit();
    \\        state.deinit();
    \\        allocator.destroy(panel);
    \\    }
    \\    panel.allocator = allocator;
    \\    panel.main_view = main_view;
    \\    panel.tabs = tabs;
    \\    panel.messenger = messenger;
    \\    panel.exit = exit;
    \\    panel.window = window;
    \\
    \\    return panel;
    \\}
;
