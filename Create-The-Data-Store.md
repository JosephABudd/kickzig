## The local sqlite file

I will use 1 data store which is a local sqlite file. It will be located in the OS's data storage folder as defined by the "known-folders" package. In that data storage folder, I'll add a "crud" folder where I will create my "store.sqlite" file.

## The store package

My sqlite store package will be in the **src/@This/deps/store/**. The package's Store struct has a member called **contact_table**. It is a pointer to the store's Contact table. The store's **contact_table** does all of the contact table work.

## Initializing and using the store package

1. In standalone-sdl.zig, **The store's path is created**.
1. In standalone-sdl.zig, **The store is created**.
1. In standalone-sdl.zig, **The back-end is initialized with the store** allowing it to initialize it's back-end message handlers with the store. Those back-end message handlers are the ones that use the store.

See [[standalone-sdl.zig|standalone--sdl.zig]] in the appendix.

## The store package's api.zig and contact.zig are shown below.

### api.zig

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ const sqlite = @import("sqlite");
  3 ⎥ const Contact = @import("contact.zig").Contact;
  4 ⎥ 
  5 ⎥ pub const Store = struct {
  6 ⎥     allocator: std.mem.Allocator,
  7 ⎥     db: *sqlite.SQLite3,
  8 ⎥     contact_table: *Contact,
  9 ⎥ 
 10 ⎥     /// init creates, opens the store and creates the tables.
 11 ⎥     /// Returns the store or error.
 12 ⎥     pub fn init(allocator: std.mem.Allocator, zpath: [:0]const u8) !*Store {
 13 ⎥         var self: *Store = try allocator.create(Store);
 14 ⎥         self.allocator = allocator;
 15 ⎥         self.db = sqlite.SQLite3.open(zpath) catch |err| {
 16 ⎥             self.allocator.destroy(self);
 17 ⎥             self.printSqliteErrMsg();
 18 ⎥             return err;
 19 ⎥         };
 20 ⎥         // Add the tables.
 21 ⎥         self.contact_table = try Contact.init(self);
 22 ⎥         errdefer {
 23 ⎥             self.db.close() catch {};
 24 ⎥             self.allocator.destroy(self);
 25 ⎥         }
 26 ⎥ 
 27 ⎥         return self;
 28 ⎥     }
 29 ⎥ 
 30 ⎥     pub fn deinit(self: *Store) void {
 31 ⎥         self.db.close() catch {};
 32 ⎥         self.contact_table.deinit();
 33 ⎥         self.allocator.destroy(self);
 34 ⎥     }
 35 ⎥ 
 36 ⎥     pub fn printSqliteErrMsg(self: *Store) void {
 37 ⎥         std.log.warn("sqlite3 errmsg: {s}\n", .{self.db.errmsg()});
 38 ⎥     }
 39 ⎥ };
 40 ⎥ 
 ```

### contact.zig

```zig
  1 ⎥ const std = @import("std");
  2 ⎥ const sqlite = @import("sqlite");
  3 ⎥ const Store = @import("api.zig").Store;
  4 ⎥ const Record = @import("record").Contact;
  5 ⎥ 
  6 ⎥ pub const Contact = struct {
  7 ⎥     store: *Store,
  8 ⎥ 
  9 ⎥     const create_statement: [:0]const u8 =
 10 ⎥         \\ CREATE TABLE IF NOT EXISTS contacts(
 11 ⎥         \\   id INTEGER PRIMARY KEY AUTOINCREMENT,
 12 ⎥         \\   name TEXT NOT NULL,
 13 ⎥         \\   address TEXT NOT NULL,
 14 ⎥         \\   city TEXT NOT NULL,
 15 ⎥         \\   state TEXT NOT NULL,
 16 ⎥         \\   zip TEXT NOT NULL
 17 ⎥         \\ );
 18 ⎥     ;
 19 ⎥ 
 20 ⎥     const get_all_statement: [:0]const u8 =
 21 ⎥         \\ SELECT id, name, address, city, state, zip
 22 ⎥         \\ FROM contacts;
 23 ⎥     ;
 24 ⎥ 
 25 ⎥     const get_statement: [:0]const u8 =
 26 ⎥         \\ SELECT id, name, address, city, state, zip
 27 ⎥         \\ FROM contacts
 28 ⎥         \\ WHERE id == ?;
 29 ⎥     ;
 30 ⎥ 
 31 ⎥     const get_last_inserted_statement: [:0]const u8 =
 32 ⎥         \\ SELECT id, name, address, city, state, zip
 33 ⎥         \\ FROM contacts
 34 ⎥         \\ WHERE id = last_insert_rowid();
 35 ⎥     ;
 36 ⎥ 
 37 ⎥     const add_statement: [:0]const u8 =
 38 ⎥         \\ INSERT INTO contacts(name, address, city, state, zip)
 39 ⎥         \\ VALUES (?, ?, ?, ?, ?);
 40 ⎥     ;
 41 ⎥     const update_statement: [:0]const u8 =
 42 ⎥         \\ UPDATE contacts
 43 ⎥         \\ SET
 44 ⎥         \\   name = ?,
 45 ⎥         \\   address = ?,
 46 ⎥         \\   city = ?,
 47 ⎥         \\   state = ?,
 48 ⎥         \\   zip = ?,
 49 ⎥         \\ WHERE id = ?;
 50 ⎥     ;
 51 ⎥ 
 52 ⎥     const delete_statement: [:0]const u8 =
 53 ⎥         \\ DELETE FROM contacts
 54 ⎥         \\ WHERE id = ?;
 55 ⎥     ;
 56 ⎥ 
 57 ⎥     pub fn init(store: *Store) !*Contact {
 58 ⎥         var self: *Contact = try store.allocator.create(Contact);
 59 ⎥ 
 60 ⎥         // Create the table.
 61 ⎥         store.db.exec(create_statement, null, null, null) catch |err| {
 62 ⎥             store.printSqliteErrMsg();
 63 ⎥             store.allocator.destroy(self);
 64 ⎥             return err;
 65 ⎥         };
 66 ⎥ 
 67 ⎥         self.store = store;
 68 ⎥         return self;
 69 ⎥     }
 70 ⎥ 
 71 ⎥     pub fn deinit(self: *Contact) void {
 72 ⎥         self.store.allocator.destroy(self);
 73 ⎥     }
 74 ⎥ 
 75 ⎥     pub fn add(self: *Contact, name: []const u8, address: []const u8, city: []const u8, state: []const u8, zip: []const u8) !void {
 76 ⎥         var statement: ?*sqlite.Stmt = self.store.db.prepare_v2(add_statement, null) catch |err| {
 77 ⎥             self.store.printSqliteErrMsg();
 78 ⎥             return err;
 79 ⎥         };
 80 ⎥ 
 81 ⎥         if (statement) |stmt| {
 82 ⎥             try stmt.bindText(1, name, .static);
 83 ⎥             try stmt.bindText(2, address, .static);
 84 ⎥             try stmt.bindText(3, city, .static);
 85 ⎥             try stmt.bindText(4, state, .static);
 86 ⎥             try stmt.bindText(5, zip, .static);
 87 ⎥             switch (try stmt.step()) {
 88 ⎥                 // .Ok, .Row => {},
 89 ⎥                 .Done => {
 90 ⎥                     stmt.finalize() catch |err| {
 91 ⎥                         self.store.printSqliteErrMsg();
 92 ⎥                         return err;
 93 ⎥                     };
 94 ⎥                     return;
 95 ⎥                 },
 96 ⎥                 else => {
 97 ⎥                     return error.AddStatementNotDone;
 98 ⎥                 },
 99 ⎥             }
100 ⎥         }
101 ⎥     }
102 ⎥ 
103 ⎥     pub fn update(self: *Contact, id: i64, name: []const u8, address: []const u8, city: []const u8, state: []const u8, zip: []const u8) !void {
104 ⎥         var statement: ?*sqlite.Stmt = self.store.db.prepare_v2(update_statement, null) catch |err| {
105 ⎥             self.store.printSqliteErrMsg();
106 ⎥             return err;
107 ⎥         };
108 ⎥ 
109 ⎥         if (statement) |stmt| {
110 ⎥             try stmt.bindText(1, name, .static);
111 ⎥             try stmt.bindText(2, address, .static);
112 ⎥             try stmt.bindText(3, city, .static);
113 ⎥             try stmt.bindText(4, state, .static);
114 ⎥             try stmt.bindText(5, zip, .static);
115 ⎥             try stmt.bindInt64(6, id);
116 ⎥             switch (try stmt.step()) {
117 ⎥                 // .Ok, .Row => {},
118 ⎥                 .Done => {
119 ⎥                     stmt.finalize() catch |err| {
120 ⎥                         self.store.printSqliteErrMsg();
121 ⎥                         return err;
122 ⎥                     };
123 ⎥                     return;
124 ⎥                 },
125 ⎥                 else => {
126 ⎥                     return error.AddStatementNotDone;
127 ⎥                 },
128 ⎥             }
129 ⎥         }
130 ⎥     }
131 ⎥ 
132 ⎥     // The caller owns the returned value;
133 ⎥     pub fn getAll(self: *Contact) ![]*Record.List {
134 ⎥         var slice = try Record.Slice.init(self.allocator);
135 ⎥         defer slice.deinit();
136 ⎥         var statement: ?*sqlite.Stmt = self.store.db.prepare_v2(get_all_statement, null) catch |err| {
137 ⎥             self.store.printSqliteErrMsg();
138 ⎥             return err;
139 ⎥         };
140 ⎥ 
141 ⎥         if (statement) |stmt| {
142 ⎥             stmt.finalize() catch |err| {
143 ⎥                 self.store.printSqliteErrMsg();
144 ⎥                 return err;
145 ⎥             };
146 ⎥             while (true) {
147 ⎥                 switch (try stmt.step()) {
148 ⎥                     .Done => {
149 ⎥                         return slice.slice();
150 ⎥                     },
151 ⎥                     .Row => {
152 ⎥                         const id = stmt.columnInt(0);
153 ⎥                         const name = stmt.columnText(1);
154 ⎥                         const address = stmt.columnText(2);
155 ⎥                         const city = stmt.columnText(3);
156 ⎥                         const state = stmt.columnText(4);
157 ⎥                         const zip = stmt.columnText(5);
158 ⎥                         const record: *Record.List = try Record.List.init(id, name, address, city, state, zip);
159 ⎥                         try slice.append(record);
160 ⎥                     },
161 ⎥                     .Ok => unreachable,
162 ⎥                 }
163 ⎥             }
164 ⎥         }
165 ⎥     }
166 ⎥ 
167 ⎥     pub fn remove(self: *Contact, id: i64) !void {
168 ⎥         var statement = self.store.db.prepare_v2(delete_statement, null) catch |err| {
169 ⎥             self.store.printSqliteErrMsg();
170 ⎥             return err;
171 ⎥         };
172 ⎥         if (statement) |stmt| {
173 ⎥             try stmt.bindInt64(1, id);
174 ⎥             switch (try stmt.step()) {
175 ⎥                 .Done => {
176 ⎥                     stmt.finalize() catch |err| {
177 ⎥                         self.store.printSqliteErrMsg();
178 ⎥                         return err;
179 ⎥                     };
180 ⎥                     return;
181 ⎥                 },
182 ⎥                 else => unreachable,
183 ⎥             }
184 ⎥         }
185 ⎥     }
186 ⎥ };
187 ⎥ 
```
