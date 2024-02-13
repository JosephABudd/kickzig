## Records are not a part of the kickzig framework

### I will add my own records module

The Contact records are required for the messages. Each type of message requires a specific type of Contact record.

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
  2 ⎥ const Store = @import("store.zig").Contact;
  3 ⎥ 
  4 ⎥ /// Contact is a contact that the user added and submitted.
  5 ⎥ pub const Contact = struct {
  6 ⎥     allocator: std.mem.Allocator,
  7 ⎥     name: ?[]const u8,
  8 ⎥     address: ?[]const u8,
  9 ⎥     city: ?[]const u8,
 10 ⎥     state: ?[]const u8,
 11 ⎥     zip: ?[]const u8,
 12 ⎥ 
 13 ⎥     pub fn init(allocator: std.mem.Allocator, name: ?[]const u8, address: ?[]const u8, city: ?[]const u8, state: ?[]const u8, zip: ?[]const u8) !*Contact {
 14 ⎥         var self: *Contact = try allocator.create(Contact);
 15 ⎥         self.allocator = allocator;
 16 ⎥         // Name.
 17 ⎥         if (name) |param_name| {
 18 ⎥             self.name = allocator.alloc(u8, param_name.len);
 19 ⎥             errdefer self.deinit();
 20 ⎥             @memcpy(self.name, param_name);
 21 ⎥         } else {
 22 ⎥             self.name = null;
 23 ⎥         }
 24 ⎥         // Address.
 25 ⎥         if (address) |param_address| {
 26 ⎥             self.address = allocator.alloc(u8, param_address.len);
 27 ⎥             errdefer self.deinit();
 28 ⎥             @memcpy(self.address, param_address);
 29 ⎥         } else {
 30 ⎥             self.address = null;
 31 ⎥         }
 32 ⎥ 
 33 ⎥         // City.
 34 ⎥         if (city) |param_city| {
 35 ⎥             self.city = allocator.alloc(u8, param_city.len);
 36 ⎥             errdefer self.deinit();
 37 ⎥             @memcpy(self.city, param_city);
 38 ⎥         } else {
 39 ⎥             self.city = null;
 40 ⎥         }
 41 ⎥ 
 42 ⎥         // State.
 43 ⎥         if (state) |param_state| {
 44 ⎥             self.state = allocator.alloc(u8, param_state.len);
 45 ⎥             errdefer self.deinit();
 46 ⎥             @memcpy(self.state, param_state);
 47 ⎥         } else {
 48 ⎥             self.state = null;
 49 ⎥         }
 50 ⎥ 
 51 ⎥         // Zip.
 52 ⎥         if (zip) |param_zip| {
 53 ⎥             self.zip = allocator.alloc(u8, param_zip.len);
 54 ⎥             errdefer self.deinit();
 55 ⎥             @memcpy(self.zip, param_zip);
 56 ⎥         } else {
 57 ⎥             self.zip = null;
 58 ⎥         }
 59 ⎥ 
 60 ⎥         return self;
 61 ⎥     }
 62 ⎥ 
 63 ⎥     pub fn deinit(self: *Contact) void {
 64 ⎥         if (self.name) |name| {
 65 ⎥             self.allocator.free(name);
 66 ⎥         }
 67 ⎥         if (self.address) |address| {
 68 ⎥             self.allocator.free(address);
 69 ⎥         }
 70 ⎥         if (self.city) |city| {
 71 ⎥             self.allocator.free(city);
 72 ⎥         }
 73 ⎥         if (self.state) |state| {
 74 ⎥             self.allocator.free(state);
 75 ⎥         }
 76 ⎥         if (self.zip) |zip| {
 77 ⎥             self.allocator.free(zip);
 78 ⎥         }
 79 ⎥         self.allocator.destroy(self);
 80 ⎥     }
 81 ⎥ 
 82 ⎥     pub fn toRecord(self: *Contact) !*Store {
 83 ⎥         return Store.init(
 84 ⎥             self.allocator,
 85 ⎥             0,
 86 ⎥             self.name,
 87 ⎥             self.address,
 88 ⎥             self.city,
 89 ⎥             self.state,
 90 ⎥             self.zip,
 91 ⎥         );
 92 ⎥     }
 93 ⎥ };
 94 ⎥ 
