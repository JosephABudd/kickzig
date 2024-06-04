const template =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\// Scrollers.
    \\
    \\/// A horizontal scroller for panel content.
    \\/// The caller owns the returned value.
    \\pub fn horizontalScroller(src: std.builtin.SourceLocation) !*dvui.ScrollAreaWidget {
    \\    return try dvui.scrollArea(
    \\        src,
    \\        .{
    \\            .horizontal = .auto,
    \\            .vertical = .none,
    \\        },
    \\        .{ .expand = .both, .color_fill = .{ .name = .fill_window } },
    \\    );
    \\}
    \\
    \\/// A vertical scroller for panel content.
    \\/// The caller owns the returned value.
    \\pub fn verticalScroller(src: std.builtin.SourceLocation) !*dvui.ScrollAreaWidget {
    \\    return try dvui.scrollArea(
    \\        src,
    \\        .{
    \\            .horizontal = .none,
    \\            .vertical = .auto,
    \\        },
    \\        .{ .expand = .horizontal, .color_fill = .{ .name = .fill_window } },
    \\    );
    \\}
    \\
    \\/// A vertical scroller for panel content.
    \\/// The caller owns the returned value.
    \\pub fn verticalScroller2(src: std.builtin.SourceLocation) !*dvui.ScrollAreaWidget {
    \\    return try dvui.scrollArea(
    \\        src,
    \\        .{
    \\            .horizontal = .auto,
    \\            .vertical = .auto,
    \\        },
    \\        .{ .expand = .both },
    \\    );
    \\}
    \\
    \\/// A vertical and horizontal scroller for panel content.
    \\/// The caller owns the returned value.
    \\pub fn contentScroller(src: std.builtin.SourceLocation) !*dvui.ScrollAreaWidget {
    \\    return try dvui.scrollArea(
    \\        src,
    \\        .{
    \\            .horizontal = .auto,
    \\            .vertical = .auto,
    \\            .horizontal_bar = .show,
    \\            .vertical_bar = .show,
    \\        },
    \\        .{ .expand = .both, .color_fill = .{ .name = .fill_window } },
    \\    );
    \\}
    \\
    \\// Layouts.
    \\
    \\/// Layout the children vertically in single column.
    \\/// The caller owns the returned value.
    \\pub fn verticalLayout(src: std.builtin.SourceLocation) !*dvui.BoxWidget {
    \\    return try dvui.box(src, .vertical, .{ .expand = .both, .background = true, .color_fill = .{ .color = dvui.Color.white } });
    \\}
    \\
    \\/// Layout the children horizontally in single row.
    \\/// The caller owns the returned value.
    \\pub fn horizontalLayout(src: std.builtin.SourceLocation) !*dvui.BoxWidget {
    \\    return try dvui.box(src, .horizontal, .{ .expand = .vertical, .background = true });
    \\}
;
