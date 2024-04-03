The application's startup parameters are defined in the file at src/@This/deps/startup/api.zig. The file defines both the front-end startup params and the back-end startup params.

The backend is going to need the Store for it's message handlers. I added the following lines for the store in api.zig which is shown below.

* line 12
* line 22

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
 22 ⎥     store: *Store,
 23 ⎥ };
 24 ⎥ 
 25 ⎥ /// Frontend is the parameters passed to the front-end when it is initialized.
 26 ⎥ pub const Frontend = struct {
 27 ⎥     allocator: std.mem.Allocator,
 28 ⎥     window: *dvui.Window,
 29 ⎥     send_channels: *_channel_.FrontendToBackend,
 30 ⎥     receive_channels: *_channel_.BackendToFrontend,
 31 ⎥     main_view: *MainView,
 32 ⎥     close_down_jobs: *_closedownjobs_.Jobs,
 33 ⎥     exit: ExitFn,
 34 ⎥     screen_pointers: *ScreenPointers,
 35 ⎥ 
 36 ⎥     pub fn setMainView(self: *const Frontend, main_view: *MainView) void {
 37 ⎥         @constCast(self).main_view = main_view;
 38 ⎥     }
 39 ⎥ 
 40 ⎥     pub fn setScreenPointers(self: *const Frontend, screen_pointers: *ScreenPointers) void {
 41 ⎥         @constCast(self).screen_pointers = screen_pointers;
 42 ⎥     }
 43 ⎥ };
 44 ⎥ 
```

## Next

[[Create The Messages.|Create-The-Messages]]
