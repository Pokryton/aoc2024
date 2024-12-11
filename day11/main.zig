const std = @import("std");

const ResultCache = std.AutoHashMap(struct { u32, u64 }, u64);

fn countStone(num: u64, blinks: u32, cache: *ResultCache) u64 {
    if (blinks == 0) return 1;
    if (num == 0) return countStone(1, blinks - 1, cache);

    const digits = std.math.log10_int(num) + 1;
    if (digits % 2 == 1)
        return countStone(2024 * num, blinks - 1, cache);

    if (cache.get(.{ blinks, num })) |v|
        return v;

    const pow = std.math.powi(u64, 10, digits / 2) catch unreachable;
    const count = countStone(num / pow, blinks - 1, cache) + countStone(num % pow, blinks - 1, cache);

    cache.put(.{ blinks, num }, count) catch {};
    return count;
}

fn solve(allocator: std.mem.Allocator, input: []const u8, blinks: u32) !u64 {
    var cache = ResultCache.init(allocator);
    defer cache.deinit();

    var it = std.mem.tokenizeScalar(u8, input, ' ');

    var sum: u64 = 0;
    while (it.next()) |num| {
        const n = try std.fmt.parseInt(u64, num, 10);
        sum += countStone(n, blinks, &cache);
    }

    return sum;
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    return solve(allocator, input, 25);
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !u64 {
    return solve(allocator, input, 75);
}

test part1 {
    const input = "125 17";
    try std.testing.expectEqual(part1(std.testing.allocator, input), 55312);
}

pub fn main() !void {
    const input = comptime std.mem.trimRight(u8, @embedFile("input"), "\n");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    std.debug.print("{}\n", .{try part1(allocator, input)});
    std.debug.print("{}\n", .{try part2(allocator, input)});
}
