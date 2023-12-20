pub const content =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const _framers_ = @import("framers");
    \\const _panels_ = @import("panels.zig");
    \\const _messenger_ = @import("messenger.zig");
    \\const _lock_ = @import("lock");
    \\const ModalParams = @import("modal_params").YesNo;
    \\
    \\pub const Panel = struct {
    \\    allocator: std.mem.Allocator,
    \\    all_screens: *_framers_.Group,
    \\    all_panels: *_panels_.Panels,
    \\    messenger: *_messenger_.Messenger,
    \\
    \\    heading: ?[]const u8,
    \\    question: ?[]const u8,
    \\
    \\    yes_label: ?[]const u8,
    \\    no_label: ?[]const u8,
    \\
    \\    yes_no: ?bool,
    \\
    \\    implementor: *anyopaque,
    \\    yes_fn: *const fn (implementor: *anyopaque) void,
    \\    no_fn: *const fn (implementor: *anyopaque) void,
    \\
    \\    pub fn presetModal(self: *Panel, setup_args: *ModalParams) !void {
    \\        self.heading = try self.allocator.alloc(u8, setup_args.heading.?.len);
    \\        @memcpy(@constCast(self.heading), setup_args.heading.?);
    \\        self.question = try self.allocator.alloc(u8, setup_args.question.?.len);
    \\        @memcpy(@constCast(self.question), setup_args.question.?);
    \\        self.implementor = setup_args.implementor;
    \\        self.yes_label = try self.allocator.alloc(u8, setup_args.yes_label.?.len);
    \\        @memcpy(@constCast(self.yes_label), setup_args.yes_label.?);
    \\        self.no_label = try self.allocator.alloc(u8, setup_args.no_label.?.len);
    \\        @memcpy(@constCast(self.no_label), setup_args.no_label.?);
    \\        self.yes_fn = setup_args.yes_fn;
    \\        self.no_fn = setup_args.no_fn;
    \\    }
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        if (self.heading) |heading| {
    \\            self.allocator.free(heading);
    \\        }
    \\        if (self.question) |question| {
    \\            self.allocator.free(question);
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
    \\        {
    \\            // Row 1: The heading.
    \\            var heading = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal, .font_style = .title_4 });
    \\            defer heading.deinit();
    \\            try heading.addText(self.heading.?, .{});
    \\        }
    \\
    \\        {
    \\            // Row 2: This question.
    \\            var question = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal });
    \\            defer question.deinit();
    \\            try question.addText(self.question.?, .{});
    \\        }
    \\
    \\        {
    \\            // Row 3: The buttons.
    \\            var row3_layout: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
    \\            defer row3_layout.deinit();
    \\
    \\            if (try dvui.button(@src(), self.yes_label.?, .{}, .{})) {
    \\                self.yes_fn(self.implementor);
    \\                try self.close();
    \\            }
    \\
    \\            if (try dvui.button(@src(), self.no_label.?, .{}, .{})) {
    \\                self.no_fn(self.implementor);
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
    \\    panel.question = null;
    \\    panel.yes_no = null;
    \\    return panel;
    \\}
;
