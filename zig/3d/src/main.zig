const std = @import("std");
const raylib = @import("raylib.zig");
const rl = raylib.rl;

// Import our modules
const math = @import("math/utils.zig");
const StateManager = @import("game/state.zig").StateManager;
const GameState = @import("game/state.zig").GameState;
const Planet = @import("game/planet.zig").Planet;
const getPlanets = @import("game/planet.zig").getSolarSystem;
const InputManager = @import("input/manager.zig").InputManager;
const Action = @import("input/manager.zig").Action;
const CameraController = @import("render/camera.zig").CameraController;
const CameraMode = @import("render/camera.zig").CameraMode;
const renderer = @import("render/renderer.zig");
const TerrainManager = @import("render/terrain_manager.zig").TerrainManager;

// Game state
var state_manager: StateManager = undefined;
var input: InputManager = undefined;
var camera_controller: CameraController = undefined;
var planets: [8]Planet = undefined;
var selected_planet: ?usize = null;
var terrain_manager: ?TerrainManager = null;

// Player state (for planet surface)
var player_pos: rl.Vector3 = undefined;
var player_angle: f32 = 0.0;

pub fn main() !void {
    // Initialize allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Initialize window
    rl.InitWindow(math.SCREEN_WIDTH, math.SCREEN_HEIGHT, "STELLAR HARVEST - Ecosystem Management Game");
    defer rl.CloseWindow();

    // Disable ESC key for closing window - we handle it ourselves
    rl.SetExitKey(0);

    rl.SetTargetFPS(math.TARGET_FPS);

    // Initialize game systems
    state_manager = StateManager.init();
    input = InputManager.init();
    camera_controller = CameraController.init();
    planets = getPlanets();

    // Initialize terrain manager
    var terrain_mgr = try TerrainManager.init(allocator);
    defer terrain_mgr.deinit();
    terrain_manager = terrain_mgr;

    // Main game loop
    while (!rl.WindowShouldClose()) {
        const dt = rl.GetFrameTime();

        // Update
        handleInput(&input);
        updateGame(dt);

        // Render
        renderGame();
    }
}

fn handleInput(inp: *InputManager) void {
    // Global input (ESC key)
    if (inp.isActionPressed(.cancel)) {
        switch (state_manager.current) {
            .planet_surface => {
                // Return to solar system
                camera_controller.transitionToOrbit();
                state_manager.enter(.solar_system);
                selected_planet = null;
            },
            .solar_system => {
                // Could open pause menu later
            },
            else => {},
        }
    }

    // State-specific input
    switch (state_manager.current) {
        .solar_system => handleSolarSystemInput(inp),
        .planet_surface => handlePlanetSurfaceInput(inp),
        else => {},
    }
}

fn handleSolarSystemInput(inp: *InputManager) void {
    // Planet selection with mouse
    if (inp.isMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) {
        const ray = rl.GetScreenToWorldRay(inp.getMousePosition(), camera_controller.camera);

        var closest_dist: f32 = 1000.0;
        var clicked_planet: ?usize = null;

        // Check all planets for intersection
        for (&planets, 0..) |*planet, i| {
            if (planet.rayIntersects(ray)) |distance| {
                if (distance < closest_dist) {
                    closest_dist = distance;
                    clicked_planet = i;
                }
            }
        }

        // If a planet was clicked, transition to it
        if (clicked_planet) |planet_idx| {
            selected_planet = planet_idx;
            const planet = planets[planet_idx];

            // Initialize player position on planet
            player_pos = rl.Vector3{
                .x = 0.0,
                .y = planet.terrain_height + math.PLAYER_HEIGHT_OFFSET,
                .z = 0.0,
            };
            player_angle = 0.0;

            // Load terrain chunks for this planet
            if (terrain_manager) |*mgr| {
                mgr.loadChunksAroundPlayer(player_pos, &planet) catch |err| {
                    std.debug.print("Failed to load terrain: {}\n", .{err});
                };
            }

            // Start camera transition
            const look_at = rl.Vector3{
                .x = player_pos.x + @cos(player_angle) * 2.0,
                .y = player_pos.y,
                .z = player_pos.z + @sin(player_angle) * 2.0,
            };
            camera_controller.transitionToFirstPerson(player_pos, look_at);
            state_manager.enter(.planet_surface);
        }
    }
}

