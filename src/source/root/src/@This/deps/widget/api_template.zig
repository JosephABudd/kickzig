const std = @import("std");
const _filenames_ = @import("filenames");

pub const Template = struct {
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Template) void {
        self.allocator.destroy(self);
    }

    pub fn content(self: *Template) ![]const u8 {
        var needle: []const u8 = undefined;
        var replacement: []const u8 = undefined;
        var replacement_size: usize = 0;

        // The tabbar widget.
        needle = "{{ tabbar_file_name }}";
        replacement = _filenames_.tabbar_file_name;
        replacement_size = std.mem.replacementSize(u8, template, needle, replacement);
        var with_tabbar_file_name: []u8 = try self.allocator.alloc(u8, replacement_size);
        _ = std.mem.replace(u8, template, needle, replacement, with_tabbar_file_name);

        return with_tabbar_file_name;
    }
};

pub fn init(allocator: std.mem.Allocator) !*Template {
    var self: *Template = try allocator.create(Template);
    self.allocator = allocator;
    return self;
}

const template =
    \\pub const tabbar = @import("{{ tabbar_file_name }}");
    \\
;
