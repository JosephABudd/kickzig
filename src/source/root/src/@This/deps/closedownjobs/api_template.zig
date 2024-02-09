pub const content: []const u8 =
    \\const std = @import("std");
    \\const Counter = @import("counter").Counter;
    \\
    \\pub const Jobs = struct {
    \\    allocator: std.mem.Allocator,
    \\    jobs: []const *Job,
    \\    jobs_index: usize,
    \\
    \\    pub fn deinit(self: *Jobs) void {
    \\        for (self.jobs, 0..) |job, i| {
    \\            if (i == self.jobs_index) {
    \\                break;
    \\            }
    \\            job.deinit();
    \\        }
    \\        self.allocator.free(self.jobs);
    \\    }
    \\
    \\    pub fn init(allocator: std.mem.Allocator) !*Jobs {
    \\        var self: *Jobs = try allocator.create(Jobs);
    \\        self.allocator = allocator;
    \\        self.jobs = try allocator.alloc(*Job, 10);
    \\        errdefer {
    \\            allocator.destroy(self);
    \\        }
    \\        self.jobs_index = 0;
    \\        return self;
    \\    }
    \\
    \\    // add adds a job to be run before exit.
    \\    pub fn add(
    \\        self: *Jobs,
    \\        title: []const u8,
    \\        implementor: *anyopaque,
    \\        function: *fn () void,
    \\    ) !void {
    \\        if (self.jobs_index == self.jobs.len) {
    \\            var more_jobs: []*Job = try self.allocator.alloc(*Job, (self.jobs_index + 10));
    \\            for (self.jobs, 0..) |job, i| {
    \\                more_jobs[i] = job;
    \\            }
    \\            self.allocator.free(self.jobs);
    \\            self.jobs = more_jobs;
    \\        }
    \\        var job: *Job = try Job.init(self.allocator, title, implementor, function);
    \\        self.jobs[self.jobs_index] = job;
    \\        self.jobs_index += 1;
    \\    }
    \\
    \\    pub fn slice(self: *Jobs) !?[]const *Job {
    \\        if (self.jobs_index == 0) {
    \\            return null;
    \\        }
    \\        var copy: []*Job = try self.allocator.alloc(*Job, self.jobs_index);
    \\        for (self.jobs, 0..) |job, i| {
    \\            if (i == self.jobs_index) {
    \\                break;
    \\            }
    \\            copy[i] = job;
    \\        }
    \\        return copy;
    \\    }
    \\};
    \\
    \\pub const Job = struct {
    \\    allocator: std.mem.Allocator,
    \\    count_pointers: *Counter,
    \\    title: []const u8,
    \\    implementor: *anyopaque,
    \\    job: *fn (implementor: *anyopaque) void,
    \\
    \\    // deinit does not deinit until self is the final pointer to Job.
    \\    pub fn deinit(self: *Job) void {
    \\        if (self.count_pointers.dec() > 0) {
    \\            // There are more pointers.
    \\            // See fn copy.
    \\            return;
    \\        }
    \\        // This is the last existing pointer.
    \\        self.allocator.free(self.title);
    \\        self.count_pointers.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    /// copy pretends to create and return a copy of the Job.
    \\    /// In order to save memory space, it really only
    \\    /// * increments the count of the number of pointers to this Job.
    \\    /// * returns self.
    \\    /// See deinit().
    \\    pub fn copy(self: *Job) !*Job {
    \\        _ = self.count_pointers.inc();
    \\        return self;
    \\    }
    \\
    \\    pub fn init(
    \\        allocator: std.mem.Allocator,
    \\        title: []const u8,
    \\        implementor: *anyopaque,
    \\        job: *fn () void,
    \\    ) !*Job {
    \\        var self: *Job = try allocator.create(Job);
    \\        self.title = try allocator.alloc(u8, title.len);
    \\        @memcpy(@constCast(self.title), title);
    \\        self.allocator = allocator;
    \\        self.implementor = implementor;
    \\        self.job = job;
    \\        return self;
    \\    }
    \\};
;
