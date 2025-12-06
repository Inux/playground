const std = @import("std");
const raylib = @import("../raylib.zig");
const rl = raylib.rl;
const math = @import("../math/utils.zig");

/// Camera modes
pub const CameraMode = enum {
    orbit,         // Orbiting around solar system
    first_person,  // First-person on planet surface
    transition,    // Transitioning between modes
};

/// Camera controller manages all camera behavior
pub const CameraController = struct {
    mode: CameraMode,
    camera: rl.Camera3D,

    // Transition state
    transition_from: rl.Vector3,
    transition_to: rl.Vector3,
    transition_target_from: rl.Vector3,
    transition_target_to: rl.Vector3,
    transition_progress: f32,

    pub fn init() CameraController {
        return CameraController{
            .mode = .orbit,
            .camera = rl.Camera3D{
                .position = .{ .x = 0.0, .y = math.SOLAR_VIEW_CAMERA_HEIGHT, .z = math.SOLAR_VIEW_CAMERA_DISTANCE },
                .target = .{ .x = 0.0, .y = 0.0, .z = 0.0 },
                .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
                .fovy = 45.0,
                .projection = rl.CAMERA_PERSPECTIVE,
            },
            .transition_from = .{ .x = 0.0, .y = 0.0, .z = 0.0 },
            .transition_to = .{ .x = 0.0, .y = 0.0, .z = 0.0 },
            .transition_target_from = .{ .x = 0.0, .y = 0.0, .z = 0.0 },
            .transition_target_to = .{ .x = 0.0, .y = 0.0, .z = 0.0 },
            .transition_progress = 1.0,
        };
    }

    /// Update camera based on current mode
    pub fn update(self: *CameraController, dt: f32) void {
        switch (self.mode) {
            .orbit => self.updateOrbit(dt),
            .first_person => {}, // Updated externally from player movement
            .transition => self.updateTransition(dt),
        }
    }

    /// Update orbital camera (auto-rotate around center)
    fn updateOrbit(self: *CameraController, dt: f32) void {
        _ = dt;
        const time: f32 = @floatCast(rl.GetTime());
        self.camera.position.x = @cos(time * math.SOLAR_VIEW_ROTATION_SPEED) * math.SOLAR_VIEW_CAMERA_DISTANCE;
        self.camera.position.z = @sin(time * math.SOLAR_VIEW_ROTATION_SPEED) * math.SOLAR_VIEW_CAMERA_DISTANCE;
        self.camera.position.y = math.SOLAR_VIEW_CAMERA_HEIGHT;
        self.camera.target = .{ .x = 0.0, .y = 0.0, .z = 0.0 };
    }

    /// Update transition between camera modes
    fn updateTransition(self: *CameraController, dt: f32) void {
        self.transition_progress += dt * 2.0; // 0.5 second transition

        if (self.transition_progress >= 1.0) {
            self.transition_progress = 1.0;
            // Transition complete, switch to target mode
            // (mode will be changed externally)
        }

        // Smooth interpolation with easing
        const t = math.smoothstep(self.transition_progress);

        self.camera.position = math.lerpVector3(
            self.transition_from,
            self.transition_to,
            t,
        );

        self.camera.target = math.lerpVector3(
            self.transition_target_from,
            self.transition_target_to,
            t,
        );
    }

    /// Start transition to first-person mode
    pub fn transitionToFirstPerson(self: *CameraController, target_pos: rl.Vector3, look_dir: rl.Vector3) void {
        self.transition_from = self.camera.position;
        self.transition_to = target_pos;
        self.transition_target_from = self.camera.target;
        self.transition_target_to = look_dir;
        self.transition_progress = 0.0;
        self.mode = .transition;
    }

    /// Start transition to orbit mode
    pub fn transitionToOrbit(self: *CameraController) void {
        const time: f32 = @floatCast(rl.GetTime());
        const target_pos = rl.Vector3{
            .x = @cos(time * math.SOLAR_VIEW_ROTATION_SPEED) * math.SOLAR_VIEW_CAMERA_DISTANCE,
            .y = math.SOLAR_VIEW_CAMERA_HEIGHT,
            .z = @sin(time * math.SOLAR_VIEW_ROTATION_SPEED) * math.SOLAR_VIEW_CAMERA_DISTANCE,
        };

        self.transition_from = self.camera.position;
        self.transition_to = target_pos;
        self.transition_target_from = self.camera.target;
        self.transition_target_to = .{ .x = 0.0, .y = 0.0, .z = 0.0 };
        self.transition_progress = 0.0;
        self.mode = .transition;
    }

    /// Check if transition is complete
    pub fn isTransitionComplete(self: *CameraController) bool {
        return self.transition_progress >= 1.0;
    }

    /// Set camera for first-person mode
    pub fn setFirstPerson(self: *CameraController, position: rl.Vector3, target: rl.Vector3) void {
        self.camera.position = position;
        self.camera.target = target;
    }

    /// Get the camera for rendering
    pub fn getCamera(self: *CameraController) *rl.Camera3D {
        return &self.camera;
    }
};
