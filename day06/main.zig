const std = @import("std");

const Direction = enum {
    up,
    right,
    down,
    left,

    pub fn getRight(self: @This()) @This() {
        const i: u2 = @intFromEnum(self);
        return @enumFromInt(i +% 1);
    }

    pub fn turnRight(self: *@This()) void {
        self.* = getRight(self.*);
    }
};

fn step(x: usize, dir: Direction, l: usize, n: usize) ?usize {
    return switch (dir) {
        .up => if (x < l) null else x - l,
        .down => if (x + l >= n) null else x + l,
        .left => if (x % l == 0) null else x - 1,
        .right => if (x % l == l - 2) null else x + 1,
    };
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !u32 {
    const l = std.mem.indexOfScalar(u8, input, '\n').? + 1;

    var x = std.mem.indexOfScalar(u8, input, '^').?;
    var dir: Direction = .up;

    var visited = try std.DynamicBitSet.initEmpty(allocator, input.len);
    defer visited.deinit();

    var count: u32 = 0;

    while (true) {
        if (!visited.isSet(x)) {
            count += 1;
            visited.set(x);
        }

        const nx = step(x, dir, l, input.len) orelse break;
        if (input[nx] == '#') {
            dir.turnRight();
        } else {
            x = nx;
        }
    }

    return count;
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !u32 {
    const l = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    const start = std.mem.indexOfScalar(u8, input, '^').?;

    var x = start;
    var dir: Direction = .up;
    var count: u32 = 0;

    const DirectionSet = std.EnumSet(Direction);

    var mark = try allocator.alloc(DirectionSet, input.len);
    defer allocator.free(mark);
    @memset(mark, DirectionSet.initEmpty());

    var mark2 = try allocator.alloc(DirectionSet, input.len);
    defer allocator.free(mark2);

    var ob_set = try std.DynamicBitSet.initEmpty(allocator, input.len);
    defer ob_set.deinit();

    // advent of brute-force
    while (true) {
        mark[x].insert(dir);

        const nx = step(x, dir, l, input.len) orelse break;
        if (input[nx] == '#') {
            dir.turnRight();
            continue;
        }
        defer x = nx;

        // add an obstruction at input[nx]
        if (ob_set.isSet(nx)) continue;
        ob_set.set(nx);

        var x2 = x;
        var dir2 = dir.getRight();
        @memcpy(mark2, mark);

        while (true) {
            if (mark2[x2].contains(dir2)) {
                count += 1;
                break;
            }
            mark2[x2].insert(dir2);

            const nx2 = step(x2, dir2, l, input.len) orelse break;
            if (input[nx2] == '#' or nx2 == nx) {
                dir2.turnRight();
            } else {
                x2 = nx2;
            }
        }
    }

    return count;
}

test {
    const input =
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...
        \\
    ;

    const ally = std.testing.allocator;
    try std.testing.expectEqual(part1(ally, input), 41);
    try std.testing.expectEqual(part2(ally, input), 6);
}

pub fn main() !void {
    const input = @embedFile("input");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    std.debug.print("{}\n", .{try part1(allocator, input)});
    std.debug.print("{}\n", .{try part2(allocator, input)});
}
