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
            line = try fmt.allocPrint(self.allocator, line1_import_vtab, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // htab screens.
        const htab_screen_names: [][]const u8 = self._htab_screen_names[0..self._htab_screen_names_index];
        for (htab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line1_import_htab, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // panel screens.
        const panel_screen_names: [][]const u8 = self._panel_screen_names[0..self._panel_screen_names_index];
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line1_import_panel, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // book screens.
        const book_screen_names: [][]const u8 = self._book_screen_names[0..self._book_screen_names_index];
        for (book_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line1_import_book, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // modal screens.
        const modal_screen_names: [][]const u8 = self._modal_screen_names[0..self._modal_screen_names_index];
        for (modal_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line1_import_modal, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line2);

        // vtab screens.
        for (vtab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_member, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // htab screens.
        for (htab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_member, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // panel screens.
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_member, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // book screens.
        for (book_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_member, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // modal screens.
        for (modal_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line2_member, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line3);

        // vtab screens.
        for (vtab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line3_deinit, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // htab screens.
        for (htab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line3_deinit, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // panel screens.
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line3_deinit, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // book screens.
        for (book_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line3_deinit, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // modal screens.
        for (modal_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line3_deinit, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line4);

        // vtab screens.
        for (vtab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line4_init, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // htab screens.
        for (htab_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line4_init, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // panel screens.
        for (panel_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line4_init, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // book screens.
        for (book_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line4_init, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        // modal screens.
        for (modal_screen_names) |name| {
            line = try fmt.allocPrint(self.allocator, line4_init, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line5);

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
    \\const _startup_ = @import("startup");
    \\
;

const line1_import_vtab =
    \\const {0s} = @import("screen/vtab/{0s}/screen.zig").Screen;
    \\
;

const line1_import_htab =
    \\const {0s} = @import("screen/htab/{0s}/screen.zig").Screen;
    \\
;

const line1_import_panel =
    \\const {0s} = @import("screen/panel/{0s}/screen.zig").Screen;
    \\
;

const line1_import_book =
    \\const {0s} = @import("screen/book/{0s}/screen.zig").Screen;
    \\
;

const line1_import_modal =
    \\const {0s} = @import("screen/modal/{0s}/screen.zig").Screen;
    \\
;

const line2 =
    \\
    \\pub const ScreenPointers = struct {
    \\    allocator: std.mem.Allocator,
    \\
;

const line2_member =
    \\    {0s}: ?*{0s},
    \\
;

const line3 =
    \\
    \\    pub fn deinit(self: *ScreenPointers) void {
;

const line3_deinit =
    \\        if (self.{0s}) |screen| {{
    \\            screen.deinit();
    \\        }}
;

const line4 =
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    pub fn init(startup: _startup_.Frontend) !*ScreenPointers {
    \\        const self: *ScreenPointers = try startup.allocator.create(ScreenPointers);
    \\        self.allocator = startup.allocator;
    \\        return self;
    \\    }
    \\
    \\    pub fn init_screens(self: *ScreenPointers, startup: _startup_.Frontend) !void {
    \\        // Set up each screen.
    \\        // Modal screens.
    \\
;

const line4_init =
    \\        self.{0s} = try {0s}.init(startup);
    \\        errdefer self.deinit();
    \\
;

const line5 =
    \\    }
    \\};
    \\
;
