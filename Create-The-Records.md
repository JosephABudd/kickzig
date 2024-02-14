## Records are not a part of the kickzig framework

### I will add my own records module

The Contact records are required for the messages. Each type of message requires a specific type of Contact record. To keep track of record life-time, a record is copied before it is passed to a fn. That receiving fn must deinit the copy it received.

1. The **Add** record type.
   * Is a partial contact record, edited by the user, that contains no contact record id.
   * Sent by the front-end to the back-end.
   * In the **AddContact** message.
1. The **Edit** record type.
   * Is a complete contact record, edited by the user, that contains the original record id.
   * Sent by the front-end to the back-end.
   * In the **EditContact** message.
1. The **Remove** record type.
   * Is only a contact record id of a contact record selected by the user.
   * Sent by the front-end to the back-end.
   * In the **RemoveContact** message.
1. The **List** type.
   * Is a complete contact record.
   * Sent by the back-end to the front-end.
   * In the **RebuildContactList** message which contains an array of **List** records to be displayed in a select list.
   * A **List** record can be converted into an Edit Contact record.
   * A **List** record can be converted into a Remove Contact record.

## The record package

My record package will be in the **src/@This/deps/record/**.

The packages files are shown below.

### api.zig

```zig
 1 ⎥ pub const Add = @import("add.zig").Contact;
 2 ⎥ pub const Edit = @import("edit.zig").Contact;
 3 ⎥ pub const List = @import("list.zig").Contact;
 4 ⎥ pub const Remove = @import("remove.zig").Contact;
 5 ⎥ pub const Slice = @import("list.zig").Slice;
 6 ⎥ 
```

### add.zig

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ const Store = @import("store").Contact;
  3 ⎥ const List = @import("list.zig");
  4 ⎥ const Counter = @import("counter").Counter;
  5 ⎥ 
  6 ⎥ /// Contact is a contact that the user added and submitted.
  7 ⎥ pub const Contact = struct {
  8 ⎥     allocator: std.mem.Allocator,
  9 ⎥     count_pointers: *Counter,
 10 ⎥     name: ?[]const u8,
 11 ⎥     address: ?[]const u8,
 12 ⎥     city: ?[]const u8,
 13 ⎥     state: ?[]const u8,
 14 ⎥     zip: ?[]const u8,
 15 ⎥ 
 16 ⎥     pub fn init(allocator: std.mem.Allocator, name: ?[]const u8, address: ?[]const u8, city: ?[]const u8, state: ?[]const u8, zip: ?[]const u8) !*Contact {
 17 ⎥         var self: *Contact = try allocator.create(Contact);
 18 ⎥         self.allocator = allocator;
 19 ⎥         self.count_pointers = try Counter.init(allocator);
 20 ⎥         errdefer allocator.destroy(self);
 21 ⎥         _ = self.count_pointers.inc();
 22 ⎥         // Name.
 23 ⎥         if (name) |param_name| {
 24 ⎥             self.name = try allocator.alloc(u8, param_name.len);
 25 ⎥             errdefer self.deinit();
 26 ⎥             @memcpy(@constCast(self.name), param_name);
 27 ⎥         } else {
 28 ⎥             self.name = null;
 29 ⎥         }
 30 ⎥         // Address.
 31 ⎥         if (address) |param_address| {
 32 ⎥             self.address = try allocator.alloc(u8, param_address.len);
 33 ⎥             errdefer self.deinit();
 34 ⎥             @memcpy(@constCast(self.address), param_address);
 35 ⎥         } else {
 36 ⎥             self.address = null;
 37 ⎥         }
 38 ⎥ 
 39 ⎥         // City.
 40 ⎥         if (city) |param_city| {
 41 ⎥             self.city = try allocator.alloc(u8, param_city.len);
 42 ⎥             errdefer self.deinit();
 43 ⎥             @memcpy(@constCast(self.city), param_city);
 44 ⎥         } else {
 45 ⎥             self.city = null;
 46 ⎥         }
 47 ⎥ 
 48 ⎥         // State.
 49 ⎥         if (state) |param_state| {
 50 ⎥             self.state = try allocator.alloc(u8, param_state.len);
 51 ⎥             errdefer self.deinit();
 52 ⎥             @memcpy(@constCast(self.state), param_state);
 53 ⎥         } else {
 54 ⎥             self.state = null;
 55 ⎥         }
 56 ⎥ 
 57 ⎥         // Zip.
 58 ⎥         if (zip) |param_zip| {
 59 ⎥             self.zip = try allocator.alloc(u8, param_zip.len);
 60 ⎥             errdefer self.deinit();
 61 ⎥             @memcpy(@constCast(self.zip), param_zip);
 62 ⎥         } else {
 63 ⎥             self.zip = null;
 64 ⎥         }
 65 ⎥ 
 66 ⎥         return self;
 67 ⎥     }
 68 ⎥ 
 69 ⎥     pub fn deinit(self: *Contact) void {
 70 ⎥         if (self.count_pointers.dec() > 0) {
 71 ⎥             // There are more pointers.
 72 ⎥             // See fn copy.
 73 ⎥             return;
 74 ⎥         }
 75 ⎥         // This is the last existing pointer.
 76 ⎥         self.count_pointers.deinit();
 77 ⎥         if (self.name) |name| {
 78 ⎥             self.allocator.free(name);
 79 ⎥         }
 80 ⎥         if (self.address) |address| {
 81 ⎥             self.allocator.free(address);
 82 ⎥         }
 83 ⎥         if (self.city) |city| {
 84 ⎥             self.allocator.free(city);
 85 ⎥         }
 86 ⎥         if (self.state) |state| {
 87 ⎥             self.allocator.free(state);
 88 ⎥         }
 89 ⎥         if (self.zip) |zip| {
 90 ⎥             self.allocator.free(zip);
 91 ⎥         }
 92 ⎥         self.allocator.destroy(self);
 93 ⎥     }
 94 ⎥ 
 95 ⎥     /// KICKZIG TODO:
 96 ⎥     /// copy pretends to create and return a copy of the message.
 97 ⎥     /// Always pass a copy to a fn. The fn must deinit its copy.
 98 ⎥     ///
 99 ⎥     /// In this case copy does not return a copy of itself.
100 ⎥     /// In order to save memory space, it really only
101 ⎥     /// * increments the count of the number of pointers to this message.
102 ⎥     /// * returns self.
103 ⎥     /// See deinit().
104 ⎥     pub fn copy(self: *Contact) !*Contact {
105 ⎥         _ = self.count_pointers.inc();
106 ⎥         return self;
107 ⎥     }
108 ⎥ };
109 ⎥ 
```

### edit.zig

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ const Store = @import("store").Contact;
  3 ⎥ const Counter = @import("counter").Counter;
  4 ⎥ 
  5 ⎥ /// Contact is a contact that the user edited and submitted.
  6 ⎥ pub const Contact = struct {
  7 ⎥     allocator: std.mem.Allocator,
  8 ⎥     count_pointers: *Counter,
  9 ⎥     id: i64,
 10 ⎥     name: ?[]const u8,
 11 ⎥     address: ?[]const u8,
 12 ⎥     city: ?[]const u8,
 13 ⎥     state: ?[]const u8,
 14 ⎥     zip: ?[]const u8,
 15 ⎥ 
 16 ⎥     pub fn init(allocator: std.mem.Allocator, id: ?i64, name: ?[]const u8, address: ?[]const u8, city: ?[]const u8, state: ?[]const u8, zip: ?[]const u8) !*Contact {
 17 ⎥         var self: *Contact = try allocator.create(Contact);
 18 ⎥         self.allocator = allocator;
 19 ⎥         self.count_pointers = try Counter.init(allocator);
 20 ⎥         errdefer allocator.destroy(self);
 21 ⎥         _ = self.count_pointers.inc();
 22 ⎥         // ID.
 23 ⎥         if (id) |param_id| {
 24 ⎥             self.id = param_id;
 25 ⎥         } else {
 26 ⎥             allocator.destroy(self);
 27 ⎥             return error.ContactIsMissingID;
 28 ⎥         }
 29 ⎥         // Name.
 30 ⎥         if (name) |param_name| {
 31 ⎥             self.name = allocator.alloc(u8, param_name.len);
 32 ⎥             errdefer self.deinit();
 33 ⎥             @memcpy(self.name, param_name);
 34 ⎥         } else {
 35 ⎥             self.name = null;
 36 ⎥         }
 37 ⎥         // Address.
 38 ⎥         if (address) |param_address| {
 39 ⎥             self.address = allocator.alloc(u8, param_address.len);
 40 ⎥             errdefer self.deinit();
 41 ⎥             @memcpy(self.address, param_address);
 42 ⎥         } else {
 43 ⎥             self.address = null;
 44 ⎥         }
 45 ⎥ 
 46 ⎥         // City.
 47 ⎥         if (city) |param_city| {
 48 ⎥             self.city = allocator.alloc(u8, param_city.len);
 49 ⎥             errdefer self.deinit();
 50 ⎥             @memcpy(self.city, param_city);
 51 ⎥         } else {
 52 ⎥             self.city = null;
 53 ⎥         }
 54 ⎥ 
 55 ⎥         // State.
 56 ⎥         if (state) |param_state| {
 57 ⎥             self.state = allocator.alloc(u8, param_state.len);
 58 ⎥             errdefer self.deinit();
 59 ⎥             @memcpy(self.state, param_state);
 60 ⎥         } else {
 61 ⎥             self.state = null;
 62 ⎥         }
 63 ⎥ 
 64 ⎥         // Zip.
 65 ⎥         if (zip) |param_zip| {
 66 ⎥             self.zip = allocator.alloc(u8, param_zip.len);
 67 ⎥             errdefer self.deinit();
 68 ⎥             @memcpy(self.zip, param_zip);
 69 ⎥         } else {
 70 ⎥             self.zip = null;
 71 ⎥         }
 72 ⎥ 
 73 ⎥         return self;
 74 ⎥     }
 75 ⎥ 
 76 ⎥     pub fn deinit(self: *Contact) void {
 77 ⎥         if (self.count_pointers.dec() > 0) {
 78 ⎥             // There are more pointers.
 79 ⎥             // See fn copy.
 80 ⎥             return;
 81 ⎥         }
 82 ⎥         // This is the last existing pointer.
 83 ⎥         self.count_pointers.deinit();
 84 ⎥         if (self.name) |name| {
 85 ⎥             self.allocator.free(name);
 86 ⎥         }
 87 ⎥         if (self.address) |address| {
 88 ⎥             self.allocator.free(address);
 89 ⎥         }
 90 ⎥         if (self.city) |city| {
 91 ⎥             self.allocator.free(city);
 92 ⎥         }
 93 ⎥         if (self.state) |state| {
 94 ⎥             self.allocator.free(state);
 95 ⎥         }
 96 ⎥         if (self.zip) |zip| {
 97 ⎥             self.allocator.free(zip);
 98 ⎥         }
 99 ⎥         self.allocator.destroy(self);
100 ⎥     }
101 ⎥ 
102 ⎥     /// KICKZIG TODO:
103 ⎥     /// copy pretends to create and return a copy of the message.
104 ⎥     /// Always pass a copy to a fn. The fn must deinit its copy.
105 ⎥     ///
106 ⎥     /// In this case copy does not return a copy of itself.
107 ⎥     /// In order to save memory space, it really only
108 ⎥     /// * increments the count of the number of pointers to this message.
109 ⎥     /// * returns self.
110 ⎥     /// See deinit().
111 ⎥     pub fn copy(self: *Contact) !*Contact {
112 ⎥         _ = self.count_pointers.inc();
113 ⎥         return self;
114 ⎥     }
115 ⎥ };
116 ⎥ 
```

### list.zig

The List Contact record can be converted to an Edit record and a Remove record. This file also defined the Slice type.

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ const Edit = @import("edit.zig").Contact;
  3 ⎥ const Remove = @import("remove.zig").Contact;
  4 ⎥ const Counter = @import("counter").Counter;
  5 ⎥ 
  6 ⎥ /// Contact is a record that is displayed for selection.
  7 ⎥ pub const Contact = struct {
  8 ⎥     allocator: std.mem.Allocator,
  9 ⎥     count_pointers: *Counter,
 10 ⎥     id: i64,
 11 ⎥     name: ?[]const u8,
 12 ⎥     address: ?[]const u8,
 13 ⎥     city: ?[]const u8,
 14 ⎥     state: ?[]const u8,
 15 ⎥     zip: ?[]const u8,
 16 ⎥ 
 17 ⎥     pub fn init(allocator: std.mem.Allocator, id: ?i64, name: ?[]const u8, address: ?[]const u8, city: ?[]const u8, state: ?[]const u8, zip: ?[]const u8) !*Contact {
 18 ⎥         var self: *Contact = try allocator.create(Contact);
 19 ⎥         self.allocator = allocator;
 20 ⎥         self.count_pointers = try Counter.init(allocator);
 21 ⎥         errdefer allocator.destroy(self);
 22 ⎥         _ = self.count_pointers.inc();
 23 ⎥         // ID.
 24 ⎥         if (id) |param_id| {
 25 ⎥             self.id = param_id;
 26 ⎥         } else {
 27 ⎥             allocator.destroy(self);
 28 ⎥             return error.ContactIsMissingID;
 29 ⎥         }
 30 ⎥         // Name.
 31 ⎥         if (name) |param_name| {
 32 ⎥             self.name = try allocator.alloc(u8, param_name.len);
 33 ⎥             errdefer self.deinit();
 34 ⎥             @memcpy(@constCast(self.name), param_name);
 35 ⎥         } else {
 36 ⎥             self.name = null;
 37 ⎥         }
 38 ⎥         // Address.
 39 ⎥         if (address) |param_address| {
 40 ⎥             self.address = try allocator.alloc(u8, param_address.len);
 41 ⎥             errdefer self.deinit();
 42 ⎥             @memcpy(@constCast(self.address), param_address);
 43 ⎥         } else {
 44 ⎥             self.address = null;
 45 ⎥         }
 46 ⎥         // City.
 47 ⎥         if (city) |param_city| {
 48 ⎥             self.city = try allocator.alloc(u8, param_city.len);
 49 ⎥             errdefer self.deinit();
 50 ⎥             @memcpy(@constCast(self.city), param_city);
 51 ⎥         } else {
 52 ⎥             self.city = null;
 53 ⎥         }
 54 ⎥         // State.
 55 ⎥         if (state) |param_state| {
 56 ⎥             self.state = try allocator.alloc(u8, param_state.len);
 57 ⎥             errdefer self.deinit();
 58 ⎥             @memcpy(@constCast(self.state), param_state);
 59 ⎥         } else {
 60 ⎥             self.state = null;
 61 ⎥         }
 62 ⎥         // Zip.
 63 ⎥         if (zip) |param_zip| {
 64 ⎥             self.zip = try allocator.alloc(u8, param_zip.len);
 65 ⎥             errdefer self.deinit();
 66 ⎥             @memcpy(@constCast(self.zip), param_zip);
 67 ⎥         } else {
 68 ⎥             self.zip = null;
 69 ⎥         }
 70 ⎥ 
 71 ⎥         return self;
 72 ⎥     }
 73 ⎥ 
 74 ⎥     pub fn deinit(self: *const Contact) void {
 75 ⎥         if (self.count_pointers.dec() > 0) {
 76 ⎥             // There are more pointers.
 77 ⎥             // See fn copy.
 78 ⎥             return;
 79 ⎥         }
 80 ⎥         // This is the last existing pointer.
 81 ⎥         self.count_pointers.deinit();
 82 ⎥         if (self.name) |name| {
 83 ⎥             self.allocator.free(name);
 84 ⎥         }
 85 ⎥         if (self.address) |address| {
 86 ⎥             self.allocator.free(address);
 87 ⎥         }
 88 ⎥         if (self.city) |city| {
 89 ⎥             self.allocator.free(city);
 90 ⎥         }
 91 ⎥         if (self.state) |state| {
 92 ⎥             self.allocator.free(state);
 93 ⎥         }
 94 ⎥         if (self.zip) |zip| {
 95 ⎥             self.allocator.free(zip);
 96 ⎥         }
 97 ⎥         self.allocator.destroy(self);
 98 ⎥     }
 99 ⎥ 
100 ⎥     /// KICKZIG TODO:
101 ⎥     /// copy pretends to create and return a copy of the message.
102 ⎥     /// Always pass a copy to a fn. The fn must deinit its copy.
103 ⎥     ///
104 ⎥     /// In this case copy does not return a copy of itself.
105 ⎥     /// In order to save memory space, it really only
106 ⎥     /// * increments the count of the number of pointers to this message.
107 ⎥     /// * returns self.
108 ⎥     /// See deinit().
109 ⎥     pub fn copy(self: *Contact) !*Contact {
110 ⎥         _ = self.count_pointers.inc();
111 ⎥         return self;
112 ⎥     }
113 ⎥ 
114 ⎥     /// The front-end will use this for a EditContact message.
115 ⎥     pub fn toEdit(self: *Contact) !*Edit {
116 ⎥         return Edit.init(
117 ⎥             self.allocator,
118 ⎥             self.id,
119 ⎥             self.name,
120 ⎥             self.address,
121 ⎥             self.city,
122 ⎥             self.state,
123 ⎥             self.zip,
124 ⎥         );
125 ⎥     }
126 ⎥ 
127 ⎥     /// The front-end will use this for a RemoveContact message.
128 ⎥     pub fn toRemove(self: *Contact) !*Remove {
129 ⎥         return Remove.init(self.allocator, self.id);
130 ⎥     }
131 ⎥ };
132 ⎥ 
133 ⎥ pub const Slice = struct {
134 ⎥     allocator: std.mem.Allocator,
135 ⎥     slice: []*const Contact,
136 ⎥     index: usize,
137 ⎥     slice_was_given_away: bool,
138 ⎥ 
139 ⎥     pub fn init(allocator: std.mem.Allocator) !*Slice {
140 ⎥         var self: *Slice = try allocator.create(Slice);
141 ⎥         self.slice = try allocator.alloc(*Contact, 10);
142 ⎥         errdefer {
143 ⎥             allocator.destroy(self);
144 ⎥         }
145 ⎥         self.index = 0;
146 ⎥         self.slice_was_given_away = false;
147 ⎥         return self;
148 ⎥     }
149 ⎥ 
150 ⎥     pub fn deinit(self: *Slice) void {
151 ⎥         if (self.index > 0 and !self.slice_was_given_away) {
152 ⎥             // The slice has not been given away so destroy each item.
153 ⎥             var deinit_contacts: []const *const Contact = self.slice[0..self.index];
154 ⎥             for (deinit_contacts) |deinit_contact| {
155 ⎥                 deinit_contact.deinit();
156 ⎥             }
157 ⎥         }
158 ⎥         // Free the slice.
159 ⎥         self.allocator.free(self.slice);
160 ⎥         self.allocator.destroy(self);
161 ⎥     }
162 ⎥ 
163 ⎥     // The caller owns the slice.
164 ⎥     pub fn sliced(self: *Slice) !?[]const *const Contact {
165 ⎥         if (self.index == 0) {
166 ⎥             return null;
167 ⎥         }
168 ⎥         if (self.slice_was_given_away) {
169 ⎥             return error.ContactListSliceAlreadyGivenAway;
170 ⎥         }
171 ⎥         self.slice_was_given_away = true;
172 ⎥         var contacts_copy: []*const Contact = try self.allocator.alloc(*const Contact, self.index);
173 ⎥         for (self.slice, 0..self.index) |contact, i| {
174 ⎥             // if (i == self.index) {
175 ⎥             //     break;
176 ⎥             // }
177 ⎥             contacts_copy[i] = contact;
178 ⎥         }
179 ⎥         return contacts_copy;
180 ⎥     }
181 ⎥ 
182 ⎥     // append copies contact.
183 ⎥     pub fn append(self: *Slice, contact: *const Contact) !void {
184 ⎥         if (self.slice_was_given_away) {
185 ⎥             return error.SliceAlreadyGivenAway;
186 ⎥         }
187 ⎥         // Copy the contact record.
188 ⎥         var contact_copy: *Contact = try Contact.init(
189 ⎥             contact.allocator,
190 ⎥             contact.id,
191 ⎥             contact.name,
192 ⎥             contact.address,
193 ⎥             contact.city,
194 ⎥             contact.state,
195 ⎥             contact.zip,
196 ⎥         );
197 ⎥         if (self.index == self.slice.len) {
198 ⎥             // Make a new bigger slice.
199 ⎥             const temp_contacts: []*const Contact = self.slice;
200 ⎥             self.slice = try self.allocator.alloc(*const Contact, (self.slice.len + 5));
201 ⎥             errdefer {
202 ⎥                 contact_copy.deint();
203 ⎥             }
204 ⎥             for (temp_contacts, 0..) |temp_contact, i| {
205 ⎥                 self.slice[i] = temp_contact;
206 ⎥             }
207 ⎥             self.allocator.free(temp_contacts);
208 ⎥         }
209 ⎥         self.slice[self.index] = contact_copy;
210 ⎥         self.index += 1;
211 ⎥     }
212 ⎥ };
213 ⎥ 
```

### remove.zig

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ const Counter = @import("counter").Counter;
  3 ⎥ 
  4 ⎥ /// Contact is a contact that the user wants to remove.
  5 ⎥ pub const Contact = struct {
  6 ⎥     allocator: std.mem.Allocator,
  7 ⎥     count_pointers: *Counter,
  8 ⎥     id: i64,
  9 ⎥ 
 10 ⎥     pub fn init(allocator: std.mem.Allocator, id: i64) !Contact {
 11 ⎥         var self: *Contact = try allocator.create(Contact);
 12 ⎥         self.allocator = allocator;
 13 ⎥         self.count_pointers = try Counter.init(allocator);
 14 ⎥         errdefer allocator.destroy(self);
 15 ⎥         _ = self.count_pointers.inc();
 16 ⎥         self.id = id;
 17 ⎥         return;
 18 ⎥     }
 19 ⎥ 
 20 ⎥     pub fn deinit(self: *Contact) void {
 21 ⎥         if (self.count_pointers.dec() > 0) {
 22 ⎥             // There are more pointers.
 23 ⎥             // See fn copy.
 24 ⎥             return;
 25 ⎥         }
 26 ⎥         // This is the last existing pointer.
 27 ⎥         self.count_pointers.deinit();
 28 ⎥         self.allocator.destroy(self);
 29 ⎥     }
 30 ⎥ 
 31 ⎥     /// KICKZIG TODO:
 32 ⎥     /// copy pretends to create and return a copy of the message.
 33 ⎥     /// Always pass a copy to a fn. The fn must deinit its copy.
 34 ⎥     ///
 35 ⎥     /// In this case copy does not return a copy of itself.
 36 ⎥     /// In order to save memory space, it really only
 37 ⎥     /// * increments the count of the number of pointers to this message.
 38 ⎥     /// * returns self.
 39 ⎥     /// See deinit().
 40 ⎥     pub fn copy(self: *Contact) !*Contact {
 41 ⎥         _ = self.count_pointers.inc();
 42 ⎥         return self;
 43 ⎥     }
 44 ⎥ };
 45 ⎥ 
```

## Next

[[Create The Messages.||Create-The-Messages]]
