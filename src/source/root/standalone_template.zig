const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    app_name: []const u8,

    // The caller owns the returned value.
    pub fn init(allocator: std.mem.Allocator, app_name: []const u8) !*Template {
        var data: *Template = try allocator.create(Template);
        data.app_name = try allocator.alloc(u8, app_name.len);
        errdefer {
            allocator.destroy(data);
        }
        @memcpy(@constCast(data.app_name), app_name);
        data.allocator = allocator;
        return data;
    }

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.app_name);
        self.allocator.destroy(self);
    }

    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        // Replace {{ app_name }} with the app name.
        var replacement_size: usize = std.mem.replacementSize(u8, template, "{{ app_name }}", self.app_name);
        var with_app_name: []u8 = try self.allocator.alloc(u8, replacement_size);
        _ = std.mem.replace(u8, template, "{{ app_name }}", self.app_name, with_app_name);
        return with_app_name;
    }
};

pub const template =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const SDLBackend = @import("SDLBackend");
    \\
    \\const _frontend_ = @import("src/@This/frontend/api.zig");
    \\const _backend_ = @import("src/@This/backend/api.zig");
    \\const _channel_ = @import("channel");
    \\const _framers_ = @import("framers");
    \\
    \\const window_icon_png = @embedFile("src/vendor/dvui/src/zig-favicon.png");
    \\
    \\// General Purpose Allocator for frontend-state, backend and channels.
    \\var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
    \\const gpa = gpa_instance.allocator();
    \\
    \\const vsync = true;
    \\
    \\var show_dialog_outside_frame: bool = false;
    \\
    \\/// This example shows how to use the dvui for a normal application:
    \\/// - dvui renders the whole application
    \\/// - render frames only when needed
    \\pub fn main() !void {
    \\    // init SDL gui_backend (creates OS window)
    \\    var gui_backend = try SDLBackend.init(.{
    \\        .size = .{ .w = 500.0, .h = 400.0 },
    \\        .min_size = .{ .w = 500.0, .h = 400.0 },
    \\        .vsync = vsync,
    \\        .title = "{{ app_name }}",
    \\        .icon = window_icon_png, // can also call setIconFromFileContent()
    \\    });
    \\    defer gui_backend.deinit();
    \\
    \\    // init dvui Window (maps onto a single OS window)
    \\    var win = try dvui.Window.init(@src(), 0, gpa, gui_backend.backend());
    \\    win.content_scale = gui_backend.initial_scale * 1.5;
    \\    defer win.deinit();
    \\
    \\    // The channels between the front and back ends.
    \\    var initialized_channels: bool = false;
    \\    const backToFront: *_channel_.Channels = try _channel_.init(gpa);
    \\    defer backToFront.deinit();
    \\    const frontToBack: *_channel_.Channels = try _channel_.init(gpa);
    \\    defer frontToBack.deinit();
    \\
    \\    // Initialize the front and back ends.
    \\    var all_screens: *_framers_.Group = try _frontend_.init(gpa, frontToBack, backToFront);
    \\    defer all_screens.deinit();
    \\    try _backend_.init(gpa, backToFront, frontToBack);
    \\    defer _backend_.deinit();
    \\
    \\    var theme_set: bool = false;
    \\
    \\    main_loop: while (true) {
    \\
    \\        // Arena allocator for the frontend frame functions.
    \\        var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    \\        defer arena_allocator.deinit();
    \\        var arena = arena_allocator.allocator();
    \\
    \\        // beginWait coordinates with waitTime below to run frames only when needed
    \\        var nstime = win.beginWait(gui_backend.hasEvent());
    \\
    \\        // marks the beginning of a frame for dvui, can call dvui functions after this
    \\        try win.begin(nstime);
    \\
    \\        // set the theme.
    \\        if (!theme_set) {
    \\            theme_set = true;
    \\            const dark_theme = &dvui.Adwaita.dark;
    \\            dvui.themeSet(dark_theme);
    \\        }
    \\
    \\        // send all SDL events to dvui for processing
    \\        const quit = try gui_backend.addAllEvents(&win);
    \\        if (quit) break :main_loop;
    \\
    \\        // if dvui widgets might not cover the whole window, then need to clear
    \\        // the previous frame's render
    \\        gui_backend.clear();
    \\
    \\        try _frontend_.frame(arena, all_screens);
    \\
    \\        if (!initialized_channels) {
    \\            initialized_channels = true;
    \\            // Send the initialize message telling the backend that the frontend is ready.
    \\            frontToBack.Initialize.send();
    \\        }
    \\
    \\        // marks end of dvui frame, don't call dvui functions after this
    \\        // - sends all dvui stuff to gui_backend for rendering, must be called before renderPresent()
    \\        const end_micros = try win.end(.{});
    \\
    \\        // cursor management
    \\        gui_backend.setCursor(win.cursorRequested());
    \\
    \\        // render frame to OS
    \\        gui_backend.renderPresent();
    \\
    \\        // waitTime and beginWait combine to achieve variable framerates
    \\        const wait_event_micros = win.waitTime(end_micros, null);
    \\        gui_backend.waitEventTimeout(wait_event_micros);
    \\
    \\        // Example of how to show a dialog from another thread (outside of win.begin/win.end)
    \\        if (show_dialog_outside_frame) {
    \\            show_dialog_outside_frame = false;
    \\            try dvui.dialog(@src(), .{ .window = &win, .modal = false, .title = "Dialog from Outside", .message = "This is a non modal dialog that was created outside win.begin()/win.end(), usually from another thread." });
    \\        }
    \\    }
    \\}
    \\
;
