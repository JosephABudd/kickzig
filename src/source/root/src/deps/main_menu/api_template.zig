pub const content =
    \\const std = @import("std");
    \\
    \\/// This is the front-end's main menu data.
    \\/// This file was generated by kickzig when you created this framework.
    \\/// You are free to edit this file.
    \\const ScreenTags = @import("framers").ScreenTags;
    \\
    \\/// KICKZIG TODO:
    \\// startup_screen_tag is the screen displayed at startup.
    \\pub const startup_screen_tag: ScreenTags = .HelloWorld;
    \\
    \\/// KICKZIG TODO:
    \\/// If true:
    \\///  * The main menu is displayed.
    \\///  * The startup_screen_tag screen is initialized for the main view.
    \\///  * All the sorted_main_menu_screen_tags screens are initialized for the main view.
    \\/// If false:
    \\///  * The main menu is not displayed.
    \\///  * Only the startup_screen_tag screen is initialized for the main view.
    \\pub const show_main_menu: bool = true;
    \\
    \\/// KICKZIG TODO:
    \\/// sorted_main_menu_screen_tags is the sorted list of screens
    \\///  that the user can access in the main menu.
    \\pub const sorted_main_menu_screen_tags = [_]ScreenTags{
    \\    .HelloWorld,
    \\};
    \\
    \\/// KICKZIG TODO:
    \\/// if true, the dvui developer menu items are displayed in the main menu.
    \\/// if false, the dvui developer menu items are not displayed in the main menu.
    \\pub const show_developer_menu_items: bool = true;
    \\
    \\/// The caller owns the returned value.
    \\/// Called from frontend/screen_pointers.zig at startup.
    \\pub fn screenTagsForInitialization(allocator: std.mem.Allocator) ![]ScreenTags {
    \\    var size = sorted_main_menu_screen_tags.len;
    \\    var matched: bool = false;
    \\    for (sorted_main_menu_screen_tags) |screen_tag| {
    \\        if (screen_tag == startup_screen_tag) {
    \\            matched = true;
    \\            break;
    \\        }
    \\    }
    \\    if (!matched) {
    \\        size += 1;
    \\    }
    \\    var screen_tags: []ScreenTags = try allocator.alloc(ScreenTags, size);
    \\    for (sorted_main_menu_screen_tags, 0..) |screen_tag, i| {
    \\        screen_tags[i] = screen_tag;
    \\    }
    \\    if (!matched) {
    \\        screen_tags[size - 1] = startup_screen_tag;
    \\    }
    \\    return screen_tags;
    \\}
    \\
;
