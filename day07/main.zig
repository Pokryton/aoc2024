const std = @import("std");

const AocPart = enum { part1, part2 };

fn checkEq(target: u64, nums: []const u64, comptime part: AocPart) bool {
    if (nums.len == 0)
        return target == 0;

    const init = nums[0 .. nums.len - 1];
    const last = nums[nums.len - 1];

    if (last > target) return false;

    if (target % last == 0 and checkEq(target / last, init, part)) return true;
    if (checkEq(target - last, init, part)) return true;

    if (comptime part == .part2) {
        var pow: u64 = 10;
        while (pow <= last) pow *= 10; // log10_int + powi
        if (target % pow == last)
            return checkEq(target / pow, init, part);
    }

    return false;
}

test checkEq {
    try std.testing.expect(checkEq(190, &[_]u64{ 10, 19 }, .part1));
    try std.testing.expect(checkEq(3267, &[_]u64{ 81, 40, 27 }, .part1));
    try std.testing.expect(!checkEq(83, &[_]u64{ 17, 5 }, .part1));

    try std.testing.expect(checkEq(156, &[_]u64{ 15, 6 }, .part2));
    try std.testing.expect(checkEq(7290, &[_]u64{ 6, 8, 6, 15 }, .part2));
    try std.testing.expect(checkEq(192, &[_]u64{ 17, 8, 14 }, .part2));
    try std.testing.expect(checkEq(710, &[_]u64{ 7, 10 }, .part2));
}

fn solve(input: []const u8, comptime part: AocPart) !u64 {
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    var nums = try std.BoundedArray(u64, 20).init(0);

    var sum: u64 = 0;

    while (line_it.next()) |line| {
        const d = std.mem.indexOfScalar(u8, line, ':').?;
        const target = try std.fmt.parseInt(u64, line[0..d], 10);

        try nums.resize(0);

        var word_it = std.mem.tokenizeScalar(u8, line[d + 1 ..], ' ');
        while (word_it.next()) |word| {
            const n = try std.fmt.parseInt(u64, word, 10);
            try nums.append(n);
        }

        if (checkEq(target, nums.slice(), part)) sum += target;
    }

    return sum;
}

fn part1(input: []const u8) !u64 {
    return solve(input, .part1);
}

fn part2(input: []const u8) !u64 {
    return solve(input, .part2);
}

test {
    const input =
        \\190: 10 19
        \\3267: 81 40 27
        \\83: 17 5
        \\156: 15 6
        \\7290: 6 8 6 15
        \\161011: 16 10 13
        \\192: 17 8 14
        \\21037: 9 7 18 13
        \\292: 11 6 16 20
    ;

    try std.testing.expectEqual(part1(input), 3749);
    try std.testing.expectEqual(part2(input), 11387);
}

pub fn main() !void {
    const input = @embedFile("input");

    std.debug.print("{}\n", .{try part1(input)});
    std.debug.print("{}\n", .{try part2(input)});
}
