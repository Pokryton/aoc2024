const std = @import("std");

const Direction = enum {
    east,
    south,
    west,
    north,

    fn turnLeft(self: @This()) @This() {
        return @enumFromInt(@intFromEnum(self) +% 1);
    }

    fn turnRight(self: @This()) @This() {
        return @enumFromInt(@intFromEnum(self) -% 1);
    }
};

inline fn step(x: usize, l: usize, dir: Direction) usize {
    return switch (dir) {
        .east => x + 1,
        .west => x - 1,
        .north => x - l,
        .south => x + l,
    };
}

fn search(map: []const u8, l: usize, x: usize, dir: Direction, score: u32, min: []u32, end: usize) void {
    if (score >= min[x] + 1000 or score >= min[end]) return;
    min[x] = score;

    if (x == end) return;

    var nx = step(x, l, dir);
    if (map[nx] != '#') search(map, l, nx, dir, score + 1, min, end);

    inline for (.{ dir.turnLeft(), dir.turnRight() }) |d| {
        nx = step(x, l, d);
        if (map[nx] != '#') search(map, l, nx, d, score + 1001, min, end);
    }
}

const bignum = std.math.maxInt(u32) / 2;

fn part1(allocator: std.mem.Allocator, input: []const u8) !u32 {
    const l = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    const start = for (input, 0..) |c, i| {
        if (c == 'S') break i;
    } else unreachable;
    const end = for (input, 0..) |c, i| {
        if (c == 'E') break i;
    } else unreachable;

    const min = try allocator.alloc(u32, input.len);
    defer allocator.free(min);
    @memset(min, bignum);

    search(input, l, start, .east, 0, min, end);
    return min[end];
}

fn markPath(map: []const u8, l: usize, x: usize, dir: Direction, score: u32, min: []u32, mark: []bool, end: usize) bool {
    if (score > min[x] + 1000 or score > min[end]) return false;
    if (x == end) return true;

    var ret: bool = false;

    var nx = step(x, l, dir);
    if (map[nx] != '#') ret = markPath(map, l, nx, dir, score + 1, min, mark, end);

    inline for (.{ dir.turnLeft(), dir.turnRight() }) |d| {
        nx = step(x, l, d);
        if (map[nx] != '#' and markPath(map, l, nx, d, score + 1001, min, mark, end))
            ret = true;
    }

    if (ret) mark[x] = true;
    return ret;
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !u32 {
    const l = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    const start = for (input, 0..) |c, i| {
        if (c == 'S') break i;
    } else unreachable;
    const end = for (input, 0..) |c, i| {
        if (c == 'E') break i;
    } else unreachable;

    const min = try allocator.alloc(u32, input.len);
    defer allocator.free(min);
    @memset(min, bignum);
    search(input, l, start, .east, 0, min, end);

    const mark = try allocator.alloc(bool, input.len);
    defer allocator.free(mark);
    @memset(mark, false);
    mark[end] = true;
    _ = markPath(input, l, start, .east, 0, min, mark, end);

    var count: u32 = 0;
    for (mark) |b| {
        if (b) count += 1;
    }
    return count;
}

test {
    const ally = std.testing.allocator;

    const input1 =
        \\###############
        \\#.......#....E#
        \\#.#.###.#.###.#
        \\#.....#.#...#.#
        \\#.###.#####.#.#
        \\#.#.#.......#.#
        \\#.#.#####.###.#
        \\#...........#.#
        \\###.#.#####.#.#
        \\#...#.....#.#.#
        \\#.#.#.###.#.#.#
        \\#.....#...#.#.#
        \\#.###.#.#.#.#.#
        \\#S..#.....#...#
        \\###############
        \\
    ;
    try std.testing.expectEqual(part1(ally, input1), 7036);
    try std.testing.expectEqual(part2(ally, input1), 45);

    const input2 =
        \\#################
        \\#...#...#...#..E#
        \\#.#.#.#.#.#.#.#.#
        \\#.#.#.#...#...#.#
        \\#.#.#.#.###.#.#.#
        \\#...#.#.#.....#.#
        \\#.#.#.#.#.#####.#
        \\#.#...#.#.#.....#
        \\#.#.#####.#.###.#
        \\#.#.#.......#...#
        \\#.#.###.#####.###
        \\#.#.#...#.....#.#
        \\#.#.#.#####.###.#
        \\#.#.#.........#.#
        \\#.#.#.#########.#
        \\#S#.............#
        \\#################
        \\
    ;
    try std.testing.expectEqual(part1(ally, input2), 11048);
    try std.testing.expectEqual(part2(ally, input2), 64);
}

pub fn main() !void {
    const input = @embedFile("input");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    std.debug.print("{}\n", .{try part1(allocator, input)});
    std.debug.print("{}\n", .{try part2(allocator, input)});
}
