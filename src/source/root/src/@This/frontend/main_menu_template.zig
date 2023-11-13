const std = @import("std");
const fmt = std.fmt;
const strings = @import("strings");
pub const default_landing_screen_name: []const u8 = "Example";

pub const Template = struct {
    _allocator: std.mem.Allocator,

    pub fn deinit(self: *Template) void {
        self._allocator.destroy(self);
    }

    pub fn content(self: *Template) ![]const u8 {
        var replacement_size: usize = std.mem.replacementSize(u8, template, "{{startup_screen_name}}", default_landing_screen_name);
        var with_startup_screen_name: []u8 = try self._allocator.alloc(u8, replacement_size);
        _ = std.mem.replace(u8, template, "{{startup_screen_name}}", default_landing_screen_name, with_startup_screen_name);
        return with_startup_screen_name;
    }
};

pub fn init(allocator: std.mem.Allocator) !*Template {
    var self: *Template = try allocator.create(Template);
    self._allocator = allocator;
    return self;
}

const template =
    \\// startup_screen_name is the screen displayed at statup.
    \\pub const startup_screen_name = "{{startup_screen_name}}";
    \\
    \\// sorted_main_menu_screen_names is the sorted list of screens
    \\//  that the user can access in the main menu.
    \\pub const sorted_main_menu_screen_names = [_][]const u8{
    \\    "{{startup_screen_name}}",
    \\};
;
