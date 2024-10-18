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

        errdefer {
            allocator.free(self.screen_name);
            allocator.free(self.panel_name);
            allocator.destroy(self);
        }
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
        var lines: std.ArrayList(u8) = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        var line: []const u8 = undefined;

        // The first line.
        try lines.appendSlice(line_start_1);

        if (self.use_messenger) {
            try lines.appendSlice(line_start_1_messenger);
        }

        try lines.appendSlice(line_start_1_last);

        try lines.appendSlice(line_start_options);

        try lines.appendSlice(line_view_start);

        if (self.use_messenger) {
            try lines.appendSlice(line_view_messenger);
        }

        {
            line = try std.fmt.allocPrint(self.allocator, line_start_3_f, .{ self.screen_name, self.panel_name });
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        // Continue in the scroller's content row 3;
        var row_number: usize = 3;

        {
            // The close container line.
            line = try std.fmt.allocPrint(self.allocator, line_close_container_f, .{ self.screen_name, self.panel_name, row_number });
            defer self.allocator.free(line);
            try lines.appendSlice(line);
            row_number += 1;
        }

        // The last line.
        {
            line = try std.fmt.allocPrint(self.allocator, line_end_1_f, .{ self.screen_name, self.panel_name, row_number });
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        if (self.use_messenger) {
            try lines.appendSlice(line_end_1_messenger);
        }

        try lines.appendSlice(line_end_2);

        if (self.use_messenger) {
            try lines.appendSlice(line_end_2_messenger);
        }

        {
            line = try std.fmt.allocPrint(self.allocator, line_end_3_f, .{ self.screen_name, self.panel_name });
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        return try lines.toOwnedSlice();
    }
};

const line_start_1: []const u8 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const Container = @import("cont").Container;
    \\const ExitFn = @import("closer").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\
;

const line_start_1_messenger: []const u8 =
    \\const Messenger = @import("messenger.zig").Messenger;
    \\
;

/// panel name {0s}
const line_start_1_last: []const u8 =
    \\const OKModalParams = @import("modal_params").OK;
    \\const ScreenOptions = @import("../screen.zig").Options;
    \\
;

const line_start_options: []const u8 =
    \\
    \\///KICKZIG TODO: Customize Options to your requirements.
    \\///All members should be optional.
    \\pub const Options = struct {
    \\    allocator: std.mem.Allocator = undefined,
    \\    foo: ?[]const u8 = null,
    \\    bar: ?bool = null,
    \\
    \\    fn init(allocator: std.mem.Allocator, defaults: Options) !*Options {
    \\        var self: *Options = try allocator.create(Options);
    \\        self.allocator = allocator;
    \\        self.foo = null;
    \\        self.bar = null;
    \\        try self.reset(defaults);
    \\        errdefer self.deinit();
    \\        return self;
    \\    }
    \\
    \\    pub fn deinit(self: *Options) void {
    \\        // Screen name.
    \\        if (self.foo) |member| {
    \\            self.allocator.free(member);
    \\        }
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    fn reset(
    \\        self: *Options,
    \\        settings: Options,
    \\    ) !void {
    \\        return self._reset(
    \\            settings.foo,
    \\            settings.bar,
    \\        );
    \\    }
    \\
    \\    fn _reset(
    \\        self: *Options,
    \\        foo: ?[]const u8,
    \\        bar: ?bool,
    \\    ) !void {
    \\        // foo.
    \\        if (foo) |reset_value| {
    \\            if (self.foo) |self_value| {
    \\                self.allocator.free(self_value);
    \\            }
    \\            self.foo = try self.allocator.alloc(u8, reset_value.len);
    \\            errdefer {
    \\                self.foo = null;
    \\                self.deinit();
    \\            }
    \\            @memcpy(@constCast(self.foo.?), reset_value);
    \\        }
    \\        // bar.
    \\        if (bar) |reset_value| {
    \\            self.bar = reset_value;
    \\        }
    \\    }
    \\};
    \\
;

const line_view_start: []const u8 =
    \\
    \\pub const View = struct {
    \\    allocator: std.mem.Allocator,
    \\    window: *dvui.Window,
    \\    main_view: *MainView,
    \\    container: ?*Container,
    \\
;

const line_view_messenger: []const u8 =
    \\    messenger: *Messenger,
    \\
;

/// screen name {0s}
/// tab name {1s}
const line_start_3_f: []const u8 =
    \\    exit: ExitFn,
    \\    lock: std.Thread.Mutex,
    \\    state: ?*Options,
    \\    screen_options: ScreenOptions,
    \\
    \\    const default_settings = Options{{
    \\        .foo = "{0s}:{1s}",
    \\        .bar = false,
    \\    }};
    \\
    \\    /// KICKZIG TODO:
    \\    /// fn frame is the View's true purpose.
    \\    /// Layout, Draw, Handle user events.
    \\    /// The arena allocator is for building this frame. Not for state.
    \\    pub fn frame(
    \\        self: *View,
    \\        arena: std.mem.Allocator,
    \\    ) !void {{
    \\        _ = arena;
    \\
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        // Begin with the view's master layout.
    \\        // A vertical stack.
    \\        // So that the scroll area is always under the heading.
    \\        // Row 1 is the heading.
    \\        // Row 2 is the scroller with it's own vertically stacked content.
    \\        var master_layout: *dvui.BoxWidget = dvui.box(
    \\            @src(),
    \\            .vertical,
    \\            .{{
    \\                .expand = .both,
    \\                .background = true,
    \\                .name = "master_layout",
    \\            }},
    \\        ) catch |err| {{
    \\            self.exit(@src(), err, "dvui.box");
    \\            return err;
    \\        }};
    \\        defer master_layout.deinit();
    \\
    \\        {{
    \\            // Vertical Stack Row 1: The screen's name.
    \\            // Use the same background as the scroller.
    \\            var row1: *dvui.BoxWidget = dvui.box(
    \\                @src(),
    \\                .horizontal,
    \\                .{{
    \\                    .expand = .horizontal,
    \\                    .background = true,
    \\                }},
    \\            ) catch |err| {{
    \\                self.exit(@src(), err, "{0s}.{1s} row1");
    \\                return err;
    \\            }};
    \\            defer row1.deinit();
    \\
    \\            dvui.labelNoFmt(@src(), "{0s}", .{{ .font_style = .title }}) catch |err| {{
    \\                self.exit(@src(), err, "{0s}.{1s} row1 label");
    \\                return err;
    \\            }};
    \\        }}
    \\
    \\        {{
    \\            // Vertical Stack Row 2: The vertical scroller.
    \\            // The vertical scroller has it's contents vertically stacked.
    \\            var scroller = dvui.scrollArea(@src(), .{{}}, .{{ .expand = .both }}) catch |err| {{
    \\                self.exit(@src(), err, "{0s}.{1s} scroller");
    \\                return err;
    \\            }};
    \\            defer scroller.deinit();
    \\    
    \\            // Vertically stack the scroller's contents.
    \\            var scroller_layout: *dvui.BoxWidget = dvui.box(@src(), .vertical, .{{ .expand = .horizontal }}) catch |err| {{
    \\                self.exit(@src(), err, "{0s}.{1s} scroller_layout");
    \\                return err;
    \\            }};
    \\            defer scroller_layout.deinit();
    \\    
    \\            {{
    \\                // Scroller's Content Row 1. The panel's name.
    \\                // Row 1 has 2 columns.
    \\                var scroller_row1: *dvui.BoxWidget = dvui.box(@src(), .horizontal, .{{}}) catch |err| {{
    \\                    self.exit(@src(), err, "{0s}.{1s} scroller_row1");
    \\                    return err;
    \\                }};
    \\                defer scroller_row1.deinit();
    \\                // Row 1 Column 1: The label.
    \\                dvui.labelNoFmt(@src(), "Panel Name: ", .{{ .font_style = .heading }}) catch |err| {{
    \\                    self.exit(@src(), err, "{0s}.{1s} scroller_row1 heading");
    \\                    return err;
    \\                }};
    \\                // Row 1 Column 2: The panel's name.
    \\                dvui.labelNoFmt(@src(), "{1s}", .{{}}) catch |err| {{
    \\                    self.exit(@src(), err, "{0s}.{1s} scroller_row1 text");
    \\                    return err;
    \\                }};
    \\            }}
    \\            {{
    \\                // Scroller's Content Row 2.
    \\                // Instructions using a text layout widget.
    \\                var scroller_row2 = dvui.TextLayoutWidget.init(
    \\                    @src(),
    \\                    .{{}},
    \\                    .{{
    \\                        .expand = .horizontal,
    \\                    }},
    \\                );
    \\                defer scroller_row2.deinit();
    \\                scroller_row2.install(.{{}}) catch |err| {{
    \\                    self.exit(@src(), err, "{0s}.{1s} scroller_row2 instructions");
    \\                    return err;
    \\                }};
    \\    
    \\                const intructions: []const u8 =
    \\                    \\The {0s} screen is a tab-bar layout.
    \\                    \\The {1s} tab uses the {1s} panel and this view for content.
    \\                    \\Tab screens function as a tab-bar showing the content of the selectd tab.
    \\                    \\
    \\                    \\Using this screen:
    \\                    \\ 1. In the main menu:
    \\                    \\    * Add .{0s} to pub const sorted_main_menu_screen_tags in src/deps/main_menu/api.zig.
    \\                    \\ 2. As content for a tab in another tab screen.
    \\                    \\    * kickzig add-tab «screen-name» *{0s} «[*]other-tab-names ...»
    \\                    \\
    \\                ;
    \\                try scroller_row2.addText(intructions, .{{}});
    \\            }}
    \\
;

/// {0s} is screen name.
/// {1s} is panel name.
/// {2d} is row number.
const line_close_container_f: []const u8 =
    \\
    \\            {{
    \\                // Scroller's Content Row {2d}.
    \\                // A button which closes the container.
    \\                if (self.container.?.isCloseable()) {{
    \\                    // This screens container can be closed.
    \\                    // Allow the user to close the container.
    \\                    const pressed: bool = dvui.button(@src(), "Close Container.", .{{}}, .{{}}) catch |err| {{
    \\                        self.exit(@src(), err, "{0s}.{1s} row{2d} close container button");
    \\                        return err;
    \\                    }};
    \\                    if (pressed) {{
    \\                        self.container.?.close();
    \\                    }}
    \\                }}
    \\            }}
    \\
;

/// {0s} is screen name.
/// {1s} is panel name.
/// {2d} is row number.
const line_end_1_f: []const u8 =
    \\
    \\            {{
    \\                // Scroller's Content Row {2d}.
    \\                // A button which opens the OK modal screen using 1 column.
    \\                const pressed: bool = dvui.button(@src(), "OK Modal Screen.", .{{}}, .{{}}) catch |err| {{
    \\                    self.exit(@src(), err, "{0s}.{1s} row{2d} OK Modal button");
    \\                    return err;
    \\                }};
    \\                if (pressed) {{
    \\                    // Modal params a part of the modal state.
    \\                    // There fore using the gpa not the arena.
    \\                    const ok_args = OKModalParams.init(self.allocator, "Using the OK Modal Screen!", "This is the OK modal activated from the {1s} panel in the {0s} screen.") catch |err| {{
    \\                        self.exit(@src(), err, "{0s}.{1s} row{2d} ok_args");
    \\                        return err;
    \\                    }};
    \\                    self.main_view.showOK(ok_args);
    \\                }}
    \\            }}
    \\        }}
    \\    }}
    \\
    \\    /// The caller owns the returned value.
    \\    pub fn label(self: *View, allocator: std.mem.Allocator) ![]const u8 {{
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        return try std.fmt.allocPrint(allocator, "{{s}}", .{{"{1s}"}});
    \\    }}
    \\
    \\    pub fn init(
    \\        allocator: std.mem.Allocator,
    \\        window: *dvui.Window,
    \\        main_view: *MainView,
    \\
;

const line_end_1_messenger: []const u8 =
    \\        messenger: *Messenger,
    \\
;

const line_end_2: []const u8 =
    \\        exit: ExitFn,
    \\        screen_options: ScreenOptions,
    \\    ) !*View {
    \\        var self: *View = try allocator.create(View);
    \\        errdefer allocator.destroy(self);
    \\        self.allocator = allocator;
    \\
    \\        // Initialize state.
    \\        self.state = try Options.init(allocator, default_settings);
    \\        errdefer {
    \\            self.state = null;
    \\            self.deinit();
    \\        }
    \\
    \\        self.window = window;
    \\        self.main_view = main_view;
    \\        self.container = null; // Will be set by Tab.
    \\
;

const line_end_2_messenger: []const u8 =
    \\        self.messenger = messenger;
    \\
;

/// {0s} is screen name.
/// {1s} is panel name.
const line_end_3_f: []const u8 =
    \\        self.exit = exit;
    \\        self.lock = std.Thread.Mutex{{}};
    \\        self.screen_options = screen_options;
    \\        return self;
    \\    }}
    \\
    \\    /// When a container closes it deinits.
    \\    /// When a container deinits, it deinits it's content.
    \\    pub fn deinit(self: *View) void {{
    \\        if (self.state) |member| {{
    \\            member.deinit(self.allocator);
    \\        }}
    \\        self.allocator.destroy(self);
    \\    }}
    \\
    \\    /// The caller owns the returned value.
    \\    pub fn getState(self: *View) !*Options {{
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        return Options.init(self.allocator, self.state.?.*);
    \\    }}
    \\
    \\    /// The caller owns the returned value.
    \\    /// Use _getState during framing or whenever View is locked.
    \\    /// self.lock must be locked.
    \\    fn _getState(self: *View) !*Options {{
    \\        return self.state.?.init(self.allocator, self.state.?.*);
    \\    }}
    \\
    \\    /// setState uses the not null members of param settings to modify self.state.
    \\    /// param settings is owned by the caller.
    \\    pub fn setState(self: *View, settings: Options) !void {{
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        return self._setState(settings);
    \\    }}
    \\
    \\    /// _setState uses the not null members of param settings to modify self.state.
    \\    /// Use _setState during framing or whenever View is locked.
    \\    /// self.lock must be locked.
    \\    /// param settings is owned by the caller.
    \\    /// Refreshes this view after updating the state.
    \\    fn _setState(self: *View, settings: Options) !void {{
    \\        self.state.?.reset(settings) catch |err| {{
    \\            self.exit(@src(), err, "{0s}.{1s} unable to set state");
    \\            return err;
    \\        }};
    \\        self.container.?.refresh();
    \\    }}
    \\
    \\    pub fn willFrame(self: *View) bool {{
    \\        _ = self;
    \\        return true;
    \\    }}
    \\}};
    \\
;
