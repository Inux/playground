const std = @import("std");

/// Game states
pub const GameState = enum {
    solar_system,
    planet_surface,
    transition,
    menu,
    paused,
};

/// State manager handles game state transitions
pub const StateManager = struct {
    current: GameState,
    previous: GameState,
    transition_progress: f32,
    transition_duration: f32,

    pub fn init() StateManager {
        return StateManager{
            .current = .solar_system,
            .previous = .solar_system,
            .transition_progress = 0.0,
            .transition_duration = 0.5, // 0.5 seconds for transitions
        };
    }

    /// Enter a new state
    pub fn enter(self: *StateManager, new_state: GameState) void {
        if (self.current == new_state) return;

        self.previous = self.current;
        self.current = new_state;
        self.transition_progress = 0.0;
    }

    /// Update state (handles transitions)
    pub fn update(self: *StateManager, dt: f32) void {
        if (self.transition_progress < 1.0) {
            self.transition_progress += dt / self.transition_duration;
            if (self.transition_progress > 1.0) {
                self.transition_progress = 1.0;
            }
        }
    }

    /// Check if we can transition (not currently transitioning)
    pub fn canTransition(self: *StateManager) bool {
        return self.transition_progress >= 1.0;
    }

    /// Check if currently transitioning
    pub fn isTransitioning(self: *StateManager) bool {
        return self.transition_progress < 1.0;
    }

    /// Get normalized transition progress (0.0 - 1.0)
    pub fn getTransitionProgress(self: *StateManager) f32 {
        return self.transition_progress;
    }
};
