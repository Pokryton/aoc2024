const std = @import("std");

fn part1(allocator: std.mem.Allocator, input: []const u8, save: u32) !u32 {
    const l = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    const start = std.mem.indexOfScalar(u8, input, 'S').?;
    const end = std.mem.indexOfScalar(u8, input, 'E').?;

    const dxs = .{ 1, l, -%@as(usize, 1), -%l };

    var x = end;
    var prev: usize = 0;

    const dist = try allocator.alloc(usize, input.len);
    defer allocator.free(dist);

    var step: u32 = 0;
    while (x != start) : (step += 1) {
        dist[x] = step;

        const nx = inline for (dxs) |dx| {
            const nx = x +% dx;
            if (nx != prev and input[nx] != '#') break nx;
        } else unreachable;

        prev = x;
        x = nx;
    }

    const lim = step - save;

    x = start;
    prev = 0;
    step = 0;

    var count: u32 = 0;
    while (step < lim) : (step += 1) {
        inline for (dxs) |dx| {
            if (input[x +% dx] == '#') {
                const nx = x +% dx +% dx;
                if (nx < input.len and input[nx] != '#' and input[nx] != '\n') {
                    if (step + 2 + dist[nx] <= lim) count += 1;
                }
            }
        }

        const nx = inline for (dxs) |dx| {
            const nx = x +% dx;
            if (nx != prev and input[nx] != '#') break nx;
        } else unreachable;

        prev = x;
        x = nx;
    }

    return count;
}

test part1 {
    const input =
        \\###############
        \\#...#...#.....#
        \\#.#.#.#.#.###.#
        \\#S#...#.#.#...#
        \\#######.#.#.###
        \\#######.#.#...#
        \\#######.#.###.#
        \\###..E#...#...#
        \\###.#######.###
        \\#...###...#...#
        \\#.#####.#.###.#
        \\#.#...#.#.#...#
        \\#.#.#.#.#.#.###
        \\#...#...#...###
        \\###############
        \\
    ;

    const ally = std.testing.allocator;
    try std.testing.expectEqual(part1(ally, input, 64), 1);
    try std.testing.expectEqual(part1(ally, input, 41), 1);
    try std.testing.expectEqual(part1(ally, input, 40), 2);
    try std.testing.expectEqual(part1(ally, input, 38), 3);
    try std.testing.expectEqual(part1(ally, input, 36), 4);
    try std.testing.expectEqual(part1(ally, input, 20), 5);
    try std.testing.expectEqual(part1(ally, input, 12), 8);
    try std.testing.expectEqual(part1(ally, input, 10), 10);
}

fn countCheats(
    map: []const u8,
    l: usize,
    start: usize,
    dist: []usize,
    lim: usize,
    queue: *std.ArrayList(usize),
    visited: *std.DynamicBitSetUnmanaged,
) !u32 {
    // TODO: refactor these dumb code, no need for bfs
    visited.unsetAll();
    queue.clearRetainingCapacity();

    try queue.append(start);

    var front: usize = 0;
    var step: usize = 0;

    var count: u32 = 0;

    while (front < queue.items.len and step <= 20) : (step += 1) {
        const back = queue.items.len;
        while (front < back) : (front += 1) {
            const x = queue.items[front];
            if (map[x] != '#') {
                if (step + dist[x] <= lim) count += 1;
            }

            inline for (.{ x -% 1, x + 1, x -% l, x + l }) |nx| {
                if (nx < map.len and map[nx] != '\n' and !visited.isSet(nx)) {
                    visited.set(nx);
                    try queue.append(nx);
                }
            }
        }
    }

    return count;
}

fn part2(allocator: std.mem.Allocator, input: []const u8, save: u32) !u32 {
    const l = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    const start = std.mem.indexOfScalar(u8, input, 'S').?;
    const end = std.mem.indexOfScalar(u8, input, 'E').?;

    const dxs = .{ 1, l, -%@as(usize, 1), -%l };

    var x = end;
    var prev: usize = 0;

    const dist = try allocator.alloc(usize, input.len);
    defer allocator.free(dist);

    var step: u32 = 0;
    while (x != start) : (step += 1) {
        dist[x] = step;

        const nx = inline for (dxs) |dx| {
            const nx = x +% dx;
            if (nx != prev and input[nx] != '#') break nx;
        } else unreachable;

        prev = x;
        x = nx;
    }

    const lim = step - save;

    x = start;
    prev = 0;
    step = 0;

    var count: u32 = 0;

    var queue = std.ArrayList(usize).init(allocator);
    defer queue.deinit();
    var visited = try std.DynamicBitSetUnmanaged.initEmpty(allocator, input.len);
    defer visited.deinit(allocator);

    while (step <= lim) : (step += 1) {
        count += try countCheats(input, l, x, dist, lim - step, &queue, &visited);

        const nx = inline for (dxs) |dx| {
            const nx = x +% dx;
            if (nx != prev and input[nx] != '#') break nx;
        } else unreachable;

        prev = x;
        x = nx;
    }

    return count;
}

test part2 {
    const input =
        \\###############
        \\#...#...#.....#
        \\#.#.#.#.#.###.#
        \\#S#...#.#.#...#
        \\#######.#.#.###
        \\#######.#.#...#
        \\#######.#.###.#
        \\###..E#...#...#
        \\###.#######.###
        \\#...###...#...#
        \\#.#####.#.###.#
        \\#.#...#.#.#...#
        \\#.#.#.#.#.#.###
        \\#...#...#...###
        \\###############
        \\
    ;

    const ally = std.testing.allocator;
    try std.testing.expectEqual(part2(ally, input, 76), 3);
    try std.testing.expectEqual(part2(ally, input, 74), 7);
    try std.testing.expectEqual(part2(ally, input, 72), 29);
    try std.testing.expectEqual(part2(ally, input, 70), 41);
    try std.testing.expectEqual(part2(ally, input, 68), 55);
}

pub fn main() !void {
    const input = @embedFile("input");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    std.debug.print("{}\n", .{try part1(allocator, input, 100)});
    std.debug.print("{}\n", .{try part2(allocator, input, 100)});
}
