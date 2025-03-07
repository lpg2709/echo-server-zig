const std = @import("std");
const buildin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "tcp-server-zig",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    comptime {
        const zig_version = "0.14.0";
        const supported_zig = std.SemanticVersion.parse(zig_version) catch unreachable;
        if (buildin.zig_version.order(supported_zig) != .eq) {
            @compileError(std.fmt.comptimePrint("Unsupporded zig version ({}). Required Zig version '{s}'!", .{ buildin.zig_version, zig_version }));
        }
    }
}
