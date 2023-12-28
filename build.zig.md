
## My additions to build.zig

### Additions related to sqlite-zig vendored in the src/vendor/sqlite-zig/ folder

* lines 17 - 31
* line 67
* lines 127 - 128

### Additions related to known-folders vendored in the src/vendor/known-folders/ folder

* lines 53 - 56
* line 115

### Additions related to my record module in the src/@This/deps/record/ folder

* lines 59 - 62
* line 66
* line 118

### Additions related to my store module in the src/@This/deps/store/ folder

* lines 63 - 69
* line 119

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ const Pkg = std.build.Pkg;
  3 ⎥ const Compile = std.Build.Step.Compile;
  4 ⎥ 
  5 ⎥ const Packages = struct {
  6 ⎥     // Declared here because submodule may not be cloned at the time build.zig runs.
  7 ⎥     const zmath = std.build.Pkg{
  8 ⎥         .name = "zmath",
  9 ⎥         .source = .{ .path = "libs/zmath/src/zmath.zig" },
 10 ⎥     };
 11 ⎥ };
 12 ⎥ 
 13 ⎥ pub fn build(b: *std.build.Builder) !void {
 14 ⎥     const target = b.standardTargetOptions(.{});
 15 ⎥     const optimize = b.standardOptimizeOption(.{});
 16 ⎥ 
 17 ⎥     // sqlite
 18 ⎥     const sqlite_mod = b.addModule("sqlite3", .{
 19 ⎥         .source_file = .{ .path = "src/vendor/sqlite-zig/src/sqlite3.zig" },
 20 ⎥     });
 21 ⎥     const sqlite_lib = b.addStaticLibrary(.{
 22 ⎥         .name = "sqlite3",
 23 ⎥         .target = target,
 24 ⎥         .optimize = optimize,
 25 ⎥     });
 26 ⎥     sqlite_lib.addCSourceFile(.{
 27 ⎥         .file = .{ .path = "src/vendor/sqlite-zig/src/sqlite3.c" },
 28 ⎥         .flags = &.{},
 29 ⎥     });
 30 ⎥     sqlite_lib.linkLibC();
 31 ⎥     b.installArtifact(sqlite_lib);
 32 ⎥ 
 33 ⎥     const lib_bundle = b.addStaticLibrary(.{
 34 ⎥         .name = "dvui_libs",
 35 ⎥         .target = target,
 36 ⎥         .optimize = optimize,
 37 ⎥         .link_libc = true,
 38 ⎥     });
 39 ⎥     link_deps(b, lib_bundle);
 40 ⎥     b.installArtifact(lib_bundle);
 41 ⎥ 
 42 ⎥     const dvui_mod = b.addModule("dvui", .{
 43 ⎥         .source_file = .{ .path = "src/vendor/dvui/src/dvui.zig" },
 44 ⎥         .dependencies = &.{},
 45 ⎥     });
 46 ⎥     const sdl_mod = b.addModule("SDLBackend", .{
 47 ⎥         .source_file = .{ .path = "src/vendor/dvui/src/backends/SDLBackend.zig" },
 48 ⎥         .dependencies = &.{
 49 ⎥             .{ .name = "dvui", .module = dvui_mod },
 50 ⎥         },
 51 ⎥     });
 52 ⎥ 
 53 ⎥     // vendor/known-folders/
 54 ⎥     const known_folders_mod = b.addModule("known-folders", .{
 55 ⎥         .source_file = .{ .path = "src/vendor/known-folders/known-folders.zig" },
 56 ⎥     });
 57 ⎥ 
 58 ⎥     // deps/ modules.
 59 ⎥     const record_mod = b.addModule("record", .{
 60 ⎥         .source_file = .{ .path = "src/@This/deps/record/api.zig" },
 61 ⎥         .dependencies = &.{},
 62 ⎥     });
 63 ⎥     const store_mod = b.addModule("store", .{
 64 ⎥         .source_file = .{ .path = "src/@This/deps/store/api.zig" },
 65 ⎥         .dependencies = &.{
 66 ⎥             .{ .name = "record", .module = record_mod },
 67 ⎥             .{ .name = "sqlite", .module = sqlite_mod },
 68 ⎥         },
 69 ⎥     });
 70 ⎥     const message_mod = b.addModule("message", .{
 71 ⎥         .source_file = .{ .path = "src/@This/deps/message/api.zig" },
 72 ⎥         .dependencies = &.{},
 73 ⎥     });
 74 ⎥     const channel_mod = b.addModule("channel", .{
 75 ⎥         .source_file = .{ .path = "src/@This/deps/channel/api.zig" },
 76 ⎥         .dependencies = &.{
 77 ⎥             .{ .name = "message", .module = message_mod },
 78 ⎥         },
 79 ⎥     });
 80 ⎥     const framers_mod = b.addModule("framers", .{
 81 ⎥         .source_file = .{ .path = "src/@This/deps/framers/api.zig" },
 82 ⎥         .dependencies = &.{},
 83 ⎥     });
 84 ⎥     const lock_mod = b.addModule("lock", .{
 85 ⎥         .source_file = .{ .path = "src/@This/deps/lock/api.zig" },
 86 ⎥         .dependencies = &.{},
 87 ⎥     });
 88 ⎥     const modal_params_mod = b.addModule("modal_params", .{
 89 ⎥         .source_file = .{ .path = "src/@This/deps/modal_params/api.zig" },
 90 ⎥         .dependencies = &.{},
 91 ⎥     });
 92 ⎥     const widget_mod = b.addModule("widget", .{
 93 ⎥         .source_file = .{ .path = "src/@This/deps/widget/api.zig" },
 94 ⎥         .dependencies = &.{
 95 ⎥             .{ .name = "dvui", .module = dvui_mod },
 96 ⎥         },
 97 ⎥     });
 98 ⎥ 
 99 ⎥     const examples = [_][]const u8{
100 ⎥         "standalone-sdl",
101 ⎥         // "ontop-sdl",
102 ⎥     };
103 ⎥ 
104 ⎥     inline for (examples) |ex| {
105 ⎥         const exe = b.addExecutable(.{
106 ⎥             .name = ex,
107 ⎥             .root_source_file = .{ .path = ex ++ ".zig" },
108 ⎥             .target = target,
109 ⎥             .optimize = optimize,
110 ⎥         });
111 ⎥ 
112 ⎥         exe.addModule("dvui", dvui_mod);
113 ⎥         exe.addModule("SDLBackend", sdl_mod);
114 ⎥         exe.addModule("sqlite", sqlite_mod);
115 ⎥         exe.addModule("known-folders", known_folders_mod);
116 ⎥ 
117 ⎥         // deps modules.
118 ⎥         exe.addModule("record", record_mod);
119 ⎥         exe.addModule("store", store_mod);
120 ⎥         exe.addModule("framers", framers_mod);
121 ⎥         exe.addModule("message", message_mod);
122 ⎥         exe.addModule("channel", channel_mod);
123 ⎥         exe.addModule("lock", lock_mod);
124 ⎥         exe.addModule("modal_params", modal_params_mod);
125 ⎥         exe.addModule("widget", widget_mod);
126 ⎥ 
127 ⎥         // links the bundled sqlite3, so leave this out if you link the system one
128 ⎥         exe.linkLibrary(sqlite_lib);
129 ⎥         exe.linkLibrary(lib_bundle);
130 ⎥         add_include_paths(b, exe);
131 ⎥ 
132 ⎥         const compile_step = b.step(ex, "Compile " ++ ex);
133 ⎥         compile_step.dependOn(&b.addInstallArtifact(exe, .{}).step);
134 ⎥         b.getInstallStep().dependOn(compile_step);
135 ⎥ 
136 ⎥         const run_cmd = b.addRunArtifact(exe);
137 ⎥         run_cmd.step.dependOn(compile_step);
138 ⎥ 
139 ⎥         const run_step = b.step("run-" ++ ex, "Run " ++ ex);
140 ⎥         run_step.dependOn(&run_cmd.step);
141 ⎥     }
142 ⎥ 
143 ⎥     // sdl test
144 ⎥     //{
145 ⎥     //const exe = b.addExecutable(.{
146 ⎥     //.name = "sdl-test",
147 ⎥     //.root_source_file = .{ .path = "sdl-test.zig" },
148 ⎥     //.target = target,
149 ⎥     //.optimize = optimize,
150 ⎥     //});
151 ⎥ 
152 ⎥     //exe.addModule("dvui", dvui_mod);
153 ⎥     //exe.addModule("SDLBackend", sdl_mod);
154 ⎥ 
155 ⎥     // deps modules.
156 ⎥     //exe.addModule("framers", framers_mod);
157 ⎥     //exe.addModule("message", message_mod);
158 ⎥     //exe.addModule("channel", channel_mod);
159 ⎥     //exe.addModule("lock", lock_mod);
160 ⎥     //exe.addModule("modal_params", modal_params_mod);
161 ⎥     //exe.addModule("widget", widget_mod);
162 ⎥ 
163 ⎥     //exe.linkLibrary(lib_bundle);
164 ⎥     //add_include_paths(b, exe);
165 ⎥ 
166 ⎥     //const compile_step = b.step("compile-sdl-test", "Compile the SDL test");
167 ⎥     //compile_step.dependOn(&b.addInstallArtifact(exe, .{}).step);
168 ⎥     //b.getInstallStep().dependOn(compile_step);
169 ⎥ 
170 ⎥     //const run_cmd = b.addRunArtifact(exe);
171 ⎥     //run_cmd.step.dependOn(compile_step);
172 ⎥ 
173 ⎥     //const run_step = b.step("sdl-test", "Run the SDL test");
174 ⎥     //run_step.dependOn(&run_cmd.step);
175 ⎥     //}
176 ⎥ }
177 ⎥ 
178 ⎥ pub fn link_deps(b: *std.Build, exe: *std.Build.Step.Compile) void {
179 ⎥     // TODO: remove this part about freetype (pulling it from the dvui_dep
180 ⎥     // sub-builder) once https://github.com/ziglang/zig/pull/14731 lands
181 ⎥     const freetype_dep = b.dependency("freetype", .{
182 ⎥         .target = exe.target,
183 ⎥         .optimize = exe.optimize,
184 ⎥     });
185 ⎥     exe.linkLibrary(freetype_dep.artifact("freetype"));
186 ⎥ 
187 ⎥     // TODO: remove this part about stb_image once either:
188 ⎥     // - zig can successfully cimport stb_image.h
189 ⎥     // - zig can have a module depend on a c file
190 ⎥     const stbi_dep = b.dependency("stb_image", .{
191 ⎥         .target = exe.target,
192 ⎥         .optimize = exe.optimize,
193 ⎥     });
194 ⎥     exe.linkLibrary(stbi_dep.artifact("stb_image"));
195 ⎥ 
196 ⎥     exe.linkLibC();
197 ⎥ 
198 ⎥     if (exe.target.isWindows()) {
199 ⎥         const sdl_dep = b.dependency("sdl", .{
200 ⎥             .target = exe.target,
201 ⎥             .optimize = exe.optimize,
202 ⎥         });
203 ⎥         exe.linkLibrary(sdl_dep.artifact("SDL2"));
204 ⎥ 
205 ⎥         exe.linkSystemLibrary("setupapi");
206 ⎥         exe.linkSystemLibrary("winmm");
207 ⎥         exe.linkSystemLibrary("gdi32");
208 ⎥         exe.linkSystemLibrary("imm32");
209 ⎥         exe.linkSystemLibrary("version");
210 ⎥         exe.linkSystemLibrary("oleaut32");
211 ⎥         exe.linkSystemLibrary("ole32");
212 ⎥     } else {
213 ⎥         if (exe.target.isDarwin()) {
214 ⎥             exe.linkSystemLibrary("z");
215 ⎥             exe.linkSystemLibrary("bz2");
216 ⎥             exe.linkSystemLibrary("iconv");
217 ⎥             exe.linkFramework("AppKit");
218 ⎥             exe.linkFramework("AudioToolbox");
219 ⎥             exe.linkFramework("Carbon");
220 ⎥             exe.linkFramework("Cocoa");
221 ⎥             exe.linkFramework("CoreAudio");
222 ⎥             exe.linkFramework("CoreFoundation");
223 ⎥             exe.linkFramework("CoreGraphics");
224 ⎥             exe.linkFramework("CoreHaptics");
225 ⎥             exe.linkFramework("CoreVideo");
226 ⎥             exe.linkFramework("ForceFeedback");
227 ⎥             exe.linkFramework("GameController");
228 ⎥             exe.linkFramework("IOKit");
229 ⎥             exe.linkFramework("Metal");
230 ⎥         }
231 ⎥ 
232 ⎥         exe.linkSystemLibrary("SDL2");
233 ⎥         //exe.addIncludePath(.{.path = "/Users/dvanderson/SDL2-2.24.1/include"});
234 ⎥         //exe.addObjectFile(.{.path = "/Users/dvanderson/SDL2-2.24.1/build/.libs/libSDL2.a"});
235 ⎥     }
236 ⎥ }
237 ⎥ 
238 ⎥ const build_runner = @import("root");
239 ⎥ const deps = build_runner.dependencies;
240 ⎥ 
241 ⎥ pub fn get_dependency_build_root(dep_prefix: []const u8, name: []const u8) []const u8 {
242 ⎥     inline for (@typeInfo(deps.imports).Struct.decls) |decl| {
243 ⎥         if (std.mem.startsWith(u8, decl.name, dep_prefix) and
244 ⎥             std.mem.endsWith(u8, decl.name, name) and
245 ⎥             decl.name.len == dep_prefix.len + name.len)
246 ⎥         {
247 ⎥             return @field(deps.build_root, decl.name);
248 ⎥         }
249 ⎥     }
250 ⎥ 
251 ⎥     std.debug.print("no dependency named '{s}'\n", .{name});
252 ⎥     std.process.exit(1);
253 ⎥ }
254 ⎥ 
255 ⎥ /// prefix: library prefix. e.g. "dvui."
256 ⎥ pub fn add_include_paths(b: *std.Build, exe: *std.Build.CompileStep) void {
257 ⎥     exe.addIncludePath(.{ .path = b.fmt("{s}{s}", .{ get_dependency_build_root(b.dep_prefix, "freetype"), "/include" }) });
258 ⎥     exe.addIncludePath(.{ .path = b.fmt("{s}{s}", .{ get_dependency_build_root(b.dep_prefix, "stb_image"), "/include" }) });
259 ⎥ }
260 ⎥ 
```
