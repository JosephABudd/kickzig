pub const content =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const background_color: dvui.Options.ColorsFromTheme = .fill_control;
    \\
    \\// Tab bar row.
    \\
    \\// The caller owns the returned value.
    \\pub fn horizontalTabBarRow(src: std.builtin.SourceLocation) !*dvui.BoxWidget {
    \\    return dvui.box(src, .horizontal, .{ .expand = .horizontal, .background = false });
    \\    // return dvui.box(src, .horizontal, .{ .expand = .horizontal, .background = true, .color_fill = .{ .name = background_color } });
    \\}
    \\
    \\// The caller owns the returned value.
    \\pub fn verticalTabBarColumn(src: std.builtin.SourceLocation) !*dvui.BoxWidget {
    \\    return dvui.box(src, .vertical, .{ .expand = .vertical, .background = false });
    \\    // return dvui.box(src, .vertical, .{ .expand = .vertical, .background = true, .color_fill = .{ .name = background_color } });
    \\}
    \\
    \\// Tab scroller.
    \\
    \\// The caller owns the returned value.
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
    \\
    \\// The caller owns the returned value.
    \\pub fn horizontalTabBar(src: std.builtin.SourceLocation) !*TabBarWidget {
    \\    var ret = try dvui.currentWindow().arena.create(TabBarWidget);
    \\    ret.* = TabBarWidget.init(src, .horizontal, .{ .background = true, .color_fill = .{ .name = background_color }, .expand = .horizontal });
    \\    try ret.install(.{});
    \\    return ret;
    \\}
    \\
    \\// The caller owns the returned value.
    \\pub fn verticalTabBar(src: std.builtin.SourceLocation) !*TabBarWidget {
    \\    var ret = try dvui.currentWindow().arena.create(TabBarWidget);
    \\    ret.* = TabBarWidget.init(src, .vertical, .{ .background = true, .color_fill = .{ .name = background_color }, .expand = .vertical });
    \\    try ret.install(.{});
    \\    return ret;
    \\}
    \\
    \\// The caller owns the returned value.
    \\pub fn contentArea(src: std.builtin.SourceLocation) !*dvui.BoxWidget {
    \\    return try dvui.box(src, .vertical, .{ .expand = .both, .background = true });
    \\}
    \\
    \\pub const TabBarWidget = struct {
    \\    pub var defaults: dvui.Options = .{
    \\        // .color_style = .window,
    \\    };
    \\
    \\    wd: dvui.WidgetData = undefined,
    \\
    \\    winId: u32 = undefined,
    \\    dir: dvui.enums.Direction = undefined,
    \\    box: dvui.BoxWidget = undefined,
    \\
    \\    mouse_over: bool = false,
    \\
    \\    pub fn init(src: std.builtin.SourceLocation, dir: dvui.enums.Direction, opts: dvui.Options) TabBarWidget {
    \\        var self = TabBarWidget{};
    \\        const options = defaults.override(opts);
    \\        self.wd = dvui.WidgetData.init(src, .{}, options);
    \\
    \\        self.winId = dvui.subwindowCurrentId();
    \\        self.dir = dir;
    \\
    \\        return self;
    \\    }
    \\
    \\    pub fn install(self: *TabBarWidget, opts: struct {}) !void {
    \\        _ = opts;
    \\        _ = dvui.parentSet(self.widget());
    \\        try self.wd.register();
    \\        try self.wd.borderAndBackground(.{});
    \\
    \\        var evts = dvui.events();
    \\        for (evts) |*e| {
    \\            if (!dvui.eventMatch(e, .{ .id = self.data().id, .r = self.data().borderRectScale().r }))
    \\                continue;
    \\
    \\            self.processEvent(e, false);
    \\        }
    \\
    \\        // self.box = dvui.BoxWidget.init(@src(), self.dir, false, self.wd.options.strip().override(.{ .expand = .both, .background = true, .color_fill = .{ .name = .accent } })); // background_color
    \\        self.box = dvui.BoxWidget.init(@src(), self.dir, false, .{ .expand = .both, .background = true, .color_fill = .{ .name = .accent } }); // background_color
    \\        try self.box.install();
    \\    }
    \\
    \\    pub fn close(self: *TabBarWidget) void {
    \\        // bubble this event to close all popups that had subtabBars leading to this
    \\        var e = dvui.Event{ .evt = .{ .close_popup = .{} } };
    \\        self.processEvent(&e, true);
    \\        dvui.refresh(null, @src(), self.data().id);
    \\    }
    \\
    \\    pub fn widget(self: *TabBarWidget) dvui.Widget {
    \\        return dvui.Widget.init(self, data, rectFor, screenRectScale, minSizeForChild, processEvent);
    \\    }
    \\
    \\    pub fn data(self: *TabBarWidget) *dvui.WidgetData {
    \\        return &self.wd;
    \\    }
    \\
    \\    pub fn rectFor(self: *TabBarWidget, id: u32, min_size: dvui.Size, e: dvui.Options.Expand, g: dvui.Options.Gravity) dvui.Rect {
    \\        return dvui.placeIn(self.wd.contentRect().justSize(), dvui.minSize(id, min_size), e, g);
    \\    }
    \\
    \\    pub fn screenRectScale(self: *TabBarWidget, rect: dvui.Rect) dvui.RectScale {
    \\        return self.wd.contentRectScale().rectToRectScale(rect);
    \\    }
    \\
    \\    pub fn minSizeForChild(self: *TabBarWidget, s: dvui.Size) void {
    \\        self.wd.minSizeMax(self.wd.padSize(s));
    \\    }
    \\
    \\    pub fn processEvent(self: *TabBarWidget, e: *dvui.Event, bubbling: bool) void {
    \\        _ = bubbling;
    \\        switch (e.evt) {
    \\            .mouse => |me| {
    \\                switch (me.action) {
    \\                    .focus => {},
    \\                    .press => {},
    \\                    .release => {},
    \\                    .motion => {},
    \\                    .wheel_y => {},
    \\                    .position => {
    \\                        // TODO: set this event to handled if there is an existing subtabBar and motion is towards the popup
    \\                        if (dvui.mouseTotalMotion().nonZero()) {
    \\                            self.mouse_over = true;
    \\                        }
    \\                    },
    \\                }
    \\            },
    \\            else => {},
    \\        }
    \\
    \\        if (e.bubbleable()) {
    \\            // self.wd.parent.processEvent(e, false);
    \\            self.wd.parent.processEvent(e, true);
    \\        }
    \\    }
    \\
    \\    pub fn deinit(self: *TabBarWidget) void {
    \\        self.box.deinit();
    \\        self.wd.minSizeSetAndRefresh();
    \\        self.wd.minSizeReportToParent();
    \\        _ = dvui.parentSet(self.wd.parent);
    \\    }
    \\
    \\    pub fn itemLabel(self: *TabBarWidget, src: std.builtin.SourceLocation, label_str: []const u8, selected: bool) !?dvui.Rect {
    \\        const flow: TabBarItemWidget.Flow = switch (self.dir) {
    \\            .horizontal => .horizontal,
    \\            .vertical => .vertical,
    \\        };
    \\        var tbi = try tabBarItem(src, .{ .flow = flow, .selected = selected }, .{});
    \\        defer tbi.deinit();
    \\
    \\        var ret: ?dvui.Rect = null;
    \\        if (tbi.activeRect()) |r| {
    \\            ret = r;
    \\        }
    \\
    \\        try dvui.labelNoFmt(@src(), label_str, .{});
    \\
    \\        return ret;
    \\    }
    \\
    \\    // pub fn tabBarItemIcon(self: *TabBarWidget, src: std.builtin.SourceLocation, name: []const u8, tvg_bytes: []const u8, selected: bool) !?dvui.Rect {
    \\    //     const flow: TabBarItemWidget.Flow = switch (self.dir) {
    \\    //         .horizontal => .horizontal,
    \\    //         .vertical => .vertical,
    \\    //     };
    \\    //     var tbi = try tabBarItem(src, .{ .flow = flow, .selected = selected }, .{});
    \\    //     defer tbi.deinit();
    \\
    \\    //     var ret: ?dvui.Rect = null;
    \\    //     if (tbi.activeRect()) |r| {
    \\    //         ret = r;
    \\    //     }
    \\
    \\    //     var iconopts = dvui.Options{};
    \\    //     if (tbi.show_active) {
    \\    //         if (tbi.init_opts.selected) {
    \\    //             switch (tbi.init_opts.flow) {
    \\    //                 .horizontal => {
    \\    //                     iconopts = iconopts.override(.{
    \\    //                         .color_style = .accent,
    \\    //                         .font_style = .heading,
    \\    //                         .padding = .{ .x = 5, .y = 5, .w = 5, .h = 8 },
    \\    //                         .border = .{ .x = 0, .y = 0, .w = 0, .h = 0 },
    \\    //                         .margin = .{ .x = 0, .y = 0, .w = 0, .h = 0 },
    \\    //                     });
    \\    //                 },
    \\    //                 .vertical => {
    \\    //                     iconopts = iconopts.override(.{
    \\    //                         .color_style = .accent,
    \\    //                         .font_style = .heading,
    \\    //                         .padding = .{ .x = 4, .y = 4, .w = 4, .h = 4 },
    \\    //                         .border = .{ .x = 0, .y = 0, .w = 0, .h = 0 },
    \\    //                         .margin = .{ .x = 0, .y = 0, .w = 0, .h = 0 },
    \\    //                     });
    \\    //                 },
    \\    //             }
    \\    //         }
    \\    //     }
    \\
    \\    //     try icon(@src(), name, tvg_bytes, iconopts);
    \\
    \\    //     return ret;
    \\    // }
    \\};
    \\
    \\pub fn verticalTabBarItemLabel(src: std.builtin.SourceLocation, label_str: []const u8, selected: bool) !?dvui.Rect {
    \\    var initOptions: TabBarItemWidget.InitOptions = TabBarItemWidget.vertical_init_options;
    \\    initOptions.selected = selected;
    \\    return tabBarItemLabel(src, label_str, initOptions);
    \\}
    \\
    \\pub fn horizontalTabBarItemLabel(src: std.builtin.SourceLocation, label_str: []const u8, selected: bool) !?dvui.Rect {
    \\    var initOptions: TabBarItemWidget.InitOptions = TabBarItemWidget.horizontal_init_options;
    \\    initOptions.selected = selected;
    \\    return tabBarItemLabel(src, label_str, initOptions);
    \\}
    \\
    \\fn tabBarItemLabel(src: std.builtin.SourceLocation, label_str: []const u8, init_opts: TabBarItemWidget.InitOptions) !?dvui.Rect {
    \\    var tbi = try tabBarItem(src, init_opts);
    \\    var ret: ?dvui.Rect = null;
    \\    if (tbi.activeRect()) |r| {
    \\        ret = r;
    \\    }
    \\
    \\    var labelopts: dvui.Options = .{};
    \\    if (tbi.show_active) {
    \\        if (tbi.init_opts.selected) {
    \\            switch (tbi.init_opts.flow) {
    \\                .horizontal => {},
    \\                .vertical => {
    \\                    labelopts.gravity_x = 1;
    \\                },
    \\            }
    \\        }
    \\    }
    \\
    \\    try dvui.labelNoFmt(@src(), label_str, labelopts);
    \\
    \\    tbi.deinit();
    \\
    \\    return ret;
    \\}
    \\
    \\// pub fn tabBarItemIcon(src: std.builtin.SourceLocation, name: []const u8, tvg_bytes: []const u8, init_opts: TabBarItemWidget.InitOptions, opts: dvui.Options) !?dvui.Rect {
    \\//     var mi = try tabBarItem(src, init_opts, opts);
    \\
    \\//     var iconopts = opts.strip();
    \\
    \\//     var ret: ?dvui.Rect = null;
    \\//     if (mi.activeRect()) |r| {
    \\//         ret = r;
    \\//     }
    \\
    \\//     if (mi.show_active) {
    \\//         iconopts = iconopts.override(.{ .color_style = .accent });
    \\//     }
    \\
    \\//     try icon(@src(), name, tvg_bytes, iconopts);
    \\
    \\//     mi.deinit();
    \\
    \\//     return ret;
    \\// }
    \\
    \\pub fn tabBarItem(src: std.builtin.SourceLocation, init_opts: TabBarItemWidget.InitOptions) !*TabBarItemWidget {
    \\    var ret = try dvui.currentWindow().arena.create(TabBarItemWidget);
    \\    ret.* = TabBarItemWidget.init(src, init_opts);
    \\    try ret.install(.{});
    \\    return ret;
    \\}
    \\
    \\pub const TabBarItemWidget = struct {
    \\    // Defaults for tabs in a horizontal tabbar.
    \\    fn horizontalDefaultOptions() dvui.Options {
    \\        var defaults: dvui.Options = .{
    \\            .color_fill = .{ .name = .fill_hover },
    \\            .corner_radius = .{ .x = 2, .y = 2, .w = 0, .h = 0 },
    \\            .padding = .{ .x = 0, .y = 0, .w = 0, .h = 0 },
    \\            .border = .{ .x = 1, .y = 1, .w = 1, .h = 0 },
    \\            .margin = .{ .x = 4, .y = 0, .w = 0, .h = 8 },
    \\            .expand = .none,
    \\            .font_style = .body,
    \\        };
    \\        var hover: dvui.Color = dvui.themeGet().color_fill_hover;
    \\        var darken: dvui.Color = dvui.Color.darken(hover, 0.5);
    \\        defaults.color_border = .{ .color = darken };
    \\        return defaults;
    \\    }
    \\    fn horizontalDefaultSelectedOptions() dvui.Options {
    \\        var bg: dvui.Color = dvui.themeGet().color_fill_window;
    \\        var defaults = horizontalDefaultOptions();
    \\        defaults.color_fill = .{ .color = bg };
    \\        defaults.color_border = .{ .name = .accent };
    \\        defaults.margin = .{ .x = 4, .y = 7, .w = 0, .h = 0 };
    \\
    \\        return defaults;
    \\    }
    \\
    \\    // Defaults for tabs in a vertical tabbar.
    \\    fn verticalDefaultOptions() dvui.Options {
    \\        var defaults: dvui.Options = .{
    \\            .color_fill = .{ .name = .fill_hover },
    \\            .color_border = .{ .name = .fill_hover },
    \\            .corner_radius = .{ .x = 2, .y = 0, .w = 0, .h = 2 },
    \\            .padding = .{ .x = 0, .y = 0, .w = 1, .h = 0 },
    \\            .border = .{ .x = 1, .y = 1, .w = 0, .h = 1 },
    \\            .margin = .{ .x = 1, .y = 4, .w = 6, .h = 0 },
    \\            .expand = .horizontal,
    \\            .font_style = .body,
    \\        };
    \\        var hover: dvui.Color = dvui.themeGet().color_fill_hover;
    \\        var darken: dvui.Color = dvui.Color.darken(hover, 0.5);
    \\        defaults.color_border = .{ .color = darken };
    \\        return defaults;
    \\    }
    \\    fn verticalDefaultSelectedOptions() dvui.Options {
    \\        var bg: dvui.Color = dvui.themeGet().color_fill_window;
    \\        var defaults = verticalDefaultOptions();
    \\        defaults.color_fill = .{ .color = bg };
    \\        defaults.color_border = .{ .name = .accent };
    \\        defaults.margin = .{ .x = 7, .y = 4, .w = 0, .h = 0 };
    \\        return defaults;
    \\    }
    \\
    \\    pub const Flow = enum {
    \\        horizontal,
    \\        vertical,
    \\    };
    \\
    \\    pub const InitOptions = struct {
    \\        selected: bool = false,
    \\        focus_on_hover: bool = true,
    \\        flow: Flow = .horizontal,
    \\    };
    \\
    \\    var horizontal_init_options: InitOptions = .{
    \\        .selected = false,
    \\        .focus_on_hover = true,
    \\        .flow = .horizontal,
    \\    };
    \\
    \\    var vertical_init_options: InitOptions = .{
    \\        .selected = false,
    \\        .focus_on_hover = true,
    \\        .flow = .vertical,
    \\    };
    \\
    \\    wd: dvui.WidgetData = undefined,
    \\    highlight: bool = false,
    \\    init_opts: InitOptions = undefined,
    \\    activated: bool = false,
    \\    show_active: bool = false,
    \\    mouse_over: bool = false,
    \\
    \\    pub fn init(src: std.builtin.SourceLocation, init_opts: InitOptions) TabBarItemWidget {
    \\        var self = TabBarItemWidget{};
    \\        const defaults: dvui.Options = switch (init_opts.flow) {
    \\            .horizontal => blk: {
    \\                switch (init_opts.selected) {
    \\                    true => break :blk horizontalDefaultSelectedOptions(),
    \\                    false => break :blk horizontalDefaultOptions(), //horizontal_defaults,
    \\                }
    \\            },
    \\            .vertical => blk: {
    \\                switch (init_opts.selected) {
    \\                    true => break :blk verticalDefaultSelectedOptions(),
    \\                    false => break :blk verticalDefaultOptions(),
    \\                }
    \\            },
    \\        };
    \\        self.wd = dvui.WidgetData.init(src, .{}, defaults);
    \\        self.init_opts = init_opts;
    \\        self.show_active = init_opts.selected;
    \\        return self;
    \\    }
    \\
    \\    pub fn install(self: *TabBarItemWidget, opts: struct { process_events: bool = true, focus_as_outline: bool = true }) !void {
    \\        try self.wd.register();
    \\
    \\        if (self.wd.visible()) {
    \\            try dvui.tabIndexSet(self.wd.id, self.wd.options.tab_index);
    \\        }
    \\
    \\        if (opts.process_events) {
    \\            var evts = dvui.events();
    \\            for (evts) |*e| {
    \\                if (dvui.eventMatch(e, .{ .id = self.data().id, .r = self.data().borderRectScale().r })) {
    \\                    self.processEvent(e, false);
    \\                }
    \\            }
    \\        }
    \\
    \\        try self.wd.borderAndBackground(.{});
    \\
    \\        if (self.show_active) {
    \\            _ = dvui.parentSet(self.widget());
    \\            return;
    \\        }
    \\
    \\        var focused: bool = false;
    \\        if (self.wd.id == dvui.focusedWidgetId()) {
    \\            focused = true;
    \\        } else if (self.wd.id == dvui.focusedWidgetIdInCurrentSubwindow() and self.highlight) {
    \\            focused = true;
    \\        }
    \\        if (focused) {
    \\            if (self.mouse_over) {
    \\                self.show_active = true;
    \\                try self.wd.focusBorder();
    \\                _ = dvui.parentSet(self.widget());
    \\                return;
    \\            } else {
    \\                focused = false;
    \\                self.show_active = false;
    \\                dvui.focusWidget(null, null, null);
    \\            }
    \\        }
    \\
    \\        if ((self.wd.id == dvui.focusedWidgetIdInCurrentSubwindow()) or self.highlight) {
    \\            const rs = self.wd.backgroundRectScale();
    \\            try dvui.pathAddRect(rs.r, self.wd.options.corner_radiusGet().scale(rs.s));
    \\            try dvui.pathFillConvex(self.wd.options.color(.fill_hover));
    \\        } else if (self.wd.options.backgroundGet()) {
    \\            const rs = self.wd.backgroundRectScale();
    \\            try dvui.pathAddRect(rs.r, self.wd.options.corner_radiusGet().scale(rs.s));
    \\            try dvui.pathFillConvex(self.wd.options.color(.fill));
    \\        }
    \\        _ = dvui.parentSet(self.widget());
    \\    }
    \\
    \\    pub fn activeRect(self: *const TabBarItemWidget) ?dvui.Rect {
    \\        if (self.activated) {
    \\            const rs = self.wd.backgroundRectScale();
    \\            return rs.r.scale(1 / dvui.windowNaturalScale());
    \\        } else {
    \\            return null;
    \\        }
    \\    }
    \\
    \\    pub fn widget(self: *TabBarItemWidget) dvui.Widget {
    \\        return dvui.Widget.init(self, data, rectFor, screenRectScale, minSizeForChild, processEvent);
    \\    }
    \\
    \\    pub fn data(self: *TabBarItemWidget) *dvui.WidgetData {
    \\        return &self.wd;
    \\    }
    \\
    \\    pub fn rectFor(self: *TabBarItemWidget, id: u32, min_size: dvui.Size, e: dvui.Options.Expand, g: dvui.Options.Gravity) dvui.Rect {
    \\        return dvui.placeIn(self.wd.contentRect().justSize(), dvui.minSize(id, min_size), e, g);
    \\    }
    \\
    \\    pub fn screenRectScale(self: *TabBarItemWidget, rect: dvui.Rect) dvui.RectScale {
    \\            return self.wd.contentRectScale().rectToRectScale(rect);
    \\    }
    \\
    \\    pub fn minSizeForChild(self: *TabBarItemWidget, s: dvui.Size) void {
    \\        self.wd.minSizeMax(self.wd.padSize(s));
    \\    }
    \\
    \\    pub fn processEvent(self: *TabBarItemWidget, e: *dvui.Event, bubbling: bool) void {
    \\        _ = bubbling;
    \\        var focused: bool = false;
    \\        var focused_id: u32 = 0;
    \\        if (dvui.focusedWidgetIdInCurrentSubwindow()) |_focused_id| {
    \\            focused = self.wd.id == _focused_id;
    \\            focused_id = _focused_id;
    \\        }
    \\        switch (e.evt) {
    \\            .mouse => |me| {
    \\                switch (me.action) {
    \\                    .focus => {
    \\                        e.handled = true;
    \\                        dvui.focusSubwindow(null, null); // focuses the window we are in
    \\                        dvui.focusWidget(self.wd.id, null, e.num);
    \\                    },
    \\                    .press => {
    \\                        if (me.button == dvui.enums.Button.left) {
    \\                            e.handled = true;
    \\                        }
    \\                    },
    \\                    .release => {
    \\                        e.handled = true;
    \\                        self.activated = true;
    \\                        dvui.refresh(null, @src(), self.data().id);
    \\                    },
    \\                    .motion => {},
    \\                    .wheel_y => {},
    \\                    .position => {
    \\                        e.handled = true;
    \\                        // We get a .position mouse event every frame.  If we
    \\                        // focus the tabBar item under the mouse even if it's not
    \\                        // moving then it breaks keyboard navigation.
    \\                        if (dvui.mouseTotalMotion().nonZero()) {
    \\                            self.highlight = true;
    \\                            self.mouse_over = true;
    \\                        }
    \\                    },
    \\                }
    \\            },
    \\            .key => |ke| {
    \\                if (ke.code == .space and ke.action == .down) {
    \\                    e.handled = true;
    \\                    if (!self.activated) {
    \\                        self.activated = true;
    \\                        dvui.refresh(null, @src(), self.data().id);
    \\                    }
    \\                } else if (ke.code == .right and ke.action == .down) {
    \\                    e.handled = true;
    \\                }
    \\            },
    \\            else => {},
    \\        }
    \\
    \\        if (e.bubbleable()) {
    \\            self.wd.parent.processEvent(e, true);
    \\        }
    \\    }
    \\
    \\    pub fn deinit(self: *TabBarItemWidget) void {
    \\        self.wd.minSizeSetAndRefresh();
    \\        self.wd.minSizeReportToParent();
    \\        _ = dvui.parentSet(self.wd.parent);
    \\    }
    \\};
;
