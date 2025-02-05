const std = @import("std");
const fs = std.fs;
const builtin = @import("builtin");
const print = std.debug.print;
pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const args = try std.process.argsAlloc(alloc);
    defer std.heap.page_allocator.free(args);
    const args_len = args.len;

    if (args.len >= 2 and (args_len - 1) % 2 == 0) {
        for (0..((args_len - 1) / 2)) |i| {
            const path_from = args[i + 1];
            const path_to = args[i + 2];

            try copyFileOrDirLeaky(alloc, path_from, path_to);

            // catch {
            //     std.debug.print("\ncould not copy the executable, make sure this is run with admin privileges", .{});
            // };
        }
    } else {
        print("\nNothing to copy on / Build Script Error", .{});
        return;
    }
    std.debug.print("\nSuccessfull!", .{});
}

fn copyFileOrDir2(alc: std.mem.Allocator, from: []const u8, to: []const u8) !void {
    const file = fs.openFileAbsolute(from, .{}) catch {
        var dir_from = try fs.openDirAbsolute(from, .{});
        var from_it = dir_from.iterate();
        var dir_to = try fs.openDirAbsolute(to, .{});

        while (from_it.next() catch {
            return;
        }) |e| {
            const npath = try dir_from.realpathAlloc(alc, e.name);
            const ntopath = try dir_to.realpathAlloc(alc, e.name);
            try copyFileOrDir2(
                alc,
                npath,
                ntopath,
            );
        }
        dir_from.close();
        dir_to.close();
        return;
    };
    file.close();
    try fs.copyFileAbsolute(from, to, .{});
}

fn copyFileOrDirLeaky(alc: std.mem.Allocator, from: []const u8, to: []const u8) !void {
    std.debug.print("\ncopy {s} to {s}", .{ from, to });
    const file = fs.openFileAbsolute(from, .{}) catch {
        // path not a file assumed it is dir
        var dir_from = try fs.openDirAbsolute(from, .{});
        var dir_to = fs.openDirAbsolute(to, .{}) catch blkd: {
            try fs.makeDirAbsolute(to);
            break :blkd try fs.openDirAbsolute(to, .{});
        };
        std.debug.print("\nhello\n", .{});
        var walker = try dir_from.walk(alc);
        while (try walker.next()) |e| {
            // const npath = try dir_from.realpathAlloc(alc, e.name);
            // const ntopath = try dir_to.realpathAlloc(alc, e.name);
            std.debug.print("\npath {s} to {s}", .{ e.path, e.basename });
            // try copyFileOrDirLeaky(
            //     alc,
            //     npath,
            //     ntopath,
            // );
        }
        dir_from.close();
        dir_to.close();
        return;
    };
    file.close();
    // try fs.copyFileAbsolute(from, to, .{});
}
