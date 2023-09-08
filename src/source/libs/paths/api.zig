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
    app: ?[]u8,
    app_src: ?[]u8,
    app_src_backend: ?[]u8,
    app_src_backend_messenger: ?[]u8,
    app_src_backend_store: ?[]u8,
    app_src_frontend: ?[]u8,
    app_src_frontend_screen: ?[]u8,
    app_src_frontend_screen_panel: ?[]u8,
    app_src_frontend_screen_tab: ?[]u8,
    app_src_frontend_lib: ?[]u8,
    app_src_frontend_framers: ?[]u8,
    app_src_shared: ?[]u8,
    app_src_shared_channel: ?[]u8,
    app_src_shared_channel_src: ?[]u8,
    app_src_shared_message: ?[]u8,
    app_src_shared_message_src: ?[]u8,
    app_src_shared_record: ?[]u8,

    pub fn deinit(self: *FolderPaths) void {
        const allocator: std.mem.Allocator = self.allocator;
        if (self.app_src_backend) |text| {
            allocator.free(text);
        }
        if (self.app_src_backend_messenger) |text| {
            allocator.free(text);
        }
        if (self.app_src_backend_store) |text| {
            allocator.free(text);
        }
        if (self.app_src_frontend) |text| {
            allocator.free(text);
        }
        if (self.app_src_frontend_framers) |text| {
            allocator.free(text);
        }
        if (self.app_src_frontend_lib) |text| {
            allocator.free(text);
        }
        if (self.app_src_frontend_screen_panel) |text| {
            allocator.free(text);
        }
        if (self.app_src_frontend_screen_tab) |text| {
            allocator.free(text);
        }
        if (self.app_src_frontend_screen) |text| {
            allocator.free(text);
        }
        if (self.app_src_shared) |text| {
            allocator.free(text);
        }
        if (self.app_src_shared_channel) |text| {
            allocator.free(text);
        }
        if (self.app_src_shared_channel_src) |text| {
            allocator.free(text);
        }
        if (self.app_src_shared_message) |text| {
            allocator.free(text);
        }
        if (self.app_src_shared_message_src) |text| {
            allocator.free(text);
        }
        if (self.app_src_shared_record) |text| {
            allocator.free(text);
        }
        if (self.app_src) |text| {
            allocator.free(text);
        }
        if (self.app) |text| {
            allocator.free(text);
        }
        allocator.destroy(self);
    }

    // unBuild removes the source folder.
    pub fn unBuild(self: *FolderPaths) !void {
        if (!_isBuilt()) {
            return;
        }
        var dir: std.fs.Dir = undefined;
        dir = try std.fs.openDirAbsolute(self.app.?, .{});
        try dir.deleteTree(folder_name_src);
    }

    // isBuilt returns if the frame work is already built.
    pub fn isBuilt(self: *FolderPaths) bool {
        _ = self;
        return _isBuilt();
    }

    // reBuild builds the paths is they are not already built.
    pub fn reBuild(self: *FolderPaths) !void {
        if (_isBuilt()) {
            return;
        }
        try self.unBuild();
        try self.build();
    }

    /// build creates the src folder and it's sub folders.
    pub fn build(self: *FolderPaths) !void {
        var dir: std.fs.Dir = undefined;
        dir = try std.fs.openDirAbsolute(self.app.?, .{});
        var srcdir: std.fs.Dir = try dir.makeOpenPath(folder_name_src, .{});
        errdefer dir.close();
        defer srcdir.close();

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
        temp = try frontend.pathScreenFolder(self.allocator);
        try srcdir.makePath(temp);
        self.allocator.free(temp);
        temp = try frontend.pathScreenPanelFolder(self.allocator);
        try srcdir.makePath(temp);
        self.allocator.free(temp);
        temp = try frontend.pathScreenTabFolder(self.allocator);
        try srcdir.makePath(temp);
        self.allocator.free(temp);
        temp = try frontend.pathLibFolder(self.allocator);
        try srcdir.makePath(temp);
        self.allocator.free(temp);
        temp = try frontend.pathLibFramersFolder(self.allocator);
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

var _application_path: []u8 = undefined;
var _allocator: std.mem.Allocator = undefined;

/// init stores the app path, and allocator.
/// whoever calls init must eventually call deinit();
pub fn init(allocator: std.mem.Allocator, app_path: []const u8) !void {
    _allocator = allocator;

    // App folder paths.
    _application_path = try allocator.alloc(u8, app_path.len);
    @memcpy(_application_path, app_path);
}

fn _isBuilt() bool {
    var folder_paths: *FolderPaths = folders() catch {
        return false;
    };
    var dir: std.fs.Dir = std.fs.openDirAbsolute(folder_paths.app_src.?, .{}) catch {
        return false;
    };
    dir.close();
    return true;
}

/// folders returns the folder paths or an error.
/// The caller owns the returned value.
pub fn folders() !*FolderPaths {
    var folder_paths: *FolderPaths = try _allocator.create(FolderPaths);
    folder_paths.app = try _allocator.alloc(u8, _application_path.len);
    errdefer {
        folder_paths.deinit();
    }
    folder_paths.allocator = _allocator;
    @memcpy(folder_paths.app.?, _application_path);
    var params2: [][]const u8 = try _allocator.alloc([]const u8, 2);
    defer _allocator.free(params2);
    params2[0] = folder_paths.app.?;
    params2[1] = folder_name_src;
    folder_paths.app_src = try fspath.join(_allocator, params2);
    errdefer {
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    // Backend folder paths.
    params2[0] = folder_paths.app_src.?;
    params2[1] = backend.folder_name_backend;
    folder_paths.app_src_backend = try fspath.join(_allocator, params2);
    errdefer {
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    var temp: []const u8 = undefined;
    temp = try backend.pathMessengerFolder(_allocator);
    errdefer {
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    params2[0] = folder_paths.app_src_backend.?;
    params2[1] = temp;
    folder_paths.app_src_backend_messenger = try fspath.join(_allocator, params2);
    errdefer {
        _allocator.free(temp);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    _allocator.free(temp);
    temp = try backend.pathStoreFolder(_allocator);
    errdefer {
        _allocator.free(temp);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.app_src_backend_store = try fspath.join(_allocator, params2);
    errdefer {
        _allocator.free(temp);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    _allocator.free(temp);

    // Frontend folder paths.
    params2[0] = folder_paths.app_src.?;
    params2[1] = frontend.folder_name_frontend;
    folder_paths.app_src_frontend = try fspath.join(_allocator, params2);
    errdefer {
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    temp = try frontend.pathScreenFolder(_allocator);
    errdefer {
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.app_src_frontend_screen = try fspath.join(_allocator, params2);
    errdefer {
        _allocator.free(temp);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    _allocator.free(temp);
    temp = try frontend.pathScreenPanelFolder(_allocator);
    errdefer {
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.app_src_frontend_screen_panel = try fspath.join(_allocator, params2);
    errdefer {
        _allocator.free(temp);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    _allocator.free(temp);
    temp = try frontend.pathScreenTabFolder(_allocator);
    errdefer {
        _allocator.free(folder_paths.app_src_frontend_screen_panel.?);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.app_src_frontend_screen_tab = try fspath.join(_allocator, params2);
    _allocator.free(temp);
    temp = try frontend.pathLibFolder(_allocator);
    errdefer {
        _allocator.free(folder_paths.app_src_frontend_screen_panel.?);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    params2[1] = frontend.folder_name_frontend;
    folder_paths.app_src_frontend_lib = try fspath.join(_allocator, params2);
    errdefer {
        _allocator.free(temp);
        _allocator.free(folder_paths.app_src_frontend_screen_panel.?);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    temp = try frontend.pathLibFramersFolder(_allocator);
    errdefer {
        _allocator.free(folder_paths.app_src_frontend_lib.?);
        _allocator.free(folder_paths.app_src_frontend_screen_panel.?);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.app_src_frontend_framers = try fspath.join(_allocator, params2);
    errdefer {
        _allocator.free(temp);
        _allocator.free(folder_paths.app_src_frontend_lib.?);
        _allocator.free(folder_paths.app_src_frontend_screen_panel.?);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    _allocator.free(temp);

    // Shared folder paths.
    params2[1] = shared.folder_name_shared;
    folder_paths.app_src_shared = try fspath.join(_allocator, params2);
    errdefer {
        _allocator.free(folder_paths.app_src_frontend_framers.?);
        _allocator.free(folder_paths.app_src_frontend_lib.?);
        _allocator.free(folder_paths.app_src_frontend_screen_panel.?);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    temp = try shared.pathChannelFolder(_allocator);
    errdefer {
        _allocator.free(folder_paths.app_src_shared.?);
        _allocator.free(folder_paths.app_src_frontend_framers.?);
        _allocator.free(folder_paths.app_src_frontend_lib.?);
        _allocator.free(folder_paths.app_src_frontend_screen_panel.?);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.app_src_shared_channel = try fspath.join(_allocator, params2);
    errdefer {
        _allocator.free(temp);
        _allocator.free(folder_paths.app_src_shared.?);
        _allocator.free(folder_paths.app_src_frontend_framers.?);
        _allocator.free(folder_paths.app_src_frontend_lib.?);
        _allocator.free(folder_paths.app_src_frontend_screen_panel.?);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    _allocator.free(temp);
    temp = try shared.pathChannelSrcFolder(_allocator);
    errdefer {
        _allocator.free(folder_paths.app_src_shared_channel.?);
        _allocator.free(folder_paths.app_src_shared.?);
        _allocator.free(folder_paths.app_src_frontend_framers.?);
        _allocator.free(folder_paths.app_src_frontend_lib.?);
        _allocator.free(folder_paths.app_src_frontend_screen_panel.?);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.app_src_shared_channel_src = try fspath.join(_allocator, params2);
    errdefer {
        _allocator.free(temp);
        _allocator.free(folder_paths.app_src_shared_channel.?);
        _allocator.free(folder_paths.app_src_shared.?);
        _allocator.free(folder_paths.app_src_frontend_framers.?);
        _allocator.free(folder_paths.app_src_frontend_lib.?);
        _allocator.free(folder_paths.app_src_frontend_screen_panel.?);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    _allocator.free(temp);
    temp = try shared.pathMessageFolder(_allocator);
    errdefer {
        _allocator.free(folder_paths.app_src_shared_channel_src.?);
        _allocator.free(folder_paths.app_src_shared_channel.?);
        _allocator.free(folder_paths.app_src_shared.?);
        _allocator.free(folder_paths.app_src_frontend_framers.?);
        _allocator.free(folder_paths.app_src_frontend_lib.?);
        _allocator.free(folder_paths.app_src_frontend_screen_panel.?);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.app_src_shared_message = try fspath.join(_allocator, params2);
    errdefer {
        _allocator.free(temp);
        _allocator.free(folder_paths.app_src_shared_channel_src.?);
        _allocator.free(folder_paths.app_src_shared_channel.?);
        _allocator.free(folder_paths.app_src_shared.?);
        _allocator.free(folder_paths.app_src_frontend_framers.?);
        _allocator.free(folder_paths.app_src_frontend_lib.?);
        _allocator.free(folder_paths.app_src_frontend_screen_panel.?);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    _allocator.free(temp);
    temp = try shared.pathMessageSrcFolder(_allocator);
    errdefer {
        _allocator.free(folder_paths.app_src_shared_message.?);
        _allocator.free(folder_paths.app_src_shared_channel_src.?);
        _allocator.free(folder_paths.app_src_shared_channel.?);
        _allocator.free(folder_paths.app_src_shared.?);
        _allocator.free(folder_paths.app_src_frontend_framers.?);
        _allocator.free(folder_paths.app_src_frontend_lib.?);
        _allocator.free(folder_paths.app_src_frontend_screen_panel.?);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.app_src_shared_message_src = try fspath.join(_allocator, params2);
    errdefer {
        _allocator.free(temp);
        _allocator.free(folder_paths.app_src_shared_message.?);
        _allocator.free(folder_paths.app_src_shared_channel_src.?);
        _allocator.free(folder_paths.app_src_shared_channel.?);
        _allocator.free(folder_paths.app_src_shared.?);
        _allocator.free(folder_paths.app_src_frontend_framers.?);
        _allocator.free(folder_paths.app_src_frontend_lib.?);
        _allocator.free(folder_paths.app_src_frontend_screen_panel.?);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    _allocator.free(temp);
    temp = try shared.pathRecordFolder(_allocator);
    errdefer {
        _allocator.free(folder_paths.app_src_shared_message_src.?);
        _allocator.free(folder_paths.app_src_shared_message.?);
        _allocator.free(folder_paths.app_src_shared_channel_src.?);
        _allocator.free(folder_paths.app_src_shared_channel.?);
        _allocator.free(folder_paths.app_src_shared.?);
        _allocator.free(folder_paths.app_src_frontend_framers.?);
        _allocator.free(folder_paths.app_src_frontend_lib.?);
        _allocator.free(folder_paths.app_src_frontend_screen_panel.?);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    params2[1] = temp;
    folder_paths.app_src_shared_record = try fspath.join(_allocator, params2);
    errdefer {
        _allocator.free(temp);
        _allocator.free(folder_paths.app_src_shared_message_src.?);
        _allocator.free(folder_paths.app_src_shared_message.?);
        _allocator.free(folder_paths.app_src_shared_channel_src.?);
        _allocator.free(folder_paths.app_src_shared_channel.?);
        _allocator.free(folder_paths.app_src_shared.?);
        _allocator.free(folder_paths.app_src_frontend_framers.?);
        _allocator.free(folder_paths.app_src_frontend_lib.?);
        _allocator.free(folder_paths.app_src_frontend_screen_panel.?);
        _allocator.free(folder_paths.app_src_frontend_screen.?);
        _allocator.free(folder_paths.app_src_frontend.?);
        _allocator.free(folder_paths.app_src_backend_store.?);
        _allocator.free(folder_paths.app_src_backend_messenger.?);
        _allocator.free(folder_paths.app_src_backend.?);
        _allocator.free(folder_paths.app_src.?);
        _allocator.free(folder_paths.app.?);
        folder_paths.deinit();
    }
    _allocator.free(temp);
    return folder_paths;
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
