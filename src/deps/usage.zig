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

    // message usage.
    line = try message(allocator, cli_name);
    try lines.appendSlice(line);
    allocator.free(line);

    return lines.toOwnedSlice();
}

pub fn framework(allocator: std.mem.Allocator, cli_name: []const u8) ![]u8 {
    // cli_name
    const size: usize = std.mem.replacementSize(u8, framework_template, "{{cli_name}}", cli_name);
    const usage_cli_name: []u8 = try allocator.alloc(u8, size);
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
    const size: usize = std.mem.replacementSize(u8, screen_template, "{{cli_name}}", cli_name);
    const usage_cli_name: []u8 = try allocator.alloc(u8, size);
    _ = std.mem.replace(u8, screen_template, "{{cli_name}}", cli_name, usage_cli_name);
    return usage_cli_name;
}

const screen_template: []const u8 =
    \\
    \\📺 MANAGING SCREENS WITH {{cli_name}}.
    \\Screen names must be in PascalCase.
    \\Panel names must be in PascalCase.
    \\Tab names must be in PascalCase.
    \\
    \\＄ cd myapp
    \\＄ {{cli_name}} screen help
    \\＄ {{cli_name}} screen list
    \\＄ {{cli_name}} screen add-panel «screen-name» «panel-name, ...»
    \\＄ {{cli_name}} screen add-content «screen-name» «panel-name, ...»
    \\＄ {{cli_name}} screen add-tab «screen-name» «[*]tab-name, ...»
    \\＄ {{cli_name}} screen add-modal «screen-name» «panel-name, ...»
    \\＄ {{cli_name}} screen remove «screen-name»
    \\
    \\A tab-name not prefixed with '*', will have it's own panel, of the same name, to provide content.
    \\A tab-name prefixed with '*', will get its content from the screen in the panel/ folder, of the same name.
    \\That screen in the panel/ folder, must already exist.
    \\
    \\After a screen is added:
    \\1. A link to it's screen.zig file is displayed.
    \\2. A search for KICKZIG TODO in the screen package files will reveal instructions for proper developement and management of the screen operation.
    \\
    \\
;

pub fn message(allocator: std.mem.Allocator, cli_name: []const u8) ![]u8 {
    // cli_name
    const size: usize = std.mem.replacementSize(u8, message_template, "{{cli_name}}", cli_name);
    const usage_cli_name: []u8 = try allocator.alloc(u8, size);
    _ = std.mem.replace(u8, message_template, "{{cli_name}}", cli_name, usage_cli_name);
    return usage_cli_name;
}

const message_template: []const u8 =
    \\
    \\💬 MANAGING MESSAGES WITH {{cli_name}}.
    \\Messages names must be in PascalCase.
    \\
    \\＄ cd myapp
    \\＄ {{cli_name}} message help
    \\＄ {{cli_name}} message list
    \\＄ {{cli_name}} message add-fbf «name-of-message» // front-end to back-end to front-end
    \\＄ {{cli_name}} message add-bf «name-of-message» // back-end to front-end
    \\＄ {{cli_name}} message add-bf-fbf «name-of-message» // back-end to front-end & front-end to back-end to front-end
    \\＄ {{cli_name}} message remove «name-of-message»
    \\
    \\After a message is added:
    \\1. A search for KICKZIG TODO will reveal instructions for proper developement and management of the message operation.
    \\
;
