const std = @import("std");

const num_keypad = [4][3]u8{
    .{ '7', '8', '9' },
    .{ '4', '5', '6' },
    .{ '1', '2', '3' },
    .{ '#', '0', 'A' },
};

const dir_keypad = [2][3]u8{
    .{ '#', '^', 'A' },
    .{ '<', 'v', '>' },
};

const Coord = struct { i: usize, j: usize };

fn locate(map: anytype, n: u8) Coord {
    for (map, 0..) |row, i| {
        for (row, 0..) |v, j| {
            if (v == n) return .{ .i = i, .j = j };
        }
    }
    unreachable;
}

// TODO: costs: [5][5]u64

fn stepCost(map: anytype, costs: [128][128]u64, from: u8, to: u8) u64 {
    const p0 = locate(map, from);
    const p1 = locate(map, to);

    const dy = @as(i32, @intCast(p1.i)) - @as(i32, @intCast(p0.i));
    const dx = @as(i32, @intCast(p1.j)) - @as(i32, @intCast(p0.j));

    if (dx == 0 and dy == 0) return 1;

    const vert: u8 = if (dy < 0) '^' else 'v';
    const horz: u8 = if (dx < 0) '<' else '>';

    if (dy == 0) return costs['A'][horz] + @abs(dx) - 1 + costs[horz]['A'];
    if (dx == 0) return costs['A'][vert] + @abs(dy) - 1 + costs[vert]['A'];

    const t = @abs(dx) + @abs(dy) - 2;
    const vh = costs['A'][vert] + costs[vert][horz] + costs[horz]['A'] + t;
    const hv = costs['A'][horz] + costs[horz][vert] + costs[vert]['A'] + t;

    if (map[p0.i][p1.j] == '#') return vh;
    if (map[p1.i][p0.j] == '#') return hv;

    return @min(vh, hv);
}

fn minPresses(code: []const u8, comptime interm: u8) u64 {
    var costs: [2][128][128]u64 = .{.{.{1} ** 128} ** 128} ** 2;
    var i: usize = 0;

    for (1..interm + 1) |_| {
        i ^= 1;

        inline for (.{ '^', '<', 'v', '>' }) |k| {
            costs[i]['A'][k] = stepCost(dir_keypad, costs[i ^ 1], 'A', k);
            costs[i][k]['A'] = stepCost(dir_keypad, costs[i ^ 1], k, 'A');
        }

        inline for (.{ '^', 'v' }) |k1| {
            inline for (.{ '<', '>' }) |k2| {
                costs[i][k1][k2] = stepCost(dir_keypad, costs[i ^ 1], k1, k2);
                costs[i][k2][k1] = stepCost(dir_keypad, costs[i ^ 1], k2, k1);
            }
        }
    }

    var last: u8 = 'A';
    var sum: u64 = 0;

    for (code) |c| {
        sum += stepCost(num_keypad, costs[i], last, c);
        last = c;
    }

    return sum;
}

test minPresses {
    const testcases = .{
        .{ "029A", 68 },
        .{ "980A", 60 },
        .{ "179A", 68 },
        .{ "456A", 64 },
        .{ "379A", 64 },
    };

    inline for (testcases) |case| {
        try std.testing.expectEqual(minPresses(case[0], 2), case[1]);
    }
}

fn solve(input: []const u8, comptime interm: u8) !u64 {
    var total: u64 = 0;

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        const n = try std.fmt.parseInt(u64, line[0..3], 10);
        const press = minPresses(line, interm);

        total += n * press;
    }

    return total;
}

fn part1(input: []const u8) !u64 {
    return solve(input, 2);
}

fn part2(input: []const u8) !u64 {
    return solve(input, 25);
}

test part1 {
    const input =
        \\029A
        \\980A
        \\179A
        \\456A
        \\379A
    ;
    try std.testing.expectEqual(try part1(input), 126384);
}

pub fn main() !void {
    const input = @embedFile("input");
    std.debug.print("{}\n", .{try part1(input)});
    std.debug.print("{}\n", .{try part2(input)});
}
