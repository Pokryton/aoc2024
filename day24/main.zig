const std = @import("std");

const Operator = enum {
    @"and",
    @"or",
    xor,
};

const Gate = struct {
    op: Operator,
    in0: [3]u8,
    in1: [3]u8,
};

const Wire = union(enum) {
    val: u1,
    gate: Gate,
};

fn findWireValue(table: std.AutoHashMap([3]u8, Wire), name: [3]u8) !u1 {
    const wire = table.getPtr(name) orelse return error.WireNotFound;

    switch (wire.*) {
        .val => |val| return val,
        .gate => |gate| {
            const in0 = try findWireValue(table, gate.in0);
            const in1 = try findWireValue(table, gate.in1);

            const val = switch (gate.op) {
                .@"and" => in0 & in1,
                .@"or" => in0 | in1,
                .xor => in0 ^ in1,
            };

            wire.* = Wire{ .val = val };
            return val;
        },
    }
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    var table = std.AutoHashMap([3]u8, Wire).init(allocator);
    defer table.deinit();

    var line_it = std.mem.splitScalar(u8, input, '\n');

    // wire vals
    while (line_it.next()) |line| {
        if (line.len == 0) break;

        const name = line[0..3].*;
        const val: u1 = @intCast(line[5] - '0');

        try table.put(name, .{ .val = val });
    }

    // gates
    while (line_it.next()) |line| {
        if (line.len == 0) break;

        const in0 = line[0..3].*;

        const op: Operator = switch (line[4]) {
            'A' => .@"and",
            'O' => .@"or",
            'X' => .xor,
            else => unreachable,
        };

        const i: usize = if (line[4] == 'O') 7 else 8;

        const in1 = line[i..][0..3].*;
        const out = line[i + 7 ..][0..3].*;

        try table.put(out, .{ .gate = .{
            .op = op,
            .in0 = in0,
            .in1 = in1,
        } });
    }

    var sum: u64 = 0;

    for (0..100) |i| {
        const name = [3]u8{
            'z',
            @intCast(i / 10 + '0'),
            @intCast(i % 10 + '0'),
        };

        if (!table.contains(name)) break;
        const v = try findWireValue(table, name);

        sum += @as(u64, @intCast(v)) << @intCast(i);
    }

    return sum;
}

test part1 {
    const ally = std.testing.allocator;

    const input1 =
        \\x00: 1
        \\x01: 1
        \\x02: 1
        \\y00: 0
        \\y01: 1
        \\y02: 0
        \\
        \\x00 AND y00 -> z00
        \\x01 XOR y01 -> z01
        \\x02 OR y02 -> z02
    ;

    try std.testing.expectEqual(part1(ally, input1), 4);

    const input2 =
        \\x00: 1
        \\x01: 0
        \\x02: 1
        \\x03: 1
        \\x04: 0
        \\y00: 1
        \\y01: 1
        \\y02: 1
        \\y03: 1
        \\y04: 1
        \\
        \\ntg XOR fgs -> mjb
        \\y02 OR x01 -> tnw
        \\kwq OR kpj -> z05
        \\x00 OR x03 -> fst
        \\tgd XOR rvg -> z01
        \\vdt OR tnw -> bfw
        \\bfw AND frj -> z10
        \\ffh OR nrd -> bqk
        \\y00 AND y03 -> djm
        \\y03 OR y00 -> psh
        \\bqk OR frj -> z08
        \\tnw OR fst -> frj
        \\gnj AND tgd -> z11
        \\bfw XOR mjb -> z00
        \\x03 OR x00 -> vdt
        \\gnj AND wpb -> z02
        \\x04 AND y00 -> kjc
        \\djm OR pbm -> qhw
        \\nrd AND vdt -> hwm
        \\kjc AND fst -> rvg
        \\y04 OR y02 -> fgs
        \\y01 AND x02 -> pbm
        \\ntg OR kjc -> kwq
        \\psh XOR fgs -> tgd
        \\qhw XOR tgd -> z09
        \\pbm OR djm -> kpj
        \\x03 XOR y03 -> ffh
        \\x00 XOR y04 -> ntg
        \\bfw OR bqk -> z06
        \\nrd XOR fgs -> wpb
        \\frj XOR qhw -> z04
        \\bqk OR frj -> z07
        \\y03 OR x01 -> nrd
        \\hwm AND bqk -> z03
        \\tgd XOR rvg -> z12
        \\tnw OR pbm -> gnj
    ;

    try std.testing.expectEqual(part1(ally, input2), 2024);
}

fn part2() void {
    // I was too dumb to come up with a code solution.

    // z05, tst
    // z11, sps
    // z23, frt
    // pmd, cgh

    // cgh,frt,pmd,sps,tst,z05,z11,z23
}

pub fn main() !void {
    const input = @embedFile("input");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    std.debug.print("{}\n", .{try part1(allocator, input)});
}
