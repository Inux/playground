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
}
