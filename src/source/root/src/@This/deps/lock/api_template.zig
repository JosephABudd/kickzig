pub const content =
    \\const std = @import("std");
    \\
    \\pub const ThreadLock = struct {
    \\    depth: usize,
    \\    id: ?std.Thread.Id,
    \\    id_stack: std.ArrayList(std.Thread.Id),
    \\    mutex: std.Thread.Mutex,
    \\
    \\    pub fn deinit(self: *ThreadLock) void {
    \\        self.id_stack.deinit();
    \\    }
    \\
    \\    pub fn lock(self: *ThreadLock) !void {
    \\        var this_id: std.Thread.Id = std.Thread.getCurrentId();
    \\        if (self.id) |self_id| {
    \\            if (this_id == self_id) {
    \\                // This thread already controls the lock.
    \\                // Let it keep the lock.
    \\                self.depth += 1;
    \\                return;
    \\            } else {
    \\                // This thread does not control the lock.
    \\                // Let it wait.
    \\                try self.id_stack.insert(0, this_id);
    \\                self.mutex.lock();
    \\                return;
    \\            }
    \\        } else {
    \\            // There is no current id.
    \\            self.id = this_id;
    \\            self.depth = 1;
    \\            self.mutex.lock();
    \\        }
    \\    }
    \\
    \\    pub fn unlock(self: *ThreadLock) void {
    \\        self.depth -= 1;
    \\        if (self.depth > 0) {
    \\            // This thread still controls this lock.
    \\            return;
    \\        } else {
    \\            // This thread no longer controls this lock.
    \\            // Move on to the next thread.
    \\            self.id = self.id_stack.popOrNull();
    \\            self.mutex.unlock();
    \\        }
    \\    }
    \\};
    \\
    \\pub fn init(allocator: std.mem.Allocator) !*ThreadLock {
    \\    var self: *ThreadLock = try allocator.create(ThreadLock);
    \\    self.id = null;
    \\    self.depth = 0;
    \\    self.id_stack = std.ArrayList(std.Thread.Id).init(allocator);
    \\    return self;
    \\}
;
