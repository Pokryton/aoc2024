const std = @import("std");
const parseInt = std.fmt.parseInt;
const sort = std.mem.sort;

fn part1(allocator: std.mem.Allocator, input: []const u8) !u32 {
    var arr = std.MultiArrayList(struct { left: u32, right: u32 }){};
    defer arr.deinit(allocator);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var nums = std.mem.tokenizeScalar(u8, line, ' ');

        try arr.append(allocator, .{
            .left = try parseInt(u32, nums.next().?, 10),
            .right = try parseInt(u32, nums.next().?, 10),
        });
    }

    sort(u32, arr.items(.left), {}, std.sort.asc(u32));
    sort(u32, arr.items(.right), {}, std.sort.asc(u32));

    var sum: u32 = 0;
    for (arr.items(.left), arr.items(.right)) |l, r| {
        sum += @max(l, r) - @min(l, r);
    }

    return sum;
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !u32 {
    // val -> (left_count, right_count)
    var map = std.AutoArrayHashMap(u32, [2]u32).init(allocator);
    defer map.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var nums = std.mem.tokenizeScalar(u8, line, ' ');

        for (0..2) |i| {
            const k = try parseInt(u32, nums.next().?, 10);

            var v = try map.getOrPut(k);
            if (!v.found_existing)
                @memset(v.value_ptr, 0);

            v.value_ptr[i] += 1;
        }
    }

    var sum: u32 = 0;

    var it = map.iterator();
    while (it.next()) |entry| {
        sum += entry.key_ptr.* * entry.value_ptr[0] * entry.value_ptr[1];
    }

    return sum;
}

test {
    const input =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;

    const ally = std.testing.allocator;
    try std.testing.expectEqual(part1(ally, input), 11);
    try std.testing.expectEqual(part2(ally, input), 31);
}

pub fn main() !void {
    const input = @embedFile("input");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    std.debug.print("{}\n", .{try part1(allocator, input)});
    std.debug.print("{}\n", .{try part2(allocator, input)});
}
