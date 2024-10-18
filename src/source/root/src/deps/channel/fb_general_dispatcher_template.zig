const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    channel_names: [][]const u8,
    channel_names_index: usize,

    pub fn init(allocator: std.mem.Allocator) !*Template {
        var data: *Template = try allocator.create(Template);
        data.channel_names = try allocator.alloc([]const u8, 5);
        errdefer {
            allocator.destroy(data);
        }
        data.channel_names_index = 0;
        data.allocator = allocator;
        return data;
    }

    pub fn deinit(self: *Template) void {
        // channel_names
        for (self.channel_names, 0..) |name, i| {
            if (self.channel_names_index == i) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self.channel_names);
        self.allocator.destroy(self);
    }

    pub fn addFrontToBackChannelName(self: *Template, new_name: []const u8) !void {
        // This is a front to back channel.
        try self.addChannelName(new_name);
    }

    fn addChannelName(self: *Template, new_name: []const u8) !void {
        if (self.channel_names_index == self.channel_names.len) {
            // Full list so create a new bigger one.
            var new_channel_names: [][]const u8 = try self.allocator.alloc([]const u8, (self.channel_names.len + 5));
            for (self.channel_names, 0..) |name, i| {
                new_channel_names[i] = name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self.channel_names);
            self.channel_names = new_channel_names;
        }
        const name: []const u8 = try self.allocator.alloc(u8, new_name.len);
        @memcpy(@constCast(name), new_name);
        self.channel_names[self.channel_names_index] = name;
        self.channel_names_index += 1;
    }

    pub fn content(self: *Template) ![]const u8 {
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();

        const channel_names: [][]const u8 = self.channel_names[0..self.channel_names_index];

        // Imports.
        try lines.appendSlice(line_import);
        {
            // backtofront/ imports.
            for (channel_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, line_import_channel, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        try lines.appendSlice(line_start_dispatcher_struct);
        {
            // channel members.
            for (channel_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, line_dispatcher_struct_member, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        if (self.channel_names_index > 0) {
            try lines.appendSlice(line_dispatcher_struct_init_start);
        } else {
            try lines.appendSlice(line_dispatcher_struct_init_start_suppressed);
        }
        {
            // struct channels init to null.
            for (channel_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, line_fb_channel_init, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        try lines.appendSlice(line_dispatcher_struct_init_end);
        try lines.appendSlice(line_dispatcher_struct_deinit_start);
        {
            // struct channels deinit.
            for (channel_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, line_dispatcher_struct_deinit_channel, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        try lines.appendSlice(line_dispatcher_struct_deinit_end);
        try lines.appendSlice(line_dispatcher_struct_dispatch_thru_run_start);
        {
            // imports.
            for (channel_names) |name| {
                const line: []const u8 = try fmt.allocPrint(self.allocator, line_dispatcher_struct_run_channel, .{name});
                defer self.allocator.free(line);
                try lines.appendSlice(line);
            }
        }
        try lines.appendSlice(line_end);
        const owned_slice = try lines.toOwnedSlice();
        const slice = try self.allocator.alloc(u8, owned_slice.len);
        @memcpy(slice, owned_slice);
        return slice;
    }
};

const line_import: []const u8 =
    \\/// GeneralDispatcher:
    \\/// This file is re-generated by kickzig each time you add or remove a back-to-front or trigger message.
    \\/// Do not edit this file.
    \\const std = @import("std");
    \\
    \\const ExitFn = @import("closer").ExitFn;
    \\
;

const line_import_channel: []const u8 =
    \\const {0s} = @import("{0s}.zig").Group;
    \\
;

const line_start_dispatcher_struct: []const u8 =
    \\
    \\pub const GeneralDispatcher = struct {
    \\    allocator: std.mem.Allocator = undefined,
    \\    condition: std.Thread.Condition,
    \\    running: bool,
    \\    running_mutex: std.Thread.Mutex,
    \\    loop_mutex: std.Thread.Mutex,
    \\    // Custom channels.
    \\
;

const line_dispatcher_struct_member: []const u8 =
    \\    {0s}: ?*{0s} = null,
    \\
;

const line_dispatcher_struct_init_start: []const u8 =
    \\
    \\    pub fn init(allocator: std.mem.Allocator, exit: ExitFn) !*GeneralDispatcher {
    \\        var self: *GeneralDispatcher = try allocator.create(GeneralDispatcher);
    \\        self.allocator = allocator;
    \\
    \\        self.loop_mutex = std.Thread.Mutex{};
    \\        self.running_mutex = std.Thread.Mutex{};
    \\        self.condition = std.Thread.Condition{};
    \\
    \\
;

const line_dispatcher_struct_init_start_suppressed: []const u8 =
    \\
    \\    pub fn init(allocator: std.mem.Allocator, _: ExitFn) !*GeneralDispatcher {
    \\        var self: *GeneralDispatcher = try allocator.create(GeneralDispatcher);
    \\        self.allocator = allocator;
    \\
    \\        self.loop_mutex = std.Thread.Mutex{};
    \\        self.running_mutex = std.Thread.Mutex{};
    \\        self.condition = std.Thread.Condition{};
    \\
    \\
;

const line_fb_channel_init: []const u8 =
    \\        self.{0s} = try {0s}.init(allocator, self, exit);
    \\        errdefer self.deinit();
    \\
    \\
;

const line_dispatcher_struct_init_end: []const u8 =
    \\
    \\        // Initialize the running.
    \\        self.running = true;
    \\        self.condition.signal();
    \\        const thread = try std.Thread.spawn(.{ .allocator = self.allocator }, GeneralDispatcher.run, .{self});
    \\        std.Thread.detach(thread);
    \\        return self;
    \\    }
    \\
    \\
;

const line_dispatcher_struct_deinit_start: []const u8 =
    \\    pub fn deinit(self: *GeneralDispatcher) void {
    \\        self.stop();
    \\
;

const line_dispatcher_struct_deinit_channel: []const u8 =
    \\        if (self.{0s}) |member| {{
    \\            member.deinit();
    \\        }}
    \\
;

const line_dispatcher_struct_deinit_end: []const u8 =
    \\        self.allocator.destroy(self);
    \\    }
    \\
;

const line_dispatcher_struct_dispatch_thru_run_start: []const u8 =
    \\
    \\    pub fn dispatch(self: *GeneralDispatcher) void {
    \\        self.condition.signal();
    \\    }
    \\
    \\    fn getRunning(self: *GeneralDispatcher) bool {
    \\        self.running_mutex.lock();
    \\        defer self.running_mutex.unlock();
    \\
    \\        return self.running;
    \\    }
    \\
    \\    fn stop(self: *GeneralDispatcher) void {
    \\        self.running_mutex.lock();
    \\        defer self.running_mutex.unlock();
    \\
    \\        if (self.running) {
    \\            self.running = false;
    \\            self.condition.signal();
    \\        }
    \\    }
    \\
    \\    fn run(self: *GeneralDispatcher) void {
    \\        self.loop_mutex.lock();
    \\        defer self.loop_mutex.unlock();
    \\
    \\        while (self.getRunning()) {
    \\            // Still running so wait for the next condition.
    \\            self.condition.wait(&self.loop_mutex);
    \\            if (self.getRunning()) {
    \\                // Have each channel dispatch its own messages.
    \\
;

const line_dispatcher_struct_run_channel: []const u8 =
    \\                self.{0s}.?.dispatch() catch {{
    \\                    // The channel or message receiver handled the errror.
    \\                    return;
    \\                }};
    \\
;

const line_end: []const u8 =
    \\            }
    \\        }
    \\    }
    \\};
    \\
;
