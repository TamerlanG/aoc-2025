const std = @import("std");

pub fn main() !void {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile("input.txt", .{ .mode = .read_only });
    defer file.close();

    // var read_buffer: []
}
