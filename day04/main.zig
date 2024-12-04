const std = @import("std");

// count the number of `i` that satisfy `haystack[i : (i+needle.len*stride) : stride] == needle`
fn countStrided(haystack: []const u8, needle: []const u8, stride: usize) usize {
    var found: usize = 0;

    outer: for (0..haystack.len - (needle.len - 1) * stride) |i| {
        for (0.., needle) |j, c| {
            if (haystack[i + j * stride] != c)
                continue :outer;
        }
        found += 1;
    }

    return found;
}

fn part1(input: []const u8) usize {
    const l = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    var count: usize = 0;

    inline for (.{ 1, l, l - 1, l + 1 }) |stride| {
        count += countStrided(input, "XMAS", stride);
        count += countStrided(input, "SAMX", stride);
    }

    return count;
}

fn part2(input: []const u8) usize {
    const l = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    var count: usize = 0;

    for (l + 1..input.len - l - 1) |i| {
        if (i % l == 0 or i % l == l - 1) continue;
        if (input[i] != 'A') continue;

        const c0 = input[i - l - 1];
        const c1 = input[i + l + 1];
        if (!((c0 == 'M' and c1 == 'S') or (c0 == 'S' and c1 == 'M')))
            continue;

        const c2 = input[i - l + 1];
        const c3 = input[i + l - 1];
        if (!((c2 == 'M' and c3 == 'S') or (c2 == 'S' and c3 == 'M')))
            continue;

        count += 1;
    }

    return count;
}

test {
    const input =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
        \\
    ;

    try std.testing.expectEqual(part1(input), 18);
    try std.testing.expectEqual(part2(input), 9);
}

pub fn main() void {
    const input = @embedFile("input");
    std.debug.print("{}\n", .{part1(input)});
    std.debug.print("{}\n", .{part2(input)});
}
