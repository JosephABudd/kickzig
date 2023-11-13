const std = @import("std");
const fmt = std.fmt;
const strings = @import("strings");

pub const Template = struct {
    allocator: std.mem.Allocator,
    src_app_folder_name: *strings.UTF8,

    pub fn init(allocator: std.mem.Allocator, name: []const u8) !*Template {
        var data: *Template = try allocator.create(Template);
        data.src_app_folder_name = try strings.UTF8.init(allocator, name);
        errdefer {
            allocator.destroy(data);
        }
        data.allocator = allocator;
        return data;
    }

    pub fn deinit(self: *Template) void {
        self.src_app_folder_name.deinit();
        self.allocator.destroy(self);
    }

    pub fn content(self: *Template) ![]const u8 {
        // Replace {{src_app_folder_name}} with the message name.
        const copy: []const u8 = try self.src_app_folder_name.copy();
        defer self.allocator.free(copy);
        var replacement_size: usize = std.mem.replacementSize(u8, template, "{{src_app_folder_name}}", copy);
        var with_src_app_folder_name: []u8 = try self.allocator.alloc(u8, replacement_size);
        _ = std.mem.replace(u8, template, "{{src_app_folder_name}}", copy, with_src_app_folder_name);
        return with_src_app_folder_name;
    }
};

pub const template =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const SDLBackend = @import("SDLBackend");
    \\
    \\const _frontend_ = @import("src/{{src_app_folder_name}}/frontend/api.zig");
    \\const _backend_ = @import("src/{{src_app_folder_name}}/backend/api.zig");
    \\const _channel_ = @import("channel");
    \\const _framers_ = @import("framers");
    \\
    \\// General Purpose Allocator for frontend-state, backend and channels.
    \\var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
    \\const gpa = gpa_instance.allocator();
    \\
    \\var show_dialog_outside_frame: bool = false;
    \\
    \\/// This example shows how to use the dvui for a normal application:
    \\/// - dvui renders the whole application
    \\/// - render frames only when needed
    \\pub fn main() !void {
    \\    // init SDL gui_backend (creates OS window)
    \\    var gui_backend = try SDLBackend.init(.{
    \\        .width = 500,
    \\        .height = 600,
    \\        .vsync = true,
    \\        .title = "GUI Standalone Example",
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
