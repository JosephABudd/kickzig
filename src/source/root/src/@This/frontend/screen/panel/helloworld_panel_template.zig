pub const content =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const _framers_ = @import("framers");
    \\const _panels_ = @import("panels.zig");
    \\const _messenger_ = @import("messenger.zig");
    \\const _lock_ = @import("lock");
    \\const _modal_params_ = @import("modal_params");
    \\const OKModalParams = _modal_params_.OK;
    \\const YesNoModalParams = _modal_params_.YesNo;
    \\
    \\pub const Panel = struct {
    \\    allocator: std.mem.Allocator, // For persistant state data.
    \\    all_screens: *_framers_.Group,
    \\    all_panels: *_panels_.Panels,
    \\    messenger: *_messenger_.Messenger,
    \\    example_message_from_messenger: ?[]const u8,
    \\    title: []const u8,
    \\    message: []const u8,
    \\    yes_no: ?bool,
    \\    exit: *const fn (user_message: []const u8) void,
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    fn modalNoCB(implementor: *anyopaque) void {
    \\        var self: *Panel = @alignCast(@ptrCast(implementor));
    \\        self.yes_no = false;
    \\    }
    \\
    \\    fn modalYesCB(implementor: *anyopaque) void {
    \\        var self: *Panel = @alignCast(@ptrCast(implementor));
    \\        self.yes_no = true;
    \\    }
    \\
    \\    // frame this panel for rendering.
    \\    // The arena allocator is for building this frame. Not for state.
    \\    pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {
    \\        _ = arena;
    \\
    \\        var scroller = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
    \\        defer scroller.deinit();
    \\
    \\        var layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{});
    \\        defer layout.deinit();
    \\
    \\        // Row 1:.
    \\        var example_title = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal, .font_style = .title_4 });
    \\        try example_title.addText("Hello...", .{});
    \\        example_title.deinit();
    \\
    \\        // Row 2:.
    \\        var example_message = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal });
    \\        if (self.example_message_from_messenger) |message| {
    \\            try example_message.addText(message, .{});
    \\        } else {
    \\            try example_message.addText(self.message, .{});
    \\        }
    \\        example_message.deinit();
    \\
    \\        // Row 3: A button which opens the OK modal screen.
    \\        if (try dvui.button(@src(), "OK Modal Screen.", .{}, .{})) {
    \\            var ok_modal = try self.all_screens.get("OK");
    \\            var ok_args = try OKModalParams.init(self.allocator, "Hello World!", "This is the OK modal popped from the HelloWorld screen.");
    \\            defer ok_args.deinit();
    \\            if(ok_modal.goModalFn.?(ok_modal.implementor, ok_args)) |err| {
    \\                return err;
    \\            }
    \\        }
    \\
    \\        // Row 4: A button which opens the YesNo modal screen.
    \\        if (try dvui.button(@src(), "YesNo Modal Screen.", .{}, .{})) {
    \\            var yesno_modal = try self.all_screens.get("YesNo");
    \\            var heading: []const u8 = undefined;
    \\            var yes_label: []const u8 = "Yes.";
    \\            var no_label: []const u8 = "No.";
    \\            if (self.yes_no) |yes_no| {
    \\                if (yes_no) {
    \\                    heading = "You clicked Yes last time.";
    \\                } else {
    \\                    heading = "You cliced No last time.";
    \\                }
    \\            } else {
    \\                heading = "You haven't clicked any buttons yet so click one!";
    \\            }
    \\            const yesno_args = try YesNoModalParams.init(
    \\                self.allocator,
    \\                heading,
    \\                "Click any button.",
    \\                yes_label,
    \\                no_label,
    \\                self,
    \\                Panel.modalYesCB,
    \\                Panel.modalNoCB,
    \\            );
    \\            defer yesno_args.deinit();
    \\            if(yesno_modal.goModalFn.?(yesno_modal.implementor, yesno_args)) |err| {
    \\                return err;
    \\            }
    \\        }
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: *const fn (user_message: []const u8) void) !*Panel {
    \\    var panel: *Panel = try allocator.create(Panel);
    \\    panel.allocator = allocator;
    \\    panel.all_screens = all_screens;
    \\    panel.all_panels = all_panels;
    \\    panel.messenger = messenger;
    \\    panel.example_message_from_messenger = null;
    \\    panel.title = "This is the \"HelloWorld\" screen's \"HelloWorld\" Panel.";
    \\    panel.message = "World!";
    \\    panel.yes_no = null;
    \\    panel.exit = exit;
    \\    return panel;
    \\}
    \\
;
