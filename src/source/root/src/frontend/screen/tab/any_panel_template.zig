const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    tab_name: []const u8,
    use_messenger: bool,

    pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, tab_name: []const u8, use_messenger: bool) !*Template {
        var self: *Template = try allocator.create(Template);
        self.tab_name = try allocator.alloc(u8, tab_name.len);
        errdefer {
            allocator.destroy(self);
        }
        @memcpy(@constCast(self.tab_name), tab_name);
        self.screen_name = try allocator.alloc(u8, screen_name.len);
        errdefer {
            allocator.free(self.tab_name);
            allocator.destroy(self);
        }
        @memcpy(@constCast(self.screen_name), screen_name);
        self.allocator = allocator;
        self.use_messenger = use_messenger;
        return self;
    }

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.screen_name);
        self.allocator.free(self.tab_name);
        self.allocator.destroy(self);
    }

    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        var lines: std.ArrayList(u8) = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        var line: []const u8 = undefined;

        try lines.appendSlice(line_1);

        if (self.use_messenger) {
            try lines.appendSlice(line_1_messenger);
        }

        {
            line = try std.fmt.allocPrint(self.allocator, line_2_f, .{self.tab_name});
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
    \\const Content = @import("cont").Content;
    \\const Container = @import("cont").Container;
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\
;

const line_1_messenger: []const u8 =
    \\const Messenger = @import("view/messenger.zig").Messenger;
    \\
;

/// {0s} tab_name
const line_2_f: []const u8 =
    \\const ScreenOptions = @import("screen.zig").Options;
    \\pub const PanelView = @import("view/{0s}.zig").View;
    \\const ViewOptions = @import("view/{0s}.zig").Options;
    \\
    \\/// {0s} panel.
    \\/// This panel is the content for this screen's {0s} tab.
    \\/// This screen's {0s} tab is this panel's container.
    \\pub const Panel = struct {{
    \\    allocator: std.mem.Allocator, // For persistant state data.
    \\    view: *PanelView,
    \\
    \\    pub const View = PanelView;
    \\
    \\    pub const Options = ViewOptions;
    \\
    \\    pub fn init(
    \\        allocator: std.mem.Allocator,
    \\        window: *dvui.Window,
    \\        main_view: *MainView,
    \\
;

const line_2_messenger: []const u8 =
    \\        messenger: *Messenger,
    \\
;

const line_3: []const u8 =
    \\        exit: ExitFn,
    \\        screen_options: ScreenOptions,
    \\    ) !*Panel {
    \\        var self: *Panel = try allocator.create(Panel);
    \\        self.allocator = allocator;
    \\        _ = screen_options;
    \\        self.view = try PanelView.init(
    \\            allocator,
    \\            window,
    \\            main_view,
    \\
;

const line_3_messenger: []const u8 =
    \\            messenger,
    \\
;

const line_4: []const u8 =
    \\            exit,
    \\            // KICKZIG TODO:
    \\            // The next value is the ViewOptions which you may want to modify using the param screen_settings.
    \\            // You may want to use param screen_settings to modify the value of the ViewOptions.
    \\            .{},
    \\        );
    \\        errdefer allocator.destroy(self);
    \\        return self;
    \\    }
    \\
    \\    // Content interface functions.
    \\
    \\    /// Convert this Panel to a Content interface.
    \\    pub fn asContent(self: *Panel) !*Content {
    \\        return try Content.init(
    \\            self.allocator,
    \\            self,
    \\            Panel.deinitContentFn,
    \\            Panel.frameContentFn,
    \\            Panel.labelContentFn,
    \\            Panel.willFrameContentFn,
    \\            Panel.setContainerFn,
    \\        );
    \\    }
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        // This panel is deinited by the container.
    \\        // So don't deinit the container.
    \\        self.view.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// When a container closes it deinits.
    \\    /// When a container deinits, it deinits it's content.
    \\    pub fn deinitContentFn(implementor: *anyopaque) void {
    \\        var self: *Panel = @alignCast(@ptrCast(implementor));
    \\        self.deinit();
    \\    }
    \\
    \\    /// Called by the container when it frames.
    \\    /// When a container frames, it frames it's content.
    \\    pub fn frameContentFn(implementor: *anyopaque, arena: std.mem.Allocator) anyerror!void {
    \\        var self: *Panel = @alignCast(@ptrCast(implementor));
    \\        try self.view.frame(arena);
    \\    }
    \\
    \\    /// labelContentFn is an implementation of the Content interface.
    \\    /// The Container may call this when it refreshes.
    \\    pub fn labelContentFn(implementor: *anyopaque, arena: std.mem.Allocator) anyerror![]const u8 {
    \\        var self: *Panel = @alignCast(@ptrCast(implementor));
    \\        const text: []const u8 = try self.view.label(arena);
    \\        defer arena.free(text);
    \\        return ContainerLabel.init(
    \\            arena,
    \\            null, // badge
    \\            text,
    \\            null, // icons
    \\            null, // menu_items
    \\        );
    \\    }
    \\
    \\    /// Called by the container.
    \\    /// Returns if this content will frame under current state.
    \\    /// A container will not frame if it's content will not frame.
    \\    pub fn willFrameContentFn(implementor: *anyopaque) bool {
    \\        var self: *Panel = @alignCast(@ptrCast(implementor));
    \\        return self.view.willFrame();
    \\    }
    \\
    \\    /// Called by the container when it inits.
    \\    /// The container sets this panel as it's content.
    \\    /// The container sets itself as this panel's container.
    \\    pub fn setContainerFn(implementor: *anyopaque, container: *Container) !void {
    \\        var self: *Panel = @alignCast(@ptrCast(implementor));
    \\        if (self.view.container != null) {
    \\            return error.ContainerAlreadySet;
    \\        }
    \\        self.view.container = container;
    \\    }
    \\
    \\    /// Called by the messenger.
    \\    /// Closes the container.
    \\    pub fn close(self: *Panel) void {
    \\        self.view.container.close();
    \\    }
    \\
    \\    /// Called by the messenger.
    \\    /// Resets the state using the not null values in values.
    \\    /// Then it refreshes for the next frame.
    \\    /// The caller owns settings.
    \\    pub fn setState(self: *Panel, settings: ViewOptions) !void {
    \\        return self.view.setState(settings);
    \\    }
    \\
    \\    /// See view/{0s}.zig fn setState.
    \\    /// The caller owns the return value.
    \\    pub fn getState(self: *Panel) !*ViewOptions {{
    \\        return self.view.getState();
    \\    }}
    \\};
;
