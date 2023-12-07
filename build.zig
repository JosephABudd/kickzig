const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    // Internal src/deps/ modules.
    const stdout_mod = b.addModule("stdout", .{
        .source_file = .{ .path = "src/deps/stdout/api.zig" },
        .dependencies = &.{},
    });
    const usage_mod = b.addModule("usage", .{
        .source_file = .{ .path = "src/deps/usage.zig" },
        .dependencies = &.{},
    });
    const warning_mod = b.addModule("warning", .{
        .source_file = .{ .path = "src/deps/warning.zig" },
        .dependencies = &.{},
    });
    const paths_mod = b.addModule("paths", .{
        .source_file = .{ .path = "src/deps/paths/api.zig" },
        .dependencies = &.{},
    });
    const filenames_mod = b.addModule("filenames", .{
        .source_file = .{ .path = "src/deps/filenames/api.zig" },
        .dependencies = &.{
            .{ .name = "paths", .module = paths_mod },
        },
    });
    const slices_mod = b.addModule("slices", .{
        .source_file = .{ .path = "src/deps/slices.zig" },
        .dependencies = &.{},
    });
    const strings_mod = b.addModule("strings", .{
        .source_file = .{ .path = "src/deps/strings.zig" },
        .dependencies = &.{},
    });
    const verify_mod = b.addModule("verify", .{
        .source_file = .{ .path = "src/deps/verify.zig" },
        .dependencies = &.{
            .{ .name = "filenames", .module = filenames_mod },
            .{ .name = "strings", .module = strings_mod },
        },
    });

    // Internal source/ module.
    const source_mod = b.addModule("source", .{
        .source_file = .{ .path = "src/source/api.zig" },
        .dependencies = &.{
            .{ .name = "stdout", .module = stdout_mod },
            .{ .name = "paths", .module = paths_mod },
            .{ .name = "filenames", .module = filenames_mod },
            .{ .name = "slices", .module = slices_mod },
            .{ .name = "strings", .module = strings_mod },
        },
    });

    const exe = b.addExecutable(.{
        .name = "kickzig",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Local src/libs/ modules.
    exe.addModule("stdout", stdout_mod);
    // Local src/commands/libs/ modules.
    exe.addModule("usage", usage_mod);
    exe.addModule("warning", warning_mod);
    exe.addModule("verify", verify_mod);
    // Local src/source/ module.
    exe.addModule("source", source_mod);
    // Local src/source/libs/ modules.
    exe.addModule("paths", paths_mod);
    exe.addModule("filenames", filenames_mod);
    exe.addModule("slices", slices_mod);
    exe.addModule("strings", strings_mod);

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
