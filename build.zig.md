
## My additions to build.zig

### Additions related to Vincent Rischmann's zig-sqlite package which is vendored in the src/vendor/zig-sqlite/ folder

* lines 33 - 50
* line 213
* lines 231 - 232
* lines 252 - 257

### Additions related to my record module in the src/@This/deps/record/ folder

* lines 134 - 138
* line 169
* line 183
* line 208 - 209
* line 212
* line 249

### Additions related to my store module in the src/@This/deps/store/ folder

* lines 128 - 132
* line 197
* line 211 - 213
* line 250

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ const Pkg = std.build.Pkg;
  3 ⎥ const Compile = std.Build.Step.Compile;
  4 ⎥ 
  5 ⎥ pub fn build(b: *std.build.Builder) !void {
  6 ⎥     const target = b.standardTargetOptions(.{});
  7 ⎥     const optimize = b.standardOptimizeOption(.{});
  8 ⎥ 
  9 ⎥     // VENDOR MODULES.
 10 ⎥ 
 11 ⎥     const lib_bundle = b.addStaticLibrary(.{
 12 ⎥         .name = "dvui_libs",
 13 ⎥         .target = target,
 14 ⎥         .optimize = optimize,
 15 ⎥     });
 16 ⎥     lib_bundle.addCSourceFile(.{ .file = .{ .path = "src/vendor/dvui/src/stb/stb_image_impl.c" }, .flags = &.{} });
 17 ⎥     lib_bundle.addCSourceFile(.{ .file = .{ .path = "src/vendor/dvui/src/stb/stb_truetype_impl.c" }, .flags = &.{} });
 18 ⎥     link_deps(b, lib_bundle);
 19 ⎥     b.installArtifact(lib_bundle);
 20 ⎥ 
 21 ⎥     const dvui_mod = b.addModule("dvui", .{
 22 ⎥         .source_file = .{ .path = "src/vendor/dvui/src/dvui.zig" },
 23 ⎥         .dependencies = &.{},
 24 ⎥     });
 25 ⎥ 
 26 ⎥     const sdl_mod = b.addModule("SDLBackend", .{
 27 ⎥         .source_file = .{ .path = "src/vendor/dvui/src/backends/SDLBackend.zig" },
 28 ⎥         .dependencies = &.{
 29 ⎥             .{ .name = "dvui", .module = dvui_mod },
 30 ⎥         },
 31 ⎥     });
 32 ⎥ 
 33 ⎥     // sqlite
 34 ⎥     const sqlite = b.addStaticLibrary(.{
 35 ⎥         .name = "sqlite",
 36 ⎥         .target = target,
 37 ⎥         .optimize = optimize,
 38 ⎥     });
 39 ⎥     sqlite.addCSourceFile(.{
 40 ⎥         .file = .{ .path = "src/vendor/zig-sqlite/c/sqlite3.c" },
 41 ⎥         .flags = &[_][]const u8{
 42 ⎥             "-std=c99",
 43 ⎥         },
 44 ⎥     });
 45 ⎥     sqlite.addIncludePath(.{ .path = "src/vendor/zig-sqlite/c" });
 46 ⎥     sqlite.linkLibC();
 47 ⎥     const sqlite_mod = b.addModule("sqlite", .{
 48 ⎥         .source_file = .{ .path = "src/vendor/zig-sqlite/sqlite.zig" },
 49 ⎥         .dependencies = &.{},
 50 ⎥     });
 51 ⎥ 
 52 ⎥     // FRAMEWORK MODULES.
 53 ⎥ 
 54 ⎥     // channel_mod. A framework deps/ module.
 55 ⎥     const channel_mod = b.addModule("channel", .{
 56 ⎥         .source_file = .{ .path = "src/@This/deps/channel/api.zig" },
 57 ⎥         .dependencies = &.{},
 58 ⎥     });
 59 ⎥ 
 60 ⎥     // closedownjobs_mod. A framework deps/ module.
 61 ⎥     const closedownjobs_mod = b.addModule("closedownjobs", .{
 62 ⎥         .source_file = .{ .path = "src/@This/deps/closedownjobs/api.zig" },
 63 ⎥         .dependencies = &.{},
 64 ⎥     });
 65 ⎥ 
 66 ⎥     // closer_mod. A framework deps/ module.
 67 ⎥     const closer_mod = b.addModule("closer", .{
 68 ⎥         .source_file = .{ .path = "src/@This/deps/closer/api.zig" },
 69 ⎥         .dependencies = &.{},
 70 ⎥     });
 71 ⎥ 
 72 ⎥     // counter_mod. A framework deps/ module.
 73 ⎥     const counter_mod = b.addModule("counter", .{
 74 ⎥         .source_file = .{ .path = "src/@This/deps/counter/api.zig" },
 75 ⎥         .dependencies = &.{},
 76 ⎥     });
 77 ⎥ 
 78 ⎥     // framers_mod. A framework deps/ module.
 79 ⎥     const framers_mod = b.addModule("framers", .{
 80 ⎥         .source_file = .{ .path = "src/@This/deps/framers/api.zig" },
 81 ⎥         .dependencies = &.{},
 82 ⎥     });
 83 ⎥ 
 84 ⎥     // lock_mod. A framework deps/ module.
 85 ⎥     const lock_mod = b.addModule("lock", .{
 86 ⎥         .source_file = .{ .path = "src/@This/deps/lock/api.zig" },
 87 ⎥         .dependencies = &.{},
 88 ⎥     });
 89 ⎥ 
 90 ⎥     // message_mod. A framework deps/ module.
 91 ⎥     const message_mod = b.addModule("message", .{
 92 ⎥         .source_file = .{ .path = "src/@This/deps/message/api.zig" },
 93 ⎥         .dependencies = &.{},
 94 ⎥     });
 95 ⎥ 
 96 ⎥     // modal_params_mod. A framework deps/ module.
 97 ⎥     const modal_params_mod = b.addModule("modal_params", .{
 98 ⎥         .source_file = .{ .path = "src/@This/deps/modal_params/api.zig" },
 99 ⎥         .dependencies = &.{},
100 ⎥     });
101 ⎥ 
102 ⎥     // screen_pointers_mod. A framework frontend/ module.
103 ⎥     const screen_pointers_mod = b.addModule("screen_pointers", .{
104 ⎥         .source_file = .{ .path = "src/@This/frontend/screen_pointers.zig" },
105 ⎥         .dependencies = &.{},
106 ⎥     });
107 ⎥ 
108 ⎥     // startup_mod. A framework deps/ module.
109 ⎥     const startup_mod = b.addModule("startup", .{
110 ⎥         .source_file = .{ .path = "src/@This/deps/startup/api.zig" },
111 ⎥         .dependencies = &.{},
112 ⎥     });
113 ⎥ 
114 ⎥     // various_mod. A framework deps/ module.
115 ⎥     const various_mod = b.addModule("various", .{
116 ⎥         .source_file = .{ .path = "src/@This/deps/various/api.zig" },
117 ⎥         .dependencies = &.{},
118 ⎥     });
119 ⎥ 
120 ⎥     // widget_mod. A framework deps/ module.
121 ⎥     const widget_mod = b.addModule("widget", .{
122 ⎥         .source_file = .{ .path = "src/@This/deps/widget/api.zig" },
123 ⎥         .dependencies = &.{},
124 ⎥     });
125 ⎥ 
126 ⎥     // My modules.
127 ⎥ 
128 ⎥     // my deps/store/ module.
129 ⎥     const store_mod = b.addModule("store", .{
130 ⎥         .source_file = .{ .path = "src/@This/deps/store/api.zig" },
131 ⎥         .dependencies = &.{},
132 ⎥     });
133 ⎥ 
134 ⎥     // my deps/record/ module.
135 ⎥     const record_mod = b.addModule("record", .{
136 ⎥         .source_file = .{ .path = "src/@This/deps/record/api.zig" },
137 ⎥         .dependencies = &.{},
138 ⎥     });
139 ⎥ 
140 ⎥     // FRAMEWORK MODULE DEPENDENCIES.
141 ⎥ 
142 ⎥     // Dependencies for channel_mod. A framework deps/ module.
143 ⎥     try channel_mod.dependencies.put("message", message_mod);
144 ⎥     try channel_mod.dependencies.put("various", various_mod);
145 ⎥ 
146 ⎥     // Dependencies for closedownjobs_mod. A framework deps/ module.
147 ⎥     try closedownjobs_mod.dependencies.put("counter", counter_mod);
148 ⎥ 
149 ⎥     // Dependencies for closer_mod. A framework deps/ module.
150 ⎥     try closer_mod.dependencies.put("closedownjobs", closedownjobs_mod);
151 ⎥     try closer_mod.dependencies.put("dvui", dvui_mod);
152 ⎥     try closer_mod.dependencies.put("framers", framers_mod);
153 ⎥     try closer_mod.dependencies.put("lock", lock_mod);
154 ⎥     try closer_mod.dependencies.put("modal_params", modal_params_mod);
155 ⎥     try closer_mod.dependencies.put("various", various_mod);
156 ⎥ 
157 ⎥     // Dependencies for framers_mod. A framework deps/ module.
158 ⎥     try framers_mod.dependencies.put("startup", startup_mod);
159 ⎥     try framers_mod.dependencies.put("dvui", dvui_mod);
160 ⎥     try framers_mod.dependencies.put("modal_params", modal_params_mod);
161 ⎥     try framers_mod.dependencies.put("various", various_mod);
162 ⎥     try framers_mod.dependencies.put("lock", lock_mod);
163 ⎥ 
164 ⎥     // Dependencies for message_mod. A framework deps/ module.
165 ⎥     try message_mod.dependencies.put("counter", counter_mod);
166 ⎥     try message_mod.dependencies.put("closedownjobs", closedownjobs_mod);
167 ⎥     try message_mod.dependencies.put("framers", framers_mod);
168 ⎥     try message_mod.dependencies.put("various", various_mod);
169 ⎥     try message_mod.dependencies.put("record", record_mod);
170 ⎥ 
171 ⎥     // Dependencies for modal_params_mod. A framework deps/ module.
172 ⎥     try modal_params_mod.dependencies.put("closedownjobs", closedownjobs_mod);
173 ⎥ 
174 ⎥     // Dependencies for screen_pointers_mod. A framework frontend/ module.
175 ⎥     try screen_pointers_mod.dependencies.put("channel", channel_mod);
176 ⎥     try screen_pointers_mod.dependencies.put("closedownjobs", closedownjobs_mod);
177 ⎥     try screen_pointers_mod.dependencies.put("closer", closer_mod);
178 ⎥     try screen_pointers_mod.dependencies.put("dvui", dvui_mod);
179 ⎥     try screen_pointers_mod.dependencies.put("framers", framers_mod);
180 ⎥     try screen_pointers_mod.dependencies.put("lock", lock_mod);
181 ⎥     try screen_pointers_mod.dependencies.put("message", message_mod);
182 ⎥     try screen_pointers_mod.dependencies.put("modal_params", modal_params_mod);
183 ⎥     try screen_pointers_mod.dependencies.put("record", record_mod);
184 ⎥     try screen_pointers_mod.dependencies.put("screen_pointers", screen_pointers_mod);
185 ⎥     try screen_pointers_mod.dependencies.put("startup", startup_mod);
186 ⎥     try screen_pointers_mod.dependencies.put("various", various_mod);
187 ⎥     try screen_pointers_mod.dependencies.put("widget", widget_mod);
188 ⎥ 
189 ⎥     // Dependencies for startup_mod. A framework deps/ module.
190 ⎥     try startup_mod.dependencies.put("channel", channel_mod);
191 ⎥     try startup_mod.dependencies.put("closedownjobs", closedownjobs_mod);
192 ⎥     try startup_mod.dependencies.put("dvui", dvui_mod);
193 ⎥     try startup_mod.dependencies.put("framers", framers_mod);
194 ⎥     try startup_mod.dependencies.put("modal_params", modal_params_mod);
195 ⎥     try startup_mod.dependencies.put("various", various_mod);
196 ⎥     try startup_mod.dependencies.put("screen_pointers", screen_pointers_mod);
197 ⎥     try startup_mod.dependencies.put("store", store_mod);
198 ⎥ 
199 ⎥     // Dependencies for widget_mod. A framework deps/ module.
200 ⎥     try widget_mod.dependencies.put("dvui", dvui_mod);
201 ⎥     try widget_mod.dependencies.put("lock", lock_mod);
202 ⎥     try widget_mod.dependencies.put("framers", framers_mod);
203 ⎥     try widget_mod.dependencies.put("startup", startup_mod);
204 ⎥     try widget_mod.dependencies.put("various", various_mod);
205 ⎥ 
206 ⎥     // MY MODULES DEPENDENCIES.
207 ⎥ 
208 ⎥     // Dependencies for record_mod. My deps/ module.
209 ⎥     try record_mod.dependencies.put("counter", counter_mod);
210 ⎥ 
211 ⎥     // Dependencies for store_mod. My deps/ module.
212 ⎥     try store_mod.dependencies.put("record", record_mod);
213 ⎥     try store_mod.dependencies.put("sqlite", sqlite_mod);
214 ⎥ 
215 ⎥     const examples = [_][]const u8{
216 ⎥         "standalone-sdl",
217 ⎥     };
218 ⎥ 
219 ⎥     inline for (examples) |ex| {
220 ⎥         const exe = b.addExecutable(.{
221 ⎥             .name = ex,
222 ⎥             .root_source_file = .{ .path = ex ++ ".zig" },
223 ⎥             .target = target,
224 ⎥             .optimize = optimize,
225 ⎥         });
226 ⎥ 
227 ⎥         // vendor/dvui module.
228 ⎥         exe.addModule("dvui", dvui_mod);
229 ⎥         exe.addModule("SDLBackend", sdl_mod);
230 ⎥ 
231 ⎥         // vendor/zig-sqlite/ module.
232 ⎥         exe.addModule("sqlite", sqlite_mod);
233 ⎥ 
234 ⎥         // deps modules.
235 ⎥         exe.addModule("various", various_mod);
236 ⎥         exe.addModule("screen_pointers", screen_pointers_mod);
237 ⎥         exe.addModule("counter", counter_mod);
238 ⎥         exe.addModule("closer", closer_mod);
239 ⎥         exe.addModule("closedownjobs", closedownjobs_mod);
240 ⎥         exe.addModule("channel", channel_mod);
241 ⎥         exe.addModule("lock", lock_mod);
242 ⎥         exe.addModule("framers", framers_mod);
243 ⎥         exe.addModule("message", message_mod);
244 ⎥         exe.addModule("modal_params", modal_params_mod);
245 ⎥         exe.addModule("startup", startup_mod);
246 ⎥         exe.addModule("widget", widget_mod);
247 ⎥ 
248 ⎥         // my deps modules.
249 ⎥         exe.addModule("record", record_mod);
250 ⎥         exe.addModule("store", store_mod);
251 ⎥ 
252 ⎥         // links the bundled sqlite3, so leave this out if you link the system one
253 ⎥         exe.linkLibrary(sqlite);
254 ⎥         exe.addIncludePath(.{ .path = "src/vendor/zig-sqlite/c" });
255 ⎥         // exe.addAnonymousModule("sqlite", .{
256 ⎥         //     .source_file = .{ .path = "src/vendor/zig-sqlite/sqlite.zig" },
257 ⎥         // });
258 ⎥ 
259 ⎥         exe.linkLibrary(lib_bundle);
260 ⎥         add_include_paths(b, exe);
261 ⎥ 
262 ⎥         const compile_step = b.step(ex, "Compile " ++ ex);
263 ⎥         compile_step.dependOn(&b.addInstallArtifact(exe, .{}).step);
264 ⎥         b.getInstallStep().dependOn(compile_step);
265 ⎥ 
266 ⎥         const run_cmd = b.addRunArtifact(exe);
267 ⎥         run_cmd.step.dependOn(compile_step);
268 ⎥ 
269 ⎥         const run_step = b.step("run-" ++ ex, "Run " ++ ex);
270 ⎥         run_step.dependOn(&run_cmd.step);
271 ⎥     }
272 ⎥ }
273 ⎥ 
274 ⎥ pub fn link_deps(b: *std.Build, exe: *std.Build.Step.Compile) void {
275 ⎥     // TODO: remove this part about freetype (pulling it from the dvui_dep
276 ⎥     // sub-builder) once https://github.com/ziglang/zig/pull/14731 lands
277 ⎥     const freetype_dep = b.dependency("freetype", .{
278 ⎥         .target = exe.target,
279 ⎥         .optimize = exe.optimize,
280 ⎥     });
281 ⎥     exe.linkLibrary(freetype_dep.artifact("freetype"));
282 ⎥ 
283 ⎥     if (exe.target.cpu_arch == .wasm32) {
284 ⎥         // nothing
285 ⎥     } else if (exe.target.isWindows()) {
286 ⎥         const sdl_dep = b.dependency("sdl", .{
287 ⎥             .target = exe.target,
288 ⎥             .optimize = exe.optimize,
289 ⎥         });
290 ⎥         exe.linkLibrary(sdl_dep.artifact("SDL2"));
291 ⎥ 
292 ⎥         exe.linkSystemLibrary("setupapi");
293 ⎥         exe.linkSystemLibrary("winmm");
294 ⎥         exe.linkSystemLibrary("gdi32");
295 ⎥         exe.linkSystemLibrary("imm32");
296 ⎥         exe.linkSystemLibrary("version");
297 ⎥         exe.linkSystemLibrary("oleaut32");
298 ⎥         exe.linkSystemLibrary("ole32");
299 ⎥     } else {
300 ⎥         if (exe.target.isDarwin()) {
301 ⎥             exe.linkSystemLibrary("z");
302 ⎥             exe.linkSystemLibrary("bz2");
303 ⎥             exe.linkSystemLibrary("iconv");
304 ⎥             exe.linkFramework("AppKit");
305 ⎥             exe.linkFramework("AudioToolbox");
306 ⎥             exe.linkFramework("Carbon");
307 ⎥             exe.linkFramework("Cocoa");
308 ⎥             exe.linkFramework("CoreAudio");
309 ⎥             exe.linkFramework("CoreFoundation");
310 ⎥             exe.linkFramework("CoreGraphics");
311 ⎥             exe.linkFramework("CoreHaptics");
312 ⎥             exe.linkFramework("CoreVideo");
313 ⎥             exe.linkFramework("ForceFeedback");
314 ⎥             exe.linkFramework("GameController");
315 ⎥             exe.linkFramework("IOKit");
316 ⎥             exe.linkFramework("Metal");
317 ⎥         }
318 ⎥ 
319 ⎥         exe.linkSystemLibrary("SDL2");
320 ⎥         //exe.addIncludePath(.{.path = "/Users/dvanderson/SDL2-2.24.1/include"});
321 ⎥         //exe.addObjectFile(.{.path = "/Users/dvanderson/SDL2-2.24.1/build/.libs/libSDL2.a"});
322 ⎥     }
323 ⎥ }
324 ⎥ 
325 ⎥ const build_runner = @import("root");
326 ⎥ const deps = build_runner.dependencies;
327 ⎥ 
328 ⎥ pub fn get_dependency_build_root(dep_prefix: []const u8, name: []const u8) []const u8 {
329 ⎥     inline for (@typeInfo(deps.imports).Struct.decls) |decl| {
330 ⎥         if (std.mem.startsWith(u8, decl.name, dep_prefix) and
331 ⎥             std.mem.endsWith(u8, decl.name, name) and
332 ⎥             decl.name.len == dep_prefix.len + name.len)
333 ⎥         {
334 ⎥             return @field(deps.build_root, decl.name);
335 ⎥         }
336 ⎥     }
337 ⎥ 
338 ⎥     std.debug.print("no dependency named '{s}'\n", .{name});
339 ⎥     std.process.exit(1);
340 ⎥ }
341 ⎥ 
342 ⎥ /// prefix: library prefix. e.g. "dvui."
343 ⎥ pub fn add_include_paths(b: *std.Build, exe: *std.Build.CompileStep) void {
344 ⎥     exe.addIncludePath(.{ .path = b.fmt("{s}{s}", .{ get_dependency_build_root(b.dep_prefix, "stb_image"), "/include" }) });
345 ⎥     exe.addIncludePath(.{ .path = b.fmt("{s}{s}", .{ get_dependency_build_root(b.dep_prefix, "freetype"), "/include" }) });
346 ⎥     exe.addIncludePath(.{ .path = b.fmt("{s}/src/stb", .{b.build_root.path.?}) });
347 ⎥ }
348 ⎥ 
```
