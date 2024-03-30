pub const content =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const Direction = dvui.enums.Direction;
    \\const Event = dvui.Event;
    \\const Options = dvui.Options;
    \\const Point = dvui.Point;
    \\const Rect = dvui.Rect;
    \\const RectScale = dvui.RectScale;
    \\const Size = dvui.Size;
    \\const Widget = dvui.Widget;
    \\const WidgetData = dvui.WidgetData;
    \\const BoxWidget = dvui.BoxWidget;
    \\
    \\pub const TabBarWidget = @This();
    \\const background_color: dvui.Options.ColorsFromTheme = .fill_control;
    \\
    \\pub var horizontalDefaults: Options = .{
    \\    .name = "HorizontalTabBar",
    \\    .background = true,
    \\    .color_fill = .{ .name = background_color },
    \\    .expand = .horizontal,
    \\};
    \\pub var verticalDefaults: Options = .{
    \\    .name = "VerticalTabBar",
    \\    .background = true,
    \\    .color_fill = .{ .name = background_color },
    \\    .expand = .vertical,
    \\};
    \\
    \\pub const InitOptions = struct {
    \\    dir: Direction = undefined,
    \\    submenus_activated_by_default: bool = false,
    \\};
    \\
    \\wd: WidgetData = undefined,
    \\dir: Direction = undefined,
    \\winId: u32 = undefined,
    \\box: BoxWidget = undefined,
    \\
    \\// whether submenus in a child menu should default to open (for mouse interactions, not for keyboard)
    \\// submenus_in_child: bool = false,
    \\mouse_over: bool = false,
    \\
    \\// The contentArea is where the selected tab's content is displayed.
    \\// The contentArea lies right of the verticalTabBarColumn.
    \\// The contentArea lies below the horizontalTabBarRow.
    \\// The caller owns the returned value.
    \\pub fn contentArea(src: std.builtin.SourceLocation) !*dvui.BoxWidget {
    \\    return try dvui.box(src, .vertical, .{ .expand = .both, .background = true });
    \\}
    \\
    \\// Tab bar row and column.
    \\
    \\// A horizontalTabBarRow contains is the horizontal tab-bar.
    \\// The horizontalTabBarRow lies above the tab-content area.
    \\// The caller owns the returned value.
    \\pub fn horizontalTabBarRow(src: std.builtin.SourceLocation) !*dvui.BoxWidget {
    \\    return dvui.box(src, .horizontal, .{ .expand = .horizontal, .background = false });
    \\}
    \\
    \\// A verticalTabBarColumn contains is the vertical tab-bar.
    \\// The verticalTabBarColumn lies left of the tab-content area.
    \\// The caller owns the returned value.
    \\pub fn verticalTabBarColumn(src: std.builtin.SourceLocation) !*dvui.BoxWidget {
    \\    return dvui.box(src, .vertical, .{ .expand = .vertical, .background = false });
    \\}
    \\
    \\// Tab scrollers.
    \\
    \\// The horizontal scroller scrolls tabs sideways.
    \\// The caller owns the returned value.
    \\// It lies inside the horizontalTabBarRow.
    \\pub fn horizontalTabScroller(src: std.builtin.SourceLocation) !*dvui.ScrollAreaWidget {
    \\    return try dvui.scrollArea(
    \\        src,
    \\        .{
    \\            .horizontal = .auto,
    \\            .vertical = .none,
    \\            .horizontal_bar = .hide,
    \\        },
    \\        .{ .expand = .horizontal, .color_fill = .{ .name = .fill_window } },
    \\    );
    \\}
    \\
    \\// The vertical scroller scrolls tabs up and down.
    \\// It lies inside the verticalTabBarColumn.
    \\// The caller owns the returned value.
    \\pub fn verticalTabScroller(src: std.builtin.SourceLocation) !*dvui.ScrollAreaWidget {
    \\    return dvui.scrollArea(
    \\        src,
    \\        .{
    \\            .horizontal = .none,
    \\            .vertical = .auto,
    \\            .vertical_bar = .hide,
    \\        },
    \\        .{ .expand = .vertical },
    \\    );
    \\}
    \\
    \\// Tab bar.
    \\// The tab-bar contains the back-ground color and the tabs.
    \\
    \\// The caller owns the returned value.
    \\pub fn horizontalTabBar(src: std.builtin.SourceLocation) !*TabBarWidget {
    \\    var ret = try dvui.currentWindow().arena.create(TabBarWidget);
    \\    ret.* = TabBarWidget.init(src, .horizontal);
    \\    // ret.* = TabBarWidget.init(src, .horizontal, .{ .expand = .horizontal });
    \\    try ret.install(.{});
    \\    return ret;
    \\}
    \\
    \\// The caller owns the returned value.
    \\pub fn verticalTabBar(src: std.builtin.SourceLocation) !*TabBarWidget {
    \\    var ret = try dvui.currentWindow().arena.create(TabBarWidget);
    \\    ret.* = TabBarWidget.init(src, .vertical);
    \\    // ret.* = TabBarWidget.init(src, .vertical, .{ .expand = .vertical });
    \\    // verticalDefaults
    \\    try ret.install(.{});
    \\    return ret;
    \\}
    \\
    \\// pub fn init(src: std.builtin.SourceLocation, init_opts: InitOptions, opts: Options) MenuWidget {
    \\//     var self = MenuWidget{};
    \\//     const options = defaults.override(opts);
    \\//     self.wd = WidgetData.init(src, .{}, options);
    \\//     self.init_opts = init_opts;
    \\
    \\//     self.winId = dvui.subwindowCurrentId();
    \\//     if (dvui.dataGet(null, self.wd.id, "_sub_act", bool)) |a| {
    \\//         self.submenus_activated = a;
    \\//     } else if (dvui.menuGet()) |pm| {
    \\//         self.submenus_activated = pm.submenus_in_child;
    \\//     } else {
    \\//         self.submenus_activated = init_opts.submenus_activated_by_default;
    \\//     }
    \\
    \\//     return self;
    \\// }
    \\pub fn init(src: std.builtin.SourceLocation, dir: Direction) TabBarWidget {
    \\    var self = TabBarWidget{};
    \\    const options: dvui.Options = switch (dir) {
    \\        .vertical => verticalDefaults,
    \\        .horizontal => horizontalDefaults,
    \\    };
    \\    self.wd = dvui.WidgetData.init(src, .{}, options);
    \\    self.winId = dvui.subwindowCurrentId();
    \\    self.dir = dir;
    \\    return self;
    \\}
    \\
    \\// pub fn install(self: *MenuWidget) !void {
    \\//     dvui.parentSet(self.widget());
    \\//     self.parentMenu = dvui.menuSet(self);
    \\//     try self.wd.register();
    \\//     try self.wd.borderAndBackground(.{});
    \\
    \\//     var evts = dvui.events();
    \\//     for (evts) |*e| {
    \\//         if (!dvui.eventMatch(e, .{ .id = self.data().id, .r = self.data().borderRectScale().r }))
    \\//             continue;
    \\
    \\//         self.processEvent(e, false);
    \\//     }
    \\
    \\//     self.box = BoxWidget.init(@src(), self.init_opts.dir, false, self.wd.options.strip().override(.{ .expand = .both }));
    \\//     try self.box.install();
    \\//     try self.box.drawBackground();
    \\// }
    \\pub fn install(self: *TabBarWidget, opts: struct {}) !void {
    \\    _ = opts;
    \\    _ = dvui.parentSet(self.widget());
    \\    try self.wd.register();
    \\    try self.wd.borderAndBackground(.{});
    \\
    \\    var evts = dvui.events();
    \\    for (evts) |*e| {
    \\        if (!dvui.eventMatch(e, .{ .id = self.data().id, .r = self.data().borderRectScale().r }))
    \\            continue;
    \\
    \\        self.processEvent(e, false);
    \\    }
    \\
    \\    // self.box = dvui.BoxWidget.init(@src(), self.dir, false, self.wd.options.strip().override(.{ .expand = .both, .background = true, .color_fill = .{ .name = .accent } })); // background_color
    \\    self.box = dvui.BoxWidget.init(@src(), self.dir, false, .{ .expand = .both, .background = true, .color_fill = .{ .name = .accent } }); // background_color
    \\    try self.box.install();
    \\}
    \\
    \\// pub fn close(self: *MenuWidget) void {
    \\//     // bubble this event to close all popups that had submenus leading to this
    \\//     var e = Event{ .evt = .{ .close_popup = .{} } };
    \\//     self.processEvent(&e, true);
    \\//     dvui.refresh(null, @src(), self.wd.id);
    \\// }
    \\pub fn close(self: *TabBarWidget) void {
    \\    // bubble this event to close all popups that had subtabBars leading to this
    \\    var e = dvui.Event{ .evt = .{ .close_popup = .{} } };
    \\    self.processEvent(&e, true);
    \\    dvui.refresh(null, @src(), self.data().id);
    \\}
    \\
    \\// pub fn widget(self: *MenuWidget) Widget {
    \\//     return Widget.init(self, data, rectFor, screenRectScale, minSizeForChild, processEvent);
    \\// }
    \\pub fn widget(self: *TabBarWidget) dvui.Widget {
    \\    return dvui.Widget.init(self, data, rectFor, screenRectScale, minSizeForChild, processEvent);
    \\}
    \\
    \\// pub fn data(self: *MenuWidget) *WidgetData {
    \\//     return &self.wd;
    \\// }
    \\pub fn data(self: *TabBarWidget) *dvui.WidgetData {
    \\    return &self.wd;
    \\}
    \\
    \\// pub fn rectFor(self: *MenuWidget, id: u32, min_size: Size, e: Options.Expand, g: Options.Gravity) Rect {
    \\//     return dvui.placeIn(self.wd.contentRect().justSize(), dvui.minSize(id, min_size), e, g);
    \\// }
    \\pub fn rectFor(self: *TabBarWidget, id: u32, min_size: dvui.Size, e: dvui.Options.Expand, g: dvui.Options.Gravity) dvui.Rect {
    \\    return dvui.placeIn(self.wd.contentRect().justSize(), dvui.minSize(id, min_size), e, g);
    \\}
    \\
    \\// pub fn screenRectScale(self: *MenuWidget, rect: Rect) RectScale {
    \\//     return self.wd.contentRectScale().rectToRectScale(rect);
    \\// }
    \\pub fn screenRectScale(self: *TabBarWidget, rect: dvui.Rect) dvui.RectScale {
    \\    return self.wd.contentRectScale().rectToRectScale(rect);
    \\}
    \\
    \\// pub fn minSizeForChild(self: *MenuWidget, s: Size) void {
    \\//     self.wd.minSizeMax(self.wd.padSize(s));
    \\// }
    \\pub fn minSizeForChild(self: *TabBarWidget, s: dvui.Size) void {
    \\    self.wd.minSizeMax(self.wd.padSize(s));
    \\}
    \\
    \\// pub fn processEvent(self: *MenuWidget, e: *Event, bubbling: bool) void {
    \\//     _ = bubbling;
    \\//     switch (e.evt) {
    \\//         .mouse => |me| {
    \\//             if (me.action == .position) {
    \\//                 if (dvui.mouseTotalMotion().nonZero()) {
    \\//                     if (dvui.dataGet(null, self.wd.id, "_child_popup", Rect)) |r| {
    \\//                         const center = Point{ .x = r.x + r.w / 2, .y = r.y + r.h / 2 };
    \\//                         const cw = dvui.currentWindow();
    \\//                         const to_center = Point.diff(center, cw.mouse_pt_prev);
    \\//                         const movement = Point.diff(cw.mouse_pt, cw.mouse_pt_prev);
    \\//                         const dot_prod = movement.x * to_center.x + movement.y * to_center.y;
    \\//                         const cos = dot_prod / (to_center.length() * movement.length());
    \\//                         if (std.math.acos(cos) < std.math.pi / 3.0) {
    \\//                             // there is an existing submenu and motion is
    \\//                             // towards the popup, so eat this event to
    \\//                             // prevent any menu items from focusing
    \\//                             e.handled = true;
    \\//                         }
    \\//                     }
    \\
    \\//                     if (!e.handled) {
    \\//                         self.mouse_over = true;
    \\//                     }
    \\//                 }
    \\//             }
    \\//         },
    \\//         .key => |ke| {
    \\//             if (ke.action == .down or ke.action == .repeat) {
    \\//                 switch (ke.code) {
    \\//                     .escape => {
    \\//                         e.handled = true;
    \\//                         var closeE = Event{ .evt = .{ .close_popup = .{} } };
    \\//                         self.processEvent(&closeE, true);
    \\//                     },
    \\//                     .up => {
    \\//                         if (self.init_opts.dir == .vertical) {
    \\//                             e.handled = true;
    \\//                             // TODO: don't do this if focus would move outside the menu
    \\//                             dvui.tabIndexPrev(e.num);
    \\//                         }
    \\//                     },
    \\//                     .down => {
    \\//                         if (self.init_opts.dir == .vertical) {
    \\//                             e.handled = true;
    \\//                             // TODO: don't do this if focus would move outside the menu
    \\//                             dvui.tabIndexNext(e.num);
    \\//                         }
    \\//                     },
    \\//                     .left => {
    \\//                         if (self.init_opts.dir == .vertical) {
    \\//                             e.handled = true;
    \\//                             if (self.parentMenu) |pm| {
    \\//                                 pm.submenus_activated = false;
    \\//                             }
    \\//                             if (self.parentSubwindowId) |sid| {
    \\//                                 dvui.focusSubwindow(sid, null);
    \\//                             }
    \\//                         } else {
    \\//                             // TODO: don't do this if focus would move outside the menu
    \\//                             dvui.tabIndexPrev(e.num);
    \\//                         }
    \\//                     },
    \\//                     .right => {
    \\//                         if (self.init_opts.dir == .vertical) {
    \\//                             e.handled = true;
    \\//                             if (self.parentMenu) |pm| {
    \\//                                 pm.submenus_activated = false;
    \\//                             }
    \\//                             if (self.parentSubwindowId) |sid| {
    \\//                                 dvui.focusSubwindow(sid, null);
    \\//                             }
    \\//                         } else {
    \\//                             e.handled = true;
    \\//                             // TODO: don't do this if focus would move outside the menu
    \\//                             dvui.tabIndexNext(e.num);
    \\//                         }
    \\//                     },
    \\//                     else => {},
    \\//                 }
    \\//             }
    \\//         },
    \\//         .close_popup => {
    \\//             self.submenus_activated = false;
    \\//         },
    \\//         else => {},
    \\//     }
    \\
    \\//     if (e.bubbleable()) {
    \\//         self.wd.parent.processEvent(e, true);
    \\//     }
    \\// }
    \\pub fn processEvent(self: *TabBarWidget, e: *dvui.Event, bubbling: bool) void {
    \\    _ = bubbling;
    \\    switch (e.evt) {
    \\        .mouse => |me| {
    \\            switch (me.action) {
    \\                .focus => {},
    \\                .press => {},
    \\                .release => {},
    \\                .motion => {},
    \\                .wheel_y => {},
    \\                .position => {
    \\                    // TODO: set this event to handled if there is an existing subtabBar and motion is towards the popup
    \\                    if (dvui.mouseTotalMotion().nonZero()) {
    \\                        self.mouse_over = true;
    \\                    }
    \\                },
    \\            }
    \\        },
    \\        else => {},
    \\    }
    \\
    \\    if (e.bubbleable()) {
    \\        // self.wd.parent.processEvent(e, false);
    \\        self.wd.parent.processEvent(e, true);
    \\    }
    \\}
    \\
    \\// pub fn deinit(self: *MenuWidget) void {
    \\//     self.box.deinit();
    \\//     dvui.dataSet(null, self.wd.id, "_sub_act", self.submenus_activated);
    \\//     if (self.child_popup_rect) |r| {
    \\//         dvui.dataSet(null, self.wd.id, "_child_popup", r);
    \\//     }
    \\//     self.wd.minSizeSetAndRefresh();
    \\//     self.wd.minSizeReportToParent();
    \\//     _ = dvui.menuSet(self.parentMenu);
    \\//     dvui.parentReset(self.wd.id, self.wd.parent);
    \\// }
    \\pub fn deinit(self: *TabBarWidget) void {
    \\    self.box.deinit();
    \\    self.wd.minSizeSetAndRefresh();
    \\    self.wd.minSizeReportToParent();
    \\    _ = dvui.parentSet(self.wd.parent);
    \\}
;
