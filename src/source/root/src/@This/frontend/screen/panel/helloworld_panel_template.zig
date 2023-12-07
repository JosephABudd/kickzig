pub const content =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\const _framers_ = @import("framers");
    \\const _panels_ = @import("panels.zig");
    \\const _messenger_ = @import("messenger.zig");
    \\const _lock_ = @import("lock");
    \\const ModalParams = @import("modal_params").OK;
    \\
    \\pub const Panel = struct {
    \\    allocator: std.mem.Allocator, // For persistant state data.
    \\    all_screens: *_framers_.Group,
    \\    all_panels: *_panels_.Panels,
    \\    messenger: *_messenger_.Messenger,
    \\    example_message_from_messenger: ?[]const u8,
    \\    title: []const u8,
    \\    message: []const u8,
    \\    n: u8,
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    // frame this panel for rendering.
    \\    // The arena allocator is for building this frame. Not for state.
    \\    pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {
    \\        _ = arena;
    \\
    \\        var scroll = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
    \\        defer scroll.deinit();
    \\
    \\        // Example 1: A title displaying the panel name.
    \\        var example_title = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal, .font_style = .title_4 });
    \\        try example_title.addText("Hello...", .{});
    \\        example_title.deinit();
    \\
    \\        // Example 2: A pretend message from the messenger.
    \\        var example_message = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal });
    \\        if (self.example_message_from_messenger) |message| {
    \\            try example_message.addText(message, .{});
    \\        } else {
    \\            try example_message.addText(self.message, .{});
    \\        }
    \\        example_message.deinit();
    \\
    \\        // Example 3: A button which opens the OK modal screen.
    \\        if (try dvui.button(@src(), "OK Modal Screen.", .{}, .{})) {
    \\            var ok_modal = try self.all_screens.get("OK");
    \\            var ok_args = try ModalParams.init(self.allocator, "Hello World!", "This is the OK modal popped from the HelloWorld screen.");
    \\            defer ok_args.deinit();
    \\            var result = ok_modal.goModalFn.?(ok_modal.implementor, ok_args);
    \\            if (result != error.Null) {
    \\                return result;
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
    \\    panel.example_message_from_messenger = null;
    \\    panel.title = "This is the \"HelloWorld\" screen's \"HelloWorld\" Panel.";
    \\    panel.message = "World!";
    \\    panel.n = 77;
    \\    return panel;
    \\}
;
