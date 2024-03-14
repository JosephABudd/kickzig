const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    screen_names: [][]const u8,
    screen_names_index: usize,
    not_modal_screen_names: [][]const u8,
    not_modal_screen_names_index: usize,
    modal_screen_names: [][]const u8,
    modal_screen_names_index: usize,

    pub fn init(allocator: std.mem.Allocator) !*Template {
        var data: *Template = try allocator.create(Template);
        data.not_modal_screen_names = try allocator.alloc([]const u8, 5);
        errdefer {
            allocator.destroy(data);
        }
        data.not_modal_screen_names_index = 0;
        data.modal_screen_names = try allocator.alloc([]const u8, 5);
        errdefer {
            allocator.destroy(data);
        }
        data.modal_screen_names_index = 0;
        data.allocator = allocator;
        return data;
    }

    pub fn deinit(self: *Template) void {
        for (self.not_modal_screen_names, 0..) |name, i| {
            if (i == self.not_modal_screen_names_index) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self.not_modal_screen_names);
        for (self.modal_screen_names, 0..) |name, i| {
            if (i == self.modal_screen_names_index) {
                break;
            }
            self.allocator.free(name);
        }
        self.allocator.free(self.not_modal_screen_names);
        self.allocator.destroy(self);
    }

    pub fn addNotModalScreenName(self: *Template, new_name: []const u8) !void {
        var new_not_modal_screen_names: [][]const u8 = undefined;
        if (self.not_modal_screen_names_index == self.not_modal_screen_names.len) {
            // Full list so create a new bigger one.
            new_not_modal_screen_names = try self.allocator.alloc([]const u8, (self.not_modal_screen_names.len + 5));
            for (self.not_modal_screen_names, 0..) |name, i| {
                new_not_modal_screen_names[i] = name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self.not_modal_screen_names);
            self.not_modal_screen_names = new_not_modal_screen_names;
        }
        self.not_modal_screen_names[self.not_modal_screen_names_index] = try self.allocator.alloc(u8, new_name.len);
        @memcpy(@constCast(self.not_modal_screen_names[self.not_modal_screen_names_index]), new_name);
        self.not_modal_screen_names_index += 1;
    }

    pub fn addModalScreenName(self: *Template, new_name: []const u8) !void {
        if (std.mem.eql(u8, "EOJ", new_name)) {
            // The EOJ modal is built into this template.
            return;
        }
        if (self.modal_screen_names_index == self.modal_screen_names.len) {
            // Full list so create a new bigger one.
            var new_modal_screen_names: [][]const u8 = try self.allocator.alloc([]const u8, (self.modal_screen_names.len + 5));
            for (self.modal_screen_names, 0..) |name, i| {
                new_modal_screen_names[i] = name;
            }
            // Replace the old list with the new bigger one.
            self.allocator.free(self.modal_screen_names);
            self.modal_screen_names = new_modal_screen_names;
        }
        self.modal_screen_names[self.modal_screen_names_index] = try self.allocator.alloc(u8, new_name.len);
        @memcpy(@constCast(self.modal_screen_names[self.modal_screen_names_index]), new_name);
        self.modal_screen_names_index += 1;
    }

    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        const modal_names: ?[][]const u8 = switch (self.modal_screen_names_index) {
            0 => null,
            else => self.modal_screen_names[0..self.modal_screen_names_index],
        };
        const not_modal_names: ?[][]const u8 = switch (self.not_modal_screen_names_index) {
            0 => null,
            else => self.not_modal_screen_names[0..self.not_modal_screen_names_index],
        };

        var line: []u8 = undefined;
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();

        // Build the content.
        try lines.appendSlice(line1);

        // Tag each screen.
        if (not_modal_names) |names| {
            for (names) |name| {
                // Replace {{ screen_name }} with the message name.
                const replacement_size: usize = std.mem.replacementSize(u8, line1_not_modal, "{{ screen_name }}", name);
                line = try self.allocator.alloc(u8, replacement_size);
                defer self.allocator.free(line);
                _ = std.mem.replace(u8, line1_not_modal, "{{ screen_name }}", name, line);
                try lines.appendSlice(line);
            }
        }

        try lines.appendSlice(line2);

        // Show funcs for not modal screens.
        if (not_modal_names) |names| {
            for (names) |name| {
                // Replace {{ screen_name }} with the message name.
                const replacement_size: usize = std.mem.replacementSize(u8, line2_not_modal, "{{ screen_name }}", name);
                line = try self.allocator.alloc(u8, replacement_size);
                defer self.allocator.free(line);
                _ = std.mem.replace(u8, line2_not_modal, "{{ screen_name }}", name, line);
                try lines.appendSlice(line);
            }
        }

        // Show funcs for modal screens.
        if (modal_names) |names| {
            for (names) |name| {
                // Replace {{ screen_name }} with the message name.
                const replacement_size: usize = std.mem.replacementSize(u8, line2_modal, "{{ screen_name }}", name);
                line = try self.allocator.alloc(u8, replacement_size);
                defer self.allocator.free(line);
                _ = std.mem.replace(u8, line2_modal, "{{ screen_name }}", name, line);
                try lines.appendSlice(line);
            }
        }

        try lines.appendSlice(line_eoj);

        const temp: []const u8 = try lines.toOwnedSlice();
        line = try self.allocator.alloc(u8, temp.len);
        @memcpy(line, temp);
        return line;
    }
};

