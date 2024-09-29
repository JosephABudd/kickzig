const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    panel_name: []const u8,
    use_messenger: bool,

    pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, panel_name: []const u8, use_messenger: bool) !*Template {
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
        self.use_messenger = use_messenger;

        return self;
    }

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.screen_name);
        self.allocator.free(self.panel_name);
        self.allocator.destroy(self);
    }

    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        // return std.fmt.allocPrint(self.allocator, template, .{ self.screen_name, self.panel_name });
        var lines: std.ArrayList(u8) = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        var line: []const u8 = undefined;

        try lines.appendSlice(line_1);

        if (self.use_messenger) {
            try lines.appendSlice(line_1_messenger);
        }

        {
            // The close container button.
            line = try std.fmt.allocPrint(self.allocator, line_2_f, .{self.panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        if (self.use_messenger) {
            try lines.appendSlice(line_2_messenger);
        }

        try lines.appendSlice(line_3);

        if (self.use_messenger) {
            try lines.appendSlice(line_3_messenger);
        }

        try lines.appendSlice(line_4);

        return try lines.toOwnedSlice();
    }
};

const line_1: []const u8 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const Container = @import("various").Container;
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\
;

const line_1_messenger: []const u8 =
    \\const Messenger = @import("view/messenger.zig").Messenger;
    \\
;

/// {0s} panel_name
const line_2_f: []const u8 =
    \\const Panels = @import("panels.zig").Panels;
    \\const ScreenOptions = @import("screen.zig").Options;
    \\const PanelView = @import("view/{0s}.zig").View;
    \\const ViewOptions = @import("view/{0s}.zig").Options;
    \\
    \\/// This panel is never a Content but it's screen is.
    \\pub const Panel = struct {{
    \\    allocator: std.mem.Allocator, // For persistant state data.
    \\    view: ?*PanelView,
    \\
    \\    pub const View = PanelView;
    \\
    \\    pub const Options = ViewOptions;
    \\
    \\    pub fn init(
    \\        allocator: std.mem.Allocator,
    \\        window: *dvui.Window,
    \\        main_view: *MainView,
    \\        all_panels: *Panels,
    \\
;

const line_2_messenger: []const u8 =
    \\        messenger: *Messenger,
    \\
;

const line_3: []const u8 =
    \\        exit: ExitFn,
    \\        container: ?*Container,
    \\        screen_options: ScreenOptions,
    \\    ) !*Panel {
    \\        var self: *Panel = try allocator.create(Panel);
    \\        self.allocator = allocator;
    \\        self.view = try PanelView.init(
    \\            allocator,
    \\            window,
    \\            main_view,
    \\            container,
    \\            all_panels,
    \\
;

const line_3_messenger: []const u8 =
    \\            messenger,
    \\
;

const line_4: []const u8 =
    \\            exit,
    \\            screen_options,
    \\        );
    \\        errdefer {
    \\            self.view = null;
    \\            self.deinit();
    \\        }
    \\        return self;
    \\    }
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        if (self.view) |member| {
    \\            member.deinit();
    \\        }
    \\        self.allocator.destroy(self);
    \\    }
    \\};
;
