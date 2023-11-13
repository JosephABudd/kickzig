const std = @import("std");
const fmt = std.fmt;
const strings = @import("strings");

pub const Template = struct {
    allocator: std.mem.Allocator,

    _htab_screen_names: []*strings.UTF8,
    _vtab_screen_names: []*strings.UTF8,
    _panel_screen_names: []*strings.UTF8,
    _modal_screen_names: []*strings.UTF8,

    _htab_screen_names_index: usize,
    _vtab_screen_names_index: usize,
    _panel_screen_names_index: usize,
    _modal_screen_names_index: usize,

    _app_name: []const u8,

    pub fn deinit(self: *Template) void {
        for (self._htab_screen_names, 0..) |name, i| {
            if (i == self._htab_screen_names_index) {
                break;
            }
            name.deinit();
        }
        self.allocator.free(self._htab_screen_names);

        for (self._vtab_screen_names, 0..) |name, i| {
            if (i == self._vtab_screen_names_index) {
                break;
            }
            name.deinit();
        }
        self.allocator.free(self._vtab_screen_names);

        for (self._panel_screen_names, 0..) |name, i| {
            if (i == self._panel_screen_names_index) {
                break;
            }
            name.deinit();
        }
        self.allocator.free(self._panel_screen_names);

        for (self._modal_screen_names, 0..) |name, i| {
            if (i == self._modal_screen_names_index) {
                break;
            }
            name.deinit();
        }
        self.allocator.free(self._modal_screen_names);

        self.allocator.free(self._app_name);
        self.allocator.destroy(self);
    }

    pub fn addVTabScreenName(self: *Template, new_screen_name: []const u8) !void {
        if (self._vtab_screen_names_index == self._vtab_screen_names.len) {
            // Full list so create a new bigger one.
            var new_screen_names: []*strings.UTF8 = try self.allocator.alloc(*strings.UTF8, (self._vtab_screen_names.len + 5));
            for (self._vtab_screen_names, 0..) |vtab_screen_name, i| {
                new_screen_names[i] = vtab_screen_name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self._vtab_screen_names);
            self._vtab_screen_names = new_screen_names;
        }
        var utf8: *strings.UTF8 = try strings.UTF8.init(self.allocator, new_screen_name);
        self._vtab_screen_names[self._vtab_screen_names_index] = utf8;
        self._vtab_screen_names_index += 1;
    }

    pub fn addHTabScreenName(self: *Template, new_screen_name: []const u8) !void {
        if (self._htab_screen_names_index == self._htab_screen_names.len) {
            // Full list so create a new bigger one.
            var new_screen_names: []*strings.UTF8 = try self.allocator.alloc(*strings.UTF8, (self._htab_screen_names.len + 5));
            for (self._htab_screen_names, 0..) |htab_screen_name, i| {
                new_screen_names[i] = htab_screen_name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self._htab_screen_names);
            self._htab_screen_names = new_screen_names;
        }
        var utf8: *strings.UTF8 = try strings.UTF8.init(self.allocator, new_screen_name);
        self._htab_screen_names[self._htab_screen_names_index] = utf8;
        self._htab_screen_names_index += 1;
    }

    pub fn addPanelScreenName(self: *Template, new_screen_name: []const u8) !void {
        if (self._panel_screen_names_index == self._panel_screen_names.len) {
            // Full list so create a new bigger one.
            var new_screen_names: []*strings.UTF8 = try self.allocator.alloc(*strings.UTF8, (self._panel_screen_names.len + 5));
            for (self._panel_screen_names, 0..) |panel_screen_name, i| {
                new_screen_names[i] = panel_screen_name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self._panel_screen_names);
            self._panel_screen_names = new_screen_names;
        }
        var utf8: *strings.UTF8 = try strings.UTF8.init(self.allocator, new_screen_name);
        self._panel_screen_names[self._panel_screen_names_index] = utf8;
        self._panel_screen_names_index += 1;
    }

    pub fn addModalScreenName(self: *Template, new_screen_name: []const u8) !void {
        if (self._modal_screen_names_index == self._modal_screen_names.len) {
            // Full list so create a new bigger one.
            var new_screen_names: []*strings.UTF8 = try self.allocator.alloc(*strings.UTF8, (self._modal_screen_names.len + 5));
            for (self._modal_screen_names, 0..) |modal_screen_name, i| {
                new_screen_names[i] = modal_screen_name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self._modal_screen_names);
            self._modal_screen_names = new_screen_names;
        }
        var utf8: *strings.UTF8 = try strings.UTF8.init(self.allocator, new_screen_name);
        self._modal_screen_names[self._modal_screen_names_index] = utf8;
        self._modal_screen_names_index += 1;
    }

    pub fn content(self: *Template) ![]const u8 {
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        try lines.appendSlice(line1);
        var copy: []const u8 = undefined;
        var line: []u8 = undefined;

        // vtab screens.
        var vtab_screen_names: []*strings.UTF8 = self._vtab_screen_names[0..self._vtab_screen_names_index];
        for (vtab_screen_names) |name| {
            copy = try name.copy();
            defer self.allocator.free(copy);
            line = try fmt.allocPrint(self.allocator, "const _{s}_ = @import(\"screen/vtab/{s}/screen.zig\");\n", .{ copy, copy });
            try lines.appendSlice(line);
            self.allocator.free(line);
        }
        // htab screens.
        var htab_screen_names: []*strings.UTF8 = self._htab_screen_names[0..self._htab_screen_names_index];
        for (htab_screen_names) |name| {
            copy = try name.copy();
            defer self.allocator.free(copy);
            line = try fmt.allocPrint(self.allocator, "const _{s}_ = @import(\"screen/htab/{s}/screen.zig\");\n", .{ copy, copy });
            try lines.appendSlice(line);
            self.allocator.free(line);
        }
        // panel screens.
        var panel_screen_names: []*strings.UTF8 = self._panel_screen_names[0..self._panel_screen_names_index];
        for (panel_screen_names) |name| {
            copy = try name.copy();
            defer self.allocator.free(copy);
            line = try fmt.allocPrint(self.allocator, "const _{s}_ = @import(\"screen/panel/{s}/screen.zig\");\n", .{ copy, copy });
            try lines.appendSlice(line);
            self.allocator.free(line);
        }
        // modal screens.
        var modal_screen_names: []*strings.UTF8 = self._modal_screen_names[0..self._modal_screen_names_index];
        for (modal_screen_names) |name| {
            copy = try name.copy();
            defer self.allocator.free(copy);
            line = try fmt.allocPrint(self.allocator, "const _{s}_ = @import(\"screen/modal/{s}/screen.zig\");\n", .{ copy, copy });
            try lines.appendSlice(line);
            self.allocator.free(line);
        }

        try lines.appendSlice(line2);

        // init modal screens.
        for (modal_screen_names, 0..) |name, i| {
            if (i == 0) {
                try lines.appendSlice("    // Modal screens.\n");
            }
            copy = try name.copy();
            defer self.allocator.free(copy);
            line = try fmt.allocPrint(self.allocator, "    try _{s}_.init(allocator, all_screens, send_channel, receive_channel);\n", .{copy});
            try lines.appendSlice(line);
            self.allocator.free(line);
        }
        // init vtabs screens.
        for (vtab_screen_names, 0..) |name, i| {
            if (i == 0) {
                try lines.appendSlice("    // VTab screens.\n");
            }
            copy = try name.copy();
            defer self.allocator.free(copy);
            line = try fmt.allocPrint(self.allocator, "    try _{s}_.init(allocator, all_screens, send_channel, receive_channel);\n", .{copy});
            try lines.appendSlice(line);
            self.allocator.free(line);
        }
        // init htabs screens.
        for (htab_screen_names, 0..) |name, i| {
            if (i == 0) {
                try lines.appendSlice("    // HTab screens.\n");
            }
            copy = try name.copy();
            defer self.allocator.free(copy);
            line = try fmt.allocPrint(self.allocator, "    try _{s}_.init(allocator, all_screens, send_channel, receive_channel);\n", .{copy});
            try lines.appendSlice(line);
            self.allocator.free(line);
        }
        // init panel screens.
        for (panel_screen_names, 0..) |name, i| {
            if (i == 0) {
                try lines.appendSlice("    // Simple screens.\n");
            }
            copy = try name.copy();
            defer self.allocator.free(copy);
            line = try fmt.allocPrint(self.allocator, "    try _{s}_.init(allocator, all_screens, send_channel, receive_channel);\n", .{copy});
            try lines.appendSlice(line);
            self.allocator.free(line);
        }

        var replacement_size: usize = std.mem.replacementSize(u8, line3, "{{app_name}}", self._app_name);
        var with_app_name: []u8 = try self.allocator.alloc(u8, replacement_size);
        _ = std.mem.replace(u8, line3, "{{app_name}}", self._app_name, with_app_name);
        try lines.appendSlice(with_app_name);
        return try lines.toOwnedSlice();
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
    self._htab_screen_names = try allocator.alloc(*strings.UTF8, 5);
    self._vtab_screen_names = try allocator.alloc(*strings.UTF8, 5);
    self._panel_screen_names = try allocator.alloc(*strings.UTF8, 5);
    self._modal_screen_names = try allocator.alloc(*strings.UTF8, 5);
    self._htab_screen_names_index = 0;
    self._vtab_screen_names_index = 0;
    self._panel_screen_names_index = 0;
    self._modal_screen_names_index = 0;
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
    \\
    \\    if (try dvui.menuItemIcon(@src(), "{{app_name}}", dvui.entypo.menu, .{ .submenu = true }, .{ .expand = .none })) |r| {
    \\        var fw = try dvui.popup(@src(), dvui.Rect.fromPoint(dvui.Point{ .x = r.x, .y = r.y + r.h }), .{});
    \\        defer fw.deinit();
    \\        
    \\        for (_main_menu_.sorted_main_menu_screen_names) |screen_name| {
    \\            if (try dvui.menuItemLabel(@src(), screen_name, .{}, .{}) != null) {
    \\                m.close();
    \\                m.deinit();
    \\                try all_screens.setCurrent(screen_name);
    \\                return;
    \\            }
    \\        }
    \\
    \\        if (try dvui.menuItemLabel(@src(), "Close Menu", .{}, .{}) != null) {
    \\            // dvui.menuGet().?.close();
    \\            m.close();
    \\            m.deinit();
    \\            return;
    \\        }
    \\    }
    \\    m.deinit();
    \\}
    \\
;
