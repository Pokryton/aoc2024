const std = @import("std");

fn part1(allocator: std.mem.Allocator, input: []const u8) !u32 {
    const s = std.mem.indexOf(u8, input, "\n\n").? + 1;

    var map = try allocator.alloc(u8, s);
    defer allocator.free(map);
    @memcpy(map, input[0..s]);

    const moves = input[s + 1 ..];

    const l = std.mem.indexOfScalar(u8, map, '\n').? + 1;

    var x = for (0.., map) |i, c| {
        if (c == '@') break i;
    } else unreachable;
    map[x] = '.';

    for (moves) |move| {
        const dx = switch (move) {
            '^' => -%l,
            '>' => 1,
            'v' => l,
            '<' => @as(usize, 0) -% 1,
            '\n' => continue,
            else => unreachable,
        };

        const nx = x +% dx;

        var i = nx;
        while (map[i] == 'O') i +%= dx;

        if (map[i] == '#') continue;
        if (i != nx) map[i] = 'O';

        x = nx;
        map[nx] = '.';
    }

    var sum: u32 = 0;
    for (map, 0..) |c, i| {
        if (c == 'O') sum += @intCast((i / l) * 100 + (i % l));
    }
    return sum;
}

fn canPushBoxVertically(map: []u8, x: usize, dx: usize) bool {
    const nx = x +% dx;

    if (map[nx] == '#' or map[nx + 1] == '#') return false;

    if (map[nx] == '[') return canPushBoxVertically(map, nx, dx);

    if (map[nx] == ']' and !canPushBoxVertically(map, nx - 1, dx)) return false;
    if (map[nx + 1] == '[' and !canPushBoxVertically(map, nx + 1, dx)) return false;

    return true;
}

fn pushBoxVertically(map: []u8, x: usize, dx: usize) void {
    const nx = x +% dx;
    if (map[nx] == '[') {
        pushBoxVertically(map, nx, dx);
    } else {
        if (map[nx] == ']') pushBoxVertically(map, nx - 1, dx);
        if (map[nx + 1] == '[') pushBoxVertically(map, nx + 1, dx);
    }

    @memcpy(map[nx .. nx + 2], "[]");
    @memcpy(map[x .. x + 2], "..");
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !u32 {
    const s = std.mem.indexOf(u8, input, "\n\n").? + 1;

    var map = try allocator.alloc(u8, s * 2);
    defer allocator.free(map);
    var x: usize = undefined;

    for (input[0..s], 0..) |c, i| {
        const m = map[2 * i .. 2 * (i + 1)];
        switch (c) {
            '#' => @memcpy(m, "##"),
            'O' => @memcpy(m, "[]"),
            '.' => @memcpy(m, ".."),
            '@' => {
                @memcpy(m, "..");
                x = 2 * i;
            },
            '\n' => @memcpy(m, " \n"),
            else => unreachable,
        }
    }

    const moves = input[s + 1 ..];

    const l = std.mem.indexOfScalar(u8, map, '\n').? + 1;

    for (moves) |move| {
        switch (move) {
            '\n' => continue,

            '<', '>' => {
                const dx = if (move == '<') @as(usize, 0) -% 1 else 1;

                var i = x +% dx;
                while (map[i] == '[' or map[i] == ']') i +%= dx;
                if (map[i] == '#') continue;

                var j = i;
                while (j != x) : (j -%= dx) {
                    map[j] = map[j -% dx];
                }
                x +%= dx;
                map[x] = '.';
            },

            '^', 'v' => {
                const dx = if (move == '^') -%l else l;
                const nx = x +% dx;
                switch (map[nx]) {
                    '.' => x = nx,
                    '#' => {},
                    '[', ']' => {
                        const box = if (map[nx] == '[') nx else nx - 1;
                        if (canPushBoxVertically(map, box, dx)) {
                            pushBoxVertically(map, box, dx);
                            x = nx;
                        }
                    },
                    else => unreachable,
                }
            },
            else => unreachable,
        }
    }

    var sum: u32 = 0;
    for (map, 0..) |c, i| {
        if (c == '[') sum += @intCast((i / l) * 100 + (i % l));
    }
    return sum;
}

test {
    const ally = std.testing.allocator;

    const input1 =
        \\########
        \\#..O.O.#
        \\##@.O..#
        \\#...O..#
        \\#.#.O..#
        \\#...O..#
        \\#......#
        \\########
        \\
        \\<^^>>>vv<v>>v<<
        \\
    ;

    try std.testing.expectEqual(part1(ally, input1), 2028);

    const input2 =
        \\##########
        \\#..O..O.O#
        \\#......O.#
        \\#.OO..O.O#
        \\#..O@..O.#
        \\#O#..O...#
        \\#O..O..O.#
        \\#.OO.O.OO#
        \\#....O...#
        \\##########
        \\
        \\<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
        \\vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
        \\><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
        \\<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
        \\^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
        \\^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
        \\>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
        \\<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
        \\^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
        \\v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
        \\
    ;
    try std.testing.expectEqual(part1(ally, input2), 10092);
    try std.testing.expectEqual(part2(ally, input2), 9021);
}

pub fn main() !void {
    const input = @embedFile("input");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    std.debug.print("{}\n", .{try part1(allocator, input)});
    std.debug.print("{}\n", .{try part2(allocator, input)});
}
