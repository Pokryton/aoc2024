const std = @import("std");

fn part1(input: []const u8) !u32 {
    var count: u32 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    outer: while (lines.next()) |line| {
        var words = std.mem.tokenizeScalar(u8, line, ' ');

        const first = words.next() orelse continue;
        const second = words.next() orelse {
            count += 1;
            continue;
        };

        const a0 = try std.fmt.parseInt(i32, first, 10);
        const a1 = try std.fmt.parseInt(i32, second, 10);
        const d0 = a1 - a0;

        if (d0 == 0 or @abs(d0) > 3) continue;

        var prev = a1;
        while (words.next()) |word| {
            const n = try std.fmt.parseInt(i32, word, 10);
            defer prev = n;
            const d = n - prev;

            if (d * d0 <= 0 or @abs(d) > 3) continue :outer;
        }

        count += 1;
    }

    return count;
}

fn part2(input: []const u8) !u32 {
    var count: u32 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    outer: while (lines.next()) |line| {
        var words = std.mem.tokenizeScalar(u8, line, ' ');

        const first = words.next() orelse continue;
        const second = words.next() orelse {
            count += 1;
            continue;
        };

        const a0 = try std.fmt.parseInt(i32, first, 10);
        const a1 = try std.fmt.parseInt(i32, second, 10);

        var r0: ??bool = @as(?bool, null);
        var r1: ??bool = if (a1 != a0 and @abs(a1 - a0) <= 3) a1 > a0 else null;
        var r2: ??bool = @as(?bool, null);

        var pp = a0;
        var p = a1;

        while (words.next()) |word| {
            const a = try std.fmt.parseInt(i32, word, 10);
            defer {
                pp = p;
                p = a;
            }

            var nr1: ??bool = null;
            var nr2: ??bool = null;

            // eww
            if (a != p and @abs(a - p) <= 3) {
                const asc = a > p;
                if (r1) |r| {
                    if (r == null or r == asc)
                        nr1 = asc;
                }

                if (r2) |r| {
                    if (r == null or r == asc)
                        nr2 = asc;
                }
            }

            if (a != pp and @abs(a - pp) <= 3) {
                const asc = a > pp;
                if (r0) |r| {
                    if (r == null or r == asc) {
                        if (nr2 == null) {
                            nr2 = asc;
                        } else if (nr2 != asc) {
                            nr2 = @as(?bool, null);
                        }
                    }
                }
            }

            r0 = r1;
            r1 = nr1;
            r2 = nr2;

            if (r0 == null and r1 == null and r2 == null) continue :outer;
        }

        count += 1;
    }

    return count;
}

test {
    const input =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;

    try std.testing.expectEqual(part1(input), 2);
    try std.testing.expectEqual(part2(input), 4);
}

pub fn main() !void {
    const input = @embedFile("input");

    std.debug.print("{}\n", .{try part1(input)});
    std.debug.print("{}\n", .{try part2(input)});
}
