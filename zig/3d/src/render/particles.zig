const std = @import("std");
const raylib = @import("../raylib.zig");
const rl = raylib.rl;

/// A single particle
pub const Particle = struct {
    position: rl.Vector3,
    velocity: rl.Vector3,
    color: rl.Color,
    lifetime: f32,
    max_lifetime: f32,
    size: f32,
    active: bool,
};

/// Particle system for atmospheric effects
pub const ParticleSystem = struct {
    particles: []Particle,
    allocator: std.mem.Allocator,
    max_particles: usize,
    spawn_rate: f32,
    spawn_accumulator: f32,

    pub fn init(allocator: std.mem.Allocator, max_particles: usize) !ParticleSystem {
        const particles = try allocator.alloc(Particle, max_particles);

        // Initialize all particles as inactive
        for (particles) |*particle| {
            particle.* = Particle{
                .position = .{ .x = 0.0, .y = 0.0, .z = 0.0 },
                .velocity = .{ .x = 0.0, .y = 0.0, .z = 0.0 },
                .color = rl.WHITE,
                .lifetime = 0.0,
                .max_lifetime = 1.0,
                .size = 0.1,
                .active = false,
            };
        }

        return ParticleSystem{
            .particles = particles,
            .allocator = allocator,
            .max_particles = max_particles,
            .spawn_rate = 5.0, // particles per second
            .spawn_accumulator = 0.0,
        };
    }

    pub fn deinit(self: *ParticleSystem) void {
        self.allocator.free(self.particles);
    }

    /// Update all particles
    pub fn update(self: *ParticleSystem, dt: f32, spawn_position: rl.Vector3, spawn_enabled: bool) void {
        // Update existing particles
        for (self.particles) |*particle| {
            if (!particle.active) continue;

            particle.lifetime -= dt;
            if (particle.lifetime <= 0.0) {
                particle.active = false;
                continue;
            }

            // Update position based on velocity
            particle.position.x += particle.velocity.x * dt;
            particle.position.y += particle.velocity.y * dt;
            particle.position.z += particle.velocity.z * dt;

            // Fade out as particle ages
            const life_ratio = particle.lifetime / particle.max_lifetime;
            particle.color.a = @intFromFloat(255.0 * life_ratio);
        }

        // Spawn new particles
        if (spawn_enabled) {
            self.spawn_accumulator += dt * self.spawn_rate;

            while (self.spawn_accumulator >= 1.0) {
                self.spawnParticle(spawn_position);
                self.spawn_accumulator -= 1.0;
            }
        }
    }

    /// Spawn a new particle at the given position
    fn spawnParticle(self: *ParticleSystem, position: rl.Vector3) void {
        // Find an inactive particle
        for (self.particles) |*particle| {
            if (particle.active) continue;

            // Random velocity
            const angle = std.crypto.random.float(f32) * std.math.pi * 2.0;
            const speed = 2.0 + std.crypto.random.float(f32) * 3.0;

            particle.* = Particle{
                .position = position,
                .velocity = .{
                    .x = @cos(angle) * speed,
                    .y = 2.0 + std.crypto.random.float(f32) * 2.0,
                    .z = @sin(angle) * speed,
                },
                .color = .{
                    .r = 200 + std.crypto.random.intRangeAtMost(u8, 0, 55),
                    .g = 220 + std.crypto.random.intRangeAtMost(u8, 0, 35),
                    .b = 255,
                    .a = 255,
                },
                .lifetime = 1.5 + std.crypto.random.float(f32) * 1.0,
                .max_lifetime = 2.5,
                .size = 0.05 + std.crypto.random.float(f32) * 0.1,
                .active = true,
            };
            return;
        }
    }

    /// Render all active particles
    pub fn render(self: *const ParticleSystem) void {
        for (self.particles) |particle| {
            if (!particle.active) continue;

            rl.DrawSphere(particle.position, particle.size, particle.color);
        }
    }

    /// Burst effect - spawn many particles at once
    pub fn burst(self: *ParticleSystem, position: rl.Vector3, count: usize) void {
        var spawned: usize = 0;
        for (self.particles) |*particle| {
            if (spawned >= count) break;
            if (particle.active) continue;

            const angle = std.crypto.random.float(f32) * std.math.pi * 2.0;
            const elevation = std.crypto.random.float(f32) * std.math.pi * 0.5;
            const speed = 3.0 + std.crypto.random.float(f32) * 5.0;

            particle.* = Particle{
                .position = position,
                .velocity = .{
                    .x = @cos(angle) * @cos(elevation) * speed,
                    .y = @sin(elevation) * speed,
                    .z = @sin(angle) * @cos(elevation) * speed,
                },
                .color = .{
                    .r = 150 + std.crypto.random.intRangeAtMost(u8, 0, 105),
                    .g = 200 + std.crypto.random.intRangeAtMost(u8, 0, 55),
                    .b = 100 + std.crypto.random.intRangeAtMost(u8, 0, 155),
                    .a = 255,
                },
                .lifetime = 0.5 + std.crypto.random.float(f32) * 1.5,
                .max_lifetime = 2.0,
                .size = 0.1 + std.crypto.random.float(f32) * 0.15,
                .active = true,
            };
            spawned += 1;
        }
    }
};
