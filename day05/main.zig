const std = @import("std");

inline fn parseRules(rules: []const u8) ![100][100]bool {
    var edge: [100][100]bool = [_][100]bool{.{false} ** 100} ** 100;

    var it = std.mem.tokenizeScalar(u8, rules, '\n');
    while (it.next()) |line| {
        const x = try std.fmt.parseInt(u8, line[0..2], 10);
        const y = try std.fmt.parseInt(u8, line[3..5], 10);

        edge[y][x] = true;
    }

    return edge;
}

fn part1(input: []const u8) !u32 {
    const l = std.mem.indexOf(u8, input, "\n\n").?;
    const edge = try parseRules(input[0..l]);

    var nums: [100]u8 = undefined; // page numbers of each updates
    var sum: u32 = 0; // answer

    var it = std.mem.tokenizeScalar(u8, input[l + 2 ..], '\n');
    outer: while (it.next()) |line| {
        const n = (line.len + 1) / 3;

        for (0..n) |i| {
            const x = try std.fmt.parseInt(u8, line[i * 3 .. i * 3 + 2], 10);
            nums[i] = x;
            for (nums[0..i]) |y| {
                if (edge[y][x]) continue :outer;
            }
        }

        sum += nums[n / 2];
    }

    return sum;
}

fn part2(input: []const u8) !u32 {
    const l = std.mem.indexOf(u8, input, "\n\n").?;
    const edge = try parseRules(input[0..l]);

    // use BoundedArray?
    var nums: [100]u8 = undefined;
    var sum: u32 = 0;

    var it = std.mem.tokenizeScalar(u8, input[l + 2 ..], '\n');
    while (it.next()) |line| {
        const n = (line.len + 1) / 3;
        var valid: bool = true;

        for (0..n) |i| {
            const x = try std.fmt.parseInt(u8, line[i * 3 .. i * 3 + 2], 10);
            nums[i] = x;
            for (nums[0..i], 0..) |y, j| {
                if (edge[y][x]) {
                    valid = false;
                    std.mem.rotate(u8, nums[j .. i + 1], i - j);
                    break;
                }
            }
        }

        if (!valid) sum += nums[n / 2];
    }

    return sum;
}

test {
    const input =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;

    try std.testing.expectEqual(part1(input), 143);
    try std.testing.expectEqual(part2(input), 123);
}

pub fn main() !void {
    const input = @embedFile("input");

    std.debug.print("{}\n", .{try part1(input)});
    std.debug.print("{}\n", .{try part2(input)});
}
