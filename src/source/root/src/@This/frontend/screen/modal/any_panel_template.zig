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
    \\const _framers_ = @import("framers");
    \\const _panels_ = @import("panels.zig");
    \\const _messenger_ = @import("messenger.zig");
    \\const ModalParams = @import("modal_params").{{ screen_name }};
    \\
    \\pub const Panel = struct {
    \\    allocator: std.mem.Allocator,
    \\    window: *dvui.Window,
    \\    all_screens: *_framers_.Group,
    \\    all_panels: *_panels_.Panels,
    \\    messenger: *_messenger_.Messenger,
    \\    exit: *const fn (user_message: []const u8) void,
    \\
    \\    pub fn presetModal(self: *Panel, setup_args: *ModalParams) !void {
    \\        // KICKFYNE TODO: Set any members that need set using the setup_args.
    \\        _ = self;
    \\        _ = setup_args;
    \\    }
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        // KICKFYNE TODO: deinit and free any members that require it.
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    // close removes this modal screen replacing it with the previous screen.
    \\    fn close(self: *Panel) !void {
    \\        try self.all_screens.popCurrent();
    \\    }
    \\
    \\    // frame is a simple screen rendering one panel at a time.
    \\    pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {
    \\        _ = arena;
    \\        var theme: *dvui.Theme = dvui.themeGet();
    \\
    \\        const padding_options = .{
    \\            .expand = .both,
    \\            .margin = dvui.Rect.all(0),
    \\            .border = dvui.Rect.all(10),
    \\            .padding = dvui.Rect.all(10),
    \\            .corner_radius = dvui.Rect.all(5),
    \\            .color_border = theme.style_accent.color_accent.?, //dvui.options.color(.accent),
    \\        };
    \\        var padding: *dvui.BoxWidget = try dvui.box(@src(), .vertical, padding_options);
    \\        defer padding.deinit();
    \\
    \\        var scroller = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
    \\        defer scroller.deinit();
    \\
    \\        var layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{});
    \\        defer layout.deinit();
    \\
    \\        // Row 1: The screen's name.
    \\        var example_title = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal, .font_style = .title_4 });
    \\        try example_title.addText("{{ screen_name }} Screen.", .{});
    \\        example_title.deinit();
    \\
    \\        // Row 2: This panel's name.
    \\        var example_message = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal });
    \\        try example_message.addText("{{ panel_name }} panel.", .{});
    \\        example_message.deinit();
    \\
    \\        // Row 3: The close button.
    \\        if (try dvui.button(@src(), "Close", .{}, .{})) {
    \\            try self.close();
    \\        }
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: *const fn (user_message: []const u8) void, window: *dvui.Window) !*Panel {
    \\    var panel: *Panel = try allocator.create(Panel);
    \\    panel.allocator = allocator;
    \\    panel.window = window;
    \\    panel.all_screens = all_screens;
    \\    panel.all_panels = all_panels;
    \\    panel.messenger = messenger;
    \\    panel.exit = exit;
    \\    return panel;
    \\}
;
