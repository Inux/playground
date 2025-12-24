const std = @import("std");
const raylib = @import("../raylib.zig");
const rl = raylib.rl;
const noise = @import("../math/noise.zig");
const Planet = @import("../game/planet.zig").Planet;
const LightingSystem = @import("lighting.zig").LightingSystem;

/// Terrain chunk for efficient rendering
pub const TerrainChunk = struct {
    mesh: rl.Mesh,
    model: rl.Model,
    position: rl.Vector3,
    size: u32,
    allocated: bool,

    pub fn init() TerrainChunk {
        return TerrainChunk{
            .mesh = undefined,
            .model = undefined,
            .position = .{ .x = 0, .y = 0, .z = 0 },
            .size = 0,
            .allocated = false,
        };
    }

    pub fn deinit(self: *TerrainChunk) void {
        if (self.allocated) {
            rl.UnloadModel(self.model);
            self.allocated = false;
        }
    }
};

/// Terrain generator
pub const TerrainGenerator = struct {
    chunk_size: u32,
    resolution: u32, // vertices per chunk dimension
    seed: u32,

    pub fn init(chunk_size: u32, resolution: u32) TerrainGenerator {
        return TerrainGenerator{
            .chunk_size = chunk_size,
            .resolution = resolution,
            .seed = 12345,
        };
    }

    /// Generate a heightmap for the given area
    pub fn generateHeightmap(
        self: *TerrainGenerator,
        allocator: std.mem.Allocator,
        start_x: f32,
        start_z: f32,
        planet: *const Planet,
    ) ![]f32 {
        const total_vertices = self.resolution * self.resolution;
        const heightmap = try allocator.alloc(f32, total_vertices);

        const step = @as(f32, @floatFromInt(self.chunk_size)) / @as(f32, @floatFromInt(self.resolution - 1));

        var z: u32 = 0;
        while (z < self.resolution) : (z += 1) {
            var x: u32 = 0;
            while (x < self.resolution) : (x += 1) {
                const world_x = start_x + @as(f32, @floatFromInt(x)) * step;
                const world_z = start_z + @as(f32, @floatFromInt(z)) * step;

                // Generate height using noise
                const height_01 = noise.terrainHeight(world_x, world_z, self.seed);

                // Scale by planet's terrain height
                const height = height_01 * planet.terrain_height;

                const index = z * self.resolution + x;
                heightmap[index] = height;
            }
        }

        return heightmap;
    }

    /// Calculate normal vector for a vertex
    fn calculateNormal(
        heightmap: []const f32,
        x: u32,
        z: u32,
        resolution: u32,
        step: f32,
    ) rl.Vector3 {
        const idx = z * resolution + x;

        // Get heights of neighboring vertices
        const h_center = heightmap[idx];

        const h_left = if (x > 0) heightmap[idx - 1] else h_center;
        const h_right = if (x < resolution - 1) heightmap[idx + 1] else h_center;
        const h_down = if (z > 0) heightmap[idx - resolution] else h_center;
        const h_up = if (z < resolution - 1) heightmap[idx + resolution] else h_center;

        // Calculate tangent vectors
        const dx = rl.Vector3{ .x = step * 2.0, .y = h_right - h_left, .z = 0.0 };
        const dz = rl.Vector3{ .x = 0.0, .y = h_up - h_down, .z = step * 2.0 };

        // Cross product for normal
        var normal = rl.Vector3{
            .x = dx.y * dz.z - dx.z * dz.y,
            .y = dx.z * dz.x - dx.x * dz.z,
            .z = dx.x * dz.y - dx.y * dz.x,
        };

        // Normalize
        const length = @sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z);
        if (length > 0.0001) {
            normal.x /= length;
            normal.y /= length;
            normal.z /= length;
        } else {
            normal = .{ .x = 0.0, .y = 1.0, .z = 0.0 };
        }

        return normal;
    }

    /// Generate mesh from heightmap
    pub fn generateMesh(
        self: *TerrainGenerator,
        allocator: std.mem.Allocator,
        heightmap: []const f32,
        start_x: f32,
        start_z: f32,
        planet: *const Planet,
        lighting: *const LightingSystem,
    ) !rl.Mesh {
        const step = @as(f32, @floatFromInt(self.chunk_size)) / @as(f32, @floatFromInt(self.resolution - 1));

        // Calculate mesh data sizes
        const vertex_count = self.resolution * self.resolution;
        const triangle_count = (self.resolution - 1) * (self.resolution - 1) * 2;

        // Allocate vertex data
        const vertices = try allocator.alloc(f32, vertex_count * 3);
        defer allocator.free(vertices);

        const normals = try allocator.alloc(f32, vertex_count * 3);
        defer allocator.free(normals);

        const texcoords = try allocator.alloc(f32, vertex_count * 2);
        defer allocator.free(texcoords);

        const colors = try allocator.alloc(u8, vertex_count * 4); // RGBA
        defer allocator.free(colors);

        const indices = try allocator.alloc(u16, triangle_count * 3);
        defer allocator.free(indices);

        // Generate vertices, normals, colors, and UVs
        var z: u32 = 0;
        while (z < self.resolution) : (z += 1) {
            var x: u32 = 0;
            while (x < self.resolution) : (x += 1) {
                const idx = z * self.resolution + x;
                const vert_idx = idx * 3;
                const uv_idx = idx * 2;
                const color_idx = idx * 4;

                const world_x = start_x + @as(f32, @floatFromInt(x)) * step;
                const world_z = start_z + @as(f32, @floatFromInt(z)) * step;
                const height = heightmap[idx];

                // Vertex position
                vertices[vert_idx + 0] = world_x;
                vertices[vert_idx + 1] = height;
                vertices[vert_idx + 2] = world_z;

                // Normal
                const normal = calculateNormal(heightmap, x, z, self.resolution, step);
                normals[vert_idx + 0] = normal.x;
                normals[vert_idx + 1] = normal.y;
                normals[vert_idx + 2] = normal.z;

                // Apply lighting to determine vertex color
                const position = rl.Vector3{ .x = world_x, .y = height, .z = world_z };
                const lit_color = lighting.applyLighting(planet.surface_color, normal, position);
                colors[color_idx + 0] = lit_color.r;
                colors[color_idx + 1] = lit_color.g;
                colors[color_idx + 2] = lit_color.b;
                colors[color_idx + 3] = lit_color.a;

                // UV coordinates
                texcoords[uv_idx + 0] = @as(f32, @floatFromInt(x)) / @as(f32, @floatFromInt(self.resolution - 1));
                texcoords[uv_idx + 1] = @as(f32, @floatFromInt(z)) / @as(f32, @floatFromInt(self.resolution - 1));
            }
        }

        // Generate indices for triangles
        var tri_idx: usize = 0;
        z = 0;
        while (z < self.resolution - 1) : (z += 1) {
            var x: u32 = 0;
            while (x < self.resolution - 1) : (x += 1) {
                const top_left = @as(u16, @intCast(z * self.resolution + x));
                const top_right = @as(u16, @intCast(z * self.resolution + x + 1));
                const bottom_left = @as(u16, @intCast((z + 1) * self.resolution + x));
                const bottom_right = @as(u16, @intCast((z + 1) * self.resolution + x + 1));

                // First triangle
                indices[tri_idx + 0] = top_left;
                indices[tri_idx + 1] = bottom_left;
                indices[tri_idx + 2] = top_right;

                // Second triangle
                indices[tri_idx + 3] = top_right;
                indices[tri_idx + 4] = bottom_left;
                indices[tri_idx + 5] = bottom_right;

                tri_idx += 6;
            }
        }

        // Create mesh
        var mesh: rl.Mesh = undefined;
        mesh.vertexCount = @intCast(vertex_count);
        mesh.triangleCount = @intCast(triangle_count);

        // Allocate mesh data (raylib will manage this memory)
        mesh.vertices = @ptrCast(@alignCast(rl.MemAlloc(@intCast(vertex_count * 3 * @sizeOf(f32)))));
        mesh.normals = @ptrCast(@alignCast(rl.MemAlloc(@intCast(vertex_count * 3 * @sizeOf(f32)))));
        mesh.texcoords = @ptrCast(@alignCast(rl.MemAlloc(@intCast(vertex_count * 2 * @sizeOf(f32)))));
        mesh.colors = @ptrCast(@alignCast(rl.MemAlloc(@intCast(vertex_count * 4 * @sizeOf(u8)))));
        mesh.indices = @ptrCast(@alignCast(rl.MemAlloc(@intCast(triangle_count * 3 * @sizeOf(u16)))));

        // Copy data to mesh
        @memcpy(mesh.vertices[0 .. vertex_count * 3], vertices);
        @memcpy(mesh.normals[0 .. vertex_count * 3], normals);
        @memcpy(mesh.texcoords[0 .. vertex_count * 2], texcoords);
        @memcpy(mesh.colors[0 .. vertex_count * 4], colors);
        @memcpy(mesh.indices[0 .. triangle_count * 3], indices);

        // Note: Don't upload mesh here - LoadModelFromMesh will do it
        return mesh;
    }

    /// Generate a terrain chunk
    pub fn generateChunk(
        self: *TerrainGenerator,
        allocator: std.mem.Allocator,
        chunk_x: i32,
        chunk_z: i32,
        planet: *const Planet,
        lighting: *const LightingSystem,
    ) !TerrainChunk {
        const start_x = @as(f32, @floatFromInt(chunk_x)) * @as(f32, @floatFromInt(self.chunk_size));
        const start_z = @as(f32, @floatFromInt(chunk_z)) * @as(f32, @floatFromInt(self.chunk_size));

        // Generate heightmap
        const heightmap = try self.generateHeightmap(allocator, start_x, start_z, planet);
        defer allocator.free(heightmap);

        // Generate mesh with lighting
        const mesh = try self.generateMesh(allocator, heightmap, start_x, start_z, planet, lighting);

        // Create model from mesh
        const model = rl.LoadModelFromMesh(mesh);

        // Set material color
        model.materials[0].maps[rl.MATERIAL_MAP_DIFFUSE].color = planet.surface_color;

        var chunk = TerrainChunk.init();
        chunk.mesh = mesh;
        chunk.model = model;
        chunk.position = .{ .x = start_x, .y = 0.0, .z = start_z };
        chunk.size = self.chunk_size;
        chunk.allocated = true;

        return chunk;
    }
};
