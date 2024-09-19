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

        try lines.appendSlice(line_start_2);

        if (self.use_messenger) {
            try lines.appendSlice(line_start_2_messenger);
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

/// {0s} is screen name.
/// {1s} is tab & panel name.
/// {2d} is row number.
const line_start_1: []const u8 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const Container = @import("various").Container;
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\
;

const line_start_1_messenger: []const u8 =
    \\const Messenger = @import("messenger.zig").Messenger;
    \\
;

const line_start_2: []const u8 =
    \\const OKModalParams = @import("modal_params").OK;
    \\const ScreenOptions = @import("../screen.zig").Options;
    \\
    \\//KICKZIG TODO: Customize Options to your requirements.
    \\pub const Options = struct {
    \\    screen_name: ?[]const u8 = null, // Example field.
    \\    panel_name: ?[]const u8 = null, // Example field.
    \\
    \\    /// The caller owns the returned value.
    \\    fn label(self: *Options, allocator: std.mem.Allocator) ![]const u8 {
    \\        return try std.fmt.allocPrint(allocator, "{s}", .{self.panel_name.?});
    \\    }
    \\
    \\    fn copyOf(values: Options, allocator: std.mem.Allocator) !*Options {
    \\        var copy_of: *Options = try allocator.create(Options);
    \\        // Null optional members for fn reset.
    \\        copy_of.screen_name = null;
    \\        copy_of.panel_name = null;
    \\        try copy_of.reset(allocator, values);
    \\        errdefer copy_of.deinit();
    \\        return copy_of;
    \\    }
    \\
    \\    pub fn deinit(self: *Options, allocator: std.mem.Allocator) void {
    \\        // Screen name.
    \\        if (self.screen_name) |member| {
    \\            allocator.free(member);
    \\        }
    \\        // Panel name.
    \\        if (self.panel_name) |member| {
    \\            allocator.free(member);
    \\        }
    \\        allocator.destroy(self);
    \\    }
    \\
    \\    fn reset(
    \\        self: *Options,
    \\        allocator: std.mem.Allocator,
    \\        settings: Options,
    \\    ) !void {
    \\        return self._reset(
    \\            allocator,
    \\            settings.screen_name,
    \\            settings.panel_name,
    \\        );
    \\    }
    \\
    \\    fn resetWithScreenOptions(
    \\        self: *Options,
    \\        allocator: std.mem.Allocator,
    \\        screen_options: ScreenOptions,
    \\    ) !void {
    \\        return self._reset(
    \\            allocator,
    \\            screen_options.screen_name,
    \\            null,
    \\        );
    \\    }
    \\
    \\    fn _reset(
    \\        self: *Options,
    \\        allocator: std.mem.Allocator,
    \\        screen_name: ?[]const u8,
    \\        panel_name: ?[]const u8,
    \\    ) !void {
    \\        // Screen name.
    \\        if (screen_name) |reset_value| {
    \\            if (self.screen_name) |value| {
    \\                allocator.free(value);
    \\            }
    \\            self.screen_name = try allocator.alloc(u8, reset_value.len);
    \\            errdefer {
    \\                self.screen_name = null;
    \\                self.deinit();
    \\            }
    \\            @memcpy(@constCast(self.screen_name.?), reset_value);
    \\        }
    \\        // Panel name.
    \\        if (panel_name) |reset_value| {
    \\            if (self.panel_name) |value| {
    \\                allocator.free(value);
    \\            }
    \\            self.panel_name = try allocator.alloc(u8, reset_value.len);
    \\            errdefer {
    \\                self.panel_name = null;
    \\                self.deinit();
    \\            }
    \\            @memcpy(@constCast(self.panel_name.?), reset_value);
    \\        }
    \\    }
    \\};
    \\
    \\pub const View = struct {
    \\    allocator: std.mem.Allocator,
    \\    window: *dvui.Window,
    \\    main_view: *MainView,
    \\    container: ?*Container,
    \\
;

const line_start_2_messenger: []const u8 =
    \\    messenger: *Messenger,
    \\
;

// screen name {0s}
// tab name {1s}
const line_start_3_f: []const u8 =
    \\    exit: ExitFn,
    \\    lock: std.Thread.Mutex,
    \\    state: ?*Options,
    \\
    \\    const default_settings = Options{{
    \\        .screen_name = "{0s}",
    \\        .panel_name = "{1s}",
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
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        // Get a copy of State.
    \\        const settings: *Options = try Options.copyOf(self.state.?.*, arena);
    \\        defer settings.deinit(arena);
    \\        const screen_name: []const u8 = try settings.label(arena);
    \\        defer arena.free(screen_name);
    \\
    \\        // Content is layed out in a vertical stack.
    \\        // The vertical stack will have 2 rows.
    \\        // Row 1 is the screen name.
    \\        // Row 2 is the scroller with it's own vertically stacked content.
    \\        var vertical_stack_layout: *dvui.BoxWidget = dvui.box(
    \\            @src(),
    \\            .vertical,
    \\            .{{
    \\                .expand = .both,
    \\                .background = true,
    \\            }},
    \\        ) catch |err| {{
    \\            self.exit(@src(), err, "{0s}.{1s} vertical_stack_layout");
    \\            return err;
    \\        }};
    \\        defer vertical_stack_layout.deinit();
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
    \\            dvui.labelNoFmt(@src(), screen_name, .{{ .font_style = .title }}) catch |err| {{
    \\                self.exit(@src(), err, "{0s}.{1s} row1 label");
    \\                return err;
    \\            }};
    \\        }}
    \\
    \\        // Vertical Stack Row 2: The vertical scroller.
    \\        // The vertical scroller has it's contents vertically stacked.
    \\        var scroller = dvui.scrollArea(@src(), .{{}}, .{{ .expand = .both }}) catch |err| {{
    \\            self.exit(@src(), err, "{0s}.{1s} scroller");
    \\            return err;
    \\        }};
    \\        defer scroller.deinit();
    \\
    \\        // Vertically stack the scroller's contents.
    \\        var scroller_layout: *dvui.BoxWidget = dvui.box(@src(), .vertical, .{{ .expand = .horizontal }}) catch |err| {{
    \\            self.exit(@src(), err, "{0s}.{1s} scroller_layout");
    \\            return err;
    \\        }};
    \\        defer scroller_layout.deinit();
    \\
    \\        {{
    \\            // Scroller's Content Row 1. The panel's name.
    \\            // Row 1 has 2 columns.
    \\            var scroller_row1: *dvui.BoxWidget = dvui.box(@src(), .horizontal, .{{}}) catch |err| {{
    \\                self.exit(@src(), err, "{0s}.{1s} scroller_row1");
    \\                return err;
    \\            }};
    \\            defer scroller_row1.deinit();
    \\            // Row 1 Column 1: The label.
    \\            dvui.labelNoFmt(@src(), "Panel Name: ", .{{ .font_style = .heading }}) catch |err| {{
    \\                self.exit(@src(), err, "{0s}.{1s} scroller_row1 heading");
    \\                return err;
    \\            }};
    \\            // Row 1 Column 2: The panel's name.
    \\            dvui.labelNoFmt(@src(), settings.panel_name.?, .{{}}) catch |err| {{
    \\                self.exit(@src(), err, "{0s}.{1s} scroller_row1 text");
    \\                return err;
    \\            }};
    \\        }}
    \\        {{
    \\            // Scroller's Content Row 2.
    \\            // Instructions using a text layout widget.
    \\            var scroller_row2 = dvui.TextLayoutWidget.init(
    \\                @src(),
    \\                .{{}},
    \\                .{{
    \\                    .expand = .horizontal,
    \\                }},
    \\            );
    \\            defer scroller_row2.deinit();
    \\            scroller_row2.install(.{{}}) catch |err| {{
    \\                self.exit(@src(), err, "{0s}.{1s} scroller_row2 instructions");
    \\                return err;
    \\            }};
    \\
    \\            const intructions: []const u8 =
    \\                \\The {0s} screen is a tab-bar layout.
    \\                \\The {1s} tab uses the {1s} panel and this view for content.
    \\                \\Tab screens function as a tab-bar showing the content of the selectd tab.
    \\                \\
    \\                \\Using this screen:
    \\                \\ 1. In the main menu:
    \\                \\    * Add .{0s} to pub const sorted_main_menu_screen_tags in src/deps/main_menu/api.zig.
    \\                \\ 2. As content for a tab in another tab screen.
    \\                \\    * kickzig add-tab «screen-name» *{0s} «[*]other-tab-names ...»
    \\                \\
    \\            ;
    \\            try scroller_row2.addText(intructions, .{{}});
    \\        }}
    \\
;

/// {0s} is screen name.
/// {1s} is panel name.
/// {2d} is row number.
const line_close_container_f: []const u8 =
    \\
    \\        // Scroller's Content Row {2d}.
    \\        // A button which closes the container.
    \\        if (self.container.?.isCloseable()) {{
    \\            // This screens container can be closed.
    \\            // Allow the user to close the container.
    \\            const pressed: bool = dvui.button(@src(), "Close Container.", .{{}}, .{{}}) catch |err| {{
    \\                self.exit(@src(), err, "{0s}.{1s} row{2d} close container button");
    \\                return err;
    \\            }};
    \\            if (pressed) {{
    \\                self.container.?.close();
    \\            }}
    \\        }}
    \\
;

/// {0s} is screen name.
/// {1s} is panel name.
/// {2d} is row number.
const line_end_1_f: []const u8 =
    \\
    \\        // Scroller's Content Row {2d}.
    \\        // A button which opens the OK modal screen using 1 column.
    \\        const pressed: bool = dvui.button(@src(), "OK Modal Screen.", .{{}}, .{{}}) catch |err| {{
    \\            self.exit(@src(), err, "{0s}.{1s} row{2d} OK Modal button");
    \\            return err;
    \\        }};
    \\        if (pressed) {{
    \\            // Modal params a part of the modal state.
    \\            // There fore using the gpa not the arena.
    \\            const ok_args = OKModalParams.init(self.allocator, "Using the OK Modal Screen!", "This is the OK modal activated from the {1s} panel in the {0s} screen.") catch |err| {{
    \\                self.exit(@src(), err, "{0s}.{1s} row{2d} ok_args");
    \\                return err;
    \\            }};
    \\            self.main_view.showOK(ok_args);
    \\        }}
    \\    }}
    \\
    \\    /// The caller owns the returned value.
    \\    pub fn label(self: *View, allocator: std.mem.Allocator) ![]const u8 {{
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        return self.state.?.label(allocator);
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
    \\        self.lock = std.Thread.Mutex{};
    \\        errdefer allocator.destroy(self);
    \\        self.allocator = allocator;
    \\        self.state = Options.copyOf(default_settings, allocator) catch |err| {
    \\            self.state = null;
    \\            self.deinit();
    \\            return err;
    \\        };
    \\        try self.state.?.resetWithScreenOptions(allocator, screen_options);
    \\        errdefer self.deinit();
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
    \\    /// setState uses the not null members of param settings to modify self.state.
    \\    /// param settings is owned by the caller.
    \\    pub fn setState(self: *View, settings: Options) !void {{
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        self.state.?.reset(self.allocator, settings) catch |err| {{
    \\            self.exit(@src(), err, "{0s}.{1s} unable to set state");
    \\            return err;
    \\        }};
    \\        self.container.?.refresh();
    \\    }}
    \\
    \\    /// The caller owns the returned value.
    \\    pub fn getState(self: *View) !*Options {{
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        return Options.copyOf(self.state.?.*, self.allocator) catch |err| {{
    \\            self.exit(@src(), err, "{0s}.{1s} unable to set state");
    \\            return err;
    \\        }};
    \\    }}
    \\
    \\    pub fn willFrame(self: *View) bool {{
    \\        _ = self;
    \\        return true;
    \\    }}
    \\}};
    \\
;
