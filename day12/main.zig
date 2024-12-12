const std = @import("std");

inline fn inSameRegion(map: []const u8, i: usize, j: usize) bool {
    return j < map.len - 1 and map[i] == map[j];
}

fn measure1(map: []const u8, i: usize, l: usize, visited: *std.DynamicBitSetUnmanaged, area: *u32, perimeter: *u32) void {
    if (visited.isSet(i)) return;
    visited.set(i);

    area.* += 1;

    const adjs = .{ i -% 1, i + 1, i -% l, i + l };
    inline for (adjs) |j| {
        if (!inSameRegion(map, i, j)) perimeter.* += 1;
    }

    inline for (adjs) |j| {
        if (inSameRegion(map, i, j)) measure1(map, j, l, visited, area, perimeter);
    }
}

// sides = corners
fn measure2(map: []const u8, i: usize, l: usize, visited: *std.DynamicBitSetUnmanaged, area: *u32, corners: *u32) void {
    if (visited.isSet(i)) return;
    visited.set(i);

    area.* += 1;

    inline for (.{ i -% 1, i + 1 }) |j| {
        inline for (.{ i -% l, i + l }) |k| {
            // convex
            if (!inSameRegion(map, i, j) and !inSameRegion(map, i, k)) corners.* += 1;

            // concave
            if (inSameRegion(map, i, j) and inSameRegion(map, i, k) and !inSameRegion(map, i, j + k - i))
                corners.* += 1;
        }
    }

    inline for (.{ i -% 1, i + 1, i -% l, i + l }) |j| {
        if (inSameRegion(map, i, j)) measure2(map, j, l, visited, area, corners);
    }
}

const AocPart = enum { part1, part2 };

fn solve(allocator: std.mem.Allocator, input: []const u8, comptime part: AocPart) !u32 {
    const l = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    var visited = try std.DynamicBitSetUnmanaged.initEmpty(allocator, input.len);
    defer visited.deinit(allocator);

    var sum: u32 = 0;
    for (input, 0..) |c, i| {
        if (c == '\n' or visited.isSet(i)) continue;

        const measureFn = comptime if (part == .part1) measure1 else measure2;

        var area: u32 = 0;
        var num: u32 = 0;
        measureFn(input, i, l, &visited, &area, &num);
        sum += area * num;
    }

    return sum;
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !u32 {
    return solve(allocator, input, .part1);
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !u32 {
    return solve(allocator, input, .part2);
}

test part1 {
    const ally = std.testing.allocator;

    const input1 =
        \\AAAA
        \\BBCD
        \\BBCC
        \\EEEC
        \\
    ;
    try std.testing.expectEqual(part1(ally, input1), 140);

    const input2 =
        \\OOOOO
        \\OXOXO
        \\OOOOO
        \\OXOXO
        \\OOOOO
        \\
    ;
    try std.testing.expectEqual(part1(ally, input2), 772);

    const input3 =
        \\RRRRIICCFF
        \\RRRRIICCCF
        \\VVRRRCCFFF
        \\VVRCCCJFFF
        \\VVVVCJJCFE
        \\VVIVCCJJEE
        \\VVIIICJJEE
        \\MIIIIIJJEE
        \\MIIISIJEEE
        \\MMMISSJEEE
        \\
    ;
    try std.testing.expectEqual(part1(ally, input3), 1930);
}

test part2 {
    const ally = std.testing.allocator;

    const input1 =
        \\AAAA
        \\BBCD
        \\BBCC
        \\EEEC
        \\
    ;
    try std.testing.expectEqual(part2(ally, input1), 80);

    const input2 =
        \\EEEEE
        \\EXXXX
        \\EEEEE
        \\EXXXX
        \\EEEEE
        \\
    ;
    try std.testing.expectEqual(part2(ally, input2), 236);

    const input3 =
        \\AAAAAA
        \\AAABBA
        \\AAABBA
        \\ABBAAA
        \\ABBAAA
        \\AAAAAA
        \\
    ;
    try std.testing.expectEqual(part2(ally, input3), 368);

    const input4 =
        \\RRRRIICCFF
        \\RRRRIICCCF
        \\VVRRRCCFFF
        \\VVRCCCJFFF
        \\VVVVCJJCFE
        \\VVIVCCJJEE
        \\VVIIICJJEE
        \\MIIIIIJJEE
        \\MIIISIJEEE
        \\MMMISSJEEE
        \\
    ;
    try std.testing.expectEqual(part2(ally, input4), 1206);
}

pub fn main() !void {
    const input = @embedFile("input");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    std.debug.print("{}\n", .{try part1(allocator, input)});
    std.debug.print("{}\n", .{try part2(allocator, input)});
}
