const std = @import("std");
const lower_case: []const u8 = "abcdefghijklmnopqrstuvwxyz";
const digit: []const u8 = "1234567890";
const punctuation: u8 = '_';

// prefix prefixes a fix.
// Caller has control of returned value.
pub fn prefix(allocator: std.mem.Allocator, src: []const u8, fix: []const u8) ![]const u8 {
    const fixed = std.ArrayList(u8).init(allocator);
    try fixed.appendSlice(fix);
    try fixed.appendSlice(src);
    return try fixed.toOwnedSlice();
}

// suffix suffixes a fix.
// Caller has control of returned value.
pub fn sufix(allocator: std.mem.Allocator, src: []const u8, fix: []const u8) ![]const u8 {
    const fixed = std.ArrayList(u8).init(allocator);
    try fixed.appendSlice(src);
    try fixed.appendSlice(fix);
    return try fixed.toOwnedSlice();
}

/// isValid returns if the text is valid for a , screen, panel, message, record, store name.
pub fn isValid(text: []const u8) bool {
    var found: bool = false;
    var is_valid: bool = false;
    for (text, 0..) |name_c, i| {
        // Check for '_'.
        found = (name_c == punctuation);
        if (found) {
            is_valid = (i > 0);
            if (is_valid) {
                // This is a correctly used '_'.
                continue;
            } else {
                // The first character can not be '_'.
                // This character is not valid.
                break;
            }
        }
        // Check for lower case letters match.
        for (lower_case) |c| {
            found = (name_c == c);
            if (found) {
                break;
            }
        }
        if (found) {
            continue;
        }
        // Check for digit match.
        is_valid = false;
        for (digit) |c| {
            found = (name_c == c);
            if (found) {
                is_valid = (i > 0);
                break;
            }
        }
        if (found & is_valid) {
            // This character is valid so check the next one.
            continue;
        } else {
            // This character is not valid.
            break;
        }
    }
    return is_valid;
}
