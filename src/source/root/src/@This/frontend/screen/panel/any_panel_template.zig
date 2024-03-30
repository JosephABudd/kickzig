const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    panel_name: []const u8,

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.screen_name);
        self.allocator.free(self.panel_name);
        self.allocator.destroy(self);
    }

    // content builds and returns the content.
    // The caller owns the return value.
    pub fn content(self: *Template) ![]const u8 {
        // screen_name
        var size: usize = std.mem.replacementSize(u8, template, "{{ screen_name }}", self.screen_name);
        const with_screen_name: []u8 = try self.allocator.alloc(u8, size);
        defer self.allocator.free(with_screen_name);
        _ = std.mem.replace(u8, template, "{{ screen_name }}", self.screen_name, with_screen_name);
        // panel_name
        size = std.mem.replacementSize(u8, with_screen_name, "{{ panel_name }}", self.panel_name);
        const with_panel_name: []u8 = try self.allocator.alloc(u8, size);
        _ = std.mem.replace(u8, with_screen_name, "{{ panel_name }}", self.panel_name, with_panel_name);
        return with_panel_name;
    }
};

pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, panel_name: []const u8) !*Template {
    var self: *Template = try allocator.create(Template);
    self.panel_name = try allocator.alloc(u8, panel_name.len);
    errdefer {
        allocator.destroy(self);
    }
    @memcpy(@constCast(self.panel_name), panel_name);
    self.screen_name = try allocator.alloc(u8, screen_name.len);
    errdefer {
        allocator.free(self.panel_name);
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
    \\const _panels_ = @import("panels.zig");
    \\const _various_ = @import("various");
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\
    \\// KICKZIG TODO:
    \\// Remember. Defers happen in reverse order.
    \\// When updating panel state.
    \\//     self.lock();
    \\//     defer self.refresh(); // 2nd defer: Refreshes the main view.
    \\//     defer self.unlock(); //  1st defer: Unlocks.
    \\//     // DO THE UPDATES.
    \\
    \\pub const Panel = struct {
    \\    allocator: std.mem.Allocator, // For persistant state data.
    \\    lock: *_lock_.ThreadLock, // For persistant state data.
    \\    window: *dvui.Window,
    \\    main_view: *MainView,
    \\    container: ?*_various_.Container,
    \\    all_panels: *_panels_.Panels,
    \\    messenger: *_messenger_.Messenger,
    \\    exit: ExitFn,
    \\
    \\    /// frame this panel.
    \\    /// Layout, Draw, Handle user events.
    \\    /// The arena allocator is for building this frame. Not for state.
    \\    pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {
    \\        _ = arena;
    \\
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        var scroller = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
    \\        defer scroller.deinit();
    \\
    \\        var layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{});
    \\        defer layout.deinit();
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
    \\            try dvui.labelNoFmt(@src(), "{{ panel_name }}", .{});
    \\        }
    \\
    \\        // Row 3 example: A button which closes the container.
    \\        if (self.container) |container| {
    \\            // This screen is framing inside a container.
    \\            // Allow the user to close the container.
    \\            if (try dvui.button(@src(), "Close Container.", .{}, .{})) {
    \\                container.close();
    \\            }
    \\        }
    \\    }
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        // The screen will deinit the container.
    \\        self.lock.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// refresh only if this panel and ( container or screen ) are showing.
    \\    pub fn refresh(self: *Panel) void {
    \\        if (self.all_panels.current_panel_tag == .{{ panel_name }}) {
    \\            // This is the current panel.
    \\            if (self.container) |container| {
    \\                // Refresh the container.
    \\                // The container will refresh only if it's the currently viewed screen.
    \\                container.refresh();
    \\            } else {
    \\                // Main view will refresh only if this is the currently viewed screen.
    \\                self.main_view.refresh{{ screen_name }}();
    \\            }
    \\        }
    \\    }
    \\
    \\    pub fn setContainer(self: *Panel, container: *_various_.Container) void {
    \\        self.container = container;
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, main_view: *MainView, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panel {
    \\    var panel: *Panel = try allocator.create(Panel);
    \\    panel.lock = try _lock_.init(allocator);
    \\    errdefer {
    \\        allocator.destroy(panel);
    \\    }
    \\    panel.container = null;
    \\    panel.allocator = allocator;
    \\    panel.main_view = main_view;
    \\    panel.all_panels = all_panels;
    \\    panel.messenger = messenger;
    \\    panel.exit = exit;
    \\    panel.window = window;
    \\    return panel;
    \\}
;
