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

    // The caller owns the returned value.
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
    \\const _framers_ = @import("framers");
    \\const _lock_ = @import("lock");
    \\const _messenger_ = @import("messenger.zig");
    \\const _panels_ = @import("panels.zig");
    \\const ExitFn = @import("various").ExitFn;
    \\
    \\// KICKZIG TODO:
    \\// Remember. Defers happen in reverse order.
    \\// When updating panel state.
    \\//     self.lock();
    \\//     defer self.unlock(); //  2nd defer: Unlocks.
    \\//     defer self.refresh(); // 1st defer: Refreshes the main view.
    \\//     // DO THE UPDATES.
    \\
    \\/// {{ panel_name }} panel.
    \\/// This panel is the content for the {{ panel_name }} tab.
    \\pub const Panel = struct {
    \\    allocator: std.mem.Allocator, // For persistant state data.
    \\    lock: *_lock_.ThreadLock, // For persistant state data.
    \\    window: *dvui.Window,
    \\    all_screens: *_framers_.Screens,
    \\    all_panels: *_panels_.Panels,
    \\    messenger: *_messenger_.Messenger,
    \\    exit: ExitFn,
    \\
    \\    /// refresh only if this panel is showing and this screen is showing.
    \\    pub fn refresh(self: *Panel) void {
    \\        if (self.all_panels.current_panel_tag == .{{ panel_name }}) {
    \\            self.main_view.refresh{{ screen_name }}();
    \\        }
    \\    }
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        self.lock.deinit();
    \\        self.allocator.destroy(self);
    \\    }
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
    \\        // The content area.
    \\        // Layout the children vertically in single column.
    \\        var vertical_layout = try dvui.box(@src(), .vertical, .{ .expand = .both, .background = true });
    \\        defer vertical_layout.deinit();
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
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Screens, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panel {
    \\    var panel: *Panel = try allocator.create(Panel);
    \\    panel.lock = try _lock_.init(allocator);
    \\    errdefer {
    \\        allocator.destroy(panel);
    \\    }
    \\    panel.allocator = allocator;
    \\    panel.window = window;
    \\    panel.all_screens = all_screens;
    \\    panel.all_panels = all_panels;
    \\    panel.messenger = messenger;
    \\    panel.exit = exit;
    \\    return panel;
    \\}
;
