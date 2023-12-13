const std = @import("std");
const strings = @import("strings");
const filenames = @import("filenames");

const initMessageName: []const u8 = "Initialize";
const fatalMessageName: []const u8 = "Fatal";

// Screen name.

/// isValidScreenName returns if the screen name is valid.
pub fn isValidScreenName(name: []const u8) bool {
    return strings.isValid(name);
}

/// isNewScreenName returns if the screen name is unique.
pub fn isNewScreenName(allocator: std.mem.Allocator, new_name: []const u8) bool {
    var names: [][]const u8 = try filenames.allFrontendScreenNames(allocator) catch {
        return false;
    };
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

// Panel name.

/// isNewScreenName returns if the screen name is unique.
pub fn isNewScreenPanelName(allocator: std.mem.Allocator, screen_name: []const u8, panel_name: []const u8) bool {
    _ = screen_name;
    var names: [][]const u8 = try filenames.allFrontendScreenNames(allocator) catch {
        return false;
    };
    defer {
        for (names) |name| {
            allocator.free(name);
        }
        allocator.free(names);
    }
    for (names) |name| {
        if (std.mem.eql(u8, name, panel_name)) {
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
    var names: [][]const u8 = try filenames.allDepsChannelNames(allocator) catch {
        return false;
    };
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

fn isNewMesssageName(allocator: std.mem.Allocator, new_name: []const u8) bool {
    var names: [][]const u8 = try filenames.allDepsMessageNames(allocator) catch {
        return false;
    };
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

// Tab name.

/// isValidTabName returns if the message name is valid.
pub fn isValidTabName(name: []const u8) bool {
    var tab_name: []const u8 = undefined;
    if (name[0] == '+') {
        tab_name = name[1..];
    } else {
        tab_name = name;
    }
    return strings.isValid(tab_name);
}
