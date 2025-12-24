const std = @import("std");
const testing = std.testing;
const noise = @import("math/noise.zig");
const math = @import("math/utils.zig");

// Test noise generation
test "noise2D returns values in valid range" {
    var i: f32 = -10.0;
    while (i < 10.0) : (i += 0.5) {
        var j: f32 = -10.0;
        while (j < 10.0) : (j += 0.5) {
            const value = noise.noise2D(i, j);
            try testing.expect(value >= -1.0 and value <= 1.0);
        }
    }
}

test "terrainHeight returns normalized values" {
    const seed: u32 = 12345;
    var x: f32 = -100.0;
    while (x < 100.0) : (x += 5.0) {
        var z: f32 = -100.0;
        while (z < 100.0) : (z += 5.0) {
            const height = noise.terrainHeight(x, z, seed);
            try testing.expect(height >= 0.0 and height <= 1.0);
            try testing.expect(!std.math.isNan(height));
            try testing.expect(!std.math.isInf(height));
        }
    }
}

test "fbm returns bounded values" {
    var x: f32 = 0.0;
    while (x < 10.0) : (x += 1.0) {
        var y: f32 = 0.0;
        while (y < 10.0) : (y += 1.0) {
            const value = noise.fbm(x, y, 4, 0.5, 2.0);
            try testing.expect(value >= -1.0 and value <= 1.0);
            try testing.expect(!std.math.isNan(value));
        }
    }
}

// Test math utilities
test "lerp interpolates correctly" {
    try testing.expectApproxEqAbs(@as(f32, 0.0), math.lerp(0.0, 10.0, 0.0), 0.001);
    try testing.expectApproxEqAbs(@as(f32, 10.0), math.lerp(0.0, 10.0, 1.0), 0.001);
    try testing.expectApproxEqAbs(@as(f32, 5.0), math.lerp(0.0, 10.0, 0.5), 0.001);
}

test "smoothstep produces smooth curve" {
    try testing.expectApproxEqAbs(@as(f32, 0.0), math.smoothstep(0.0), 0.001);
    try testing.expectApproxEqAbs(@as(f32, 1.0), math.smoothstep(1.0), 0.001);
    const mid = math.smoothstep(0.5);
    try testing.expect(mid > 0.4 and mid < 0.6);
}

test "clamp works correctly" {
    try testing.expectApproxEqAbs(@as(f32, 0.0), math.clamp(-5.0, 0.0, 10.0), 0.001);
    try testing.expectApproxEqAbs(@as(f32, 10.0), math.clamp(15.0, 0.0, 10.0), 0.001);
    try testing.expectApproxEqAbs(@as(f32, 5.0), math.clamp(5.0, 0.0, 10.0), 0.001);
}

test "distance3D calculates correctly" {
    const raylib = @import("raylib.zig");
    const rl = raylib.rl;

    const p1 = rl.Vector3{ .x = 0.0, .y = 0.0, .z = 0.0 };
    const p2 = rl.Vector3{ .x = 3.0, .y = 4.0, .z = 0.0 };
    const dist = math.distance3D(p1, p2);
    try testing.expectApproxEqAbs(@as(f32, 5.0), dist, 0.001);
}

test "floatToU8 converts safely" {
    try testing.expectEqual(@as(u8, 0), math.floatToU8(-10.0));
    try testing.expectEqual(@as(u8, 255), math.floatToU8(300.0));
    try testing.expectEqual(@as(u8, 128), math.floatToU8(128.0));
}

test "addBrightness doesn't overflow" {
    try testing.expectEqual(@as(u8, 255), math.addBrightness(200, 100));
    try testing.expectEqual(@as(u8, 150), math.addBrightness(100, 50));
    try testing.expectEqual(@as(u8, 0), math.addBrightness(0, 0));
}
