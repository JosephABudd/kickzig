const std = @import("std");
const backend = @import("backend.zig");
const frontend = @import("frontend.zig");
const shared = @import("shared.zig");
const fspath = std.fs.path;
const folder_name_src: []const u8 = "src";

/// FolderPaths is each of the application's folder paths.
pub const FolderPaths = struct {
    built: bool,
    allocator: std.mem.Allocator,
    app: ?[]const u8,
    app_src: ?[]const u8,
    app_src_backend: ?[]const u8,
    app_src_backend_messenger: ?[]const u8,
    app_src_backend_store: ?[]const u8,
    app_src_frontend: ?[]const u8,
    app_src_frontend_screen: ?[]const u8,
    app_src_frontend_screen_panel: ?[]const u8,
    app_src_frontend_screen_tab: ?[]const u8,
    app_src_frontend_lib: ?[]const u8,
    app_src_frontend_framers: ?[]const u8,
    app_src_shared: ?[]const u8,
    app_src_shared_channel: ?[]const u8,
    app_src_shared_channel_src: ?[]const u8,
    app_src_shared_message: ?[]const u8,
    app_src_shared_message_src: ?[]const u8,
    app_src_shared_record: ?[]const u8,

    pub fn isBuilt(self: *FolderPaths) bool {
        return self.built;
    }

    // unBuild removes the source folder.
    pub fn unBuild(self: *FolderPaths) !void {
        if (!self.isBuilt()) {
            return;
        }
        var dir: std.fs.Dir = undefined;
        dir = try std.fs.openDirAbsolute(self.app, .{});
        try dir.deleteTree(folder_name_src);
    }

    // reBuild builds the paths is they are not already built.
    pub fn reBuild(self: *FolderPaths) !void {
        if (self.isBuilt()) {
            return;
        }
        try self.build();
    }

    /// build creates the src folder and it's sub folders.
    pub fn build(self: *FolderPaths) !void {
        var dir: std.fs.Dir = undefined;
        dir = try std.fs.openDirAbsolute(self.app, .{});
        var srcdir: std.fs.Dir = try dir.makeOpenPath(self.folder_name_src);
        errdefer dir.Close();
        defer srcdir.Close();

        var temp: []const u8 = undefined;

        // Backend folder paths.
        try srcdir.makePath(backend.folder_name_backend);
        temp = try backend.pathMessengerFolder(self.allocator);
        try srcdir.makePath(temp);
        self.allocator.free(temp);
        temp = try backend.pathStoreFolder(self.allocator);
        try srcdir.makePath(temp);
        self.allocator.free(temp);

        // Frontend folder paths.
        try srcdir.makePath(frontend.folder_name_frontend);
        temp = try backend.pathScreenFolder(self.allocator);
        try srcdir.makePath(temp);
        self.allocator.free(temp);
        temp = try backend.pathScreenPanelFolder(self.allocator);
        try srcdir.makePath(temp);
        self.allocator.free(temp);
        temp = try backend.pathScreenTabFolder(self.allocator);
        try srcdir.makePath(temp);
        self.allocator.free(temp);
        temp = try backend.pathLibFolder(self.allocator);
        try srcdir.makePath(temp);
        self.allocator.free(temp);
        temp = try backend.pathLibFramersFolder(self.allocator);
        try srcdir.makePath(temp);
        self.allocator.free(temp);

        // Shared folder paths.
        try srcdir.makePath(shared.folder_name_shared);
        temp = try shared.pathChannelFolder(self.allocator);
        try srcdir.makePath(temp);
        self.allocator.free(temp);
        temp = try shared.pathChannelSrcFolder(self.allocator);
        try srcdir.makePath(temp);
        self.allocator.free(temp);
        temp = try shared.pathMessageFolder(self.allocator);
        try srcdir.makePath(temp);
        self.allocator.free(temp);
        temp = try shared.pathMessageSrcFolder(self.allocator);
        try srcdir.makePath(temp);
        self.allocator.free(temp);
        temp = try shared.pathRecordFolder(self.allocator);
        try srcdir.makePath(temp);
        self.allocator.free(temp);
    }
};

var folder_paths: ?*FolderPaths = null;

/// folders returns the folder paths or an error.
/// The caller does not own the returned value.
pub fn folders() !FolderPaths {
    if (folder_paths) |paths| {
        return paths;
    } else {
        return error.NoFolderPaths;
    }
}

