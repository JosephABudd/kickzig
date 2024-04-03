The Contacts screen will be a Panel screen. A Panel screen simply switches from one panel to another. Only one panel is ever displayed at a time.

The contacts panel screen will have:

* a panel for selecting a contact.
* a panel for adding a new contact,
* a panel for editing a selected contact,
* a panel for confirming the removal of a selected contact,

```shell
＄ kickzig screen add-panel Contacts Select Add Edit Remove
Added the front-end «Contacts» Panel screen at /home/nil/zig/misc/crud/src/@This/frontend/screen/panel/Contacts/screen.zig:1:1:
```

## The select panel

The select panel is shown below. The panel begins with the contact's name at the left and an Add icon at the right for adding a new contact. The Add icon simply switches from the Select panel to the Add panel.

Below that is the scrolling list of buttons. Each button displays a contact record. Clicking a button opens the Choice modal screen which allows the user to edit or remove the contact.

I added the following lines.

* line 8, 9 & 12
* lines 47 - 77
* lines 105 - 181
* line 197

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
 41 ⎥         var scroller = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
 42 ⎥         defer scroller.deinit();
 43 ⎥ 
 44 ⎥         var layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{});
 45 ⎥         defer layout.deinit();
 46 ⎥ 
 47 ⎥         {
 48 ⎥             // Row 1: The screen's name.
 49 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{ .expand = .horizontal });
 50 ⎥             defer row.deinit();
 51 ⎥ 
 52 ⎥             try dvui.labelNoFmt(@src(), "Select a Contact.", .{ .font_style = .title, .gravity_x = 0.0 });
 53 ⎥             if (try dvui.buttonIcon(@src(), "AddAContactButton", dvui.entypo.add_to_list, .{}, .{ .gravity_x = 1.0 })) {
 54 ⎥                 self.all_panels.setCurrentToAdd();
 55 ⎥             }
 56 ⎥         }
 57 ⎥         {
 58 ⎥             // Row 2: List of contacts.
 59 ⎥             var contact_list_scroller = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
 60 ⎥             defer contact_list_scroller.deinit();
 61 ⎥ 
 62 ⎥             {
 63 ⎥                 var contact_list_scroller_layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{ .expand = .horizontal });
 64 ⎥                 defer contact_list_scroller_layout.deinit();
 65 ⎥ 
 66 ⎥                 if (self.contact_list_records) |contact_list_records| {
 67 ⎥                     for (contact_list_records, 0..) |contact_list_record, i| {
 68 ⎥                         var label = try std.fmt.allocPrint(arena, "{s}\n{s}\n{s}, {s} {s}", .{ contact_list_record.name.?, contact_list_record.address.?, contact_list_record.city.?, contact_list_record.state.?, contact_list_record.zip.? });
 69 ⎥                         if (try dvui.button(@src(), label, .{}, .{ .expand = .both, .id_extra = i })) {
 70 ⎥                             // user selected this contact.
 71 ⎥                             const contact_copy = try contact_list_record.copy();
 72 ⎥                             try self.handleClick(contact_copy);
 73 ⎥                         }
 74 ⎥                     }
 75 ⎥                 }
 76 ⎥             }
 77 ⎥         }
 78 ⎥     }
 79 ⎥ 
 80 ⎥     pub fn deinit(self: *Panel) void {
 81 ⎥         // The screen will deinit the container.
 82 ⎥         self.lock.deinit();
 83 ⎥         self.allocator.destroy(self);
 84 ⎥     }
 85 ⎥ 
 86 ⎥     /// refresh only if this panel and ( container or screen ) are showing.
 87 ⎥     pub fn refresh(self: *Panel) void {
 88 ⎥         if (self.all_panels.current_panel_tag == .Select) {
 89 ⎥             // This is the current panel.
 90 ⎥             if (self.container) |container| {
 91 ⎥                 // Refresh the container.
 92 ⎥                 // The container will refresh only if it's the currently viewed screen.
 93 ⎥                 container.refresh();
 94 ⎥             } else {
 95 ⎥                 // Main view will refresh only if this is the currently viewed screen.
 96 ⎥                 self.main_view.refreshContacts();
 97 ⎥             }
 98 ⎥         }
 99 ⎥     }
