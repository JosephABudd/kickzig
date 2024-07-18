
I will use 1 data store which is a local sqlite file. It will be located in the OS's data storage folder as defined by the zig's **std.fs** package. In that data storage folder, I'll add a "crud" folder where I will create my "store.sqlite" file.

## The store package

My sqlite store package will be in the **src/deps/store/**. The package's Store struct has a member **contact_table**. It is a pointer to the store's Contact table. The store's **contact_table** does all of the contact table work.

## Initializing and using the store package

1. In main.zig, **The store's path is created**.
1. In main.zig, **The store is created**.
1. In main.zig, **The store is added to the back-end startup params**.
1. In main.zig, **The back-end is initialized with the startup params** allowing it to initialize it's back-end message handlers with the store. Those back-end message handlers are the ones that use the store.

See [[main.zig|main.zig]] in the appendix.

## The store package's api.zig and contact.zig are shown below

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
  4 ⎥ const Record = @import("record");
  5 ⎥ 
  6 ⎥ pub const Contact = struct {
  7 ⎥     store: *Store,
  8 ⎥     allocator: std.mem.Allocator,
  9 ⎥ 
 10 ⎥     const create_statement: [:0]const u8 =
 11 ⎥         \\ CREATE TABLE IF NOT EXISTS contacts(
 12 ⎥         \\   id INTEGER PRIMARY KEY AUTOINCREMENT,
 13 ⎥         \\   name TEXT NOT NULL,
 14 ⎥         \\   address TEXT NOT NULL,
 15 ⎥         \\   city TEXT NOT NULL,
 16 ⎥         \\   state TEXT NOT NULL,
 17 ⎥         \\   zip TEXT NOT NULL
 18 ⎥         \\ );
 19 ⎥     ;
 20 ⎥ 
 21 ⎥     const get_all_statement: [:0]const u8 =
 22 ⎥         \\ SELECT id, name, address, city, state, zip
 23 ⎥         \\ FROM contacts;
 24 ⎥     ;
 25 ⎥ 
 26 ⎥     const get_statement: [:0]const u8 =
 27 ⎥         \\ SELECT id, name, address, city, state, zip
 28 ⎥         \\ FROM contacts
 29 ⎥         \\ WHERE id == ?;
 30 ⎥     ;
 31 ⎥ 
 32 ⎥     const get_last_inserted_statement: [:0]const u8 =
 33 ⎥         \\ SELECT id, name, address, city, state, zip
 34 ⎥         \\ FROM contacts
 35 ⎥         \\ WHERE id = last_insert_rowid();
 36 ⎥     ;
 37 ⎥ 
 38 ⎥     const add_statement: [:0]const u8 =
 39 ⎥         \\ INSERT INTO contacts(name, address, city, state, zip)
 40 ⎥         \\ VALUES (?, ?, ?, ?, ?);
 41 ⎥     ;
 42 ⎥     const update_statement: [:0]const u8 =
 43 ⎥         \\ UPDATE contacts
 44 ⎥         \\ SET
 45 ⎥         \\   name = ?,
 46 ⎥         \\   address = ?,
 47 ⎥         \\   city = ?,
 48 ⎥         \\   state = ?,
 49 ⎥         \\   zip = ?
 50 ⎥         \\ WHERE id = ?;
 51 ⎥     ;
 52 ⎥ 
 53 ⎥     const delete_statement: [:0]const u8 =
 54 ⎥         \\ DELETE FROM contacts
 55 ⎥         \\ WHERE id = ?;
 56 ⎥     ;
 57 ⎥ 
 58 ⎥     pub fn init(store: *Store) !*Contact {
 59 ⎥         var self: *Contact = try store.allocator.create(Contact);
 60 ⎥         self.allocator = store.allocator;
 61 ⎥         self.store = store;
 62 ⎥ 
 63 ⎥         // Create the table.
 64 ⎥         var statement = try self.store.db.prepare(create_statement);
 65 ⎥         defer statement.deinit();
 66 ⎥         try statement.exec();
 67 ⎥         errdefer {
 68 ⎥             self.allocator.destroy(self);
 69 ⎥         }
 70 ⎥ 
 71 ⎥         return self;
 72 ⎥     }
 73 ⎥ 
 74 ⎥     pub fn deinit(self: *Contact) void {
 75 ⎥         self.allocator.destroy(self);
 76 ⎥     }
 77 ⎥ 
 78 ⎥     pub fn add(self: *Contact, name: []const u8, address: []const u8, city: []const u8, state: []const u8, zip: []const u8) !void {
 79 ⎥         var statement = try self.store.db.prepare(add_statement);
 80 ⎥         defer statement.deinit();
 81 ⎥ 
 82 ⎥         try statement.bind(0, name);
 83 ⎥         try statement.bind(1, address);
 84 ⎥         try statement.bind(2, city);
 85 ⎥         try statement.bind(3, state);
 86 ⎥         try statement.bind(4, zip);
 87 ⎥ 
 88 ⎥         try statement.exec();
 89 ⎥     }
 90 ⎥ 
 91 ⎥     pub fn update(self: *Contact, id: i64, name: []const u8, address: []const u8, city: []const u8, state: []const u8, zip: []const u8) !void {
 92 ⎥         var statement = try self.store.db.prepare(update_statement);
 93 ⎥         defer statement.deinit();
 94 ⎥ 
 95 ⎥         try statement.bind(0, name);
 96 ⎥         try statement.bind(1, address);
 97 ⎥         try statement.bind(2, city);
 98 ⎥         try statement.bind(3, state);
 99 ⎥         try statement.bind(4, zip);
100 ⎥         try statement.bind(5, id);
101 ⎥ 
102 ⎥         try statement.exec();
103 ⎥     }
104 ⎥ 
105 ⎥     // The caller owns the returned value;
106 ⎥     pub fn getAll(self: *Contact) !?[]*const Record.List {
107 ⎥         var statement: sqlite.Statement = try self.store.db.prepare(get_all_statement);
108 ⎥         defer statement.deinit();
109 ⎥ 
110 ⎥         var rows = std.ArrayList(*const Record.List).init(self.allocator);
111 ⎥         defer rows.deinit();
112 ⎥ 
113 ⎥         while (true) {
114 ⎥             switch (try statement.step()) {
115 ⎥                 .row => {
116 ⎥                     // Construct the list record from the row.
117 ⎥                     const list: *const Record.List = try self.statementToListRecord(&statement);
118 ⎥                     errdefer {
119 ⎥                         while (rows.popOrNull()) |row| {
120 ⎥                             row.deinit();
121 ⎥                         }
122 ⎥                         rows.deinit();
123 ⎥                     }
124 ⎥                     // Add the list record.
125 ⎥                     try rows.append(list);
126 ⎥                     errdefer {
127 ⎥                         while (rows.popOrNull()) |row| {
128 ⎥                             row.deinit();
129 ⎥                         }
130 ⎥                         rows.deinit();
131 ⎥                     }
132 ⎥                 },
133 ⎥                 .done => {
134 ⎥                     const records = try rows.toOwnedSlice();
135 ⎥                     if (records.len > 0) {
136 ⎥                         return records;
137 ⎥                     }
138 ⎥                     // No records.
139 ⎥                     self.allocator.free(records);
140 ⎥                     return null;
141 ⎥                 },
142 ⎥             }
143 ⎥         }
144 ⎥         // No records.
145 ⎥         return null;
146 ⎥     }
147 ⎥ 
148 ⎥     pub fn remove(self: *Contact, id: i64) !void {
149 ⎥         var statement = try self.store.db.prepare(delete_statement);
150 ⎥         defer statement.deinit();
151 ⎥ 
152 ⎥         try statement.bind(0, id);
153 ⎥ 
154 ⎥         try statement.exec();
155 ⎥     }
156 ⎥ 
157 ⎥     fn statementToListRecord(self: *Contact, statement: *sqlite.Statement) !*const Record.List {
158 ⎥         // Read each column.
159 ⎥         const id = try statement.column(i64, 0);
160 ⎥         const name = try statement.column([]const u8, 1);
161 ⎥         const address = try statement.column([]const u8, 2);
162 ⎥         errdefer {
163 ⎥             self.allocator.free(name);
164 ⎥         }
165 ⎥         const city = try statement.column([]const u8, 3);
166 ⎥         errdefer {
167 ⎥             self.allocator.free(name);
168 ⎥             self.allocator.free(address);
169 ⎥         }
170 ⎥         const state = try statement.column([]const u8, 4);
171 ⎥         errdefer {
172 ⎥             self.allocator.free(name);
173 ⎥             self.allocator.free(address);
174 ⎥             self.allocator.free(city);
175 ⎥         }
176 ⎥         const zip = try statement.column([]const u8, 5);
177 ⎥         errdefer {
178 ⎥             self.allocator.free(name);
179 ⎥             self.allocator.free(address);
180 ⎥             self.allocator.free(city);
181 ⎥             self.allocator.free(state);
182 ⎥         }
183 ⎥ 
184 ⎥         // Construct the list record.
185 ⎥         const list: *const Record.List = try Record.List.init(
186 ⎥             self.allocator,
187 ⎥             id,
188 ⎥             name,
189 ⎥             address,
190 ⎥             city,
191 ⎥             state,
192 ⎥             zip,
193 ⎥         );
194 ⎥         errdefer {
195 ⎥             self.allocator.free(name);
196 ⎥             self.allocator.free(address);
197 ⎥             self.allocator.free(city);
198 ⎥             self.allocator.free(state);
199 ⎥             self.allocator.free(zip);
200 ⎥         }
201 ⎥ 
202 ⎥         // Return the list record.
203 ⎥         return list;
204 ⎥     }
205 ⎥ };
206 ⎥ ```

## Next

[[Create The Records.|Create-The-Records]]
