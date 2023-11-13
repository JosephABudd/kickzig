const std = @import("std");

pub const Template = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !*Template {
        var data: *Template = try allocator.create(Template);
        data.allocator = allocator;
        return data;
    }

    pub fn deinit(self: *Template) void {
        self.allocator.destroy(self);
    }

    /// The caller owns the returned value.
    pub fn content(self: *Template, modal_params_name: []const u8) ![]const u8 {
        return std.fmt.allocPrint(self.allocator, template, .{modal_params_name});
    }
};

const template =
    \\const std = @import("std");
    \\
    \\/// Params is the parameters for the {0s} modal screen's goModalFn.
    \\/// See src/@This/frontend/screen/modal/{0s}/screen.zig goModalFn.
    \\/// Your arguments are the values assigned to each Params member.
    \\/// For examples:
    \\/// * See OK.zig for a Params example.
    \\/// * See src/@This/frontend/screen/modal/OK/screen.zig goModalFn.
    \\pub const Params = struct {
    \\    allocator: std.mem.Allocator,
    \\
    \\    // Parameters.
    \\
    \\    /// The caller owns the returned value.
    \\    pub fn init(allocator: std.mem.Allocator, heading: []const u8, message: []const u8) !*Params {
    \\        var args: *Params = try allocator.create(Params);
    \\        args.allocator = allocator;
    \\        return args;
    \\    }
    \\
    \\    pub fn deinit(self: *Params) void {
    \\        self.allocator.destroy(self);
    \\    }
    \\};
    \\
;
