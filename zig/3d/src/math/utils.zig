const std = @import("std");
const raylib = @import("../raylib.zig");
const rl = raylib.rl;

// === Constants ===

pub const PI = std.math.pi;
pub const TAU = std.math.tau;

// Camera constants
pub const SOLAR_VIEW_CAMERA_HEIGHT: f32 = 30.0;
pub const SOLAR_VIEW_CAMERA_DISTANCE: f32 = 60.0;
pub const SOLAR_VIEW_ROTATION_SPEED: f32 = 0.2;

// Planet constants
pub const SUN_RADIUS: f32 = 3.0;
pub const ORBIT_SPEED_MULTIPLIER: f32 = 0.1;

// Terrain constants
pub const TERRAIN_GRID_SIZE: i32 = 50;
pub const TERRAIN_CELL_SIZE: f32 = 2.0;
pub const TERRAIN_CUBE_SIZE: f32 = 0.8;
pub const TERRAIN_CUBE_HEIGHT: f32 = 0.1;

// Player constants
pub const PLAYER_HEIGHT_OFFSET: f32 = 1.5;
pub const PLAYER_MOVE_SPEED: f32 = 5.0;
pub const PLAYER_TURN_SPEED: f32 = 2.0;

// Screen constants
pub const SCREEN_WIDTH: i32 = 1280;
pub const SCREEN_HEIGHT: i32 = 720;
pub const TARGET_FPS: i32 = 60;

// === Math Utilities ===

/// Linearly interpolate between two f32 values
pub fn lerp(a: f32, b: f32, t: f32) f32 {
    return a + (b - a) * t;
}

/// Linearly interpolate between two Vector3 values
pub fn lerpVector3(a: rl.Vector3, b: rl.Vector3, t: f32) rl.Vector3 {
    return rl.Vector3{
        .x = lerp(a.x, b.x, t),
        .y = lerp(a.y, b.y, t),
        .z = lerp(a.z, b.z, t),
    };
}

/// Ease-in-out cubic interpolation (smooth transitions)
pub fn smoothstep(t: f32) f32 {
    const clamped = @max(0.0, @min(1.0, t));
    return clamped * clamped * (3.0 - 2.0 * clamped);
}

/// Ease-out cubic (fast start, slow end)
pub fn easeOut(t: f32) f32 {
    const inv = 1.0 - t;
    return 1.0 - (inv * inv * inv);
}

/// Ease-in cubic (slow start, fast end)
pub fn easeIn(t: f32) f32 {
    return t * t * t;
}

/// Clamp a value between min and max
pub fn clamp(value: f32, min: f32, max: f32) f32 {
    return @max(min, @min(max, value));
}

/// Clamp a value between 0 and 1
pub fn clamp01(value: f32) f32 {
    return clamp(value, 0.0, 1.0);
}

/// Calculate distance between two 3D points
pub fn distance3D(a: rl.Vector3, b: rl.Vector3) f32 {
    const dx = b.x - a.x;
    const dy = b.y - a.y;
    const dz = b.z - a.z;
    return @sqrt(dx * dx + dy * dy + dz * dz);
}

/// Normalize an angle to [0, TAU)
pub fn normalizeAngle(angle: f32) f32 {
    var result = @mod(angle, TAU);
    if (result < 0.0) result += TAU;
    return result;
}

/// Calculate terrain height at a position using sine/cosine waves
pub fn calculateTerrainHeight(x: f32, z: f32, amplitude: f32) f32 {
    return amplitude * (@sin(x * 0.5) * @cos(z * 0.5) + 1.0) * 0.5;
}

/// Safely convert and clamp a float to u8 (0-255)
pub fn floatToU8(value: f32) u8 {
    const clamped = clamp(value, 0.0, 255.0);
    return @as(u8, @intFromFloat(clamped));
}

/// Add brightness to a color channel safely
pub fn addBrightness(channel: u8, brightness: u8) u8 {
    return @as(u8, @min(255, @as(u16, channel) + @as(u16, brightness)));
}

/// Calculate color with height-based brightness
pub fn calculateTerrainColor(base_color: rl.Color, height: f32, max_height: f32) rl.Color {
    // Calculate brightness (0-50) based on height
    const brightness_float = clamp(height / max_height * 50.0, 0.0, 50.0);
    const brightness = floatToU8(brightness_float);

    return rl.Color{
        .r = addBrightness(base_color.r, brightness),
        .g = addBrightness(base_color.g, brightness),
        .b = addBrightness(base_color.b, brightness),
        .a = base_color.a,
    };
}
