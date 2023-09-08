const std = @import("std");

pub fn fatal(allocator: std.mem.Allocator, err: anyerror, command: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "The following fatal error occurred while executing \"{s}\": \"{s}.\n", .{ command, @errorName(err) });
}

// Framework build.

pub const already_built: []const u8 = "The framework is already built.\n";

// Screen name.

/// invalidScreenNameMessage returns a invalid screen name message.
/// The caller controls the returned value.
pub fn invalidScreenNameMessage(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not a valid screen name. Use lower case and underscore.", name);
}

/// notNewScreenNameMessage returns a not new screen name message.
/// The caller controls the returned value.
pub fn notNewScreenNameMessage(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not a new screen name.", name);
}

/// notCurrentScreenNameMessage returns a not new screen name message.
/// The caller controls the returned value.
pub fn notCurrentScreenNameMessage(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "\"{s}\" is not a current screen name.", name);
}

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
