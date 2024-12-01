const std = @import("std");

pub fn build(b: *std.Build) void {
    const day = b.option(u8, "day", "day number") orelse 1;
    buildDay(b, day);
}

pub fn buildDay(b: *std.Build, day: u8) void {
    const day_str = b.fmt("day{:0>2}", .{day});
    const src_path = b.fmt("{s}/main.zig", .{day_str});

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = day_str,
        .root_source_file = b.path(src_path),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run.step);

    const unit_tests = b.addTest(.{
        .root_source_file = b.path(src_path),
        .target = target,
    });

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&unit_tests.step);
}
