# 🌌 STELLAR HARVEST

**A AAA Ecosystem Management Game Built in Zig**

Transform and balance planetary ecosystems across multiple solar systems. Built from scratch in Zig, showcasing professional game architecture and C library interoperability.

> **Status**: Phase 1 Complete ✅ | Currently in development
> **Next**: Phase 2 - Visual Quality Upgrade

## Features

- **Solar System View**: Orbiting planets around a central sun with realistic orbital speeds
- **Planet Surface Exploration**: Click on any planet to teleport to its surface
- **First-Person Movement**: WASD controls to walk around on planet surfaces
- **Dynamic Terrain**: Procedurally generated terrain height for each planet
- **Smooth Transitions**: Seamless camera transitions between views

## Zig & C Interop Showcase

This project demonstrates Zig's powerful C interoperability features:

1. **@cImport**: Using Zig's built-in C header import
   ```zig
   const rl = @cImport({
       @cInclude("raylib.h");
       @cInclude("raymath.h");
   });
   ```

2. **System Library Linking**: Linking against system-installed C libraries
   ```zig
   root_module.linkSystemLibrary("raylib", .{});
   ```

3. **Direct C API Usage**: Calling C functions directly from Zig code
   ```zig
   rl.DrawSphere(planet_pos, planet.size, planet.color);
   ```

## Building

### Prerequisites

- Zig 0.15.2 or higher
- raylib (install via Homebrew: `brew install raylib`)

### Build Commands

```bash
# Build the project
zig build

# Build and run
zig build run
```

The executable will be placed in `zig-out/bin/solar-system`

## How to Play

1. **Solar System View**:
   - Watch planets orbit around the sun
   - Click on any planet to visit its surface
   - Camera auto-rotates around the solar system

2. **Planet Surface View**:
   - Use **W/A/S/D** to move around
   - Use **Mouse** to look around (planned feature)
   - Press **ESC** to return to solar system view

## Planets

- Mercury (gray, fast orbit)
- Venus (orange, moderate orbit)
- Earth (blue, moderate orbit)
- Mars (red, slow orbit)
- Jupiter (tan, very slow orbit)
- Saturn (pale yellow, very slow orbit)
- Uranus (cyan, extremely slow orbit)
- Neptune (blue, extremely slow orbit)

## Technical Details

- **Language**: Zig 0.15.2
- **Graphics Library**: raylib 5.5 (C library)
- **Build System**: Zig's native build system
- **Window Size**: 1280x720
- **Target FPS**: 60

## Project Structure

```
3d/
├── build.zig          # Build configuration
├── build.zig.zon      # Package manifest
├── src/
│   └── main.zig       # Main game logic
└── zig-out/
    └── bin/
        └── solar-system   # Compiled executable
```

## What This Showcases

1. **Zig Build System**: Modern, declarative build configuration
2. **C Interoperability**: Seamless integration with C libraries
3. **Type Safety**: Zig's compile-time type checking with C types
4. **Error Handling**: Zig's error handling patterns
5. **Memory Safety**: No runtime overhead while maintaining safety
6. **Zero-Cost Abstractions**: Direct C function calls with no wrapper overhead

## License

This is a demonstration project showcasing Zig's capabilities.