```

### edit.zig

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ const Store = @import("store.zig").Contact;
  3 ⎥ 
  4 ⎥ /// Contact is a contact that the user edited and submitted.
  5 ⎥ pub const Contact = struct {
  6 ⎥     allocator: std.mem.Allocator,
  7 ⎥     id: i64,
  8 ⎥     name: []const u8,
  9 ⎥     address: []const u8,
 10 ⎥     city: []const u8,
 11 ⎥     state: []const u8,
 12 ⎥     zip: []const u8,
 13 ⎥ 
 14 ⎥     pub fn init(allocator: std.mem.Allocator, id: ?i64, name: ?[]const u8, address: ?[]const u8, city: ?[]const u8, state: ?[]const u8, zip: ?[]const u8) !*Contact {
 15 ⎥         var self: *Contact = try allocator.create(Contact);
 16 ⎥         self.allocator = allocator;
 17 ⎥         // ID.
 18 ⎥         if (id) |param_id| {
 19 ⎥             self.id = param_id;
 20 ⎥         } else {
 21 ⎥             allocator.destroy(self);
 22 ⎥             return error.ContactIsMissingID;
 23 ⎥         }
 24 ⎥         // Name.
 25 ⎥         if (name) |param_name| {
 26 ⎥             self.name = allocator.alloc(u8, param_name.len);
 27 ⎥             errdefer self.deinit();
 28 ⎥             @memcpy(self.name, param_name);
 29 ⎥         } else {
 30 ⎥             self.name = null;
 31 ⎥         }
 32 ⎥         // Address.
 33 ⎥         if (address) |param_address| {
 34 ⎥             self.address = allocator.alloc(u8, param_address.len);
 35 ⎥             errdefer self.deinit();
 36 ⎥             @memcpy(self.address, param_address);
 37 ⎥         } else {
 38 ⎥             self.address = null;
 39 ⎥         }
 40 ⎥ 
 41 ⎥         // City.
 42 ⎥         if (city) |param_city| {
 43 ⎥             self.city = allocator.alloc(u8, param_city.len);
 44 ⎥             errdefer self.deinit();
 45 ⎥             @memcpy(self.city, param_city);
 46 ⎥         } else {
 47 ⎥             self.city = null;
 48 ⎥         }
 49 ⎥ 
 50 ⎥         // State.
 51 ⎥         if (state) |param_state| {
 52 ⎥             self.state = allocator.alloc(u8, param_state.len);
 53 ⎥             errdefer self.deinit();
 54 ⎥             @memcpy(self.state, param_state);
 55 ⎥         } else {
 56 ⎥             self.state = null;
 57 ⎥         }
 58 ⎥ 
 59 ⎥         // Zip.
 60 ⎥         if (zip) |param_zip| {
 61 ⎥             self.zip = allocator.alloc(u8, param_zip.len);
 62 ⎥             errdefer self.deinit();
 63 ⎥             @memcpy(self.zip, param_zip);
 64 ⎥         } else {
 65 ⎥             self.zip = null;
 66 ⎥         }
 67 ⎥ 
 68 ⎥         return self;
 69 ⎥     }
 70 ⎥ 
 71 ⎥     pub fn deinit(self: *Contact) void {
 72 ⎥         if (self.name) |name| {
 73 ⎥             self.allocator.free(name);
 74 ⎥         }
 75 ⎥         if (self.address) |address| {
 76 ⎥             self.allocator.free(address);
 77 ⎥         }
 78 ⎥         if (self.city) |city| {
 79 ⎥             self.allocator.free(city);
 80 ⎥         }
 81 ⎥         if (self.state) |state| {
 82 ⎥             self.allocator.free(state);
 83 ⎥         }
 84 ⎥         if (self.zip) |zip| {
 85 ⎥             self.allocator.free(zip);
 86 ⎥         }
 87 ⎥         self.allocator.destroy(self);
 88 ⎥     }
 89 ⎥ 
 90 ⎥     pub fn toRecord(self: *Contact) !*Store {
 91 ⎥         return Store.init(
 92 ⎥             self.allocator,
 93 ⎥             self.id,
 94 ⎥             self.name,
 95 ⎥             self.address,
 96 ⎥             self.city,
 97 ⎥             self.state,
 98 ⎥             self.zip,
 99 ⎥         );
100 ⎥     }
101 ⎥ };
102 ⎥ 
```

