const std = @import("std");
const raylib = @import("../raylib.zig");
const rl = raylib.rl;
const resources = @import("resources.zig");
const ResourcePool = resources.ResourcePool;

/// Planet data structure
pub const Planet = struct {
    name: [*:0]const u8,
    orbit_radius: f32,
    size: f32,
    color: rl.Color,
    orbit_speed: f32,
    angle: f32,
    surface_color: rl.Color,
    terrain_height: f32,
    resources: ResourcePool,

    /// Update planet's orbital position and ecosystem
    pub fn update(self: *Planet, dt: f32, speed_multiplier: f32) void {
        self.angle += self.orbit_speed * dt * speed_multiplier;

        // Update ecosystem dynamics
        resources.ResourceDependencies.updateEcosystem(&self.resources, dt);
    }

    /// Get planet's 3D position in orbit
    pub fn getPosition(self: *const Planet) rl.Vector3 {
        return rl.Vector3{
            .x = @cos(self.angle) * self.orbit_radius,
            .y = 0.0,
            .z = @sin(self.angle) * self.orbit_radius,
        };
    }

    /// Check if a ray intersects this planet (for mouse picking)
    pub fn rayIntersects(self: *const Planet, ray: rl.Ray) ?f32 {
        const pos = self.getPosition();
        const collision = rl.GetRayCollisionSphere(ray, pos, self.size);
        if (collision.hit) {
            return collision.distance;
        }
        return null;
    }
};

/// Our solar system planets
pub fn getSolarSystem() [8]Planet {
    return [_]Planet{
        .{
            .name = "Mercury",
            .orbit_radius = 8.0,
            .size = 0.4,
            .color = rl.GRAY,
            .orbit_speed = 4.0,
            .angle = 0.0,
            .surface_color = .{ .r = 169, .g = 169, .b = 169, .a = 255 },
            .terrain_height = 0.3,
            .resources = ResourcePool.init(),
        },
        .{
            .name = "Venus",
            .orbit_radius = 12.0,
            .size = 0.9,
            .color = rl.ORANGE,
            .orbit_speed = 3.0,
            .angle = 0.0,
            .surface_color = .{ .r = 255, .g = 198, .b = 73, .a = 255 },
            .terrain_height = 0.4,
            .resources = ResourcePool.init(),
        },
        .{
            .name = "Earth",
            .orbit_radius = 16.0,
            .size = 1.0,
            .color = rl.BLUE,
            .orbit_speed = 2.5,
            .angle = 0.0,
            .surface_color = .{ .r = 34, .g = 139, .b = 34, .a = 255 },
            .terrain_height = 0.8,
            .resources = ResourcePool.init(),
        },
        .{
            .name = "Mars",
            .orbit_radius = 20.0,
            .size = 0.7,
            .color = rl.RED,
            .orbit_speed = 2.0,
            .angle = 0.0,
            .surface_color = .{ .r = 193, .g = 68, .b = 14, .a = 255 },
            .terrain_height = 0.5,
            .resources = ResourcePool.init(),
        },
        .{
            .name = "Jupiter",
            .orbit_radius = 28.0,
            .size = 2.5,
            .color = .{ .r = 194, .g = 178, .b = 128, .a = 255 },
            .orbit_speed = 1.0,
            .angle = 0.0,
            .surface_color = .{ .r = 194, .g = 178, .b = 128, .a = 255 },
            .terrain_height = 0.2,
            .resources = ResourcePool.init(),
        },
        .{
            .name = "Saturn",
            .orbit_radius = 36.0,
            .size = 2.0,
            .color = .{ .r = 238, .g = 221, .b = 130, .a = 255 },
            .orbit_speed = 0.8,
            .angle = 0.0,
            .surface_color = .{ .r = 238, .g = 221, .b = 130, .a = 255 },
            .terrain_height = 0.2,
            .resources = ResourcePool.init(),
        },
        .{
            .name = "Uranus",
            .orbit_radius = 44.0,
            .size = 1.6,
            .color = .{ .r = 79, .g = 208, .b = 231, .a = 255 },
            .orbit_speed = 0.6,
            .angle = 0.0,
            .surface_color = .{ .r = 79, .g = 208, .b = 231, .a = 255 },
            .terrain_height = 0.3,
            .resources = ResourcePool.init(),
        },
        .{
            .name = "Neptune",
            .orbit_radius = 50.0,
            .size = 1.5,
            .color = .{ .r = 63, .g = 84, .b = 186, .a = 255 },
            .orbit_speed = 0.5,
            .angle = 0.0,
            .surface_color = .{ .r = 63, .g = 84, .b = 186, .a = 255 },
            .terrain_height = 0.3,
            .resources = ResourcePool.init(),
        },
    };
}
