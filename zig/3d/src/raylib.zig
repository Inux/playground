// Shared raylib C import - all modules should import from here
pub const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

// Re-export commonly used types for convenience
pub const Vector2 = rl.Vector2;
pub const Vector3 = rl.Vector3;
pub const Color = rl.Color;
pub const Camera3D = rl.Camera3D;
pub const Ray = rl.Ray;
