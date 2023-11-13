/// This file builds the deps/modal_params/ part of the framework.
/// fn create adds:
/// - deps/modal_params/api.zig
/// - deps/modal_params/OK.zig
/// - deps/modal_params/<<any-modal>>.zig
const std = @import("std");
const fspath = std.fs.path;
const paths = @import("paths");
const filenames = @import("filenames");
const api_template = @import("api_template.zig");
const any_template = @import("any_template.zig");
const ok_template = @import("ok_template.zig");

/// fn create adds:
/// - deps/modal_params/api.zig
/// - deps/modal_params/OK.zig
pub fn create(allocator: std.mem.Allocator) !void {
    try addOK();
    // Build api.zig with all of the channels.
    try buildApiZig(allocator);
}

fn addOK() !void {
    // Open the folder.
    var folders = try paths.folders();
    defer folders.deinit();
    var modal_params_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_modal_params.?, .{});
    defer modal_params_dir.close();

    // Open, write and close the file.
    var ofile = try modal_params_dir.createFile(filenames.ok_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(ok_template.content);
}

fn buildApiZig(allocator: std.mem.Allocator) !void {
    // Build the template and the content.
    const template: *api_template.Template = try api_template.Template.init(allocator);
    defer template.deinit();
    // Get the names of each channel and use them in the template.
    var custom_modal_param_names: [][]const u8 = try filenames.allCustomDepsModalParamsNames(allocator);
    defer {
        for (custom_modal_param_names) |name| {
            allocator.free(name);
        }
        allocator.free(custom_modal_param_names);
    }
    for (custom_modal_param_names) |name| {
        try template.addName(name);
    }
    var content: []const u8 = try template.content();
    defer allocator.free(content);

    // Open the folder.
    var folders = try paths.folders();
    defer folders.deinit();
    var modal_params_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_modal_params.?, .{});
    defer modal_params_dir.close();

    // Open, write and close the file.
    var ofile = try modal_params_dir.createFile(filenames.api_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}

fn add(allocator: std.mem.Allocator, modal_params_name: []const u8) !void {
    const template = try ok_template.init(allocator);
    defer template.deinit();
    const content: []const u8 = try template.content(modal_params_name);
    defer allocator.free(content);

    // Open the folder.
    var folders = try paths.folders();
    defer folders.deinit();
    var modal_params_dir: std.fs.Dir = try std.fs.openDirAbsolute(folders.root_src_this_deps_modal_params.?, .{});
    defer modal_params_dir.close();

    // Open, write and close the file.
    var modal_file_name: []const u8 = filenames.depsModalParamsFileName(modal_params_name);
    defer allocator.free(modal_file_name);
    var ofile = try modal_params_dir.createFile(modal_file_name, .{});
    defer ofile.close();
    try ofile.writeAll(content);
}
