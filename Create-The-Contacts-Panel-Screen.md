The Contacts screen will be a Panel screen. A Panel screen simply switches from one panel to another. Only one panel is ever displayed at a time.

The contacts panel screen will have:

* a panel for selecting a contact.
* a panel for adding a new contact,
* a panel for editing a selected contact,
* a panel for confirming the removal of a selected contact,

```shell
＄ kickzig screen add-panel Contacts Select Add Edit Remove
Added the front-end «Contacts» Panel screen at /home/nil/zig/misc/crud/src/frontend/screen/panel/Contacts/screen.zig:1:1:
```

## The select panel

The select panel is shown below. The panel begins with the contact's name at the left and an Add icon at the right for adding a new contact. The Add icon simply switches from the Select panel to the Add panel.

Below that is the scrolling list of buttons. Each button displays a contact record. Clicking a button opens the Choice modal screen which allows the user to edit or remove the contact.

I added the following lines.

* line 8, 9 & 12
* lines 41 - 86
* lines 121 - 198
* line 214

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ const dvui = @import("dvui");
  3 ⎥ 
  4 ⎥ const _lock_ = @import("lock");
  5 ⎥ const _messenger_ = @import("messenger.zig");
  6 ⎥ const _panels_ = @import("panels.zig");
  7 ⎥ const _various_ = @import("various");
  8 ⎥ const ChoiceItem = @import("modal_params").ChoiceItem;
  9 ⎥ const ContactList = @import("record").List;
 10 ⎥ const ExitFn = @import("various").ExitFn;
 11 ⎥ const MainView = @import("framers").MainView;
 12 ⎥ const ModalParams = @import("modal_params").Choice;
 13 ⎥ 
 14 ⎥ // KICKZIG TODO:
 15 ⎥ // Remember. Defers happen in reverse order.
 16 ⎥ // When updating panel state.
 17 ⎥ //     self.lock();
 18 ⎥ //     defer self.unlock(); //  2nd defer: Unlocks.
 19 ⎥ //     defer self.refresh(); // 1st defer: Refreshes the main view.
 20 ⎥ //     // DO THE UPDATES.
 21 ⎥ 
 22 ⎥ pub const Panel = struct {
 23 ⎥     allocator: std.mem.Allocator, // For persistant state data.
 24 ⎥     lock: *_lock_.ThreadLock, // For persistant state data.
 25 ⎥     window: *dvui.Window,
 26 ⎥     main_view: *MainView,
 27 ⎥     container: ?*_various_.Container,
 28 ⎥     all_panels: *_panels_.Panels,
 29 ⎥     messenger: *_messenger_.Messenger,
 30 ⎥     exit: ExitFn,
 31 ⎥ 
 32 ⎥     contact_list_records: ?[]const *const ContactList,
 33 ⎥ 
 34 ⎥     /// frame this panel.
 35 ⎥     /// Layout, Draw, Handle user events.
 36 ⎥     /// The arena allocator is for building this frame. Not for state.
 37 ⎥     pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {
 38 ⎥         self.lock.lock();
 39 ⎥         defer self.lock.unlock();
 40 ⎥ 
 41 ⎥         {
 42 ⎥             // Row 1: The screen's name.
 43 ⎥             // Use the same background as the scroller.
 44 ⎥             var row: *dvui.BoxWidget = try dvui.box(
 45 ⎥                 @src(),
 46 ⎥                 .horizontal,
 47 ⎥                 .{
 48 ⎥                     .expand = .horizontal,
 49 ⎥                     .background = true,
 50 ⎥                 },
 51 ⎥             );
 52 ⎥             defer row.deinit();
 53 ⎥ 
 54 ⎥             try dvui.labelNoFmt(@src(), "Select a Contact.", .{ .font_style = .title, .gravity_x = 0.0 });
 55 ⎥             if (try dvui.buttonIcon(@src(), "AddAContactButton", dvui.entypo.add_to_list, .{}, .{ .gravity_x = 1.0 })) {
 56 ⎥                 self.all_panels.Add.?.clearBuffer();
 57 ⎥                 self.all_panels.setCurrentToAdd();
 58 ⎥             }
 59 ⎥         }
 60 ⎥         {
 61 ⎥             // Row 2: List of contacts.
 62 ⎥             const scroller = try dvui.scrollArea(
 63 ⎥                 @src(),
 64 ⎥                 .{},
 65 ⎥                 .{
 66 ⎥                     .expand = .both,
 67 ⎥                 },
 68 ⎥             );
 69 ⎥             defer scroller.deinit();
 70 ⎥ 
 71 ⎥             {
 72 ⎥                 var scroller_layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{ .expand = .both });
 73 ⎥                 defer scroller_layout.deinit();
 74 ⎥ 
 75 ⎥                 if (self.contact_list_records) |contact_list_records| {
 76 ⎥                     for (contact_list_records, 0..) |contact_list_record, i| {
 77 ⎥                         const label = try std.fmt.allocPrint(arena, "{s}\n{s}\n{s}, {s} {s}", .{ contact_list_record.name.?, contact_list_record.address.?, contact_list_record.city.?, contact_list_record.state.?, contact_list_record.zip.? });
 78 ⎥                         if (try dvui.button(@src(), label, .{}, .{ .expand = .both, .id_extra = i })) {
 79 ⎥                             // user selected this contact.
 80 ⎥                             const contact_copy = try contact_list_record.copy();
 81 ⎥                             try self.handleClick(contact_copy);
 82 ⎥                         }
 83 ⎥                     }
 84 ⎥                 }
 85 ⎥             }
 86 ⎥         }
 87 ⎥     }
 88 ⎥ 
 89 ⎥     pub fn deinit(self: *Panel) void {
 90 ⎥         // The screen will deinit the container.
 91 ⎥ 
 92 ⎥         if (self.contact_list_records) |deinit_contact_list_records| {
 93 ⎥             for (deinit_contact_list_records) |deinit_contact_list_record| {
 94 ⎥                 deinit_contact_list_record.deinit();
 95 ⎥             }
 96 ⎥             self.allocator.free(deinit_contact_list_records);
 97 ⎥         }
 98 ⎥         self.lock.deinit();
 99 ⎥         self.allocator.destroy(self);
100 ⎥     }
101 ⎥ 
102 ⎥     /// refresh only if this panel and ( container or screen ) are showing.
103 ⎥     pub fn refresh(self: *Panel) void {
104 ⎥         if (self.all_panels.current_panel_tag == .Select) {
105 ⎥             // This is the current panel.
106 ⎥             if (self.container) |container| {
107 ⎥                 // Refresh the container.
108 ⎥                 // The container will refresh only if it's the currently viewed screen.
109 ⎥                 container.refresh();
110 ⎥             } else {
111 ⎥                 // Main view will refresh only if this is the currently viewed screen.
112 ⎥                 self.main_view.refreshContacts();
113 ⎥             }
114 ⎥         }
115 ⎥     }
116 ⎥ 
117 ⎥     pub fn setContainer(self: *Panel, container: *_various_.Container) void {
118 ⎥         self.container = container;
119 ⎥     }
120 ⎥ 
121 ⎥     // has_records returns if there are records in the list to display.
122 ⎥     pub fn has_records(self: *Panel) bool {
123 ⎥         self.lock.lock();
124 ⎥         defer self.lock.unlock();
125 ⎥ 
126 ⎥         return (self.contact_list_records != null);
127 ⎥     }
128 ⎥ 
129 ⎥     // set is called by the messenger.
130 ⎥     // on handles and returns any error.
131 ⎥     // Param contact_list_records is owned by this fn.
132 ⎥     pub fn set(self: *Panel, contact_list_records: ?[]const *const ContactList) !void {
133 ⎥         self.lock.lock();
134 ⎥         defer self.lock.unlock();
135 ⎥         defer self.refresh();
136 ⎥ 
137 ⎥         // deinit the old records.
138 ⎥         if (self.contact_list_records) |deinit_contact_list_records| {
139 ⎥             for (deinit_contact_list_records) |deinit_contact_list_record| {
140 ⎥                 deinit_contact_list_record.deinit();
141 ⎥             }
142 ⎥             self.allocator.free(deinit_contact_list_records);
143 ⎥         }
144 ⎥         // add the new records;
145 ⎥         self.contact_list_records = contact_list_records;
146 ⎥     }
147 ⎥ 
148 ⎥     // handleClick owns param contact_list_record.
149 ⎥     fn handleClick(self: *Panel, contact_list_record: *const ContactList) !void {
150 ⎥         // Build the arguments for the modal call.
151 ⎥         // Modal args are owned by the modal screen. So do not deinit here.
152 ⎥         var choice_modal_args: *ModalParams = try ModalParams.init(self.allocator, contact_list_record.name.?);
153 ⎥         // Add each choice.
154 ⎥         try choice_modal_args.addChoiceItem(
155 ⎥             "Edit",
156 ⎥             self,
157 ⎥             @constCast(contact_list_record),
158 ⎥             &Panel.modalEditFn,
159 ⎥         );
160 ⎥         try choice_modal_args.addChoiceItem(
161 ⎥             "Remove",
162 ⎥             self,
163 ⎥             @constCast(contact_list_record),
164 ⎥             &Panel.modalRemoveFn,
165 ⎥         );
166 ⎥         try choice_modal_args.addChoiceItem(
167 ⎥             "Cancel",
168 ⎥             null,
169 ⎥             null,
170 ⎥             null,
171 ⎥         );
172 ⎥         // Show the Choice modal screen.
173 ⎥         self.main_view.showChoice(choice_modal_args);
174 ⎥     }
175 ⎥ 
176 ⎥     // Param context is owned by modalEditFn.
177 ⎥     fn modalEditFn(implementor: ?*anyopaque, context: ?*anyopaque) anyerror!void {
178 ⎥         var self: *Panel = @alignCast(@ptrCast(implementor.?));
179 ⎥         const contact_list_record: *const ContactList = @alignCast(@ptrCast(context.?));
180 ⎥         defer contact_list_record.deinit();
181 ⎥         // Pass a copy of the contact_list_record to the edit panel's fn set.
182 ⎥         const edit_panel_contact_copy: *const ContactList = try contact_list_record.copy();
183 ⎥         self.all_panels.Edit.?.set(edit_panel_contact_copy);
184 ⎥         self.all_panels.setCurrentToEdit();
185 ⎥     }
186 ⎥ 
187 ⎥     // Param context is owned by modalRemoveFn.
188 ⎥     fn modalRemoveFn(implementor: ?*anyopaque, context: ?*anyopaque) anyerror!void {
189 ⎥         var self: *Panel = @alignCast(@ptrCast(implementor.?));
190 ⎥         const contact_list_record: *const ContactList = @alignCast(@ptrCast(context.?));
191 ⎥         defer contact_list_record.deinit();
192 ⎥         const remove_panel_contact_copy: *const ContactList = contact_list_record.copy() catch |err| {
193 ⎥             self.exit(@src(), err, "contact_list_record.copy()");
194 ⎥             return err;
195 ⎥         };
196 ⎥         self.all_panels.Remove.?.set(remove_panel_contact_copy);
197 ⎥         self.all_panels.setCurrentToRemove();
198 ⎥     }
199 ⎥ };
200 ⎥ 
201 ⎥ pub fn init(allocator: std.mem.Allocator, main_view: *MainView, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panel {
202 ⎥     var panel: *Panel = try allocator.create(Panel);
203 ⎥     panel.lock = try _lock_.init(allocator);
204 ⎥     errdefer {
205 ⎥         allocator.destroy(panel);
206 ⎥     }
207 ⎥     panel.container = null;
208 ⎥     panel.allocator = allocator;
209 ⎥     panel.main_view = main_view;
210 ⎥     panel.all_panels = all_panels;
211 ⎥     panel.messenger = messenger;
212 ⎥     panel.exit = exit;
213 ⎥     panel.window = window;
214 ⎥     panel.contact_list_records = null;
215 ⎥     return panel;
216 ⎥ }
217 ⎥ 
```

## The Add panel

The add panel is just a form. The submit button passes the form info to the messenger in a ContactEdit record. The cancel button clears the form and if possible, switches to the select panel.

I added the following lines.

* line 8
* lines 30 - 34
* lines 45 - 133
* lines 137 - 141
* lines 167 - 215
* lines 232 - 238

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ const dvui = @import("dvui");
  3 ⎥ 
  4 ⎥ const _lock_ = @import("lock");
  5 ⎥ const _messenger_ = @import("messenger.zig");
  6 ⎥ const _panels_ = @import("panels.zig");
  7 ⎥ const _various_ = @import("various");
  8 ⎥ const Contact = @import("record").Add;
  9 ⎥ const ExitFn = @import("various").ExitFn;
 10 ⎥ const MainView = @import("framers").MainView;
 11 ⎥ 
 12 ⎥ // KICKZIG TODO:
 13 ⎥ // Remember. Defers happen in reverse order.
 14 ⎥ // When updating panel state.
 15 ⎥ //     self.lock();
 16 ⎥ //     defer self.unlock(); //  2nd defer: Unlocks.
 17 ⎥ //     defer self.refresh(); // 1st defer: Refreshes the main view.
 18 ⎥ //     // DO THE UPDATES.
 19 ⎥ 
 20 ⎥ pub const Panel = struct {
 21 ⎥     allocator: std.mem.Allocator, // For persistant state data.
 22 ⎥     lock: *_lock_.ThreadLock, // For persistant state data.
 23 ⎥     window: *dvui.Window,
 24 ⎥     main_view: *MainView,
 25 ⎥     container: ?*_various_.Container,
 26 ⎥     all_panels: *_panels_.Panels,
 27 ⎥     messenger: *_messenger_.Messenger,
 28 ⎥     exit: ExitFn,
 29 ⎥ 
 30 ⎥     name_buffer: []u8,
 31 ⎥     address_buffer: []u8,
 32 ⎥     city_buffer: []u8,
 33 ⎥     state_buffer: []u8,
 34 ⎥     zip_buffer: []u8,
 35 ⎥ 
 36 ⎥     /// frame this panel.
 37 ⎥     /// Layout, Draw, Handle user events.
 38 ⎥     /// The arena allocator is for building this frame. Not for state.
 39 ⎥     pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {
 40 ⎥         _ = arena;
 41 ⎥ 
 42 ⎥         self.lock.lock();
 43 ⎥         defer self.lock.unlock();
 44 ⎥ 
 45 ⎥         {
 46 ⎥             // Row 1: The screen's name.
 47 ⎥             // This row has a background because the scroller has a background.
 48 ⎥             var row: *dvui.BoxWidget = try dvui.box(
 49 ⎥                 @src(),
 50 ⎥                 .horizontal,
 51 ⎥                 .{
 52 ⎥                     .expand = .horizontal,
 53 ⎥                     .background = true,
 54 ⎥                 },
 55 ⎥             );
 56 ⎥             defer row.deinit();
 57 ⎥ 
 58 ⎥             try dvui.labelNoFmt(@src(), "Add a new contact.", .{ .font_style = .title });
 59 ⎥         }
 60 ⎥ 
 61 ⎥         var scroller = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
 62 ⎥         defer scroller.deinit();
 63 ⎥ 
 64 ⎥         var layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{});
 65 ⎥         defer layout.deinit();
 66 ⎥ 
 67 ⎥         {
 68 ⎥             // Row 2: This contact's name.
 69 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 70 ⎥             defer row.deinit();
 71 ⎥ 
 72 ⎥             try dvui.labelNoFmt(@src(), "Name:", .{ .font_style = .heading });
 73 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.name_buffer }, .{});
 74 ⎥             defer input.deinit();
 75 ⎥         }
 76 ⎥         {
 77 ⎥             // Row 3: This contact's address.
 78 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 79 ⎥             defer row.deinit();
 80 ⎥ 
 81 ⎥             try dvui.labelNoFmt(@src(), "Address:", .{ .font_style = .heading });
 82 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.address_buffer }, .{});
 83 ⎥             defer input.deinit();
 84 ⎥         }
 85 ⎥         {
 86 ⎥             // Row 4: This contact's city.
 87 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 88 ⎥             defer row.deinit();
 89 ⎥ 
 90 ⎥             try dvui.labelNoFmt(@src(), "City:", .{ .font_style = .heading });
 91 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.city_buffer }, .{});
 92 ⎥             defer input.deinit();
 93 ⎥         }
 94 ⎥         {
 95 ⎥             // Row 5: This contact's state.
 96 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 97 ⎥             defer row.deinit();
 98 ⎥ 
 99 ⎥             try dvui.labelNoFmt(@src(), "State:", .{ .font_style = .heading });
100 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.state_buffer }, .{});
101 ⎥             defer input.deinit();
102 ⎥         }
103 ⎥         {
104 ⎥             // Row 6: This contact's zip.
105 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
106 ⎥             defer row.deinit();
107 ⎥ 
108 ⎥             try dvui.labelNoFmt(@src(), "Zip:", .{ .font_style = .heading });
109 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.zip_buffer }, .{});
110 ⎥             defer input.deinit();
111 ⎥         }
112 ⎥         {
113 ⎥             // Row 7: Submit button.
114 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
115 ⎥             defer row.deinit();
116 ⎥             // Submit button.
117 ⎥             if (try dvui.button(@src(), "Submit.", .{}, .{})) {
118 ⎥                 // Submit this form.
119 ⎥                 // Create an add contact record to send to the back-end.
120 ⎥                 const contact_add_record: *Contact = try self.bufferToContact();
121 ⎥                 // sendAddContact owns contact_add_record.
122 ⎥                 try self.messenger.sendAddContact(contact_add_record);
123 ⎥             }
124 ⎥             // Row 8: Cancel button.
125 ⎥             if (try dvui.button(@src(), "Cancel.", .{}, .{})) {
126 ⎥                 // Clear the form.
127 ⎥                 self.clearBuffer();
128 ⎥                 // Switch to the select panel if there are contacts.
129 ⎥                 if (self.all_panels.Select.?.has_records()) {
130 ⎥                     self.all_panels.setCurrentToSelect();
131 ⎥                 }
132 ⎥             }
133 ⎥         }
134 ⎥     }
135 ⎥ 
136 ⎥     pub fn deinit(self: *Panel) void {
137 ⎥         self.allocator.free(self.name_buffer);
138 ⎥         self.allocator.free(self.address_buffer);
139 ⎥         self.allocator.free(self.city_buffer);
140 ⎥         self.allocator.free(self.state_buffer);
141 ⎥         self.allocator.free(self.zip_buffer);
142 ⎥ 
143 ⎥         // The screen will deinit the container.
144 ⎥         self.lock.deinit();
145 ⎥         self.allocator.destroy(self);
146 ⎥     }
147 ⎥ 
148 ⎥     /// refresh only if this panel and ( container or screen ) are showing.
149 ⎥     pub fn refresh(self: *Panel) void {
150 ⎥         if (self.all_panels.current_panel_tag == .Add) {
151 ⎥             // This is the current panel.
152 ⎥             if (self.container) |container| {
153 ⎥                 // Refresh the container.
154 ⎥                 // The container will refresh only if it's the currently viewed screen.
155 ⎥                 container.refresh();
156 ⎥             } else {
157 ⎥                 // Main view will refresh only if this is the currently viewed screen.
158 ⎥                 self.main_view.refreshContacts();
159 ⎥             }
160 ⎥         }
161 ⎥     }
162 ⎥ 
163 ⎥     pub fn setContainer(self: *Panel, container: *_various_.Container) void {
164 ⎥         self.container = container;
165 ⎥     }
166 ⎥ 
167 ⎥     pub fn clearBuffer(self: *Panel) void {
168 ⎥         @memset(self.name_buffer, 0);
169 ⎥         @memset(self.address_buffer, 0);
170 ⎥         @memset(self.city_buffer, 0);
171 ⎥         @memset(self.state_buffer, 0);
172 ⎥         @memset(self.zip_buffer, 0);
173 ⎥     }
174 ⎥ 
175 ⎥     fn bufferToContact(self: *Panel) !*Contact {
176 ⎥         const name_buffer_len: usize = std.mem.indexOf(u8, self.name_buffer, &[1]u8{0}) orelse self.name_buffer.len;
177 ⎥         const address_buffer_len: usize = std.mem.indexOf(u8, self.address_buffer, &[1]u8{0}) orelse self.address_buffer.len;
178 ⎥         const city_buffer_len: usize = std.mem.indexOf(u8, self.city_buffer, &[1]u8{0}) orelse self.city_buffer.len;
179 ⎥         const state_buffer_len: usize = std.mem.indexOf(u8, self.state_buffer, &[1]u8{0}) orelse self.state_buffer.len;
180 ⎥         const zip_buffer_len: usize = std.mem.indexOf(u8, self.zip_buffer, &[1]u8{0}) orelse self.zip_buffer.len;
181 ⎥ 
182 ⎥         const name: ?[]const u8 = switch (name_buffer_len) {
183 ⎥             0 => null,
184 ⎥             else => self.name_buffer[0..name_buffer_len],
185 ⎥         };
186 ⎥         const address: ?[]const u8 = switch (address_buffer_len) {
187 ⎥             0 => null,
188 ⎥             else => self.address_buffer[0..address_buffer_len],
189 ⎥         };
190 ⎥         const city: ?[]const u8 = switch (city_buffer_len) {
191 ⎥             0 => null,
192 ⎥             else => self.city_buffer[0..city_buffer_len],
193 ⎥         };
194 ⎥         const state: ?[]const u8 = switch (state_buffer_len) {
195 ⎥             0 => null,
196 ⎥             else => self.state_buffer[0..state_buffer_len],
197 ⎥         };
198 ⎥         const zip: ?[]const u8 = switch (zip_buffer_len) {
199 ⎥             0 => null,
200 ⎥             else => self.zip_buffer[0..zip_buffer_len],
201 ⎥         };
202 ⎥ 
203 ⎥         const contact: *Contact = Contact.init(
204 ⎥             self.allocator,
205 ⎥             name,
206 ⎥             address,
207 ⎥             city,
208 ⎥             state,
209 ⎥             zip,
210 ⎥         ) catch |err| {
211 ⎥             self.exit(@src(), err, "Contact.init(...)");
212 ⎥             return err;
213 ⎥         };
214 ⎥         return contact;
215 ⎥     }
216 ⎥ };
217 ⎥ 
218 ⎥ pub fn init(allocator: std.mem.Allocator, main_view: *MainView, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panel {
219 ⎥     var panel: *Panel = try allocator.create(Panel);
220 ⎥     panel.lock = try _lock_.init(allocator);
221 ⎥     errdefer {
222 ⎥         allocator.destroy(panel);
223 ⎥     }
224 ⎥     panel.container = null;
225 ⎥     panel.allocator = allocator;
226 ⎥     panel.main_view = main_view;
227 ⎥     panel.all_panels = all_panels;
228 ⎥     panel.messenger = messenger;
229 ⎥     panel.exit = exit;
230 ⎥     panel.window = window;
231 ⎥ 
232 ⎥     // The input buffers.
233 ⎥     panel.name_buffer = try allocator.alloc(u8, 255);
234 ⎥     panel.address_buffer = try allocator.alloc(u8, 255);
235 ⎥     panel.city_buffer = try allocator.alloc(u8, 255);
236 ⎥     panel.state_buffer = try allocator.alloc(u8, 255);
237 ⎥     panel.zip_buffer = try allocator.alloc(u8, 255);
238 ⎥     panel.clearBuffer();
239 ⎥ 
240 ⎥     return panel;
241 ⎥ }
242 ⎥ ```

## The Edit panel

The edit panels is just a form displaying a current record. The submit button passes the edits to the messenger in a ContactEdit record. The cancel button just switches to the Select panel.

I added the following lines.

* lines 8 - 9
* line 31 - 37
* lines 48 - 134
* lines 141 - 145
* lines 171 - 254
* lines 271 - 280

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ const dvui = @import("dvui");
  3 ⎥ 
  4 ⎥ const _lock_ = @import("lock");
  5 ⎥ const _messenger_ = @import("messenger.zig");
  6 ⎥ const _panels_ = @import("panels.zig");
  7 ⎥ const _various_ = @import("various");
  8 ⎥ const ContactEdit = @import("record").Edit;
  9 ⎥ const ContactList = @import("record").List;
 10 ⎥ const ExitFn = @import("various").ExitFn;
 11 ⎥ const MainView = @import("framers").MainView;
 12 ⎥ 
 13 ⎥ // KICKZIG TODO:
 14 ⎥ // Remember. Defers happen in reverse order.
 15 ⎥ // When updating panel state.
 16 ⎥ //     self.lock();
 17 ⎥ //     defer self.unlock(); //  2nd defer: Unlocks.
 18 ⎥ //     defer self.refresh(); // 1st defer: Refreshes the main view.
 19 ⎥ //     // DO THE UPDATES.
 20 ⎥ 
 21 ⎥ pub const Panel = struct {
 22 ⎥     allocator: std.mem.Allocator, // For persistant state data.
 23 ⎥     lock: *_lock_.ThreadLock, // For persistant state data.
 24 ⎥     window: *dvui.Window,
 25 ⎥     main_view: *MainView,
 26 ⎥     container: ?*_various_.Container,
 27 ⎥     all_panels: *_panels_.Panels,
 28 ⎥     messenger: *_messenger_.Messenger,
 29 ⎥     exit: ExitFn,
 30 ⎥ 
 31 ⎥     contact_list_record: ?*const ContactList,
 32 ⎥ 
 33 ⎥     name_buffer: []u8,
 34 ⎥     address_buffer: []u8,
 35 ⎥     city_buffer: []u8,
 36 ⎥     state_buffer: []u8,
 37 ⎥     zip_buffer: []u8,
 38 ⎥ 
 39 ⎥     /// frame this panel.
 40 ⎥     /// Layout, Draw, Handle user events.
 41 ⎥     /// The arena allocator is for building this frame. Not for state.
 42 ⎥     pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {
 43 ⎥         _ = arena;
 44 ⎥ 
 45 ⎥         self.lock.lock();
 46 ⎥         defer self.lock.unlock();
 47 ⎥ 
 48 ⎥         {
 49 ⎥             // Row 1: The screen's name.
 50 ⎥             // Use the same background as the scroller.
 51 ⎥             var row: *dvui.BoxWidget = try dvui.box(
 52 ⎥                 @src(),
 53 ⎥                 .horizontal,
 54 ⎥                 .{
 55 ⎥                     .expand = .horizontal,
 56 ⎥                     .background = true,
 57 ⎥                 },
 58 ⎥             );
 59 ⎥             defer row.deinit();
 60 ⎥ 
 61 ⎥             try dvui.labelNoFmt(@src(), "Edit a contact.", .{ .font_style = .title });
 62 ⎥         }
 63 ⎥ 
 64 ⎥         var scroller = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
 65 ⎥         defer scroller.deinit();
 66 ⎥ 
 67 ⎥         var layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{});
 68 ⎥         defer layout.deinit();
 69 ⎥ 
 70 ⎥         {
 71 ⎥             // Row 2: This contact's name.
 72 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 73 ⎥             defer row.deinit();
 74 ⎥ 
 75 ⎥             try dvui.labelNoFmt(@src(), "Name:", .{ .font_style = .heading });
 76 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.name_buffer }, .{});
 77 ⎥             defer input.deinit();
 78 ⎥         }
 79 ⎥         {
 80 ⎥             // Row 3: This contact's address.
 81 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 82 ⎥             defer row.deinit();
 83 ⎥ 
 84 ⎥             try dvui.labelNoFmt(@src(), "Address:", .{ .font_style = .heading });
 85 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.address_buffer }, .{});
 86 ⎥             defer input.deinit();
 87 ⎥         }
 88 ⎥         {
 89 ⎥             // Row 4: This contact's city.
 90 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 91 ⎥             defer row.deinit();
 92 ⎥ 
 93 ⎥             try dvui.labelNoFmt(@src(), "City:", .{ .font_style = .heading });
 94 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.city_buffer }, .{});
 95 ⎥             defer input.deinit();
 96 ⎥         }
 97 ⎥         {
 98 ⎥             // Row 5: This contact's state.
 99 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
100 ⎥             defer row.deinit();
101 ⎥ 
102 ⎥             try dvui.labelNoFmt(@src(), "State:", .{ .font_style = .heading });
103 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.state_buffer }, .{});
104 ⎥             defer input.deinit();
105 ⎥         }
106 ⎥         {
107 ⎥             // Row 6: This contact's zip.
108 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
109 ⎥             defer row.deinit();
110 ⎥ 
111 ⎥             try dvui.labelNoFmt(@src(), "Zip:", .{ .font_style = .heading });
112 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.zip_buffer }, .{});
113 ⎥             defer input.deinit();
114 ⎥         }
115 ⎥         {
116 ⎥             // Row 7: Submit or Cancel.
117 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
118 ⎥             defer row.deinit();
119 ⎥             // Submit button.
120 ⎥             if (try dvui.button(@src(), "Submit.", .{}, .{})) {
121 ⎥                 // Submit this form.
122 ⎥                 const contact_edit_record: *const ContactEdit = try self.bufferToContact();
123 ⎥                 try self.messenger.sendEditContact(contact_edit_record);
124 ⎥             }
125 ⎥             // Cancel button which switches to the select panel.
126 ⎥             if (try dvui.button(@src(), "Cancel.", .{}, .{})) {
127 ⎥                 // Switch to the select panel or the add panel.
128 ⎥                 if (self.all_panels.Select.?.has_records()) {
129 ⎥                     self.all_panels.setCurrentToSelect();
130 ⎥                 } else {
131 ⎥                     self.all_panels.setCurrentToAdd();
132 ⎥                 }
133 ⎥             }
134 ⎥         }
135 ⎥     }
136 ⎥ 
137 ⎥     pub fn deinit(self: *Panel) void {
138 ⎥         if (self.contact_list_record) |contact_list_record| {
139 ⎥             contact_list_record.deinit();
140 ⎥         }
141 ⎥         self.allocator.free(self.name_buffer);
142 ⎥         self.allocator.free(self.address_buffer);
143 ⎥         self.allocator.free(self.city_buffer);
144 ⎥         self.allocator.free(self.state_buffer);
145 ⎥         self.allocator.free(self.zip_buffer);
146 ⎥ 
147 ⎥         // The screen will deinit the container.
148 ⎥         self.lock.deinit();
149 ⎥         self.allocator.destroy(self);
150 ⎥     }
151 ⎥ 
152 ⎥     /// refresh only if this panel and ( container or screen ) are showing.
153 ⎥     pub fn refresh(self: *Panel) void {
154 ⎥         if (self.all_panels.current_panel_tag == .Edit) {
155 ⎥             // This is the current panel.
156 ⎥             if (self.container) |container| {
157 ⎥                 // Refresh the container.
158 ⎥                 // The container will refresh only if it's the currently viewed screen.
159 ⎥                 container.refresh();
160 ⎥             } else {
161 ⎥                 // Main view will refresh only if this is the currently viewed screen.
162 ⎥                 self.main_view.refreshContacts();
163 ⎥             }
164 ⎥         }
165 ⎥     }
166 ⎥ 
167 ⎥     pub fn setContainer(self: *Panel, container: *_various_.Container) void {
168 ⎥         self.container = container;
169 ⎥     }
170 ⎥ 
171 ⎥     // set is called by the select panel's modalEditFn.
172 ⎥     // handles and returns any error.
173 ⎥     // Param contact_list_record is owned by this fn. See Panel.deinit();
174 ⎥     pub fn set(self: *Panel, contact_list_record: *const ContactList) void {
175 ⎥         self.lock.lock();
176 ⎥         defer self.lock.unlock();
177 ⎥         defer self.refresh();
178 ⎥ 
179 ⎥         if (self.contact_list_record) |old_contact_list_record| {
180 ⎥             old_contact_list_record.deinit();
181 ⎥         }
182 ⎥         self.contact_list_record = contact_list_record;
183 ⎥         self.contactToBuffer();
184 ⎥     }
185 ⎥ 
186 ⎥     pub fn contactToBuffer(self: *Panel) void {
187 ⎥         self.clearBuffer();
188 ⎥         for (self.contact_list_record.?.name.?, 0..) |b, i| {
189 ⎥             self.name_buffer[i] = b;
190 ⎥         }
191 ⎥         for (self.contact_list_record.?.address.?, 0..) |b, i| {
192 ⎥             self.address_buffer[i] = b;
193 ⎥         }
194 ⎥         for (self.contact_list_record.?.city.?, 0..) |b, i| {
195 ⎥             self.city_buffer[i] = b;
196 ⎥         }
197 ⎥         for (self.contact_list_record.?.state.?, 0..) |b, i| {
198 ⎥             self.state_buffer[i] = b;
199 ⎥         }
200 ⎥         for (self.contact_list_record.?.zip.?, 0..) |b, i| {
201 ⎥             self.zip_buffer[i] = b;
202 ⎥         }
203 ⎥     }
204 ⎥ 
205 ⎥     fn bufferToContact(self: *Panel) !*const ContactEdit {
206 ⎥         const name_buffer_len: usize = std.mem.indexOf(u8, self.name_buffer, &[1]u8{0}) orelse self.name_buffer.len;
207 ⎥         const address_buffer_len: usize = std.mem.indexOf(u8, self.address_buffer, &[1]u8{0}) orelse self.address_buffer.len;
208 ⎥         const city_buffer_len: usize = std.mem.indexOf(u8, self.city_buffer, &[1]u8{0}) orelse self.city_buffer.len;
209 ⎥         const state_buffer_len: usize = std.mem.indexOf(u8, self.state_buffer, &[1]u8{0}) orelse self.state_buffer.len;
210 ⎥         const zip_buffer_len: usize = std.mem.indexOf(u8, self.zip_buffer, &[1]u8{0}) orelse self.zip_buffer.len;
211 ⎥ 
212 ⎥         const name: ?[]const u8 = switch (name_buffer_len) {
213 ⎥             0 => null,
214 ⎥             else => self.name_buffer[0..name_buffer_len],
215 ⎥         };
216 ⎥         const address: ?[]const u8 = switch (address_buffer_len) {
217 ⎥             0 => null,
218 ⎥             else => self.address_buffer[0..address_buffer_len],
219 ⎥         };
220 ⎥         const city: ?[]const u8 = switch (city_buffer_len) {
221 ⎥             0 => null,
222 ⎥             else => self.city_buffer[0..city_buffer_len],
223 ⎥         };
224 ⎥         const state: ?[]const u8 = switch (state_buffer_len) {
225 ⎥             0 => null,
226 ⎥             else => self.state_buffer[0..state_buffer_len],
227 ⎥         };
228 ⎥         const zip: ?[]const u8 = switch (zip_buffer_len) {
229 ⎥             0 => null,
230 ⎥             else => self.zip_buffer[0..zip_buffer_len],
231 ⎥         };
232 ⎥ 
233 ⎥         const contact: *const ContactEdit = ContactEdit.init(
234 ⎥             self.allocator,
235 ⎥             self.contact_list_record.?.id,
236 ⎥             name,
237 ⎥             address,
238 ⎥             city,
239 ⎥             state,
240 ⎥             zip,
241 ⎥         ) catch |err| {
242 ⎥             self.exit(@src(), err, "ContactEdit.init(...)");
243 ⎥             return err;
244 ⎥         };
245 ⎥         return contact;
246 ⎥     }
247 ⎥ 
248 ⎥     fn clearBuffer(self: *Panel) void {
249 ⎥         @memset(self.name_buffer, 0);
250 ⎥         @memset(self.address_buffer, 0);
251 ⎥         @memset(self.city_buffer, 0);
252 ⎥         @memset(self.state_buffer, 0);
253 ⎥         @memset(self.zip_buffer, 0);
254 ⎥     }
255 ⎥ };
256 ⎥ 
257 ⎥ pub fn init(allocator: std.mem.Allocator, main_view: *MainView, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panel {
258 ⎥     var panel: *Panel = try allocator.create(Panel);
259 ⎥     panel.lock = try _lock_.init(allocator);
260 ⎥     errdefer {
261 ⎥         allocator.destroy(panel);
262 ⎥     }
263 ⎥     panel.container = null;
264 ⎥     panel.allocator = allocator;
265 ⎥     panel.main_view = main_view;
266 ⎥     panel.all_panels = all_panels;
267 ⎥     panel.messenger = messenger;
268 ⎥     panel.exit = exit;
269 ⎥     panel.window = window;
270 ⎥ 
271 ⎥     // The contact list record.
272 ⎥     panel.contact_list_record = null;
273 ⎥ 
274 ⎥     // The input buffers.
275 ⎥     panel.name_buffer = try allocator.alloc(u8, 255);
276 ⎥     panel.address_buffer = try allocator.alloc(u8, 255);
277 ⎥     panel.city_buffer = try allocator.alloc(u8, 255);
278 ⎥     panel.state_buffer = try allocator.alloc(u8, 255);
279 ⎥     panel.zip_buffer = try allocator.alloc(u8, 255);
280 ⎥     panel.clearBuffer();
281 ⎥ 
282 ⎥     return panel;
283 ⎥ }
284 ⎥ 
```

## The Remove panel

The remove panel displays a contact record. The submit button passes the record id to the messenger in a ContactRemove record. The cancel button just switches to the Select panel.

I added the following lines.

* lines 8 - 9
* line 31, 33
* lines 44 - 128
* lines 132 - 134
* lines 160 - 171
* lines 188 - 189

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ const dvui = @import("dvui");
  3 ⎥ 
  4 ⎥ const _lock_ = @import("lock");
  5 ⎥ const _messenger_ = @import("messenger.zig");
  6 ⎥ const _panels_ = @import("panels.zig");
  7 ⎥ const _various_ = @import("various");
  8 ⎥ const ContactList = @import("record").List;
  9 ⎥ const ContactRemove = @import("record").Remove;
 10 ⎥ const ExitFn = @import("various").ExitFn;
 11 ⎥ const MainView = @import("framers").MainView;
 12 ⎥ 
 13 ⎥ // KICKZIG TODO:
 14 ⎥ // Remember. Defers happen in reverse order.
 15 ⎥ // When updating panel state.
 16 ⎥ //     self.lock();
 17 ⎥ //     defer self.unlock(); //  2nd defer: Unlocks.
 18 ⎥ //     defer self.refresh(); // 1st defer: Refreshes the main view.
 19 ⎥ //     // DO THE UPDATES.
 20 ⎥ 
 21 ⎥ pub const Panel = struct {
 22 ⎥     allocator: std.mem.Allocator, // For persistant state data.
 23 ⎥     lock: *_lock_.ThreadLock, // For persistant state data.
 24 ⎥     window: *dvui.Window,
 25 ⎥     main_view: *MainView,
 26 ⎥     container: ?*_various_.Container,
 27 ⎥     all_panels: *_panels_.Panels,
 28 ⎥     messenger: *_messenger_.Messenger,
 29 ⎥     exit: ExitFn,
 30 ⎥ 
 31 ⎥     contact_list_record: ?*const ContactList,
 32 ⎥ 
 33 ⎥     const grav: dvui.Options = .{ .gravity_x = 0.5, .gravity_y = 0.5 };
 34 ⎥ 
 35 ⎥     /// frame this panel.
 36 ⎥     /// Layout, Draw, Handle user events.
 37 ⎥     /// The arena allocator is for building this frame. Not for state.
 38 ⎥     pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {
 39 ⎥         _ = arena;
 40 ⎥ 
 41 ⎥         self.lock.lock();
 42 ⎥         defer self.lock.unlock();
 43 ⎥ 
 44 ⎥         {
 45 ⎥             // Row 1: The screen's name.
 46 ⎥             // Use the same background as the scroller.
 47 ⎥             var row: *dvui.BoxWidget = try dvui.box(
 48 ⎥                 @src(),
 49 ⎥                 .horizontal,
 50 ⎥                 .{
 51 ⎥                     .expand = .horizontal,
 52 ⎥                     .background = true,
 53 ⎥                 },
 54 ⎥             );
 55 ⎥             defer row.deinit();
 56 ⎥ 
 57 ⎥             try dvui.labelNoFmt(@src(), "Remove a contact.", .{ .font_style = .title });
 58 ⎥         }
 59 ⎥ 
 60 ⎥         var scroller = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
 61 ⎥         defer scroller.deinit();
 62 ⎥ 
 63 ⎥         var layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{});
 64 ⎥         defer layout.deinit();
 65 ⎥ 
 66 ⎥         {
 67 ⎥             // Row 2: This contact's name.
 68 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 69 ⎥             defer row.deinit();
 70 ⎥ 
 71 ⎥             try dvui.labelNoFmt(@src(), "Name:", .{ .font_style = .heading });
 72 ⎥             try dvui.labelNoFmt(@src(), self.contact_list_record.?.name.?, .{});
 73 ⎥         }
 74 ⎥         {
 75 ⎥             // Row 3: This contact's address.
 76 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 77 ⎥             defer row.deinit();
 78 ⎥ 
 79 ⎥             try dvui.labelNoFmt(@src(), "Address:", .{ .font_style = .heading });
 80 ⎥             try dvui.labelNoFmt(@src(), self.contact_list_record.?.address.?, .{});
 81 ⎥         }
 82 ⎥         {
 83 ⎥             // Row 4: This contact's city.
 84 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 85 ⎥             defer row.deinit();
 86 ⎥ 
 87 ⎥             try dvui.labelNoFmt(@src(), "City:", .{ .font_style = .heading });
 88 ⎥             try dvui.labelNoFmt(@src(), self.contact_list_record.?.city.?, .{});
 89 ⎥         }
 90 ⎥         {
 91 ⎥             // Row 5: This contact's state.
 92 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 93 ⎥             defer row.deinit();
 94 ⎥ 
 95 ⎥             try dvui.labelNoFmt(@src(), "State:", .{ .font_style = .heading });
 96 ⎥             try dvui.labelNoFmt(@src(), self.contact_list_record.?.state.?, .{});
 97 ⎥         }
 98 ⎥         {
 99 ⎥             // Row 6: This contact's zip.
100 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
101 ⎥             defer row.deinit();
102 ⎥ 
103 ⎥             try dvui.labelNoFmt(@src(), "Zip:", .{ .font_style = .heading });
104 ⎥             try dvui.labelNoFmt(@src(), self.contact_list_record.?.zip.?, .{});
105 ⎥         }
106 ⎥         {
107 ⎥             // Row 7: Submit or Cancel.
108 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
109 ⎥             defer row.deinit();
110 ⎥             // Submit button.
111 ⎥             if (try dvui.button(@src(), "Submit.", .{}, .{})) {
112 ⎥                 // Submit this form.
113 ⎥                 const contact_remove_record: *ContactRemove = try ContactRemove.init(
114 ⎥                     self.allocator,
115 ⎥                     self.contact_list_record.?.id,
116 ⎥                 );
117 ⎥                 try self.messenger.sendRemoveContact(contact_remove_record);
118 ⎥             }
119 ⎥             // Cancel button which switches to the select panel.
120 ⎥             if (try dvui.button(@src(), "Cancel.", .{}, .{})) {
121 ⎥                 // Switch to the select panel or the add panel.
122 ⎥                 if (self.all_panels.Select.?.has_records()) {
123 ⎥                     self.all_panels.setCurrentToSelect();
124 ⎥                 } else {
125 ⎥                     self.all_panels.setCurrentToAdd();
126 ⎥                 }
127 ⎥             }
128 ⎥         }
129 ⎥     }
130 ⎥ 
131 ⎥     pub fn deinit(self: *Panel) void {
132 ⎥         if (self.contact_list_record) |contact_list_record| {
133 ⎥             contact_list_record.deinit();
134 ⎥         }
135 ⎥ 
136 ⎥         // The screen will deinit the container.
137 ⎥         self.lock.deinit();
138 ⎥         self.allocator.destroy(self);
139 ⎥     }
140 ⎥ 
141 ⎥     /// refresh only if this panel and ( container or screen ) are showing.
142 ⎥     pub fn refresh(self: *Panel) void {
143 ⎥         if (self.all_panels.current_panel_tag == .Remove) {
144 ⎥             // This is the current panel.
145 ⎥             if (self.container) |container| {
146 ⎥                 // Refresh the container.
147 ⎥                 // The container will refresh only if it's the currently viewed screen.
148 ⎥                 container.refresh();
149 ⎥             } else {
150 ⎥                 // Main view will refresh only if this is the currently viewed screen.
151 ⎥                 self.main_view.refreshContacts();
152 ⎥             }
153 ⎥         }
154 ⎥     }
155 ⎥ 
156 ⎥     pub fn setContainer(self: *Panel, container: *_various_.Container) void {
157 ⎥         self.container = container;
158 ⎥     }
159 ⎥ 
160 ⎥     // set is called by the select panel's modalRemoveFn.
161 ⎥     // Param contact_list_record is owned by this fn. See Panel.deinit();
162 ⎥     pub fn set(self: *Panel, contact_list_record: *const ContactList) void {
163 ⎥         self.lock.lock();
164 ⎥         defer self.lock.unlock();
165 ⎥         defer self.refresh();
166 ⎥ 
167 ⎥         if (self.contact_list_record) |old_contact_list_record| {
168 ⎥             old_contact_list_record.deinit();
169 ⎥         }
170 ⎥         self.contact_list_record = contact_list_record;
171 ⎥     }
172 ⎥ };
173 ⎥ 
174 ⎥ pub fn init(allocator: std.mem.Allocator, main_view: *MainView, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panel {
175 ⎥     var panel: *Panel = try allocator.create(Panel);
176 ⎥     panel.lock = try _lock_.init(allocator);
177 ⎥     errdefer {
178 ⎥         allocator.destroy(panel);
179 ⎥     }
180 ⎥     panel.container = null;
181 ⎥     panel.allocator = allocator;
182 ⎥     panel.main_view = main_view;
183 ⎥     panel.all_panels = all_panels;
184 ⎥     panel.messenger = messenger;
185 ⎥     panel.exit = exit;
186 ⎥     panel.window = window;
187 ⎥ 
188 ⎥     // The contact list record.
189 ⎥     panel.contact_list_record = null;
190 ⎥ 
191 ⎥     return panel;
192 ⎥ }
193 ⎥ 
```

## The messenger

The messenger communicates with the back-end.

I added the following lines.

* lines 7, 8, 11 & 12 // Imports.

* line 27 - 50 // RebuildContactList message handler.
* line 52 - 85 // AddContact message handlers.
* lines 87 - 125 // EditContact message handlers.
* lines 127 - 171 // RemoveContact message handlers.

* lines 182 - 194 // RebuildContactList subscription.
* lines 196 - 208 // AddContact subscription.
* lines 210 - 222 // EditContact subscription.
* lines 224 - 236 // RemoveContact subscription.

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ 
  3 ⎥ const _channel_ = @import("channel");
  4 ⎥ const _message_ = @import("message");
  5 ⎥ const _modal_params_ = @import("modal_params");
  6 ⎥ const _panels_ = @import("panels.zig");
  7 ⎥ const AddContact = @import("record").Add;
  8 ⎥ const EditContact = @import("record").Edit;
  9 ⎥ const ExitFn = @import("various").ExitFn;
 10 ⎥ const MainView = @import("framers").MainView;
 11 ⎥ const OKModalParams = @import("modal_params").OK;
 12 ⎥ const RemoveContact = @import("record").Remove;
 13 ⎥ 
 14 ⎥ pub const Messenger = struct {
 15 ⎥     allocator: std.mem.Allocator,
 16 ⎥ 
 17 ⎥     main_view: *MainView,
 18 ⎥     all_panels: *_panels_.Panels,
 19 ⎥     send_channels: *_channel_.FrontendToBackend,
 20 ⎥     receive_channels: *_channel_.BackendToFrontend,
 21 ⎥     exit: ExitFn,
 22 ⎥ 
 23 ⎥     pub fn deinit(self: *Messenger) void {
 24 ⎥         self.allocator.destroy(self);
 25 ⎥     }
 26 ⎥ 
 27 ⎥     // RebuildContactList messages.
 28 ⎥ 
 29 ⎥     // receiveRebuildContactList receives the RebuildContactList message.
 30 ⎥     // It implements a behavior required by receive_channels.RebuildContactList.
 31 ⎥     // Errors are handled and returned.
 32 ⎥     pub fn receiveRebuildContactList(implementor: *anyopaque, message: *_message_.RebuildContactList.Message) anyerror!void {
 33 ⎥         std.log.debug("receiveRebuildContactList", .{});
 34 ⎥         var self: *Messenger = @alignCast(@ptrCast(implementor));
 35 ⎥         defer message.deinit();
 36 ⎥         var select_panel = self.all_panels.Select.?;
 37 ⎥         var contacts = message.backend_payload.copyContacts() catch |err| {
 38 ⎥             self.exit(@src(), err, "message.backend_payload.copyContacts()");
 39 ⎥             return err;
 40 ⎥         };
 41 ⎥         select_panel.set(contacts) catch |err| {
 42 ⎥             self.exit(@src(), err, "select_panel.set(contacts)");
 43 ⎥             return err;
 44 ⎥         };
 45 ⎥         if (select_panel.has_records()) {
 46 ⎥             self.all_panels.setCurrentToSelect();
 47 ⎥         } else {
 48 ⎥             self.all_panels.setCurrentToAdd();
 49 ⎥         }
 50 ⎥     }
 51 ⎥ 
 52 ⎥     // AddContact messages.
 53 ⎥ 
 54 ⎥     pub fn sendAddContact(self: *Messenger, contact: *AddContact) !void {
 55 ⎥         var msg: *_message_.AddContact.Message = try _message_.AddContact.init(self.allocator);
 56 ⎥         try msg.frontend_payload.set(.{ .contact = contact });
 57 ⎥         errdefer msg.deinit();
 58 ⎥         // send will deinit msg even if there is an error.
 59 ⎥         try self.send_channels.AddContact.send(msg);
 60 ⎥     }
 61 ⎥ 
 62 ⎥     // receiveAddContact receives the AddContact message.
 63 ⎥     // It implements a behavior required by receive_channels.AddContact.
 64 ⎥     // Errors are handled and returned.
 65 ⎥     pub fn receiveAddContact(implementor: *anyopaque, message: *_message_.AddContact.Message) anyerror!void {
 66 ⎥         var self: *Messenger = @alignCast(@ptrCast(implementor));
 67 ⎥         defer message.deinit();
 68 ⎥ 
 69 ⎥         if (message.backend_payload.user_error_message) |user_error_message| {
 70 ⎥             // The back-end is reporting a user error.
 71 ⎥             var ok_args = OKModalParams.init(self.allocator, "Error.", user_error_message) catch |err| {
 72 ⎥                 self.exit(@src(), err, "OKModalParams.init(self.allocator, \"Error.\", user_error_message)");
 73 ⎥                 return err;
 74 ⎥             };
 75 ⎥             self.main_view.showOK(ok_args);
 76 ⎥             return;
 77 ⎥         }
 78 ⎥         // No user errors.
 79 ⎥         var ok_args = OKModalParams.init(self.allocator, "Success.", "The contact was added.") catch |err| {
 80 ⎥             self.exit(@src(), err, "OKModalParams.init(self.allocator, \"Success.\", \"The contact was added.\")");
 81 ⎥             return err;
 82 ⎥         };
 83 ⎥         self.main_view.showOK(ok_args);
 84 ⎥         self.all_panels.Add.?.clearBuffer();
 85 ⎥     }
 86 ⎥ 
 87 ⎥     // EditContact messages.
 88 ⎥ 
 89 ⎥     pub fn sendEditContact(self: *Messenger, contact: *const EditContact) !void {
 90 ⎥         var msg: *_message_.EditContact.Message = try _message_.EditContact.init(self.allocator);
 91 ⎥         try msg.frontend_payload.set(.{ .contact = contact });
 92 ⎥         errdefer msg.deinit();
 93 ⎥         // send will deinit msg even if there is an error.
 94 ⎥         try self.send_channels.EditContact.send(msg);
 95 ⎥     }
 96 ⎥ 
 97 ⎥     // receiveEditContact receives the EditContact message.
 98 ⎥     // It implements a behavior required by receive_channels.EditContact.
 99 ⎥     // Errors are handled and returned.
100 ⎥     pub fn receiveEditContact(implementor: *anyopaque, message: *_message_.EditContact.Message) anyerror!void {
101 ⎥         var self: *Messenger = @alignCast(@ptrCast(implementor));
102 ⎥         defer message.deinit();
103 ⎥ 
104 ⎥         if (message.backend_payload.user_error_message) |user_error_message| {
105 ⎥             // The back-end is reporting a user error.
106 ⎥             var ok_args = OKModalParams.init(self.allocator, "Error.", user_error_message) catch |err| {
107 ⎥                 self.exit(@src(), err, "OKModalParams.init(self.allocator, \"Error.\", user_error_message)");
108 ⎥                 return err;
109 ⎥             };
110 ⎥             self.main_view.showOK(ok_args);
111 ⎥             return;
112 ⎥         }
113 ⎥         // No user errors.
114 ⎥         var ok_args = OKModalParams.init(self.allocator, "Success.", "The contact was updated.") catch |err| {
115 ⎥             self.exit(@src(), err, "OKModalParams.init(self.allocator, \"Success.\", \"The contact was updated.\")");
116 ⎥             return err;
117 ⎥         };
118 ⎥         self.main_view.showOK(ok_args);
119 ⎥         // Display the correct panel. Either select or add.
120 ⎥         if (self.all_panels.Select.?.has_records()) {
121 ⎥             self.all_panels.setCurrentToSelect();
122 ⎥         } else {
123 ⎥             self.all_panels.setCurrentToAdd();
124 ⎥         }
125 ⎥     }
126 ⎥ 
127 ⎥     // RemoveContact messages.
128 ⎥ 
129 ⎥     pub fn sendRemoveContact(self: *Messenger, contact: *RemoveContact) !void {
130 ⎥         var msg: *_message_.RemoveContact.Message = _message_.RemoveContact.init(self.allocator) catch |err| {
131 ⎥             self.exit(@src(), err, "_message_.RemoveContact.init(self.allocator)");
132 ⎥             return err;
133 ⎥         };
134 ⎥         msg.frontend_payload.set(.{ .contact = contact }) catch |err| {
135 ⎥             self.exit(@src(), err, "msg.frontend_payload.set(.{ .contact = contact })");
136 ⎥             msg.deinit();
137 ⎥             return err;
138 ⎥         };
139 ⎥         // send will deinit msg even if there is an error.
140 ⎥         try self.send_channels.RemoveContact.send(msg);
141 ⎥     }
142 ⎥ 
143 ⎥     // receiveRemoveContact receives the RemoveContact message.
144 ⎥     // It implements a behavior required by receive_channels.RemoveContact.
145 ⎥     // Errors are handled and returned.
146 ⎥     pub fn receiveRemoveContact(implementor: *anyopaque, message: *_message_.RemoveContact.Message) anyerror!void {
147 ⎥         var self: *Messenger = @alignCast(@ptrCast(implementor));
148 ⎥         defer message.deinit();
149 ⎥ 
150 ⎥         if (message.backend_payload.user_error_message) |user_error_message| {
151 ⎥             // The back-end is reporting a user error.
152 ⎥             var ok_args = OKModalParams.init(self.allocator, "Error.", user_error_message) catch |err| {
153 ⎥                 self.exit(@src(), err, "OKModalParams.init(self.allocator, \"Error.\", user_error_message)");
154 ⎥                 return;
155 ⎥             };
156 ⎥             self.main_view.showOK(ok_args);
157 ⎥             return;
158 ⎥         }
159 ⎥         // No user errors.
160 ⎥         var ok_args = OKModalParams.init(self.allocator, "Success.", "The contact was removed.") catch |err| {
161 ⎥             self.exit(@src(), err, "OKModalParams.init(self.allocator, \"Success.\", \"The contact was removed.\")");
162 ⎥             return;
163 ⎥         };
164 ⎥         self.main_view.showOK(ok_args);
165 ⎥         // Display the correct panel. Either select or add.
166 ⎥         if (self.all_panels.Select.?.has_records()) {
167 ⎥             self.all_panels.setCurrentToSelect();
168 ⎥         } else {
169 ⎥             self.all_panels.setCurrentToAdd();
170 ⎥         }
171 ⎥     }
172 ⎥ };
173 ⎥ 
174 ⎥ pub fn init(allocator: std.mem.Allocator, main_view: *MainView, send_channels: *_channel_.FrontendToBackend, receive_channels: *_channel_.BackendToFrontend, exit: ExitFn) !*Messenger {
175 ⎥     var messenger: *Messenger = try allocator.create(Messenger);
176 ⎥     messenger.allocator = allocator;
177 ⎥     messenger.main_view = main_view;
178 ⎥     messenger.send_channels = send_channels;
179 ⎥     messenger.receive_channels = receive_channels;
180 ⎥     messenger.exit = exit;
181 ⎥ 
182 ⎥     // The RebuildContactList message.
183 ⎥     // * Define the required behavior.
184 ⎥     var rebuild_contact_list_behavior = try receive_channels.RebuildContactList.initBehavior();
185 ⎥     errdefer {
186 ⎥         allocator.destroy(messenger);
187 ⎥     }
188 ⎥     rebuild_contact_list_behavior.implementor = messenger;
189 ⎥     rebuild_contact_list_behavior.receiveFn = &Messenger.receiveRebuildContactList;
190 ⎥     // * Subscribe in order to receive the RebuildContactList messages.
191 ⎥     try receive_channels.RebuildContactList.subscribe(rebuild_contact_list_behavior);
192 ⎥     errdefer {
193 ⎥         allocator.destroy(messenger);
194 ⎥     }
195 ⎥ 
196 ⎥     // The AddContact message.
197 ⎥     // * Define the required behavior.
198 ⎥     var add_contact_behavior = try receive_channels.AddContact.initBehavior();
199 ⎥     errdefer {
200 ⎥         allocator.destroy(messenger);
201 ⎥     }
202 ⎥     add_contact_behavior.implementor = messenger;
203 ⎥     add_contact_behavior.receiveFn = Messenger.receiveAddContact;
204 ⎥     // * Subscribe in order to receive the AddContact messages.
205 ⎥     try receive_channels.AddContact.subscribe(add_contact_behavior);
206 ⎥     errdefer {
207 ⎥         allocator.destroy(messenger);
208 ⎥     }
209 ⎥ 
210 ⎥     // The EditContact message.
211 ⎥     // * Define the required behavior.
212 ⎥     var edit_contact_behavior = try receive_channels.EditContact.initBehavior();
213 ⎥     errdefer {
214 ⎥         allocator.destroy(messenger);
215 ⎥     }
216 ⎥     edit_contact_behavior.implementor = messenger;
217 ⎥     edit_contact_behavior.receiveFn = Messenger.receiveEditContact;
218 ⎥     // * Subscribe in order to receive the EditContact messages.
219 ⎥     try receive_channels.EditContact.subscribe(edit_contact_behavior);
220 ⎥     errdefer {
221 ⎥         allocator.destroy(messenger);
222 ⎥     }
223 ⎥ 
224 ⎥     // The RemoveContact message.
225 ⎥     // * Define the required behavior.
226 ⎥     var remove_contact_behavior = try receive_channels.RemoveContact.initBehavior();
227 ⎥     errdefer {
228 ⎥         allocator.destroy(messenger);
229 ⎥     }
230 ⎥     remove_contact_behavior.implementor = messenger;
231 ⎥     remove_contact_behavior.receiveFn = Messenger.receiveRemoveContact;
232 ⎥     // * Subscribe in order to receive the RemoveContact messages.
233 ⎥     try receive_channels.RemoveContact.subscribe(remove_contact_behavior);
234 ⎥     errdefer {
235 ⎥         allocator.destroy(messenger);
236 ⎥     }
237 ⎥ 
238 ⎥     return messenger;
239 ⎥ }
240 ⎥ 
```

## Next

* [[The New Startup Screen.|The-New-Startup-Screen]]
