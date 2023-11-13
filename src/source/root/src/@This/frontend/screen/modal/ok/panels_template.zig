pub const content =
    \\const std = @import("std");
    \\const _framers_ = @import("framers");
    \\const _messenger_ = @import("messenger.zig");
    \\const _OK_ = @import("OK_panel.zig");
    \\
    \\const PanelTags = enum {
    \\    OK,
    \\    none,
    \\};
    \\
    \\pub const Panels = struct {
    \\    allocator: std.mem.Allocator,
    \\    current: PanelTags,
    \\
    \\    OK: *_OK_.Panel,
    \\
    \\    pub fn deinit(self: *Panels) void {
    \\        self.OK.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    pub fn frameCurrent(self: *Panels, allocator: std.mem.Allocator) !void {
    \\        var result = switch (self.current) {
    \\            .OK => self.OK.frame(allocator),
    \\            .none => self.OK.frame(allocator),
    \\        };
    \\        return result;
    \\    }
    \\
    \\    pub fn setCurrentToOK(self: *Panels) void {
    \\        self.current = PanelTags.OK;
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, messenger: *_messenger_.Messenger) !*Panels {
    \\    var panels: *Panels = try allocator.create(Panels);
    \\    panels.allocator = allocator;
    \\
    \\    panels.OK = try _OK_.init(allocator, all_screens, panels, messenger);
    \\    errdefer {
    \\        allocator.destroy(panels);
    \\    }
    \\
    \\    return panels;
    \\}
;
