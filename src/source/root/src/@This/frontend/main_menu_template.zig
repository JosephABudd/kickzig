const std = @import("std");
const fmt = std.fmt;

pub const default_landing_screen_name: []const u8 = "HelloWorld";

pub const Template = struct {
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Template) void {
        self.allocator.destroy(self);
    }

    // The caller owns the returned value;
    pub fn content(self: *Template) ![]const u8 {
        const replacement_size: usize = std.mem.replacementSize(u8, template, "{{startup_screen_name}}", default_landing_screen_name);
        const with_startup_screen_name: []u8 = try self.allocator.alloc(u8, replacement_size);
        _ = std.mem.replace(u8, template, "{{startup_screen_name}}", default_landing_screen_name, with_startup_screen_name);
        return with_startup_screen_name;
    }
};

pub fn init(allocator: std.mem.Allocator) !*Template {
    var self: *Template = try allocator.create(Template);
    self.allocator = allocator;
    return self;
}

const template =
    \\// menu items for the developer, not for release.
    \\pub const show_developer_menu_items: bool = true;
    \\
    \\// startup_screen_name is the screen displayed at statup.
    \\pub const startup_screen_name = "{{startup_screen_name}}";
    \\
    \\// sorted_main_menu_screen_names is the sorted list of screens
    \\//  that the user can access in the main menu.
    \\pub const sorted_main_menu_screen_names = [_][]const u8{
    \\    "{{startup_screen_name}}",
    \\};
;
