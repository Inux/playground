const std = @import("std");
const raylib = @import("../raylib.zig");
const rl = raylib.rl;
const GameState = @import("../game/state.zig").GameState;

/// Input actions (abstract away from physical keys)
pub const Action = enum {
    cancel,          // ESC
    confirm,         // ENTER or SPACE
    move_forward,    // W
    move_backward,   // S
    move_left,       // A
    move_right,      // D
    interact,        // E
    menu,            // TAB
    quick_menu,      // Q
};

/// Input manager handles all input with action mapping
pub const InputManager = struct {
    // No state needed yet, but we'll add action remapping later

    pub fn init() InputManager {
        return InputManager{};
    }

    /// Check if an action was just pressed (single frame)
    pub fn isActionPressed(self: *InputManager, action: Action) bool {
        _ = self; // Not used yet
        return switch (action) {
            .cancel => rl.IsKeyPressed(rl.KEY_ESCAPE),
            .confirm => rl.IsKeyPressed(rl.KEY_ENTER) or rl.IsKeyPressed(rl.KEY_SPACE),
            .move_forward => false, // Use isActionDown for continuous movement
            .move_backward => false,
            .move_left => false,
            .move_right => false,
            .interact => rl.IsKeyPressed(rl.KEY_E),
            .menu => rl.IsKeyPressed(rl.KEY_TAB),
            .quick_menu => rl.IsKeyPressed(rl.KEY_Q),
        };
    }

    /// Check if an action is currently held down
    pub fn isActionDown(self: *InputManager, action: Action) bool {
        _ = self;
        return switch (action) {
            .cancel => rl.IsKeyDown(rl.KEY_ESCAPE),
            .confirm => rl.IsKeyDown(rl.KEY_ENTER) or rl.IsKeyDown(rl.KEY_SPACE),
            .move_forward => rl.IsKeyDown(rl.KEY_W),
            .move_backward => rl.IsKeyDown(rl.KEY_S),
            .move_left => rl.IsKeyDown(rl.KEY_A),
            .move_right => rl.IsKeyDown(rl.KEY_D),
            .interact => rl.IsKeyDown(rl.KEY_E),
            .menu => rl.IsKeyDown(rl.KEY_TAB),
            .quick_menu => rl.IsKeyDown(rl.KEY_Q),
        };
    }

    /// Check if mouse button was just clicked
    pub fn isMouseButtonPressed(self: *InputManager, button: c_int) bool {
        _ = self;
        return rl.IsMouseButtonPressed(button);
    }

    /// Get mouse position
    pub fn getMousePosition(self: *InputManager) rl.Vector2 {
        _ = self;
        return rl.GetMousePosition();
    }

    /// Get mouse delta (for camera rotation)
    pub fn getMouseDelta(self: *InputManager) rl.Vector2 {
        _ = self;
        return rl.GetMouseDelta();
    }
};