100 ⎥ 
101 ⎥     pub fn setContainer(self: *Panel, container: *_various_.Container) void {
102 ⎥         self.container = container;
103 ⎥     }
104 ⎥ 
105 ⎥     pub fn has_records(self: *Panel) bool {
106 ⎥         self.lock.lock();
107 ⎥         defer self.lock.unlock();
108 ⎥ 
109 ⎥         return (self.contact_list_records != null);
110 ⎥     }
111 ⎥ 
112 ⎥     // set is called by the messenger.
113 ⎥     // on handles and returns any error.
114 ⎥     // Param contact_list_records is owned by this fn.
115 ⎥     pub fn set(self: *Panel, contact_list_records: ?[]const *const ContactList) !void {
116 ⎥         self.lock.lock();
117 ⎥         defer self.lock.unlock();
118 ⎥         defer self.refresh();
119 ⎥ 
120 ⎥         // deinit the old records.
121 ⎥         if (self.contact_list_records) |deinit_contact_list_records| {
122 ⎥             for (deinit_contact_list_records) |deinit_contact_list_record| {
123 ⎥                 deinit_contact_list_record.deinit();
124 ⎥             }
125 ⎥             self.allocator.free(deinit_contact_list_records);
126 ⎥         }
127 ⎥         // add the new records;
128 ⎥         self.contact_list_records = contact_list_records;
129 ⎥     }
130 ⎥ 
131 ⎥     // handleClick owns param contact_list_record.
132 ⎥     fn handleClick(self: *Panel, contact_list_record: *const ContactList) !void {
133 ⎥         // Build the arguments for the modal call.
134 ⎥         // Modal args are owned by the modal screen. So do not deinit here.
135 ⎥         var choice_modal_args: *ModalParams = try ModalParams.init(self.allocator, contact_list_record.name.?);
136 ⎥         // Add each choice.
137 ⎥         try choice_modal_args.addChoiceItem(
138 ⎥             "Edit",
139 ⎥             self,
140 ⎥             @constCast(contact_list_record),
141 ⎥             &Panel.modalEditFn,
142 ⎥         );
143 ⎥         try choice_modal_args.addChoiceItem(
144 ⎥             "Remove",
145 ⎥             self,
146 ⎥             @constCast(contact_list_record),
147 ⎥             &Panel.modalRemoveFn,
148 ⎥         );
149 ⎥         try choice_modal_args.addChoiceItem(
150 ⎥             "Cancel",
151 ⎥             null,
152 ⎥             null,
153 ⎥             null,
154 ⎥         );
155 ⎥         // Show the Choice modal screen.
156 ⎥         self.main_view.showChoice(choice_modal_args);
157 ⎥     }
158 ⎥ 
159 ⎥     // Param context is owned by modalRemoveFn.
160 ⎥     fn modalEditFn(implementor: ?*anyopaque, context: ?*anyopaque) anyerror!void {
161 ⎥         var self: *Panel = @alignCast(@ptrCast(implementor.?));
162 ⎥         const contact_list_record: *const ContactList = @alignCast(@ptrCast(context.?));
163 ⎥         defer contact_list_record.deinit();
164 ⎥         // Pass a copy of the contact_list_record to the edit panel's fn set.
165 ⎥         const edit_panel_contact_copy: *const ContactList = try contact_list_record.copy();
166 ⎥         self.all_panels.Edit.?.set(edit_panel_contact_copy);
167 ⎥         self.all_panels.setCurrentToEdit();
168 ⎥     }
169 ⎥ 
170 ⎥     // Param context is owned by modalRemoveFn.
171 ⎥     fn modalRemoveFn(implementor: ?*anyopaque, context: ?*anyopaque) anyerror!void {
172 ⎥         var self: *Panel = @alignCast(@ptrCast(implementor.?));
173 ⎥         const contact_list_record: *const ContactList = @alignCast(@ptrCast(context.?));
174 ⎥         defer contact_list_record.deinit();
175 ⎥         const remove_panel_contact_copy: *const ContactList = contact_list_record.copy() catch |err| {
176 ⎥             self.exit(@src(), err, "contact_list_record.copy()");
177 ⎥             return err;
178 ⎥         };
179 ⎥         self.all_panels.Remove.?.set(remove_panel_contact_copy);
180 ⎥         self.all_panels.setCurrentToRemove();
181 ⎥     }
182 ⎥ };
183 ⎥ 
184 ⎥ pub fn init(allocator: std.mem.Allocator, main_view: *MainView, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panel {
185 ⎥     var panel: *Panel = try allocator.create(Panel);
186 ⎥     panel.lock = try _lock_.init(allocator);
187 ⎥     errdefer {
188 ⎥         allocator.destroy(panel);
189 ⎥     }
190 ⎥     panel.container = null;
191 ⎥     panel.allocator = allocator;
192 ⎥     panel.main_view = main_view;
193 ⎥     panel.all_panels = all_panels;
194 ⎥     panel.messenger = messenger;
195 ⎥     panel.exit = exit;
196 ⎥     panel.window = window;
197 ⎥     panel.contact_list_records = null;
198 ⎥     return panel;
199 ⎥ }
200 ⎥ 
```

## The Add panel

The add panel is just a form. The submit button passes the form info to the messenger in a ContactEdit record. The cancel button clears the form and if possible, switches to the select panel.

I added the following lines.

* line 8
* lines 30 - 34
* lines 51 - 124
* lines 158 - 206
* lines 223 - 229

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
 45 ⎥         var scroller = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
 46 ⎥         defer scroller.deinit();
 47 ⎥ 
 48 ⎥         var layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{});
 49 ⎥         defer layout.deinit();
 50 ⎥ 
 51 ⎥         {
 52 ⎥             // Row 1: The screen's name.
 53 ⎥             // var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 54 ⎥             // defer row.deinit();
 55 ⎥ 
 56 ⎥             try dvui.labelNoFmt(@src(), "Add a new contact.", .{ .font_style = .title });
 57 ⎥         }
 58 ⎥         {
 59 ⎥             // Row 2: This contact's name.
 60 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 61 ⎥             defer row.deinit();
 62 ⎥ 
 63 ⎥             try dvui.labelNoFmt(@src(), "Name:", .{ .font_style = .heading });
 64 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.name_buffer }, .{});
 65 ⎥             defer input.deinit();
 66 ⎥         }
 67 ⎥         {
 68 ⎥             // Row 3: This contact's address.
 69 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 70 ⎥             defer row.deinit();
 71 ⎥ 
 72 ⎥             try dvui.labelNoFmt(@src(), "Address:", .{ .font_style = .heading });
 73 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.address_buffer }, .{});
 74 ⎥             defer input.deinit();
 75 ⎥         }
 76 ⎥         {
 77 ⎥             // Row 4: This contact's city.
 78 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 79 ⎥             defer row.deinit();
 80 ⎥ 
 81 ⎥             try dvui.labelNoFmt(@src(), "City:", .{ .font_style = .heading });
 82 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.city_buffer }, .{});
 83 ⎥             defer input.deinit();
 84 ⎥         }
 85 ⎥         {
 86 ⎥             // Row 5: This contact's state.
 87 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 88 ⎥             defer row.deinit();
 89 ⎥ 
 90 ⎥             try dvui.labelNoFmt(@src(), "State:", .{ .font_style = .heading });
 91 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.state_buffer }, .{});
 92 ⎥             defer input.deinit();
 93 ⎥         }
 94 ⎥         {
 95 ⎥             // Row 6: This contact's zip.
 96 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 97 ⎥             defer row.deinit();
 98 ⎥ 
 99 ⎥             try dvui.labelNoFmt(@src(), "Zip:", .{ .font_style = .heading });
100 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.zip_buffer }, .{});
101 ⎥             defer input.deinit();
102 ⎥         }
103 ⎥         {
104 ⎥             // Row 7: Submit button.
105 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
106 ⎥             defer row.deinit();
107 ⎥             // Submit button.
108 ⎥             if (try dvui.button(@src(), "Submit.", .{}, .{})) {
109 ⎥                 // Submit this form.
110 ⎥                 // Create an add contact record to send to the back-end.
111 ⎥                 const contact_add_record: *Contact = try self.bufferToContact();
112 ⎥                 // sendAddContact owns contact_add_record.
113 ⎥                 try self.messenger.sendAddContact(contact_add_record);
114 ⎥             }
115 ⎥             // Row 8: Cancel button.
116 ⎥             if (try dvui.button(@src(), "Cancel.", .{}, .{})) {
117 ⎥                 // Clear the form.
118 ⎥                 self.clearBuffer();
119 ⎥                 // Switch to the select panel if there are contacts.
120 ⎥                 if (self.all_panels.Select.?.has_records()) {
121 ⎥                     self.all_panels.setCurrentToSelect();
122 ⎥                 }
123 ⎥             }
124 ⎥         }
125 ⎥     }
126 ⎥ 
127 ⎥     pub fn deinit(self: *Panel) void {
128 ⎥         self.allocator.free(self.name_buffer);
129 ⎥         self.allocator.free(self.address_buffer);
130 ⎥         self.allocator.free(self.city_buffer);
131 ⎥         self.allocator.free(self.state_buffer);
132 ⎥         self.allocator.free(self.zip_buffer);
133 ⎥ 
134 ⎥         // The screen will deinit the container.
135 ⎥         self.lock.deinit();
136 ⎥         self.allocator.destroy(self);
137 ⎥     }
138 ⎥ 
139 ⎥     /// refresh only if this panel and ( container or screen ) are showing.
140 ⎥     pub fn refresh(self: *Panel) void {
141 ⎥         if (self.all_panels.current_panel_tag == .Add) {
142 ⎥             // This is the current panel.
143 ⎥             if (self.container) |container| {
144 ⎥                 // Refresh the container.
145 ⎥                 // The container will refresh only if it's the currently viewed screen.
146 ⎥                 container.refresh();
147 ⎥             } else {
148 ⎥                 // Main view will refresh only if this is the currently viewed screen.
149 ⎥                 self.main_view.refreshContacts();
150 ⎥             }
151 ⎥         }
152 ⎥     }
153 ⎥ 
154 ⎥     pub fn setContainer(self: *Panel, container: *_various_.Container) void {
155 ⎥         self.container = container;
156 ⎥     }
157 ⎥ 
158 ⎥     pub fn clearBuffer(self: *Panel) void {
159 ⎥         @memset(self.name_buffer, 0);
160 ⎥         @memset(self.address_buffer, 0);
161 ⎥         @memset(self.city_buffer, 0);
162 ⎥         @memset(self.state_buffer, 0);
163 ⎥         @memset(self.zip_buffer, 0);
164 ⎥     }
165 ⎥ 
166 ⎥     fn bufferToContact(self: *Panel) !*Contact {
167 ⎥         var name_buffer_len: usize = std.mem.indexOf(u8, self.name_buffer, &[1]u8{0}) orelse self.name_buffer.len;
168 ⎥         var address_buffer_len: usize = std.mem.indexOf(u8, self.address_buffer, &[1]u8{0}) orelse self.address_buffer.len;
169 ⎥         var city_buffer_len: usize = std.mem.indexOf(u8, self.city_buffer, &[1]u8{0}) orelse self.city_buffer.len;
170 ⎥         var state_buffer_len: usize = std.mem.indexOf(u8, self.state_buffer, &[1]u8{0}) orelse self.state_buffer.len;
171 ⎥         var zip_buffer_len: usize = std.mem.indexOf(u8, self.zip_buffer, &[1]u8{0}) orelse self.zip_buffer.len;
172 ⎥ 
173 ⎥         var name: ?[]const u8 = switch (name_buffer_len) {
174 ⎥             0 => null,
175 ⎥             else => self.name_buffer[0..name_buffer_len],
176 ⎥         };
177 ⎥         var address: ?[]const u8 = switch (address_buffer_len) {
178 ⎥             0 => null,
179 ⎥             else => self.address_buffer[0..address_buffer_len],
180 ⎥         };
181 ⎥         var city: ?[]const u8 = switch (city_buffer_len) {
182 ⎥             0 => null,
183 ⎥             else => self.city_buffer[0..city_buffer_len],
184 ⎥         };
185 ⎥         var state: ?[]const u8 = switch (state_buffer_len) {
186 ⎥             0 => null,
187 ⎥             else => self.state_buffer[0..state_buffer_len],
188 ⎥         };
189 ⎥         var zip: ?[]const u8 = switch (zip_buffer_len) {
190 ⎥             0 => null,
191 ⎥             else => self.zip_buffer[0..zip_buffer_len],
192 ⎥         };
193 ⎥ 
194 ⎥         const contact: *Contact = Contact.init(
195 ⎥             self.allocator,
196 ⎥             name,
197 ⎥             address,
198 ⎥             city,
199 ⎥             state,
200 ⎥             zip,
201 ⎥         ) catch |err| {
202 ⎥             self.exit(@src(), err, "Contact.init(...)");
203 ⎥             return err;
204 ⎥         };
205 ⎥         return contact;
206 ⎥     }
207 ⎥ };
208 ⎥ 
209 ⎥ pub fn init(allocator: std.mem.Allocator, main_view: *MainView, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panel {
210 ⎥     var panel: *Panel = try allocator.create(Panel);
211 ⎥     panel.lock = try _lock_.init(allocator);
212 ⎥     errdefer {
213 ⎥         allocator.destroy(panel);
214 ⎥     }
215 ⎥     panel.container = null;
216 ⎥     panel.allocator = allocator;
217 ⎥     panel.main_view = main_view;
218 ⎥     panel.all_panels = all_panels;
219 ⎥     panel.messenger = messenger;
220 ⎥     panel.exit = exit;
221 ⎥     panel.window = window;
222 ⎥ 
223 ⎥     // The input buffers.
224 ⎥     panel.name_buffer = try allocator.alloc(u8, 255);
225 ⎥     panel.address_buffer = try allocator.alloc(u8, 255);
226 ⎥     panel.city_buffer = try allocator.alloc(u8, 255);
227 ⎥     panel.state_buffer = try allocator.alloc(u8, 255);
228 ⎥     panel.zip_buffer = try allocator.alloc(u8, 255);
229 ⎥     panel.clearBuffer();
230 ⎥ 
231 ⎥     return panel;
232 ⎥ }
233 ⎥ 
```

## The Edit panel

The edit panels is just a form displaying a current record. The submit button passes the edits to the messenger in a ContactEdit record. The cancel button just switches to the Select panel.

I added the following lines.

* lines 8 - 9
* line 31
* lines 33 - 37
* lines 54 - 125
* lines 129 - 136
* lines 162 - 245
* lines 262 - 271

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
 48 ⎥         var scroller = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
 49 ⎥         defer scroller.deinit();
 50 ⎥ 
 51 ⎥         var layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{});
 52 ⎥         defer layout.deinit();
 53 ⎥ 
 54 ⎥         {
 55 ⎥             // Row 1: The screen's name.
 56 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 57 ⎥             defer row.deinit();
 58 ⎥ 
 59 ⎥             try dvui.labelNoFmt(@src(), "Edit a contact.", .{ .font_style = .title });
 60 ⎥         }
 61 ⎥         {
 62 ⎥             // Row 2: This contact's name.
 63 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 64 ⎥             defer row.deinit();
 65 ⎥ 
 66 ⎥             try dvui.labelNoFmt(@src(), "Name:", .{ .font_style = .heading });
 67 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.name_buffer }, .{});
 68 ⎥             defer input.deinit();
 69 ⎥         }
 70 ⎥         {
 71 ⎥             // Row 3: This contact's address.
 72 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 73 ⎥             defer row.deinit();
 74 ⎥ 
 75 ⎥             try dvui.labelNoFmt(@src(), "Address:", .{ .font_style = .heading });
 76 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.address_buffer }, .{});
 77 ⎥             defer input.deinit();
 78 ⎥         }
 79 ⎥         {
 80 ⎥             // Row 4: This contact's city.
 81 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 82 ⎥             defer row.deinit();
 83 ⎥ 
 84 ⎥             try dvui.labelNoFmt(@src(), "City:", .{ .font_style = .heading });
 85 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.city_buffer }, .{});
 86 ⎥             defer input.deinit();
 87 ⎥         }
 88 ⎥         {
 89 ⎥             // Row 5: This contact's state.
 90 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 91 ⎥             defer row.deinit();
 92 ⎥ 
 93 ⎥             try dvui.labelNoFmt(@src(), "State:", .{ .font_style = .heading });
 94 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.state_buffer }, .{});
 95 ⎥             defer input.deinit();
 96 ⎥         }
 97 ⎥         {
 98 ⎥             // Row 6: This contact's zip.
 99 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
100 ⎥             defer row.deinit();
101 ⎥ 
102 ⎥             try dvui.labelNoFmt(@src(), "Zip:", .{ .font_style = .heading });
103 ⎥             var input = try dvui.textEntry(@src(), .{ .text = self.zip_buffer }, .{});
104 ⎥             defer input.deinit();
105 ⎥         }
106 ⎥         {
107 ⎥             // Row 7: Submit or Cancel.
108 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
109 ⎥             defer row.deinit();
110 ⎥             // Submit button.
111 ⎥             if (try dvui.button(@src(), "Submit.", .{}, .{})) {
112 ⎥                 // Submit this form.
113 ⎥                 var contact_edit_record: *const ContactEdit = try self.bufferToContact();
114 ⎥                 try self.messenger.sendEditContact(contact_edit_record);
115 ⎥             }
116 ⎥             // Cancel button which switches to the select panel.
117 ⎥             if (try dvui.button(@src(), "Cancel.", .{}, .{})) {
118 ⎥                 // Switch to the select panel or the add panel.
119 ⎥                 if (self.all_panels.Select.?.has_records()) {
120 ⎥                     self.all_panels.setCurrentToSelect();
121 ⎥                 } else {
122 ⎥                     self.all_panels.setCurrentToAdd();
123 ⎥                 }
124 ⎥             }
125 ⎥         }
126 ⎥     }
127 ⎥ 
128 ⎥     pub fn deinit(self: *Panel) void {
129 ⎥         if (self.contact_list_record) |contact_list_record| {
130 ⎥             contact_list_record.deinit();
131 ⎥         }
132 ⎥         self.allocator.free(self.name_buffer);
133 ⎥         self.allocator.free(self.address_buffer);
134 ⎥         self.allocator.free(self.city_buffer);
135 ⎥         self.allocator.free(self.state_buffer);
136 ⎥         self.allocator.free(self.zip_buffer);
137 ⎥ 
138 ⎥         // The screen will deinit the container.
139 ⎥         self.lock.deinit();
140 ⎥         self.allocator.destroy(self);
141 ⎥     }
142 ⎥ 
143 ⎥     /// refresh only if this panel and ( container or screen ) are showing.
144 ⎥     pub fn refresh(self: *Panel) void {
145 ⎥         if (self.all_panels.current_panel_tag == .Edit) {
146 ⎥             // This is the current panel.
147 ⎥             if (self.container) |container| {
148 ⎥                 // Refresh the container.
149 ⎥                 // The container will refresh only if it's the currently viewed screen.
150 ⎥                 container.refresh();
151 ⎥             } else {
152 ⎥                 // Main view will refresh only if this is the currently viewed screen.
153 ⎥                 self.main_view.refreshContacts();
154 ⎥             }
155 ⎥         }
156 ⎥     }
157 ⎥ 
158 ⎥     pub fn setContainer(self: *Panel, container: *_various_.Container) void {
159 ⎥         self.container = container;
160 ⎥     }
161 ⎥ 
162 ⎥     // set is called by the select panel's modalEditFn.
163 ⎥     // handles and returns any error.
164 ⎥     // Param contact_list_record is owned by this fn. See Panel.deinit();
165 ⎥     pub fn set(self: *Panel, contact_list_record: *const ContactList) void {
166 ⎥         self.lock.lock();
167 ⎥         defer self.lock.unlock();
168 ⎥         defer self.refresh();
169 ⎥ 
170 ⎥         if (self.contact_list_record) |old_contact_list_record| {
171 ⎥             old_contact_list_record.deinit();
172 ⎥         }
173 ⎥         self.contact_list_record = contact_list_record;
174 ⎥         self.contactToBuffer();
175 ⎥     }
176 ⎥ 
177 ⎥     pub fn contactToBuffer(self: *Panel) void {
178 ⎥         self.clearBuffer();
179 ⎥         for (self.contact_list_record.?.name.?, 0..) |b, i| {
180 ⎥             self.name_buffer[i] = b;
181 ⎥         }
182 ⎥         for (self.contact_list_record.?.address.?, 0..) |b, i| {
183 ⎥             self.address_buffer[i] = b;
184 ⎥         }
185 ⎥         for (self.contact_list_record.?.city.?, 0..) |b, i| {
186 ⎥             self.city_buffer[i] = b;
187 ⎥         }
188 ⎥         for (self.contact_list_record.?.state.?, 0..) |b, i| {
189 ⎥             self.state_buffer[i] = b;
190 ⎥         }
191 ⎥         for (self.contact_list_record.?.zip.?, 0..) |b, i| {
192 ⎥             self.zip_buffer[i] = b;
193 ⎥         }
194 ⎥     }
195 ⎥ 
196 ⎥     fn bufferToContact(self: *Panel) !*const ContactEdit {
197 ⎥         var name_buffer_len: usize = std.mem.indexOf(u8, self.name_buffer, &[1]u8{0}) orelse self.name_buffer.len;
198 ⎥         var address_buffer_len: usize = std.mem.indexOf(u8, self.address_buffer, &[1]u8{0}) orelse self.address_buffer.len;
199 ⎥         var city_buffer_len: usize = std.mem.indexOf(u8, self.city_buffer, &[1]u8{0}) orelse self.city_buffer.len;
200 ⎥         var state_buffer_len: usize = std.mem.indexOf(u8, self.state_buffer, &[1]u8{0}) orelse self.state_buffer.len;
201 ⎥         var zip_buffer_len: usize = std.mem.indexOf(u8, self.zip_buffer, &[1]u8{0}) orelse self.zip_buffer.len;
202 ⎥ 
203 ⎥         var name: ?[]const u8 = switch (name_buffer_len) {
204 ⎥             0 => null,
205 ⎥             else => self.name_buffer[0..name_buffer_len],
206 ⎥         };
207 ⎥         var address: ?[]const u8 = switch (address_buffer_len) {
208 ⎥             0 => null,
209 ⎥             else => self.address_buffer[0..address_buffer_len],
210 ⎥         };
211 ⎥         var city: ?[]const u8 = switch (city_buffer_len) {
212 ⎥             0 => null,
213 ⎥             else => self.city_buffer[0..city_buffer_len],
214 ⎥         };
215 ⎥         var state: ?[]const u8 = switch (state_buffer_len) {
216 ⎥             0 => null,
217 ⎥             else => self.state_buffer[0..state_buffer_len],
218 ⎥         };
219 ⎥         var zip: ?[]const u8 = switch (zip_buffer_len) {
220 ⎥             0 => null,
221 ⎥             else => self.zip_buffer[0..zip_buffer_len],
222 ⎥         };
223 ⎥ 
224 ⎥         const contact: *const ContactEdit = ContactEdit.init(
225 ⎥             self.allocator,
226 ⎥             self.contact_list_record.?.id,
227 ⎥             name,
228 ⎥             address,
229 ⎥             city,
230 ⎥             state,
231 ⎥             zip,
232 ⎥         ) catch |err| {
233 ⎥             self.exit(@src(), err, "ContactEdit.init(...)");
234 ⎥             return err;
235 ⎥         };
236 ⎥         return contact;
237 ⎥     }
238 ⎥ 
239 ⎥     fn clearBuffer(self: *Panel) void {
240 ⎥         @memset(self.name_buffer, 0);
241 ⎥         @memset(self.address_buffer, 0);
242 ⎥         @memset(self.city_buffer, 0);
243 ⎥         @memset(self.state_buffer, 0);
244 ⎥         @memset(self.zip_buffer, 0);
245 ⎥     }
246 ⎥ };
247 ⎥ 
248 ⎥ pub fn init(allocator: std.mem.Allocator, main_view: *MainView, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panel {
249 ⎥     var panel: *Panel = try allocator.create(Panel);
250 ⎥     panel.lock = try _lock_.init(allocator);
251 ⎥     errdefer {
252 ⎥         allocator.destroy(panel);
253 ⎥     }
254 ⎥     panel.container = null;
255 ⎥     panel.allocator = allocator;
256 ⎥     panel.main_view = main_view;
257 ⎥     panel.all_panels = all_panels;
258 ⎥     panel.messenger = messenger;
259 ⎥     panel.exit = exit;
260 ⎥     panel.window = window;
261 ⎥ 
262 ⎥     // The contact list record.
263 ⎥     panel.contact_list_record = null;
264 ⎥ 
265 ⎥     // The input buffers.
266 ⎥     panel.name_buffer = try allocator.alloc(u8, 255);
267 ⎥     panel.address_buffer = try allocator.alloc(u8, 255);
268 ⎥     panel.city_buffer = try allocator.alloc(u8, 255);
269 ⎥     panel.state_buffer = try allocator.alloc(u8, 255);
270 ⎥     panel.zip_buffer = try allocator.alloc(u8, 255);
271 ⎥     panel.clearBuffer();
272 ⎥ 
273 ⎥     return panel;
274 ⎥ }
275 ⎥ 
```

## The Remove panel

The remove panel displays a contact record. The submit button passes the record id to the messenger in a ContactRemove record. The cancel button just switches to the Select panel.

I added the following lines.

* lines 8 - 9
* line 31, 33
* lines 50 - 119
* lines 123 - 125
* lines 151 - 162
* lines 179 - 180

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
 44 ⎥         var scroller = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
 45 ⎥         defer scroller.deinit();
 46 ⎥ 
 47 ⎥         var layout: *dvui.BoxWidget = try dvui.box(@src(), .vertical, .{});
 48 ⎥         defer layout.deinit();
 49 ⎥ 
 50 ⎥         {
 51 ⎥             // Row 1: The screen's name.
 52 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 53 ⎥             defer row.deinit();
 54 ⎥ 
 55 ⎥             try dvui.labelNoFmt(@src(), "Remove a contact.", .{ .font_style = .title });
 56 ⎥         }
 57 ⎥         {
 58 ⎥             // Row 2: This contact's name.
 59 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 60 ⎥             defer row.deinit();
 61 ⎥ 
 62 ⎥             try dvui.labelNoFmt(@src(), "Name:", .{ .font_style = .heading });
 63 ⎥             try dvui.labelNoFmt(@src(), self.contact_list_record.?.name.?, .{});
 64 ⎥         }
 65 ⎥         {
 66 ⎥             // Row 3: This contact's address.
 67 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 68 ⎥             defer row.deinit();
 69 ⎥ 
 70 ⎥             try dvui.labelNoFmt(@src(), "Address:", .{ .font_style = .heading });
 71 ⎥             try dvui.labelNoFmt(@src(), self.contact_list_record.?.address.?, .{});
 72 ⎥         }
 73 ⎥         {
 74 ⎥             // Row 4: This contact's city.
 75 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 76 ⎥             defer row.deinit();
 77 ⎥ 
 78 ⎥             try dvui.labelNoFmt(@src(), "City:", .{ .font_style = .heading });
 79 ⎥             try dvui.labelNoFmt(@src(), self.contact_list_record.?.city.?, .{});
 80 ⎥         }
 81 ⎥         {
 82 ⎥             // Row 5: This contact's state.
 83 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 84 ⎥             defer row.deinit();
 85 ⎥ 
 86 ⎥             try dvui.labelNoFmt(@src(), "State:", .{ .font_style = .heading });
 87 ⎥             try dvui.labelNoFmt(@src(), self.contact_list_record.?.state.?, .{});
 88 ⎥         }
 89 ⎥         {
 90 ⎥             // Row 6: This contact's zip.
 91 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
 92 ⎥             defer row.deinit();
 93 ⎥ 
 94 ⎥             try dvui.labelNoFmt(@src(), "Zip:", .{ .font_style = .heading });
 95 ⎥             try dvui.labelNoFmt(@src(), self.contact_list_record.?.zip.?, .{});
 96 ⎥         }
 97 ⎥         {
 98 ⎥             // Row 7: Submit or Cancel.
 99 ⎥             var row: *dvui.BoxWidget = try dvui.box(@src(), .horizontal, .{});
100 ⎥             defer row.deinit();
101 ⎥             // Submit button.
102 ⎥             if (try dvui.button(@src(), "Submit.", .{}, .{})) {
103 ⎥                 // Submit this form.
104 ⎥                 var contact_remove_record: *ContactRemove = try ContactRemove.init(
105 ⎥                     self.allocator,
106 ⎥                     self.contact_list_record.?.id,
107 ⎥                 );
108 ⎥                 try self.messenger.sendRemoveContact(contact_remove_record);
109 ⎥             }
110 ⎥             // Cancel button which switches to the select panel.
111 ⎥             if (try dvui.button(@src(), "Cancel.", .{}, .{})) {
112 ⎥                 // Switch to the select panel or the add panel.
113 ⎥                 if (self.all_panels.Select.?.has_records()) {
114 ⎥                     self.all_panels.setCurrentToSelect();
115 ⎥                 } else {
116 ⎥                     self.all_panels.setCurrentToAdd();
117 ⎥                 }
118 ⎥             }
119 ⎥         }
120 ⎥     }
121 ⎥ 
122 ⎥     pub fn deinit(self: *Panel) void {
123 ⎥         if (self.contact_list_record) |contact_list_record| {
124 ⎥             contact_list_record.deinit();
125 ⎥         }
126 ⎥ 
127 ⎥         // The screen will deinit the container.
128 ⎥         self.lock.deinit();
129 ⎥         self.allocator.destroy(self);
130 ⎥     }
131 ⎥ 
132 ⎥     /// refresh only if this panel and ( container or screen ) are showing.
133 ⎥     pub fn refresh(self: *Panel) void {
134 ⎥         if (self.all_panels.current_panel_tag == .Remove) {
135 ⎥             // This is the current panel.
136 ⎥             if (self.container) |container| {
137 ⎥                 // Refresh the container.
138 ⎥                 // The container will refresh only if it's the currently viewed screen.
139 ⎥                 container.refresh();
140 ⎥             } else {
141 ⎥                 // Main view will refresh only if this is the currently viewed screen.
142 ⎥                 self.main_view.refreshContacts();
143 ⎥             }
144 ⎥         }
145 ⎥     }
146 ⎥ 
147 ⎥     pub fn setContainer(self: *Panel, container: *_various_.Container) void {
148 ⎥         self.container = container;
149 ⎥     }
150 ⎥ 
151 ⎥     // set is called by the select panel's modalRemoveFn.
152 ⎥     // Param contact_list_record is owned by this fn. See Panel.deinit();
153 ⎥     pub fn set(self: *Panel, contact_list_record: *const ContactList) void {
154 ⎥         self.lock.lock();
155 ⎥         defer self.lock.unlock();
156 ⎥         defer self.refresh();
157 ⎥ 
158 ⎥         if (self.contact_list_record) |old_contact_list_record| {
159 ⎥             old_contact_list_record.deinit();
160 ⎥         }
161 ⎥         self.contact_list_record = contact_list_record;
162 ⎥     }
163 ⎥ };
164 ⎥ 
165 ⎥ pub fn init(allocator: std.mem.Allocator, main_view: *MainView, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panel {
166 ⎥     var panel: *Panel = try allocator.create(Panel);
167 ⎥     panel.lock = try _lock_.init(allocator);
168 ⎥     errdefer {
169 ⎥         allocator.destroy(panel);
170 ⎥     }
171 ⎥     panel.container = null;
172 ⎥     panel.allocator = allocator;
173 ⎥     panel.main_view = main_view;
174 ⎥     panel.all_panels = all_panels;
175 ⎥     panel.messenger = messenger;
176 ⎥     panel.exit = exit;
177 ⎥     panel.window = window;
178 ⎥ 
179 ⎥     // The contact list record.
180 ⎥     panel.contact_list_record = null;
181 ⎥ 
182 ⎥     return panel;
183 ⎥ }
184 ⎥ 
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
