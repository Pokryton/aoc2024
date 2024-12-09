const std = @import("std");

fn file_cksum(addr: usize, size: usize, id: usize) usize {
    return @divExact((addr * 2 + size - 1) * size, 2) * id;
}

fn part1(input: []const u8) u64 {
    const Disk = struct {
        used: usize = 0,
        cksum: usize = 0,

        fn write(self: *@This(), len: usize, id: usize) void {
            self.cksum += file_cksum(self.used, len, id);
            self.used += len;
        }
    };

    var disk: Disk = .{ .used = input[0] - '0' };

    var i: usize = 1;
    var j: usize = input.len - 1;

    var fragment: u8 = input[j] - '0';

    while (true) {
        var space = input[i] - '0';
        while (space >= fragment and j > i + 1) {
            space -= fragment;
            disk.write(fragment, j / 2);

            j -= 2;
            fragment = input[j] - '0';
        }

        if (j == i + 1) {
            disk.write(fragment, j / 2);
            break;
        }

        disk.write(space, j / 2);
        fragment -= space;
        disk.write(input[i + 1] - '0', (i + 1) / 2);
        i += 2;
    }

    return disk.cksum;
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !usize {
    var occupied = try allocator.alloc(u8, input.len / 2); // for each free spaces
    defer allocator.free(occupied);
    @memset(occupied, 0);

    var sum: usize = 0;

    var i = input.len - 1;
    outer: while (i > 0) : (i -= 2) {
        const file_size = input[i] - '0';

        var j: usize = 1;
        var addr: usize = input[0] - '0'; // precomputing the address may improve performance

        while (j < i) : ({
            addr += input[j] - '0' + input[j + 1] - '0';
            j += 2;
        }) {
            const space = input[j] - '0' - occupied[j / 2];
            if (space >= file_size) {
                sum += file_cksum(addr + occupied[j / 2], file_size, i / 2);
                occupied[j / 2] += file_size;
                continue :outer;
            }
        }

        sum += file_cksum(addr - file_size, file_size, i / 2);
    }

    return sum;
}

test {
    const input = "2333133121414131402";

    try std.testing.expectEqual(part1(input), 1928);
    try std.testing.expectEqual(part2(std.testing.allocator, input), 2858);
}

pub fn main() !void {
    const input = comptime std.mem.trimRight(u8, @embedFile("input"), "\n");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    std.debug.print("{}\n", .{part1(input)});
    std.debug.print("{}\n", .{try part2(allocator, input)});
}
