const std = @import("std");

const Vec2 = struct { x: i32, y: i32 };

// "a=xx,yy" => .{ .x = xx, .y = yy }
fn parseVec(input: []const u8) !Vec2 {
    const i = 1; // std.mem.indexOfScalar(u8, input, '=') orelse return error.InvalidInput;
    const j = std.mem.indexOfScalar(u8, input, ',') orelse return error.InvalidInput;

    return .{
        .x = try std.fmt.parseInt(i32, input[i + 1 .. j], 10),
        .y = try std.fmt.parseInt(i32, input[j + 1 ..], 10),
    };
}

pub fn part1(input: []const u8, square: struct { width: comptime_int = 101, height: comptime_int = 103 }) !u32 {
    var quadrant: [2][2]u32 = .{.{ 0, 0 }} ** 2;

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        const s = std.mem.indexOfScalar(u8, line, ' ').?;
        const pos = try parseVec(line[0..s]);
        const v = try parseVec(line[s + 1 ..]);

        const dst = .{
            .x = @mod(pos.x + v.x * 100, square.width),
            .y = @mod(pos.y + v.y * 100, square.height),
        };

        const midx = square.width / 2;
        const midy = square.height / 2;

        if (dst.x == midx or dst.y == midy) continue;
        quadrant[@intFromBool(dst.x < midx)][@intFromBool(dst.y < midy)] += 1;
    }

    return quadrant[0][0] * quadrant[0][1] * quadrant[1][0] * quadrant[1][1];
}

pub fn part2(input: []const u8) !u32 {
    const width = 101;
    const height = 103;

    var robots = try std.BoundedArray(struct { pos: Vec2, v: Vec2 }, 500).init(0);
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        const s = std.mem.indexOfScalar(u8, line, ' ').?;
        const pos = try parseVec(line[0..s]);
        const v = try parseVec(line[s + 1 ..]);

        try robots.append(.{ .pos = pos, .v = v });
    }

    for (0..width * height) |second| {
        var grid: [height][width]bool = .{.{false} ** width} ** height;

        for (robots.slice()) |*robot| {
            grid[@intCast(robot.pos.y)][@intCast(robot.pos.x)] = true;
        }

        var dense_count: usize = 0;
        for (0..height) |j| {
            for (0..width) |k| {
                if (!grid[j][k]) continue;
                if ((j > 0 and grid[j - 1][k]) or
                    (k > 0 and grid[j][k - 1]) or
                    (j < height - 1 and grid[j + 1][k]) or
                    (k < width - 1 and grid[j][k + 1]))
                    dense_count += 1;
            }
        }

        // std.debug.print("{d}\n", .{@as(f64, @floatFromInt(dense_count)) / @as(f64, @floatFromInt(robots.len))});
        if (dense_count >= robots.slice().len * 2 / 3) return @intCast(second);

        for (robots.slice()) |*robot| {
            robot.pos.x = @mod(robot.pos.x + robot.v.x, width);
            robot.pos.y = @mod(robot.pos.y + robot.v.y, height);
        }
    }

    return error.NotFound;
}

test part1 {
    const input =
        \\p=0,4 v=3,-3
        \\p=6,3 v=-1,-3
        \\p=10,3 v=-1,2
        \\p=2,0 v=2,-1
        \\p=0,0 v=1,3
        \\p=3,0 v=-2,-2
        \\p=7,6 v=-1,-3
        \\p=3,0 v=-1,-2
        \\p=9,3 v=2,3
        \\p=7,3 v=-1,2
        \\p=2,4 v=2,-3
        \\p=9,5 v=-3,-3
    ;
    try std.testing.expectEqual(part1(input, .{ .width = 11, .height = 7 }), 12);
}

pub fn main() !void {
    const input = @embedFile("input");

    std.debug.print("{}\n", .{try part1(input, .{})});
    std.debug.print("{}\n", .{try part2(input)});
}
