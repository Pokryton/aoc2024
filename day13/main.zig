const std = @import("std");
const parseInt = std.fmt.parseInt;

const AocPart = enum { part1, part2 };

fn solve(input: []const u8, comptime part: AocPart) !u64 {
    var sum: u64 = 0;

    var section_it = std.mem.tokenizeSequence(u8, input, "\n\n");
    while (section_it.next()) |section| {
        var line_it = std.mem.tokenizeScalar(u8, section, '\n');

        var a: [2][2]i64 = undefined;
        var b: [2]i64 = undefined;

        for (0..2) |i| {
            const line = line_it.next().?;
            const sep = std.mem.indexOfScalar(u8, line, ',').?;

            a[i][0] = try parseInt(i64, line[12..sep], 10);
            a[i][1] = try parseInt(i64, line[sep + 4 ..], 10);
        }

        const line = line_it.next().?;
        const sep = std.mem.indexOfScalar(u8, line, ',').?;
        b[0] = try parseInt(i64, line[9..sep], 10);
        b[1] = try parseInt(i64, line[sep + 4 ..], 10);

        if (comptime part == .part2) {
            b[0] += 10000000000000;
            b[1] += 10000000000000;
        }

        const det = a[0][0] * a[1][1] - a[0][1] * a[1][0];
        if (det == 0) @panic("unimplemented");

        const det0 = b[0] * a[1][1] - b[1] * a[1][0];
        const x0 = std.math.divExact(i64, det0, det) catch |err| {
            if (err == error.UnexpectedRemainder) continue;
            return err;
        };

        const det1 = a[0][0] * b[1] - a[0][1] * b[0];
        const x1 = std.math.divExact(i64, det1, det) catch |err| {
            if (err == error.UnexpectedRemainder) continue;
            return err;
        };

        if (x0 <= 0 or x1 <= 0) continue;
        if ((comptime part == .part1) and (x0 >= 100 or x1 >= 100)) continue;

        sum += @intCast(3 * x0 + x1);
    }

    return sum;
}

fn part1(input: []const u8) !u64 {
    return solve(input, .part1);
}

fn part2(input: []const u8) !u64 {
    return solve(input, .part2);
}

test part1 {
    const input =
        \\Button A: X+94, Y+34
        \\Button B: X+22, Y+67
        \\Prize: X=8400, Y=5400
        \\
        \\Button A: X+26, Y+66
        \\Button B: X+67, Y+21
        \\Prize: X=12748, Y=12176
        \\
        \\Button A: X+17, Y+86
        \\Button B: X+84, Y+37
        \\Prize: X=7870, Y=6450
        \\
        \\Button A: X+69, Y+23
        \\Button B: X+27, Y+71
        \\Prize: X=18641, Y=10279
    ;
    try std.testing.expectEqual(part1(input), 480);
}

pub fn main() !void {
    const input = @embedFile("input");

    std.debug.print("{}\n", .{try part1(input)});
    std.debug.print("{}\n", .{try part2(input)});
}
