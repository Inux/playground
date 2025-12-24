const std = @import("std");

/// Resource types in the game ecosystem
pub const ResourceType = enum {
    water,
    minerals,
    energy,
    atmosphere,
    biomass,
    temperature,

    pub fn getName(self: ResourceType) []const u8 {
        return switch (self) {
            .water => "Water",
            .minerals => "Minerals",
            .energy => "Energy",
            .atmosphere => "Atmosphere",
            .biomass => "Biomass",
            .temperature => "Temperature",
        };
    }

    pub fn getIcon(self: ResourceType) []const u8 {
        return switch (self) {
            .water => "💧",
            .minerals => "⛏️",
            .energy => "⚡",
            .atmosphere => "🌫️",
            .biomass => "🌿",
            .temperature => "🌡️",
        };
    }
};

/// Resource storage and management
pub const ResourcePool = struct {
    water: f32,
    minerals: f32,
    energy: f32,
    atmosphere: f32,
    biomass: f32,
    temperature: f32,

    // Maximum values for each resource
    max_water: f32,
    max_minerals: f32,
    max_energy: f32,
    max_atmosphere: f32,
    max_biomass: f32,
    max_temperature: f32,

    pub fn init() ResourcePool {
        return ResourcePool{
            .water = 50.0,
            .minerals = 50.0,
            .energy = 50.0,
            .atmosphere = 50.0,
            .biomass = 50.0,
            .temperature = 50.0,
            .max_water = 100.0,
            .max_minerals = 100.0,
            .max_energy = 100.0,
            .max_atmosphere = 100.0,
            .max_biomass = 100.0,
            .max_temperature = 100.0,
        };
    }

    /// Get resource value by type
    pub fn get(self: *const ResourcePool, resource_type: ResourceType) f32 {
        return switch (resource_type) {
            .water => self.water,
            .minerals => self.minerals,
            .energy => self.energy,
            .atmosphere => self.atmosphere,
            .biomass => self.biomass,
            .temperature => self.temperature,
        };
    }

    /// Get max value for resource type
    pub fn getMax(self: *const ResourcePool, resource_type: ResourceType) f32 {
        return switch (resource_type) {
            .water => self.max_water,
            .minerals => self.max_minerals,
            .energy => self.max_energy,
            .atmosphere => self.max_atmosphere,
            .biomass => self.max_biomass,
            .temperature => self.max_temperature,
        };
    }

    /// Add resources (clamped to max)
    pub fn add(self: *ResourcePool, resource_type: ResourceType, amount: f32) void {
        const max = self.getMax(resource_type);
        switch (resource_type) {
            .water => self.water = @min(max, self.water + amount),
            .minerals => self.minerals = @min(max, self.minerals + amount),
            .energy => self.energy = @min(max, self.energy + amount),
            .atmosphere => self.atmosphere = @min(max, self.atmosphere + amount),
            .biomass => self.biomass = @min(max, self.biomass + amount),
            .temperature => self.temperature = @min(max, self.temperature + amount),
        }
    }

    /// Remove resources (clamped to 0)
    pub fn remove(self: *ResourcePool, resource_type: ResourceType, amount: f32) bool {
        const current = self.get(resource_type);
        if (current < amount) return false;

        switch (resource_type) {
            .water => self.water = @max(0.0, self.water - amount),
            .minerals => self.minerals = @max(0.0, self.minerals - amount),
            .energy => self.energy = @max(0.0, self.energy - amount),
            .atmosphere => self.atmosphere = @max(0.0, self.atmosphere - amount),
            .biomass => self.biomass = @max(0.0, self.biomass - amount),
            .temperature => self.temperature = @max(0.0, self.temperature - amount),
        }
        return true;
    }

    /// Get resource percentage (0-1)
    pub fn getPercentage(self: *const ResourcePool, resource_type: ResourceType) f32 {
        const current = self.get(resource_type);
        const max = self.getMax(resource_type);
        return current / max;
    }

    /// Calculate overall ecosystem health (average of all resources)
    pub fn getEcosystemHealth(self: *const ResourcePool) f32 {
        const total = self.getPercentage(.water) +
            self.getPercentage(.minerals) +
            self.getPercentage(.energy) +
            self.getPercentage(.atmosphere) +
            self.getPercentage(.biomass) +
            self.getPercentage(.temperature);
        return total / 6.0;
    }
};

