const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_name: []const u8,
    panel_names: [][]const u8,
    panel_names_index: usize,
    using_messenger: bool,

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.screen_name);
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

    pub fn content(self: *Template) ![]const u8 {
        var line: []u8 = undefined;
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        const panel_names: [][]const u8 = self.panel_names[0..self.panel_names_index];
        var size: usize = 0;
        const default_panel_name: []const u8 = panel_names[0];

        try lines.appendSlice(line_start);

        if (self.using_messenger) {
            try lines.appendSlice(line_messenger_import);
        }

        for (panel_names) |panel_name| {
            size = std.mem.replacementSize(u8, line_panel_imports, "{{ panel_name }}", panel_name);
            const with_panel_name: []u8 = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_panel_name);
            _ = std.mem.replace(u8, line_panel_imports, "{{ panel_name }}", panel_name, with_panel_name);
            try lines.appendSlice(with_panel_name);
        }

        {
            size = std.mem.replacementSize(u8, line_imports_panel_tags, "{{ screen_name }}", self.screen_name);
            const with_screen_name: []u8 = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_screen_name);
            _ = std.mem.replace(u8, line_imports_panel_tags, "{{ screen_name }}", self.screen_name, with_screen_name);
            try lines.appendSlice(with_screen_name);
        }

        for (panel_names) |panel_name| {
            size = std.mem.replacementSize(u8, line_panel_tag, "{{ panel_name }}", panel_name);
            const with_panel_name: []u8 = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_panel_name);
            _ = std.mem.replace(u8, line_panel_tag, "{{ panel_name }}", panel_name, with_panel_name);
            try lines.appendSlice(with_panel_name);
        }

        try lines.appendSlice(line_none_tag_panels_struct);

        for (panel_names) |panel_name| {
            size = std.mem.replacementSize(u8, line2_panel_struct_member, "{{ panel_name }}", panel_name);
            const with_panel_name: []u8 = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_panel_name);
            _ = std.mem.replace(u8, line2_panel_struct_member, "{{ panel_name }}", panel_name, with_panel_name);
            try lines.appendSlice(with_panel_name);
        }

        try lines.appendSlice(line_deinit);

        for (panel_names) |panel_name| {
            size = std.mem.replacementSize(u8, line3_panel_deinit, "{{ panel_name }}", panel_name);
            const with_panel_name: []u8 = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_panel_name);
            _ = std.mem.replace(u8, line3_panel_deinit, "{{ panel_name }}", panel_name, with_panel_name);
            try lines.appendSlice(with_panel_name);
        }

        try lines.appendSlice(line_end_deinit_start_frameCurrent);

        for (panel_names) |panel_name| {
            size = std.mem.replacementSize(u8, line_frame_panel, "{{ panel_name }}", panel_name);
            const with_panel_name: []u8 = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_panel_name);
            _ = std.mem.replace(u8, line_frame_panel, "{{ panel_name }}", panel_name, with_panel_name);
            try lines.appendSlice(with_panel_name);
        }

        {
            size = std.mem.replacementSize(u8, line_frame_none, "{{ panel_name }}", default_panel_name);
            const with_panel_name: []u8 = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_panel_name);
            _ = std.mem.replace(u8, line_frame_none, "{{ panel_name }}", default_panel_name, with_panel_name);
            try lines.appendSlice(with_panel_name);
        }

        for (panel_names) |panel_name| {
            size = std.mem.replacementSize(u8, line_set_current_to, "{{ panel_name }}", panel_name);
            const with_panel_name: []u8 = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_panel_name);
            _ = std.mem.replace(u8, line_set_current_to, "{{ panel_name }}", panel_name, with_panel_name);
            try lines.appendSlice(with_panel_name);
        }

        try lines.appendSlice(line_preset_modal_start);

        for (panel_names) |panel_name| {
            size = std.mem.replacementSize(u8, line_panel_preset_modal, "{{ panel_name }}", panel_name);
            const with_panel_name: []u8 = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_panel_name);
            _ = std.mem.replace(u8, line_panel_preset_modal, "{{ panel_name }}", panel_name, with_panel_name);
            try lines.appendSlice(with_panel_name);
        }

        if (self.using_messenger) {
            try lines.appendSlice(line_preset_modal_end_init_start_with_messenger);
        } else {
            try lines.appendSlice(line_preset_modal_end_init_start_without_messenger);
        }

        for (panel_names) |panel_name| {
            const line_panel_init: []const u8 = switch (self.using_messenger) {
                true => line_panel_init_with_messenger,
                false => line_panel_init_without_messenger,
            };
            size = std.mem.replacementSize(u8, line_panel_init, "{{ panel_name }}", panel_name);
            const with_panel_name: []u8 = try self.allocator.alloc(u8, size);
            defer self.allocator.free(with_panel_name);
            _ = std.mem.replace(u8, line_panel_init, "{{ panel_name }}", panel_name, with_panel_name);
            try lines.appendSlice(with_panel_name);
        }

        try lines.appendSlice(line_last);

        const temp: []const u8 = try lines.toOwnedSlice();
        line = try self.allocator.alloc(u8, temp.len);
        @memcpy(line, temp);
        return line;
    }
};

