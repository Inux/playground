const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create root module
    const root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .strip = false,
    });

    // Add system raylib headers - using LazyPath for absolute paths
    root_module.addIncludePath(.{ .cwd_relative = "/opt/homebrew/include" });
    root_module.addLibraryPath(.{ .cwd_relative = "/opt/homebrew/lib" });
    root_module.link_libc = true;
    root_module.linkSystemLibrary("raylib", .{});

    // Create executable
    const exe = b.addExecutable(.{
        .name = "solar-system",
        .root_module = root_module,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the solar system explorer");
    run_step.dependOn(&run_cmd.step);

    // Add test step
    const test_module = b.createModule(.{
        .root_source_file = b.path("src/test_core.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Add raylib paths to test module
    test_module.addIncludePath(.{ .cwd_relative = "/opt/homebrew/include" });
    test_module.addLibraryPath(.{ .cwd_relative = "/opt/homebrew/lib" });
    test_module.link_libc = true;
    test_module.linkSystemLibrary("raylib", .{});

    const test_exe = b.addTest(.{
        .root_module = test_module,
    });

    const run_test = b.addRunArtifact(test_exe);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_test.step);
}
