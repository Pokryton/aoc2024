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

        const Rec = struct { asc: ?bool };

        var r0: ?Rec = .{ .asc = null };
        var r1: ?Rec = if (a1 != a0 and @abs(a1 - a0) <= 3) .{ .asc = a1 > a0 } else null;
        var r2: ?Rec = .{ .asc = null };

        var pp = a0;
        var p = a1;

        while (words.next()) |word| {
            const a = try std.fmt.parseInt(i32, word, 10);
            defer {
                pp = p;
                p = a;
            }

            var nr1: ?Rec = null; // skipped
            var nr2: ?Rec = null; // unskipped

            // eww
            if (a != p and @abs(a - p) <= 3) {
                const asc = a > p;
                if (r1) |r| {
                    if (r.asc == null or r.asc == asc)
                        nr1 = .{ .asc = asc };
                }

                if (r2) |r| {
                    if (r.asc == null or r.asc == asc)
                        nr2 = .{ .asc = asc };
                }
            }

            if (a != pp and @abs(a - pp) <= 3) {
                const asc = a > pp;
                if (r0) |r| {
                    if (r.asc == null or r.asc == asc) {
                        if (nr2) |x| {
                            if (x.asc != asc) nr2 = .{ .asc = null };
                        } else {
                            nr2 = .{ .asc = asc };
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
