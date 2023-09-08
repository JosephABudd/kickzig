const build_zig = @import("build_zig.zig");
const std = @import("std");

pub const file_name: []const u8 = "build.zig";

pub const Context = struct {
    allocator: std.mem.Allocator,
    name: []u8,

    pub fn deinit(self: *Context) void {
        self.allocator.free(self.name);
        self.allocator.destroy(self);
    }
};

/// initContext constructs a new context.
/// The caller owns the return value.
pub fn initContext(allocator: std.mem.Allocator, name: []const u8) !*Context {
    var context: *Context = try allocator.create(Context);
    context.allocator = allocator;
    context.name = try allocator.alloc(u8, name.len);
    @memcpy(context.name, name);
    return context;
}

pub fn render(stream: anytype, ctx: *Context) !void {
    var temp: []u8 = undefined;
    // beware of this dirty hack for pseudo-unused
    {
        const ___magic = .{ stream, ctx };
        _ = ___magic;
    }
    // here comes the actual content
    try stream.writeAll("const std = @import(\"std\");\n\npub fn build(b: *std.Build) !void {\n    const target = b.standardTargetOptions(.{});\n    const optimize = b.standardOptimizeOption(.{});\n\n    const dvui_dep = b.dependency(\"dvui\", .{ .target = target, .optimize = optimize });\n    // WAS GOING TO TRY THIS. NOT SURE IF IT'S CORRECT.\n    // const dvui_mod = b.addModule(\"dvui\", .{\n    //     .source_file = .{ .path = \"lib/dvui/dvui.zig\" },\n    //     .dependencies = &.{},\n    // });\n\n    const sdl_mod = b.addModule(\"SDLBackend\", .{\n        .source_file = .{ .path = \"lib/dvui/src/SDLBackend.zig\" },\n        .dependencies = &.{},\n    });\n    _ = sdl_mod;\n\n    // shared modules.\n    const message_mod = b.addModule(\"message\", .{\n        .source_file = .{ .path = \"src/shared/message/api.zig\" },\n        .dependencies = &.{},\n    });\n    const channel_mod = b.addModule(\"channel\", .{\n        .source_file = .{ .path = \"src/shared/channel/api.zig\" },\n        .dependencies = &.{\n            .{ .name = \"message\", .module = message_mod },\n        },\n    });\n\n    // frontend dependencies.\n    const framers_mod = b.addModule(\"framers\", .{\n        .source_file = .{ .path = \"src/frontend/lib/framers/api.zig\" },\n        .dependencies = &.{},\n    });\n\n    const exe = b.addExecutable(.{\n        .name = ");
    temp = try std.fmt.allocPrint(ctx.allocator, "{s}", .{ctx.name});
    try stream.writeAll(temp);
    ctx.allocator.free(temp);
    try stream.writeAll(",\n        .root_source_file = .{ .path = \"");
    temp = try std.fmt.allocPrint(ctx.allocator, "{s}", .{ctx.name});
    try stream.writeAll(temp);
    ctx.allocator.free(temp);
    try stream.writeAll(".zig\" },\n        .target = target,\n        .optimize = optimize,\n    });\n\n    exe.addModule(\"dvui\", dvui_dep.module(\"dvui\"));\n    exe.addModule(\"SDLBackend\", dvui_dep.module(\"SDLBackend\"));\n\n    // WAS GOING TO TRY THIS. NOT SURE IF IT'S CORRECT.\n    // exe.addModule(\"dvui\", dvui_mod);\n    // exe.addModule(\"SDLBackend\", sdl_mod);\n\n    // frontend dependencies.\n    exe.addModule(\"framers\", framers_mod);\n\n    // shared modules.\n    exe.addModule(\"message\", message_mod);\n    exe.addModule(\"channel\", channel_mod);\n\n    // TODO: remove this part about freetype (pulling it from the dvui_dep\n    // sub-builder) once https://github.com/ziglang/zig/pull/14731 lands\n    const freetype_dep = dvui_dep.builder.dependency(\"freetype\", .{\n        .target = target,\n        .optimize = optimize,\n    });\n    // WAS GOING TO TRY THIS. NOT SURE IF IT'S CORRECT.\n    // const freetype_dep = dvui_mod.builder.dependency(\"freetype\", .{\n    //     .target = target,\n    //     .optimize = optimize,\n    // });\n    exe.linkLibrary(freetype_dep.artifact(\"freetype\"));\n\n    exe.linkSystemLibrary(\"SDL2\");\n    exe.linkLibC();\n\n    const compile_step = b.step(\"");
    temp = try std.fmt.allocPrint(ctx.allocator, "{s}", .{ctx.name});
    try stream.writeAll(temp);
    ctx.allocator.free(temp);
    try stream.writeAll("\", \"Compile ");
    temp = try std.fmt.allocPrint(ctx.allocator, "{s}", .{ctx.name});
    try stream.writeAll(temp);
    ctx.allocator.free(temp);
    try stream.writeAll("\");\n    compile_step.dependOn(&b.addInstallArtifact(exe, .{}).step);\n    b.getInstallStep().dependOn(compile_step);\n\n    const run_cmd = b.addRunArtifact(exe);\n    run_cmd.step.dependOn(compile_step);\n\n    const run_step = b.step(\"run-");
    temp = try std.fmt.allocPrint(ctx.allocator, "{s}", .{ctx.name});
    try stream.writeAll(temp);
    ctx.allocator.free(temp);
    try stream.writeAll("\", \"Run ");
    temp = try std.fmt.allocPrint(ctx.allocator, "{s}", .{ctx.name});
    try stream.writeAll(temp);
    ctx.allocator.free(temp);
    try stream.writeAll("\");\n    run_step.dependOn(&run_cmd.step);\n}");
}
