const std = @import("std");

// The caller owns the returned value.
pub fn fatal(allocator: std.mem.Allocator, err: anyerror, command: []const u8) ![]const u8 {
    return std.fmt.allocPrint(allocator, "The following fatal error occurred while executing \"{s}\": \"{s}.\n", .{ command, @errorName(err) });
}

// The caller owns the returned value.
pub fn syntaxError(allocator: std.mem.Allocator, cli_name: []const u8, cmd: []const u8, help_verb: []const u8) ![]const u8 {
    const line2: []const u8 = try std.fmt.allocPrint(allocator, "Try «{0s} {1s} {2s}»\n", .{ cli_name, cmd, help_verb });
    defer allocator.free(line2);
    const lines: [2][]const u8 = [2][]const u8{
        "Not sure what you are trying to do.\n",
        line2,
    };
    return std.mem.join(allocator, "", &lines);
}

// Framework build.

pub const already_built: []const u8 = "The framework is already built.\n";
pub const already_built_with_messages: []const u8 = "The framework is already built with messages.\n";
pub const already_built_without_messages: []const u8 = "The framework is already built without messages.\n";
pub const not_framework_folder: []const u8 = "A framework root folder was not found in your path.\n";
// Channel name.

/// invalidChannelNameMessage returns a invalid channel name message.
/// The caller controls the returned value.
pub fn invalidChannelNameMessage(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not a valid channel name. Use lower case and underscore.", name);
}

/// notNewChannelNameMessage returns a not new channel name message.
/// The caller controls the returned value.
pub fn notNewChannelNameMessage(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not a new channel name.", name);
}

/// notCurrentChannelNameMessage returns a not current channel name message.
/// The caller controls the returned value.
pub fn notCurrentChannelNameMessage(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not a current channel name.", name);
}

// Message name.

pub const addMessageError: []const u8 = "This framework was intentionally created without messages.\nYou can not add messages now.\n";

/// invalidMessageNameMessage returns a invalid message name message.
/// The caller controls the returned value.
pub fn invalidMessageNameMessage(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not a valid message name. Use lower case and underscore.", name);
}

/// notNewMessageNameMessage returns a not new message name message.
/// The caller controls the returned value.
pub fn notNewMessageNameMessage(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not a new message name.", name);
}

/// notCurrentMessageNameMessage returns a not current message name message.
/// The caller controls the returned value.
pub fn notCurrentMessageNameMessage(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not a current message name.", name);
}

// Screen.

/// notUniqueScreenName returns not a unique screen name message.
/// The caller controls the returned value.
pub fn notUniqueScreenName(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not a new and unique screen name.\n", .{name});
}

/// notValidScreenName returns not a valid screen name message.
/// The caller controls the returned value.
pub fn notValidScreenName(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not an valid screen name.\n", .{name});
}

/// partOfFrameworkScreenName returns screen is part of framework message.
/// The caller controls the returned value.
pub fn partOfFrameworkScreenName(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "The \"{s}\" screen is part of the framework and cannot be removed.\n", .{name});
}

/// notNewScreenName returns not an new screen name message.
/// The caller controls the returned value.
pub fn notNewScreenName(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not a new screen name.\n", .{name});
}

/// notExistingScreenName returns not an current screen name message.
/// The caller controls the returned value.
pub fn notExistingScreenName(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not an current screen name.\n", .{name});
}

/// notExistingPanelScreenName returns not an current panel-screen name message.
/// The caller controls the returned value.
pub fn notExistingPanelScreenName(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not an current panel-screen name.\n", .{name});
}

// Screen Panel.

/// notValidPanelName returns not a valid panel name message.
/// The caller controls the returned value.
pub fn notValidPanelName(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not an valid panel name.\n", .{name});
}

// Screen Tab.

/// notNewTabName returns not a new tab name message.
/// The caller controls the returned value.
pub fn notNewTabName(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not a new tab name.\n", .{name});
}

/// notUniqueTabName retusn a not unique tab name message.
/// The caller controls the returned value.
pub fn notUniqueTabName(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not a unique tab name.\n", .{name});
}

/// notValidScreenTabName returns a not current tab name message.
/// The caller controls the returned value.
pub fn notValidScreenTabName(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not a valid name for a tab using screen content.\nA tab using screen content must have the same name as the content-screen or panel-screen providing the content.\nThe content-screen or panel-screen providing the content must already exist.\n", .{name});
}
