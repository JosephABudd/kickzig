const std = @import("std");
const fmt = std.fmt;
const _strings_ = @import("strings");

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
        var with_screen_name: []u8 = try self.allocator.alloc(u8, size);
        defer self.allocator.free(with_screen_name);
        _ = std.mem.replace(u8, template, "{{ screen_name }}", self.screen_name, with_screen_name);
        // panel_name
        size = std.mem.replacementSize(u8, with_screen_name, "{{ panel_name }}", self.panel_name);
        var with_panel_name: []u8 = try self.allocator.alloc(u8, size);
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
    \\const _framers_ = @import("framers");
    \\const _panels_ = @import("panels.zig");
    \\const _messenger_ = @import("messenger.zig");
    \\
    \\/// {{ panel_name }} panel.
    \\/// This panel is the content for the {{ panel_name }} tab.
    \\pub const Panel = struct {
    \\    allocator: std.mem.Allocator, // For persistant state data.
    \\    all_screens: *_framers_.Group,
    \\    all_panels: *_panels_.Panels,
    \\    messenger: *_messenger_.Messenger,
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// frame this panel for rendering.
    \\    /// The arena allocator is for building this frame. Not for state.
    \\    pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {
    \\        _ = self;
    \\        _ = arena;
    \\
    \\        // The content area for a tab's content.
    \\        var scroll = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
    \\        defer scroll.deinit();
    \\
    \\        // Example 1: The screen's name.
    \\        var example_title = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal, .font_style = .title_4 });
    \\        try example_title.addText("{{ screen_name }} Screen.", .{});
    \\        example_title.deinit();
    \\
    \\        // Example 2: This panel's name.
    \\        var example_message = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal });
    \\        try example_message.addText("{{ panel_name }} panel.", .{});
    \\        example_message.deinit();
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger) !*Panel {
    \\    var panel: *Panel = try allocator.create(Panel);
    \\    panel.allocator = allocator;
    \\    panel.all_screens = all_screens;
    \\    panel.all_panels = all_panels;
    \\    panel.messenger = messenger;
    \\    return panel;
    \\}
;
