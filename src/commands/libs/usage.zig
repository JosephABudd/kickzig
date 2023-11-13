const std = @import("std");

pub fn application(allocator: std.mem.Allocator, cli_name: []const u8, app_name: []const u8) ![]const u8 {
    var lines = std.ArrayList(u8).init(allocator);
    defer lines.deinit();
    var line: []u8 = undefined;

    // framework usage.
    line = try framework(allocator, cli_name, app_name);
    try lines.appendSlice(line);

    return lines.toOwnedSlice();
}

pub fn framework(allocator: std.mem.Allocator, cli_name: []const u8, app_name: []const u8) ![]u8 {
    // cli_name
    var size: usize = std.mem.replacementSize(u8, framework_template, "{{cli_name}}", cli_name);
    var usage_cli_name: []u8 = try allocator.alloc(u8, size);
    defer allocator.free(usage_cli_name);
    _ = std.mem.replace(u8, framework_template, "{{cli_name}}", cli_name, usage_cli_name);
    // app_name
    size = std.mem.replacementSize(u8, usage_cli_name, "{{app_name}}", app_name);
    var usage_app_name: []u8 = try allocator.alloc(u8, size);
    _ = std.mem.replace(u8, usage_cli_name, "{{app_name}}", app_name, usage_app_name);
    return usage_app_name;
}

const framework_template: []const u8 =
    \\🗽 GETTING STARTED WITH {{cli_name}}.
    \\
    \\＄ cd ~/projects/«name-of-my-app»
    \\＄ {{cli_name}} framework
    \\
    \\🌐 THE FRAMEWORK:
    \\The framework is contained in 5 folders.
    \\1. ./ which contains build.zig, main.zig and main-test.zig.
    \\2. ./src/ which contains the backend/, frontend/ and deps/ folders.
    \\3. ./src/backend/ which contains the back-end code.
    \\4. ./src/frontend/ which contains the front-end code.
    \\5. ./src/deps/ which contains the dependencies.
    \\
    \\🔨 BUILDING THE APP:
    \\You can build the app after running the command "＄ {{cli_name}} framework".
    \\The following build example is done in the app's folder.
    \\
    \\＄ zig build
    \\＄ ./zig-out/bin/«name-of-executable»
    \\
;
