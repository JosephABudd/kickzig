const std = @import("std");
const builtin = @import("builtin");
pub const backend = @import("backend.zig");
const frontend = @import("frontend.zig");
pub const deps = @import("deps.zig");
const fspath = std.fs.path;
const folder_name_src: []const u8 = "src";
pub const folder_name_framers: []const u8 = "framers";
pub const folder_name_lock: []const u8 = "lock";
pub const folder_name_counter: []const u8 = "counter";
pub const modal_folder_name_ok = frontend.folder_name_ok;
pub const modal_folder_name_yesno = frontend.folder_name_yesno;
pub const modal_folder_name_eoj = frontend.folder_name_eoj;

pub var app_name: ?[]const u8 = null;
pub var root_path: ?[]const u8 = undefined;
var gpa: std.mem.Allocator = undefined;

/// init stores the root path, and allocator.
/// whoever calls init must eventually call deinit();
pub fn init(allocator: std.mem.Allocator) !bool {
    gpa = allocator;
    return initRootAppName();
}

pub fn deinit() void {
    if (app_name) |member| {
        gpa.free(member);
    }
    if (root_path) |member| {
        gpa.free(member);
    }
}

fn setRootPath(disk: ?[]const u8, folder_names: []const []const u8) !void {
    // Build the root path.
    const path: []const u8 = try fspath.join(gpa, folder_names);
    if (disk) |d| {
        defer gpa.free(path);
        const parts: [2][]const u8 = [2][]const u8{ d, path };
        root_path = try std.mem.join(gpa, "", &parts);
        // root_path = try fspath.join(gpa, &parts);
    } else {
        root_path = path;
    }
}

fn setAppName(name: []const u8) !void {
    app_name = try gpa.alloc(u8, name.len);
    @memcpy(@constCast(app_name.?), name);
}

fn initRootAppName() !bool {
    const cwd: []const u8 = try std.process.getCwdAlloc(gpa);
    defer gpa.free(cwd);
    return switch (builtin.target.os.tag) {
        .windows => initRootAppNameWindows(cwd),
        else => initRootAppNameLinux(cwd),
    };
}

fn initRootAppNameLinux(cwd: []const u8) !bool {
    var disk_designator: ?[]const u8 = null;
    var path_buffer: []const u8 = undefined;
    if (cwd[0] == std.fs.path.sep) {
        disk_designator = cwd[0..1];
        path_buffer = cwd[1..];
    } else {
        path_buffer = cwd;
    }
    var iterator = std.mem.splitScalar(
        u8,
        path_buffer,
        std.fs.path.sep,
    );
    var parts_list = std.ArrayList([]const u8).init(gpa);
    while (iterator.next()) |folder| {
        try parts_list.append(folder);
    }
    const parts: []const []const u8 = try parts_list.toOwnedSlice();
    if (try build_app_name_root_path(disk_designator, parts)) {
        return true;
    }
    // Check the cwd. Does it contain the src folder.
    return src_path_exists(cwd);
}

fn initRootAppNameWindows(cwd: []const u8) !bool {
    var disk_designator: ?[]const u8 = try std.fs.path.diskDesignatorWindows(cwd);
    const path_buffer: []const u8 = cwd[disk_designator.len..];
    if (disk_designator) |disk| {
        if (disk.len == 0) {
            disk_designator = null;
        }
    }
    var iterator = std.mem.splitScalar(
        u8,
        path_buffer,
        std.fs.path.sep,
    );
    var parts_list = std.ArrayList([]const u8).init(gpa);
    while (iterator.next()) |folder| {
        try parts_list.append(folder);
    }
    const parts: []const []const u8 = try parts_list.toOwnedSlice();
    if (try build_app_name_root_path(disk_designator, parts)) {
        return true;
    }
    // Check the cwd. Does it contain the src folder.
    return src_path_exists(cwd);
}

fn build_app_name_root_path(disk_designator: ?[]const u8, parts: []const []const u8) !bool {
    if (parts.len <= 1) {
        return false;
    }
    // Figure it out.
    const start: usize = parts.len - 1;
    var i: usize = start;
    var src_i: usize = parts.len;
    while (i >= 0) {
        if (std.mem.eql(u8, parts[i], folder_name_src)) {
            src_i = i;
        }
        if (i == 0) {
            break;
        } else {
            i -= 1;
        }
    }
    if (src_i < parts.len and src_i > 0) {
        // Have app_name/src/.
        try setAppName(parts[src_i - 1]);
        try setRootPath(disk_designator, parts[0..src_i]);
        return true;
    }
    // Possibly in a potential root folder.
    try setAppName(parts[start]);
    try setRootPath(disk_designator, parts);
    return false;
}

