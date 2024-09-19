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
        .root_source_file = .{
            .src_path = .{
                .owner = b,
                .sub_path = "src/deps/stdout/api.zig",
            },
        },
    });
    const usage_mod = b.addModule("usage", .{
        .root_source_file = .{
            .src_path = .{
                .owner = b,
                .sub_path = "src/deps/usage.zig",
            },
        },
    });
    const warning_mod = b.addModule("warning", .{
        .root_source_file = .{
            .src_path = .{
                .owner = b,
                .sub_path = "src/deps/warning.zig",
            },
        },
    });
    const paths_mod = b.addModule("paths", .{
        .root_source_file = .{
            .src_path = .{
                .owner = b,
                .sub_path = "src/deps/paths/api.zig",
            },
        },
    });
    const filenames_mod = b.addModule("filenames", .{
        .root_source_file = .{
            .src_path = .{
                .owner = b,
                .sub_path = "src/deps/filenames/api.zig",
            },
        },
    });
    const success_mod = b.addModule("success", .{
        .root_source_file = .{
            .src_path = .{
                .owner = b,
                .sub_path = "src/deps/success.zig",
            },
        },
    });
    const slices_mod = b.addModule("slices", .{
        .root_source_file = .{
            .src_path = .{
                .owner = b,
                .sub_path = "src/deps/slices.zig",
            },
        },
    });
    const strings_mod = b.addModule("strings", .{
        .root_source_file = .{
            .src_path = .{
                .owner = b,
                .sub_path = "src/deps/strings.zig",
            },
        },
    });
    const verify_mod = b.addModule("verify", .{
        .root_source_file = .{
            .src_path = .{
                .owner = b,
                .sub_path = "src/deps/verify.zig",
            },
        },
    });

    // src/source/root/src/deps/.
    const source_deps_mod = b.addModule("source_deps", .{
        .root_source_file = .{
            .src_path = .{
                .owner = b,
                .sub_path = "src/source/root/src/deps/framework.zig",
            },
        },
    });

    // source/ module.
    const source_mod = b.addModule("source", .{
        .root_source_file = .{
            .src_path = .{
                .owner = b,
                .sub_path = "src/source/api.zig",
            },
        },
    });

    // Dependencies for filenames_mod
    filenames_mod.addImport("paths", paths_mod);
    filenames_mod.addImport("verify", verify_mod);
    filenames_mod.addImport("verify", verify_mod);

    // Dependencies for success_mod
    success_mod.addImport("paths", paths_mod);
    success_mod.addImport("filenames", filenames_mod);

    verify_mod.addImport("filenames", filenames_mod);
    verify_mod.addImport("strings", strings_mod);

    // verify_mod for verify_mod
    source_deps_mod.addImport("filenames", filenames_mod);
    source_deps_mod.addImport("strings", strings_mod);

    // Dependencies for source_deps_mod
    source_deps_mod.addImport("filenames", filenames_mod);
    source_deps_mod.addImport("paths", paths_mod);
    source_deps_mod.addImport("strings", strings_mod);

    // Dependencies for source_mod.
    source_mod.addImport("stdout", stdout_mod);
    source_mod.addImport("paths", paths_mod);
    source_mod.addImport("filenames", filenames_mod);
    source_mod.addImport("slices", slices_mod);
    source_mod.addImport("strings", strings_mod);
    source_mod.addImport("source_deps", source_deps_mod);

    const exe = b.addExecutable(.{
        .name = "kickzig",
        .root_source_file = .{
            .src_path = .{
                .owner = b,
                .sub_path = "src/main.zig",
            },
        },
        .target = target,
        .optimize = optimize,
    });

    // src/libs/ modules.
    exe.root_module.addImport("stdout", stdout_mod);
    // src/deps/ modules.
    exe.root_module.addImport("usage", usage_mod);
    exe.root_module.addImport("warning", warning_mod);
    exe.root_module.addImport("success", success_mod);
    exe.root_module.addImport("verify", verify_mod);
    // src/source/ module.
    exe.root_module.addImport("source", source_mod);
    // src/source/root/src/deps/.
    exe.root_module.addImport("source_deps", source_deps_mod);
    // src/source/libs/ modules.
    exe.root_module.addImport("paths", paths_mod);
    exe.root_module.addImport("filenames", filenames_mod);
    exe.root_module.addImport("slices", slices_mod);
    exe.root_module.addImport("strings", strings_mod);

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
        .root_source_file = .{
            .src_path = .{
                .owner = b,
                .sub_path = "src/main.zig",
            },
        },
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