/// init creates the FolderPaths
/// whoever calls init must eventually call deinit();
pub fn init(allocator: std.mem.Allocator, app_path: []const u8) !void {
    folder_paths = try allocator.create(FolderPaths);
    folder_paths.built = false;
    folder_paths.allocator = allocator;

    // App folder paths.
    folder_paths.app = try allocator.alloc(app_path.len);
    @memcpy(folder_paths.app_src, app_path);
    folder_paths.app_src = try fspath.join(allocator, folder_paths.app, folder_name_src);

    // Backend folder paths.
    folder_paths.app_src_backend = try fspath.join(allocator, folder_paths.app_src, backend.folder_name_backend);
    var temp: []const u8 = undefined;
    temp = try backend.pathMessengerFolder(folder_paths.allocator);
    errdefer allocator.free(temp);
    folder_paths.app_src_backend_messenger = try fspath.join(allocator, folder_paths.app_src, temp);
    allocator.free(temp);
    temp = try backend.pathStoreFolder(folder_paths.allocator);
    errdefer allocator.free(temp);
    folder_paths.app_src_backend_store = try fspath.join(allocator, folder_paths.app_src, temp);
    allocator.free(temp);

    // Frontend folder paths.
    folder_paths.app_src_frontend = try fspath.join(allocator, folder_paths.app_src, frontend.folder_name_frontend);
    temp = try frontend.pathScreenFolder(folder_paths.allocator);
    errdefer allocator.free(temp);
    folder_paths.app_src_frontend_screen = try fspath.join(allocator, folder_paths.app_src, temp);
    allocator.free(temp);
    temp = try frontend.pathScreenPanelFolder(folder_paths.allocator);
    errdefer allocator.free(temp);
    folder_paths.app_src_frontend_screen_panel = try fspath.join(allocator, folder_paths.app_src, temp);
    allocator.free(temp);
    temp = try frontend.pathScreenTabFolder(folder_paths.allocator);
    errdefer allocator.free(temp);
    folder_paths.app_src_frontend_screen_tab = try fspath.join(allocator, folder_paths.app_src, temp);
    allocator.free(temp);
    temp = try frontend.pathLibFolder(folder_paths.allocator);
    errdefer allocator.free(temp);
    folder_paths.app_src_frontend_lib = try fspath.join(allocator, folder_paths.app_src, temp);
    allocator.free(temp);
    temp = try frontend.pathLibFramersFolder(folder_paths.allocator);
    errdefer allocator.free(temp);
    folder_paths.app_src_frontend_framers = try fspath.join(allocator, folder_paths.app_src, temp);
    allocator.free(temp);

    // Shared folder paths.
    folder_paths.app_src_shared = try fspath.join(allocator, folder_paths.app_src, shared.folder_name_shared);
    temp = try shared.pathChannelFolder(folder_paths.allocator);
    errdefer allocator.free(temp);
    folder_paths.app_src_shared_channel = try fspath.join(allocator, folder_paths.app_src, temp);
    allocator.free(temp);
    temp = try shared.pathChannelSrcFolder(folder_paths.allocator);
    errdefer allocator.free(temp);
    folder_paths.app_src_shared_channel_src = try fspath.join(allocator, folder_paths.app_src, temp);
    allocator.free(temp);
    temp = try shared.pathMessageFolder(folder_paths.allocator);
    errdefer allocator.free(temp);
    folder_paths.app_src_shared_message = try fspath.join(allocator, folder_paths.app_src, temp);
    allocator.free(temp);
    temp = try shared.pathMessageSrcFolder(folder_paths.allocator);
    errdefer allocator.free(temp);
    folder_paths.app_src_shared_message_src = try fspath.join(allocator, folder_paths.app_src, temp);
    allocator.free(temp);
    temp = try shared.pathRecordFolder(folder_paths.allocator);
    errdefer allocator.free(temp);
    folder_paths.app_src_shared_record = try fspath.join(allocator, folder_paths.app_src, temp);
    allocator.free(temp);
}

pub fn deinit(self: *FolderPaths) void {
    if (self.app) |member| {
        self.allocator.free(member);
    }
    if (self.app_src) |member| {
        self.allocator.free(member);
    }
    if (self.app_src_backend) |member| {
        self.allocator.free(member);
    }
    if (self.app_src_backend_messenger) |member| {
        self.allocator.free(member);
    }
    if (self.app_src_backend_store) |member| {
        self.allocator.free(member);
    }
    if (self.app_src_frontend) |member| {
        self.allocator.free(member);
    }
    if (self.app_src_frontend_screen) |member| {
        self.allocator.free(member);
    }
    if (self.app_src_frontend_screen_panel) |member| {
        self.allocator.free(member);
    }
    if (self.app_src_frontend_screen_tab) |member| {
        self.allocator.free(member);
    }
    if (self.app_src_frontend_lib) |member| {
        self.allocator.free(member);
    }
    if (self.app_src_frontend_framers) |member| {
        self.allocator.free(member);
    }
    if (self.app_src_shared) |member| {
        self.allocator.free(member);
    }
    if (self.app_src_shared_channel) |member| {
        self.allocator.free(member);
    }
    if (self.app_src_shared_channel_src) |member| {
        self.allocator.free(member);
    }
    if (self.app_src_shared_message) |member| {
        self.allocator.free(member);
    }
    if (self.app_src_shared_record) |member| {
        self.allocator.free(member);
    }
    self.allocator.destroy(self);
}
