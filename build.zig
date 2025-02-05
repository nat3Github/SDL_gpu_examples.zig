// © 2024 Carl Åstholm
// SPDX-License-Identifier: MIT

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    // steps
    const run_step = b.step("run", "Run the game");

    // dep
    const sdl_dep = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });
    const sdl_lib = sdl_dep.artifact("SDL3");

    // executable
    const exe = b.addExecutable(.{
        .name = "gpu example one",
        .target = target,
        .optimize = optimize,
    });
    exe.addCSourceFiles(.{
        .files = &.{
            "Examples/main.c",
            "Examples/BasicTriangle.c",
            "Examples/Common.c",
            "Examples/ClearScreen.c",
            "Examples/ClearScreenMultiWindow.c",
            "Examples/BasicVertexBuffer.c",
            "Examples/CullMode.c",
            "Examples/BasicStencil.c",
            "Examples/InstancedIndexed.c",
            "Examples/TexturedQuad.c",
            "Examples/TexturedAnimatedQuad.c",
            "Examples/Clear3DSlice.c",
            "Examples/BasicCompute.c",
            "Examples/ComputeUniforms.c",
            "Examples/ToneMapping.c",
            "Examples/CustomSampling.c",
            "Examples/DrawIndirect.c",
            "Examples/ComputeSampler.c",
            "Examples/CopyAndReadback.c",
            "Examples/CopyConsistency.c",
            "Examples/Texture2DArray.c",
            "Examples/TriangleMSAA.c",
            "Examples/Cubemap.c",
            "Examples/WindowResize.c",
            "Examples/Blit2DArray.c",
            "Examples/BlitCube.c",
            "Examples/BlitMirror.c",
            "Examples/GenerateMipmaps.c",
            "Examples/ASTC.c",
            "Examples/Latency.c",
            "Examples/DepthSampler.c",
            "Examples/ComputeSpriteBatch.c",
            "Examples/PullSpriteBatch.c",
        },
    });
    exe.root_module.linkLibrary(sdl_lib);
    b.installArtifact(exe);

    const cp_assets = b.addInstallDirectory(.{
        .source_dir = b.path("Content"),
        .install_dir = .{ .prefix = {} },
        .install_subdir = "bin/Content",
    });
    b.getInstallStep().dependOn(&cp_assets.step);

    const run_exe = b.addRunArtifact(exe);
    run_exe.step.dependOn(b.getInstallStep());

    run_step.dependOn(&run_exe.step);
}
