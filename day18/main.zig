const std = @import("std");

const Coord = struct { u32, u32 };

fn bfs(ps: []const Coord, n: comptime_int) !?u32 {
    const l = n + 1;
    var visited: [l][l]bool = .{.{false} ** l} ** l; // or corrupted

    for (ps) |p| {
        visited[p[0]][p[1]] = true;
    }

    var queue = try std.BoundedArray(Coord, l * l).init(0);
    var top: usize = 0;

    try queue.append(.{ 0, 0 });
    visited[0][0] = true;

    var step: u32 = 0;
    while (top < queue.slice().len) : (step += 1) {
        const end = queue.slice().len;

        while (top < end) : (top += 1) {
            const x, const y = queue.get(top);

            if (x == n and y == n) return step;

            inline for (.{ @as(@TypeOf(x), 0) -% 1, 1 }) |i| {
                const nx = x +% i;
                if (nx <= n and !visited[nx][y]) {
                    visited[nx][y] = true;
                    try queue.append(.{ nx, y });
                }

                const ny = y +% i;
                if (ny <= n and !visited[x][ny]) {
                    visited[x][ny] = true;
                    try queue.append(.{ x, ny });
                }
            }
        }
    }

    return null;
}

fn part1(input: []const u8, n: comptime_int, bytes: comptime_int) !u32 {
    var positions = try std.BoundedArray(Coord, 5000).init(0);

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    var count: u32 = 0;
    while (it.next()) |line| : (count += 1) {
        if (count == bytes) break;

        const sep = std.mem.indexOfScalar(u8, line, ',').?;
        const x = try std.fmt.parseInt(u8, line[0..sep], 10);
        const y = try std.fmt.parseInt(u8, line[sep + 1 ..], 10);
        try positions.append(.{ x, y });
    }

    return (try bfs(positions.slice(), n)) orelse error.Unreachable;
}

fn part2(input: []const u8, n: comptime_int) !Coord {
    var positions = try std.BoundedArray(Coord, 5000).init(0);

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        const sep = std.mem.indexOfScalar(u8, line, ',').?;
        const x = try std.fmt.parseInt(u8, line[0..sep], 10);
        const y = try std.fmt.parseInt(u8, line[sep + 1 ..], 10);
        try positions.append(.{ x, y });
    }

    const ps = positions.slice();

    var lo: u32 = 0; // 1024
    var hi: u32 = @intCast(ps.len - 1);

    while (lo < hi) {
        const mid = (lo + hi) / 2;
        if (try bfs(ps[0..mid], n) != null) {
            lo = mid + 1;
        } else {
            hi = mid;
        }
    }

    return ps[lo - 1];
}

test {
    const input =
        \\5,4
        \\4,2
        \\4,5
        \\3,0
        \\2,1
        \\6,3
        \\2,4
        \\1,5
        \\0,6
        \\3,3
        \\2,6
        \\5,1
        \\1,2
        \\5,5
        \\2,5
        \\6,5
        \\1,4
        \\0,4
        \\6,4
        \\1,1
        \\6,1
        \\1,0
        \\0,5
        \\1,6
        \\2,0
    ;

    try std.testing.expectEqual(part1(input, 6, 12), 22);
    try std.testing.expectEqual(part2(input, 6), .{ 6, 1 });
}

pub fn main() !void {
    const input = @embedFile("input");

    std.debug.print("{}\n", .{try part1(input, 70, 1024)});
    std.debug.print("{}\n", .{try part2(input, 70)});
}
