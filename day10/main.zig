const std = @import("std");

fn getScore1(height: u8, pos: usize, input: []const u8, l: usize, visited: *std.DynamicBitSetUnmanaged) u32 {
    if (input[pos] != height) return 0;

    if (visited.isSet(pos)) return 0;
    visited.set(pos);

    if (height == '9') return 1;

    var score: u32 = 0;
    inline for (.{ 1, l }) |step| {
        if (step <= pos) score += getScore1(height + 1, pos - step, input, l, visited);
        if (pos + step < input.len) score += getScore1(height + 1, pos + step, input, l, visited);
    }

    return score;
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !u32 {
    const l = std.mem.indexOfScalar(u8, input, '\n').? + 1;

    var visited = try std.DynamicBitSetUnmanaged.initEmpty(allocator, input.len);
    defer visited.deinit(allocator);

    var sum: u32 = 0;

    for (input, 0..) |c, i| {
        if (c == '0') {
            visited.unsetAll();
            sum += getScore1('0', i, input, l, &visited);
        }
    }

    return sum;
}

fn getScore2(height: u8, pos: usize, input: []const u8, l: usize, cached: []?u32) u32 {
    if (input[pos] != height) return 0;
    if (height == '9') return 1;

    if (cached[pos]) |score|
        return score;

    var score: u32 = 0;
    inline for (.{ 1, l }) |step| {
        if (step <= pos) score += getScore2(height + 1, pos - step, input, l, cached);
        if (pos + step < input.len) score += getScore2(height + 1, pos + step, input, l, cached);
    }

    cached[pos] = score;
    return score;
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !u32 {
    const l = std.mem.indexOfScalar(u8, input, '\n').? + 1;

    const cached = try allocator.alloc(?u32, input.len);
    @memset(cached, null);
    defer allocator.free(cached);

    var sum: u32 = 0;

    for (input, 0..) |c, i| {
        if (c == '0') sum += getScore2('0', i, input, l, cached);
    }

    return sum;
}

test {
    const input =
        \\89010123
        \\78121874
        \\87430965
        \\96549874
        \\45678903
        \\32019012
        \\01329801
        \\10456732
        \\
    ;

    const ally = std.testing.allocator;
    try std.testing.expectEqual(part1(ally, input), 36);
    try std.testing.expectEqual(part2(ally, input), 81);
}

pub fn main() !void {
    const input = @embedFile("input");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    std.debug.print("{}\n", .{try part1(allocator, input)});
    std.debug.print("{}\n", .{try part2(allocator, input)});
}
