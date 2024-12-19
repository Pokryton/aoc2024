const std = @import("std");

fn checkDesign(design: []const u8, towels: []const []const u8) bool {
    if (design.len == 0) return true;

    for (towels) |towel| {
        if (std.mem.startsWith(u8, design, towel)) {
            if (checkDesign(design[towel.len..], towels))
                return true;
        }
    }

    return false;
}

fn part1(input: []const u8) !u32 {
    const sep = std.mem.indexOf(u8, input, "\n\n").?;
    const towels_str = input[0..sep];
    const designs_str = input[sep + 2 ..];

    var towels = try std.BoundedArray([]const u8, 500).init(0);

    var towel_it = std.mem.tokenizeSequence(u8, towels_str, ", ");
    while (towel_it.next()) |towel| {
        try towels.append(towel);
    }

    var count: u32 = 0;

    var design_it = std.mem.tokenizeScalar(u8, designs_str, '\n');
    while (design_it.next()) |design| {
        if (checkDesign(design, towels.slice())) count += 1;
    }

    return count;
}

fn part2(input: []const u8) !u64 {
    const sep = std.mem.indexOf(u8, input, "\n\n").?;
    const towels_str = input[0..sep];
    const designs_str = input[sep + 2 ..];

    var towels = try std.BoundedArray([]const u8, 500).init(0);

    var towel_it = std.mem.tokenizeSequence(u8, towels_str, ", ");
    while (towel_it.next()) |towel| {
        try towels.append(towel);
    }

    var total: u64 = 0;

    var design_it = std.mem.tokenizeScalar(u8, designs_str, '\n');
    while (design_it.next()) |design| {
        var count: [100]u64 = .{0} ** 100;
        count[0] = 1;

        for (1..design.len + 1) |i| {
            for (towels.slice()) |towel| {
                if (std.mem.endsWith(u8, design[0..i], towel))
                    count[i] += count[i - towel.len];
            }
        }

        total += count[design.len];
    }

    return total;
}

test {
    const input =
        \\r, wr, b, g, bwu, rb, gb, br
        \\
        \\brwrr
        \\bggr
        \\gbbr
        \\rrbgbr
        \\ubwu
        \\bwurrg
        \\brgr
        \\bbrgwb
    ;
    try std.testing.expectEqual(part1(input), 6);
    try std.testing.expectEqual(part2(input), 16);
}

pub fn main() !void {
    const input = @embedFile("input");

    std.debug.print("{}\n", .{try part1(input)});
    std.debug.print("{}\n", .{try part2(input)});
}
