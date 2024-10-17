const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    panel_name: []const u8,
    all_panel_names: [][]const u8, // default is first name.
    use_messenger: bool,

    pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, panel_name: []const u8, all_panel_names: []const []const u8, use_messenger: bool) !*Template {
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

        self.all_panel_names = try allocator.alloc([]const u8, all_panel_names.len);
        errdefer {
            allocator.free(self.screen_name);
            allocator.free(self.panel_name);
            allocator.destroy(self);
        }
        for (all_panel_names, 0..) |name, i| {
            self.all_panel_names[i] = allocator.alloc(u8, name.len) catch |err| {
                for (self.all_panel_names, 0..) |deinit_name, j| {
                    if (j == i) {
                        break;
                    }
                    allocator.free(deinit_name);
                }
                allocator.free(self.all_panel_names);
                allocator.free(self.screen_name);
                allocator.free(self.panel_name);
                allocator.destroy(self);
                return err;
            };
            @memcpy(@constCast(@constCast(self.all_panel_names)[i]), name);
        }
        self.allocator = allocator;
        self.use_messenger = use_messenger;

        return self;
    }

    pub fn deinit(self: *Template) void {
        for (self.all_panel_names) |deinit_name| {
            self.allocator.free(deinit_name);
        }
        self.allocator.free(self.all_panel_names);
        self.allocator.free(self.screen_name);
        self.allocator.free(self.panel_name);
        self.allocator.destroy(self);
    }

    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        var lines: std.ArrayList(u8) = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        var line: []const u8 = undefined;

        try lines.appendSlice(line_import_start);

        if (self.use_messenger) {
            try lines.appendSlice(line_import_messenger);
        }

        {
            line = try fmt.allocPrint(self.allocator, line_import_modal_params_f, .{self.panel_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_fn_struct_start);

        if (self.use_messenger) {
            try lines.appendSlice(line_fn_init_struct_messenger);
        }

        {
            line = try std.fmt.allocPrint(self.allocator, line_fn_frame_start, .{ self.screen_name, self.panel_name });
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        if (self.all_panel_names.len == 1) {
            try lines.appendSlice(line_fn_frame_instructions_no_other_panels);
        } else {
            try lines.appendSlice(line_fn_frame_instructions_other_panels);
        }

        try lines.appendSlice(line_fn_frame_add_instructions_text);

        // Continue in the scroller's content row 3;
        var row_number: usize = 3;

        // The buttons to the other panels.
        for (self.all_panel_names) |panel_name| {
            if (!std.mem.eql(u8, panel_name, self.panel_name)) {
                line = try std.fmt.allocPrint(self.allocator, line_fn_frame_row_switch_panel_button_f, .{ panel_name, row_number });
                defer self.allocator.free(line);
                try lines.appendSlice(line);
                row_number += 1;
            }
        }

        {
            // Finish fn frame start fn init.
            line = try std.fmt.allocPrint(self.allocator, line_fn_frame_end_fn_init_start, .{ self.screen_name, self.panel_name, row_number });
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        if (self.use_messenger) {
            try lines.appendSlice(line_fn_init_messenger);
        }

        try lines.appendSlice(line_fn_init_continue);

        if (self.use_messenger) {
            try lines.appendSlice(line_fn_init_set_messenger);
        }

        try lines.appendSlice(line_fn_frame_end_fn_init_start_struct_end);

        return try lines.toOwnedSlice();
    }
};

const line_import_start: []const u8 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const Container = @import("cont").Container;
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\
;

const line_import_messenger: []const u8 =
    \\const Messenger = @import("messenger.zig").Messenger;
    \\
;

// screen name {0s}
const line_import_modal_params_f: []const u8 =
    \\const ModalParams = @import("modal_params").{0s};
    \\const Panels = @import("../panels.zig").Panels;
    \\
;

const line_fn_struct_start: []const u8 =
    \\
    \\pub const View = struct {
    \\    allocator: std.mem.Allocator,
    \\    border_color: dvui.Options.ColorOrName,
    \\    window: *dvui.Window,
    \\    main_view: *MainView,
    \\    all_panels: *Panels,
    \\    exit: ExitFn,
    \\
;

const line_fn_init_struct_messenger: []const u8 =
    \\    messenger: *Messenger,
    \\
;

// {0s} is screen name.
// {1s} is the panel name.
const line_fn_frame_start: []const u8 =
    \\
    \\    /// KICKZIG TODO:
    \\    /// fn frame is the View's true purpose.
    \\    /// Layout, Draw, Handle user events.
    \\    /// The arena allocator is for building this frame. Not for state.
    \\    pub fn frame(
    \\        self: *View,
    \\        arena: std.mem.Allocator,
    \\        modal_params: *ModalParams,
    \\    ) !void {{
    \\        _ = modal_params;
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
    \\                self.exit(@src(), err, "row1");
    \\                return err;
    \\            }};
    \\            defer row1.deinit();
    \\
    \\            const screen_name: []const u8 = std.fmt.allocPrint(arena, "{{s}} Screen.", .{{"{0s}"}}) catch |err| {{
    \\                self.exit(@src(), err, "row1 screen_name");
    \\                return err;
    \\            }};
    \\            defer arena.free(screen_name);
    \\            dvui.labelNoFmt(@src(), screen_name, .{{ .font_style = .title }}) catch |err| {{
    \\                self.exit(@src(), err, "row1 label");
    \\                return err;
    \\            }};
    \\        }}
    \\
    \\        {{
    \\            // Vertical Stack Row 2: The vertical scroller.
    \\            // The vertical scroller has it's contents vertically stacked.
    \\            var scroller = dvui.scrollArea(@src(), .{{}}, .{{ .expand = .both }}) catch |err| {{
    \\                self.exit(@src(), err, "scroller");
    \\                return err;
    \\            }};
    \\            defer scroller.deinit();
    \\    
    \\            // Vertically stack the scroller's contents.
    \\            var scroller_layout: *dvui.BoxWidget = dvui.box(@src(), .vertical, .{{ .expand = .horizontal }}) catch |err| {{
    \\                self.exit(@src(), err, "scroller_layout");
    \\                return err;
    \\            }};
    \\            defer scroller_layout.deinit();
    \\    
    \\            {{
    \\                // Scroller's Content Row 1. The panel's name.
    \\                // Row 1 has 2 columns.
    \\                var scroller_row1: *dvui.BoxWidget = dvui.box(@src(), .horizontal, .{{}}) catch |err| {{
    \\                    self.exit(@src(), err, "scroller_row1");
    \\                    return err;
    \\                }};
    \\                defer scroller_row1.deinit();
    \\                // Row 1 Column 1: The label.
    \\                dvui.labelNoFmt(@src(), "Panel Name: ", .{{ .font_style = .heading }}) catch |err| {{
    \\                    self.exit(@src(), err, "scroller_row1 heading");
    \\                    return err;
    \\                }};
    \\                // Row 1 Column 2: The panel's name.
    \\                dvui.labelNoFmt(@src(), "{1s}", .{{}}) catch |err| {{
    \\                    self.exit(@src(), err, "scroller_row1 text");
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
    \\                    self.exit(@src(), err, "scroller_row2 instructions");
    \\                    return err;
    \\                }};
    \\    
    \\                const intructions: []const u8 =
    \\                    \\The {0s} screen is a modal screen.
    \\                    \\Modal screens, like Panel screens, function by showing only one panel at a time.
    \\                    \\
    \\
;

const line_fn_frame_instructions_no_other_panels: []const u8 =
    \\                    \\
    \\                ;
    \\
;

const line_fn_frame_instructions_other_panels: []const u8 =
    \\                    \\The other panels in this screen can be viewed using the buttons below.
    \\                    \\
    \\                ;
    \\
;

const line_fn_frame_add_instructions_text: []const u8 =
    \\                try scroller_row2.addText(intructions, .{});
    \\            }
    \\
;

/// {0s} is panel name.
/// {1d} is row number.
const line_fn_frame_row_switch_panel_button_f: []const u8 =
    \\            {{
    \\                // Scroller's Content Row {1d}.
    \\                // A button which switches panels.
    \\                const pressed: bool = dvui.button(@src(), "Switch to the {0s} panel.", .{{}}, .{{}}) catch |err| {{
    \\                    self.exit(@src(), err, "row{1d} switch panel button");
    \\                    return err;
    \\                }};
    \\                if (pressed) {{
    \\                    self.all_panels.setCurrentTo{0s}();
    \\                }}
    \\            }}
    \\
;

// {0s} is screen name.
/// {1s} is panel name.
// {1d} is row number.
const line_fn_frame_end_fn_init_start: []const u8 =
    \\            {{
    \\                // Scroller's Content Row {2d}.
    \\                // A button which closes this modal screen.
    \\                const pressed: bool = dvui.button(@src(), "Close this modal screen.", .{{}}, .{{}}) catch |err| {{
    \\                    self.exit(@src(), err, "row{2d} close button");
    \\                    return err;
    \\                }};
    \\                if (pressed) {{
    \\                    self.close();
    \\                }}
    \\            }}
    \\        }}
    \\    }}
    \\
    \\    // close removes this modal screen replacing it with the previous screen.
    \\    fn close(self: *View) void {{
    \\        self.main_view.hide{0s}();
    \\    }}
    \\
    \\    /// refresh only if this panel is showing and this screen is showing.
    \\    pub fn refresh(self: *View) void {{
    \\        if (self.all_panels.current_panel_tag == .{1s}) {{
    \\            self.main_view.refresh{0s}();
    \\        }}
    \\    }}
    \\
    \\    pub fn init(
    \\        allocator: std.mem.Allocator,
    \\        window: *dvui.Window,
    \\        main_view: *MainView,
    \\        all_panels: *Panels,
    \\
;

const line_fn_init_messenger: []const u8 =
    \\        messenger: *Messenger,
    \\
;

const line_fn_init_continue: []const u8 =
    \\        exit: ExitFn,
    \\        theme: *dvui.Theme,
    \\    ) !*View {
    \\        var self: *View = try allocator.create(View);
    \\        errdefer allocator.destroy(self);
    \\        self.allocator = allocator;
    \\        self.window = window;
    \\        self.main_view = main_view;
    \\        self.all_panels = all_panels;
    \\
;

const line_fn_init_set_messenger: []const u8 =
    \\        self.messenger = messenger;
    \\
;

const line_fn_frame_end_fn_init_start_struct_end: []const u8 =
    \\        self.exit = exit;
    \\        self.border_color = theme.style_accent.color_accent.?;
    \\        return self;
    \\    }
    \\
    \\    pub fn deinit(self: *View) void {
    \\        self.allocator.destroy(self);
    \\    }
    \\};
    \\
;
