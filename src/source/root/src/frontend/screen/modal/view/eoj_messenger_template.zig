pub const content: []const u8 =
    \\    const std = @import("std");
    \\
    \\const _channel_ = @import("channel");
    \\
    \\const ExitFn = @import("various").ExitFn;
    \\const Job = @import("closedownjobs").Job;
    \\const MainView = @import("framers").MainView;
    \\const Message = @import("message").CloseDownJobs.Message;
    \\const Panels = @import("../panels.zig").Panels;
    \\
    \\pub const Messenger = struct {
    \\    allocator: std.mem.Allocator,
    \\
    \\    main_view: *MainView,
    \\    all_panels: *Panels,
    \\    send_channels: *_channel_.FrontendToBackend,
    \\    receive_channels: *_channel_.BackendToFrontend,
    \\    exit: ExitFn,
    \\
    \\    pub fn init(allocator: std.mem.Allocator, main_view: *MainView, send_channels: *_channel_.FrontendToBackend, receive_channels: *_channel_.BackendToFrontend, exit: ExitFn) !*Messenger {
    \\        var messenger: *Messenger = try allocator.create(Messenger);
    \\        messenger.allocator = allocator;
    \\        messenger.main_view = main_view;
    \\        messenger.send_channels = send_channels;
    \\        messenger.receive_channels = receive_channels;
    \\        messenger.exit = exit;
    \\    
    \\        // The CloseDownJobs message.
    \\        // * Define the required behavior.
    \\        var closeDownJobsBehavior = try receive_channels.CloseDownJobs.initBehavior();
    \\        errdefer {
    \\            allocator.destroy(messenger);
    \\        }
    \\        closeDownJobsBehavior.implementor = messenger;
    \\        closeDownJobsBehavior.receiveFn = Messenger.receiveCloseDownJobs;
    \\        // * Subscribe in order to receive the CloseDownJobs messages.
    \\        try receive_channels.CloseDownJobs.subscribe(closeDownJobsBehavior);
    \\        errdefer {
    \\            allocator.destroy(messenger);
    \\        }
    \\    
    \\        return messenger;
    \\    }
    \\
    \\    pub fn deinit(self: *Messenger) void {
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    pub fn sendCloseDownJobs(self: *Messenger, jobs: ?[]const *const Job) void {
    \\        var message: *Message = Message.init(self.allocator) catch {
    \\            // ignore error.
    \\            return;
    \\        };
    \\        message.frontend_payload.set(.{ .jobs = jobs }) catch {
    \\            // ignore error.
    \\            message.deinit();
    \\            return;
    \\        };
    \\        self.send_channels.CloseDownJobs.send(message) catch {
    \\            // ignore error.
    \\            return;
    \\        };
    \\    }
    \\
    \\    // receiveCloseDownJobs receives the CloseDownJobs message from the back-end.
    \\    // It passes the information to the EOJ panel.
    \\    pub fn receiveCloseDownJobs(implementor: *anyopaque, message: *Message) anyerror!void {
    \\        defer message.deinit();
    \\
    \\        var self: *Messenger = @alignCast(@ptrCast(implementor));
    \\        self.all_panels.EOJ.?.update(message.backend_payload.status_update, message.backend_payload.completed, message.backend_payload.progress);
    \\    }
    \\};
    \\
;
