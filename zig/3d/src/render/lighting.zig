const std = @import("std");
const raylib = @import("../raylib.zig");
const rl = raylib.rl;

/// Simple lighting setup using raylib's default lighting
pub const LightingSystem = struct {
    sun_position: rl.Vector3,
    sun_color: rl.Color,
    ambient_intensity: f32,

    pub fn init() LightingSystem {
        return LightingSystem{
            .sun_position = rl.Vector3{ .x = 100.0, .y = 200.0, .z = 100.0 },
            .sun_color = rl.Color{ .r = 255, .g = 250, .b = 220, .a = 255 }, // Warm sunlight
            .ambient_intensity = 0.3, // 30% ambient light
        };
    }

    /// Draw a visual representation of the sun (for debugging/visuals)
    pub fn renderSun(self: *const LightingSystem) void {
        // Draw a small sphere to show where the sun is
        rl.DrawSphere(self.sun_position, 5.0, self.sun_color);

        // Draw rays/glow effect
        rl.DrawSphereWires(self.sun_position, 6.0, 8, 8, rl.Color{ .r = 255, .g = 255, .b = 200, .a = 100 });
        rl.DrawSphereWires(self.sun_position, 7.0, 8, 8, rl.Color{ .r = 255, .g = 255, .b = 150, .a = 50 });
    }

    /// Get the direction from a point to the sun (for manual lighting calculations)
    pub fn getSunDirection(self: *const LightingSystem, from: rl.Vector3) rl.Vector3 {
        const dx = self.sun_position.x - from.x;
        const dy = self.sun_position.y - from.y;
        const dz = self.sun_position.z - from.z;
        const length = @sqrt(dx * dx + dy * dy + dz * dz);

        if (length > 0.0001) {
            return rl.Vector3{
                .x = dx / length,
                .y = dy / length,
                .z = dz / length,
            };
        }
        return rl.Vector3{ .x = 0.0, .y = 1.0, .z = 0.0 };
    }

    /// Calculate simple diffuse lighting for a color
    pub fn applyLighting(self: *const LightingSystem, base_color: rl.Color, normal: rl.Vector3, position: rl.Vector3) rl.Color {
        const sun_dir = self.getSunDirection(position);

        // Dot product for diffuse lighting
        const diffuse = @max(0.0, normal.x * sun_dir.x + normal.y * sun_dir.y + normal.z * sun_dir.z);

        // Combine ambient and diffuse
        const light_intensity = self.ambient_intensity + diffuse * (1.0 - self.ambient_intensity);

        return rl.Color{
            .r = @intFromFloat(@min(255.0, @as(f32, @floatFromInt(base_color.r)) * light_intensity)),
            .g = @intFromFloat(@min(255.0, @as(f32, @floatFromInt(base_color.g)) * light_intensity)),
            .b = @intFromFloat(@min(255.0, @as(f32, @floatFromInt(base_color.b)) * light_intensity)),
            .a = base_color.a,
        };
    }
};
