pub const content: []const u8 =
    \\const std = @import("std");
    \\const _framers_ = @import("framers");
    \\const _lock_ = @import("lock");
    \\const _jobs_ = @import("closedownjobs");
    \\const Params = @import("modal_params").EOJ;
    \\
    \\const Context = enum {
    \\    none,
    \\    started,
    \\    completed,
    \\};
    \\
    \\var lock: *_lock_.ThreadLock = undefined;
    \\var screens: *_framers_.Group = undefined;
    \\var state: Context = .none;
    \\var modal_params: *Params = undefined;
    \\
    \\pub fn eoj() void {
    \\    lock.lock();
    \\    defer lock.unlock();
    \\
    \\    state = .completed;
    \\}
    \\
    \\pub fn init(allocator: std.mem.Allocator, jobs: *_jobs_.Jobs) !*const fn (user_message: []const u8) void {
    \\    lock = try _lock_.init(allocator);
    \\    screens = undefined;
    \\    modal_params = try Params.init(allocator, jobs);
    \\    return &exit;
    \\}
    \\
    \\pub fn set_screens(all_screens: *_framers_.Group) void {
    \\    screens = all_screens;
    \\}
    \\
    \\pub fn deinit() void {
    \\    modal_params.deinit();
    \\}
    \\
    \\fn exit(user_message: []const u8) void {
    \\    lock.lock();
    \\    if (state != .none) {
    \\        lock.unlock();
    \\        return;
    \\    }
    \\    state = .started;
    \\    lock.unlock();
    \\
    \\    var behavior = screens.get("EOJ") catch return;
    \\    modal_params.is_fatal = true;
    \\    modal_params.setHeading("Closing. Fatal Error.");
    \\    modal_params.setMessage(user_message);
    \\    _ = behavior.goModalFn.?(behavior.implementor, modal_params);
    \\}
    \\
    \\pub fn close(user_message: []const u8) void {
    \\    lock.lock();
    \\    if (state != .none) {
    \\        lock.unlock();
    \\        return;
    \\    }
    \\    state = .started;
    \\    lock.unlock();
    \\
    \\    var behavior: *_framers_.Behavior = screens.get("EOJ") catch |err| {
    \\        std.log.debug("{s}", .{@errorName(err)});
    \\        return;
    \\    };
    \\    modal_params.setHeading("Closing");
    \\    modal_params.setMessage(user_message);
    \\    _ = behavior.goModalFn.?(behavior.implementor, modal_params);
    \\}
    \\
    \\pub fn context() Context {
    \\    lock.lock();
    \\    defer lock.unlock();
    \\    return state;
    \\}
;
