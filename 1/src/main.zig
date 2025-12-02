const std = @import("std");

pub var alloc: std.mem.Allocator = std.heap.page_allocator;

const Direction = enum { Left, Right };

const Rotation = struct {
    direction: Direction,
    distance: isize,
};

const Dial = struct {
    position: isize = 50,

    fn rotate(self: *Dial, rotation: *const Rotation) isize {
        const distance = @mod(rotation.distance, 100);
        var res = @divFloor(rotation.distance, 100);

        switch (rotation.direction) {
            .Left => {
                if (self.position != 0 and self.position < distance) res += 1;
                self.position = @mod(self.position - distance, 100);
            },
            .Right => {
                if (100 - self.position < distance) res += 1;
                self.position = @mod(self.position + distance, 100);
            },
        }

        return res;
    }
};

pub fn parse(input: []const u8) ![]Rotation {
    var lines = std.mem.splitAny(u8, input, "\n");
    var rotations: std.array_list.Aligned(Rotation, null) = .empty;
    defer rotations.deinit(alloc);

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        switch (line[0]) {
            'L' => try rotations.append(alloc, Rotation{ .direction = Direction.Left, .distance = try std.fmt.parseInt(isize, line[1..], 10) }),
            'R' => try rotations.append(alloc, Rotation{ .direction = Direction.Right, .distance = try std.fmt.parseInt(isize, line[1..], 10) }),
            else => return error.InvalidInput,
        }
    }

    return rotations.toOwnedSlice(alloc);
}

pub fn problemOne(rotations: []Rotation) isize {
    var dial = Dial{};
    var res: isize = 0;

    for (rotations) |rotation| {
        _ = dial.rotate(&rotation);
        if (dial.position == 0) {
            res += 1;
        }
    }

    return res;
}

pub fn problemTwo(rotations: []Rotation) isize {
    var dial = Dial{};
    var res: isize = 0;

    for (rotations) |rotation| {
        res += dial.rotate(&rotation);
        if (dial.position == 0) {
            res += 1;
        }
    }

    return res;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const cwd = std.fs.cwd();
    const file = try cwd.openFile("input.txt", .{ .mode = .read_only });
    defer file.close();

    // Get its size
    const stat = try file.stat();
    const size = stat.size;

    // Allocate a buffer of exactly that size
    const buf = try allocator.alloc(u8, size);
    defer allocator.free(buf);

    // Read entire file into your buffer
    const read_bytes = try file.readAll(buf);
    if (read_bytes != size) return error.UnexpectedEndOfFile;

    const rotations = try parse(buf);
    const res_problem_1 = problemOne(rotations);
    const res_problem_2 = problemTwo(rotations);

    std.debug.print("Problem 1 solution: {d} \n", .{res_problem_1});
    std.debug.print("Problem 2 solution: {d} \n", .{res_problem_2});
}

test "case_1" {
    {
        const input =
            \\L68
            \\L30
            \\R48
            \\L5
            \\R60
            \\L55
            \\L1
            \\L99
            \\R14
            \\L82
        ;
        const res = try parse(input);
        try std.testing.expectEqual(@as(isize, 3), problemOne(res));
        try std.testing.expectEqual(@as(isize, 6), problemTwo(res));
    }
}
