const std = @import("std");
const fmt = std.fmt;

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

/// The caller owns the return value.
pub fn framework(allocator: std.mem.Allocator, cli_name: []const u8) ![]u8 {
    return fmt.allocPrint(allocator, framework_template, .{cli_name});
}

const framework_template: []const u8 =
    \\
    \\🗽 GETTING STARTED WITH {0s}.
    \\Build and run the application framework.
    \\In this case the framework is built with messages.
    \\
    \\＄ mkdir myapp
    \\＄ cd myapp
    \\＄ kickzig framework add-messages
    \\＄ zig fetch --save https://github.com/david-vanderson/dvui/archive/27b59c5f25350ad4481110eecd0920b828e61a30.tar.gz
    \\＄ zig build -freference-trace=255
    \\＄ ./zig-out/bin/myapp
    \\
    \\🌐 THE FRAMEWORK:
    \\The framework is contained in these folders.
    \\1. ./ which contains build.zig, build.zig.zon.
    \\2. ./src/ which contains main.zig.
    \\3. ./src/frontend/ which contains the front-end code.
    \\4. ./src/deps/ which contains the dependencies.
    \\5. ./src/backend/messenger/ which contains the optional back-end messenger code.
    \\
    \\Framework Options.
    \\1. Build the framework without messages.
    \\   This is the default framework setting.
    \\   ＄ kickzig framework
    \\2. Build the framework with messages.
    \\   ＄ kickzig framework add-messages
    \\
    \\
;

/// The caller owns the return value.
pub fn screen(allocator: std.mem.Allocator, cli_name: []const u8) ![]u8 {
    return fmt.allocPrint(allocator, screen_template, .{cli_name});
}

const screen_template: []const u8 =
    \\
    \\📺 MANAGING SCREENS WITH {0s}.
    \\Screen names must be in TitleCase.
    \\Panel names must be in TitleCase.
    \\Tab names must be in TitleCase.
    \\
    \\＄ cd myapp
    \\＄ {0s} screen help
    \\＄ {0s} screen list
    \\＄ {0s} screen add-panel «screen-name» «panel-name, ...»
    \\＄ {0s} screen add-tab «screen-name» «[*]tab-name, ...»
    \\＄ {0s} screen add-modal «screen-name» «panel-name, ...»
    \\＄ {0s} screen remove «screen-name»
    \\
    \\Tab names:
    \\* A tab-name prefixed with '*':
    \\  Will get its content from the screen of the same name.
    \\  That screen must already exist.
    \\* A tab-name not prefixed with '*':
    \\  Will get its content from a panel of the same name.
    \\  That panel will be created in the same screen as the tab.
    \\
    \\After a screen is added:
    \\1. A link to it's screen.zig file is displayed.
    \\2. A search for KICKZIG TODO in the screen package files will reveal instructions for proper developement and management of the screen operation.
    \\
    \\
;

/// The caller owns the return value.
pub fn message(allocator: std.mem.Allocator, cli_name: []const u8) ![]u8 {
    return fmt.allocPrint(allocator, message_template, .{cli_name});
}

const message_template: []const u8 =
    \\
    \\💬 MANAGING MESSAGES WITH {0s}.
    \\Messages names must be in TitleCase.
    \\
    \\＄ cd myapp
    \\＄ {0s} message help
    \\＄ {0s} message list
    \\＄ {0s} message add-fbf «name-of-message» // front-end to back-end to front-end
    \\＄ {0s} message add-bf «name-of-message» // back-end to front-end
    \\＄ {0s} message add-bf-fbf «name-of-message» // back-end to front-end & front-end to back-end to front-end
    \\＄ {0s} message remove «name-of-message»
    \\
    \\After a message is added:
    \\1. A search for KICKZIG TODO will reveal instructions for proper developement and management of the message operation.
    \\
;
