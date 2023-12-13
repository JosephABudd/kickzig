const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    message_names: [][]const u8,
    message_names_index: usize,

    // The caller owns the returned value.
    pub fn init(allocator: std.mem.Allocator) !*Template {
        var data: *Template = try allocator.create(Template);
        data.message_names = try allocator.alloc([]const u8, 5);
        errdefer {
            allocator.destroy(data);
        }
        data.message_names_index = 0;
        data.allocator = allocator;
        return data;
    }

    pub fn deinit(self: *Template) void {
        for (self.message_names, 0..) |name, i| {
            if (i == self.message_names_index) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self.message_names);
        self.allocator.destroy(self);
    }

    pub fn addName(self: *Template, new_name: []const u8) !void {
        var new_message_names: [][]const u8 = undefined;
        if (self.message_names_index == self.message_names.len) {
            // Full list so create a new bigger one.
            new_message_names = try self.allocator.alloc([]const u8, (self.message_names.len + 5));
            for (self.message_names, 0..) |name, i| {
                new_message_names[i] = name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self.message_names);
            self.message_names = new_message_names;
        }
        self.message_names[self.message_names_index] = try self.allocator.alloc(u8, new_name.len);
        @memcpy(@constCast(self.message_names[self.message_names_index]), new_name);
        self.message_names_index += 1;
    }

    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        var line: []u8 = undefined;
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        try lines.appendSlice(line1);
        var names: [][]const u8 = self.message_names[0..self.message_names_index];
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, "const _{0s}_ = @import(\"{0s}.zig\");\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line2);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, "    {0s}: *_{0s}_.Messenger,\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line3);
        for (names) |name| {
            line = try fmt.allocPrint(self.allocator, "        self.{0s}.deinit();\n", .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line4);
        for (names, 0..) |name, i| {
            {
                line = try fmt.allocPrint(self.allocator, "    messenger.{0s} = try _{0s}_.init(allocator, send_channels, receive_channels);\n", .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
            try lines.appendSlice("    errdefer {\n");
            var deinit_names: [][]const u8 = names[0..i];
            for (deinit_names) |deinit_name| {
                line = try fmt.allocPrint(self.allocator, "        messenger.{0s}.deinit();\n", .{deinit_name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        try lines.appendSlice(line5);
        var temp: []const u8 = try lines.toOwnedSlice();
        line = try self.allocator.alloc(u8, temp.len);
        @memcpy(@constCast(line), temp);
        return line;
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