fn handlePlanetSurfaceInput(inp: *InputManager) void {
    if (selected_planet == null) return;

    const planet = planets[selected_planet.?];
    const dt = rl.GetFrameTime();

    // Movement
    if (inp.isActionDown(.move_forward)) {
        player_pos.x += @cos(player_angle) * math.PLAYER_MOVE_SPEED * dt;
        player_pos.z += @sin(player_angle) * math.PLAYER_MOVE_SPEED * dt;
    }
    if (inp.isActionDown(.move_backward)) {
        player_pos.x -= @cos(player_angle) * math.PLAYER_MOVE_SPEED * dt;
        player_pos.z -= @sin(player_angle) * math.PLAYER_MOVE_SPEED * dt;
    }
    if (inp.isActionDown(.move_left)) {
        player_angle -= math.PLAYER_TURN_SPEED * dt;
    }
    if (inp.isActionDown(.move_right)) {
        player_angle += math.PLAYER_TURN_SPEED * dt;
    }

    // Update player height based on terrain
    const terrain_height = if (terrain_manager) |*mgr|
        mgr.getHeightAtPosition(player_pos.x, player_pos.z)
    else
        math.calculateTerrainHeight(player_pos.x, player_pos.z, planet.terrain_height);
    player_pos.y = terrain_height + math.PLAYER_HEIGHT_OFFSET;

    // Update camera to follow player
    const look_at = rl.Vector3{
        .x = player_pos.x + @cos(player_angle) * 2.0,
        .y = player_pos.y,
        .z = player_pos.z + @sin(player_angle) * 2.0,
    };
    camera_controller.setFirstPerson(player_pos, look_at);
}

fn updateGame(dt: f32) void {
    // Update state manager
    state_manager.update(dt);

    // Update camera
    camera_controller.update(dt);

    // Check for transition completion
    if (camera_controller.mode == .transition and camera_controller.isTransitionComplete()) {
        // Transition complete, set final mode
        if (state_manager.current == .solar_system) {
            camera_controller.mode = .orbit;
        } else if (state_manager.current == .planet_surface) {
            camera_controller.mode = .first_person;
        }
    }

    // Update planets (orbital motion)
    if (state_manager.current == .solar_system) {
        for (&planets) |*planet| {
            planet.update(dt, math.ORBIT_SPEED_MULTIPLIER);
        }
    }
}

fn renderGame() void {
    rl.BeginDrawing();
    defer rl.EndDrawing();

    rl.ClearBackground(rl.BLACK);

    // 3D rendering
    rl.BeginMode3D(camera_controller.camera);
    defer rl.EndMode3D();

    switch (state_manager.current) {
        .solar_system, .transition => {
            renderer.renderSolarSystem(&planets);
        },
        .planet_surface => {
            // Render terrain using terrain manager
            if (terrain_manager) |*mgr| {
                mgr.render();
            }

            // Render sky sphere (fallback for now)
            if (selected_planet) |planet_idx| {
                const planet = planets[planet_idx];
                rl.DrawSphere(.{ .x = player_pos.x, .y = -1000.0, .z = player_pos.z }, 900.0, planet.color);
            }
        },
        else => {},
    }

    // 2D UI rendering
    switch (state_manager.current) {
        .solar_system => {
            renderer.renderSolarSystemUI();
        },
        .planet_surface => {
            if (selected_planet) |planet_idx| {
                renderer.renderPlanetSurfaceUI(planets[planet_idx].name);
            }
        },
        else => {},
    }

    // Always render FPS
    renderer.renderFPS();
}
