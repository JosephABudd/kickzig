I want to use the Choice modal screen to allow the user to choose to Edit a contact record, Remove a contact record or Do nothing at all.

The Choice modal screen displays options as buttons. Each button has a label and call back. The screen will have 1 panel named Choice.

The Choice modal screen also has modal params.

```shell
＄ kickzig screen add-modal Choice Choice
Added the front-end «Choice» Modal screen at /home/nil/zig/crud/src/frontend/screen/modal/Choice/screen.zig:1:1:
Added the deps «Choice» Modal Params at /home/nil/zig/crud/src/deps/modal_params/Choice.zig:1:1:
```

## Choice modal params

My edited deps/modal_params/Choice.zig file is shown below. I added the following lines.

* lines 3 - 31
* lines 43 - 45
* line 50 & 53 - 57
* lines 62 - 68
* lines 72 - 96
* lines 98 - 100

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ 
  3 ⎥ const ChoiceItem = struct {
  4 ⎥     allocator: std.mem.Allocator,
  5 ⎥     label: []const u8,
  6 ⎥     implementor: ?*anyopaque,
  7 ⎥     context: ?*anyopaque,
  8 ⎥     call_back: ?*const fn (implementor: ?*anyopaque, context: ?*anyopaque) anyerror!void,
  9 ⎥ 
 10 ⎥     fn deinit(self: *ChoiceItem) void {
 11 ⎥         self.allocator.free(self.label);
 12 ⎥         self.allocator.destroy(self);
 13 ⎥     }
 14 ⎥ 
 15 ⎥     fn init(
 16 ⎥         allocator: std.mem.Allocator,
 17 ⎥         label: []const u8,
 18 ⎥         implementor: ?*anyopaque,
 19 ⎥         context: ?*anyopaque,
 20 ⎥         call_back: ?*const fn (implementor: ?*anyopaque, context: ?*anyopaque) anyerror!void,
 21 ⎥     ) !*const ChoiceItem {
 22 ⎥         const self: *ChoiceItem = try allocator.create(ChoiceItem);
 23 ⎥         self.label = try allocator.alloc(u8, label.len);
 24 ⎥         @memcpy(@constCast(self.label), label);
 25 ⎥         self.implementor = implementor;
 26 ⎥         self.context = context;
 27 ⎥         self.call_back = call_back;
 28 ⎥         self.allocator = allocator;
 29 ⎥         return self;
 30 ⎥     }
 31 ⎥ };
 32 ⎥ 
 33 ⎥ /// Params is the parameters for the Choice modal screen's state.
 34 ⎥ /// See src/frontend/screen/modal/Choice/screen.zig setState.
 35 ⎥ /// Your arguments are the values assigned to each Params member.
 36 ⎥ /// For examples:
 37 ⎥ /// * See OK.zig for a Params example.
 38 ⎥ /// * See src/frontend/screen/modal/OK/screen.zig setState.
 39 ⎥ pub const Params = struct {
 40 ⎥     allocator: std.mem.Allocator,
 41 ⎥ 
 42 ⎥     // Parameters.
 43 ⎥     title: []const u8,
 44 ⎥     choices: []*const ChoiceItem,
 45 ⎥     choices_index: usize,
 46 ⎥ 
 47 ⎥     /// The caller owns the returned value.
 48 ⎥     pub fn init(
 49 ⎥         allocator: std.mem.Allocator,
 50 ⎥         title: []const u8,
 51 ⎥     ) !*Params {
 52 ⎥         var args: *Params = try allocator.create(Params);
 53 ⎥         args.title = try allocator.alloc(u8, title.len);
 54 ⎥         @memcpy(@constCast(args.title), title);
 55 ⎥         args.allocator = allocator;
 56 ⎥         args.choices = try allocator.alloc(*ChoiceItem, 5);
 57 ⎥         args.choices_index = 0;
 58 ⎥         return args;
 59 ⎥     }
 60 ⎥ 
 61 ⎥     pub fn deinit(self: *Params) void {
 62 ⎥         for (self.choices, 0..) |choice, i| {
 63 ⎥             if (i == self.choices_index) {
 64 ⎥                 break;
 65 ⎥             }
 66 ⎥             @constCast(choice).deinit();
 67 ⎥         }
 68 ⎥         self.allocator.free(self.choices);
 69 ⎥         self.allocator.destroy(self);
 70 ⎥     }
 71 ⎥ 
 72 ⎥     pub fn addChoiceItem(
 73 ⎥         self: *Params,
 74 ⎥         label: []const u8,
 75 ⎥         implementor: ?*anyopaque,
 76 ⎥         context: ?*anyopaque,
 77 ⎥         call_back: ?*const fn (implementor: ?*anyopaque, context: ?*anyopaque) anyerror!void,
 78 ⎥     ) !void {
 79 ⎥         const choice_item: *const ChoiceItem = try ChoiceItem.init(
 80 ⎥             self.allocator,
 81 ⎥             label,
 82 ⎥             implementor,
 83 ⎥             context,
 84 ⎥             call_back,
 85 ⎥         );
 86 ⎥         if (self.choices_index == self.choices.len) {
 87 ⎥             const temps = self.choices;
 88 ⎥             defer self.allocator.free(temps);
 89 ⎥             self.choices = try self.allocator.alloc(*const ChoiceItem, temps.len + 5);
 90 ⎥             for (temps, 0..) |temp, i| {
 91 ⎥                 self.choices[i] = temp;
 92 ⎥             }
 93 ⎥         }
 94 ⎥         self.choices[self.choices_index] = choice_item;
 95 ⎥         self.choices_index += 1;
 96 ⎥     }
 97 ⎥ 
 98 ⎥     pub fn choiceItems(self: *Params) []*const ChoiceItem {
 99 ⎥         return self.choices[0..self.choices_index];
100 ⎥     }
101 ⎥ };
102 ⎥ 
```

My edited frontend/screens/modal/Choice/Choice_panel.zig file is shown below. I added the following lines.

* lines 78 - 95

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ const dvui = @import("dvui");
  3 ⎥ 
  4 ⎥ const _channel_ = @import("channel");
  5 ⎥ const _lock_ = @import("lock");
  6 ⎥ const _messenger_ = @import("messenger.zig");
  7 ⎥ const _panels_ = @import("panels.zig");
  8 ⎥ const ExitFn = @import("various").ExitFn;
  9 ⎥ const MainView = @import("framers").MainView;
 10 ⎥ const ModalParams = @import("modal_params").Choice;
 11 ⎥ 
 12 ⎥ pub const Panel = struct {
 13 ⎥     allocator: std.mem.Allocator, // For persistant state data.
 14 ⎥     lock: *_lock_.ThreadLock, // For persistant state data.
 15 ⎥     window: *dvui.Window,
 16 ⎥     main_view: *MainView,
 17 ⎥     all_panels: *_panels_.Panels,
 18 ⎥     messenger: *_messenger_.Messenger,
 19 ⎥     exit: ExitFn,
 20 ⎥ 
 21 ⎥     modal_params: ?*ModalParams,
 22 ⎥ 
 23 ⎥     // This panels owns the modal params.
 24 ⎥     pub fn presetModal(self: *Panel, setup_args: *ModalParams) !void {
 25 ⎥         if (self.modal_params) |modal_params| {
 26 ⎥             modal_params.deinit();
 27 ⎥         }
 28 ⎥         self.modal_params = setup_args;
 29 ⎥     }
 30 ⎥ 
 31 ⎥     /// refresh only if this panel is showing and this screen is showing.
 32 ⎥     pub fn refresh(self: *Panel) void {
 33 ⎥         if (self.all_panels.current_panel_tag == .Choice) {
 34 ⎥             self.main_view.refreshChoice();
 35 ⎥         }
 36 ⎥     }
 37 ⎥ 
 38 ⎥     pub fn deinit(self: *Panel) void {
 39 ⎥         if (self.modal_params) |modal_params| {
 40 ⎥             modal_params.deinit();
 41 ⎥         }
 42 ⎥         self.lock.deinit();
 43 ⎥         self.allocator.destroy(self);
 44 ⎥     }
 45 ⎥ 
 46 ⎥     // close removes this modal screen replacing it with the previous screen.
 47 ⎥     fn close(self: *Panel) void {
 48 ⎥         self.main_view.hideChoice();
 49 ⎥     }
 50 ⎥ 
 51 ⎥     /// frame this panel.
 52 ⎥     /// Layout, Draw, Handle user events.
 53 ⎥     pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {
 54 ⎥         _ = arena;
 55 ⎥ 
 56 ⎥         self.lock.lock();
 57 ⎥         defer self.lock.unlock();
 58 ⎥ 
 59 ⎥         const theme: *dvui.Theme = dvui.themeGet();
 60 ⎥ 
 61 ⎥         const padding_options = .{
 62 ⎥             .expand = .both,
 63 ⎥             .margin = dvui.Rect.all(0),
 64 ⎥             .border = dvui.Rect.all(10),
 65 ⎥             .padding = dvui.Rect.all(10),
 66 ⎥             .corner_radius = dvui.Rect.all(5),
 67 ⎥             .color_border = theme.style_accent.color_accent.?, //dvui.options.color(.accent),
 68 ⎥         };
 69 ⎥         var padding: *dvui.BoxWidget = try dvui.box(@src(), .vertical, padding_options);
 70 ⎥         defer padding.deinit();
 71 ⎥ 
 72 ⎥         var scroller = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
 73 ⎥         defer scroller.deinit();
 74 ⎥ 
 75 ⎥         var layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{});
 76 ⎥         defer layout.deinit();
 77 ⎥ 
 78 ⎥         // Row 1: User defined title.
 79 ⎥         var title = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal, .font_style = .title_4 });
 80 ⎥         try title.addText(self.modal_params.?.title, .{});
 81 ⎥         title.deinit();
 82 ⎥ 
 83 ⎥         // Row 2-?: User defined buttons
 84 ⎥         const choices = self.modal_params.?.choiceItems();
 85 ⎥         for (choices, 0..) |choice, i| {
 86 ⎥             if (try dvui.button(@src(), choice.label, .{}, .{ .expand = .both, .id_extra = i })) {
 87 ⎥                 // The button is clicked so close the window and call back.
 88 ⎥                 self.close();
 89 ⎥                 if (choice.call_back) |call_back| {
 90 ⎥                     call_back(choice.implementor.?, choice.context.?) catch |err| {
 91 ⎥                         self.exit(@src(), err, "choice.call_back(choice.implementor, choice.context)");
 92 ⎥                     };
 93 ⎥                 }
 94 ⎥             }
 95 ⎥         }
 96 ⎥     }
 97 ⎥ };
 98 ⎥ 
 99 ⎥ pub fn init(allocator: std.mem.Allocator, main_view: *MainView, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panel {
100 ⎥     var panel: *Panel = try allocator.create(Panel);
101 ⎥     panel.lock = try _lock_.init(allocator);
102 ⎥     errdefer {
103 ⎥         allocator.destroy(panel);
104 ⎥     }
105 ⎥     panel.allocator = allocator;
106 ⎥     panel.main_view = main_view;
107 ⎥     panel.all_panels = all_panels;
108 ⎥     panel.messenger = messenger;
109 ⎥     panel.exit = exit;
110 ⎥     panel.window = window;
111 ⎥     panel.modal_params = null;
112 ⎥     return panel;
113 ⎥ }
114 ⎥ 
```

## Next

[[Create The Contacts Panel Screen.|Create-The-Contacts-Panel-Screen]]