### list.zig

The List Contact record can be converted to an Edit record and a Remove record. This file also defined the Slice type.

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ const Edit = @import("edit.zig").Contact;
  3 ⎥ const Remove = @import("remove.zig").Contact;
  4 ⎥ 
  5 ⎥ /// Contact is a record that is displayed for selection.
  6 ⎥ pub const Contact = struct {
  7 ⎥     allocator: std.mem.Allocator,
  8 ⎥     id: i64,
  9 ⎥     name: ?[]const u8,
 10 ⎥     address: ?[]const u8,
 11 ⎥     city: ?[]const u8,
 12 ⎥     state: ?[]const u8,
 13 ⎥     zip: ?[]const u8,
 14 ⎥ 
 15 ⎥     pub fn init(allocator: std.mem.Allocator, id: ?i64, name: ?[]const u8, address: ?[]const u8, city: ?[]const u8, state: ?[]const u8, zip: ?[]const u8) !*Contact {
 16 ⎥         var self: *Contact = try allocator.create(Contact);
 17 ⎥         self.allocator = allocator;
 18 ⎥         // ID.
 19 ⎥         if (id) |param_id| {
 20 ⎥             self.id = param_id;
 21 ⎥         } else {
 22 ⎥             allocator.destroy(self);
 23 ⎥             return error.ContactIsMissingID;
 24 ⎥         }
 25 ⎥         // Name.
 26 ⎥         if (name) |param_name| {
 27 ⎥             self.name = allocator.alloc(u8, param_name.len);
 28 ⎥             errdefer self.deinit();
 29 ⎥             @memcpy(self.name, param_name);
 30 ⎥         } else {
 31 ⎥             self.name = null;
 32 ⎥         }
 33 ⎥         // Address.
 34 ⎥         if (address) |param_address| {
 35 ⎥             self.address = allocator.alloc(u8, param_address.len);
 36 ⎥             errdefer self.deinit();
 37 ⎥             @memcpy(self.address, param_address);
 38 ⎥         } else {
 39 ⎥             self.address = null;
 40 ⎥         }
 41 ⎥         // City.
 42 ⎥         if (city) |param_city| {
 43 ⎥             self.city = allocator.alloc(u8, param_city.len);
 44 ⎥             errdefer self.deinit();
 45 ⎥             @memcpy(self.city, param_city);
 46 ⎥         } else {
 47 ⎥             self.city = null;
 48 ⎥         }
 49 ⎥         // State.
 50 ⎥         if (state) |param_state| {
 51 ⎥             self.state = allocator.alloc(u8, param_state.len);
 52 ⎥             errdefer self.deinit();
 53 ⎥             @memcpy(self.state, param_state);
 54 ⎥         } else {
 55 ⎥             self.state = null;
 56 ⎥         }
 57 ⎥         // Zip.
 58 ⎥         if (zip) |param_zip| {
 59 ⎥             self.zip = allocator.alloc(u8, param_zip.len);
 60 ⎥             errdefer self.deinit();
 61 ⎥             @memcpy(self.zip, param_zip);
 62 ⎥         } else {
 63 ⎥             self.zip = null;
 64 ⎥         }
 65 ⎥ 
 66 ⎥         return self;
 67 ⎥     }
 68 ⎥ 
 69 ⎥     pub fn deinit(self: *Contact) void {
 70 ⎥         if (self.name) |name| {
 71 ⎥             self.allocator.free(name);
 72 ⎥         }
 73 ⎥         if (self.address) |address| {
 74 ⎥             self.allocator.free(address);
 75 ⎥         }
 76 ⎥         if (self.city) |city| {
 77 ⎥             self.allocator.free(city);
 78 ⎥         }
 79 ⎥         if (self.state) |state| {
 80 ⎥             self.allocator.free(state);
 81 ⎥         }
 82 ⎥         if (self.zip) |zip| {
 83 ⎥             self.allocator.free(zip);
 84 ⎥         }
 85 ⎥         self.allocator.destroy(self);
 86 ⎥     }
 87 ⎥ 
 88 ⎥     pub fn toEdit(self: *Contact) !*Edit {
 89 ⎥         return Edit.init(
 90 ⎥             self.allocator,
 91 ⎥             self.id,
 92 ⎥             self.name,
 93 ⎥             self.address,
 94 ⎥             self.city,
 95 ⎥             self.state,
 96 ⎥             self.zip,
 97 ⎥         );
 98 ⎥     }
 99 ⎥ 
100 ⎥     pub fn toRemove(self: *Contact) !*Remove {
101 ⎥         return Remove.init(self.allocator, self.id);
102 ⎥     }
103 ⎥ };
104 ⎥ 
105 ⎥ const Slice = struct {
106 ⎥     allocator: std.mem.Allocator,
107 ⎥     slice: []*Contact,
108 ⎥     index: usize,
109 ⎥     slice_was_given_away: bool,
110 ⎥ 
111 ⎥     pub fn init(allocator: std.mem.Allocator) !*Slice {
112 ⎥         var self: *Slice = try allocator.create(Slice);
113 ⎥         self.slice = try allocator.alloc(*Contact, 10);
114 ⎥         errdefer {
115 ⎥             allocator.destroy(self);
116 ⎥         }
117 ⎥         self.index = 0;
118 ⎥         self.slice_was_given_away = false;
119 ⎥         return self;
120 ⎥     }
121 ⎥ 
122 ⎥     pub fn deinit(self: *Slice) void {
123 ⎥         if (self.index > 0) {
124 ⎥             if (!self.slice_was_given_away) {
125 ⎥                 // The slice has not been given away so destroy each item.
126 ⎥                 var deinit_contacts: []*Contact = self.slice[0..self.index];
127 ⎥                 for (deinit_contacts) |deinit_contact| {
128 ⎥                     self.allocator.free(deinit_contact);
129 ⎥                 }
130 ⎥                 // Free the slice.
131 ⎥                 self.allocator.free(self.slice);
132 ⎥             }
133 ⎥         }
134 ⎥         self.allocator.destroy(self);
135 ⎥     }
136 ⎥ 
137 ⎥     // The caller owns the slice.
138 ⎥     pub fn slice(self: *Slice) ![]*Contact {
139 ⎥         if (self.slice_was_given_away) {
140 ⎥             return error.SliceAlreadyGivenAway;
141 ⎥         }
142 ⎥         // Give the slice away.
143 ⎥         self.slice_was_given_away = true;
144 ⎥         return self.slice;
145 ⎥     }
146 ⎥ 
147 ⎥     // append copies contact.
148 ⎥     pub fn append(self: *Slice, contact: *Contact) !void {
149 ⎥         if (self.slice_was_given_away) {
150 ⎥             return error.SliceAlreadyGivenAway;
151 ⎥         }
152 ⎥         // Copy the contact record.
153 ⎥         var contact_copy: *Contact = Contact.init(
154 ⎥             contact.id,
155 ⎥             contact.name,
156 ⎥             contact.address,
157 ⎥             contact.city,
158 ⎥             contact.state,
159 ⎥             contact.zip,
160 ⎥         );
161 ⎥         if (self.index == self.slice.len) {
162 ⎥             // Make a new bigger slice.
163 ⎥             const temp_contacts: []*Contact = self.slice;
164 ⎥             self.slice = try self.allocator.alloc(*Contact, (self.slice.len + 5));
165 ⎥             errdefer {
166 ⎥                 contact_copy.deint();
167 ⎥             }
168 ⎥             for (temp_contacts, 0..) |temp_contact, i| {
169 ⎥                 self.slice[i] = temp_contact;
170 ⎥             }
171 ⎥             self.allocator.free(temp_contacts);
172 ⎥         }
173 ⎥         self.slice[self.index] = contact_copy;
174 ⎥         self.index += 1;
175 ⎥     }
176 ⎥ };
177 ⎥ 
```

### remove.zig

```zig
 1 ⎥ pub const Add = @import("add.zig").Contact;
 2 ⎥ pub const Edit = @import("edit.zig").Contact;
 3 ⎥ pub const List = @import("list.zig").Contact;
 4 ⎥ pub const Remove = @import("remove.zig").Contact;
 5 ⎥ pub const Slice = @import("list.zig").Slice;
 6 ⎥ 
```

## Next

[[Create The Messages.||Create-The-Messages]]
