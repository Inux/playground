const std = @import("std");
const raylib = @import("../raylib.zig");
const rl = raylib.rl;
const Planet = @import("../game/planet.zig").Planet;

/// Skybox renderer for planet surfaces
pub const Skybox = struct {
    model: rl.Model,
    shader: rl.Shader,
    use_shader: bool,

    pub fn init() Skybox {
        // Create a large cube for the skybox
        const mesh = rl.GenMeshCube(1.0, 1.0, 1.0);
        const model = rl.LoadModelFromMesh(mesh);

        return Skybox{
            .model = model,
            .shader = undefined,
            .use_shader = false,
        };
    }

    pub fn deinit(self: *Skybox) void {
        rl.UnloadModel(self.model);
        if (self.use_shader) {
            rl.UnloadShader(self.shader);
        }
    }

    /// Render skybox centered on camera position
    pub fn render(self: *const Skybox, camera_pos: rl.Vector3, planet: *const Planet) void {
        // Create gradient effect by drawing sphere instead for now
        // (proper skybox would use cubemap textures)
        self.renderGradientSky(camera_pos, planet);
    }

    /// Render gradient sky (simpler approach without cubemap textures)
    fn renderGradientSky(self: *const Skybox, camera_pos: rl.Vector3, planet: *const Planet) void {
        _ = self;

        // Calculate sky colors based on planet atmosphere
        const horizon_color = planet.color;

        // Lighter color for zenith (top of sky) - use saturating arithmetic
        const zenith_color = rl.Color{
            .r = @intCast(@min(255, @as(u16, horizon_color.r) + 50)),
            .g = @intCast(@min(255, @as(u16, horizon_color.g) + 50)),
            .b = @intCast(@min(255, @as(u16, horizon_color.b) + 80)),
            .a = 255,
        };

        // Draw large sphere below for ground reflection
        rl.DrawSphere(
            .{ .x = camera_pos.x, .y = -900.0, .z = camera_pos.z },
            850.0,
            horizon_color,
        );

        // Draw hemisphere for sky with gradient
        const segments = 16;
        const rings = 8;

        // Draw sky dome
        var ring: i32 = 0;
        while (ring < rings) : (ring += 1) {
            const angle1 = @as(f32, @floatFromInt(ring)) * std.math.pi / @as(f32, @floatFromInt(rings * 2));
            const angle2 = @as(f32, @floatFromInt(ring + 1)) * std.math.pi / @as(f32, @floatFromInt(rings * 2));

            const y1 = @cos(angle1) * 900.0;
            const y2 = @cos(angle2) * 900.0;
            const r1 = @sin(angle1) * 900.0;
            const r2 = @sin(angle2) * 900.0;

            // Interpolate color from horizon to zenith
            const t1 = @as(f32, @floatFromInt(ring)) / @as(f32, @floatFromInt(rings));
            const t2 = @as(f32, @floatFromInt(ring + 1)) / @as(f32, @floatFromInt(rings));

            const color1 = lerpColor(horizon_color, zenith_color, t1);
            const color2 = lerpColor(horizon_color, zenith_color, t2);

            var segment: i32 = 0;
            while (segment < segments) : (segment += 1) {
                const theta1 = @as(f32, @floatFromInt(segment)) * 2.0 * std.math.pi / @as(f32, @floatFromInt(segments));
                const theta2 = @as(f32, @floatFromInt(segment + 1)) * 2.0 * std.math.pi / @as(f32, @floatFromInt(segments));

                const x1 = @cos(theta1);
                const z1 = @sin(theta1);
                const x2 = @cos(theta2);
                const z2 = @sin(theta2);

                const v1 = rl.Vector3{
                    .x = camera_pos.x + x1 * r1,
                    .y = camera_pos.y + y1,
                    .z = camera_pos.z + z1 * r1,
                };
                const v2 = rl.Vector3{
                    .x = camera_pos.x + x2 * r1,
                    .y = camera_pos.y + y1,
                    .z = camera_pos.z + z2 * r1,
                };
                const v3 = rl.Vector3{
                    .x = camera_pos.x + x2 * r2,
                    .y = camera_pos.y + y2,
                    .z = camera_pos.z + z2 * r2,
                };
                const v4 = rl.Vector3{
                    .x = camera_pos.x + x1 * r2,
                    .y = camera_pos.y + y2,
                    .z = camera_pos.z + z1 * r2,
                };

                // Draw quad as two triangles
                rl.DrawTriangle3D(v1, v2, v3, color1);
                rl.DrawTriangle3D(v1, v3, v4, color2);
            }
        }
    }

    /// Linear interpolation between two colors
    fn lerpColor(a: rl.Color, b: rl.Color, t: f32) rl.Color {
        return rl.Color{
            .r = @intFromFloat(@as(f32, @floatFromInt(a.r)) + (@as(f32, @floatFromInt(b.r)) - @as(f32, @floatFromInt(a.r))) * t),
            .g = @intFromFloat(@as(f32, @floatFromInt(a.g)) + (@as(f32, @floatFromInt(b.g)) - @as(f32, @floatFromInt(a.g))) * t),
            .b = @intFromFloat(@as(f32, @floatFromInt(a.b)) + (@as(f32, @floatFromInt(b.b)) - @as(f32, @floatFromInt(a.b))) * t),
            .a = 255,
        };
    }
};
