const std = @import("std");
const fmt = std.fmt;
const strings = @import("strings");

pub const Template = struct {
    allocator: std.mem.Allocator,
    _message_names: []*strings.UTF8,
    _message_names_index: usize,

    pub fn init(allocator: std.mem.Allocator) !*Template {
        var data: *Template = try allocator.create(Template);
        data._message_names = try allocator.alloc(*strings.UTF8, 5);
        errdefer {
            allocator.destroy(data);
        }
        data._message_names_index = 0;
        data.allocator = allocator;
        return data;
    }

    pub fn deinit(self: *Template) void {
        for (self._message_names, 0..) |name, i| {
            if (i == self._message_names_index) {
                break;
            }
            name.deinit();
        }
        self.allocator.free(self._message_names);
        self.allocator.destroy(self);
    }

    pub fn addName(self: *Template, new_name: []const u8) !void {
        var new_message_names: []*strings.UTF8 = undefined;
        if (self._message_names_index == self._message_names.len) {
            // Full list so create a new bigger one.
            new_message_names = try self.allocator.alloc(*strings.UTF8, (self._message_names.len + 5));
            for (self._message_names, 0..) |name, i| {
                new_message_names[i] = name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self._message_names);
            self._message_names = new_message_names;
        }
        var utf8: *strings.UTF8 = try strings.UTF8.init(self.allocator, new_name);
        self._message_names[self._message_names_index] = utf8;
        self._message_names_index += 1;
    }

    pub fn content(self: *Template) ![]const u8 {
        var line: []u8 = undefined;
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        try lines.appendSlice(line1);
        var names: []*strings.UTF8 = self._message_names[0..self._message_names_index];
        var lc: []const u8 = undefined;
        var copy: []const u8 = undefined;
        for (names) |name| {
            {
                lc = try name.lowerCased();
                defer self.allocator.free(lc);
                copy = try name.copy();
                defer self.allocator.free(copy);
                line = try fmt.allocPrint(self.allocator, "const _{s}_ = @import(\"{s}.zig\");\n", .{ lc, copy });
                try lines.appendSlice(line);
                self.allocator.free(line);
            }
        }
        try lines.appendSlice(line2);
        for (names) |name| {
            {
                lc = try name.lowerCased();
                defer self.allocator.free(lc);
                copy = try name.copy();
                defer self.allocator.free(copy);
                line = try fmt.allocPrint(self.allocator, "    {s}: *_{s}_.Messenger,\n", .{ copy, lc });
                try lines.appendSlice(line);
                self.allocator.free(line);
            }
        }
        try lines.appendSlice(line3);
        for (names) |name| {
            {
                copy = try name.copy();
                defer self.allocator.free(copy);
                line = try fmt.allocPrint(self.allocator, "        self.{s}.deinit();\n", .{copy});
                try lines.appendSlice(line);
                self.allocator.free(line);
            }
        }
        try lines.appendSlice(line4);
        for (names, 0..) |name, i| {
            {
                lc = try name.lowerCased();
                copy = try name.copy();
                line = try fmt.allocPrint(self.allocator, "    messenger.{s} = try _{s}_.init(allocator, send_channels, receive_channels);\n", .{ copy, lc });
                try lines.appendSlice(line);
                self.allocator.free(line);
                try lines.appendSlice("    errdefer {\n");
                var deinit_names: []*strings.UTF8 = names[0..i];
                for (deinit_names, 0..i) |deinit_name, j| {
                    _ = deinit_name;
                    if (j < i) {
                        line = try fmt.allocPrint(self.allocator, "        messenger.{s}.deinit();\n", .{copy});
                        try lines.appendSlice(line);
                        self.allocator.free(line);
                    }
                }
            }
        }
        try lines.appendSlice(line5);
        return try lines.toOwnedSlice();
    }
};

const line1: []const u8 =
    \\const std = @import("std");
    \\
    \\const _channel_ = @import("channel");
    \\
;
// \\{{#messageNames}}
// \\    const _{{lower_case}}{{&content}}_ = @import("{{copy}}{{&content}}.zig");
// \\{{/messageNames}}

const line2: []const u8 =
    \\
    \\/// Messenger is the collection of the back-end message handlers.
    \\/// Each individual message handler initializes itself to
    \\/// - receive it's own unique message.
    \\/// - send messages to the front.
    \\pub const Messenger = struct {
    \\    allocator: std.mem.Allocator,
    \\
;
// \\{{#messageNames}}
// \\    {{copy}}{{&content}}: *_{{lower_case}}{{&content}}_.Messenger,
// \\{{/messageNames}}

const line3: []const u8 =
    \\
    \\    pub fn deinit(self: *Messenger) void {
    \\
;
// \\{{#messageNames}}
// \\        self.{{copy}}{{&content}}.deinit();
// \\{{/messageNames}}

const line4: []const u8 =
    \\    }
    \\};
    \\
    \\/// init constructs a Messenger.
    \\/// It initializes each unique message handler.
    \\pub fn init(allocator: std.mem.Allocator, send_channels: *_channel_.Channels, receive_channels: *_channel_.Channels) !*Messenger {
    \\    var messenger: *Messenger = try allocator.create(Messenger);
    \\    errdefer {
    \\        messenger.allocator.destroy(messenger);
    \\    }
    \\
;
// \\{{#messageNames}}
// \\    messenger.{{copy}}{{&content}} = try _{{lower_case}}{{&content}}_.init(allocator, send_channels, receive_channels);
// \\    errdefer {
// \\{{#deinits}}
// \\        messenger.{{copy}}{{&content}}.deinit();
// \\{{/deinits}}

const line5: []const u8 =
    \\        messenger.Initialize.deinit();
    \\        messenger.allocator.destroy(messenger);
    \\    }
    \\    return messenger;
    \\}
    \\
;
