const std = @import("std");

fn next(n: u64) u64 {
    var x = n;

    x = ((x * 64) ^ x) % 16777216;
    x = ((x / 32) ^ x) % 16777216;
    x = ((x * 2048) ^ x) % 16777216;

    return x;
}

fn part1(input: []const u8) !u64 {
    var sum: u64 = 0;

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        var n = try std.fmt.parseInt(u64, line, 10);

        for (0..2000) |_| n = next(n);

        sum += n;
    }
    return sum;
}

test part1 {
    const input =
        \\1
        \\10
        \\100
        \\2024
    ;
    try std.testing.expectEqual(part1(input), 37327623);
}

fn countBananas(prices: [][2000]i8, changes: [][2000]i8, seq: []i8) u32 {
    var count: u32 = 0;

    for (prices, changes) |price, change| {
        if (std.mem.indexOf(i8, &change, seq)) |i| {
            count += @intCast(price[i + 3]);
        }
    }

    return count;
}

fn findSeq(prices: [][2000]i8, changes: [][2000]i8, seq: *[4]i8, comptime seq_len: u8, ans: *u32) void {
    if (seq_len == 4) {
        ans.* = @max(ans.*, countBananas(prices, changes, seq));
        return;
    }

    var min: i8 = 0;
    var max: i8 = 9;

    for (seq[0..seq_len]) |change| {
        min = @max(0, min + change);
        max = @min(9, max + change);
    }

    var i = 0 - max;
    while (i <= 9 - min) : (i += 1) {
        seq[seq_len] = i;
        findSeq(prices, changes, seq, seq_len + 1, ans);
    }
}

fn part2(input: []const u8) !u32 {
    var prices: [2000][2000]i8 = undefined;
    var changes: [2000][2000]i8 = undefined;
    var len: usize = 0;

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| : (len += 1) {
        var n = try std.fmt.parseInt(u64, line, 10);

        const origin: i8 = @intCast(n % 10);

        n = next(n);
        prices[len][0] = @intCast(n % 10);
        changes[len][0] = prices[len][0] - origin;

        for (1..2000) |i| {
            n = next(n);
            prices[len][i] = @intCast(n % 10);
            changes[len][i] = prices[len][i] - prices[len][i - 1];
        }
    }

    var count: u32 = 0;
    var buf: [4]i8 = undefined;
    findSeq(prices[0..len], changes[0..len], &buf, 0, &count);
    return count;
}

test part2 {
    try std.testing.expectEqual(part2("2024"), 9);

    const input =
        \\1
        \\2
        \\3
        \\2024
    ;

    try std.testing.expectEqual(part2(input), 23);
}

pub fn main() !void {
    const input = @embedFile("input");

    std.debug.print("{}\n", .{try part1(input)});
    std.debug.print("{}\n", .{try part2(input)});
}
