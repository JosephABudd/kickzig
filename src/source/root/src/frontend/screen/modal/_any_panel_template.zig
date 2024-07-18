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
    \\const _channel_ = @import("channel");
    \\const _lock_ = @import("lock");
    \\const _messenger_ = @import("messenger.zig");
    \\const _panels_ = @import("panels.zig");
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\const ModalParams = @import("modal_params").{{ screen_name }};
    \\
    \\pub const Panel = struct {
    \\    allocator: std.mem.Allocator, // For persistant state data.
    \\    lock: *_lock_.ThreadLock, // For persistant state data.
    \\    window: *dvui.Window,
    \\    main_view: *MainView,
    \\    all_panels: *_panels_.Panels,
    \\    messenger: *_messenger_.Messenger,
    \\    exit: ExitFn,
    \\
    \\    modal_params: ?*ModalParams,
    \\
    \\    // This panels owns the modal params.
    \\    pub fn presetModal(self: *Panel, setup_args: *ModalParams) !void {
    \\        // The screen already deinited self.modal_params.
    \\        self.modal_params = setup_args;
    \\    }
    \\
    \\    /// refresh only if this panel is showing and this screen is showing.
    \\    pub fn refresh(self: *Panel) void {
    \\        if (self.all_panels.current_panel_tag == .{{ panel_name }}) {
    \\            self.main_view.refresh{{ screen_name }}();
    \\        }
    \\    }
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        // The screen already deinited self.modal_params.
    \\        self.lock.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    // close removes this modal screen replacing it with the previous screen.
    \\    fn close(self: *Panel) void {
    \\        self.main_view.hide{{ screen_name }}();
    \\    }
    \\
    \\    /// frame this panel.
    \\    /// Layout, Draw, Handle user events.
    \\    pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {
    \\        _ = arena;
    \\
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        const theme: *dvui.Theme = dvui.themeGet();
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
    \\        // Row 3: The close button closes this modal screen and returns to the previous screen.
    \\        if (try dvui.button(@src(), "Close", .{}, .{})) {
    \\            self.close();
    \\        }
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, main_view: *MainView, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panel {
    \\    var panel: *Panel = try allocator.create(Panel);
    \\    panel.lock = try _lock_.init(allocator);
    \\    errdefer {
    \\        allocator.destroy(panel);
    \\    }
    \\    panel.allocator = allocator;
    \\    panel.main_view = main_view;
    \\    panel.all_panels = all_panels;
    \\    panel.messenger = messenger;
    \\    panel.exit = exit;
    \\    panel.window = window;
    \\    panel.modal_params = null;
    \\    return panel;
    \\}
;
