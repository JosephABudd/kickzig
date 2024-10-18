const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    use_messenger: bool,

    // The caller owns the returned value.
    pub fn init(allocator: std.mem.Allocator, use_messenger: bool) !*Template {
        var data: *Template = try allocator.create(Template);
        data.allocator = allocator;
        data.use_messenger = use_messenger;
        return data;
    }

    pub fn deinit(self: *Template) void {
        self.allocator.destroy(self);
    }

    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();

        try lines.appendSlice(line_1);
        if (self.use_messenger) {
            try lines.appendSlice(line_1_use_messenger);
        }

        try lines.appendSlice(line_2);
        if (self.use_messenger) {
            try lines.appendSlice(line_2_use_messenger);
        }

        try lines.appendSlice(line_3);
        if (self.use_messenger) {
            try lines.appendSlice(line_3_use_messenger);
        }

        try lines.appendSlice(line_4);

        return try lines.toOwnedSlice();
    }
};

const line_1: []const u8 =
    \\/// KICKZIG TODO: You are free to modify this file.
    \\/// You may want to add your own members to these startup structs.
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\
;

const line_1_use_messenger: []const u8 =
    \\const _channel_ = @import("channel");
    \\
;

const line_2: []const u8 =
    \\const _closedownjobs_ = @import("closedownjobs");
    \\const _modal_params_ = @import("modal_params");
    \\
    \\const ExitFn = @import("closer").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\const ScreenPointers = @import("screen_pointers").ScreenPointers;
    \\
;

const line_2_use_messenger: []const u8 =
    \\
    \\/// Backend is the parameters passed to the back-end when it is initialized.
    \\pub const Backend = struct {
    \\    allocator: std.mem.Allocator,
    \\    send_channels: *_channel_.BackendToFrontend,
    \\    receive_channels: *_channel_.FrontendToBackend,
    \\    triggers: *_channel_.Trigger,
    \\    close_down_jobs: *_closedownjobs_.Jobs,
    \\    exit: ExitFn,
    \\};
    \\
;

const line_3: []const u8 =
    \\
    \\/// Frontend is the parameters passed to the front-end when it is initialized.
    \\pub const Frontend = struct {
    \\    allocator: std.mem.Allocator,
    \\    window: *dvui.Window,
    \\    theme: *dvui.Theme,
    \\
;

const line_3_use_messenger: []const u8 =
    \\    send_channels: *_channel_.FrontendToBackend,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\
;

const line_4: []const u8 =
    \\    main_view: *MainView,
    \\    close_down_jobs: *_closedownjobs_.Jobs,
    \\    exit: ExitFn,
    \\    screen_pointers: *ScreenPointers,
    \\
    \\    pub fn setMainView(self: *const Frontend, main_view: *MainView) void {
    \\        @constCast(self).main_view = main_view;
    \\    }
    \\
    \\    pub fn setScreenPointers(self: *const Frontend, screen_pointers: *ScreenPointers) void {
    \\        @constCast(self).screen_pointers = screen_pointers;
    \\    }
    \\};
    \\
;
