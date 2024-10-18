const std = @import("std");
const fmt = std.fmt;

pub const Template = struct {
    allocator: std.mem.Allocator,
    app_name: []const u8,
    use_messenger: bool,

    // The caller owns the returned value.
    pub fn init(allocator: std.mem.Allocator, app_name: []const u8, use_messenger: bool) !*Template {
        var data: *Template = try allocator.create(Template);
        data.app_name = try allocator.alloc(u8, app_name.len);
        errdefer {
            allocator.destroy(data);
        }
        @memcpy(@constCast(data.app_name), app_name);
        data.allocator = allocator;
        data.use_messenger = use_messenger;
        return data;
    }

    pub fn deinit(self: *Template) void {
        self.allocator.free(self.app_name);
        self.allocator.destroy(self);
    }

    // The caller owns the returned value.
    pub fn content(self: *Template) ![]const u8 {
        var lines = std.ArrayList(u8).init(self.allocator);
        defer lines.deinit();
        var line: []u8 = undefined;

        try lines.appendSlice(line_1);
        if (self.use_messenger) {
            try lines.appendSlice(line_1_use_messenger);
        }

        try lines.appendSlice(line_2);
        if (self.use_messenger) {
            try lines.appendSlice(line_2_use_messenger);
        }

        try lines.appendSlice(line_3);
        if (self.use_messenger) {
            try lines.appendSlice(line_3_use_messenger);
        }

        try lines.appendSlice(line_4);
        if (self.use_messenger) {
            try lines.appendSlice(line_4_use_messenger);
        }

        try lines.appendSlice(line_5);
        if (self.use_messenger) {
            try lines.appendSlice(line_5_use_messenger);
        }

        try lines.appendSlice(line_6);
        if (self.use_messenger) {
            try lines.appendSlice(line_6_use_messenger);
        }

        try lines.appendSlice(line_7);
        if (self.use_messenger) {
            try lines.appendSlice(line_7_use_messenger);
        }

        {
            line = try fmt.allocPrint(self.allocator, line_8_f, .{self.app_name});
            defer self.allocator.free(line);
            try lines.appendSlice(line);
        }
        if (self.use_messenger) {
            try lines.appendSlice(line_8_use_messenger);
        }

        try lines.appendSlice(line_9);
        if (self.use_messenger) {
            try lines.appendSlice(line_9_use_messenger);
        }

        try lines.appendSlice(line_10);

        const temp: []const u8 = try lines.toOwnedSlice();
        line = try self.allocator.alloc(u8, temp.len);
        @memcpy(line, temp);
        return line;
    }
};

