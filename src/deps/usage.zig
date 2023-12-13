const std = @import("std");

pub fn application(allocator: std.mem.Allocator, cli_name: []const u8) ![]const u8 {
    var lines = std.ArrayList(u8).init(allocator);
    defer lines.deinit();
    var line: []u8 = undefined;

    // framework usage.
    line = try framework(allocator, cli_name);
    try lines.appendSlice(line);
    allocator.free(line);

    // screen usage.
    line = try screen(allocator, cli_name);
    try lines.appendSlice(line);
    allocator.free(line);

    // panel usage.
    line = try panel(allocator, cli_name);
    try lines.appendSlice(line);
    allocator.free(line);

    // message usage.
    line = try message(allocator, cli_name);
    try lines.appendSlice(line);
    allocator.free(line);

    return lines.toOwnedSlice();
}

pub fn framework(allocator: std.mem.Allocator, cli_name: []const u8) ![]u8 {
    // cli_name
    var size: usize = std.mem.replacementSize(u8, framework_template, "{{cli_name}}", cli_name);
    var usage_cli_name: []u8 = try allocator.alloc(u8, size);
    _ = std.mem.replace(u8, framework_template, "{{cli_name}}", cli_name, usage_cli_name);
    return usage_cli_name;
}

const framework_template: []const u8 =
    \\
    \\🗽 GETTING STARTED WITH {{cli_name}}.
    \\Build and run the application framework.
    \\
    \\＄ mkdir myapp
    \\＄ cd myapp
    \\＄ kickzig framework
    \\＄ git clone https://github.com/david-vanderson/dvui.git src/vendor/dvui/
    \\＄ zig build -freference-trace=255
    \\＄ ./zig-out/bin/standalone-sdl
    \\
    \\🌐 THE FRAMEWORK:
    \\The framework is contained in these folders.
    \\1. ./ which contains build.zig, build.zig.zon, standalone-sdl.zig
    \\2. ./src/@This/backend/ which contains the back-end code.
    \\3. ./src/@This/frontend/ which contains the front-end code.
    \\4. ./src/@This/deps/ which contains the dependencies.
    \\5. ./src/vendor/ which contains vendered code.
    \\6. ./src/vendor/dvui/ which contains dvui.
    \\
    \\
;

pub fn screen(allocator: std.mem.Allocator, cli_name: []const u8) ![]u8 {
    // cli_name
    var size: usize = std.mem.replacementSize(u8, screen_template, "{{cli_name}}", cli_name);
    var usage_cli_name: []u8 = try allocator.alloc(u8, size);
    _ = std.mem.replace(u8, screen_template, "{{cli_name}}", cli_name, usage_cli_name);
    return usage_cli_name;
}

const screen_template: []const u8 =
    \\
    \\📺 MANAGING SCREENS WITH {{cli_name}}.
    \\Screen names must be in UpperCamelCase.
    \\
    \\＄ cd myapp
    \\＄ {{cli_name}} screen help
    \\＄ {{cli_name}} screen list
    \\＄ {{cli_name}} screen add-panel «screen-name» «panel-name, ...»
    \\＄ {{cli_name}} screen add-vtab «screen-name» «[+]tab-name, ...»
    \\＄ {{cli_name}} screen add-htab «screen-name» «[+]tab-name, ...»
    \\＄ {{cli_name}} screen add-modal «screen-name» «panel-name, ...»
    \\＄ {{cli_name}} screen remove «screen-name»
    \\
    \\A vtab and htab tab-name prefixed with '+' is given its own panel of the same name as the tab for content.
    \\A vtab and htab tab-name not prefixed with '+' is given the screen of the same name as the tab for content.
    \\
    \\After a screen is added:
    \\1. A search for KICKZIG TODO will reveal instructions for proper developement and management of the screen operation.
    \\
    \\
;

pub fn panel(allocator: std.mem.Allocator, cli_name: []const u8) ![]u8 {
    // cli_name
    var size: usize = std.mem.replacementSize(u8, panel_template, "{{cli_name}}", cli_name);
    var usage_cli_name: []u8 = try allocator.alloc(u8, size);
    _ = std.mem.replace(u8, panel_template, "{{cli_name}}", cli_name, usage_cli_name);
    return usage_cli_name;
}

const panel_template: []const u8 =
    \\
    \\📄 MANAGING SCREEN PANELS WITH {{cli_name}}.
    \\Panel names must be in UpperCamelCase.
    \\
    \\＄ cd myapp
    \\＄ {{cli_name}} panel help
    \\＄ {{cli_name}} panel list «screen-name»
    \\＄ {{cli_name}} panel add «screen-name» «name-of-panel»
    \\＄ {{cli_name}} panel remove «screen-name» «name-of-panel»
    \\
    \\After a panel is added:
    \\1. A search for KICKZIG TODO will reveal instructions for proper developement and management of the panel operation.
    \\
    \\
;

pub fn message(allocator: std.mem.Allocator, cli_name: []const u8) ![]u8 {
    // cli_name
    var size: usize = std.mem.replacementSize(u8, message_template, "{{cli_name}}", cli_name);
    var usage_cli_name: []u8 = try allocator.alloc(u8, size);
    _ = std.mem.replace(u8, message_template, "{{cli_name}}", cli_name, usage_cli_name);
    return usage_cli_name;
}

const message_template: []const u8 =
    \\
    \\💬 MANAGING MESSAGES WITH {{cli_name}}.
    \\Messages names must be in UpperCamelCase.
    \\
    \\＄ cd myapp
    \\＄ {{cli_name}} message help
    \\＄ {{cli_name}} message list
    \\＄ {{cli_name}} message add «name-of-message»
    \\＄ {{cli_name}} message remove «name-of-message»
    \\
    \\After a message is added:
    \\1. A search for KICKZIG TODO will reveal instructions for proper developement and management of the message operation.
    \\
;
