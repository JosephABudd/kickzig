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
        var line: []const u8 = undefined;

        // Imports.
        line = try self.contentImports();
        try lines.appendSlice(line);
        // Front to back struct.
        line = try self.contentFrontToBackStruct();
        try lines.appendSlice(line);
        // Back to front struct.
        line = try self.contentBackToFrontStruct();
        try lines.appendSlice(line);
        // Trigger struct.
        line = try self.contentTriggerStruct();
        try lines.appendSlice(line);

        return try lines.toOwnedSlice();
    }

    fn contentImports(self: *Template) ![]const u8 {
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();

        const line1 =
            \\// This file is re-generated by kickzig when a message is added or removed.
            \\// DO NOT EDIT THIS FILE.
            \\const std = @import("std");
            \\
            \\const BackToFrontDispatcher = @import("backtofront/general_dispatcher.zig").GeneralDispatcher;
            \\const FrontToBackDispatcher = @import("fronttoback/general_dispatcher.zig").GeneralDispatcher;
            \\const ExitFn = @import("various").ExitFn;
            \\
            \\
        ;

        const line_bf_import =
            \\const BF_{0s} = @import("backtofront/{0s}.zig").Group;
            \\
        ;

        const line_fb_import =
            \\const FB_{0s} = @import("fronttoback/{0s}.zig").Group;
            \\
        ;

        const line_trigger_import =
            \\const TR_{0s} = @import("trigger/{0s}.zig").Group;
            \\
        ;

        const frontend_to_backend_channel_names: [][]const u8 = self.frontend_to_backend_channel_names[0..self.frontend_to_backend_channel_names_index];
        const backend_to_frontend_channel_names: [][]const u8 = self.backend_to_frontend_channel_names[0..self.backend_to_frontend_channel_names_index];
        const backend_trigger_names: [][]const u8 = self.backend_trigger_names[0..self.backend_trigger_names_index];

        // Imports.
        try lines.appendSlice(line1);
        // backtofront/ imports.
        for (backend_to_frontend_channel_names) |name| {
            const line: []const u8 = try fmt.allocPrint(self.allocator, line_bf_import, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        {
            // fronttoback/ imports.
            for (frontend_to_backend_channel_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, line_fb_import, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        {
            // trigger/ imports.
            for (backend_trigger_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, line_trigger_import, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }

        return lines.toOwnedSlice();
    }

    fn contentFrontToBackStruct(self: *Template) ![]const u8 {
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();

        const line_fb_struct_start =
            \\
            \\/// FrontendToBackend is each message's channel.
            \\pub const FrontendToBackend = struct {
            \\    allocator: std.mem.Allocator,
            \\    // Dispatcher.
            \\    general_dispatcher: *FrontToBackDispatcher,
            \\
            \\    // Channels.
            \\
        ;

        const line_fb_member_declare =
            \\    {0s}: *FB_{0s},
            \\
        ;

        const line_deinit =
            \\
            \\    pub fn deinit(self: *FrontendToBackend) void {
            \\        self.general_dispatcher.deinit();
            \\        self.allocator.destroy(self);
            \\    }
            \\
        ;

        const line_init_start =
            \\
            \\    pub fn init(allocator: std.mem.Allocator, exit: ExitFn) !*FrontendToBackend {
            \\        var self: *FrontendToBackend = try allocator.create(FrontendToBackend);
            \\        self.allocator = allocator;
            \\        self.general_dispatcher = try FrontToBackDispatcher.init(allocator, exit);
            \\
        ;

        const line_set_channel =
            \\        self.{0s} = self.general_dispatcher.{0s}.?;
            \\
        ;

        const line_fb_deinit_end_init_end =
            \\
            \\        return self;
            \\    }
            \\};
            \\
            \\
        ;

        const frontend_to_backend_channel_names: [][]const u8 = self.frontend_to_backend_channel_names[0..self.frontend_to_backend_channel_names_index];

        // FrontToBack struct.
        try lines.appendSlice(line_fb_struct_start);
        {
            // frontend declarations.
            for (frontend_to_backend_channel_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, line_fb_member_declare, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        try lines.appendSlice(line_deinit);

        try lines.appendSlice(line_init_start);
        // frontend inits.
        for (frontend_to_backend_channel_names) |name| {
            {
                const line: []const u8 = try fmt.allocPrint(self.allocator, line_set_channel, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        try lines.appendSlice(line_fb_deinit_end_init_end);

        return lines.toOwnedSlice();
    }

    fn contentBackToFrontStruct(self: *Template) ![]const u8 {
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();

        const lineBFa =
            \\
            \\/// BackendToFrontend is each message's channel.
            \\pub const BackendToFrontend = struct {
            \\    allocator: std.mem.Allocator,
            \\    // Dispatcher.
            \\    general_dispatcher: *BackToFrontDispatcher,
            \\    // Channels.
            \\
        ;

        const line_bf_member_declare =
            \\    {0s}: *BF_{0s},
            \\
        ;

        const line_deinit =
            \\
            \\    pub fn deinit(self: *BackendToFrontend) void {
            \\        self.general_dispatcher.deinit();
            \\        self.allocator.destroy(self);
            \\    }
            \\
        ;

        const line_init_start =
            \\
            \\    pub fn init(allocator: std.mem.Allocator, exit: ExitFn) !*BackendToFrontend {
            \\        var self: *BackendToFrontend = try allocator.create(BackendToFrontend);
            \\        self.allocator = allocator;
            \\        // Dispatcher.
            \\        self.general_dispatcher = try BackToFrontDispatcher.init(allocator, exit);
            \\        // Channels.
            \\
        ;

        const line_set_channel =
            \\        self.{0s} = self.general_dispatcher.{0s}.?;
            \\
        ;

        const line_init_end =
            \\
            \\        return self;
            \\    }
            \\};
            \\
        ;

        const backend_to_frontend_channel_names: [][]const u8 = self.backend_to_frontend_channel_names[0..self.backend_to_frontend_channel_names_index];

        // BackToFront struct.
        try lines.appendSlice(lineBFa);
        {
            // BackToFront member declarations.
            for (backend_to_frontend_channel_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, line_bf_member_declare, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }

        try lines.appendSlice(line_deinit);
        try lines.appendSlice(line_init_start);
        for (backend_to_frontend_channel_names) |name| {
            const line: []const u8 = try fmt.allocPrint(self.allocator, line_set_channel, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line_init_end);

        return lines.toOwnedSlice();
    }

    fn contentTriggerStruct(self: *Template) ![]const u8 {
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();

        const line_trigger_struct_start =
            \\
            \\/// Trigger is each trigger.
            \\pub const Trigger = struct {
            \\    allocator: std.mem.Allocator,
            \\
        ;

        const line_trigger_member =
            \\    {0s}: ?*TR_{0s} = null,
            \\
        ;

        const line_trigger_deinit_start =
            \\
            \\    pub fn deinit(self: *Trigger) void {
            \\
        ;

        const line_trigger_member_deinit =
            \\        if (self.{0s}) |{0s}| {{
            \\            {0s}.deinit();
            \\        }}
            \\
        ;

        const line_trigger_deinit_end =
            \\        self.allocator.destroy(self);
            \\    }
            \\
        ;

        const line_trigger_init_start =
            \\    pub fn init(allocator: std.mem.Allocator, exit: ExitFn) !*Trigger {
            \\        var self: *Trigger = try allocator.create(Trigger);
            \\        self.allocator = allocator;
            \\    
            \\
        ;

        const line_equals_exit =
            \\        _ = exit;
            \\
        ;

        const line_trigger_init_member =
            \\        self.{0s} = try TR_{0s}.init(self.allocator, exit);
            \\        errdefer self.deinit();
            \\
        ;

        const line_trigger_init_end =
            \\
            \\        return self;
            \\    }
            \\};
            \\
            \\
        ;

        const backend_trigger_names: [][]const u8 = self.backend_trigger_names[0..self.backend_trigger_names_index];

        // Trigger struct.
        try lines.appendSlice(line_trigger_struct_start);
        // Trigger declare members.
        for (backend_trigger_names) |name| {
            const line: []const u8 = try fmt.allocPrint(self.allocator, line_trigger_member, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }

        // fn deinit.
        try lines.appendSlice(line_trigger_deinit_start);
        for (backend_trigger_names) |name| {
            const line: []const u8 = try fmt.allocPrint(self.allocator, line_trigger_member_deinit, .{name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        try lines.appendSlice(line_trigger_deinit_end);

        // fn init.
        try lines.appendSlice(line_trigger_init_start);
        if (backend_trigger_names.len == 0) {
            try lines.appendSlice(line_equals_exit);
        } else {
            // trigger inits.
            for (backend_trigger_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, line_trigger_init_member, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        try lines.appendSlice(line_trigger_init_end);

        return lines.toOwnedSlice();
    }
};
