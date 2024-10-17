pub const content =
    \\const std = @import("std");
    \\
    \\pub const ExitFn = *const fn (src: std.builtin.SourceLocation, err: anyerror, description: []const u8) void;
;
