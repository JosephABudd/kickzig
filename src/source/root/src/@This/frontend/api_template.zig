const std = @import("std");
const fmt = std.fmt;
const strings = @import("strings");

pub const Template = struct {
    allocator: std.mem.Allocator,

    _htab_screen_names: [][]const u8,
    _vtab_screen_names: [][]const u8,
    _panel_screen_names: [][]const u8,
    _modal_screen_names: [][]const u8,
    _book_screen_names: [][]const u8,

    _htab_screen_names_index: usize,
    _vtab_screen_names_index: usize,
    _panel_screen_names_index: usize,
    _modal_screen_names_index: usize,
    _book_screen_names_index: usize,

    _app_name: []const u8,

    pub fn deinit(self: *Template) void {
        for (self._htab_screen_names, 0..) |name, i| {
            if (i == self._htab_screen_names_index) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self._htab_screen_names);

        for (self._vtab_screen_names, 0..) |name, i| {
            if (i == self._vtab_screen_names_index) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self._vtab_screen_names);

        for (self._panel_screen_names, 0..) |name, i| {
            if (i == self._panel_screen_names_index) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self._panel_screen_names);

        for (self._modal_screen_names, 0..) |name, i| {
            if (i == self._modal_screen_names_index) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self._modal_screen_names);

        for (self._book_screen_names, 0..) |name, i| {
            if (i == self._book_screen_names_index) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self._book_screen_names);

        self.allocator.free(self._app_name);
        self.allocator.destroy(self);
    }

    pub fn addVTabScreenName(self: *Template, new_screen_name: []const u8) !void {
        if (self._vtab_screen_names_index == self._vtab_screen_names.len) {
            // Full list so create a new bigger one.
            var new_screen_names: [][]const u8 = try self.allocator.alloc([]const u8, (self._vtab_screen_names.len + 5));
            for (self._vtab_screen_names, 0..) |vtab_screen_name, i| {
                new_screen_names[i] = vtab_screen_name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self._vtab_screen_names);
            self._vtab_screen_names = new_screen_names;
        }
        self._vtab_screen_names[self._vtab_screen_names_index] = try self.allocator.alloc(u8, new_screen_name.len);
        @memcpy(@constCast(self._vtab_screen_names[self._vtab_screen_names_index]), new_screen_name);
        self._vtab_screen_names_index += 1;
    }

    pub fn addHTabScreenName(self: *Template, new_screen_name: []const u8) !void {
        if (self._htab_screen_names_index == self._htab_screen_names.len) {
            // Full list so create a new bigger one.
            var new_screen_names: [][]const u8 = try self.allocator.alloc([]const u8, (self._htab_screen_names.len + 5));
            for (self._htab_screen_names, 0..) |htab_screen_name, i| {
                new_screen_names[i] = htab_screen_name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self._htab_screen_names);
            self._htab_screen_names = new_screen_names;
        }
        self._htab_screen_names[self._htab_screen_names_index] = try self.allocator.alloc(u8, new_screen_name.len);
        @memcpy(@constCast(self._htab_screen_names[self._htab_screen_names_index]), new_screen_name);
        self._htab_screen_names_index += 1;
    }

    pub fn addPanelScreenName(self: *Template, new_screen_name: []const u8) !void {
        if (self._panel_screen_names_index == self._panel_screen_names.len) {
            // Full list so create a new bigger one.
            var new_screen_names: [][]const u8 = try self.allocator.alloc([]const u8, (self._panel_screen_names.len + 5));
            for (self._panel_screen_names, 0..) |panel_screen_name, i| {
                new_screen_names[i] = panel_screen_name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self._panel_screen_names);
            self._panel_screen_names = new_screen_names;
        }
        self._panel_screen_names[self._panel_screen_names_index] = try self.allocator.alloc(u8, new_screen_name.len);
        @memcpy(@constCast(self._panel_screen_names[self._panel_screen_names_index]), new_screen_name);
        self._panel_screen_names_index += 1;
    }

    pub fn addBookScreenName(self: *Template, new_screen_name: []const u8) !void {
        if (self._book_screen_names_index == self._book_screen_names.len) {
            // Full list so create a new bigger one.
            var new_screen_names: [][]const u8 = try self.allocator.alloc([]const u8, (self._book_screen_names.len + 5));
            for (self._book_screen_names, 0..) |book_screen_name, i| {
                new_screen_names[i] = book_screen_name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self._book_screen_names);
            self._book_screen_names = new_screen_names;
        }
        self._book_screen_names[self._book_screen_names_index] = try self.allocator.alloc(u8, new_screen_name.len);
        @memcpy(@constCast(self._book_screen_names[self._book_screen_names_index]), new_screen_name);
        self._book_screen_names_index += 1;
    }

    pub fn addModalScreenName(self: *Template, new_screen_name: []const u8) !void {
        if (self._modal_screen_names_index == self._modal_screen_names.len) {
            // Full list so create a new bigger one.
            var new_screen_names: [][]const u8 = try self.allocator.alloc([]const u8, (self._modal_screen_names.len + 5));
            for (self._modal_screen_names, 0..) |modal_screen_name, i| {
                new_screen_names[i] = modal_screen_name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self._modal_screen_names);
            self._modal_screen_names = new_screen_names;
        }
        self._modal_screen_names[self._modal_screen_names_index] = try self.allocator.alloc(u8, new_screen_name.len);
        @memcpy(@constCast(self._modal_screen_names[self._modal_screen_names_index]), new_screen_name);
        self._modal_screen_names_index += 1;
    }

    pub fn content(self: *Template) ![]const u8 {
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();

        // Start. Imports etc.
        try lines.appendSlice(line1);
        var line: []u8 = undefined;

        // vtab screens.
        const vtab_screen_names: [][]const u8 = self._vtab_screen_names[0..self._vtab_screen_names_index];
        for (vtab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line1_not_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // htab screens.
        const htab_screen_names: [][]const u8 = self._htab_screen_names[0..self._htab_screen_names_index];
        for (htab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line1_not_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // panel screens.
        const panel_screen_names: [][]const u8 = self._panel_screen_names[0..self._panel_screen_names_index];
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line1_not_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // book screens.
        const book_screen_names: [][]const u8 = self._book_screen_names[0..self._book_screen_names_index];
        for (book_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line1_not_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // modal screens.
        const modal_screen_names: [][]const u8 = self._modal_screen_names[0..self._modal_screen_names_index];
        for (modal_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line1_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line2);

        // vtab screens.
        for (vtab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_label, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // htab screens.
        for (htab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_label, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // panel screens.
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_label, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // book screens.
        for (book_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_label, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // modal screens.
        for (modal_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_label, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line3);

        // vtab screens.
        for (vtab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line3_not_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // htab screens.
        for (htab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line3_not_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // panel screens.
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line3_not_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // book screens.
        for (book_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line3_not_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line4);

        const temp: []const u8 = try lines.toOwnedSlice();
        line = try self.allocator.alloc(u8, temp.len);
        @memcpy(line, temp);
        return line;
    }
};

pub fn init(allocator: std.mem.Allocator, app_name: []const u8) !*Template {
    var self: *Template = try allocator.create(Template);
    self._app_name = try allocator.alloc(u8, app_name.len);
    errdefer {
        allocator.destroy(self);
    }
    @memcpy(@constCast(self._app_name), app_name);
    self.allocator = allocator;
    self._htab_screen_names = try allocator.alloc([]const u8, 5);
    self._vtab_screen_names = try allocator.alloc([]const u8, 5);
    self._panel_screen_names = try allocator.alloc([]const u8, 5);
    self._modal_screen_names = try allocator.alloc([]const u8, 5);
    self._book_screen_names = try allocator.alloc([]const u8, 5);
    self._htab_screen_names_index = 0;
    self._vtab_screen_names_index = 0;
    self._panel_screen_names_index = 0;
    self._modal_screen_names_index = 0;
    self._book_screen_names_index = 0;
    return self;
}

const line1 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const _main_menu_ = @import("main_menu.zig");
    \\const _modal_params_ = @import("modal_params");
    \\const _startup_ = @import("startup");
    \\const MainView = @import("framers").MainView;
    \\const ScreenPointers = @import("screen_pointers").ScreenPointers;
    \\
    \\var allocator: std.mem.Allocator = undefined;
    \\var main_view: *MainView = undefined; // standalone-sdl will deinit.
    \\var screen_pointers: *ScreenPointers = undefined;
    \\
    \\pub fn init(startup: *_startup_.Frontend) !void {
    \\    // Set up each all screens.
    \\    allocator = startup.allocator;
    \\    main_view = startup.main_view;
    \\    screen_pointers = try ScreenPointers.init(startup.*);
    \\    // screen_pointers = try startup.allocator.create(ScreenPointers);
    \\    startup.screen_pointers = screen_pointers;
    \\    try screen_pointers.init_screens(startup.*);
    \\
    \\    // Initialze the example demo window.
    \\    // KICKZIG TODO:
    \\    // When you no longer want to display the example demo window
    \\    //  you can comment the following line out.
    \\    dvui.Examples.show_demo_window = false;
    \\
    \\    // Set the default screen.
    \\    try main_view.show(_main_menu_.startup_screen_tag);
    \\}
    \\
    \\pub fn deinit() void {
    \\    screen_pointers.deinit();
    \\}
    \\
    \\pub fn frame(arena: std.mem.Allocator) !void {
    \\    if (main_view.currentTag()) |current_tag| {
    \\        switch (current_tag) {
    \\
;

const line1_not_modal =
    \\            .{0s} => {{
    \\                try frame_main_menu();
    \\                try screen_pointers.{0s}.?.frame(arena);
    \\            }},
    \\
;

const line1_modal =
    \\            .{0s} => {{
    \\                if (main_view.isNewModal()) {{
    \\                    var modal_args: *_modal_params_.{0s} = @alignCast(@ptrCast(main_view.modalArgs()));
    \\                    try screen_pointers.{0s}.?.setState(modal_args);
    \\                }}
    \\                try screen_pointers.{0s}.?.frame(arena);
    \\            }},
    \\
;
// .HelloWorld => {
//     try frame_main_menu();
//     try screen_pointers.HelloWorld.?.frame(arena);
// },
// .YesNo => {
//     if (main_view.isNewModal()) {
//         var modal_args: *_modal_params_.YesNo = @alignCast(@ptrCast(main_view.modalArgs()));
//         try screen_pointers.YesNo.?.setState(modal_args);
//     }
//     try screen_pointers.YesNo.?.frame(arena);
// },

const line2 =
    \\        }
    \\    }
    \\}
    \\
    \\pub fn frame_main_menu() !void {
    \\    if (!_main_menu_.show_main_menu) {
    \\        // Not showing the main menu in this app.
    \\        return;
    \\    }
    \\    var m = try dvui.menu(@src(), .horizontal, .{ .background = true, .expand = .horizontal });
    \\    defer m.deinit();
    \\
    \\    if (try dvui.menuItemIcon(@src(), "menu", dvui.entypo.menu, .{ .submenu = true }, .{ .expand = .none })) |r| {
    \\        var fw = try dvui.floatingMenu(@src(), dvui.Rect.fromPoint(dvui.Point{ .x = r.x, .y = r.y + r.h }), .{});
    \\        defer fw.deinit();
    \\
    \\        for (_main_menu_.sorted_main_menu_screen_tags, 0..) |screen_tag, id_extra| {
    \\            const label: []const u8 = switch (screen_tag) {
    \\
;

const line2_label =
    \\                .{0s} => screen_pointers.{0s}.?.label(),
    \\
;
// .Contacts => screen_pointers.Contacts.?.label(),
// .HelloWorld => screen_pointers.HelloWorld.?.label(),
// .Choice => screen_pointers.Choice.?.label(),
// .YesNo => screen_pointers.YesNo.?.label(),
// .OK => screen_pointers.OK.?.label(),
// .EOJ => screen_pointers.EOJ.?.label(),

const line3 =
    \\            };
    \\
    \\            if (try dvui.menuItemLabel(@src(), label, .{}, .{ .id_extra = id_extra }) != null) {
    \\                m.close();
    \\
    \\                return switch (screen_tag) {
    \\
;

const line3_not_modal =
    \\                    .{0s} => main_view.show(screen_tag),
    \\
;

const line4 =
    \\                    else => blk: {
    \\                        const yesno_args = try _modal_params_.OK.init(
    \\                            allocator,
    \\                            "That won't work.",
    \\                            "Can not open modals from the main menu.",
    \\                        );
    \\                        break :blk main_view.showOK(yesno_args);
    \\                    },
    \\                };
    \\            }
    \\        }
    \\
    \\        // KICKZIG TODO:
    \\        // When you no longer want to display the developer menu items.
    \\        //  set _main_menu_.show_developer_menu_items to false.
    \\        // Developer menu items.
    \\        if (_main_menu_.show_developer_menu_items) {
    \\            if (try dvui.menuItemLabel(@src(), "DVUI Debug", .{}, .{}) != null) {
    \\                dvui.toggleDebugWindow();
    \\            }
    \\            if (dvui.Examples.show_demo_window) {
    \\                if (try dvui.menuItemLabel(@src(), "Hide the DVUI Demo", .{}, .{}) != null) {
    \\                    dvui.Examples.show_demo_window = false;
    \\                }
    \\            } else {
    \\                if (try dvui.menuItemLabel(@src(), "Show the DVUI Demo", .{}, .{}) != null) {
    \\                    dvui.Examples.show_demo_window = true;
    \\                }
    \\            }
    \\        }
    \\
    \\        if (try dvui.menuItemIcon(@src(), "close", dvui.entypo.align_top, .{ .submenu = false }, .{ .expand = .none }) != null) {
    \\            m.close();
    \\            return;
    \\        }
    \\    }
    \\
    \\    // look at demo() for examples of dvui widgets, shows in a floating window
    \\    // KICKZIG TODO:
    \\    // When you no longer want to display the example demo window
    \\    //  you can comment the following line out.
    \\    try dvui.Examples.demo();
    \\}
;
