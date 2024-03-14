const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    default_panel_name: []const u8,

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.screen_name);
        self.allocator.destroy(self);
    }

    // content builds and returns the content.
    // The caller owns the return value.
    pub fn content(self: *Template) ![]const u8 {
        var size: usize = 0;
        // screen_name
        size = std.mem.replacementSize(u8, template, "{{ screen_name }}", self.screen_name);
        const with_screen_name: []u8 = try self.allocator.alloc(u8, size);
        defer self.allocator.free(with_screen_name);
        _ = std.mem.replace(u8, template, "{{ screen_name }}", self.screen_name, with_screen_name);
        // default_panel_name
        size = std.mem.replacementSize(u8, with_screen_name, "{{ default_panel_name }}", self.default_panel_name);
        const with_default_panel_name: []u8 = try self.allocator.alloc(u8, size);
        _ = std.mem.replace(u8, with_screen_name, "{{ default_panel_name }}", self.default_panel_name, with_default_panel_name);
        return with_default_panel_name;
    }
};

pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, default_panel_name: []const u8) !*Template {
    var self: *Template = try allocator.create(Template);
    self.screen_name = try allocator.alloc(u8, screen_name.len);
    errdefer {
        allocator.destroy(self);
    }
    @memcpy(@constCast(self.screen_name), screen_name);
    self.default_panel_name = try allocator.alloc(u8, default_panel_name.len);
    errdefer {
        allocator.free(self.screen_name);
        allocator.destroy(self);
    }
    @memcpy(@constCast(self.default_panel_name), default_panel_name);
    self.allocator = allocator;
    return self;
}

const template =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const _channel_ = @import("channel");
    \\const _messenger_ = @import("messenger.zig");
    \\const _panels_ = @import("panels.zig");
    \\const _startup_ = @import("startup");
    \\const MainView = @import("framers").MainView;
    \\
    \\pub const Screen = struct {
    \\    allocator: std.mem.Allocator,
    \\    main_view: *MainView,
    \\    all_panels: *_panels_.Panels,
    \\    send_channels: *_channel_.FrontendToBackend,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\
    \\    /// init constructs this self, subscribes it to main_view and returns the error.
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
    \\};
;
