const std = @import("std");
const unicode = std.unicode;
const strings = @import("strings");

const uc_vowels = []const u8{ 'A', 'E', 'I', 'O', 'U' };
const lc_vowels = []const u8{ 'a', 'e', 'i', 'o', 'u' };

// pub const UTF8 = struct {
//     allocator: std.mem.Allocator,
//     string: []const u8,

//     pub fn init(allocator: std.mem.Allocator, original: []const u8) !*UTF8 {
//         var utf8: *UTF8 = try allocator.create(UTF8);
//         utf8.allocator = allocator;
//         utf8.string = try utf8.utf8Only(original);
//         return utf8;
//     }

//     pub fn deinit(self: *UTF8) void {
//         self.allocator.free(self.string);
//         self.allocator.destroy(self);
//     }

//     /// copy returns a copy of the utf8 string.
//     // Caller has control of returned value.
//     pub fn copy(self: *UTF8) ![]const u8 {
//         var string_copy: []const u8 = try self.allocator.alloc(u8, self.string.len);
//         @memcpy(@constCast(string_copy), self.string);
//         return string_copy;
//     }

//     // prefix prefixes self.string and returns a copy of self.string.
//     // Caller has control of returned value.
//     pub fn prefix(self: *UTF8, fix: []const u8) ![]const u8 {
//         const fixed = std.ArrayList(u8).init(self.allocator);
//         defer fixed.deinit();
//         const utf8_fix = try self.utf8Only(fix);
//         defer utf8_fix.deinit();
//         try fixed.appendSlice(utf8_fix);
//         try fixed.appendSlice(self.string);
//         var fixed_string: []const u8 = try fixed.toOwnedSlice();
//         // Set self.string;
//         self.allocator.free(self.string);
//         self.string = try self.allocator.alloc(u8, fixed_string.len);
//         @memcpy(self.string, fixed_string);
//         // Return a copy of the fixed string.
//         var copy_string: []const u8 = try self.allocator.alloc(u8, self.string.len);
//         @memcpy(@constCast(copy_string), self.string);
//         return copy_string;
//     }

//     // suffix suffixes self.string and returns a copy of self.string.
//     // Caller has control of returned value.
//     pub fn suffix(self: *UTF8, fix: []const u8) ![]const u8 {
//         const fixed = std.ArrayList(u8).init(self.allocator);
//         defer fixed.deinit();
//         const utf8_fix = try self.utf8Only(fix);
//         defer utf8_fix.deinit();
//         try fixed.appendSlice(self.string);
//         try fixed.appendSlice(utf8_fix);
//         var fixed_string: []const u8 = try fixed.toOwnedSlice();
//         // Set self.string;
//         self.allocator.free(self.string);
//         self.string = try self.allocator.alloc(u8, fixed_string.len);
//         @memcpy(self.string, fixed_string);
//         // Return a copy of the fixed string.
//         var copy_string: []const u8 = try self.allocator.alloc(u8, self.string.len);
//         @memcpy(@constCast(copy_string), self.string);
//         return copy_string;
//     }

//     // prefixed returns a prefixed copy of self.string.
//     // It leaves self.string unchanged.
//     // Caller has control of returned value.
//     pub fn prefixed(self: *UTF8, fix: []const u8) ![]const u8 {
//         const fixed = std.ArrayList(u8).init(self.allocator);
//         defer fixed.deinit();
//         const utf8_fix = try self.utf8Only(fix);
//         defer utf8_fix.deinit();
//         try fixed.appendSlice(utf8_fix);
//         try fixed.appendSlice(self.string);
//         var fixed_string: []const u8 = try fixed.toOwnedSlice();
//         return fixed_string;
//     }

//     // suffixed returns a suffixed copy of self.string.
//     // It leaves self.string unchanged.
//     // Caller has control of returned value.
//     pub fn suffixed(self: *UTF8, fix: []const u8) ![]const u8 {
//         const fixed = std.ArrayList(u8).init(self.allocator);
//         defer fixed.deinit();
//         const utf8_fix = try self.utf8Only(fix);
//         defer utf8_fix.deinit();
//         try fixed.appendSlice(self.string);
//         try fixed.appendSlice(utf8_fix);
//         var fixed_string: []const u8 = try fixed.toOwnedSlice();
//         return fixed_string;
//     }

//     // lowerCase lower cases self.string and returns a copy of self.string.
//     // Caller has control of returned value.
//     pub fn lowerCase(self: *UTF8) ![]const u8 {
//         const l: usize = self.string.len;
//         var i: usize = 0;
//         while (i < l) {
//             var unicode_len: usize = try unicode.utf8ByteSequenceLength(self.string[i]) catch {
//                 // z-byte or junk
//                 break;
//             };
//             if (unicode_len == 1) {
//                 self.string[i] = std.ascii.toLower(self.string[i]);
//             }
//             i += unicode_len;
//         }
//         // Return a copy of the fixed string.
//         var copy_string: []const u8 = try self.allocator.alloc(u8, self.string.len);
//         @memcpy(@constCast(copy_string), self.string);
//         return copy_string;
//     }