pub fn init(allocator: std.mem.Allocator, screen_name: []const u8, using_messenger: bool) !*Template {
    var data: *Template = try allocator.create(Template);
    data.panel_names = try allocator.alloc([]const u8, 5);
    errdefer {
        allocator.destroy(data);
    }
    errdefer {
        allocator.free(data.panel_names);
        allocator.destroy(data);
    }
    data.screen_name = try allocator.alloc(u8, screen_name.len);
    @memcpy(@constCast(data.screen_name), screen_name);
    errdefer {
        allocator.free(data.panel_names);
        allocator.destroy(data);
    }
    data.panel_names_index = 0;
    data.allocator = allocator;
    data.using_messenger = using_messenger;
    return data;
}

const line_start =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\
;

const line_messenger_import =
    \\const _messenger_ = @import("messenger.zig");
    \\
;

const line_panel_imports =
    \\const _{{ panel_name }}_ = @import("{{ panel_name }}_panel.zig");
    \\
;

const line_imports_panel_tags =
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\const ModalParams = @import("modal_params").{{ screen_name }};
    \\
    \\const PanelTags = enum {
;

const line_panel_tag =
    \\    {{ panel_name }},
    \\
;

const line_none_tag_panels_struct =
    \\    none,
    \\};
    \\
    \\pub const Panels = struct {
    \\    allocator: std.mem.Allocator,
    \\    current_panel_tag: PanelTags,
    \\
;

const line2_panel_struct_member =
    \\    {{ panel_name }}: ?*_{{ panel_name }}_.Panel,
    \\
;

const line_deinit =
    \\
    \\    pub fn deinit(self: *Panels) void {
    \\
;

const line3_panel_deinit =
    \\        if (self.{{ panel_name }}) |member| {
    \\            member.deinit();
    \\        }
    \\
;

const line_end_deinit_start_frameCurrent =
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    pub fn frameCurrent(self: *Panels, allocator: std.mem.Allocator) !void {
    \\        const result = switch (self.current_panel_tag) {
    \\
;

const line_frame_panel =
    \\            .{{ panel_name }} => self.{{ panel_name }}.?.frame(allocator),
    \\
;

const line_frame_none =
    \\            .none => self.{{ panel_name }}.?.frame(allocator),
    \\        };
    \\        return result;
    \\    }
    \\
;

const line_set_current_to =
    \\
    \\    pub fn setCurrentTo{{ panel_name }}(self: *Panels) void {
    \\        self.current_panel_tag = PanelTags.{{ panel_name }};
    \\    }
    \\
;

// const line_preset_modal_init =
const line_preset_modal_start =
    \\
    \\    pub fn presetModal(self: *Panels, modal_params: *ModalParams) !void {
    \\
;

const line_panel_preset_modal =
    \\        try self.{{ panel_name }}.presetModal(modal_params);
    \\
;

const line_preset_modal_end_init_start_with_messenger =
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, main_view: *MainView, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panels {
    \\    var panels: *Panels = try allocator.create(Panels);
    \\    panels.allocator = allocator;
    \\
;

const line_preset_modal_end_init_start_without_messenger =
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, main_view: *MainView, exit: ExitFn, window: *dvui.Window) !*Panels {
    \\    var panels: *Panels = try allocator.create(Panels);
    \\    panels.allocator = allocator;
    \\
;

const line_panel_init_with_messenger =
    \\
    \\    panels.{{ panel_name }} = try _{{ panel_name }}_.init(allocator, main_view, panels, messenger, exit, window);
    \\    errdefer {
    \\        panels.deinit();
    \\    }
    \\
;

const line_panel_init_without_messenger =
    \\
    \\    panels.{{ panel_name }} = try _{{ panel_name }}_.init(allocator, main_view, panels, exit, window);
    \\    errdefer {
    \\        panels.deinit();
    \\    }
    \\
;

const line_last =
    \\
    \\    return panels;
    \\}
;
