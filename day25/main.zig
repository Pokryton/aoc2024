const std = @import("std");

fn part1(input: []const u8) !u64 {
    const V = @Vector(5, u8);

    var keys = try std.BoundedArray(V, 500).init(0);
    var locks = try std.BoundedArray(V, 500).init(0);

    var it = std.mem.tokenizeSequence(u8, input, "\n\n");
    while (it.next()) |entry| {
        var v: V = @splat(0);

        for (0..5) |i| {
            for (1..6) |j| {
                if (entry[i + j * 6] == '#') v[i] += 1;
            }
        }

        if (entry[0] == '#') {
            try locks.append(v);
        } else {
            try keys.append(v);
        }
    }

    var count: u64 = 0;

    for (keys.slice()) |key| {
        for (locks.slice()) |item| {
            const sum = key + item;
            const matches = sum < @as(V, @splat(6));
            if (@reduce(.And, matches))
                count += 1;
        }
    }

    return count;
}

test part1 {
    const input =
        \\#####
        \\.####
        \\.####
        \\.####
        \\.#.#.
        \\.#...
        \\.....
        \\
        \\#####
        \\##.##
        \\.#.##
        \\...##
        \\...#.
        \\...#.
        \\.....
        \\
        \\.....
        \\#....
        \\#....
        \\#...#
        \\#.#.#
        \\#.###
        \\#####
        \\
        \\.....
        \\.....
        \\#.#..
        \\###..
        \\###.#
        \\###.#
        \\#####
        \\
        \\.....
        \\.....
        \\.....
        \\#....
        \\#.#..
        \\#.#.#
        \\#####
    ;

    try std.testing.expectEqual(part1(input), 3);
}

pub fn main() !void {
    const input = @embedFile("input");

    std.debug.print("{}\n", .{try part1(input)});
}
