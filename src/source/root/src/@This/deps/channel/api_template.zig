const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    backend_to_frontend_channel_names: [][]const u8,
    backend_to_frontend_channel_names_index: usize,
    backend_trigger_names: [][]const u8,
    backend_trigger_names_index: usize,
    frontend_to_backend_channel_names: [][]const u8,
    frontend_to_backend_channel_names_index: usize,

    pub fn init(allocator: std.mem.Allocator) !*Template {
        var data: *Template = try allocator.create(Template);
        data.frontend_to_backend_channel_names = try allocator.alloc([]const u8, 5);
        errdefer {
            allocator.destroy(data);
        }
        data.frontend_to_backend_channel_names_index = 0;
        data.backend_to_frontend_channel_names = try allocator.alloc([]const u8, 5);
        errdefer {
            allocator.free(data.frontend_to_backend_channel_names);
            allocator.destroy(data);
        }
        data.backend_to_frontend_channel_names_index = 0;
        data.backend_trigger_names = try allocator.alloc([]const u8, 5);
        errdefer {
            allocator.free(data.backend_to_frontend_channel_names);
            allocator.free(data.frontend_to_backend_channel_names);
            allocator.destroy(data);
        }
        data.backend_trigger_names_index = 0;
        data.allocator = allocator;
        return data;
    }

    pub fn deinit(self: *Template) void {
        // backend_to_frontend_channel_names
        for (self.backend_to_frontend_channel_names, 0..) |name, i| {
            if (self.backend_to_frontend_channel_names_index == i) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self.backend_to_frontend_channel_names);
        // backend_trigger_names
        for (self.backend_trigger_names, 0..) |name, i| {
            if (self.backend_trigger_names_index == i) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self.backend_trigger_names);
        // frontend_to_backend_channel_names
        for (self.frontend_to_backend_channel_names, 0..) |name, i| {
            if (self.frontend_to_backend_channel_names_index == i) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self.frontend_to_backend_channel_names);
        self.allocator.destroy(self);
    }

    pub fn addBFName(self: *Template, new_name: []const u8) !void {
        // This is a back to front channel.
        try self.addBackToFrontChannelName(new_name);
        try self.addBackendTriggerName(new_name);
    }

    pub fn addFBFName(self: *Template, new_name: []const u8) !void {
        // This is a front to back channel.
        try self.addFrontToBackChannelName(new_name);
        try self.addBackToFrontChannelName(new_name);
        self.fbf_channel_names_index += 1;
    }

    pub fn addBFFBFName(self: *Template, new_name: []const u8) !void {
        try self.addFrontToBackChannelName(new_name);
        try self.addBackToFrontChannelName(new_name);
        try self.addBackendTriggerName(new_name);
    }

    pub fn addBackToFrontChannelName(self: *Template, new_name: []const u8) !void {
        if (self.backend_to_frontend_channel_names_index == self.backend_to_frontend_channel_names.len) {
            // Full list so create a new bigger one.
            var new_backend_to_frontend_channel_names: [][]const u8 = try self.allocator.alloc([]const u8, (self.backend_to_frontend_channel_names.len + 5));
            for (self.backend_to_frontend_channel_names, 0..) |name, i| {
                new_backend_to_frontend_channel_names[i] = name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self.backend_to_frontend_channel_names);
            self.backend_to_frontend_channel_names = new_backend_to_frontend_channel_names;
        }
        const name: []const u8 = try self.allocator.alloc(u8, new_name.len);
        @memcpy(@constCast(name), new_name);
        self.backend_to_frontend_channel_names[self.backend_to_frontend_channel_names_index] = name;
        self.backend_to_frontend_channel_names_index += 1;
    }

    pub fn addBackendTriggerName(self: *Template, new_name: []const u8) !void {
        if (self.backend_trigger_names_index == self.backend_trigger_names.len) {
            // Full list so create a new bigger one.
            var new_backend_trigger_names: [][]const u8 = try self.allocator.alloc([]const u8, (self.backend_trigger_names.len + 5));
            for (self.backend_trigger_names, 0..) |name, i| {
                new_backend_trigger_names[i] = name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self.backend_trigger_names);
            self.backend_trigger_names = new_backend_trigger_names;
        }
        const name: []const u8 = try self.allocator.alloc(u8, new_name.len);
        @memcpy(@constCast(name), new_name);
        self.backend_trigger_names[self.backend_trigger_names_index] = name;
        self.backend_trigger_names_index += 1;
    }

    pub fn addFrontToBackChannelName(self: *Template, new_name: []const u8) !void {
        if (self.frontend_to_backend_channel_names_index == self.frontend_to_backend_channel_names.len) {
            // Full list so create a new bigger one.
            var new_frontend_to_backend_channel_names: [][]const u8 = try self.allocator.alloc([]const u8, (self.frontend_to_backend_channel_names.len + 5));
            for (self.frontend_to_backend_channel_names, 0..) |name, i| {
                new_frontend_to_backend_channel_names[i] = name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self.frontend_to_backend_channel_names);
            self.frontend_to_backend_channel_names = new_frontend_to_backend_channel_names;
        }
        const name: []const u8 = try self.allocator.alloc(u8, new_name.len);
        @memcpy(@constCast(name), new_name);
        self.frontend_to_backend_channel_names[self.frontend_to_backend_channel_names_index] = name;
        self.frontend_to_backend_channel_names_index += 1;
    }

    pub fn content(self: *Template) ![]const u8 {
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();

        const frontend_to_backend_channel_names: [][]const u8 = self.frontend_to_backend_channel_names[0..self.frontend_to_backend_channel_names_index];
        const backend_to_frontend_channel_names: [][]const u8 = self.backend_to_frontend_channel_names[0..self.backend_to_frontend_channel_names_index];
        const backend_trigger_names: [][]const u8 = self.backend_trigger_names[0..self.backend_trigger_names_index];

        // Imports.
        try lines.appendSlice(line1);
        {
            // backtofront/ imports.
            for (backend_to_frontend_channel_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, "const _backend_to_frontend_{0s}_ = @import(\"backtofront/{0s}.zig\");\n", .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        {
            // fronttoback/ imports.
            for (frontend_to_backend_channel_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, "const _frontend_to_backend_{0s}_ = @import(\"fronttoback/{0s}.zig\");\n", .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        {
            // trigger/ imports.
            for (backend_trigger_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, "const _trigger_{0s}_ = @import(\"trigger/{0s}.zig\");\n", .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }

        // FrontToBack struct.
        try lines.appendSlice(lineFBa);
        {
            // frontend declarations.
            for (frontend_to_backend_channel_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, "        {0s}: *_frontend_to_backend_{0s}_.Group,\n", .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        try lines.appendSlice(lineFBb);
        {
            // frontend deinits.
            for (frontend_to_backend_channel_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, "        self.{0s}.deinit();\n", .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }

        try lines.appendSlice(lineFBc);
        if (frontend_to_backend_channel_names.len == 0) {
            const line: []const u8 = try fmt.allocPrint(self.allocator, "        _ = exit;\n", .{});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        } else {
            // frontend inits.
            for (frontend_to_backend_channel_names, 0..) |name, i| {
                {
                    const line: []const u8 = try fmt.allocPrint(self.allocator, "        channels.{0s} = _frontend_to_backend_{0s}_.init(allocator, exit) catch |err| {{\n", .{name});
                    defer self.allocator.free(line);
                    try lines.appendSlice(line);
                }
                if (i > 0) {
                    const deinit_names: [][]const u8 = frontend_to_backend_channel_names[0..i];
                    for (deinit_names) |deinit_name| {
                        const line: []const u8 = try fmt.allocPrint(self.allocator, "            channels.{0s}.deinit();\n", .{deinit_name});
                        defer self.allocator.free(line);
                        try lines.appendSlice(line);
                    }
                }
                try lines.appendSlice("            allocator.destroy(channels);\n");
                try lines.appendSlice("            return err;\n");
                try lines.appendSlice("        };\n");
            }
        }
        try lines.appendSlice(lineFBd);

        // BackToFront struct.
        try lines.appendSlice(lineBFa);
        {
            // BackToFront member declarations.
            for (backend_to_frontend_channel_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, "        {0s}: *_backend_to_frontend_{0s}_.Group,\n", .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }

        try lines.appendSlice(lineBFb);
        // BackToFront.deinit().
        {
            // channel deinits.
            for (backend_to_frontend_channel_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, "        self.{0s}.deinit();\n", .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }

        // BackToFront.init(...).
        try lines.appendSlice(lineBFc);
        if (backend_to_frontend_channel_names.len == 0) {
            const line: []const u8 = try fmt.allocPrint(self.allocator, "        _ = exit;\n", .{});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        } else {
            // channel inits.
            for (backend_to_frontend_channel_names, 0..) |name, i| {
                {
                    const line: []const u8 = try fmt.allocPrint(self.allocator, "        channels.{0s} = _backend_to_frontend_{0s}_.init(allocator, exit) catch |err| {{\n", .{name});
                    defer self.allocator.free(line);
                    try lines.appendSlice(line);
                }
                if (i > 0) {
                    const deinit_names: [][]const u8 = backend_to_frontend_channel_names[0..i];
                    for (deinit_names) |deinit_name| {
                        const line: []const u8 = try fmt.allocPrint(self.allocator, "            channels.{0s}.deinit();\n", .{deinit_name});
                        defer self.allocator.free(line);
                        try lines.appendSlice(line);
                    }
                }
                try lines.appendSlice("            allocator.destroy(channels);\n");
                try lines.appendSlice("            return err;\n");
                try lines.appendSlice("        };\n");
            }
        }
        try lines.appendSlice(lineBFd);

        // Trigger struct.
        try lines.appendSlice(lineTRa);
        // Trigger member declarations.
        {
            // triggers members.
            for (backend_trigger_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, "        {0s}: *_trigger_{0s}_.Group,\n", .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }

        try lines.appendSlice(lineTRb);
        if (backend_trigger_names.len == 0) {
            const line: []const u8 = try fmt.allocPrint(self.allocator, "        _ = exit;\n", .{});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        } else {
            // trigger inits.
            for (backend_trigger_names, 0..) |name, i| {
                {
                    const line: []const u8 = try fmt.allocPrint(self.allocator, "        triggers.{0s} = _trigger_{0s}_.init(triggers.allocator, exit) catch |err| {{\n", .{name});
                    defer self.allocator.free(line);
                    try lines.appendSlice(line);
                }
                if (i > 0) {
                    const deinit_names: [][]const u8 = backend_trigger_names[0..i];
                    for (deinit_names) |deinit_name| {
                        const line: []const u8 = try fmt.allocPrint(self.allocator, "            triggers.{0s}.deinit();\n", .{deinit_name});
                        defer self.allocator.free(line);
                        try lines.appendSlice(line);
                    }
                }
                try lines.appendSlice("            triggers.allocator.destroy(triggers);\n");
                try lines.appendSlice("            return err;\n");
                try lines.appendSlice("        };\n");
            }
        }
        try lines.appendSlice(lineTRc);
        const owned_slice = try lines.toOwnedSlice();
        const slice = try self.allocator.alloc(u8, owned_slice.len);
        @memcpy(slice, owned_slice);
        return slice;
    }
};

const line1: []const u8 =
    \\// This file is re-generated by kickzig when a message is added or removed.
    \\// DO NOT EDIT THIS FILE.
    \\const std = @import("std");
    \\const testing = std.testing;
    \\
;
// \\const _XXX_ = @import("src/XXX.zig");
// \\const _YYY_ = @import("src/YYY.zig");
// \\const _ZZZ_ = @import("src/ZZZ.zig");
// \\

const lineFBa: []const u8 =
    \\
    \\/// FrontendToBackend is each message's channel.
    \\pub const FrontendToBackend = struct {
    \\    allocator: std.mem.Allocator,
    \\
    \\    // Custom channels.
    \\
;
// XXX: *_XXX_.Group,
// YYY: *_YYY_.Group,
// ZZZ: *_ZZZ_.Group,

const lineFBb =
    \\
    \\    pub fn deinit(self: *FrontendToBackend) void {
    \\
;
// self.XXX.deinit();
// self.YYY.deinit();
// self.ZZZ.deinit();

const lineFBc =
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\
    \\    pub fn init(allocator: std.mem.Allocator, exit: *const fn (user_message: []const u8) void) !*FrontendToBackend {
    \\        var channels: *FrontendToBackend = try allocator.create(FrontendToBackend);
    \\        channels.allocator = allocator;
    \\    
    \\        // Customs.
    \\
;
// channels.XXX = _XXX_.init(allocator) catch |err| {
//     allocator.destroy(channels);
//     return err;
// };

// channels.YYY = _YYY_.init(allocator) catch |err| {
//     channels.XXX.deinit();
//     allocator.destroy(channels);
//     return err;
// };

// channels.ZZZ = _ZZZ_.init(allocator) catch |err| {
//     channels.YYY.deinit();
//     channels.XXX.deinit();
//     allocator.destroy(channels);
//     return err;
// };

const lineFBd =
    \\
    \\        return channels;
    \\    }
    \\};
    \\
    \\
;

const lineBFa: []const u8 =
    \\
    \\/// BackendToFrontend is each message's channel.
    \\pub const BackendToFrontend = struct {
    \\    allocator: std.mem.Allocator,
    \\
    \\    // Custom channels.
    \\
;
// XXX: *_XXX_.Group,
// YYY: *_YYY_.Group,
// ZZZ: *_ZZZ_.Group,

const lineBFb =
    \\
    \\    pub fn deinit(self: *BackendToFrontend) void {
    \\
;
// self.XXX.deinit();
// self.YYY.deinit();
// self.ZZZ.deinit();

const lineBFc =
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\
    \\    pub fn init(allocator: std.mem.Allocator, exit: *const fn (user_message: []const u8) void) !*BackendToFrontend {
    \\        var channels: *BackendToFrontend = try allocator.create(BackendToFrontend);
    \\        channels.allocator = allocator;
    \\    
    \\        // Customs.
    \\
;
// channels.XXX = _XXX_.init(allocator) catch |err| {
//     allocator.destroy(channels);
//     return err;
// };

// channels.YYY = _YYY_.init(allocator) catch |err| {
//     channels.XXX.deinit();
//     allocator.destroy(channels);
//     return err;
// };

// channels.ZZZ = _ZZZ_.init(allocator) catch |err| {
//     channels.YYY.deinit();
//     channels.XXX.deinit();
//     allocator.destroy(channels);
//     return err;
// };

const lineBFd =
    \\
    \\        return channels;
    \\    }
    \\};
    \\
;

const lineTRa: []const u8 =
    \\
    \\/// Trigger is each trigger.
    \\pub const Trigger = struct {
    \\    allocator: std.mem.Allocator,
    \\
    \\
;
// XXX: *_XXX_.Group,
// YYY: *_YYY_.Group,
// ZZZ: *_ZZZ_.Group,

const lineTRb =
    \\
    \\    pub fn deinit(self: *Trigger) void {
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    pub fn init(backend_to_frontend: *BackendToFrontend, exit: *const fn (user_message: []const u8) void) !*Trigger {
    \\        var triggers: *Trigger = try backend_to_frontend.allocator.create(Trigger);
    \\        triggers.allocator = backend_to_frontend.allocator;
    \\    
    \\
;
// triggers.XXX = backend_to_frontend.XXX;
// triggers.YYY = backend_to_frontend.YYY;
// triggers.ZZZ = backend_to_frontend.ZZZ;

const lineTRc =
    \\
    \\        return triggers;
    \\    }
    \\};
    \\
    \\
;
