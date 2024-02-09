pub const content =
    \\/// KICKZIG TODO: You are free to modify this file.
    \\/// You may want to add your own members to these startup structs.
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const _channel_ = @import("channel");
    \\const _closedownjobs_ = @import("closedownjobs");
    \\const _framers_ = @import("framers");
    \\const _modal_params_ = @import("modal_params");
    \\
    \\/// Backend is the parameters passed to the back-end when it is initialized.
    \\pub const Backend = struct {
    \\    allocator: std.mem.Allocator,
    \\    send_channels: *_channel_.BackendToFrontend,
    \\    receive_channels: *_channel_.FrontendToBackend,
    \\    triggers: *_channel_.Trigger,
    \\    finish_up_jobs: *_closedownjobs_.Jobs,
    \\    exit: *const fn (user_message: []const u8) void,
    \\};
    \\
    \\/// Frontend is the parameters passed to the front-end when it is initialized.
    \\pub const Frontend = struct {
    \\    allocator: std.mem.Allocator,
    \\    window: *dvui.Window,
    \\    send_channels: *_channel_.FrontendToBackend,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\    all_screens: *_framers_.Group,
    \\    finish_up_jobs: *_closedownjobs_.Jobs,
    \\    exit: *const fn (user_message: []const u8) void,
    \\
    \\    pub fn setAllScreens(self: *Frontend, all_screens: *_framers_.Group) void {
    \\        self.all_screens = all_screens;
    \\    }
    \\
    \\    pub fn init(
    \\        allocator: std.mem.Allocator,
    \\        window: *dvui.Window,
    \\        send_channels: *_channel_.FrontendToBackend,
    \\        receive_channels: *_channel_.BackendToFrontend,
    \\        finish_up_jobs: *_closedownjobs_.Jobs,
    \\        exit: *const fn (user_message: []const u8) void,
    \\    ) !*Frontend {
    \\        var self: *Frontend = try allocator.create(Frontend);
    \\        self.allocator = allocator;
    \\        self.window = window;
    \\        self.send_channels = send_channels;
    \\        self.receive_channels = receive_channels;
    \\        self.all_screens = undefined;
    \\        self.finish_up_jobs = finish_up_jobs;
    \\        self.exit = exit;
    \\        return self;
    \\    }
    \\};
;
