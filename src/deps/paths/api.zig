const std = @import("std");
pub const backend = @import("backend.zig");
const frontend = @import("frontend.zig");
pub const deps = @import("deps.zig");
const fspath = std.fs.path;
const folder_name_src: []const u8 = "src";
pub const folder_name_this: []const u8 = "@This";
pub const folder_name_framers: []const u8 = "framers";
pub const folder_name_lock: []const u8 = "lock";
pub const folder_name_vendor: []const u8 = "vendor";
pub const folder_name_counter: []const u8 = "counter";
pub const modal_folder_name_ok = frontend.folder_name_ok;
pub const modal_folder_name_yesno = frontend.folder_name_yesno;
pub const modal_folder_name_eoj = frontend.folder_name_eoj;

/// FolderPaths is each of the application's folder paths.
pub const FolderPaths = struct {
    built: bool,
    allocator: std.mem.Allocator,
    root: ?[]const u8,
    root_src: ?[]const u8,
    root_src_vendor: ?[]const u8,
    root_src_this: ?[]const u8,
    root_src_this_backend: ?[]const u8,
    root_src_this_backend_messenger: ?[]const u8,
    root_src_this_frontend: ?[]const u8,
    root_src_this_frontend_screen: ?[]const u8,
    root_src_this_frontend_screen_panel: ?[]const u8,
    root_src_this_frontend_screen_htab: ?[]const u8,
    root_src_this_frontend_screen_vtab: ?[]const u8,
    root_src_this_frontend_screen_book: ?[]const u8,
    root_src_this_frontend_screen_modal: ?[]const u8,
    root_src_this_frontend_screen_modal_ok: ?[]const u8,
    root_src_this_deps: ?[]const u8,
    root_src_this_deps_channel: ?[]const u8,
    root_src_this_deps_channel_fronttoback: ?[]const u8,
    root_src_this_deps_channel_backtofront: ?[]const u8,
    root_src_this_deps_channel_trigger: ?[]const u8,
    root_src_this_deps_closer: ?[]const u8,
    root_src_this_deps_counter: ?[]const u8,
    root_src_this_deps_message: ?[]const u8,
    root_src_this_deps_framers: ?[]const u8,
    root_src_this_deps_lock: ?[]const u8,
    root_src_this_deps_closedownjobs: ?[]const u8,
    root_src_this_deps_modal_params: ?[]const u8,
    root_src_this_deps_widget: ?[]const u8,
    root_src_this_deps_startup: ?[]const u8,
    root_src_this_deps_various: ?[]const u8,

    pub fn deinit(self: *FolderPaths) void {
        const allocator: std.mem.Allocator = self.allocator;
        if (self.root) |member| {
            allocator.free(member);
        }
        if (self.root_src) |member| {
            allocator.free(member);
        }
        if (self.root_src_vendor) |member| {
            allocator.free(member);
        }
        if (self.root_src_this) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_backend) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_backend_messenger) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_frontend) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_frontend_screen_panel) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_frontend_screen_htab) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_frontend_screen_vtab) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_frontend_screen_book) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_frontend_screen_modal) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_frontend_screen_modal_ok) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_frontend_screen) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_deps) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_deps_channel) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_deps_channel_backtofront) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_deps_channel_trigger) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_deps_channel_fronttoback) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_deps_closer) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_deps_counter) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_deps_message) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_deps_framers) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_deps_lock) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_deps_closedownjobs) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_deps_modal_params) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_deps_widget) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_deps_startup) |member| {
            allocator.free(member);
        }
        if (self.root_src_this_deps_various) |member| {
            allocator.free(member);
        }
        allocator.destroy(self);
    }

    // unBuild removes the root/src/@This/ folder.
    fn unBuild(self: *FolderPaths) !void {
        if (!paths_exist()) {
            // root/src/@This/ does not exist.
            return;
        }
        // Remove root/src/@This/.
        var dir: std.fs.Dir = undefined;
        dir = try std.fs.openDirAbsolute(self.root_src.?, .{});
        try dir.deleteTree(folder_name_this);
    }

    // isBuilt returns if the frame work is already built.
    pub fn isBuilt(self: *FolderPaths) bool {
        _ = self;
        return paths_exist();
    }

    // reBuild only rebuilds root/src/@This/.
    pub fn reBuild(self: *FolderPaths) !void {
        try self.unBuild();
        var src_dir: std.fs.Dir = try std.fs.openDirAbsolute(self.root_src.?, .{});
        defer src_dir.close();
        try self.buildThis(src_dir);
    }

    /// build creates the src folder and it's sub folders.
    pub fn build(self: *FolderPaths) !void {
        var root_dir: std.fs.Dir = try std.fs.openDirAbsolute(self.root.?, .{});
        defer root_dir.close();
        var src_dir: std.fs.Dir = try root_dir.makeOpenPath(folder_name_src, .{});
        defer src_dir.close();
        try self.buildThis(src_dir);
        var vendor_dir: std.fs.Dir = try src_dir.makeOpenPath(folder_name_vendor, .{});
        defer vendor_dir.close();
    }

    /// buildThis creates the root/src/@This folder and it's sub folders.
    /// Param src_dir is the root/src/ folder.
    fn buildThis(self: *FolderPaths, src_dir: std.fs.Dir) !void {
        var this_dir: std.fs.Dir = try src_dir.makeOpenPath(folder_name_this, .{});
        defer this_dir.close();

        var temp: []const u8 = undefined;

        // root/src/@This/backend/ folder paths.
        try this_dir.makePath(backend.folder_name_backend);
        temp = try backend.pathMessengerFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);

        // root/src/@This/frontend/ folder paths.
        try this_dir.makePath(frontend.folder_name_frontend);
        // frontend/screen/
        temp = try frontend.pathScreenFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // frontend/screen/panel/
        temp = try frontend.pathScreenPanelFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // frontend/screen/htab/
        temp = try frontend.pathScreenHTabFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // frontend/screen/vtab/
        temp = try frontend.pathScreenVTabFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // frontend/screen/book/
        temp = try frontend.pathScreenBookFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // frontend/screen/modal/
        temp = try frontend.pathScreenModalFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // frontend/screen/modal/OK/
        temp = try frontend.pathScreenModalOKFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // frontend/screen/modal/EOJ/
        temp = try frontend.pathScreenModalEOJFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);

        // root/src/@This/deps/ folder paths.
        try this_dir.makePath(deps.folder_name_deps);
        // deps/channel/
        temp = try deps.pathChannelFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // deps/channel/trigger/
        temp = try deps.pathChannelTriggerFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // deps/channel/backtofront/
        temp = try deps.pathChannelBackToFrontFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // deps/channel/fronttoback/
        temp = try deps.pathChannelFrontToBackFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // deps/closer/
        temp = try deps.pathCloserFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // deps/counter/
        temp = try deps.pathCounterFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // deps/closedownjobs/
        temp = try deps.pathCloseDownJobsFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // deps/framers/
        temp = try deps.pathFramersFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // deps/lock/
        temp = try deps.pathLockFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // deps/message/
        temp = try deps.pathMessageFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // deps/modal_params/
        temp = try deps.pathModalParamsFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // deps/widget/
        temp = try deps.pathWidgetFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // deps/startup/
        temp = try deps.pathStartupFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
        // deps/various/
        temp = try deps.pathVariousFolder(self.allocator);
        try this_dir.makePath(temp);
        self.allocator.free(temp);
    }
};

