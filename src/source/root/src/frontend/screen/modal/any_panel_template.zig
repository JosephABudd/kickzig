const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    panel_name: []const u8,
    all_panel_names: [][]const u8, // default is first name.

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
        var lines: std.ArrayList([]const u8) = std.ArrayList([]const u8).init(self.allocator);
        defer lines.deinit();

        // The first line.
        var line: []const u8 = undefined;
        line = try self.buildLineStart();
        try lines.append(line);
        errdefer {
            while (lines.popOrNull()) |deinit_line| {
                self.allocator.free(deinit_line);
            }
        }

        // The buttons to the other panels.
        var row_number: usize = 4;
        for (self.all_panel_names) |panel_name| {
            if (std.mem.eql(u8, panel_name, self.panel_name)) {
                // Already at this panel.
            } else {
                line = try self.buildLineSwitch(row_number, panel_name);
                errdefer {
                    while (lines.popOrNull()) |deinit_line| {
                        self.allocator.free(deinit_line);
                    }
                }
                try lines.append(line);
                errdefer {
                    while (lines.popOrNull()) |deinit_line| {
                        self.allocator.free(deinit_line);
                    }
                }
                row_number += 1;
            }
        }

        // The last line.
        line = try self.buildLineEnd(row_number);
        errdefer {
            while (lines.popOrNull()) |deinit_line| {
                self.allocator.free(deinit_line);
            }
        }
        try lines.append(line);
        errdefer {
            while (lines.popOrNull()) |deinit_line| {
                self.allocator.free(deinit_line);
            }
        }

        const slices: [][]const u8 = try lines.toOwnedSlice();
        errdefer {
            while (lines.popOrNull()) |deinit_line| {
                self.allocator.free(deinit_line);
            }
        }
        return std.mem.join(self.allocator, "", slices);
    }

    // The caller owns the return value.
    pub fn buildLineStart(self: *Template) ![]const u8 {
        // screen_name
        var size: usize = std.mem.replacementSize(u8, line_start, "{{ screen_name }}", self.screen_name);
        const with_screen_name: []u8 = try self.allocator.alloc(u8, size);
        defer self.allocator.free(with_screen_name);
        _ = std.mem.replace(u8, line_start, "{{ screen_name }}", self.screen_name, with_screen_name);
        // panel_name
        size = std.mem.replacementSize(u8, with_screen_name, "{{ panel_name }}", self.panel_name);
        const with_panel_name: []u8 = try self.allocator.alloc(u8, size);
        _ = std.mem.replace(u8, with_screen_name, "{{ panel_name }}", self.panel_name, with_panel_name);
        return with_panel_name;
    }

    // The caller owns the return value.
    pub fn buildLineSwitch(self: *Template, row_number: usize, panel_name: []const u8) ![]const u8 {

        // row_number
        const row_number_str: []const u8 = try std.fmt.allocPrint(self.allocator, "{d}", .{row_number});
        defer self.allocator.free(row_number_str);
        var size: usize = std.mem.replacementSize(u8, line_row_switch_panel_button, "{{ row_number }}", row_number_str);
        const with_row_number: []u8 = try self.allocator.alloc(u8, size);
        defer self.allocator.free(with_row_number);
        _ = std.mem.replace(u8, line_row_switch_panel_button, "{{ row_number }}", row_number_str, with_row_number);

        // panel_name
        size = std.mem.replacementSize(u8, with_row_number, "{{ panel_name }}", panel_name);
        const with_panel_name: []u8 = try self.allocator.alloc(u8, size);
        _ = std.mem.replace(u8, with_row_number, "{{ panel_name }}", panel_name, with_panel_name);
        return with_panel_name;
    }

    // The caller owns the return value.
    pub fn buildLineEnd(self: *Template, row_number: usize) ![]const u8 {
        // row_number
        const row_number_str: []const u8 = try std.fmt.allocPrint(self.allocator, "{d}", .{row_number});
        defer self.allocator.free(row_number_str);
        const size: usize = std.mem.replacementSize(u8, line_end, "{{ row_number }}", row_number_str);
        const with_row_number: []u8 = try self.allocator.alloc(u8, size);
        _ = std.mem.replace(u8, line_end, "{{ row_number }}", row_number_str, with_row_number);
        return with_row_number;
    }
};

pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, panel_name: []const u8, all_panel_names: []const []const u8) !*Template {
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
    return self;
}

const line_start =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const _channel_ = @import("channel");
    \\const _lock_ = @import("lock");
    \\const _messenger_ = @import("messenger.zig");
    \\const _panels_ = @import("panels.zig");
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\const ModalParams = @import("modal_params").{{ screen_name }};
    \\
    \\pub const Panel = struct {
    \\    allocator: std.mem.Allocator, // For persistant state data.
    \\    lock: *_lock_.ThreadLock, // For persistant state data.
    \\    window: *dvui.Window,
    \\    main_view: *MainView,
    \\    all_panels: *_panels_.Panels,
    \\    messenger: *_messenger_.Messenger,
    \\    exit: ExitFn,
    \\
    \\    modal_params: ?*ModalParams,
    \\
    \\    // The screen owns the modal params.
    \\    pub fn presetModal(self: *Panel, setup_args: *ModalParams) !void {
    \\        // previous modal_params are already deinited by the screen.
    \\        self.modal_params = setup_args;
    \\    }
    \\
    \\    /// refresh only if this panel is showing and this screen is showing.
    \\    pub fn refresh(self: *Panel) void {
    \\        if (self.all_panels.current_panel_tag == .{{ panel_name }}) {
    \\            self.main_view.refresh{{ screen_name }}();
    \\        }
    \\    }
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        // modal_params are already deinited by the screen.
    \\        self.lock.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    // close removes this modal screen replacing it with the previous screen.
    \\    fn close(self: *Panel) void {
    \\        self.main_view.hide{{ screen_name }}();
    \\    }
    \\
    \\    /// frame this panel.
    \\    /// Layout, Draw, Handle user events.
    \\    pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {
    \\        _ = arena;
    \\
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        {
    \\            // Row 1: The screen's name using 1 column.
    \\            // Use the same background as the scroller.
    \\            var row: *dvui.BoxWidget = try dvui.box(
    \\                @src(),
    \\                .horizontal,
    \\                .{
    \\                    .expand = .horizontal,
    \\                    .background = true,
    \\                },
    \\            );
    \\            defer row.deinit();
    \\
    \\            try dvui.labelNoFmt(@src(), "{{ screen_name }} Screen.", .{ .font_style = .title });
    \\        }
    \\
    \\        var scroller = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
    \\        defer scroller.deinit();
    \\
    \\        var layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{});
    \\        defer layout.deinit();
    \\
    \\        {
    \\            // Row 2 example: This panel's name using 2 columns.
    \\            var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
    \\            defer row.deinit();
    \\
    \\            try dvui.labelNoFmt(@src(), "Panel Name: ", .{ .font_style = .heading });
    \\            try dvui.labelNoFmt(@src(), "{{ panel_name }}", .{});
    \\        }
    \\        {
    \\            // Row 3 example: Information using 1 column.
    \\            var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
    \\            defer row.deinit();
    \\
    \\            try dvui.label(@src(), "This panel is displaying it's screen name as a heading.\nBelow that is a scroll area displaying the rest of the panel's content.\n", .{}, .{});
    \\        }
    \\
;

const line_row_switch_panel_button =
    \\        {
    \\            // Row {{ row_number }} example: Information using 1 column.
    \\            var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
    \\            defer row.deinit();
    \\
    \\            if (try dvui.button(@src(), "Switch to the {{ panel_name }} panel.", .{}, .{})) {
    \\                self.all_panels.setCurrentTo{{ panel_name }}();
    \\            }
    \\        }
    \\
;

const line_end =
    \\
    \\        {
    \\            // Row {{ row_number }} example: The close button closes this modal screen and returns to the previous screen.
    \\            if (try dvui.button(@src(), "Close", .{}, .{})) {
    \\                self.close();
    \\            }
    \\        }
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, main_view: *MainView, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panel {
    \\    var panel: *Panel = try allocator.create(Panel);
    \\    panel.lock = try _lock_.init(allocator);
    \\    errdefer {
    \\        allocator.destroy(panel);
    \\    }
    \\    panel.allocator = allocator;
    \\    panel.main_view = main_view;
    \\    panel.all_panels = all_panels;
    \\    panel.messenger = messenger;
    \\    panel.exit = exit;
    \\    panel.window = window;
    \\    panel.modal_params = null;
    \\    return panel;
    \\}
;
