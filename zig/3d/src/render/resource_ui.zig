const std = @import("std");
const raylib = @import("../raylib.zig");
const rl = raylib.rl;
const resources = @import("../game/resources.zig");
const ResourceType = resources.ResourceType;
const ResourcePool = resources.ResourcePool;

/// Render resource bars for a planet
pub fn renderResourceBars(pool: *const ResourcePool, x: i32, y: i32) void {
    const bar_width: i32 = 200;
    const bar_height: i32 = 20;
    const spacing: i32 = 25;

    const resource_types = [_]ResourceType{ .water, .minerals, .energy, .atmosphere, .biomass, .temperature };

    var offset_y: i32 = y;
    for (resource_types) |rt| {
        renderResourceBar(pool, rt, x, offset_y, bar_width, bar_height);
        offset_y += spacing;
    }

    // Render ecosystem health
    offset_y += 10;
    renderEcosystemHealth(pool, x, offset_y, bar_width, bar_height);
}

/// Render a single resource bar
fn renderResourceBar(pool: *const ResourcePool, resource_type: ResourceType, x: i32, y: i32, width: i32, height: i32) void {
    const percentage = pool.getPercentage(resource_type);
    const fill_width = @as(i32, @intFromFloat(@as(f32, @floatFromInt(width)) * percentage));

    // Background
    rl.DrawRectangle(x, y, width, height, rl.DARKGRAY);

    // Fill bar with color based on percentage
    const fill_color = getResourceColor(resource_type, percentage);
    rl.DrawRectangle(x, y, fill_width, height, fill_color);

    // Border
    rl.DrawRectangleLines(x, y, width, height, rl.WHITE);

    // Label and value
    const name = resource_type.getName();
    const name_cstr = @as([*:0]const u8, @ptrCast(name.ptr));

    rl.DrawText(name_cstr, x + 5, y + 3, 14, rl.WHITE);

    // Percentage text
    var buffer: [32]u8 = undefined;
    const percent_int = @as(i32, @intFromFloat(percentage * 100.0));
    const value_text = std.fmt.bufPrintZ(&buffer, "{d}%", .{percent_int}) catch "??%";
    rl.DrawText(value_text, x + width - 35, y + 3, 14, rl.WHITE);
}

/// Get color for resource bar based on percentage
fn getResourceColor(resource_type: ResourceType, percentage: f32) rl.Color {
    // Base color by resource type
    var base_color = switch (resource_type) {
        .water => rl.BLUE,
        .minerals => rl.BROWN,
        .energy => rl.YELLOW,
        .atmosphere => rl.SKYBLUE,
        .biomass => rl.GREEN,
        .temperature => rl.ORANGE,
    };

    // Adjust brightness based on percentage
    if (percentage < 0.3) {
        // Critical - darker/redder
        base_color.r = @min(255, base_color.r + 100);
        base_color.g = @max(0, base_color.g / 2);
        base_color.b = @max(0, base_color.b / 2);
    } else if (percentage < 0.5) {
        // Warning - slightly darker
        base_color.r = @max(0, base_color.r - 30);
        base_color.g = @max(0, base_color.g - 30);
        base_color.b = @max(0, base_color.b - 30);
    }

    return base_color;
}

/// Render ecosystem health indicator
fn renderEcosystemHealth(pool: *const ResourcePool, x: i32, y: i32, width: i32, height: i32) void {
    const health = pool.getEcosystemHealth();
    const fill_width = @as(i32, @intFromFloat(@as(f32, @floatFromInt(width)) * health));

    // Background
    rl.DrawRectangle(x, y, width, height + 5, rl.DARKGRAY);

    // Fill with gradient based on health
    const fill_color = if (health >= 0.8)
        rl.GREEN
    else if (health >= 0.5)
        rl.YELLOW
    else if (health >= 0.3)
        rl.ORANGE
    else
        rl.RED;

    rl.DrawRectangle(x, y, fill_width, height + 5, fill_color);

    // Border
    rl.DrawRectangleLines(x, y, width, height + 5, rl.WHITE);

    // Label
    rl.DrawText("ECOSYSTEM HEALTH", x + 5, y + 5, 14, rl.WHITE);

    // Percentage
    var buffer: [32]u8 = undefined;
    const percent_int = @as(i32, @intFromFloat(health * 100.0));
    const value_text = std.fmt.bufPrintZ(&buffer, "{d}%", .{percent_int}) catch "??%";
    rl.DrawText(value_text, x + width - 35, y + 5, 14, rl.WHITE);
}

/// Render compact resource summary (for solar system view)
pub fn renderResourceSummary(pool: *const ResourcePool, x: i32, y: i32) void {
    const health = pool.getEcosystemHealth();

    var buffer: [64]u8 = undefined;
    const percent_int = @as(i32, @intFromFloat(health * 100.0));
    const text = std.fmt.bufPrintZ(&buffer, "Health: {d}%", .{percent_int}) catch "Health: ??%";

    const color = if (health >= 0.8)
        rl.GREEN
    else if (health >= 0.5)
        rl.YELLOW
    else
        rl.RED;

    rl.DrawText(text, x, y, 12, color);
}
