
## My additions to build.zig

### Additions related to sqlite-zig vendored in the src/vendor/sqlite-zig/ folder

* lines 17 - 31
* line 119
* lines 165 - 166

### Additions related to my record module in the src/@This/deps/record/ folder

* lines 53 - 57
* line 75
* line 118
* 162

### Additions related to my store module in the src/@This/deps/store/ folder

* lines 114 - 121
* line 130
* line 163

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
 53 ⎥     // my deps/record/ module.
 54 ⎥     const record_mod = b.addModule("record", .{
 55 ⎥         .source_file = .{ .path = "src/@This/deps/record/api.zig" },
 56 ⎥         .dependencies = &.{},
 57 ⎥     });
 58 ⎥ 
 59 ⎥     // deps/ modules.
 60 ⎥     const counter_mod = b.addModule("counter", .{
 61 ⎥         .source_file = .{ .path = "src/@This/deps/counter/api.zig" },
 62 ⎥         .dependencies = &.{},
 63 ⎥     });
 64 ⎥     const closedownjobs_mod = b.addModule("closedownjobs", .{
 65 ⎥         .source_file = .{ .path = "src/@This/deps/closedownjobs/api.zig" },
 66 ⎥         .dependencies = &.{
 67 ⎥             .{ .name = "counter", .module = counter_mod },
 68 ⎥         },
 69 ⎥     });
 70 ⎥     const message_mod = b.addModule("message", .{
 71 ⎥         .source_file = .{ .path = "src/@This/deps/message/api.zig" },
 72 ⎥         .dependencies = &.{
 73 ⎥             .{ .name = "counter", .module = counter_mod },
 74 ⎥             .{ .name = "closedownjobs", .module = closedownjobs_mod },
 75 ⎥             .{ .name = "record", .module = record_mod },
 76 ⎥         },
 77 ⎥     });
 78 ⎥     const channel_mod = b.addModule("channel", .{
 79 ⎥         .source_file = .{ .path = "src/@This/deps/channel/api.zig" },
 80 ⎥         .dependencies = &.{
 81 ⎥             .{ .name = "message", .module = message_mod },
 82 ⎥         },
 83 ⎥     });
 84 ⎥     const framers_mod = b.addModule("framers", .{
 85 ⎥         .source_file = .{ .path = "src/@This/deps/framers/api.zig" },
 86 ⎥         .dependencies = &.{},
 87 ⎥     });
 88 ⎥     const lock_mod = b.addModule("lock", .{
 89 ⎥         .source_file = .{ .path = "src/@This/deps/lock/api.zig" },
 90 ⎥         .dependencies = &.{},
 91 ⎥     });
 92 ⎥     const modal_params_mod = b.addModule("modal_params", .{
 93 ⎥         .source_file = .{ .path = "src/@This/deps/modal_params/api.zig" },
 94 ⎥         .dependencies = &.{
 95 ⎥             .{ .name = "closedownjobs", .module = closedownjobs_mod },
 96 ⎥         },
 97 ⎥     });
 98 ⎥     const closer_mod = b.addModule("closer", .{
 99 ⎥         .source_file = .{ .path = "src/@This/deps/closer/api.zig" },
100 ⎥         .dependencies = &.{
101 ⎥             .{ .name = "lock", .module = lock_mod },
102 ⎥             .{ .name = "framers", .module = framers_mod },
103 ⎥             .{ .name = "closedownjobs", .module = closedownjobs_mod },
104 ⎥             .{ .name = "modal_params", .module = modal_params_mod },
105 ⎥         },
106 ⎥     });
107 ⎥     const widget_mod = b.addModule("widget", .{
108 ⎥         .source_file = .{ .path = "src/@This/deps/widget/api.zig" },
109 ⎥         .dependencies = &.{
110 ⎥             .{ .name = "dvui", .module = dvui_mod },
111 ⎥         },
112 ⎥     });
113 ⎥ 
114 ⎥     // my deps/store/ module.
115 ⎥     const store_mod = b.addModule("store", .{
116 ⎥         .source_file = .{ .path = "src/@This/deps/store/api.zig" },
117 ⎥         .dependencies = &.{
118 ⎥             .{ .name = "record", .module = record_mod },
119 ⎥             .{ .name = "sqlite", .module = sqlite_mod },
120 ⎥         },
121 ⎥     });
122 ⎥     const startup_mod = b.addModule("startup", .{
123 ⎥         .source_file = .{ .path = "src/@This/deps/startup/api.zig" },
124 ⎥         .dependencies = &.{
125 ⎥             .{ .name = "channel", .module = channel_mod },
126 ⎥             .{ .name = "closedownjobs", .module = closedownjobs_mod },
127 ⎥             .{ .name = "framers", .module = framers_mod },
128 ⎥             .{ .name = "modal_params", .module = modal_params_mod },
129 ⎥             .{ .name = "dvui", .module = dvui_mod },
130 ⎥             .{ .name = "store", .module = store_mod },
131 ⎥         },
132 ⎥     });
133 ⎥ 
134 ⎥     const examples = [_][]const u8{
135 ⎥         "standalone-sdl",
136 ⎥         // "ontop-sdl",
137 ⎥     };
138 ⎥ 
139 ⎥     inline for (examples) |ex| {
140 ⎥         const exe = b.addExecutable(.{
141 ⎥             .name = ex,
142 ⎥             .root_source_file = .{ .path = ex ++ ".zig" },
143 ⎥             .target = target,
144 ⎥             .optimize = optimize,
145 ⎥         });
146 ⎥ 
147 ⎥         exe.addModule("dvui", dvui_mod);
148 ⎥         exe.addModule("SDLBackend", sdl_mod);
149 ⎥ 
150 ⎥         // deps modules.
151 ⎥         exe.addModule("closer", closer_mod);
152 ⎥         exe.addModule("closedownjobs", closedownjobs_mod);
153 ⎥         exe.addModule("channel", channel_mod);
154 ⎥         exe.addModule("lock", lock_mod);
155 ⎥         exe.addModule("framers", framers_mod);
156 ⎥         exe.addModule("message", message_mod);
157 ⎥         exe.addModule("modal_params", modal_params_mod);
158 ⎥         exe.addModule("startup", startup_mod);
159 ⎥         exe.addModule("widget", widget_mod);
160 ⎥ 
161 ⎥         // my deps modules.
162 ⎥         exe.addModule("record", record_mod);
163 ⎥         exe.addModule("store", store_mod);
164 ⎥ 
165 ⎥         // links the bundled sqlite3, so leave this out if you link the system one
166 ⎥         exe.linkLibrary(sqlite_lib);
167 ⎥ 
168 ⎥         exe.linkLibrary(lib_bundle);
169 ⎥         add_include_paths(b, exe);
170 ⎥ 
171 ⎥         const compile_step = b.step(ex, "Compile " ++ ex);
172 ⎥         compile_step.dependOn(&b.addInstallArtifact(exe, .{}).step);
173 ⎥         b.getInstallStep().dependOn(compile_step);
174 ⎥ 
175 ⎥         const run_cmd = b.addRunArtifact(exe);
176 ⎥         run_cmd.step.dependOn(compile_step);
177 ⎥ 
178 ⎥         const run_step = b.step("run-" ++ ex, "Run " ++ ex);
179 ⎥         run_step.dependOn(&run_cmd.step);
180 ⎥     }
181 ⎥ 
182 ⎥     // sdl test
183 ⎥     //{
184 ⎥     //const exe = b.addExecutable(.{
185 ⎥     //.name = "sdl-test",
186 ⎥     //.root_source_file = .{ .path = "sdl-test.zig" },
187 ⎥     //.target = target,
188 ⎥     //.optimize = optimize,
189 ⎥     //});
190 ⎥ 
191 ⎥     //exe.addModule("dvui", dvui_mod);
192 ⎥     //exe.addModule("SDLBackend", sdl_mod);
193 ⎥ 
194 ⎥     // deps modules.
195 ⎥     //exe.addModule("framers", framers_mod);
196 ⎥     //exe.addModule("message", message_mod);
197 ⎥     //exe.addModule("channel", channel_mod);
198 ⎥     //exe.addModule("lock", lock_mod);
199 ⎥     //exe.addModule("modal_params", modal_params_mod);
200 ⎥     //exe.addModule("widget", widget_mod);
201 ⎥ 
202 ⎥     //exe.linkLibrary(lib_bundle);
203 ⎥     //add_include_paths(b, exe);
204 ⎥ 
205 ⎥     //const compile_step = b.step("compile-sdl-test", "Compile the SDL test");
206 ⎥     //compile_step.dependOn(&b.addInstallArtifact(exe, .{}).step);
207 ⎥     //b.getInstallStep().dependOn(compile_step);
208 ⎥ 
209 ⎥     //const run_cmd = b.addRunArtifact(exe);
210 ⎥     //run_cmd.step.dependOn(compile_step);
211 ⎥ 
212 ⎥     //const run_step = b.step("sdl-test", "Run the SDL test");
213 ⎥     //run_step.dependOn(&run_cmd.step);
214 ⎥     //}
215 ⎥ }
216 ⎥ 
217 ⎥ pub fn link_deps(b: *std.Build, exe: *std.Build.Step.Compile) void {
218 ⎥     // TODO: remove this part about freetype (pulling it from the dvui_dep
219 ⎥     // sub-builder) once https://github.com/ziglang/zig/pull/14731 lands
220 ⎥     const freetype_dep = b.dependency("freetype", .{
221 ⎥         .target = exe.target,
222 ⎥         .optimize = exe.optimize,
223 ⎥     });
224 ⎥     exe.linkLibrary(freetype_dep.artifact("freetype"));
225 ⎥ 
226 ⎥     // TODO: remove this part about stb_image once either:
227 ⎥     // - zig can successfully cimport stb_image.h
228 ⎥     // - zig can have a module depend on a c file
229 ⎥     const stbi_dep = b.dependency("stb_image", .{
230 ⎥         .target = exe.target,
231 ⎥         .optimize = exe.optimize,
232 ⎥     });
233 ⎥     exe.linkLibrary(stbi_dep.artifact("stb_image"));
234 ⎥ 
235 ⎥     exe.linkLibC();
236 ⎥ 
237 ⎥     if (exe.target.isWindows()) {
238 ⎥         const sdl_dep = b.dependency("sdl", .{
239 ⎥             .target = exe.target,
240 ⎥             .optimize = exe.optimize,
241 ⎥         });
242 ⎥         exe.linkLibrary(sdl_dep.artifact("SDL2"));
243 ⎥ 
244 ⎥         exe.linkSystemLibrary("setupapi");
245 ⎥         exe.linkSystemLibrary("winmm");
246 ⎥         exe.linkSystemLibrary("gdi32");
247 ⎥         exe.linkSystemLibrary("imm32");
248 ⎥         exe.linkSystemLibrary("version");
249 ⎥         exe.linkSystemLibrary("oleaut32");
250 ⎥         exe.linkSystemLibrary("ole32");
251 ⎥     } else {
252 ⎥         if (exe.target.isDarwin()) {
253 ⎥             exe.linkSystemLibrary("z");
254 ⎥             exe.linkSystemLibrary("bz2");
255 ⎥             exe.linkSystemLibrary("iconv");
256 ⎥             exe.linkFramework("AppKit");
257 ⎥             exe.linkFramework("AudioToolbox");
258 ⎥             exe.linkFramework("Carbon");
259 ⎥             exe.linkFramework("Cocoa");
260 ⎥             exe.linkFramework("CoreAudio");
261 ⎥             exe.linkFramework("CoreFoundation");
262 ⎥             exe.linkFramework("CoreGraphics");
263 ⎥             exe.linkFramework("CoreHaptics");
264 ⎥             exe.linkFramework("CoreVideo");
265 ⎥             exe.linkFramework("ForceFeedback");
266 ⎥             exe.linkFramework("GameController");
267 ⎥             exe.linkFramework("IOKit");
268 ⎥             exe.linkFramework("Metal");
269 ⎥         }
270 ⎥ 
271 ⎥         exe.linkSystemLibrary("SDL2");
272 ⎥         //exe.addIncludePath(.{.path = "/Users/dvanderson/SDL2-2.24.1/include"});
273 ⎥         //exe.addObjectFile(.{.path = "/Users/dvanderson/SDL2-2.24.1/build/.libs/libSDL2.a"});
274 ⎥     }
275 ⎥ }
276 ⎥ 
277 ⎥ const build_runner = @import("root");
278 ⎥ const deps = build_runner.dependencies;
279 ⎥ 
280 ⎥ pub fn get_dependency_build_root(dep_prefix: []const u8, name: []const u8) []const u8 {
281 ⎥     inline for (@typeInfo(deps.imports).Struct.decls) |decl| {
282 ⎥         if (std.mem.startsWith(u8, decl.name, dep_prefix) and
283 ⎥             std.mem.endsWith(u8, decl.name, name) and
284 ⎥             decl.name.len == dep_prefix.len + name.len)
285 ⎥         {
286 ⎥             return @field(deps.build_root, decl.name);
287 ⎥         }
288 ⎥     }
289 ⎥ 
290 ⎥     std.debug.print("no dependency named '{s}'\n", .{name});
291 ⎥     std.process.exit(1);
292 ⎥ }
293 ⎥ 
294 ⎥ /// prefix: library prefix. e.g. "dvui."
295 ⎥ pub fn add_include_paths(b: *std.Build, exe: *std.Build.CompileStep) void {
296 ⎥     exe.addIncludePath(.{ .path = b.fmt("{s}{s}", .{ get_dependency_build_root(b.dep_prefix, "freetype"), "/include" }) });
297 ⎥     exe.addIncludePath(.{ .path = b.fmt("{s}{s}", .{ get_dependency_build_root(b.dep_prefix, "stb_image"), "/include" }) });
298 ⎥ }
299 ⎥ 
```
