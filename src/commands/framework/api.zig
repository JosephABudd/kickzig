const std = @import("std");
const paths = @import("paths");
const stdout = @import("stdout");
const source = @import("source");

const warning = @import("warning");
const usage = @import("usage");

pub const command: []const u8 = "framework";
pub const verb_help: []const u8 = "help";
pub const verb_restart: []const u8 = "restart";

pub fn handleCommand(allocator: std.mem.Allocator, cli_name: []const u8, app_name: []const u8, remaining_args: [][]u8) !void {
    var folder_paths: *paths.FolderPaths = try paths.folders();
    defer folder_paths.deinit();
    if (remaining_args.len > 0) {
        if (std.mem.eql(u8, remaining_args[0], verb_help)) {
            // User input is "framework help".
            var framework_usage: []u8 = try usage.framework(allocator, cli_name, app_name);
            defer allocator.free(framework_usage);
            try stdout.print(framework_usage);
        } else if (std.mem.eql(u8, remaining_args[0], verb_restart)) {
            // User input is "framework restart".
            // Remove and then create a new root/src/@This/.
            folder_paths.reBuild() catch |restart_err| {
                var user_input: []const u8 = undefined;
                user_input = std.fmt.allocPrint(allocator, "{s} {s}", .{ command, verb_restart }) catch {
                    return restart_err;
                };
                defer allocator.free(user_input);
                // Have input so make the error message.
                var msg: []const u8 = warning.fatal(allocator, restart_err, user_input) catch {
                    return restart_err;
                };
                try stdout.print(msg);
                allocator.free(msg);
            };

            // Create the framework.
            source.recreate(allocator, app_name) catch |create_err| {
                // Have input so make the error message.
                var user_command: []const u8 = try std.fmt.allocPrint(allocator, "{s} {s}", .{ command, verb_restart });
                defer allocator.free(user_command);
                const msg: []const u8 = warning.fatal(allocator, create_err, user_command) catch {
                    return create_err;
                };
                try stdout.print(msg);
                allocator.free(msg);
                return create_err;
            };
        } else {
            // User input is "framework ????".
            var framework_usage: []u8 = try usage.framework(allocator, cli_name, app_name);
            defer allocator.free(framework_usage);
            try stdout.print(framework_usage);
        }
    } else {
        // User input is "framework".
        // Create the framework if possible.
        if (folder_paths.isBuilt()) {
            // The framework was already built.
            try stdout.print(warning.already_built);
            return;
        }
        // Create the framework folders.
        try folder_paths.build();

        // Create the framework.
        source.create(allocator, app_name) catch |create_err| {
            // Have input so make the error message.
            const msg: []const u8 = warning.fatal(allocator, create_err, command) catch {
                return create_err;
            };
            try stdout.print(msg);
            allocator.free(msg);
            return create_err;
        };
    }
}