const line1 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const _lock_ = @import("lock");
    \\const _modal_params_ = @import("modal_params");
    \\const _startup_ = @import("startup");
    \\const ExitFn = @import("various").ExitFn;
    \\pub const ScreenTags = @import("screen_tags.zig").ScreenTags;
    \\
    \\/// MainView is each and every screen.
    \\pub const MainView = struct {
    \\    allocator: std.mem.Allocator,
    \\    lock: *_lock_.ThreadLock,
    \\    window: *dvui.Window,
    \\    exit: ExitFn,
    \\    current: ?ScreenTags,
    \\    current_modal_is_new: bool,
    \\    current_is_modal: bool,
    \\    previous: ?ScreenTags,
    \\    modal_args: ?*anyopaque,
    \\
    \\    pub fn init(startup: _startup_.Frontend) !*MainView {
    \\        var self: *MainView = try startup.allocator.create(MainView);
    \\        self.lock = try _lock_.init(startup.allocator);
    \\        errdefer startup.allocator.destroy(self);
    \\
    \\        self.allocator = startup.allocator;
    \\        self.exit = startup.exit;
    \\        self.window = startup.window;
    \\
    \\        self.current = null;
    \\        self.previous = null;
    \\        self.current_is_modal = false;
    \\        self.modal_args = null;
    \\        self.current_modal_is_new = false;
    \\
    \\        return self;
    \\    }
    \\
    \\    pub fn deinit(self: *MainView) void {
    \\        self.lock.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    pub fn show(self: *MainView, screen: ScreenTags) !void {
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        // Only show if not a modal screen.
    \\        return switch (screen) {
    \\
;

const line1_not_modal =
    \\            .{{ screen_name }} => self.show{{ screen_name }}(),
    \\
;

const line2 =
    \\            else => error.CantShowModalScreen,
    \\        };
    \\    }
    \\
    \\    pub fn isModal(self: *MainView) bool {
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        return self.current_is_modal;
    \\    }
    \\
    \\    pub fn isNewModal(self: *MainView) bool {
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        const is_new: bool = self.current_modal_is_new;
    \\        self.current_modal_is_new = false;
    \\        return is_new;
    \\    }
    \\
    \\    pub fn currentTag(self: *MainView) ?ScreenTags {
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        return self.current;
    \\    }
    \\
    \\    pub fn modalArgs(self: *MainView) ?*anyopaque {
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        const modal_args = self.modal_args;
    \\        self.modal_args = null;
    \\        return modal_args;
    \\    }
    \\
;

const line2_not_modal =
    \\
    \\    // The {{ screen_name }} screen.
    \\
    \\    /// show{{ screen_name }} makes the {{ screen_name }} screen to the current one.
    \\    pub fn show{{ screen_name }}(self: *MainView) void {
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        if (!self.current_is_modal) {
    \\            // The current screen is not modal so replace it.
    \\            self.current = .{{ screen_name }};
    \\            self.current_is_modal = false;
    \\        }
    \\    }
    \\
    \\    /// refresh{{ screen_name }} refreshes the window if the {{ screen_name }} screen is the current one.
    \\    pub fn refresh{{ screen_name }}(self: *MainView) void {
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        if (self.current) |current| {
    \\            if (current == .{{ screen_name }}) {
    \\                // {{ screen_name }} is the current screen.
    \\                dvui.refresh(self.window, @src(), null);
    \\            }
    \\        }
    \\    }
    \\
;

const line2_modal =
    \\    // The {{ screen_name }} modal screen.
    \\
    \\    /// show{{ screen_name }} starts the {{ screen_name }} modal screen.
    \\    /// Param args is the {{ screen_name }} modal args.
    \\    /// show{{ screen_name }} owns modal_args_ptr.
    \\    pub fn show{{ screen_name }}(self: *MainView, modal_args_ptr: *anyopaque) void {
    \\        self.lock.lock();
    \\        defer dvui.refresh(self.window, @src(), null);
    \\        defer self.lock.unlock();
    \\
    \\        if (self.current_is_modal) {
    \\            // The current modal is still showing.
    \\            return;
    \\        }
    \\        // Save the current screen.
    \\        self.previous = self.current;
    \\        self.current_modal_is_new = true;
    \\        self.current_is_modal = true;
    \\        self.modal_args = modal_args_ptr;
    \\        self.current = .{{ screen_name }};
    \\    }
    \\
    \\    /// hide{{ screen_name }} hides the modal screen {{ screen_name }}.
    \\    pub fn hide{{ screen_name }}(self: *MainView) void {
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        if (self.current) |current| {
    \\            if (current == .{{ screen_name }}) {
    \\                // {{ screen_name }} is the current screen so hide it.
    \\                self.current = self.previous;
    \\                self.current_is_modal = false;
    \\                self.modal_args = null;
    \\                self.previous = null;
    \\            }
    \\        }
    \\    }
    \\
    \\    /// refresh{{ screen_name }} refreshes the window if the {{ screen_name }} screen is the current one.
    \\    pub fn refresh{{ screen_name }}(self: *MainView) void {
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        if (self.current) |current| {
    \\            if (current == .{{ screen_name }}) {
    \\                // {{ screen_name }} is the current screen.
    \\                dvui.refresh(self.window, @src(), null);
    \\            }
    \\        }
    \\    }
    \\
;

const line_eoj =
    \\
    \\    // The EOJ modal screen.
    \\
    \\    /// forceEOJ starts the EOJ modal screen even if another modal is shown.
    \\    /// Param args is the EOJ modal args.
    \\    /// forceEOJ owns modal_args_ptr.
    \\    pub fn forceEOJ(self: *MainView, modal_args_ptr: *anyopaque) void {
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        // Don't save the current screen.
    \\        self.current_modal_is_new = true;
    \\        self.current_is_modal = true;
    \\        self.modal_args = modal_args_ptr;
    \\        self.current = .EOJ;
    \\    }
    \\
    \\    /// showEOJ starts the EOJ modal screen.
    \\    /// Param args is the EOJ modal args.
    \\    /// showEOJ owns modal_args_ptr.
    \\    pub fn showEOJ(self: *MainView, modal_args_ptr: *anyopaque) void {
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        if (self.current_is_modal) {
    \\            // The current modal is not hidden yet.
    \\            return;
    \\        }
    \\        // Don't save the current screen.
    \\        self.current_modal_is_new = true;
    \\        self.current_is_modal = true;
    \\        self.modal_args = modal_args_ptr;
    \\        self.current = .EOJ;
    \\    }
    \\
    \\    /// hideEOJ hides the modal screen EOJ.
    \\    pub fn hideEOJ(self: *MainView) void {
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        if (self.current) |current| {
    \\            if (current == .EOJ) {
    \\                // EOJ is the current screen so hide it.
    \\                self.current = self.previous;
    \\                self.current_is_modal = false;
    \\                self.modal_args = null;
    \\                self.previous = null;
    \\            }
    \\        }
    \\    }
    \\
    \\    /// refreshEOJ refreshes the window if the EOJ screen is the current one.
    \\    pub fn refreshEOJ(self: *MainView) void {
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        if (self.current) |current| {
    \\            if (current == .EOJ) {
    \\                // EOJ is the current screen.
    \\                dvui.refresh(self.window, @src(), null);
    \\            }
    \\        }
    \\    }
    \\};
;
