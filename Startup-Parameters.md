The application's startup parameters are defined in the file at src/deps/startup/api.zig. The file defines both the front-end startup params and the back-end startup params.

The backend is going to need the Store for it's message handlers. I added the following lines for the store in api.zig which is shown below.

* line 12
* line 23

```zig
  1 ⎥ /// KICKZIG TODO: You are free to modify this file.
  2 ⎥ /// You may want to add your own members to these startup structs.
  3 ⎥ const std = @import("std");
  4 ⎥ const dvui = @import("dvui");
  5 ⎥ 
  6 ⎥ const _channel_ = @import("channel");
  7 ⎥ const _closedownjobs_ = @import("closedownjobs");
  8 ⎥ const _modal_params_ = @import("modal_params");
  9 ⎥ const ExitFn = @import("various").ExitFn;
 10 ⎥ const MainView = @import("framers").MainView;
 11 ⎥ const ScreenPointers = @import("screen_pointers").ScreenPointers;
 12 ⎥ const Store = @import("store").Store;
 13 ⎥ 
 14 ⎥ /// Backend is the parameters passed to the back-end when it is initialized.
 15 ⎥ pub const Backend = struct {
 16 ⎥     allocator: std.mem.Allocator,
 17 ⎥     send_channels: *_channel_.BackendToFrontend,
 18 ⎥     receive_channels: *_channel_.FrontendToBackend,
 19 ⎥     triggers: *_channel_.Trigger,
 20 ⎥     close_down_jobs: *_closedownjobs_.Jobs,
 21 ⎥     exit: ExitFn,
 22 ⎥ 
 23 ⎥     store: ?*Store = null,
 24 ⎥ };
 25 ⎥ 
 26 ⎥ /// Frontend is the parameters passed to the front-end when it is initialized.
 27 ⎥ pub const Frontend = struct {
 28 ⎥     allocator: std.mem.Allocator,
 29 ⎥     window: *dvui.Window,
 30 ⎥     send_channels: *_channel_.FrontendToBackend,
 31 ⎥     receive_channels: *_channel_.BackendToFrontend,
 32 ⎥     main_view: *MainView,
 33 ⎥     close_down_jobs: *_closedownjobs_.Jobs,
 34 ⎥     exit: ExitFn,
 35 ⎥     screen_pointers: *ScreenPointers,
 36 ⎥ 
 37 ⎥     pub fn setMainView(self: *const Frontend, main_view: *MainView) void {
 38 ⎥         @constCast(self).main_view = main_view;
 39 ⎥     }
 40 ⎥ 
 41 ⎥     pub fn setScreenPointers(self: *const Frontend, screen_pointers: *ScreenPointers) void {
 42 ⎥         @constCast(self).screen_pointers = screen_pointers;
 43 ⎥     }
 44 ⎥ };
 45 ⎥ 
```

## Next

[[Create The Messages.|Create-The-Messages]]
