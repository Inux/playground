const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

const GameState = enum {
    solar_system,
    planet_surface,
};

const Planet = struct {
    name: [*:0]const u8,
    orbit_radius: f32,
    size: f32,
    color: rl.Color,
    orbit_speed: f32,
    angle: f32,
    surface_color: rl.Color,
    terrain_height: f32,
};

var planets = [_]Planet{
    .{ .name = "Mercury", .orbit_radius = 8.0, .size = 0.4, .color = rl.GRAY, .orbit_speed = 4.0, .angle = 0.0, .surface_color = .{ .r = 169, .g = 169, .b = 169, .a = 255 }, .terrain_height = 0.3 },
    .{ .name = "Venus", .orbit_radius = 12.0, .size = 0.9, .color = rl.ORANGE, .orbit_speed = 3.0, .angle = 0.0, .surface_color = .{ .r = 255, .g = 198, .b = 73, .a = 255 }, .terrain_height = 0.4 },
    .{ .name = "Earth", .orbit_radius = 16.0, .size = 1.0, .color = rl.BLUE, .orbit_speed = 2.5, .angle = 0.0, .surface_color = .{ .r = 34, .g = 139, .b = 34, .a = 255 }, .terrain_height = 0.8 },
    .{ .name = "Mars", .orbit_radius = 20.0, .size = 0.7, .color = rl.RED, .orbit_speed = 2.0, .angle = 0.0, .surface_color = .{ .r = 193, .g = 68, .b = 14, .a = 255 }, .terrain_height = 0.5 },
    .{ .name = "Jupiter", .orbit_radius = 28.0, .size = 2.5, .color = .{ .r = 194, .g = 178, .b = 128, .a = 255 }, .orbit_speed = 1.0, .angle = 0.0, .surface_color = .{ .r = 194, .g = 178, .b = 128, .a = 255 }, .terrain_height = 0.2 },
    .{ .name = "Saturn", .orbit_radius = 36.0, .size = 2.0, .color = .{ .r = 238, .g = 221, .b = 130, .a = 255 }, .orbit_speed = 0.8, .angle = 0.0, .surface_color = .{ .r = 238, .g = 221, .b = 130, .a = 255 }, .terrain_height = 0.2 },
    .{ .name = "Uranus", .orbit_radius = 44.0, .size = 1.6, .color = .{ .r = 79, .g = 208, .b = 231, .a = 255 }, .orbit_speed = 0.6, .angle = 0.0, .surface_color = .{ .r = 79, .g = 208, .b = 231, .a = 255 }, .terrain_height = 0.3 },
    .{ .name = "Neptune", .orbit_radius = 50.0, .size = 1.5, .color = .{ .r = 63, .g = 84, .b = 186, .a = 255 }, .orbit_speed = 0.5, .angle = 0.0, .surface_color = .{ .r = 63, .g = 84, .b = 186, .a = 255 }, .terrain_height = 0.3 },
};

var game_state: GameState = .solar_system;
var selected_planet: ?usize = null;
var transition_progress: f32 = 0.0;
var player_pos: rl.Vector3 = undefined;
var player_angle: f32 = 0.0;

pub fn main() !void {
    const screenWidth = 1280;
    const screenHeight = 720;

    rl.InitWindow(screenWidth, screenHeight, "Zig Solar System Explorer - C Interop Demo");
    defer rl.CloseWindow();

    rl.SetTargetFPS(60);

    var camera = rl.Camera3D{
        .position = .{ .x = 0.0, .y = 30.0, .z = 60.0 },
        .target = .{ .x = 0.0, .y = 0.0, .z = 0.0 },
        .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .fovy = 45.0,
        .projection = rl.CAMERA_PERSPECTIVE,
    };

    while (!rl.WindowShouldClose()) {
        const dt = rl.GetFrameTime();

        // Handle input
        if (game_state == .planet_surface and rl.IsKeyPressed(rl.KEY_ESCAPE)) {
            game_state = .solar_system;
            transition_progress = 0.0;
            selected_planet = null;
        }

        if (game_state == .solar_system) {
            updateSolarSystem(dt, &camera);
        } else {
            updatePlanetSurface(dt, &camera);
        }

        // Drawing
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.BLACK);

        rl.BeginMode3D(camera);
        defer rl.EndMode3D();

        if (game_state == .solar_system) {
            drawSolarSystem();
        } else {
            drawPlanetSurface();
        }

        // Draw UI
        drawUI();
    }
}

fn updateSolarSystem(dt: f32, camera: *rl.Camera3D) void {
    // Update planet positions
    for (&planets) |*planet| {
        planet.angle += planet.orbit_speed * dt * 0.1;
    }

    // Handle planet selection with mouse
    if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) {
        const ray = rl.GetScreenToWorldRay(rl.GetMousePosition(), camera.*);

        var closest_dist: f32 = 1000.0;
        var clicked_planet: ?usize = null;

        for (planets, 0..) |planet, i| {
            const x = @cos(planet.angle) * planet.orbit_radius;
            const z = @sin(planet.angle) * planet.orbit_radius;
            const planet_pos = rl.Vector3{ .x = x, .y = 0.0, .z = z };

            const collision = rl.GetRayCollisionSphere(ray, planet_pos, planet.size);
            if (collision.hit and collision.distance < closest_dist) {
                closest_dist = collision.distance;
                clicked_planet = i;
            }
        }

        if (clicked_planet) |planet_idx| {
            selected_planet = planet_idx;
            game_state = .planet_surface;
            const planet = planets[planet_idx];
            player_pos = rl.Vector3{ .x = 0.0, .y = planet.terrain_height + 1.5, .z = 0.0 };
            player_angle = 0.0;
        }
    }

    // Rotate camera around solar system
    const time: f32 = @floatCast(rl.GetTime());
    camera.position.x = @cos(time * 0.2) * 60.0;
    camera.position.z = @sin(time * 0.2) * 60.0;
}