/// FolderPaths is each of the application's folder paths.
pub const FolderPaths = struct {
    built: bool,
    allocator: std.mem.Allocator,
    root: ?[]const u8,
    root_src: ?[]const u8,
    root_src_backend: ?[]const u8,
    root_src_backend_messenger: ?[]const u8,
    root_src_frontend: ?[]const u8,
    root_src_frontend_screen: ?[]const u8,
    root_src_frontend_screen_panel: ?[]const u8,
    root_src_frontend_screen_tab: ?[]const u8,
    root_src_frontend_screen_book: ?[]const u8,
    root_src_frontend_screen_modal: ?[]const u8,
    root_src_frontend_screen_modal_ok: ?[]const u8,
    root_src_deps: ?[]const u8,
    root_src_deps_channel: ?[]const u8,
    root_src_deps_channel_fronttoback: ?[]const u8,
    root_src_deps_channel_backtofront: ?[]const u8,
    root_src_deps_channel_trigger: ?[]const u8,
    root_src_deps_closer: ?[]const u8,
    root_src_deps_counter: ?[]const u8,
    root_src_deps_message: ?[]const u8,
    root_src_deps_framers: ?[]const u8,
    root_src_deps_lock: ?[]const u8,
    root_src_deps_closedownjobs: ?[]const u8,
    root_src_deps_modal_params: ?[]const u8,
    root_src_deps_widget: ?[]const u8,
    root_src_deps_widget_tabbar: ?[]const u8,
    root_src_deps_startup: ?[]const u8,
    root_src_deps_various: ?[]const u8,

    pub fn deinit(self: *FolderPaths) void {
        const allocator: std.mem.Allocator = self.allocator;
        if (self.root) |member| {
            allocator.free(member);
        }
        if (self.root_src) |member| {
            allocator.free(member);
        }
        if (self.root_src_backend) |member| {
            allocator.free(member);
        }
        if (self.root_src_backend_messenger) |member| {
            allocator.free(member);
        }
        if (self.root_src_frontend) |member| {
            allocator.free(member);
        }
        if (self.root_src_frontend_screen_panel) |member| {
            allocator.free(member);
        }
        if (self.root_src_frontend_screen_tab) |member| {
            allocator.free(member);
        }
        if (self.root_src_frontend_screen_book) |member| {
            allocator.free(member);
        }
        if (self.root_src_frontend_screen_modal) |member| {
            allocator.free(member);
        }
        if (self.root_src_frontend_screen_modal_ok) |member| {
            allocator.free(member);
        }
        if (self.root_src_frontend_screen) |member| {
            allocator.free(member);
        }
        if (self.root_src_deps) |member| {
            allocator.free(member);
        }
        if (self.root_src_deps_channel) |member| {
            allocator.free(member);
        }
        if (self.root_src_deps_channel_backtofront) |member| {
            allocator.free(member);
        }
        if (self.root_src_deps_channel_trigger) |member| {
            allocator.free(member);
        }
        if (self.root_src_deps_channel_fronttoback) |member| {
            allocator.free(member);
        }
        if (self.root_src_deps_closer) |member| {
            allocator.free(member);
        }
        if (self.root_src_deps_counter) |member| {
            allocator.free(member);
        }
        if (self.root_src_deps_message) |member| {
            allocator.free(member);
        }
        if (self.root_src_deps_framers) |member| {
            allocator.free(member);
        }
        if (self.root_src_deps_lock) |member| {
            allocator.free(member);
        }
        if (self.root_src_deps_closedownjobs) |member| {
            allocator.free(member);
        }
        if (self.root_src_deps_modal_params) |member| {
            allocator.free(member);
        }
        if (self.root_src_deps_widget) |member| {
            allocator.free(member);
        }
        if (self.root_src_deps_widget_tabbar) |member| {
            allocator.free(member);
        }
        if (self.root_src_deps_startup) |member| {
            allocator.free(member);
        }
        if (self.root_src_deps_various) |member| {
            allocator.free(member);
        }
        allocator.destroy(self);
    }

    // unBuild removes the root/src/ folder.
    fn unBuild(self: *FolderPaths) !void {
        if (root_path) |root| {
            if (!src_path_exists(root)) {
                return;
            }
            // Remove root/src/.
            var dir: std.fs.Dir = try std.fs.openDirAbsolute(self.root.?, .{});
            defer dir.close();
            try dir.deleteTree(folder_name_src);
        }
    }

    // isBuilt returns if the frame work is already built.
    pub fn isBuilt(self: *FolderPaths) bool {
        _ = self;
        if (root_path) |root| {
            return src_path_exists(root);
        }
        return false;
    }

    // reBuild only rebuilds root/src/.
    pub fn reBuild(self: *FolderPaths) !void {
        try self.unBuild();
        var src_dir: std.fs.Dir = try std.fs.openDirAbsolute(self.root_src.?, .{});
        defer src_dir.close();
        try self.buildSrcSubFolders(src_dir);
    }

    /// build creates the src folder and it's sub folders.
    pub fn build(self: *FolderPaths) !void {
        var root_dir: std.fs.Dir = try std.fs.openDirAbsolute(self.root.?, .{});
        defer root_dir.close();
        var src_dir: std.fs.Dir = try root_dir.makeOpenPath(folder_name_src, .{});
        defer src_dir.close();
        try self.buildSrcSubFolders(src_dir);
    }

    /// buildSrcSubFolders creates the root/src/ sub folders.
    /// Param src_dir is the root/src/ folder.
    fn buildSrcSubFolders(self: *FolderPaths, src_dir: std.fs.Dir) !void {
        var temp: []const u8 = undefined;

        // root/src/backend/
        {
            // root/src/backend/ folder paths.
            try src_dir.makePath(backend.folder_name_backend);
            temp = try backend.pathMessengerFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }

        // root/src/frontend/.
        {
            // root/src/frontend/ folder paths.
            try src_dir.makePath(frontend.folder_name_frontend);
            // frontend/screen/
            temp = try frontend.pathScreenFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // frontend/screen/panel/
            temp = try frontend.pathScreenPanelFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // frontend/screen/tab/
            temp = try frontend.pathScreenTabFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // frontend/screen/book/
            temp = try frontend.pathScreenBookFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // frontend/screen/modal/
            temp = try frontend.pathScreenModalFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // frontend/screen/modal/OK/
            temp = try frontend.pathScreenModalOKFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // frontend/screen/modal/EOJ/
            temp = try frontend.pathScreenModalEOJFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }

        // root/src/deps/
        {
            // root/src/deps/ folder paths.
            try src_dir.makePath(deps.folder_name_deps);
            // deps/channel/
            temp = try deps.pathChannelFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // deps/channel/trigger/
            temp = try deps.pathChannelTriggerFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // deps/channel/backtofront/
            temp = try deps.pathChannelBackToFrontFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // deps/channel/fronttoback/
            temp = try deps.pathChannelFrontToBackFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // deps/closer/
            temp = try deps.pathCloserFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // deps/counter/
            temp = try deps.pathCounterFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // deps/closedownjobs/
            temp = try deps.pathCloseDownJobsFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // deps/framers/
            temp = try deps.pathFramersFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // deps/lock/
            temp = try deps.pathLockFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // deps/message/
            temp = try deps.pathMessageFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // deps/modal_params/
            temp = try deps.pathModalParamsFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // deps/widget/
            temp = try deps.pathWidgetFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // deps/widget/tabbar/
            temp = try deps.pathWidgetTabbarFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // deps/startup/
            temp = try deps.pathStartupFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
        {
            // deps/various/
            temp = try deps.pathVariousFolder(self.allocator);
            defer self.allocator.free(temp);
            try src_dir.makePath(temp);
        }
    }
};

fn src_path_exists(root: []const u8) bool {
    var root_dir: std.fs.Dir = std.fs.openDirAbsolute(root, .{}) catch {
        return false;
    };
    defer root_dir.close();
    var src_dir: std.fs.Dir = root_dir.openDir(folder_name_src, .{}) catch {
        return false;
    };
    defer src_dir.close();

    // src/backend/
    var backend_dir: std.fs.Dir = src_dir.openDir(backend.folder_name_backend, .{}) catch {
        return false;
    };
    backend_dir.close();

    // src/frontend/
    var frontend_dir: std.fs.Dir = src_dir.openDir(frontend.folder_name_frontend, .{}) catch {
        return false;
    };
    frontend_dir.close();

    // src/deps/
    var deps_dir: std.fs.Dir = src_dir.openDir(deps.folder_name_deps, .{}) catch {
        return false;
    };
    deps_dir.close();

    // src/backend/ exists.
    // src/frontend/ exists.
    // src/deps/ exists.
    return true;
}

/// folders returns the folder paths or an error.
/// The caller owns the returned value.
pub fn folders() !*FolderPaths {
    if (root_path) |root| {
        var folder_paths: *FolderPaths = try gpa.create(FolderPaths);
        folder_paths.allocator = gpa;

        // The root folder path.
        folder_paths.root = try gpa.alloc(u8, root.len);
        errdefer folder_paths.deinit();
        @memcpy(@constCast(folder_paths.root.?), root);

        // The root/src/ folder path.
        var params2: [][]const u8 = try gpa.alloc([]const u8, 2);
        defer gpa.free(params2);
        params2[0] = folder_paths.root.?;
        params2[1] = folder_name_src;
        folder_paths.root_src = try fspath.join(gpa, params2);
        errdefer folder_paths.deinit();

        // This application's folder path. root/src/.
        params2[0] = folder_paths.root_src.?;
        folder_paths.root_src_backend = try fspath.join(gpa, params2[0..0]);
        errdefer folder_paths.deinit();

        // /src/backend/ path.
        params2[1] = backend.folder_name_backend;
        folder_paths.root_src_backend = try fspath.join(gpa, params2);
        errdefer folder_paths.deinit();

        // /src/backend/messenger/ path.
        var temp: []const u8 = undefined;
        {
            temp = try backend.pathMessengerFolder(gpa);
            errdefer {
                folder_paths.deinit();
            }
            defer gpa.free(temp);
            params2[1] = temp;
            folder_paths.root_src_backend_messenger = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        // /src/frontend/ path.
        params2[1] = frontend.folder_name_frontend;
        folder_paths.root_src_frontend = try fspath.join(gpa, params2);
        errdefer {
            folder_paths.deinit();
        }

        {
            // /src/frontend/screen/ path.
            temp = try frontend.pathScreenFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_frontend_screen = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        {
            // /src/frontend/screen/panel/ path.
            temp = try frontend.pathScreenPanelFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_frontend_screen_panel = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        {
            // /src/frontend/screen/tab/ path.
            temp = try frontend.pathScreenTabFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_frontend_screen_tab = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        {
            // /src/frontend/screen/book/ path.
            temp = try frontend.pathScreenBookFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_frontend_screen_book = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        {
            // /src/frontend/screen/modal/ path.
            temp = try frontend.pathScreenModalFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_frontend_screen_modal = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        {
            // /src/frontend/screen/modal/OK/ path.
            temp = try frontend.pathScreenModalOKFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_frontend_screen_modal_ok = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        // /src/deps/ path.
        params2[1] = deps.folder_name_deps;
        folder_paths.root_src_deps = try fspath.join(gpa, params2);
        errdefer {
            folder_paths.deinit();
        }

        { // /src/deps/channel/ path.
            temp = try deps.pathChannelFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_deps_channel = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        {
            // /src/deps/channel/fronttoback/ path.
            temp = try deps.pathChannelFrontToBackFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_deps_channel_fronttoback = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        { // /src/deps/channel/backtofront/ path.
            temp = try deps.pathChannelBackToFrontFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_deps_channel_backtofront = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        {

            // /src/deps/channel/trigger/ path.
            temp = try deps.pathChannelTriggerFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_deps_channel_trigger = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        {
            // /src/deps/closer/ path.
            temp = try deps.pathCloserFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_deps_closer = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        {
            // /src/deps/counter/ path.
            temp = try deps.pathCounterFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_deps_counter = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        {
            // /src/deps/closedownjobs/ path.
            temp = try deps.pathCloseDownJobsFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_deps_closedownjobs = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        { // /src/deps/framers/ path.
            temp = try deps.pathFramersFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_deps_framers = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        {
            // /src/deps/lock/ path.
            temp = try deps.pathLockFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_deps_lock = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        {
            // /src/deps/message/ path.
            temp = try deps.pathMessageFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_deps_message = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        {
            // /src/deps/modal_params/ path.
            temp = try deps.pathModalParamsFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_deps_modal_params = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        {
            // /src/deps/startup/ path.
            temp = try deps.pathStartupFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_deps_startup = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        { // /src/deps/widget/ path.
            temp = try deps.pathWidgetFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_deps_widget = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        {
            // /src/deps/widget/tabbar/ path.
            temp = try deps.pathWidgetTabbarFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_deps_widget_tabbar = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        {
            // /src/deps/various/ path.
            temp = try deps.pathVariousFolder(gpa);
            defer gpa.free(temp);
            errdefer {
                folder_paths.deinit();
            }
            params2[1] = temp;
            folder_paths.root_src_deps_various = try fspath.join(gpa, params2);
            errdefer {
                folder_paths.deinit();
            }
        }

        return folder_paths;
    } else {
        return error.NullRootPath;
    }
}
