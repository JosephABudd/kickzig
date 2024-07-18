
## dvui

The framework included the dvui dependency in build.zig when it created the file, so I don't have to.

* lines 7 - 10

## My additions to build.zig

I have to include the dependency for

* Kamil Tomšík's fridge (sqlite) dependency in build.zig.zon,
* my record package at src/deps/record/,
* my store package at src/deps/store/.

### Additions related to Kamil Tomšík's fridge (sqlite) package

* lines 11 - 16
* line 277
* lines 312 - 313

### Additions related to my record module in the src/deps/record/ folder

* lines 191 - 202
* line 232
* line 247
* line 272 - 273
* line 276
* line 309

### Additions related to my store module in the src/deps/store/ folder

* lines 178 - 189
* line 261
* line 275 - 277
* line 310

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ 
  3 ⎥ pub fn build(b: *std.Build) void {
  4 ⎥     const target = b.standardTargetOptions(.{});
  5 ⎥     const optimize = b.standardOptimizeOption(.{});
  6 ⎥ 
  7 ⎥     const dvui_dep = b.dependency(
  8 ⎥         "dvui",
  9 ⎥         .{ .target = target, .optimize = optimize },
 10 ⎥     );
 11 ⎥     const sqlite_dep = b.dependency(
 12 ⎥         "fridge",
 13 ⎥         .{
 14 ⎥             .bundle = true,
 15 ⎥         },
 16 ⎥     );
 17 ⎥ 
 18 ⎥     // Framework modules.
 19 ⎥ 
 20 ⎥     // channel_mod. A framework deps/ module.
 21 ⎥     const channel_mod = b.addModule(
 22 ⎥         "channel",
 23 ⎥         .{
 24 ⎥             .root_source_file = .{
 25 ⎥                 .src_path = .{
 26 ⎥                     .owner = b,
 27 ⎥                     .sub_path = "src/deps/channel/api.zig",
 28 ⎥                 },
 29 ⎥             },
 30 ⎥         },
 31 ⎥     );
 32 ⎥ 
 33 ⎥     // closedownjobs_mod. A framework deps/ module.
 34 ⎥     const closedownjobs_mod = b.addModule(
 35 ⎥         "closedownjobs",
 36 ⎥         .{
 37 ⎥             .root_source_file = .{
 38 ⎥                 .src_path = .{
 39 ⎥                     .owner = b,
 40 ⎥                     .sub_path = "src/deps/closedownjobs/api.zig",
 41 ⎥                 },
 42 ⎥             },
 43 ⎥         },
 44 ⎥     );
 45 ⎥ 
 46 ⎥     // closer_mod. A framework deps/ module.
 47 ⎥     const closer_mod = b.addModule(
 48 ⎥         "closer",
 49 ⎥         .{
 50 ⎥             .root_source_file = .{
 51 ⎥                 .src_path = .{
 52 ⎥                     .owner = b,
 53 ⎥                     .sub_path = "src/deps/closer/api.zig",
 54 ⎥                 },
 55 ⎥             },
 56 ⎥         },
 57 ⎥     );
 58 ⎥ 
 59 ⎥     // counter_mod. A framework deps/ module.
 60 ⎥     const counter_mod = b.addModule(
 61 ⎥         "counter",
 62 ⎥         .{
 63 ⎥             .root_source_file = .{
 64 ⎥                 .src_path = .{
 65 ⎥                     .owner = b,
 66 ⎥                     .sub_path = "src/deps/counter/api.zig",
 67 ⎥                 },
 68 ⎥             },
 69 ⎥         },
 70 ⎥     );
 71 ⎥ 
 72 ⎥     // framers_mod. A framework deps/ module.
 73 ⎥     const framers_mod = b.addModule(
 74 ⎥         "framers",
 75 ⎥         .{
 76 ⎥             .root_source_file = .{
 77 ⎥                 .src_path = .{
 78 ⎥                     .owner = b,
 79 ⎥                     .sub_path = "src/deps/framers/api.zig",
 80 ⎥                 },
 81 ⎥             },
 82 ⎥         },
 83 ⎥     );
 84 ⎥ 
 85 ⎥     // lock_mod. A framework deps/ module.
 86 ⎥     const lock_mod = b.addModule(
 87 ⎥         "lock",
 88 ⎥         .{
 89 ⎥             .root_source_file = .{
 90 ⎥                 .src_path = .{
 91 ⎥                     .owner = b,
 92 ⎥                     .sub_path = "src/deps/lock/api.zig",
 93 ⎥                 },
 94 ⎥             },
 95 ⎥         },
 96 ⎥     );
 97 ⎥ 
 98 ⎥     // message_mod. A framework deps/ module.
 99 ⎥     const message_mod = b.addModule(
100 ⎥         "message",
101 ⎥         .{
102 ⎥             .root_source_file = .{
103 ⎥                 .src_path = .{
104 ⎥                     .owner = b,
105 ⎥                     .sub_path = "src/deps/message/api.zig",
106 ⎥                 },
107 ⎥             },
108 ⎥         },
109 ⎥     );
110 ⎥ 
111 ⎥     // modal_params_mod. A framework deps/ module.
112 ⎥     const modal_params_mod = b.addModule(
113 ⎥         "modal_params",
114 ⎥         .{
115 ⎥             .root_source_file = .{
116 ⎥                 .src_path = .{
117 ⎥                     .owner = b,
118 ⎥                     .sub_path = "src/deps/modal_params/api.zig",
119 ⎥                 },
120 ⎥             },
121 ⎥         },
122 ⎥     );
123 ⎥ 
124 ⎥     // screen_pointers_mod. A framework frontend/ module.
125 ⎥     const screen_pointers_mod = b.addModule(
126 ⎥         "screen_pointers",
127 ⎥         .{
128 ⎥             .root_source_file = .{
129 ⎥                 .src_path = .{
130 ⎥                     .owner = b,
131 ⎥                     .sub_path = "src/frontend/screen_pointers.zig",
132 ⎥                 },
133 ⎥             },
134 ⎥         },
135 ⎥     );
136 ⎥ 
137 ⎥     // startup_mod. A framework deps/ module.
138 ⎥     const startup_mod = b.addModule(
139 ⎥         "startup",
140 ⎥         .{
141 ⎥             .root_source_file = .{
142 ⎥                 .src_path = .{
143 ⎥                     .owner = b,
144 ⎥                     .sub_path = "src/deps/startup/api.zig",
145 ⎥                 },
146 ⎥             },
147 ⎥         },
148 ⎥     );
149 ⎥ 
150 ⎥     // various_mod. A framework deps/ module.
151 ⎥     const various_mod = b.addModule(
152 ⎥         "various",
153 ⎥         .{
154 ⎥             .root_source_file = .{
155 ⎥                 .src_path = .{
156 ⎥                     .owner = b,
157 ⎥                     .sub_path = "src/deps/various/api.zig",
158 ⎥                 },
159 ⎥             },
160 ⎥         },
161 ⎥     );
162 ⎥ 
163 ⎥     // widget_mod. A framework deps/ module.
164 ⎥     const widget_mod = b.addModule(
165 ⎥         "widget",
166 ⎥         .{
167 ⎥             .root_source_file = .{
168 ⎥                 .src_path = .{
169 ⎥                     .owner = b,
170 ⎥                     .sub_path = "src/deps/widget/api.zig",
171 ⎥                 },
172 ⎥             },
173 ⎥         },
174 ⎥     );
175 ⎥ 
176 ⎥     // My modules.
177 ⎥ 
178 ⎥     // my deps/store/ module.
179 ⎥     const store_mod = b.addModule(
180 ⎥         "store",
181 ⎥         .{
182 ⎥             .root_source_file = .{
183 ⎥                 .src_path = .{
184 ⎥                     .owner = b,
185 ⎥                     .sub_path = "src/deps/store/api.zig",
186 ⎥                 },
187 ⎥             },
188 ⎥         },
189 ⎥     );
190 ⎥ 
191 ⎥     // my deps/record/ module.
192 ⎥     const record_mod = b.addModule(
193 ⎥         "record",
194 ⎥         .{
195 ⎥             .root_source_file = .{
196 ⎥                 .src_path = .{
197 ⎥                     .owner = b,
198 ⎥                     .sub_path = "src/deps/record/api.zig",
199 ⎥                 },
200 ⎥             },
201 ⎥         },
202 ⎥     );
203 ⎥ 
204 ⎥     // Framework module dependencies.
205 ⎥ 
206 ⎥     // Dependencies for channel_mod. A framework deps/ module.
207 ⎥     channel_mod.addImport("message", message_mod);
208 ⎥     channel_mod.addImport("various", various_mod);
209 ⎥ 
210 ⎥     // Dependencies for closedownjobs_mod. A framework deps/ module.
211 ⎥     closedownjobs_mod.addImport("counter", counter_mod);
212 ⎥ 
213 ⎥     // Dependencies for closer_mod. A framework deps/ module.
214 ⎥     closer_mod.addImport("closedownjobs", closedownjobs_mod);
215 ⎥     closer_mod.addImport("dvui", dvui_dep.module("dvui"));
216 ⎥     closer_mod.addImport("framers", framers_mod);
217 ⎥     closer_mod.addImport("lock", lock_mod);
218 ⎥     closer_mod.addImport("modal_params", modal_params_mod);
219 ⎥     closer_mod.addImport("various", various_mod);
220 ⎥ 
221 ⎥     // Dependencies for framers_mod. A framework deps/ module.
222 ⎥     framers_mod.addImport("startup", startup_mod);
223 ⎥     framers_mod.addImport("dvui", dvui_dep.module("dvui"));
224 ⎥     framers_mod.addImport("modal_params", modal_params_mod);
225 ⎥     framers_mod.addImport("various", various_mod);
226 ⎥     framers_mod.addImport("lock", lock_mod);
227 ⎥ 
228 ⎥     // Dependencies for message_mod. A framework deps/ module.
229 ⎥     message_mod.addImport("counter", counter_mod);
230 ⎥     message_mod.addImport("closedownjobs", closedownjobs_mod);
231 ⎥     message_mod.addImport("framers", framers_mod);
232 ⎥     message_mod.addImport("record", record_mod);
233 ⎥     message_mod.addImport("various", various_mod);
234 ⎥ 
235 ⎥     // Dependencies for modal_params_mod. A framework deps/ module.
236 ⎥     modal_params_mod.addImport("closedownjobs", closedownjobs_mod);
237 ⎥ 
238 ⎥     // Dependencies for screen_pointers_mod. A framework frontend/ module.
239 ⎥     screen_pointers_mod.addImport("channel", channel_mod);
240 ⎥     screen_pointers_mod.addImport("closedownjobs", closedownjobs_mod);
241 ⎥     screen_pointers_mod.addImport("closer", closer_mod);
242 ⎥     screen_pointers_mod.addImport("dvui", dvui_dep.module("dvui"));
243 ⎥     screen_pointers_mod.addImport("framers", framers_mod);
244 ⎥     screen_pointers_mod.addImport("lock", lock_mod);
245 ⎥     screen_pointers_mod.addImport("message", message_mod);
246 ⎥     screen_pointers_mod.addImport("modal_params", modal_params_mod);
247 ⎥     screen_pointers_mod.addImport("record", record_mod);
248 ⎥     screen_pointers_mod.addImport("screen_pointers", screen_pointers_mod);
249 ⎥     screen_pointers_mod.addImport("startup", startup_mod);
250 ⎥     screen_pointers_mod.addImport("various", various_mod);
251 ⎥     screen_pointers_mod.addImport("widget", widget_mod);
252 ⎥ 
253 ⎥     // Dependencies for startup_mod. A framework deps/ module.
254 ⎥     startup_mod.addImport("channel", channel_mod);
255 ⎥     startup_mod.addImport("closedownjobs", closedownjobs_mod);
256 ⎥     startup_mod.addImport("dvui", dvui_dep.module("dvui"));
257 ⎥     startup_mod.addImport("framers", framers_mod);
258 ⎥     startup_mod.addImport("modal_params", modal_params_mod);
259 ⎥     startup_mod.addImport("various", various_mod);
260 ⎥     startup_mod.addImport("screen_pointers", screen_pointers_mod);
261 ⎥     startup_mod.addImport("store", store_mod);
262 ⎥ 
263 ⎥     // Dependencies for widget_mod. A framework deps/ module.
264 ⎥     widget_mod.addImport("dvui", dvui_dep.module("dvui"));
265 ⎥     widget_mod.addImport("lock", lock_mod);
266 ⎥     widget_mod.addImport("framers", framers_mod);
267 ⎥     widget_mod.addImport("startup", startup_mod);
268 ⎥     widget_mod.addImport("various", various_mod);
269 ⎥ 
270 ⎥     // MY MODULES DEPENDENCIES.
271 ⎥ 
272 ⎥     // Dependencies for record_mod. My deps/ module.
273 ⎥     record_mod.addImport("counter", counter_mod);
274 ⎥ 
275 ⎥     // Dependencies for store_mod. My deps/ module.
276 ⎥     store_mod.addImport("record", record_mod);
277 ⎥     store_mod.addImport("sqlite", sqlite_dep.module("fridge"));
278 ⎥ 
279 ⎥     const exe = b.addExecutable(.{
280 ⎥         .name = "crud",
281 ⎥         .root_source_file = .{
282 ⎥             .src_path = .{
283 ⎥                 .owner = b,
284 ⎥                 .sub_path = "src/main.zig",
285 ⎥             },
286 ⎥         },
287 ⎥         .target = target,
288 ⎥         .optimize = optimize,
289 ⎥     });
290 ⎥ 
291 ⎥     exe.root_module.addImport("dvui", dvui_dep.module("dvui"));
292 ⎥     exe.root_module.addImport("SDLBackend", dvui_dep.module("SDLBackend"));
293 ⎥ 
294 ⎥     // Framework modules.
295 ⎥     exe.root_module.addImport("channel", channel_mod);
296 ⎥     exe.root_module.addImport("closedownjobs", closedownjobs_mod);
297 ⎥     exe.root_module.addImport("closer", closer_mod);
298 ⎥     exe.root_module.addImport("counter", counter_mod);
299 ⎥     exe.root_module.addImport("framers", framers_mod);
300 ⎥     exe.root_module.addImport("lock", lock_mod);
301 ⎥     exe.root_module.addImport("message", message_mod);
302 ⎥     exe.root_module.addImport("modal_params", modal_params_mod);
303 ⎥     exe.root_module.addImport("screen_pointers", screen_pointers_mod);
304 ⎥     exe.root_module.addImport("startup", startup_mod);
305 ⎥     exe.root_module.addImport("various", various_mod);
306 ⎥     exe.root_module.addImport("widget", widget_mod);
307 ⎥ 
308 ⎥     // my deps modules.
309 ⎥     exe.root_module.addImport("record", record_mod);
310 ⎥     exe.root_module.addImport("store", store_mod);
311 ⎥ 
312 ⎥     // vendor/fridge/ module.
313 ⎥     exe.root_module.addImport("sqlite", sqlite_dep.module("fridge"));
314 ⎥ 
315 ⎥     // This declares intent for the executable to be installed into the
316 ⎥     // standard location when the user invokes the "install" step (the default
317 ⎥     // step when running `zig build`).
318 ⎥     b.installArtifact(exe);
319 ⎥ 
320 ⎥     // This *creates* a Run step in the build graph, to be executed when another
321 ⎥     // step is evaluated that depends on it. The next line below will establish
322 ⎥     // such a dependency.
323 ⎥     const run_cmd = b.addRunArtifact(exe);
324 ⎥ 
325 ⎥     // By making the run step depend on the install step, it will be run from the
326 ⎥     // installation directory rather than directly from within the cache directory.
327 ⎥     // This is not necessary, however, if the application depends on other installed
328 ⎥     // files, this ensures they will be present and in the expected location.
329 ⎥     run_cmd.step.dependOn(b.getInstallStep());
330 ⎥ 
331 ⎥     // This allows the user to pass arguments to the application in the build
332 ⎥     // command itself, like this: `zig build run -- arg1 arg2 etc`
333 ⎥     if (b.args) |args| {
334 ⎥         run_cmd.addArgs(args);
335 ⎥     }
336 ⎥ 
337 ⎥     // This creates a build step. It will be visible in the `zig build --help` menu,
338 ⎥     // and can be selected like this: `zig build run`
339 ⎥     // This will evaluate the `run` step rather than the default, which is "install".
340 ⎥     const run_step = b.step("run", "Run the app");
341 ⎥     run_step.dependOn(&run_cmd.step);
342 ⎥ 
343 ⎥     // Creates a step for unit testing. This only builds the test executable
344 ⎥     // but does not run it.
345 ⎥     const sep_test = b.addTest(.{
346 ⎥         .root_source_file = b.path("src/root.zig"),
347 ⎥         .target = target,
348 ⎥         .optimize = optimize,
349 ⎥     });
350 ⎥ 
351 ⎥     const run_sep_unit_tests = b.addRunArtifact(sep_test);
352 ⎥ 
353 ⎥     const exe_unit_tests = b.addTest(.{
354 ⎥         .root_source_file = b.path("src/main.zig"),
355 ⎥         .target = target,
356 ⎥         .optimize = optimize,
357 ⎥     });
358 ⎥ 
359 ⎥     const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
360 ⎥ 
361 ⎥     // Similar to creating the run step earlier, this exposes a `test` step to
362 ⎥     // the `zig build --help` menu, providing a way for the user to request
363 ⎥     // running the unit tests.
364 ⎥     const test_step = b.step("test", "Run unit tests");
365 ⎥     test_step.dependOn(&run_exe_unit_tests.step);
366 ⎥     test_step.dependOn(&run_sep_unit_tests.step);
367 ⎥ }
368 ⎥ 
```
