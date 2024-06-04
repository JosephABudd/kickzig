const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    panel_names: [][]const u8,

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.screen_name);
        self.allocator.destroy(self);
    }

    // content builds and returns the content.
    // The caller owns the return value.
    pub fn content(self: *Template) ![]const u8 {
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        var size: usize = 0;
        var with_screen_name: []u8 = undefined;
        var with_default_panel_name: []u8 = undefined;
        var line: []u8 = undefined;
        const default_panel_name: []const u8 = self.panel_names[0];

        {
            // line_start.
            // screen_name
            size = std.mem.replacementSize(u8, line_start, "{{ screen_name }}", self.screen_name);
            with_screen_name = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_screen_name);
            _ = std.mem.replace(u8, line_start, "{{ screen_name }}", self.screen_name, with_screen_name);
            // default_panel_name
            size = std.mem.replacementSize(u8, with_screen_name, "{{ default_panel_name }}", default_panel_name);
            with_default_panel_name = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_default_panel_name);
            _ = std.mem.replace(u8, with_screen_name, "{{ default_panel_name }}", default_panel_name, with_default_panel_name);
            try lines.appendSlice(with_default_panel_name);
        }

        for (self.panel_names) |panel_name| {
            line = try std.fmt.allocPrint(self.allocator, line_preset_modal, .{panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        {
            // line_end.
            // screen_name
            size = std.mem.replacementSize(u8, line_end, "{{ screen_name }}", self.screen_name);
            with_screen_name = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_screen_name);
            _ = std.mem.replace(u8, line_end, "{{ screen_name }}", self.screen_name, with_screen_name);
            // default_panel_name
            size = std.mem.replacementSize(u8, with_screen_name, "{{ default_panel_name }}", default_panel_name);
            with_default_panel_name = try self.allocator.alloc(u8, size);
            _ = std.mem.replace(u8, with_screen_name, "{{ default_panel_name }}", default_panel_name, with_default_panel_name);
            try lines.appendSlice(with_default_panel_name);
        }

        const temp: []const u8 = try lines.toOwnedSlice();
        line = try self.allocator.alloc(u8, temp.len);
        @memcpy(line, temp);
        return line;
    }
};

pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, panel_names: [][]const u8) !*Template {
    var self: *Template = try allocator.create(Template);
    self.screen_name = try allocator.alloc(u8, screen_name.len);
    errdefer {
        allocator.destroy(self);
    }
    @memcpy(@constCast(self.screen_name), screen_name);
    self.panel_names = try allocator.alloc([]const u8, panel_names.len);
    errdefer {
        allocator.free(self.screen_name);
        allocator.destroy(self);
    }
    for (panel_names, 0..) |panel_name, i| {
        self.panel_names[i] = try allocator.alloc(u8, panel_name.len);
        errdefer {
            for (self.panel_names, 0..) |deinit_panel_name, j| {
                if (i == j) {
                    break;
                }
                allocator.free(deinit_panel_name);
            }
            allocator.free(self.screen_name);
            allocator.destroy(self);
        }
        @memcpy(@constCast(self.panel_names[i]), panel_name);
    }
    self.allocator = allocator;
    return self;
}

const line_start =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const _channel_ = @import("channel");
    \\const _panels_ = @import("panels.zig");
    \\const _messenger_ = @import("messenger.zig");
    \\const _startup_ = @import("startup");
    \\const MainView = @import("framers").MainView;
    \\const ModalParams = @import("modal_params").{{ screen_name }};
    \\
    \\pub const Screen = struct {
    \\    allocator: std.mem.Allocator,
    \\    main_view: *MainView,
    \\    all_panels: *_panels_.Panels,
    \\    send_channels: *_channel_.FrontendToBackend,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\
    \\    /// init constructs this screen, subscribes it to main_view and returns the error.
    \\    pub fn init(startup: _startup_.Frontend) !*Screen {
    \\        var self: *Screen = try startup.allocator.create(Screen);
    \\        self.allocator = startup.allocator;
    \\        self.main_view = startup.main_view;
    \\        self.receive_channels = startup.receive_channels;
    \\        self.send_channels = startup.send_channels;
    \\
    \\        // The messenger.
    \\        var messenger: *_messenger_.Messenger = try _messenger_.init(startup.allocator, startup.main_view, startup.send_channels, startup.receive_channels, startup.exit);
    \\        errdefer {
    \\            self.deinit();
    \\        }
    \\
    \\        // All of the panels.
    \\        self.all_panels = try _panels_.init(startup.allocator, startup.main_view, messenger, startup.exit, startup.window);
    \\        errdefer {
    \\            messenger.deinit();
    \\            self.deinit();
    \\        }
    \\        messenger.all_panels = self.all_panels;
    \\        // The {{ default_panel_name }} panel is the default.
    \\        self.all_panels.setCurrentTo{{ default_panel_name }}();
    \\        return self;
    \\    }
    \\
    \\    pub fn deinit(self: *Screen) void {
    \\        self.all_panels.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// The caller does not own the returned value.
    \\    /// KICKZIG TODO: You may want to edit the returned label.
    \\    pub fn label(_: *Screen) []const u8 {
    \\        return "{{ screen_name }}";
    \\    }
    \\
    \\    pub fn frame(self: *Screen, arena: std.mem.Allocator) !void {
    \\        try self.all_panels.frameCurrent(arena);
    \\    }
    \\
    \\    /// setState sets the state for this modal screen.
    \\    pub fn setState(self: *Screen, setup_args: *ModalParams) !void {
    \\
;

const line_preset_modal =
    \\        try self.all_panels.{0s}.?.presetModal(setup_args);
    \\
;

const line_end =
    \\    }
    \\};
;
