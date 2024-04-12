pub const content =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const _lock_ = @import("lock");
    \\const _messenger_ = @import("messenger.zig");
    \\const _modal_params_ = @import("modal_params");
    \\const _panels_ = @import("panels.zig");
    \\const _various_ = @import("various");
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\const OKModalParams = _modal_params_.OK;
    \\const YesNoModalParams = _modal_params_.YesNo;
    \\
    \\// KICKZIG TODO:
    \\// Remember. Defers happen in reverse order.
    \\// When updating panel state.
    \\//     self.lock();
    \\//     defer self.unlock(); //  2nd defer: Unlocks.
    \\//     defer self.refresh(); // 1st defer: Refreshes the main view.
    \\//     // DO THE UPDATES.
    \\
    \\pub const Panel = struct {
    \\    allocator: std.mem.Allocator, // For persistant state data.
    \\    lock: *_lock_.ThreadLock, // For persistant state data.
    \\    window: *dvui.Window,
    \\    main_view: *MainView,
    \\    container: ?*_various_.Container,
    \\    all_panels: *_panels_.Panels,
    \\    messenger: *_messenger_.Messenger,
    \\    example_message_from_messenger: ?[]const u8,
    \\    title: []const u8,
    \\    message: []const u8,
    \\    yes_no: ?bool,
    \\    exit: ExitFn,
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        self.lock.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// refresh only if this panel and ( container or screen ) are showing.
    \\    pub fn refresh(self: *Panel) void {
    \\        if (self.all_panels.current_panel_tag == .HelloWorld) {
    \\            // This is the current panel.
    \\            if (self.container) |container| {
    \\                // Refresh the container.
    \\                // The container will refresh only if it's the currently viewed screen.
    \\                container.refresh();
    \\            } else {
    \\                // Main view will refresh only if this is the currently viewed screen.
    \\                self.main_view.refreshHelloWorld();
    \\            }
    \\        }
    \\    }
    \\
    \\    pub fn setContainer(self: *Panel, container: *_various_.Container) void {
    \\        self.container = container;
    \\    }
    \\
    \\    fn modalNoCB(implementor: *anyopaque) void {
    \\        var self: *Panel = @alignCast(@ptrCast(implementor));
    \\        self.lock.lock();
    \\        self.yes_no = false;
    \\        self.lock.unlock();
    \\    }
    \\
    \\    fn modalYesCB(implementor: *anyopaque) void {
    \\        var self: *Panel = @alignCast(@ptrCast(implementor));
    \\        self.lock.lock();
    \\        self.yes_no = true;
    \\        self.lock.unlock();
    \\    }
    \\
    \\    /// frame this panel.
    \\    /// Layout, Draw, Handle user events.
    \\    // The arena allocator is for building this frame. Not for state.
    \\    pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {
    \\        _ = arena;
    \\
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        var scroller = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
    \\        defer scroller.deinit();
    \\
    \\        var layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{});
    \\        defer layout.deinit();
    \\
    \\        // Row 1 example: The screen's name.
    \\        try dvui.labelNoFmt(@src(), "HelloWorld Screen.", .{ .font_style = .title });
    \\
    \\        // Row 2 example: This panel's name.
    \\        {
    \\            var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
    \\            defer row.deinit();
    \\
    \\            try dvui.labelNoFmt(@src(), "Panel Name: ", .{ .font_style = .heading });
    \\            try dvui.labelNoFmt(@src(), "HelloWorld", .{});
    \\        }
    \\
    \\        // Row 3 example text:
    \\        try dvui.labelNoFmt(@src(), "HelloWorld", .{});
    \\
    \\        // Row 4: A button which opens the OK modal screen.
    \\        if (try dvui.button(@src(), "OK Modal Screen.", .{}, .{})) {
    \\            var ok_args = try OKModalParams.init(self.allocator, "Hello World!", "This is the OK modal popped from the HelloWorld screen.");
    \\            self.main_view.showOK(ok_args);
    \\        }
    \\
    \\        // Row 5: A button which opens the YesNo modal screen.
    \\        if (try dvui.button(@src(), "YesNo Modal Screen.", .{}, .{})) {
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
    \\            self.main_view.showYesNo(yesno_args);
    \\        }
    \\
    \\        // Row 6 example: A button which closes the container.
    \\        if (self.container) |container| {
    \\            // This screen is framing inside a container.
    \\            // Allow the user to close the container.
    \\            if (try dvui.button(@src(), "Close Container.", .{}, .{})) {
    \\                container.close();
    \\            }
    \\        }
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, main_view: *MainView, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panel {
    \\    var panel: *Panel = try allocator.create(Panel);
    \\    panel.lock = try _lock_.init(allocator);
    \\    errdefer {
    \\        allocator.destroy(panel);
    \\    }
    \\    panel.allocator = allocator;
    \\    panel.main_view = main_view;
    \\    panel.all_panels = all_panels;
    \\    panel.messenger = messenger;
    \\    panel.example_message_from_messenger = null;
    \\    panel.title = "This is the \"HelloWorld\" screen's \"HelloWorld\" Panel.";
    \\    panel.message = "World!";
    \\    panel.yes_no = null;
    \\    panel.exit = exit;
    \\    panel.window = window;
    \\    panel.container = null;
    \\    return panel;
    \\}
;
