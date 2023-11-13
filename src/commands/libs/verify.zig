const std = @import("std");
const strings = @import("strings");
const filenames = @import("filenames");

const initMessageName: []const u8 = "Initialize";
const fatalMessageName: []const u8 = "Fatal";

const okModalScreenName: []const u8 = "OK";

// Screen name.

/// isValidScreenName returns if the screen name is valid.
pub fn isValidScreenName(name: []const u8) bool {
    return strings.isValid(name);
}

/// isNewScreenName returns if the screen name is unique.
pub fn isNewScreenName(allocator: std.mem.Allocator, new_name: []const u8) bool {
    var names: [][]const u8 = try filenames.allFrontendScreenNames(allocator);
    defer {
        for (names) |name| {
            allocator.free(name);
        }
        allocator.free(names);
    }
    for (names) |name| {
        if (std.mem.eql(u8, name, new_name)) {
            return false;
        }
    }
    return true;
}

// Channel name.

/// isValidChannelName returns if the channel name is valid.
pub fn isValidChannelName(name: []const u8) bool {
    return strings.isValid(name);
}

/// isNewChannelName returns if the channel name is unique.
pub fn isNewChannelName(allocator: std.mem.Allocator, new_name: []const u8) bool {
    var names: [][]const u8 = try filenames.allDepsChannelNames(allocator);
    defer {
        for (names) |name| {
            allocator.free(name);
        }
        allocator.free(names);
    }
    for (names) |name| {
        if (std.mem.eql(u8, name, new_name)) {
            return false;
        }
    }
    return true;
}

// Message name.

/// isValidMessageName returns if the message name is valid.
pub fn isValidMessageName(name: []const u8) bool {
    if (!strings.isValid(name)) {
        return false;
    }
    if (std.mem.eql(u8, name, fatalMessageName)) {
        return false;
    }
    return !std.mem.eql(u8, name, initMessageName);
}

/// isNewMesssageName returns if the message name is unique.
pub fn isNewMesssageName(allocator: std.mem.Allocator, new_name: []const u8) !bool {
    var isNew: bool = try isNewSharedMesssageName(allocator, new_name);
    if (!isNew) {
        return isNew;
    }
    return isNewSharedMesssageName(allocator, new_name);
}

fn isNewSharedMesssageName(allocator: std.mem.Allocator, new_name: []const u8) !bool {
    var names: [][]const u8 = try filenames.allDepsMessageNames(allocator);
    defer {
        for (names) |name| {
            allocator.free(name);
        }
        allocator.free(names);
    }
    for (names) |name| {
        if (std.mem.eql(u8, name, new_name)) {
            return false;
        }
    }
    return true;
}

pub fn isNewBackendMesssageHandlerName(allocator: std.mem.Allocator, new_name: []const u8) !bool {
    var names: [][]const u8 = try filenames.allBackendMessageHandlerNames(allocator);
    defer {
        for (names) |name| {
            allocator.free(name);
        }
        allocator.free(names);
    }
    for (names) |name| {
        if (std.mem.eql(u8, name, new_name)) {
            return false;
        }
    }
    return true;
}
