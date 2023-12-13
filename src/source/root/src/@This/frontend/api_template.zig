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
        try lines.appendSlice(line1);
        var line: []u8 = undefined;

        // vtab screens.
        var vtab_screen_names: [][]const u8 = self._vtab_screen_names[0..self._vtab_screen_names_index];
        for (vtab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, "const _{0s}_ = @import(\"screen/vtab/{0s}/screen.zig\");\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // htab screens.
        var htab_screen_names: [][]const u8 = self._htab_screen_names[0..self._htab_screen_names_index];
        for (htab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, "const _{0s}_ = @import(\"screen/htab/{0s}/screen.zig\");\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // panel screens.
        var panel_screen_names: [][]const u8 = self._panel_screen_names[0..self._panel_screen_names_index];
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, "const _{0s}_ = @import(\"screen/panel/{0s}/screen.zig\");\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // book screens.
        var book_screen_names: [][]const u8 = self._book_screen_names[0..self._book_screen_names_index];
        for (book_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, "const _{0s}_ = @import(\"screen/book/{0s}/screen.zig\");\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // modal screens.
        var modal_screen_names: [][]const u8 = self._modal_screen_names[0..self._modal_screen_names_index];
        for (modal_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, "const _{0s}_ = @import(\"screen/modal/{0s}/screen.zig\");\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line2);

        // init modal screens.
        for (modal_screen_names, 0..) |name, i| {
            if (i == 0) {
                try lines.appendSlice("    // Modal screens.\n");
            }
            line = try fmt.allocPrint(self.allocator, "    try _{0s}_.init(allocator, all_screens, send_channel, receive_channel);\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // init vtabs screens.
        for (vtab_screen_names, 0..) |name, i| {
            if (i == 0) {
                try lines.appendSlice("    // VTab screens.\n");
            }
            line = try fmt.allocPrint(self.allocator, "    try _{0s}_.init(allocator, all_screens, send_channel, receive_channel);\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // init htabs screens.
        for (htab_screen_names, 0..) |name, i| {
            if (i == 0) {
                try lines.appendSlice("    // HTab screens.\n");
            }
            line = try fmt.allocPrint(self.allocator, "    try _{0s}_.init(allocator, all_screens, send_channel, receive_channel);\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // init panel screens.
        for (panel_screen_names, 0..) |name, i| {
            if (i == 0) {
                try lines.appendSlice("    // Panel screens.\n");
            }
            line = try fmt.allocPrint(self.allocator, "    try _{0s}_.init(allocator, all_screens, send_channel, receive_channel);\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // init book screens.
        for (book_screen_names, 0..) |name, i| {
            if (i == 0) {
                try lines.appendSlice("    // Book screens.\n");
            }
            line = try fmt.allocPrint(self.allocator, "    try _{0s}_.init(allocator, all_screens, send_channel, receive_channel);\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // end.
        try lines.appendSlice(line3);

        var temp: []const u8 = try lines.toOwnedSlice();
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
    \\const _channel_ = @import("channel");
    \\const _framers_ = @import("framers");
    \\
;
// \\const _simple_screen_ = @import("screen/panel/simple/screen.zig");
// \\const _hard_screen_ = @import("screen/panel/hard/screen.zig");
// \\const _htabs_screen_ = @import("screen/htab/htabs/screen.zig");
// \\const _vtabs_screen_ = @import("screen/vtab/vtabs/screen.zig");
// \\const _crud_screen_ = @import("screen/htab/crud/screen.zig");
// \\const _ok_screen_ = @import("screen/modal/ok/screen.zig");

const line2 =
    \\
    \\pub fn init(allocator: std.mem.Allocator, send_channel: *_channel_.Channels, receive_channel: *_channel_.Channels) !*_framers_.Group {
    \\    // Screens.
    \\    var all_screens: *_framers_.Group = try _framers_.init(allocator);
    \\
    \\    // Set up each screen.
    \\
;
// \\    try _simple_screen_.init(allocator, all_screens, send_channel, receive_channel);
// \\    try _hard_screen_.init(allocator, all_screens, send_channel, receive_channel);
// \\    try _htabs_screen_.init(allocator, all_screens, send_channel, receive_channel);
// \\    try _vtabs_screen_.init(allocator, all_screens, send_channel, receive_channel);
// \\    try _crud_screen_.init(allocator, all_screens, send_channel, receive_channel);
// \\    try _ok_screen_.init(allocator, all_screens, send_channel, receive_channel);

const line3 =
    \\
    \\    // Initialze the example demo window.
    \\    // KICKZIG TODO:
    \\    // When you no longer want to display the example demo window
    \\    //  you can comment the following line out.
    \\    dvui.Examples.show_demo_window = false;
    \\
    \\    // Set the default screen.
    \\    try all_screens.setCurrent(_main_menu_.startup_screen_name);
    \\    return all_screens;
    \\}
    \\
    \\pub fn frame(arena: std.mem.Allocator, all_screens: *_framers_.Group) !void {
    \\    if (!all_screens.isModal()) {
    \\        // Frame the main menu if this is not a modal view.
    \\        try frame_main_menu(all_screens);
    \\    }
    \\    // Frame the current screen.
    \\    try all_screens.frame(arena);
    \\}
    \\
    \\pub fn frame_main_menu(all_screens: *_framers_.Group) !void {
    \\    var m = try dvui.menu(@src(), .horizontal, .{ .background = true, .expand = .horizontal });
    \\    defer m.deinit();
    \\
    \\    if (try dvui.menuItemIcon(@src(), "menu", dvui.entypo.menu, .{ .submenu = true }, .{ .expand = .none })) |r| {
    \\        var fw = try dvui.popup(@src(), dvui.Rect.fromPoint(dvui.Point{ .x = r.x, .y = r.y + r.h }), .{});
    \\        defer fw.deinit();
    \\        
    \\        for (_main_menu_.sorted_main_menu_screen_names, 0..) |screen_name, id_extra| {
    \\            if (try dvui.menuItemLabel(@src(), screen_name, .{}, .{ .id_extra = id_extra }) != null) {
    \\                m.close();
    \\                try all_screens.setCurrent(screen_name);
    \\                return;
    \\            }
    \\        }
    \\
    \\        if (try dvui.menuItemLabel(@src(), "DVUI Debug", .{}, .{}) != null) {
    \\            dvui.toggleDebugWindow();
    \\        }
    \\
    \\        // KICKZIG TODO:
    \\        // When you no longer want to display the developer menu items.
    \\        //  set _main_menu_.show_developer_menu_items to false.
    \\        // Developer menu items.
    \\        if (_main_menu_.show_developer_menu_items) {
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
    \\    }
    \\
    \\    // look at demo() for examples of dvui widgets, shows in a floating window
    \\    // KICKZIG TODO:
    \\    // When you no longer want to display the example demo window
    \\    //  you can comment the following line out.
    \\    try dvui.Examples.demo();
    \\}
    \\
;
