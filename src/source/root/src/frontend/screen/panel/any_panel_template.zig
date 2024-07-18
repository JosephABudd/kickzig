const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    panel_name: []const u8,
    all_panel_names: [][]const u8, // default is first name.
    kind: Kind,

    const Kind = enum {
        Content,
        Panel,
    };

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
        defer {
            while (lines.popOrNull()) |deinit_line| {
                self.allocator.free(deinit_line);
            }
            lines.deinit();
        }

        // The first line.
        var line: []const u8 = undefined;
        line = try self.buildLineStart();
        try lines.append(line);

        // The buttons to the other panels.
        var row_number: usize = 4;
        for (self.all_panel_names) |panel_name| {
            if (std.mem.eql(u8, panel_name, self.panel_name)) {
                // Already at this panel.
            } else {
                line = try self.buildLineSwitch(row_number, panel_name);
                try lines.append(line);
                row_number += 1;
            }
        }

        // The close container line.
        line = try self.buildLineCloseContainer(row_number);
        try lines.append(line);
        row_number += 1;

        // The last line.
        line = try self.buildLineEnd(row_number);
        try lines.append(line);

        const slices: [][]const u8 = try lines.toOwnedSlice();
        return std.mem.join(self.allocator, "", slices);
    }

    // The caller owns the return value.
    fn buildLineStart(self: *Template) ![]const u8 {
        var lines: std.ArrayList([]const u8) = std.ArrayList([]const u8).init(self.allocator);
        defer {
            while (lines.popOrNull()) |deinit_line| {
                self.allocator.free(deinit_line);
            }
            lines.deinit();
        }

        // screen_name
        try lines.append(line_start);
        switch (self.kind) {
            .Content => try lines.append(line_row2_instructions_content),
            .Panel => try lines.append(line_row2_instructions_panel),
        }
        if (self.all_panel_names.len > 0) {
            try lines.append(line_row2_instructions_other_panels);
        } else {
            try lines.append(line_row2_instructions_no_other_panels);
        }
        try lines.append(line_row2_end);
        const slices: []const []const u8 = try lines.toOwnedSlice();
        const line = try std.mem.join(self.allocator, "", slices);
        defer self.allocator.free(line);

        // Now that the line has been constructed do the replacements.
        var size: usize = std.mem.replacementSize(u8, line, "{{ screen_name }}", self.screen_name);
        const with_screen_name: []u8 = try self.allocator.alloc(u8, size);
        defer self.allocator.free(with_screen_name);
        _ = std.mem.replace(u8, line, "{{ screen_name }}", self.screen_name, with_screen_name);

        // panel_name
        size = std.mem.replacementSize(u8, with_screen_name, "{{ panel_name }}", self.panel_name);
        const with_panel_name: []u8 = try self.allocator.alloc(u8, size);
        _ = std.mem.replace(u8, with_screen_name, "{{ panel_name }}", self.panel_name, with_panel_name);
        return with_panel_name;
    }

    // The caller owns the return value.
    fn buildLineSwitch(self: *Template, row_number: usize, panel_name: []const u8) ![]const u8 {

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

    fn buildLineCloseContainer(self: *Template, row_number: usize) ![]const u8 {

        // row_number
        const row_number_str: []const u8 = try std.fmt.allocPrint(self.allocator, "{d}", .{row_number});
        const size: usize = std.mem.replacementSize(u8, line_close_container, "{{ row_number }}", row_number_str);
        const with_row_number: []u8 = try self.allocator.alloc(u8, size);
        _ = std.mem.replace(u8, line_close_container, "{{ row_number }}", row_number_str, with_row_number);
        return with_row_number;
    }

    // The caller owns the return value.
    fn buildLineEnd(self: *Template, row_number: usize) ![]const u8 {

        // row_number
        const row_number_str: []const u8 = try std.fmt.allocPrint(self.allocator, "{d}", .{row_number});
        defer self.allocator.free(row_number_str);
        var size: usize = std.mem.replacementSize(u8, line_end, "{{ row_number }}", row_number_str);
        const with_row_number: []u8 = try self.allocator.alloc(u8, size);
        defer self.allocator.free(with_row_number);
        _ = std.mem.replace(u8, line_end, "{{ row_number }}", row_number_str, with_row_number);

        // screen_name
        size = std.mem.replacementSize(u8, with_row_number, "{{ screen_name }}", self.screen_name);
        const with_screen_name: []u8 = try self.allocator.alloc(u8, size);
        defer self.allocator.free(with_screen_name);
        _ = std.mem.replace(u8, with_row_number, "{{ screen_name }}", self.screen_name, with_screen_name);

        // panel_name
        size = std.mem.replacementSize(u8, with_screen_name, "{{ panel_name }}", self.panel_name);
        const with_panel_name: []u8 = try self.allocator.alloc(u8, size);
        _ = std.mem.replace(u8, with_screen_name, "{{ panel_name }}", self.panel_name, with_panel_name);
        return with_panel_name;
    }
};

pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, panel_name: []const u8, all_panel_names: []const []const u8, only_frame_in_container: bool) !*Template {
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
    self.kind = switch (only_frame_in_container) {
        true => .Content,
        false => .Panel,
    };

    return self;
}

