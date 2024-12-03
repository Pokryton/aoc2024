const std = @import("std");

// "3,7" -> 21
fn calcMul(s: []const u8) !u32 {
    const i = std.mem.indexOfScalar(u8, s, ',') orelse return error.InvalidFormat;

    const n1 = try std.fmt.parseInt(u32, s[0..i], 10);
    const n2 = try std.fmt.parseInt(u32, s[i + 1 ..], 10);

    return n1 * n2;
}

fn part1(input: []const u8) u32 {
    var sum: u32 = 0;

    var it = std.mem.splitSequence(u8, input, "mul(");
    while (it.next()) |s| {
        const l = std.mem.indexOfScalar(u8, s[0..@min(s.len, 8)], ')') orelse continue;
        sum += calcMul(s[0..l]) catch 0;
    }

    return sum;
}

fn part2(input: []const u8) u32 {
    var sum: u32 = 0;
    var i: usize = 0;

    while (i < input.len - 8) {
        if (std.mem.eql(u8, "don't()", input[i .. i + 7])) {
            i = std.mem.indexOfPos(u8, input, i + 7, "do()") orelse break;
            i += 4;
            continue;
        }

        if (std.mem.eql(u8, "mul(", input[i .. i + 4])) {
            i += 4;
            const l = std.mem.indexOfScalar(u8, input[i..@min(input.len, i + 8)], ')') orelse continue;
            sum += calcMul(input[i .. i + l]) catch 0;
            i += l;
            continue;
        }

        i += 1;
    }

    return sum;
}

test "part1" {
    const input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
    try std.testing.expectEqual(part1(input), 161);
}

test "part2" {
    const input = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";
    try std.testing.expectEqual(part2(input), 48);
}

pub fn main() void {
    const input = @embedFile("input");

    std.debug.print("{}\n", .{part1(input)});
    std.debug.print("{}\n", .{part2(input)});
}
