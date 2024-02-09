pub const content =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const _framers_ = @import("framers");
    \\const _panels_ = @import("panels.zig");
    \\const _messenger_ = @import("messenger.zig");
    \\const _lock_ = @import("lock");
    \\const ModalParams = @import("modal_params").EOJ;
    \\const _closedownjobs_ = @import("closedownjobs");
    \\const _closer_ = @import("closer");
    \\
    \\pub const Panel = struct {
    \\    allocator: std.mem.Allocator,
    \\    window: *dvui.Window,
    \\    all_screens: *_framers_.Group,
    \\    all_panels: *_panels_.Panels,
    \\    messenger: *_messenger_.Messenger,
    \\    lock: *_lock_.ThreadLock,
    \\    heading: ?[]u8,
    \\    message: ?[]u8,
    \\    status: [255]u8,
    \\    status_len: usize,
    \\    is_fatal: bool,
    \\    completed: bool,
    \\    progress: f32,
    \\    exit: *const fn (user_message: []const u8) void,
    \\
    \\    pub fn presetModal(self: *Panel, setup_args: *ModalParams) !void {
    \\        // heading.
    \\        if (setup_args.heading) |heading| {
    \\            if (self.heading) |self_heading| {
    \\                self.allocator.free(self_heading);
    \\            }
    \\            self.heading = try self.allocator.alloc(u8, heading.len);
    \\            @memcpy(self.heading.?, heading);
    \\        } else {
    \\            self.heading = null;
    \\        }
    \\
    \\        // message.
    \\        if (setup_args.message) |message| {
    \\            if (self.message) |self_message| {
    \\                self.allocator.free(self_message);
    \\            }
    \\            self.message = try self.allocator.alloc(u8, message.len);
    \\            @memcpy(self.message.?, message);
    \\        } else {
    \\            self.message = null;
    \\        }
    \\        self.is_fatal = setup_args.is_fatal;
    \\
    \\        // Send the jobs to the back-end to process.
    \\        var jobs: ?[]const *_closedownjobs_.Job = try setup_args.exit_jobs.slice();
    \\        self.messenger.sendCloseDownJobs(jobs);
    \\    }
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        if (self.heading) |heading| {
    \\            self.allocator.free(heading);
    \\        }
    \\        if (self.message) |message| {
    \\            self.allocator.free(message);
    \\        }
    \\        self.lock.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    // close removes this modal screen replacing it with the previous screen.
    \\    fn close(self: *Panel) !void {
    \\        try self.all_screens.popCurrent();
    \\    }
    \\
    \\    pub fn update(self: *Panel, status: ?[]const u8, completed: bool, progress: f32) void {
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        if (status) |text| {
    \\            self.status_len = @min(text.len, self.status.len);
    \\            for (0..self.status_len) |i| {
    \\                self.status[i] = text[i];
    \\            }
    \\        } else {
    \\            self.status_len = 0;
    \\        }
    \\        self.completed = completed;
    \\        self.progress = progress;
    \\    }
    \\
    \\    // frame is a simple screen rendering one panel at a time.
    \\    pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {
    \\        _ = arena;
    \\        var theme: *dvui.Theme = dvui.themeGet();
    \\
    \\        var padding_options = .{
    \\            .expand = .both,
    \\            .margin = dvui.Rect.all(0),
    \\            .border = dvui.Rect.all(10),
    \\            .padding = dvui.Rect.all(10),
    \\            .corner_radius = dvui.Rect.all(5),
    \\            .color_border = theme.style_accent.color_accent.?, //dvui.options.color(.accent),
    \\        };
    \\        var padding: *dvui.BoxWidget = try dvui.box(@src(), .vertical, padding_options);
    \\        defer padding.deinit();
    \\
    \\        var scroller = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
    \\        defer scroller.deinit();
    \\
    \\        var layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{});
    \\        defer layout.deinit();
    \\
    \\        // Row 1. Heading.
    \\        if (self.heading) |heading| {
    \\            var header = try dvui.textLayout(@src(), .{}, .{ .expand = .both, .font_style = .title_4 });
    \\            try header.addText(heading, .{});
    \\            header.deinit();
    \\        }
    \\
    \\        // Row 2. Message.
    \\        if (self.is_fatal) {
    \\            if (self.message) |message| {
    \\                var content = try dvui.textLayout(@src(), .{}, .{ .expand = .both });
    \\                try content.addText(message, .{});
    \\                content.deinit();
    \\            }
    \\        }
    \\
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        if (self.is_fatal) {
    \\            // Row 3. Status.
    \\            if (self.status_len > 0) {
    \\                var content = try dvui.textLayout(@src(), .{}, .{ .expand = .both });
    \\                try content.addText(self.status[0..self.status_len], .{});
    \\                content.deinit();
    \\            }
    \\        }
    \\
    \\        // Row 3b Progress.
    \\        try dvui.progress(@src(), .{ .percent = self.progress }, .{ .expand = .horizontal, .gravity_y = 0.5, .corner_radius = dvui.Rect.all(100) });
    \\        if (self.completed) {
    \\            const bg_thread = try std.Thread.spawn(.{}, background_progress, .{self});
    \\            bg_thread.detach();
    \\        }
    \\
    \\        if (self.is_fatal) {
    \\            // Row 4. Buttons.
    \\            if (self.completed and self.progress >= 1.0) {
    \\                if (try dvui.button(@src(), "CloseDownJobs", .{}, .{})) {
    \\                    _closer_.eoj();
    \\                }
    \\            }
    \\        } else {
    \\            if (self.progress >= 1.0) {
    \\                // Done closing normally so just close the window.
    \\                _closer_.eoj();
    \\            }
    \\        }
    \\    }
    \\
    \\    // background_progress was shamelessly copied from src/vendor/dvui/src/Examples.zig
    \\    fn background_progress(implementor: *anyopaque) !void {
    \\        var self: *Panel = @alignCast(@ptrCast(implementor));
    \\
    \\        const delay_ns: u64 = 2_000_000_000;
    \\        const interval: u64 = 10_000_000;
    \\        const total_sleep_f32: f32 = @as(f32, @floatFromInt(delay_ns)) * self.progress;
    \\        var total_sleep: u64 = @intFromFloat(total_sleep_f32);
    \\        while (total_sleep < delay_ns) : (total_sleep += interval) {
    \\            std.time.sleep(interval);
    \\            self.lock.lock();
    \\            self.progress = @as(f32, @floatFromInt(total_sleep)) / @as(f32, @floatFromInt(delay_ns));
    \\            self.lock.unlock();
    \\            dvui.refresh(self.window, @src(), null);
    \\            if (self.progress >= 1.0) {
    \\                return;
    \\            }
    \\        }
    \\        self.lock.lock();
    \\        self.progress = 1.0;
    \\        self.lock.unlock();
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: *const fn (user_message: []const u8) void, window: *dvui.Window) !*Panel {
    \\    var panel: *Panel = try allocator.create(Panel);
    \\    panel.lock = try _lock_.init(allocator);
    \\    errdefer allocator.destroy(panel);
    \\    panel.allocator = allocator;
    \\    panel.window = window;
    \\    panel.all_screens = all_screens;
    \\    panel.all_panels = all_panels;
    \\    panel.messenger = messenger;
    \\    panel.heading = null;
    \\    panel.message = null;
    \\    panel.exit = exit;
    \\    panel.status_len = 0;
    \\    panel.completed = false;
    \\    panel.progress = 0.0;
    \\    return panel;
    \\}
;