const line_start =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const _lock_ = @import("lock");
    \\const _messenger_ = @import("messenger.zig");
    \\const _panels_ = @import("panels.zig");
    \\const _various_ = @import("various");
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\const OKModalParams = @import("modal_params").OK;
    \\
    \\// KICKZIG TODO:
    \\// Remember. Defers happen in reverse order.
    \\// When updating panel state.
    \\//     self.lock();
    \\//     defer self.unlock(); //  2nd defer: Unlocks.
    \\//     defer self.refresh(); // 1st defer: Refreshes the main view.
    \\//     // DO THE UPDATES.
    \\
    \\pub const Panel = struct {
    \\    allocator: std.mem.Allocator, // For persistant state data.
    \\    lock: *_lock_.ThreadLock, // For persistant state data.
    \\    window: *dvui.Window,
    \\    main_view: *MainView,
    \\    container: ?*_various_.Container,
    \\    all_panels: *_panels_.Panels,
    \\    messenger: *_messenger_.Messenger,
    \\    exit: ExitFn,
    \\
    \\    /// frame this panel.
    \\    /// Layout, Draw, Handle user events.
    \\    /// The arena allocator is for building this frame. Not for state.
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
    \\        var layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{ .expand = .horizontal });
    \\        defer layout.deinit();
    \\
    \\        {
    \\            // Row 2.a example: This panel's name using 2 columns.
    \\            var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
    \\            defer row.deinit();
    \\
    \\            try dvui.labelNoFmt(@src(), "Panel Name: ", .{ .font_style = .heading });
    \\            try dvui.labelNoFmt(@src(), "{{ panel_name }}", .{});
    \\        }
    \\        {
    \\            // Row 2.b example: Information using a text layout widget.
    \\            var tl = dvui.TextLayoutWidget.init(
    \\                @src(),
    \\                .{},
    \\                .{
    \\                    .expand = .horizontal,
    \\                },
    \\            );
    \\            try tl.install(.{});
    \\            defer tl.deinit();
    \\
;

const line_row2_instructions_panel =
    \\            const intructions: []const u8 =
    \\                \\The {{ screen_name }} screen is a panel screen.
    \\                \\
    \\                \\The framework will initialize this screen for you at startup. You will need to add this screen's tag to pub const sorted_main_menu_screen_tags in src/frontend/main_menu.zig.
    \\                \\
    \\                \\This same screen may also be used as content for a tab. In that case the tab will initialize it's own instance if this screen.
    \\                \\
    \\                \\Panel screens function by showing only one panel at a time. You can view the other panels in this screen using the switch buttons below.
    \\                \\
    \\
;

const line_row2_instructions_content =
    \\            const intructions: []const u8 =
    \\                \\The {{ screen_name }} screen is a content screen.
    \\                \\
    \\                \\This screen must only be used as content for a tab. The tab will initialize it's own instance if this screen.
    \\                \\
    \\                \\Content screens function by showing only one panel at a time. You can view the other panels in this screen using the switch buttons below.
    \\                \\
    \\
;

const line_row2_instructions_no_other_panels =
    \\            ;
;

const line_row2_instructions_other_panels =
    \\                \\The other panels in this screen can be viewed using the buttons below.
    \\                \\
    \\            ;
;

const line_row2_end =
    \\            try tl.addText(intructions, .{});
    \\        }
    \\
;

const line_row_switch_panel_button =
    \\        {
    \\            // Row {{ row_number }} example: A button which switches panels.
    \\            if (try dvui.button(@src(), "Switch to the {{ panel_name }} panel.", .{}, .{})) {
    \\                self.all_panels.setCurrentTo{{ panel_name }}();
    \\            }
    \\        }
    \\
;

const line_close_container =
    \\        // Row {{ row_number }} example: A button which closes the container.
    \\        if (self.container) |container| {
    \\            // This screen is framing inside a container.
    \\            // Allow the user to close the container.
    \\            if (try dvui.button(@src(), "Close Container.", .{}, .{})) {
    \\                container.close();
    \\            }
    \\        }
    \\
;

const line_end =
    \\        // Row {{ row_number }} example: A button which opens the OK modal screen using 1 column.
    \\        if (try dvui.button(@src(), "OK Modal Screen.", .{}, .{})) {
    \\            const ok_args = try OKModalParams.init(self.allocator, "Using the OK Modal Screen!", "This is the OK modal activated from the {{ panel_name }} panel in the {{ screen_name }} screen.");
    \\            self.main_view.showOK(ok_args);
    \\        }
    \\    }
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        // The screen will deinit the container.
    \\        self.lock.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// refresh only if this panel and ( container or screen ) are showing.
    \\    pub fn refresh(self: *Panel) void {
    \\        if (self.all_panels.current_panel_tag == .{{ panel_name }}) {
    \\            // This is the current panel.
    \\            if (self.container) |container| {
    \\                // Refresh the container.
    \\                // The container will refresh only if it's the currently viewed screen.
    \\                container.refresh();
    \\            } else {
    \\                // Main view will refresh only if this is the currently viewed screen.
    \\                self.main_view.refresh{{ screen_name }}();
    \\            }
    \\        }
    \\    }
    \\
    \\    pub fn setContainer(self: *Panel, container: *_various_.Container) void {
    \\        self.container = container;
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
    \\    panel.container = null;
    \\    return panel;
    \\}
;
