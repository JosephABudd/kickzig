pub const content: []const u8 =
    \\const std = @import("std");
    \\const dvui = @import("dvui");
    \\
    \\const _closedownjobs_ = @import("closedownjobs");
    \\
    \\const ExitFn = @import("various").ExitFn;
    \\const MainView = @import("framers").MainView;
    \\const Messenger = @import("view/messenger.zig").Messenger;
    \\const ModalParams = @import("modal_params").EOJ;
    \\const Panels = @import("panels.zig").Panels;
    \\const View = @import("view/EOJ.zig").View;
    \\
    \\pub const Panel = struct {
    \\    allocator: std.mem.Allocator,
    \\    window: *dvui.Window,
    \\    main_view: *MainView,
    \\    all_panels: *Panels,
    \\    messenger: *Messenger,
    \\    lock: std.Thread.Mutex,
    \\    exit: ExitFn,
    \\    view: *View,
    \\
    \\    modal_params: ?*ModalParams,
    \\    border_color: dvui.Options.ColorOrName,
    \\
    \\    status: [255]u8,
    \\    status_len: usize,
    \\    completed_callbacks: bool,
    \\    progress: f32,
    \\
    \\    pub fn presetModal(self: *Panel, setup_args: *ModalParams) !void {
    \\        if (self.modal_params != null) {
    \\            // EOJ is single use only.
    \\            setup_args.deinit();
    \\            return;
    \\        }
    \\
    \\        self.modal_params = setup_args;
    \\        self.status_len = 0;
    \\        self.progress = 0.0;
    \\
    \\        if (setup_args.exit_jobs.jobs_index > 0) {
    \\            // There are jobs to run.
    \\            self.completed_callbacks = false;
    \\
    \\            // Send the jobs to the back-end to process.
    \\            const close_down_jobs: ?[]const *const _closedownjobs_.Job = try setup_args.exit_jobs.slice();
    \\            self.messenger.sendCloseDownJobs(close_down_jobs);
    \\        } else {
    \\            // No jobs to run.
    \\            self.completed_callbacks = true;
    \\            if (self.completed_callbacks) {
    \\                const bg_thread = try std.Thread.spawn(.{}, background_progress, .{ self, self.progress });
    \\                bg_thread.detach();
    \\            }
    \\        }
    \\    }
    \\
    \\    pub fn init(allocator: std.mem.Allocator, main_view: *MainView, all_panels: *Panels, messenger: *Messenger, exit: ExitFn, window: *dvui.Window, theme: *dvui.Theme) !*Panel {
    \\        var self: *Panel = try allocator.create(Panel);
    \\        self.lock = std.Thread.Mutex{};
    \\        self.view = try View.init(
    \\            allocator,
    \\            window,
    \\            main_view,
    \\            all_panels,
    \\            exit,
    \\        );
    \\        errdefer {
    \\            allocator.destroy(self);
    \\        }
    \\        self.allocator = allocator;
    \\        self.window = window;
    \\        self.main_view = main_view;
    \\        self.all_panels = all_panels;
    \\        self.messenger = messenger;
    \\        self.exit = exit;
    \\        self.border_color = theme.style_accent.color_accent.?;
    \\        self.modal_params = null;
    \\        self.status_len = 0;
    \\        self.completed_callbacks = false;
    \\        self.progress = 0.0;
    \\        return self;
    \\    }
    \\
    \\    pub fn deinit(self: *Panel) void {
    \\        if (self.modal_params) |modal_params| {
    \\            modal_params.deinit();
    \\        }
    \\        self.view.deinit();
    \\        self.allocator.destroy(self);
    \\    }
    \\
    \\    // close removes this modal screen replacing it with the previous screen.
    \\    fn close(self: *Panel) void {
    \\        self.main_view.hideEOJ();
    \\    }
    \\
    \\    pub fn update(self: *Panel, status: ?[]const u8, completed_callbacks: bool, progress: f32) void {
    \\        // Block fn frame.
    \\        self.lock.lock();
    \\        defer self.lock.unlock();
    \\
    \\        if (self.completed_callbacks) {
    \\            std.log.debug("EOJPanel.update: called after completed.", .{});
    \\            return;
    \\        }
    \\
    \\        if (status) |text| {
    \\            if (text.len > 0) {
    \\                self.status_len = @min(text.len, 255);
    \\                for (0..self.status_len) |i| {
    \\                    self.status[i] = text[i];
    \\                }
    \\            } else {
    \\                self.status_len = 0;
    \\            }
    \\        } else {
    \\            self.status_len = 0;
    \\        }
    \\        self.completed_callbacks = completed_callbacks;
    \\        if (self.completed_callbacks) {
    \\            // There will be no more updates from the back end.
    \\            // Let the back ground thread update progress and call refresh().
    \\            const bg_thread = std.Thread.spawn(.{}, background_progress, .{ self, self.progress }) catch {
    \\                return;
    \\            };
    \\            bg_thread.detach();
    \\        } else {
    \\            // Update progress and call refresh();
    \\            self.progress = progress;
    \\            dvui.refresh(self.window, @src(), null);
    \\        }
    \\    }
    \\
    \\    /// frame this panel.
    \\    /// Layout, Draw, Handle user events.
    \\    /// Displays a progress bar.
    \\    /// Continues the progress bar after callbacks are finished running.
    \\    /// Allows the window to close after the progress bar finishes.
    \\    pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {
    \\        return self.view.frame(
    \\            arena,
    \\            self.modal_params,
    \\            self.status,
    \\            self.status_len,
    \\            self.completed_callbacks,
    \\            self.progress,
    \\        );
    \\    }
    \\
    \\    /// Called when there are no more jobs to run.
    \\    fn background_progress(self: *Panel, self_progress: f32) !void {
    \\        const interval: u64 = 10_000_000;
    \\        var current_progress: f32 = self_progress;
    \\        var progress: f32 = current_progress;
    \\        while (progress < 1.0) {
    \\            std.time.sleep(interval);
    \\            progress += 0.005;
    \\            {
    \\                if (progress > current_progress) {
    \\                    current_progress = progress;
    \\                    // Block fn frame.
    \\                    self.lock.lock();
    \\                    self.progress = current_progress;
    \\                    self.lock.unlock();
    \\                    dvui.refresh(self.window, @src(), null);
    \\                }
    \\            }
    \\        }
    \\    }
    \\};
;
