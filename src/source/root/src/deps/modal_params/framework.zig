/// This file builds the deps/modal_params/ part of the framework.
/// fn create adds:
/// - deps/modal_params/api.zig
/// - deps/modal_params/OK.zig
/// - deps/modal_params/EOJ.zig
/// - deps/modal_params/<<any-modal>>.zig
const std = @import("std");
const fspath = std.fs.path;
const _paths_ = @import("paths");
const _filenames_ = @import("filenames");
const _api_template_ = @import("api_template.zig");
const _any_template_ = @import("any_template.zig");
const _ok_template_ = @import("ok_template.zig");
const _yesno_template_ = @import("yesno_template.zig");
const _eoj_template_ = @import("eoj_template.zig");

/// fn create adds:
/// - deps/modal_params/api.zig
/// - deps/modal_params/OK.zig
pub fn create(allocator: std.mem.Allocator) !void {
    try addOK();
    try addYesNo();
    try addEOJ();
    // Build api.zig with all of the params.
    try buildApiZig(allocator);
}

fn addOK() !void {
    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var modal_params_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_modal_params.?, .{});
    defer modal_params_dir.close();

    // Open, write and close the file.
    var ofile = try modal_params_dir.createFile(_filenames_.ok_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(_ok_template_.content);
}

fn addYesNo() !void {
    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var modal_params_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_modal_params.?, .{});
    defer modal_params_dir.close();

    // Open, write and close the file.
    var ofile = try modal_params_dir.createFile(_filenames_.yesno_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(_yesno_template_.content);
}

fn addEOJ() !void {
    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var modal_params_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_modal_params.?, .{});
    defer modal_params_dir.close();

    // Open, write and close the file.
    var ofile = try modal_params_dir.createFile(_filenames_.deps.eoj_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(_eoj_template_.content);
}

fn buildApiZig(allocator: std.mem.Allocator) !void {
    // Build the template and the content.
    const template: *_api_template_.Template = try _api_template_.Template.init(allocator);
    defer template.deinit();
    // Get the names of each modal params and use them in the template.
    const custom_modal_param_names: [][]const u8 = try _filenames_.allCustomDepsModalParamsNames(allocator);
    if (custom_modal_param_names.len > 0) {
        defer {
            for (custom_modal_param_names) |name| {
                allocator.free(name);
            }
            allocator.free(custom_modal_param_names);
        }
        for (custom_modal_param_names) |name| {
            try template.addName(name);
        }
    }
    const content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var modal_params_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_modal_params.?, .{});
    defer modal_params_dir.close();

    // Open, write and close the file.
    var ofile = try modal_params_dir.createFile(_filenames_.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

pub fn add(allocator: std.mem.Allocator, modal_params_name: []const u8) !void {
    const template = try _any_template_.init(allocator);
    defer template.deinit();
    const content: []const u8 = try template.content(modal_params_name);
    defer allocator.free(content);

    // Open the folder.
    var folders = try _paths_.folders();
    defer folders.deinit();
    var modal_params_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_deps_modal_params.?, .{});
    defer modal_params_dir.close();

    // Open, write and close the file.
    const modal_file_name: []const u8 = try _filenames_.depsModalParamsFileName(allocator, modal_params_name);
    defer allocator.free(modal_file_name);
    var ofile = try modal_params_dir.createFile(modal_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);

    // Build api.zig with all of the params.
    try buildApiZig(allocator);
}
