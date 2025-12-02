const std = @import("std");

pub var alloc: std.mem.Allocator = std.heap.page_allocator;

const ProductIDRange = struct {
    start: u64,
    end: u64,
};

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

    const product_ids = try parse(buf);
    const res_problem_1 = try problemOne(product_ids);

    std.debug.print("Problem 1 solution: {} \n", .{res_problem_1});
}

pub fn parse(input: []const u8) ![]ProductIDRange {
    const trimmed_input = std.mem.trim(u8, input, " \t\n\r");
    var ranges = std.mem.splitAny(u8, trimmed_input, ",");
    var product_ranges: std.array_list.Aligned(ProductIDRange, null) = .empty;
    defer product_ranges.deinit(alloc);

    while (ranges.next()) |range| {
        if (range.len == 0) continue;

        var split = std.mem.splitAny(u8, range, "-");

        const start_str = split.next().?;
        const end_str = split.next().?;

        product_ranges.append(alloc, ProductIDRange{
            .start = try std.fmt.parseInt(u64, start_str, 10),
            .end = try std.fmt.parseInt(u64, end_str, 10),
        }) catch |err| {
            return err;
        };
    }

    return product_ranges.toOwnedSlice(alloc);
}

pub fn problemOne(ranges: []ProductIDRange) !usize {
    var total: usize = 0;
    for (ranges) |range| {
        for (range.start..range.end + 1) |id| {
            var buf: [64]u8 = undefined;
            const string = try std.fmt.bufPrint(&buf, "{}", .{id});

            if (string.len % 2 != 0) continue;

            const mid = string.len / 2;

            const left = string[0..mid];
            const right = string[mid..string.len];

            if (std.mem.eql(u8, left, right)) {
                total += id;
            }
        }
    }

    return total;
}

test "case_1" {
    {
        const input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

        const res = try parse(input);

        try std.testing.expectEqual(@as(usize, 1227775554), problemOne(res));
    }
}
