const std = @import("std");
const raylib = @import("../raylib.zig");
const rl = raylib.rl;
const terrain = @import("terrain.zig");
const TerrainGenerator = terrain.TerrainGenerator;
const TerrainChunk = terrain.TerrainChunk;
const Planet = @import("../game/planet.zig").Planet;

/// Manages terrain chunks for a planet
pub const TerrainManager = struct {
    allocator: std.mem.Allocator,
    generator: TerrainGenerator,
    chunks: std.ArrayList(TerrainChunk),
    current_planet: ?*const Planet,

    // Chunk loading parameters
    view_distance: u32, // chunks in each direction
    chunk_size: u32,
    resolution: u32,

    pub fn init(allocator: std.mem.Allocator) !TerrainManager {
        return TerrainManager{
            .allocator = allocator,
            .generator = TerrainGenerator.init(32, 33), // 32x32 world units, 33x33 vertices
            .chunks = std.ArrayList(TerrainChunk).init(allocator),
            .current_planet = null,
            .view_distance = 2, // 2 chunks in each direction = 5x5 grid
            .chunk_size = 32,
            .resolution = 33,
        };
    }

    pub fn deinit(self: *TerrainManager) void {
        self.clearChunks();
        self.chunks.deinit();
    }

    /// Clear all loaded chunks
    pub fn clearChunks(self: *TerrainManager) void {
        for (self.chunks.items) |*chunk| {
            chunk.deinit();
        }
        self.chunks.clearRetainingCapacity();
    }

    /// Load chunks around player position
    pub fn loadChunksAroundPlayer(self: *TerrainManager, player_pos: rl.Vector3, planet: *const Planet) !void {
        // Clear existing chunks
        self.clearChunks();
        self.current_planet = planet;

        // Calculate which chunk the player is in
        const player_chunk_x = @as(i32, @intFromFloat(@floor(player_pos.x / @as(f32, @floatFromInt(self.chunk_size)))));
        const player_chunk_z = @as(i32, @intFromFloat(@floor(player_pos.z / @as(f32, @floatFromInt(self.chunk_size)))));

        // Load chunks in view distance
        const view = @as(i32, @intCast(self.view_distance));
        var z: i32 = player_chunk_z - view;
        while (z <= player_chunk_z + view) : (z += 1) {
            var x: i32 = player_chunk_x - view;
            while (x <= player_chunk_x + view) : (x += 1) {
                const chunk = try self.generator.generateChunk(self.allocator, x, z, planet);
                try self.chunks.append(chunk);
            }
        }
    }

    /// Render all loaded chunks
    pub fn render(self: *TerrainManager) void {
        for (self.chunks.items) |chunk| {
            if (chunk.allocated) {
                rl.DrawModel(chunk.model, chunk.position, 1.0, rl.WHITE);
            }
        }
    }

    /// Get terrain height at world position (for player collision)
    pub fn getHeightAtPosition(self: *TerrainManager, x: f32, z: f32) f32 {
        if (self.current_planet) |planet| {
            const noise = @import("../math/noise.zig");
            const height_01 = noise.terrainHeight(x, z, self.generator.seed);
            return height_01 * planet.terrain_height;
        }
        return 0.0;
    }
};