const line_1: []const u8 =
    \\const std = @import("std");
    \\
    \\pub fn build(b: *std.Build) void {
    \\    const target = b.standardTargetOptions(.{});
    \\    const optimize = b.standardOptimizeOption(.{});
    \\
    \\    const dvui_dep = b.dependency("dvui", .{ .target = target, .optimize = optimize });
    \\
    \\    // Framework modules.
    \\
;

const line_1_use_messenger: []const u8 =
    \\
    \\    // channel_mod. A framework deps/ module.
    \\    const channel_mod = b.addModule(
    \\        "channel",
    \\        .{
    \\            .root_source_file = .{
    \\                .src_path = .{
    \\                    .owner = b,
    \\                    .sub_path = "src/deps/channel/api.zig",
    \\                },
    \\            },
    \\        },
    \\    );
    \\
;

const line_2: []const u8 =
    \\
    \\    // closedownjobs_mod. A framework deps/ module.
    \\    const closedownjobs_mod = b.addModule(
    \\        "closedownjobs",
    \\        .{
    \\            .root_source_file = .{
    \\                .src_path = .{
    \\                    .owner = b,
    \\                    .sub_path = "src/deps/closedownjobs/api.zig",
    \\                },
    \\            },
    \\        },
    \\    );
    \\
    \\    // closer_mod. A framework deps/ module.
    \\    const closer_mod = b.addModule(
    \\        "closer",
    \\        .{
    \\            .root_source_file = .{
    \\                .src_path = .{
    \\                    .owner = b,
    \\                    .sub_path = "src/deps/closer/api.zig",
    \\                },
    \\            },
    \\        },
    \\    );
    \\
    \\    // cont_mod. A framework deps/ module.
    \\    const cont_mod = b.addModule(
    \\        "cont",
    \\        .{
    \\            .root_source_file = .{
    \\                .src_path = .{
    \\                    .owner = b,
    \\                    .sub_path = "src/deps/cont/api.zig",
    \\                },
    \\            },
    \\        },
    \\    );
    \\
    \\    // counter_mod. A framework deps/ module.
    \\    const counter_mod = b.addModule(
    \\        "counter",
    \\        .{
    \\            .root_source_file = .{
    \\                .src_path = .{
    \\                    .owner = b,
    \\                    .sub_path = "src/deps/counter/api.zig",
    \\                },
    \\            },
    \\        },
    \\    );
    \\
    \\    // embed_mod. A framework deps/ module.
    \\    const embed_mod = b.addModule(
    \\        "embed",
    \\        .{
    \\            .root_source_file = .{
    \\                .src_path = .{
    \\                    .owner = b,
    \\                    .sub_path = "src/deps/embed/api.zig",
    \\                },
    \\            },
    \\        },
    \\    );
    \\
    \\    // framers_mod. A framework deps/ module.
    \\    const framers_mod = b.addModule(
    \\        "framers",
    \\        .{
    \\            .root_source_file = .{
    \\                .src_path = .{
    \\                    .owner = b,
    \\                    .sub_path = "src/deps/framers/api.zig",
    \\                },
    \\            },
    \\        },
    \\    );
    \\
    \\    // main_menu_mod. A framework deps/ module.
    \\    const main_menu_mod = b.addModule(
    \\        "main_menu",
    \\        .{
    \\            .root_source_file = .{
    \\                .src_path = .{
    \\                    .owner = b,
    \\                    .sub_path = "src/deps/main_menu/api.zig",
    \\                },
    \\            },
    \\        },
    \\    );
    \\
;

const line_2_use_messenger: []const u8 =
    \\
    \\    // message_mod. A framework deps/ module.
    \\    const message_mod = b.addModule(
    \\        "message",
    \\        .{
    \\            .root_source_file = .{
    \\                .src_path = .{
    \\                    .owner = b,
    \\                    .sub_path = "src/deps/message/api.zig",
    \\                },
    \\            },
    \\        },
    \\    );
    \\
;

const line_3: []const u8 =
    \\
    \\    // modal_params_mod. A framework deps/ module.
    \\    const modal_params_mod = b.addModule(
    \\        "modal_params",
    \\        .{
    \\            .root_source_file = .{
    \\                .src_path = .{
    \\                    .owner = b,
    \\                    .sub_path = "src/deps/modal_params/api.zig",
    \\                },
    \\            },
    \\        },
    \\    );
    \\
    \\    // screen_pointers_mod. A framework frontend/ module.
    \\    const screen_pointers_mod = b.addModule(
    \\        "screen_pointers",
    \\        .{
    \\            .root_source_file = .{
    \\                .src_path = .{
    \\                    .owner = b,
    \\                    .sub_path = "src/frontend/screen_pointers.zig",
    \\                },
    \\            },
    \\        },
    \\    );
    \\
    \\    // startup_mod. A framework deps/ module.
    \\    const startup_mod = b.addModule(
    \\        "startup",
    \\        .{
    \\            .root_source_file = .{
    \\                .src_path = .{
    \\                    .owner = b,
    \\                    .sub_path = "src/deps/startup/api.zig",
    \\                },
    \\            },
    \\        },
    \\    );
    \\
    \\    // widget_mod. A framework deps/ module.
    \\    const widget_mod = b.addModule(
    \\        "widget",
    \\        .{
    \\            .root_source_file = .{
    \\                .src_path = .{
    \\                    .owner = b,
    \\                    .sub_path = "src/deps/widget/api.zig",
    \\                },
    \\            },
    \\        },
    \\    );
    \\
    \\    // Framework module dependencies.
    \\
    \\    // Dependencies for channel_mod. A framework deps/ module.
    \\
;

const line_3_use_messenger: []const u8 =
    \\    channel_mod.addImport("closer", closer_mod);
    \\    channel_mod.addImport("message", message_mod);
    \\
;

const line_4: []const u8 =
    \\
    \\    // Dependencies for closedownjobs_mod. A framework deps/ module.
    \\    closedownjobs_mod.addImport("counter", counter_mod);
    \\
    \\    // Dependencies for closer_mod. A framework deps/ module.
    \\    closer_mod.addImport("closedownjobs", closedownjobs_mod);
    \\    closer_mod.addImport("closer", closer_mod);
    \\    closer_mod.addImport("dvui", dvui_dep.module("dvui"));
    \\    closer_mod.addImport("framers", framers_mod);
    \\    closer_mod.addImport("modal_params", modal_params_mod);
    \\
    \\    // Dependencies for framers_mod. A framework deps/ module.
    \\    framers_mod.addImport("dvui", dvui_dep.module("dvui"));
    \\    framers_mod.addImport("closer", closer_mod);
    \\    framers_mod.addImport("cont", cont_mod);
    \\    framers_mod.addImport("main_menu", main_menu_mod);
    \\    framers_mod.addImport("modal_params", modal_params_mod);
    \\    framers_mod.addImport("startup", startup_mod);
    \\
    \\    // Dependencies from cont_mod. A framwork deps/ module.
    \\    cont_mod.addImport("counter", counter_mod);
    \\
;

const line_4_use_messenger: []const u8 =
    \\
    \\    // Dependencies for message_mod. A framework deps/ module.
    \\    message_mod.addImport("counter", counter_mod);
    \\    message_mod.addImport("closedownjobs", closedownjobs_mod);
    \\    message_mod.addImport("closer", closer_mod);
    \\    message_mod.addImport("framers", framers_mod);
    \\
;

const line_5: []const u8 =
    \\
    \\    // Dependencies for message_mod. A framework deps/ module.
    \\    main_menu_mod.addImport("framers", framers_mod);
    \\
    \\    // Dependencies for modal_params_mod. A framework deps/ module.
    \\    modal_params_mod.addImport("closedownjobs", closedownjobs_mod);
    \\
    \\    // Dependencies for screen_pointers_mod. A framework frontend/ module.
    \\
;

const line_5_use_messenger: []const u8 =
    \\    screen_pointers_mod.addImport("channel", channel_mod);
    \\
;

const line_6: []const u8 =
    \\    screen_pointers_mod.addImport("closedownjobs", closedownjobs_mod);
    \\    screen_pointers_mod.addImport("closer", closer_mod);
    \\    screen_pointers_mod.addImport("cont", cont_mod);
    \\    screen_pointers_mod.addImport("dvui", dvui_dep.module("dvui"));
    \\    screen_pointers_mod.addImport("embed", embed_mod);
    \\    screen_pointers_mod.addImport("framers", framers_mod);
    \\
;

const line_6_use_messenger: []const u8 =
    \\    screen_pointers_mod.addImport("message", message_mod);
    \\
;

const line_7: []const u8 =
    \\    screen_pointers_mod.addImport("main_menu", main_menu_mod);
    \\    screen_pointers_mod.addImport("modal_params", modal_params_mod);
    \\    screen_pointers_mod.addImport("startup", startup_mod);
    \\    screen_pointers_mod.addImport("closer", closer_mod);
    \\    screen_pointers_mod.addImport("widget", widget_mod);
    \\
    \\    // Dependencies for startup_mod. A framework deps/ module.
    \\
;

const line_7_use_messenger: []const u8 =
    \\    startup_mod.addImport("channel", channel_mod);
    \\
;

const line_8_f: []const u8 =
    \\    startup_mod.addImport("closedownjobs", closedownjobs_mod);
    \\    startup_mod.addImport("dvui", dvui_dep.module("dvui"));
    \\    startup_mod.addImport("framers", framers_mod);
    \\    startup_mod.addImport("modal_params", modal_params_mod);
    \\    startup_mod.addImport("closer", closer_mod);
    \\    startup_mod.addImport("screen_pointers", screen_pointers_mod);
    \\
    \\    // Dependencies for widget_mod. A framework deps/ module.
    \\    widget_mod.addImport("closer", closer_mod);
    \\    widget_mod.addImport("cont", cont_mod);
    \\    widget_mod.addImport("dvui", dvui_dep.module("dvui"));
    \\    widget_mod.addImport("framers", framers_mod);
    \\    widget_mod.addImport("startup", startup_mod);
    \\
    \\    const exe = b.addExecutable(.{{
    \\        .name = "{0s}",
    \\        .root_source_file = .{{
    \\            .src_path = .{{
    \\                .owner = b,
    \\                .sub_path = "src/main.zig",
    \\            }},
    \\        }},
    \\        .target = target,
    \\        .optimize = optimize,
    \\    }});
    \\
    \\    exe.root_module.addImport("dvui", dvui_dep.module("dvui"));
    \\    exe.root_module.addImport("SDLBackend", dvui_dep.module("SDLBackend"));
    \\
    \\    // Framework modules.
    \\
;

const line_8_use_messenger: []const u8 =
    \\    exe.root_module.addImport("channel", channel_mod);
    \\
;

const line_9: []const u8 =
    \\    exe.root_module.addImport("closedownjobs", closedownjobs_mod);
    \\    exe.root_module.addImport("closer", closer_mod);
    \\    exe.root_module.addImport("cont", cont_mod);
    \\    exe.root_module.addImport("counter", counter_mod);
    \\    exe.root_module.addImport("embed", embed_mod);
    \\    exe.root_module.addImport("framers", framers_mod);
    \\    exe.root_module.addImport("main_menu", main_menu_mod);
    \\
;

const line_9_use_messenger: []const u8 =
    \\    exe.root_module.addImport("message", message_mod);
    \\
;

const line_10: []const u8 =
    \\    exe.root_module.addImport("modal_params", modal_params_mod);
    \\    exe.root_module.addImport("screen_pointers", screen_pointers_mod);
    \\    exe.root_module.addImport("startup", startup_mod);
    \\    exe.root_module.addImport("widget", widget_mod);
    \\
    \\    // This declares intent for the executable to be installed into the
    \\    // standard location when the user invokes the "install" step (the default
    \\    // step when running `zig build`).
    \\    b.installArtifact(exe);
    \\
    \\    // This *creates* a Run step in the build graph, to be executed when another
    \\    // step is evaluated that depends on it. The next line below will establish
    \\    // such a dependency.
    \\    const run_cmd = b.addRunArtifact(exe);
    \\
    \\    // By making the run step depend on the install step, it will be run from the
    \\    // installation directory rather than directly from within the cache directory.
    \\    // This is not necessary, however, if the application depends on other installed
    \\    // files, this ensures they will be present and in the expected location.
    \\    run_cmd.step.dependOn(b.getInstallStep());
    \\
    \\    // This allows the user to pass arguments to the application in the build
    \\    // command itself, like this: `zig build run -- arg1 arg2 etc`
    \\    if (b.args) |args| {
    \\        run_cmd.addArgs(args);
    \\    }
    \\
    \\    // This creates a build step. It will be visible in the `zig build --help` menu,
    \\    // and can be selected like this: `zig build run`
    \\    // This will evaluate the `run` step rather than the default, which is "install".
    \\    const run_step = b.step("run", "Run the app");
    \\    run_step.dependOn(&run_cmd.step);
    \\
    \\    // Creates a step for unit testing. This only builds the test executable
    \\    // but does not run it.
    \\    const sep_test = b.addTest(.{
    \\        .root_source_file = b.path("src/root.zig"),
    \\        .target = target,
    \\        .optimize = optimize,
    \\    });
    \\
    \\    const run_sep_unit_tests = b.addRunArtifact(sep_test);
    \\
    \\    const exe_unit_tests = b.addTest(.{
    \\        .root_source_file = b.path("src/main.zig"),
    \\        .target = target,
    \\        .optimize = optimize,
    \\    });
    \\
    \\    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    \\
    \\    // Similar to creating the run step earlier, this exposes a `test` step to
    \\    // the `zig build --help` menu, providing a way for the user to request
    \\    // running the unit tests.
    \\    const test_step = b.step("test", "Run unit tests");
    \\    test_step.dependOn(&run_exe_unit_tests.step);
    \\    test_step.dependOn(&run_sep_unit_tests.step);
    \\}
;
