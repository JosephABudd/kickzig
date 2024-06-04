const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    panel_names: [][]const u8,
    panel_names_index: usize,

    pub fn deinit(self: *Template) void {
        for (self.panel_names, 0..) |name, i| {
            if (i == self.panel_names_index) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self.panel_names);
        self.allocator.destroy(self);
    }

    pub fn addName(self: *Template, new_name: []const u8) !void {
        if (self.panel_names_index == self.panel_names.len) {
            // Full list so create a new bigger one.
            var new_panel_names: [][]const u8 = try self.allocator.alloc([]const u8, (self.panel_names.len + 5));
            for (self.panel_names, 0..) |name, i| {
                new_panel_names[i] = name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self.panel_names);
            self.panel_names = new_panel_names;
        }
        self.panel_names[self.panel_names_index] = try self.allocator.alloc(u8, new_name.len);
        @memcpy(@constCast(self.panel_names[self.panel_names_index]), new_name);
        self.panel_names_index += 1;
    }

    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        var line: []u8 = undefined;
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        const names: [][]const u8 = self.panel_names[0..self.panel_names_index];

        try lines.appendSlice(line_start);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_const_import, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_paneltags_enum_start);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_panentag, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_paneltags_enum_end_panels_struct_start);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_paneltags_struct_member, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_paneltags_struct_member_end_fn_deinit_start);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_paneltags_struct_fn_deinit_member, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_paneltags_struct_fn_deinit_end_fn_frameCurrent_start);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_paneltags_struct_fn_frameCurrent_prong, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        if (names.len > 0) {
            line = try fmt.allocPrint(self.allocator, line_paneltags_struct_fn_frameCurrent_prong_none, .{names[0]});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_paneltags_struct_fn_frameCurrent_end);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, line_paneltags_struct_fn_setCurrent, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        try lines.appendSlice(line_paneltags_struct_end_fn_init_start);
        if (names.len > 0) {
            for (names) |name| {
                line = try fmt.allocPrint(self.allocator, line_paneltags_struct_end_fn_init_member, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        } else {
            try lines.appendSlice(line_paneltags_struct_end_fn_init_no_member);
        }

        try lines.appendSlice(line_paneltags_struct_end_fn_init_end);
        return try lines.toOwnedSlice();
    }
};

pub fn init(allocator: std.mem.Allocator) !*Template {
    var data: *Template = try allocator.create(Template);
    data.panel_names = try allocator.alloc([]const u8, 5);
    errdefer {
        allocator.destroy(data);
    }
    errdefer {
        allocator.free(data.panel_names);
        allocator.destroy(data);
    }
    data.panel_names_index = 0;
    data.allocator = allocator;
    return data;
}

const line_start =
    \\const std = @import("std");
    \\
    \\const _framers_ = @import("framers");
    \\const _messenger_ = @import("messenger.zig");
    \\const ExitFn = @import("various").ExitFn;
    \\
;

const line_const_import =
    \\const _{0s}_ = @import("{0s}_panel.zig");
    \\
;

const line_paneltags_enum_start =
    \\
    \\const PanelTags = enum {
    \\
;
const line_panentag =
    \\    {0s},
    \\
;

const line_paneltags_enum_end_panels_struct_start =
    \\    none,
    \\};
    \\
    \\pub const Panels = struct {
    \\    allocator: std.mem.Allocator,
    \\
;

const line_paneltags_struct_member =
    \\    {0s}: ?*_{0s}_.Panel = null,
    \\
;

const line_paneltags_struct_member_end_fn_deinit_start =
    \\    current_panel_tag: PanelTags,
    \\
    \\    pub fn deinit(self: *Panels) void {
    \\
;
const line_paneltags_struct_fn_deinit_member =
    \\        if (self.{0s}) |{0s}| {{
    \\            {0s}.deinit();
    \\        }}
    \\
;

const line_paneltags_struct_fn_deinit_end_fn_frameCurrent_start =
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    pub fn frameCurrent(self: *Panels, allocator: std.mem.Allocator) !void {
    \\        return switch (self.current_panel_tag) {
    \\
;

const line_paneltags_struct_fn_frameCurrent_prong =
    \\            .{0s} => self.{0s}.?.frame(allocator),
    \\
;

const line_paneltags_struct_fn_frameCurrent_prong_none =
    \\            .none => self.{0s}.?.frame(allocator),
    \\
;

const line_paneltags_struct_fn_frameCurrent_end =
    \\        };
    \\    }
    \\
;
const line_paneltags_struct_fn_setCurrent =
    \\
    \\    pub fn setCurrentTo{0s}(self: *Panels) void {{
    \\        self.current_panel_tag = PanelTags.{0s};
    \\    }}
    \\
;

const line_paneltags_struct_end_fn_init_start =
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Screens, messenger: *_messenger_.Messenger, exit: ExitFn) !*Panels {
    \\    var panels: *Panels = try allocator.create(Panels);
    \\    panels.allocator = allocator;
    \\
;

const line_paneltags_struct_end_fn_init_member =
    \\
    \\    panels.{0s} = try _{0s}_.init(allocator, all_screens, panels, messenger, exit, window);
    \\    errdefer panels.deinit();
    \\
;

const line_paneltags_struct_end_fn_init_no_member =
    \\    _ = all_screens;
    \\    _ = messenger;
;

const line_paneltags_struct_end_fn_init_end =
    \\
    \\    return panels;
    \\}
    \\
;
