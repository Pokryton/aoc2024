const std = @import("std");

fn hostId(name: *const [2]u8) u16 {
    const x: u16 = name[0] - 'a';
    const y: u16 = name[1] - 'a';
    return x * 26 + y;
}

fn hostName(id: u16) [2]u8 {
    const c0: u8 = @intCast(id / 26);
    const c1: u8 = @intCast(id % 26);
    return .{c0 + 'a', c1 + 'a'};
}

const capacity = 26 * 26;

fn part1(input: []const u8) !u32 {
    var connected: [capacity][capacity]bool = .{.{false} ** capacity} ** capacity;

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        const x = hostId(line[0..2]);
        const y = hostId(line[3..5]);
        connected[x][y] = true;
        connected[y][x] = true;
    }

    var sum: u32 = 0;
    var sum2: u32 = 0;
    var sum3: u32 = 0;

    for (hostId("ta")..hostId("tz") + 1) |x| {
        for (0..capacity) |y| {
            if (!connected[x][y]) continue;

            const yt = (y / 26 + 'a') == 't';

            for (y + 1..capacity) |z| {
                if (!connected[y][z] or !connected[x][z]) continue;

                sum += 1;

                const zt = (z / 26 + 'a') == 't';
                if (yt and zt) {
                    sum3 += 1;
                } else if (yt or zt) {
                    sum2 += 1;
                }
            }
        }
    }

    return sum - sum2 / 2 - sum3 / 3 * 2;
}

const Clique = std.BoundedArray(u16, capacity);

fn searchClique(
    connected: [capacity][capacity]bool,
    start: u16,
    clique: *Clique,
    max_clique: *Clique,
) !void {
    try clique.append(start);

    var maximal: bool = true;

    outer: for (start + 1..capacity) |u| {
        for (clique.slice()) |v| {
            if (!connected[u][v]) continue :outer;
        }

        try searchClique(connected, @intCast(u), clique, max_clique);
        maximal = false;
    }

    if (maximal and clique.len > max_clique.len) {
        max_clique.* = clique.*;
    }

    _ = clique.pop();
}

fn part2(input: []const u8) !Clique {
    var connected: [capacity][capacity]bool = .{.{false} ** capacity} ** capacity;

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        const x = hostId(line[0..2]);
        const y = hostId(line[3..5]);
        connected[x][y] = true;
        connected[y][x] = true;
    }

    var clique = try Clique.init(0);
    var max = try Clique.init(0);

    for (0..capacity) |start| {
        try searchClique(connected, @intCast(start), &clique, &max);
    }

    return max;
}

test {
    const input =
        \\kh-tc
        \\qp-kh
        \\de-cg
        \\ka-co
        \\yn-aq
        \\qp-ub
        \\cg-tb
        \\vc-aq
        \\tb-ka
        \\wh-tc
        \\yn-cg
        \\kh-ub
        \\ta-co
        \\de-co
        \\tc-td
        \\tb-wq
        \\wh-td
        \\ta-ka
        \\td-qp
        \\aq-cg
        \\wq-ub
        \\ub-vc
        \\de-ta
        \\wq-aq
        \\wq-vc
        \\wh-yn
        \\ka-de
        \\kh-ta
        \\co-tc
        \\wh-qp
        \\tb-vc
        \\td-yn
    ;
    try std.testing.expectEqual(part1(input), 7);

    const max_clique = try part2(input);
    const expected = [_]*const [2]u8{"co", "de", "ka", "ta"};

    for (max_clique.slice(), expected) |i, s| {
        try std.testing.expectEqual(i, hostId(s));
    }
}

pub fn main() !void {
    const input = @embedFile("input");

    std.debug.print("{}\n", .{try part1(input)});

    const max_clique = try part2(input);
    for (max_clique.slice()) |i| {
        std.debug.print("{s},", .{hostName(i)});
    }
    std.debug.print("\n", .{});
}
