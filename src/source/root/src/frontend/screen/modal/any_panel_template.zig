const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    panel_name: []const u8,
    all_panel_names: [][]const u8, // default is first name.
    use_messenger: bool,

    pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, panel_name: []const u8, all_panel_names: []const []const u8, use_messenger: bool) !*Template {
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

        self.all_panel_names = try allocator.alloc([]const u8, all_panel_names.len);
        errdefer {
            allocator.free(self.screen_name);
            allocator.free(self.panel_name);
            allocator.destroy(self);
        }
        for (all_panel_names, 0..) |name, i| {
            self.all_panel_names[i] = allocator.alloc(u8, name.len) catch |err| {
                for (self.all_panel_names, 0..) |deinit_name, j| {
                    if (j == i) {
                        break;
                    }
                    allocator.free(deinit_name);
                }
                allocator.free(self.all_panel_names);
                allocator.free(self.screen_name);
                allocator.free(self.panel_name);
                allocator.destroy(self);
                return err;
            };
            @memcpy(@constCast(@constCast(self.all_panel_names)[i]), name);
        }
        self.allocator = allocator;
        self.use_messenger = use_messenger;
        return self;
    }

    pub fn deinit(self: *Template) void {
        for (self.all_panel_names) |deinit_name| {
            self.allocator.free(deinit_name);
        }
        self.allocator.free(self.all_panel_names);
        self.allocator.free(self.screen_name);
        self.allocator.free(self.panel_name);
        self.allocator.destroy(self);
    }

    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        var lines: std.ArrayList(u8) = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        var line: []const u8 = undefined;

        // Imports.

        {
            line = try fmt.allocPrint(self.allocator, line_import_a_f, .{self.panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        if (self.use_messenger) {
            try lines.appendSlice(line_import_messenger);
        }

        {
            line = try fmt.allocPrint(self.allocator, line_import_b_f, .{self.screen_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        // Panel struct.
        try lines.appendSlice(line_panel_struct_start_a);

        if (self.use_messenger) {
            try lines.appendSlice(line_panel_struct_start_messenger);
        }

        {
            line = try fmt.allocPrint(self.allocator, line_panel_struct_b_f, .{ self.screen_name, self.panel_name });
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        if (self.use_messenger) {
            try lines.appendSlice(line_panel_struct_messenger);
        }

        {
            line = try fmt.allocPrint(self.allocator, line_panel_struct_c_f, .{self.screen_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        return try lines.toOwnedSlice();
    }
};

/// panel name {0s}
const line_import_a_f: []const u8 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const _channel_ = @import("channel");
    \\
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\const View  = @import("view/{0s}.zig").View;
    \\
;

const line_import_messenger: []const u8 =
    \\const Messenger = @import("messenger.zig").Messenger;
    \\
;

/// screen name {0s}
const line_import_b_f: []const u8 =
    \\const ModalParams = @import("modal_params").{0s};
    \\const Panels = @import("panels.zig").Panels;
    \\
    \\
;

const line_panel_struct_start_a: []const u8 =
    \\pub const Panel = struct {
    \\    allocator: std.mem.Allocator, // For persistant state data.
    \\    window: *dvui.Window,
    \\    main_view: *MainView,
    \\    all_panels: *Panels,
    \\
;

const line_panel_struct_start_messenger: []const u8 =
    \\    messenger: *Messenger,
    \\
;

// screen name {0s}
// panel name {1s}
const line_panel_struct_b_f: []const u8 =
    \\    exit: ExitFn,
    \\
    \\    modal_params: ?*ModalParams,
    \\
    \\    // The screen owns the modal params.
    \\    pub fn presetModal(self: *Panel, setup_args: *ModalParams) !void {{
    \\        // previous modal_params are already deinited by the screen.
    \\        self.modal_params = setup_args;
    \\    }}
    \\
    \\    /// refresh only if this panel is showing and this screen is showing.
    \\    pub fn refresh(self: *Panel) void {{
    \\        if (self.all_panels.current_panel_tag == .{1s}) {{
    \\            self.main_view.refresh{0s}();
    \\        }}
    \\    }}
    \\
    \\    pub fn init(allocator: std.mem.Allocator, main_view: *MainView, all_panels: *Panels, messenger: *Messenger, exit: ExitFn, window: *dvui.Window, theme: *dvui.Theme) !*Panel {{
    \\        var panel: *Panel = try allocator.create(Panel);
    \\        panel.allocator = allocator;
    \\        panel.main_view = main_view;
    \\        panel.all_panels = all_panels;
    \\
;

const line_panel_struct_messenger: []const u8 =
    \\        panel.messenger = messenger;
    \\
;

// screen name {0s}
const line_panel_struct_c_f: []const u8 =
    \\        panel.exit = exit;
    \\        panel.window = window;
    \\        panel.border_color = theme.style_accent.color_accent.?;
    \\        panel.modal_params = null;
    \\        return panel;
    \\    }}
    \\
    \\    pub fn deinit(self: *Panel) void {{
    \\        // modal_params are already deinited by the screen.
    \\        self.allocator.destroy(self);
    \\    }}
    \\
    \\    // close removes this modal screen replacing it with the previous screen.
    \\    fn close(self: *Panel) void {{
    \\        self.main_view.hide{0s}();
    \\    }}
    \\
    \\    /// frame this panel.
    \\    /// Layout, Draw, Handle user events.
    \\    pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {{
    \\        self.view.frame(arena, self.modal_params);
    \\    }}
    \\}};
    \\
;
