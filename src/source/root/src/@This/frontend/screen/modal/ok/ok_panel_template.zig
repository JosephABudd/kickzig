pub const content =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const _framers_ = @import("framers");
    \\const _panels_ = @import("panels.zig");
    \\const _messenger_ = @import("messenger.zig");
    \\
    \\pub const Panel = struct {
    \\    allocator: std.mem.Allocator,
    \\    all_screens: *_framers_.Group,
    \\    all_panels: *_panels_.Panels,
    \\    messenger: *_messenger_.Messenger,
    \\    heading: ?[]u8,
    \\    message: ?[]u8,
    \\
    \\    pub fn presetModal(self: *Panel, heading: []const u8, message: []const u8) !void {
    \\        // heading.
    \\        if (self.heading) |self_heading| {
    \\            self.allocator.free(self_heading);
    \\        }
    \\        self.heading = try self.allocator.alloc(u8, heading.len);
    \\        @memcpy(self.heading.?, heading);
    \\        // message.
    \\        if (self.message) |self_message| {
    \\            self.allocator.free(self_message);
    \\        }
    \\        self.message = try self.allocator.alloc(u8, message.len);
    \\        @memcpy(self.message.?, message);
    \\    }
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        if (self.heading) |heading| {
    \\            self.allocator.free(heading);
    \\        }
    \\        if (self.message) |message| {
    \\            self.allocator.free(message);
    \\        }
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    // close removes this modal screen replacing it with the previous screen.
    \\    fn close(self: *Panel) !void {
    \\        try self.all_screens.popCurrent();
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
    \\            .color_border = theme.style_accent.accent.?, //dvui.options.color(.accent),
    \\        };
    \\        var padding: *dvui.BoxWidget = try dvui.box(@src(), .vertical, padding_options);
    \\        defer padding.deinit();
    \\
    \\        {
    \\            // Row 1.
    \\            var row = try dvui.box(@src(), .horizontal, .{ .expand = .horizontal });
    \\            defer row.deinit();
    \\
    \\            if (self.heading) |heading| {
    \\                var header = try dvui.textLayout(@src(), .{}, .{ .expand = .both, .font_style = .title_4 });
    \\                try header.addText(heading, .{});
    \\                header.deinit();
    \\            }
    \\        }
    \\
    \\        {
    \\            // Row 2.
    \\            var row = try dvui.box(@src(), .horizontal, .{ .expand = .both });
    \\            defer row.deinit();
    \\
    \\            if (self.message) |message| {
    \\                var content = try dvui.textLayout(@src(), .{}, .{ .expand = .both });
    \\                try content.addText(message, .{});
    \\                content.deinit();
    \\            }
    \\        }
    \\
    \\        {
    \\            // Row 3. buttons.
    \\            var row = try dvui.box(@src(), .horizontal, .{ .expand = .horizontal });
    \\            defer row.deinit();
    \\
    \\            if (try dvui.button(@src(), "OK", .{})) {
    \\                try self.close();
    \\            }
    \\        }
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger) !*Panel {
    \\    var panel: *Panel = try allocator.create(Panel);
    \\    panel.allocator = allocator;
    \\    panel.all_screens = all_screens;
    \\    panel.all_panels = all_panels;
    \\    panel.messenger = messenger;
    \\    panel.heading = null;
    \\    panel.message = null;
    \\    return panel;
    \\}
;
