const std = @import("std");
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");

// create adds the .git_keep_this_folder file.
pub fn create() !void {
    // The vendor folder is part of the framework.
    // So it needs a git keep file.
    var package_dir: std.fs.Dir = try vendorDirectory();
    defer package_dir.close();
    try _filenames_.addGitKeepFile(package_dir);
}

// The caller must close the returned directory.
fn vendorDirectory() !std.fs.Dir {
    const folders: *_paths_.FolderPaths = try _paths_.folders();
    defer folders.deinit();
    return try std.fs.openDirAbsolute(folders.root_src_vendor.?, .{});
}
