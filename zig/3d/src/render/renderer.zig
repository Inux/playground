const std = @import("std");
const raylib = @import("../raylib.zig");
const rl = raylib.rl;
const Planet = @import("../game/planet.zig").Planet;
const math = @import("../math/utils.zig");

/// Render the solar system view (sun and orbiting planets)
pub fn renderSolarSystem(planets: []Planet) void {
    // Draw sun
    rl.DrawSphere(.{ .x = 0.0, .y = 0.0, .z = 0.0 }, math.SUN_RADIUS, rl.YELLOW);
    rl.DrawSphereWires(.{ .x = 0.0, .y = 0.0, .z = 0.0 }, math.SUN_RADIUS, 16, 16, rl.GOLD);

    // Draw planets and their orbits
    for (planets) |planet| {
        // Draw orbit path
        rl.DrawCircle3D(
            .{ .x = 0.0, .y = 0.0, .z = 0.0 },
            planet.orbit_radius,
            .{ .x = 1.0, .y = 0.0, .z = 0.0 },
            90.0,
            .{ .r = 50, .g = 50, .b = 50, .a = 100 },
        );

        // Get planet position
        const planet_pos = planet.getPosition();

        // Draw planet
        rl.DrawSphere(planet_pos, planet.size, planet.color);
        rl.DrawSphereWires(planet_pos, planet.size, 8, 8, rl.WHITE);
    }
}

/// Render planet surface (terrain)
pub fn renderPlanetSurface(planet: *const Planet, player_pos: rl.Vector3) void {
    // Draw terrain grid
    var x: i32 = -math.TERRAIN_GRID_SIZE;

    while (x <= math.TERRAIN_GRID_SIZE) : (x += 1) {
        var z: i32 = -math.TERRAIN_GRID_SIZE;
        while (z <= math.TERRAIN_GRID_SIZE) : (z += 1) {
            const fx = @as(f32, @floatFromInt(x)) * math.TERRAIN_CELL_SIZE;
            const fz = @as(f32, @floatFromInt(z)) * math.TERRAIN_CELL_SIZE;

            // Calculate height
            const height = math.calculateTerrainHeight(fx, fz, planet.terrain_height);

            const pos = rl.Vector3{ .x = fx, .y = height, .z = fz };

            // Color variation based on height
            const tile_color = math.calculateTerrainColor(
                planet.surface_color,
                height,
                planet.terrain_height,
            );

            // Draw terrain cube
            rl.DrawCube(pos, math.TERRAIN_CUBE_SIZE, math.TERRAIN_CUBE_HEIGHT, math.TERRAIN_CUBE_SIZE, tile_color);
            rl.DrawCubeWires(pos, math.TERRAIN_CUBE_SIZE, math.TERRAIN_CUBE_HEIGHT, math.TERRAIN_CUBE_SIZE, .{ .r = 0, .g = 0, .b = 0, .a = 50 });
        }
    }

    // Draw sky (large sphere below horizon)
    rl.DrawSphere(.{ .x = player_pos.x, .y = -1000.0, .z = player_pos.z }, 900.0, planet.color);
}

/// Render UI for solar system view
pub fn renderSolarSystemUI() void {
    rl.DrawText("Click on a planet to visit its surface", 10, 10, 20, rl.WHITE);
    rl.DrawText("Built with Zig + raylib (C library)", 10, 40, 16, rl.LIGHTGRAY);
    rl.DrawText("STELLAR HARVEST - AAA Development In Progress", 10, 70, 14, rl.GREEN);
}

/// Render UI for planet surface view
pub fn renderPlanetSurfaceUI(planet_name: [*:0]const u8) void {
    var buffer: [128]u8 = undefined;
    const text = std.fmt.bufPrintZ(&buffer, "On {s} - Press ESC to return to solar system", .{planet_name}) catch "Surface";
    rl.DrawText(text, 10, 10, 20, rl.WHITE);
    rl.DrawText("WASD to move | Mouse to look around (WIP)", 10, 40, 16, rl.LIGHTGRAY);
}

/// Render FPS counter
pub fn renderFPS() void {
    rl.DrawFPS(10, math.SCREEN_HEIGHT - 30);
}
