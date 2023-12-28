## Additions related to Store

* line 10
* lines 42 - 61
* line 73

## Additions related to known-folders

The known-folders package is vendored in the src/vendor/known-folders/ folder.

* line 11
* line 44

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ const dvui = @import("dvui");
  3 ⎥ const SDLBackend = @import("SDLBackend");
  4 ⎥ 
  5 ⎥ const _frontend_ = @import("src/@This/frontend/api.zig");
  6 ⎥ const _backend_ = @import("src/@This/backend/api.zig");
  7 ⎥ const _channel_ = @import("channel");
  8 ⎥ const _framers_ = @import("framers");
  9 ⎥ 
 10 ⎥ const Store = @import("store").Store;
 11 ⎥ const known_folders = @import("known-folders");
 12 ⎥ 
 13 ⎥ const window_icon_png = @embedFile("src/vendor/dvui/src/zig-favicon.png");
 14 ⎥ 
 15 ⎥ // General Purpose Allocator for frontend-state, backend and channels.
 16 ⎥ var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
 17 ⎥ const gpa = gpa_instance.allocator();
 18 ⎥ 
 19 ⎥ const vsync = true;
 20 ⎥ 
 21 ⎥ var show_dialog_outside_frame: bool = false;
 22 ⎥ 
 23 ⎥ /// This example shows how to use the dvui for a normal application:
 24 ⎥ /// - dvui renders the whole application
 25 ⎥ /// - render frames only when needed
 26 ⎥ pub fn main() !void {
 27 ⎥     // init SDL gui_backend (creates OS window)
 28 ⎥     var gui_backend = try SDLBackend.init(.{
 29 ⎥         .size = .{ .w = 500.0, .h = 400.0 },
 30 ⎥         .min_size = .{ .w = 500.0, .h = 400.0 },
 31 ⎥         .vsync = vsync,
 32 ⎥         .title = "crud",
 33 ⎥         .icon = window_icon_png, // can also call setIconFromFileContent()
 34 ⎥     });
 35 ⎥     defer gui_backend.deinit();
 36 ⎥ 
 37 ⎥     // init dvui Window (maps onto a single OS window)
 38 ⎥     var win = try dvui.Window.init(@src(), 0, gpa, gui_backend.backend());
 39 ⎥     win.content_scale = gui_backend.initial_scale * 1.5;
 40 ⎥     defer win.deinit();
 41 ⎥ 
 42 ⎥     // Initialize the local data store.
 43 ⎥     // The data must be stored in the OS's application data folder.
 44 ⎥     var data_path: []const u8 = try known_folders.getPath(gpa, .data) orelse try std.fs.selfExeDirPathAlloc(gpa);
 45 ⎥     defer gpa.free(data_path);
 46 ⎥     // Create a folder for this application.
 47 ⎥     var crud_paths: [2][]const u8 = [_][]const u8{ data_path, "crud" };
 48 ⎥     var crud_path: []const u8 = try std.fs.path.join(gpa, &crud_paths);
 49 ⎥     defer gpa.free(crud_path);
 50 ⎥     std.fs.makeDirAbsolute(crud_path) catch |err| {
 51 ⎥         if (err != error.PathAlreadyExists) {
 52 ⎥             return err;
 53 ⎥         }
 54 ⎥     };
 55 ⎥     // Create the path for this application's store.
 56 ⎥     var store_paths: [2][]const u8 = [_][]const u8{ crud_path, "store.sql" };
 57 ⎥     var store_path: [:0]const u8 = try std.fs.path.joinZ(gpa, &store_paths);
 58 ⎥     defer gpa.free(store_path);
 59 ⎥     // Create and / or open the store.
 60 ⎥     var store: *Store = try Store.init(gpa, store_path);
 61 ⎥     defer store.deinit();
 62 ⎥ 
 63 ⎥     // The channels between the front and back ends.
 64 ⎥     var initialized_channels: bool = false;
 65 ⎥     const backToFront: *_channel_.Channels = try _channel_.init(gpa);
 66 ⎥     defer backToFront.deinit();
 67 ⎥     const frontToBack: *_channel_.Channels = try _channel_.init(gpa);
 68 ⎥     defer frontToBack.deinit();
 69 ⎥ 
 70 ⎥     // Initialize the front and back ends.
 71 ⎥     var all_screens: *_framers_.Group = try _frontend_.init(gpa, frontToBack, backToFront);
 72 ⎥     defer all_screens.deinit();
 73 ⎥     try _backend_.init(gpa, backToFront, frontToBack, store);
 74 ⎥     defer _backend_.deinit();
 75 ⎥ 
 76 ⎥     var theme_set: bool = false;
 77 ⎥ 
 78 ⎥     main_loop: while (true) {
 79 ⎥ 
 80 ⎥         // Arena allocator for the frontend frame functions.
 81 ⎥         var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
 82 ⎥         defer arena_allocator.deinit();
 83 ⎥         var arena = arena_allocator.allocator();
 84 ⎥ 
 85 ⎥         // beginWait coordinates with waitTime below to run frames only when needed
 86 ⎥         var nstime = win.beginWait(gui_backend.hasEvent());
 87 ⎥ 
 88 ⎥         // marks the beginning of a frame for dvui, can call dvui functions after this
 89 ⎥         try win.begin(nstime);
 90 ⎥ 
 91 ⎥         // set the theme.
 92 ⎥         if (!theme_set) {
 93 ⎥             theme_set = true;
 94 ⎥             const dark_theme = &dvui.Adwaita.dark;
 95 ⎥             dvui.themeSet(dark_theme);
 96 ⎥         }
 97 ⎥ 
 98 ⎥         // send all SDL events to dvui for processing
 99 ⎥         const quit = try gui_backend.addAllEvents(&win);
100 ⎥         if (quit) break :main_loop;
101 ⎥ 
102 ⎥         // if dvui widgets might not cover the whole window, then need to clear
103 ⎥         // the previous frame's render
104 ⎥         gui_backend.clear();
105 ⎥ 
106 ⎥         try _frontend_.frame(arena, all_screens);
107 ⎥ 
108 ⎥         if (!initialized_channels) {
109 ⎥             initialized_channels = true;
110 ⎥             // Send the initialize message telling the backend that the frontend is ready.
111 ⎥             frontToBack.Initialize.send();
112 ⎥         }
113 ⎥ 
114 ⎥         // marks end of dvui frame, don't call dvui functions after this
115 ⎥         // - sends all dvui stuff to gui_backend for rendering, must be called before renderPresent()
116 ⎥         const end_micros = try win.end(.{});
117 ⎥ 
118 ⎥         // cursor management
119 ⎥         gui_backend.setCursor(win.cursorRequested());
120 ⎥ 
121 ⎥         // render frame to OS
122 ⎥         gui_backend.renderPresent();
123 ⎥ 
124 ⎥         // waitTime and beginWait combine to achieve variable framerates
125 ⎥         const wait_event_micros = win.waitTime(end_micros, null);
126 ⎥         gui_backend.waitEventTimeout(wait_event_micros);
127 ⎥ 
128 ⎥         // Example of how to show a dialog from another thread (outside of win.begin/win.end)
129 ⎥         if (show_dialog_outside_frame) {
130 ⎥             show_dialog_outside_frame = false;
131 ⎥             try dvui.dialog(@src(), .{ .window = &win, .modal = false, .title = "Dialog from Outside", .message = "This is a non modal dialog that was created outside win.begin()/win.end(), usually from another thread." });
132 ⎥         }
133 ⎥     }
134 ⎥ }
135 ⎥ 
```
