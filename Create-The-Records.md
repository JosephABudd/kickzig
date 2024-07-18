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

My record package will be in the **src/deps/record/**.

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
 26 ⎥             @memcpy(@constCast(self.name.?), param_name);
 27 ⎥         } else {
 28 ⎥             self.name = null;
 29 ⎥         }
 30 ⎥         // Address.
 31 ⎥         if (address) |param_address| {
 32 ⎥             self.address = try allocator.alloc(u8, param_address.len);
 33 ⎥             errdefer self.deinit();
 34 ⎥             @memcpy(@constCast(self.address.?), param_address);
 35 ⎥         } else {
 36 ⎥             self.address = null;
 37 ⎥         }
 38 ⎥ 
 39 ⎥         // City.
 40 ⎥         if (city) |param_city| {
 41 ⎥             self.city = try allocator.alloc(u8, param_city.len);
 42 ⎥             errdefer self.deinit();
 43 ⎥             @memcpy(@constCast(self.city.?), param_city);
 44 ⎥         } else {
 45 ⎥             self.city = null;
 46 ⎥         }
 47 ⎥ 
 48 ⎥         // State.
 49 ⎥         if (state) |param_state| {
 50 ⎥             self.state = try allocator.alloc(u8, param_state.len);
 51 ⎥             errdefer self.deinit();
 52 ⎥             @memcpy(@constCast(self.state.?), param_state);
 53 ⎥         } else {
 54 ⎥             self.state = null;
 55 ⎥         }
 56 ⎥ 
 57 ⎥         // Zip.
 58 ⎥         if (zip) |param_zip| {
 59 ⎥             self.zip = try allocator.alloc(u8, param_zip.len);
 60 ⎥             errdefer self.deinit();
 61 ⎥             @memcpy(@constCast(self.zip.?), param_zip);
 62 ⎥         } else {
 63 ⎥             self.zip = null;
 64 ⎥         }
 65 ⎥ 
 66 ⎥         return self;
 67 ⎥     }
 68 ⎥ 
 69 ⎥     pub fn deinit(self: anytype) void {
 70 ⎥         return switch (@TypeOf(self)) {
 71 ⎥             *Contact => _deinit(self),
 72 ⎥             *const Contact => _deinit(@constCast(self)),
 73 ⎥             else => {},
 74 ⎥         };
 75 ⎥     }
 76 ⎥ 
 77 ⎥     fn _deinit(self: *Contact) void {
 78 ⎥         if (self.count_pointers.dec() > 0) {
 79 ⎥             // There are more pointers.
 80 ⎥             // See fn copy.
 81 ⎥             return;
 82 ⎥         }
 83 ⎥         // This is the last existing pointer.
 84 ⎥         self.count_pointers.deinit();
 85 ⎥         if (self.name) |name| {
 86 ⎥             self.allocator.free(name);
 87 ⎥         }
 88 ⎥         if (self.address) |address| {
 89 ⎥             self.allocator.free(address);
 90 ⎥         }
 91 ⎥         if (self.city) |city| {
 92 ⎥             self.allocator.free(city);
 93 ⎥         }
 94 ⎥         if (self.state) |state| {
 95 ⎥             self.allocator.free(state);
 96 ⎥         }
 97 ⎥         if (self.zip) |zip| {
 98 ⎥             self.allocator.free(zip);
 99 ⎥         }
100 ⎥         self.allocator.destroy(self);
101 ⎥     }
102 ⎥ 
103 ⎥     /// KICKZIG TODO:
104 ⎥     /// copy pretends to create and return a copy of the message.
105 ⎥     /// Always pass a copy to a fn. The fn must deinit its copy.
106 ⎥     ///
107 ⎥     /// In this case copy does not return a copy of itself.
108 ⎥     /// In order to save memory space, it really only
109 ⎥     /// * increments the count of the number of pointers to this message.
110 ⎥     /// * returns self.
111 ⎥     /// See deinit().
112 ⎥     pub fn copy(self: *Contact) !*Contact {
113 ⎥         _ = self.count_pointers.inc();
114 ⎥         return self;
115 ⎥     }
116 ⎥ };
117 ⎥ 
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
 31 ⎥             self.name = try allocator.alloc(u8, param_name.len);
 32 ⎥             errdefer self.deinit();
 33 ⎥             @memcpy(@constCast(self.name.?), param_name);
 34 ⎥         } else {
 35 ⎥             self.name = null;
 36 ⎥         }
 37 ⎥         // Address.
 38 ⎥         if (address) |param_address| {
 39 ⎥             self.address = try allocator.alloc(u8, param_address.len);
 40 ⎥             errdefer self.deinit();
 41 ⎥             @memcpy(@constCast(self.address.?), param_address);
 42 ⎥         } else {
 43 ⎥             self.address = null;
 44 ⎥         }
 45 ⎥ 
 46 ⎥         // City.
 47 ⎥         if (city) |param_city| {
 48 ⎥             self.city = try allocator.alloc(u8, param_city.len);
 49 ⎥             errdefer self.deinit();
 50 ⎥             @memcpy(@constCast(self.city.?), param_city);
 51 ⎥         } else {
 52 ⎥             self.city = null;
 53 ⎥         }
 54 ⎥ 
 55 ⎥         // State.
 56 ⎥         if (state) |param_state| {
 57 ⎥             self.state = try allocator.alloc(u8, param_state.len);
 58 ⎥             errdefer self.deinit();
 59 ⎥             @memcpy(@constCast(self.state.?), param_state);
 60 ⎥         } else {
 61 ⎥             self.state = null;
 62 ⎥         }
 63 ⎥ 
 64 ⎥         // Zip.
 65 ⎥         if (zip) |param_zip| {
 66 ⎥             self.zip = try allocator.alloc(u8, param_zip.len);
 67 ⎥             errdefer self.deinit();
 68 ⎥             @memcpy(@constCast(self.zip.?), param_zip);
 69 ⎥         } else {
 70 ⎥             self.zip = null;
 71 ⎥         }
 72 ⎥ 
 73 ⎥         return self;
 74 ⎥     }
 75 ⎥ 
 76 ⎥     pub fn deinit(self: anytype) void {
 77 ⎥         return switch (@TypeOf(self)) {
 78 ⎥             *Contact => _deinit(self),
 79 ⎥             *const Contact => _deinit(@constCast(self)),
 80 ⎥             else => {},
 81 ⎥         };
 82 ⎥     }
 83 ⎥ 
 84 ⎥     fn _deinit(self: *Contact) void {
 85 ⎥         if (self.count_pointers.dec() > 0) {
 86 ⎥             // There are more pointers.
 87 ⎥             // See fn copy.
 88 ⎥             return;
 89 ⎥         }
 90 ⎥         // This is the last existing pointer.
 91 ⎥         self.count_pointers.deinit();
 92 ⎥         if (self.name) |name| {
 93 ⎥             self.allocator.free(name);
 94 ⎥         }
 95 ⎥         if (self.address) |address| {
 96 ⎥             self.allocator.free(address);
 97 ⎥         }
 98 ⎥         if (self.city) |city| {
 99 ⎥             self.allocator.free(city);
100 ⎥         }
101 ⎥         if (self.state) |state| {
102 ⎥             self.allocator.free(state);
103 ⎥         }
104 ⎥         if (self.zip) |zip| {
105 ⎥             self.allocator.free(zip);
106 ⎥         }
107 ⎥         self.allocator.destroy(self);
108 ⎥     }
109 ⎥ 
110 ⎥     /// KICKZIG TODO:
111 ⎥     /// copy pretends to create and return a copy of the message.
112 ⎥     /// Always pass a copy to a fn. The fn must deinit its copy.
113 ⎥     ///
114 ⎥     /// In this case copy does not return a copy of itself.
115 ⎥     /// In order to save memory space, it really only
116 ⎥     /// * increments the count of the number of pointers to this message.
117 ⎥     /// * returns self.
118 ⎥     /// See deinit().
119 ⎥     pub fn copy(self: *Contact) !*Contact {
120 ⎥         _ = self.count_pointers.inc();
121 ⎥         return self;
122 ⎥     }
123 ⎥ };
124 ⎥ 
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
 34 ⎥             @memcpy(@constCast(self.name.?), param_name);
 35 ⎥         } else {
 36 ⎥             self.name = null;
 37 ⎥         }
 38 ⎥         // Address.
 39 ⎥         if (address) |param_address| {
 40 ⎥             self.address = try allocator.alloc(u8, param_address.len);
 41 ⎥             errdefer self.deinit();
 42 ⎥             @memcpy(@constCast(self.address.?), param_address);
 43 ⎥         } else {
 44 ⎥             self.address = null;
 45 ⎥         }
 46 ⎥         // City.
 47 ⎥         if (city) |param_city| {
 48 ⎥             self.city = try allocator.alloc(u8, param_city.len);
 49 ⎥             errdefer self.deinit();
 50 ⎥             @memcpy(@constCast(self.city.?), param_city);
 51 ⎥         } else {
 52 ⎥             self.city = null;
 53 ⎥         }
 54 ⎥         // State.
 55 ⎥         if (state) |param_state| {
 56 ⎥             self.state = try allocator.alloc(u8, param_state.len);
 57 ⎥             errdefer self.deinit();
 58 ⎥             @memcpy(@constCast(self.state.?), param_state);
 59 ⎥         } else {
 60 ⎥             self.state = null;
 61 ⎥         }
 62 ⎥         // Zip.
 63 ⎥         if (zip) |param_zip| {
 64 ⎥             self.zip = try allocator.alloc(u8, param_zip.len);
 65 ⎥             errdefer self.deinit();
 66 ⎥             @memcpy(@constCast(self.zip.?), param_zip);
 67 ⎥         } else {
 68 ⎥             self.zip = null;
 69 ⎥         }
 70 ⎥ 
 71 ⎥         return self;
 72 ⎥     }
 73 ⎥ 
 74 ⎥     pub fn deinit(self: anytype) void {
 75 ⎥         return switch (@TypeOf(self)) {
 76 ⎥             *Contact => _deinit(self),
 77 ⎥             *const Contact => _deinit(@constCast(self)),
 78 ⎥             else => {},
 79 ⎥         };
 80 ⎥     }
 81 ⎥ 
 82 ⎥     fn _deinit(self: *Contact) void {
 83 ⎥         if (self.count_pointers.dec() > 0) {
 84 ⎥             // There are more pointers.
 85 ⎥             // See fn copy.
 86 ⎥             return;
 87 ⎥         }
 88 ⎥         // This is the last existing pointer.
 89 ⎥         self.count_pointers.deinit();
 90 ⎥         if (self.name) |name| {
 91 ⎥             self.allocator.free(name);
 92 ⎥         }
 93 ⎥         if (self.address) |address| {
 94 ⎥             self.allocator.free(address);
 95 ⎥         }
 96 ⎥         if (self.city) |city| {
 97 ⎥             self.allocator.free(city);
 98 ⎥         }
 99 ⎥         if (self.state) |state| {
100 ⎥             self.allocator.free(state);
101 ⎥         }
102 ⎥         if (self.zip) |zip| {
103 ⎥             self.allocator.free(zip);
104 ⎥         }
105 ⎥         self.allocator.destroy(self);
106 ⎥     }
107 ⎥ 
108 ⎥     /// KICKZIG TODO:
109 ⎥     /// copy pretends to create and return a copy of the message.
110 ⎥     /// Always pass a copy to a fn. The fn must deinit its copy.
111 ⎥     ///
112 ⎥     /// In this case copy does not return a copy of itself.
113 ⎥     /// In order to save memory space, it really only
114 ⎥     /// * increments the count of the number of pointers to this message.
115 ⎥     /// * returns self.
116 ⎥     /// See deinit().
117 ⎥     pub fn copy(self: *const Contact) !*const Contact {
118 ⎥         _ = self.count_pointers.inc();
119 ⎥         return self;
120 ⎥     }
121 ⎥ };
122 ⎥ 
123 ⎥ pub const Slice = struct {
124 ⎥     allocator: std.mem.Allocator,
125 ⎥     slice: []*const Contact,
126 ⎥     index: usize,
127 ⎥     slice_was_given_away: bool,
128 ⎥ 
129 ⎥     pub fn init(allocator: std.mem.Allocator) !*Slice {
130 ⎥         var self: *Slice = try allocator.create(Slice);
131 ⎥         self.slice = try allocator.alloc(*Contact, 10);
132 ⎥         errdefer {
133 ⎥             allocator.destroy(self);
134 ⎥         }
135 ⎥         self.index = 0;
136 ⎥         self.slice_was_given_away = false;
137 ⎥         return self;
138 ⎥     }
139 ⎥ 
140 ⎥     pub fn deinit(self: *Slice) void {
141 ⎥         if (self.index > 0 and !self.slice_was_given_away) {
142 ⎥             // The slice has not been given away so destroy each item.
143 ⎥             const deinit_contacts: []const *const Contact = self.slice[0..self.index];
144 ⎥             for (deinit_contacts) |deinit_contact| {
145 ⎥                 deinit_contact.deinit();
146 ⎥             }
147 ⎥         }
148 ⎥         // Free the slice.
149 ⎥         self.allocator.free(self.slice);
150 ⎥         self.allocator.destroy(self);
151 ⎥     }
152 ⎥ 
153 ⎥     // The caller owns the slice.
154 ⎥     pub fn sliced(self: *Slice) !?[]const *const Contact {
155 ⎥         if (self.index == 0) {
156 ⎥             return null;
157 ⎥         }
158 ⎥         if (self.slice_was_given_away) {
159 ⎥             return error.ContactListSliceAlreadyGivenAway;
160 ⎥         }
161 ⎥         self.slice_was_given_away = true;
162 ⎥         var contacts_copy: []*const Contact = try self.allocator.alloc(*const Contact, self.index);
163 ⎥         for (self.slice, 0..self.index) |contact, i| {
164 ⎥             // if (i == self.index) {
165 ⎥             //     break;
166 ⎥             // }
167 ⎥             contacts_copy[i] = contact;
168 ⎥         }
169 ⎥         return contacts_copy;
170 ⎥     }
171 ⎥ 
172 ⎥     // append copies contact.
173 ⎥     pub fn append(self: *Slice, contact: *const Contact) !void {
174 ⎥         if (self.slice_was_given_away) {
175 ⎥             return error.SliceAlreadyGivenAway;
176 ⎥         }
177 ⎥         // Copy the contact record.
178 ⎥         var contact_copy: *Contact = try Contact.init(
179 ⎥             contact.allocator,
180 ⎥             contact.id,
181 ⎥             contact.name,
182 ⎥             contact.address,
183 ⎥             contact.city,
184 ⎥             contact.state,
185 ⎥             contact.zip,
186 ⎥         );
187 ⎥         if (self.index == self.slice.len) {
188 ⎥             // Make a new bigger slice.
189 ⎥             const temp_contacts: []*const Contact = self.slice;
190 ⎥             self.slice = try self.allocator.alloc(*const Contact, (self.slice.len + 5));
191 ⎥             errdefer {
192 ⎥                 contact_copy.deint();
193 ⎥             }
194 ⎥             for (temp_contacts, 0..) |temp_contact, i| {
195 ⎥                 self.slice[i] = temp_contact;
196 ⎥             }
197 ⎥             self.allocator.free(temp_contacts);
198 ⎥         }
199 ⎥         self.slice[self.index] = contact_copy;
200 ⎥         self.index += 1;
201 ⎥     }
202 ⎥ };
203 ⎥ 
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
 10 ⎥     pub fn init(allocator: std.mem.Allocator, id: i64) !*Contact {
 11 ⎥         var self: *Contact = try allocator.create(Contact);
 12 ⎥         self.allocator = allocator;
 13 ⎥         self.count_pointers = try Counter.init(allocator);
 14 ⎥         errdefer allocator.destroy(self);
 15 ⎥         _ = self.count_pointers.inc();
 16 ⎥         self.id = id;
 17 ⎥         return self;
 18 ⎥     }
 19 ⎥ 
 20 ⎥     pub fn deinit(self: anytype) void {
 21 ⎥         return switch (@TypeOf(self)) {
 22 ⎥             *Contact => _deinit(self),
 23 ⎥             *const Contact => _deinit(@constCast(self)),
 24 ⎥             else => {},
 25 ⎥         };
 26 ⎥     }
 27 ⎥ 
 28 ⎥     fn _deinit(self: *Contact) void {
 29 ⎥         if (self.count_pointers.dec() > 0) {
 30 ⎥             // There are more pointers.
 31 ⎥             // See fn copy.
 32 ⎥             return;
 33 ⎥         }
 34 ⎥         // This is the last existing pointer.
 35 ⎥         self.count_pointers.deinit();
 36 ⎥         self.allocator.destroy(self);
 37 ⎥     }
 38 ⎥ 
 39 ⎥     /// KICKZIG TODO:
 40 ⎥     /// copy pretends to create and return a copy of the message.
 41 ⎥     /// Always pass a copy to a fn. The fn must deinit its copy.
 42 ⎥     ///
 43 ⎥     /// In this case copy does not return a copy of itself.
 44 ⎥     /// In order to save memory space, it really only
 45 ⎥     /// * increments the count of the number of pointers to this message.
 46 ⎥     /// * returns self.
 47 ⎥     /// See deinit().
 48 ⎥     pub fn copy(self: *Contact) !*Contact {
 49 ⎥         _ = self.count_pointers.inc();
 50 ⎥         return self;
 51 ⎥     }
 52 ⎥ };
 53 ⎥ 
```

## Next

[[Startup Parameters.|Startup-Parameters]]