var root_path: []u8 = undefined;
var gpa: std.mem.Allocator = undefined;

/// init stores the root path, and allocator.
/// whoever calls init must eventually call deinit();
pub fn init(allocator: std.mem.Allocator, app_root_path: []const u8) !void {
    gpa = allocator;

    // App folder paths.
    root_path = try allocator.alloc(u8, app_root_path.len);
    @memcpy(root_path, app_root_path);
}

fn paths_exist() bool {
    const folder_paths: *FolderPaths = folders() catch {
        return false;
    };
    var dir: std.fs.Dir = std.fs.openDirAbsolute(folder_paths.root_src_this.?, .{}) catch {
        return false;
    };
    dir.close();
    return true;
}

/// folders returns the folder paths or an error.
/// The caller owns the returned value.
pub fn folders() !*FolderPaths {
    var folder_paths: *FolderPaths = try gpa.create(FolderPaths);
    folder_paths.root = try gpa.alloc(u8, root_path.len);
    errdefer folder_paths.deinit();
    folder_paths.allocator = gpa;

    // The root folder path.
    @memcpy(@constCast(folder_paths.root.?), root_path);

    // The root/src/ folder path.
    var params2: [][]const u8 = try gpa.alloc([]const u8, 2);
    defer gpa.free(params2);
    params2[0] = folder_paths.root.?;
    params2[1] = folder_name_src;
    folder_paths.root_src = try fspath.join(gpa, params2);
    errdefer folder_paths.deinit();

    // The root/src/vendor/ folder path.
    params2[0] = folder_paths.root_src.?;
    params2[1] = folder_name_vendor;
    folder_paths.root_src_vendor = try fspath.join(gpa, params2);
    errdefer folder_paths.deinit();

    // The root/src/@This/ folder path.
    params2[1] = folder_name_this;
    folder_paths.root_src_this = try fspath.join(gpa, params2);
    errdefer folder_paths.deinit();

    // This application's folder path. /src/@This/
    params2[0] = folder_paths.root_src_this.?;
    folder_paths.root_src_this_backend = try fspath.join(gpa, params2[0..0]);
    errdefer folder_paths.deinit();

    // /src/@This/backend/ path.
    params2[1] = backend.folder_name_backend;
    folder_paths.root_src_this_backend = try fspath.join(gpa, params2);
    errdefer folder_paths.deinit();

    // /src/@This/backend/messenger/ path.
    var temp: []const u8 = undefined;
    temp = try backend.pathMessengerFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_backend_messenger = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/frontend/ path.
    params2[1] = frontend.folder_name_frontend;
    folder_paths.root_src_this_frontend = try fspath.join(gpa, params2);
    errdefer {
        folder_paths.deinit();
    }

    // /src/@This/frontend/screen/ path.
    temp = try frontend.pathScreenFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_frontend_screen = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/frontend/screen/panel/ path.
    temp = try frontend.pathScreenPanelFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_frontend_screen_panel = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/frontend/screen/htab/ path.
    temp = try frontend.pathScreenHTabFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_frontend_screen_htab = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/frontend/screen/vtab/ path.
    temp = try frontend.pathScreenVTabFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_frontend_screen_vtab = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/frontend/screen/book/ path.
    temp = try frontend.pathScreenBookFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_frontend_screen_book = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/frontend/screen/modal/ path.
    temp = try frontend.pathScreenModalFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_frontend_screen_modal = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/frontend/screen/modal/OK/ path.
    temp = try frontend.pathScreenModalOKFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_frontend_screen_modal_ok = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/deps/ path.
    params2[1] = deps.folder_name_deps;
    folder_paths.root_src_this_deps = try fspath.join(gpa, params2);
    errdefer {
        folder_paths.deinit();
    }

    // /src/@This/deps/channel/ path.
    temp = try deps.pathChannelFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_deps_channel = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/deps/channel/fronttoback/ path.
    temp = try deps.pathChannelFrontToBackFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_deps_channel_fronttoback = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/deps/channel/backtofront/ path.
    temp = try deps.pathChannelBackToFrontFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_deps_channel_backtofront = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/deps/channel/trigger/ path.
    temp = try deps.pathChannelTriggerFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_deps_channel_trigger = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/deps/closer/ path.
    temp = try deps.pathCloserFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_deps_closer = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/deps/counter/ path.
    temp = try deps.pathCounterFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_deps_counter = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/deps/closedownjobs/ path.
    temp = try deps.pathCloseDownJobsFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_deps_closedownjobs = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/deps/framers/ path.
    temp = try deps.pathFramersFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_deps_framers = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/deps/lock/ path.
    temp = try deps.pathLockFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_deps_lock = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/deps/message/ path.
    temp = try deps.pathMessageFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_deps_message = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/deps/modal_params/ path.
    temp = try deps.pathModalParamsFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_deps_modal_params = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/deps/startup/ path.
    temp = try deps.pathStartupFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_deps_startup = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/deps/widget/ path.
    temp = try deps.pathWidgetFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_deps_widget = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    // /src/@This/deps/various/ path.
    temp = try deps.pathVariousFolder(gpa);
    errdefer {
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.root_src_this_deps_various = try fspath.join(gpa, params2);
    errdefer {
        gpa.free(temp);
        folder_paths.deinit();
    }
    gpa.free(temp);

    return folder_paths;
}
