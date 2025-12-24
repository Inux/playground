const std = @import("std");

/// Simple Perlin-like noise implementation for terrain generation
/// This is a basic implementation - can be replaced with more sophisticated noise later

/// Hash function for pseudo-random values
fn hash(x: i32, y: i32) f32 {
    var h = @as(u32, @bitCast(x *% 374761393 +% y *% 668265263));
    h = (h ^ (h >> 13)) *% 1274126177;
    h = h ^ (h >> 16);
    return @as(f32, @floatFromInt(h & 0xFFFFFF)) / 16777216.0;
}

/// Smooth interpolation
fn smoothstep(t: f32) f32 {
    return t * t * (3.0 - 2.0 * t);
}

/// Bilinear interpolation
fn lerp(a: f32, b: f32, t: f32) f32 {
    return a + (b - a) * t;
}

/// 2D Perlin-like noise function
/// Returns value between -1.0 and 1.0
pub fn noise2D(x: f32, y: f32) f32 {
    const x0 = @as(i32, @intFromFloat(@floor(x)));
    const y0 = @as(i32, @intFromFloat(@floor(y)));
    const x1 = x0 + 1;
    const y1 = y0 + 1;

    const fx = x - @as(f32, @floatFromInt(x0));
    const fy = y - @as(f32, @floatFromInt(y0));

    const sx = smoothstep(fx);
    const sy = smoothstep(fy);

    const n00 = hash(x0, y0);
    const n10 = hash(x1, y0);
    const n01 = hash(x0, y1);
    const n11 = hash(x1, y1);

    const nx0 = lerp(n00, n10, sx);
    const nx1 = lerp(n01, n11, sx);

    return lerp(nx0, nx1, sy) * 2.0 - 1.0;
}

/// Fractional Brownian Motion (fBm) - layered noise for natural terrain
/// Returns value between -1.0 and 1.0
pub fn fbm(x: f32, y: f32, octaves: u32, persistence: f32, lacunarity: f32) f32 {
    var total: f32 = 0.0;
    var frequency: f32 = 1.0;
    var amplitude: f32 = 1.0;
    var max_value: f32 = 0.0;

    var i: u32 = 0;
    while (i < octaves) : (i += 1) {
        total += noise2D(x * frequency, y * frequency) * amplitude;
        max_value += amplitude;
        amplitude *= persistence;
        frequency *= lacunarity;
    }

    return total / max_value;
}

/// Generate terrain height at a position
/// Returns height value suitable for terrain (0.0 - 1.0 range, can be scaled)
pub fn terrainHeight(x: f32, z: f32, seed: u32) f32 {
    const offset_x = @as(f32, @floatFromInt(seed % 10000));
    const offset_z = @as(f32, @floatFromInt((seed / 10000) % 10000));

    // Base terrain with multiple octaves
    const scale: f32 = 0.05; // Larger scale = smoother terrain
    const base = fbm(
        (x + offset_x) * scale,
        (z + offset_z) * scale,
        4, // octaves
        0.5, // persistence
        2.0, // lacunarity
    );

    // Add some fine detail
    const detail_scale: f32 = 0.2;
    const detail = fbm(
        (x + offset_x) * detail_scale,
        (z + offset_z) * detail_scale,
        2,
        0.3,
        2.5,
    );

    // Combine base and detail, normalize to 0-1
    const result = (base * 0.8 + detail * 0.2 + 1.0) * 0.5;

    // Safety: clamp to valid range
    return @max(0.0, @min(1.0, result));
}

/// Generate height with biome-specific characteristics
pub fn biomeTerrainHeight(x: f32, z: f32, seed: u32, roughness: f32, elevation: f32) f32 {
    const offset_x = @as(f32, @floatFromInt(seed % 10000));
    const offset_z = @as(f32, @floatFromInt((seed / 10000) % 10000));

    const scale: f32 = 0.05 / roughness;
    const octaves = @as(u32, @intFromFloat(3.0 + roughness * 2.0));

    const height = fbm(
        (x + offset_x) * scale,
        (z + offset_z) * scale,
        octaves,
        0.5,
        2.0,
    );

    // Apply elevation offset and normalize
    return @max(0.0, @min(1.0, (height + 1.0) * 0.5 + elevation));
}