/// Resource interaction/dependency rules
pub const ResourceDependencies = struct {
    /// Update resources based on ecosystem interactions
    pub fn updateEcosystem(pool: *ResourcePool, dt: f32) void {
        // Biomass grows with water and energy
        if (pool.water > 20.0 and pool.energy > 20.0) {
            pool.add(.biomass, dt * 2.0);
        } else {
            _ = pool.remove(.biomass, dt * 1.0);
        }

        // Energy production requires minerals and atmosphere
        if (pool.minerals > 10.0 and pool.atmosphere > 30.0) {
            pool.add(.energy, dt * 1.5);
            _ = pool.remove(.minerals, dt * 0.5);
        }

        // Atmosphere depends on biomass
        if (pool.biomass > 40.0) {
            pool.add(.atmosphere, dt * 1.0);
        } else if (pool.atmosphere > 0.0) {
            _ = pool.remove(.atmosphere, dt * 0.5);
        }

        // Temperature regulation requires atmosphere
        if (pool.atmosphere > 50.0) {
            // Move temperature towards ideal (50)
            const diff = 50.0 - pool.temperature;
            if (diff > 0) {
                pool.add(.temperature, dt * 2.0);
            } else if (diff < 0) {
                _ = pool.remove(.temperature, dt * 2.0);
            }
        }

        // Water evaporation/condensation based on temperature
        if (pool.temperature > 60.0) {
            _ = pool.remove(.water, dt * 0.8);
            pool.add(.atmosphere, dt * 0.4);
        } else if (pool.temperature < 40.0 and pool.atmosphere > 30.0) {
            pool.add(.water, dt * 0.6);
            _ = pool.remove(.atmosphere, dt * 0.3);
        }
    }

    /// Check if ecosystem is balanced (all resources above threshold)
    pub fn isBalanced(pool: *const ResourcePool) bool {
        const threshold = 0.5; // 50%
        return pool.getPercentage(.water) >= threshold and
            pool.getPercentage(.minerals) >= threshold and
            pool.getPercentage(.energy) >= threshold and
            pool.getPercentage(.atmosphere) >= threshold and
            pool.getPercentage(.biomass) >= threshold and
            pool.getPercentage(.temperature) >= threshold;
    }

    /// Get critical resources (below 30%)
    pub fn getCriticalResources(pool: *const ResourcePool, allocator: std.mem.Allocator) ![]ResourceType {
        var critical = std.ArrayList(ResourceType).init(allocator);

        const resource_types = [_]ResourceType{ .water, .minerals, .energy, .atmosphere, .biomass, .temperature };
        for (resource_types) |rt| {
            if (pool.getPercentage(rt) < 0.3) {
                try critical.append(rt);
            }
        }

        return critical.toOwnedSlice();
    }
};

/// Resource node - can be placed on planet surface for harvesting
pub const ResourceNode = struct {
    resource_type: ResourceType,
    position: [3]f32, // x, y, z world position
    amount: f32,
    max_amount: f32,
    regeneration_rate: f32,
    active: bool,

    pub fn init(resource_type: ResourceType, x: f32, y: f32, z: f32) ResourceNode {
        return ResourceNode{
            .resource_type = resource_type,
            .position = [3]f32{ x, y, z },
            .amount = 100.0,
            .max_amount = 100.0,
            .regeneration_rate = 5.0, // 5 units per second
            .active = true,
        };
    }

    /// Harvest resources from this node
    pub fn harvest(self: *ResourceNode, amount: f32) f32 {
        if (!self.active) return 0.0;

        const harvested = @min(self.amount, amount);
        self.amount -= harvested;

        if (self.amount <= 0.0) {
            self.active = false;
        }

        return harvested;
    }

    /// Regenerate resource over time
    pub fn regenerate(self: *ResourceNode, dt: f32) void {
        if (self.amount < self.max_amount) {
            self.amount = @min(self.max_amount, self.amount + self.regeneration_rate * dt);
            self.active = true;
        }
    }

    /// Get distance from a point
    pub fn distanceFrom(self: *const ResourceNode, x: f32, z: f32) f32 {
        const dx = self.position[0] - x;
        const dz = self.position[2] - z;
        return @sqrt(dx * dx + dz * dz);
    }
};