//     // upperCase upper cases self.string and returns a copy of self.string.
//     // Caller has control of returned value.
//     pub fn upperCase(self: *UTF8) ![]const u8 {
//         const l: usize = self.string.len;
//         var i: usize = 0;
//         while (i < l) {
//             var unicode_len: usize = try unicode.utf8ByteSequenceLength(self.string[i]) catch {
//                 // z-byte or junk
//                 break;
//             };
//             if (unicode_len == 1) {
//                 self.string[i] = std.ascii.toUpper(self.string[i]);
//             }
//             i += unicode_len;
//         }
//         // Return a copy of the fixed string.
//         var copy_string: []const u8 = try self.allocator.alloc(u8, self.string.len);
//         @memcpy(@constCast(copy_string), self.string);
//         return copy_string;
//     }

//     // lowerCased returns a lower cased copy of self.string.
//     // It leaves self.string unchanged.
//     // Caller has control of returned value.
//     pub fn lowerCased(self: *UTF8) ![]const u8 {
//         const l: usize = self.string.len;
//         var i: usize = 0;
//         var cased: []const u8 = try self.allocator.alloc(u8, self.string.len);
//         @memcpy(@constCast(cased), self.string);
//         while (i < l) {
//             var unicode_len: u3 = unicode.utf8ByteSequenceLength(cased[i]) catch {
//                 // z-byte or junk
//                 break;
//             };
//             if (unicode_len == 1) {
//                 @constCast(cased)[i] = std.ascii.toLower(cased[i]);
//             }
//             i += unicode_len;
//         }
//         return cased;
//     }

//     // upperCased returns a upper cased copy of self.string.
//     // It leaves self.string unchanged.
//     // Caller has control of returned value.
//     pub fn upperCased(self: *UTF8) ![]const u8 {
//         const l: usize = self.string.len;
//         var i: usize = 0;
//         var cased: []const u8 = try self.allocator.alloc(u8, self.string.len);
//         @memcpy(cased, self.string);
//         while (i < l) {
//             var unicode_len: usize = try unicode.utf8ByteSequenceLength(cased[i]) catch {
//                 // z-byte or junk
//                 break;
//             };
//             if (unicode_len == 1) {
//                 cased[i] = std.ascii.toUpper(cased[i]);
//             }
//             i += unicode_len;
//         }
//         return cased;
//     }

//     // aAn returns "a" or "an".
//     // It leaves self.string unchanged.
//     // Caller has control of returned value.
//     pub fn aAn(self: *UTF8) ![]const u8 {
//         var a_an: []const u8 = undefined;
//         if (std.mem.indexOf(u8, uc_vowels, self.string[0])) |_| {
//             // The name begins with a vowel.
//             a_an = try self.allocator.alloc(u8, 2);
//             @memcpy(a_an, "an");
//             return a_an;
//         }
//         if (std.mem.indexOf(u8, lc_vowels, self.string[0])) |_| {
//             // The name begins with a vowel.
//             a_an = try self.allocator.alloc(u8, 2);
//             @memcpy(a_an, "an");
//             return a_an;
//         }
//         if (self.string[0] == 'Y') {
//             if (std.mem.indexOf(u8, uc_vowels, self.string[1])) |_| {
//                 // The name begins with 'Y' followed by a vowel.
//                 // "YAngle"
//                 a_an = try self.allocator.alloc(u8, 1);
//                 @memcpy(a_an, "a");
//                 return a_an;
//             }
//             if (std.mem.indexOf(u8, lc_vowels, self.string[1])) |_| {
//                 // The name begins with 'Y' followed by a vowel.
//                 // "Yellow"
//                 a_an = try self.allocator.alloc(u8, 1);
//                 @memcpy(a_an, "a");
//                 return a_an;
//             }
//             // The name begins with 'Y' followed by a consonant.
//             // "Y" sounds like the vowel "I".
//             // "Ywis"
//             a_an = try self.allocator.alloc(u8, 2);
//             @memcpy(a_an, "an");
//             return a_an;
//         }
//         a_an = try self.allocator.alloc(u8, 1);
//         @memcpy(a_an, "a");
//         return a_an;
//     }

//     // Caller has control of returned value.
//     fn utf8Only(self: *UTF8, src: []const u8) ![]const u8 {
//         // Convert the input to a utf8 string.
//         var characters = std.ArrayList(u8).init(self.allocator);
//         defer characters.deinit();

//         const l: usize = src.len;
//         var i: usize = 0;
//         while (i < l) {
//             var byte: u8 = src[i];
//             const unicode_len: u3 = unicode.utf8ByteSequenceLength(byte) catch 0;
//             if (unicode_len == 0) {
//                 break;
//             }
//             var last: usize = i + @as(usize, unicode_len);
//             if (last > l) {
//                 // ignore these junk characters.
//                 break;
//             }
//             // Append each of the character's bytes.
//             try characters.append(byte);
//             i += 1;
//             while (i < last) {
//                 try characters.append(src[i]);
//                 i += 1;
//             }
//         }
//         return try characters.toOwnedSlice();
//     }
// };

/// isValid returns if the text is valid for a , screen, panel, message name.
pub fn isValid(text: []const u8) bool {
    var is_valid: bool = false;
    for (text, 0..) |c, i| {
        if (i == 0) {
            // Valid first characters are A-Z.
            is_valid = (c >= 'A' and c <= 'Z');
        } else {
            // Characters after first character.
            is_valid = (c >= 'A' and c <= 'Z') or (c >= 'a' and c <= 'z') or (c >= '0' and c <= '9');
        }
        if (!is_valid) {
            break;
        }
    }
    return is_valid;
}