fn updatePlanetSurface(dt: f32, camera: *rl.Camera3D) void {
    if (selected_planet) |planet_idx| {
        const planet = planets[planet_idx];
        const move_speed: f32 = 5.0;
        const turn_speed: f32 = 2.0;

        // Movement controls
        if (rl.IsKeyDown(rl.KEY_W)) {
            player_pos.x += @cos(player_angle) * move_speed * dt;
            player_pos.z += @sin(player_angle) * move_speed * dt;
        }
        if (rl.IsKeyDown(rl.KEY_S)) {
            player_pos.x -= @cos(player_angle) * move_speed * dt;
            player_pos.z -= @sin(player_angle) * move_speed * dt;
        }
        if (rl.IsKeyDown(rl.KEY_A)) {
            player_angle -= turn_speed * dt;
        }
        if (rl.IsKeyDown(rl.KEY_D)) {
            player_angle += turn_speed * dt;
        }

        // Simple terrain height based on position
        const terrain_height = planet.terrain_height * (@sin(player_pos.x * 0.5) * @cos(player_pos.z * 0.5) + 1.0) * 0.5;
        player_pos.y = terrain_height + 1.5;

        // Update camera to follow player
        camera.position = player_pos;
        camera.target = rl.Vector3{
            .x = player_pos.x + @cos(player_angle) * 2.0,
            .y = player_pos.y,
            .z = player_pos.z + @sin(player_angle) * 2.0,
        };
    }
}

fn drawSolarSystem() void {
    // Draw sun
    rl.DrawSphere(.{ .x = 0.0, .y = 0.0, .z = 0.0 }, 3.0, rl.YELLOW);
    rl.DrawSphereWires(.{ .x = 0.0, .y = 0.0, .z = 0.0 }, 3.0, 16, 16, rl.GOLD);

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

        // Calculate planet position
        const x = @cos(planet.angle) * planet.orbit_radius;
        const z = @sin(planet.angle) * planet.orbit_radius;
        const planet_pos = rl.Vector3{ .x = x, .y = 0.0, .z = z };

        // Draw planet
        rl.DrawSphere(planet_pos, planet.size, planet.color);
        rl.DrawSphereWires(planet_pos, planet.size, 8, 8, rl.WHITE);
    }
}

fn drawPlanetSurface() void {
    if (selected_planet) |planet_idx| {
        const planet = planets[planet_idx];

        // Draw terrain grid
        const grid_size: i32 = 50;
        const cell_size: f32 = 2.0;
        var x: i32 = -grid_size;

        while (x <= grid_size) : (x += 1) {
            var z: i32 = -grid_size;
            while (z <= grid_size) : (z += 1) {
                const fx = @as(f32, @floatFromInt(x)) * cell_size;
                const fz = @as(f32, @floatFromInt(z)) * cell_size;
                const height = planet.terrain_height * (@sin(fx * 0.5) * @cos(fz * 0.5) + 1.0) * 0.5;

                const pos = rl.Vector3{ .x = fx, .y = height, .z = fz };
                const size: f32 = 0.8;

                // Color variation based on height
                var tile_color = planet.surface_color;
                const brightness = @as(u8, @intFromFloat(height / planet.terrain_height * 50.0));
                tile_color.r = @min(255, @as(u16, tile_color.r) + @as(u16, brightness));
                tile_color.g = @min(255, @as(u16, tile_color.g) + @as(u16, brightness));
                tile_color.b = @min(255, @as(u16, tile_color.b) + @as(u16, brightness));

                rl.DrawCube(pos, size, 0.1, size, tile_color);
                rl.DrawCubeWires(pos, size, 0.1, size, .{ .r = 0, .g = 0, .b = 0, .a = 50 });
            }
        }

        // Draw sky color
        rl.DrawSphere(.{ .x = player_pos.x, .y = -1000.0, .z = player_pos.z }, 900.0, planet.color);
    }
}

fn drawUI() void {
    if (game_state == .solar_system) {
        rl.DrawText("Click on a planet to visit its surface", 10, 10, 20, rl.WHITE);
        rl.DrawText("Built with Zig + raylib (C library)", 10, 40, 16, rl.LIGHTGRAY);
    } else if (selected_planet) |planet_idx| {
        const planet = planets[planet_idx];
        var buffer: [64]u8 = undefined;
        const text = std.fmt.bufPrintZ(&buffer, "On {s} - Press ESC to return", .{planet.name}) catch "Surface";
        rl.DrawText(text, 10, 10, 20, rl.WHITE);
        rl.DrawText("WASD to move, Mouse to look around", 10, 40, 16, rl.LIGHTGRAY);
    }

    // FPS counter
    rl.DrawFPS(10, rl.GetScreenHeight() - 30);
}
