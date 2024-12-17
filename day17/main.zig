const std = @import("std");

fn part1() void {
    // Register A: 44348299
    // Register B: 0
    // Register C: 0
    //
    // Program: 2,4,1,5,7,5,1,6,0,3,4,2,5,5,3,0

    // 0: 2, 4   bst A        ; B = A / 8
    // 1: 1, 5   bxl 5        ; B ^= 5
    // 2: 7, 5   cdv B        ; C = A / 2^B
    // 3: 1, 6   bxl 6        ; B ^= 6
    // 4: 0, 3   adv 3        ; A /= 8
    // 5: 4, 2   bxc          ; B ^= C
    // 6: 5, 5   out B
    // 7: 3, 0   jnz 0        ; if (A != 0) goto 0;

    var a: usize = 44348299;
    var b: usize = 0;
    var c: usize = 0;

    while (a != 0) {
        b = a & 7;
        b ^= 5;
        c = a >> @as(u3, @intCast(b));
        b ^= 6;
        a = a >> 3;
        b ^= c;
        std.debug.print("{},", .{b & 7});
    }

    std.debug.print("\n", .{});
}

fn restore(v: usize, outs: []const u3) ?usize {
    if (outs.len == 0) return v;

    for (0..8) |x| {
        const a = (v << 3) + x;
        const c = a >> @as(u3, @intCast(x ^ 5));
        const b = (x ^ 3) ^ c;

        if (b & 7 == outs[outs.len - 1]) {
            if (restore(a, outs[0 .. outs.len - 1])) |ans|
                return ans;
        }
    }

    return null;
}

fn part2() void {
    const outs = [_]u3{ 2, 4, 1, 5, 7, 5, 1, 6, 0, 3, 4, 2, 5, 5, 3, 0 };
    std.debug.print("{}\n", .{restore(0, &outs).?});
}

pub fn main() void {
    part1();
    part2();
}
