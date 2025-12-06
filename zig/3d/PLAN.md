# 🌌 STELLAR HARVEST - AAA Ecosystem Management Game
## Complete Implementation Plan

**Project**: Transform basic solar system demo into AAA-quality generative ecosystem management game
**Timeline**: 12 weeks (3 months)
**Approach**: Balanced development - parallel tracks for gameplay mechanics and visual quality

---

## 🎯 CORE CONCEPT

**Stellar Harvest** is a generative ecosystem management game where players balance planetary ecosystems across multiple solar systems to achieve universal harmony.

### Game Loop
1. **Explore** planets in solar system
2. **Analyze** biomes and ecosystems
3. **Plant** resources and build facilities
4. **Harvest** at optimal times
5. **Balance** interconnected systems across all planets
6. **Achieve** solar system harmony (80%+ health on all planets)
7. **Unlock** new solar systems with increasing complexity
8. **Travel** via gateways, ships, or wormholes
9. **Master** the galaxy ecosystem

### Victory Condition
Only when ALL planets in a solar system reach and maintain ecosystem balance can the system flourish. Success unlocks new solar systems with unique challenges.

---

## 📊 CURRENT STATE ANALYSIS

### Bugs Identified
1. **ESC Key Bug**: `WindowShouldClose()` catches ESC in all states, closes app instead of returning to solar view
2. **Brightness Overflow**: Type conversion issues in terrain color calculation
3. **Poor Performance**: 20,000+ draw calls per frame for terrain (cube-based)
4. **Visual Quality**: Blocky terrain, no lighting, no textures

### Architecture Issues
- Global mutable state everywhere
- No state machine
- No input abstraction
- Immediate mode rendering (inefficient)
- No separation of concerns
- Mixed update/render logic
- Unused variables (`transition_progress`)

### Code Quality
- Magic numbers everywhere
- No documentation
- No error handling
- String formatting in render loop
- Array access without bounds checking

---

## 🗓️ DEVELOPMENT PHASES

---

## PHASE 1: CRITICAL BUG FIXES & FOUNDATION
**Duration**: 1 week
**Goal**: Fix all bugs, establish solid architecture

### 1.1 Immediate Bug Fixes
- [ ] Fix ESC key closing app
  - Add `rl.SetExitKey(0)` in initialization
  - Handle ESC globally in input system
- [ ] Fix brightness calculation overflow
  - Proper type casting with bounds checking
  - Clamp values correctly
- [ ] Implement smooth camera transitions
  - Use existing `transition_progress` variable
  - Interpolate camera position/target

### 1.2 Code Restructuring

**New File Structure:**
```
src/
├── main.zig                 # Entry point, game loop
├── game/
│   ├── state.zig           # State machine implementation
│   ├── world.zig           # Solar system & galaxy data
│   ├── planet.zig          # Planet definitions & logic
│   └── ecosystem.zig       # Ecosystem simulation
├── render/
│   ├── renderer.zig        # Rendering pipeline
│   ├── camera.zig          # Camera controllers
│   ├── terrain.zig         # Terrain generation
│   └── ui.zig              # UI rendering
├── input/
│   └── manager.zig         # Input handling & action mapping
└── math/
    └── utils.zig           # Math helpers & constants
```

### 1.3 Core Systems Architecture

**StateManager**
```zig
pub const GameState = enum {
    solar_view,
    planet_surface,
    galaxy_map,
    transition,
    menu,
    paused,
};

pub const StateManager = struct {
    current: GameState,
    previous: GameState,
    transition_progress: f32,

    pub fn enter(self: *StateManager, state: GameState) void;
    pub fn update(self: *StateManager, dt: f32) void;
    pub fn canTransition(self: *StateManager) bool;
};
```

**InputManager**
```zig
pub const Action = enum {
    confirm,
    cancel,
    move_forward,
    move_backward,
    move_left,
    move_right,
    look_mouse,
    interact,
    menu,
};

pub const InputManager = struct {
    action_map: std.AutoHashMap(Action, Key),

    pub fn isActionPressed(self: *InputManager, action: Action) bool;
    pub fn isActionDown(self: *InputManager, action: Action) bool;
    pub fn getMouseDelta(self: *InputManager) Vector2;
};
```

**CameraController**
```zig
pub const CameraMode = enum {
    orbit,
    first_person,
    transition,
};

pub const CameraController = struct {
    mode: CameraMode,
    camera: Camera3D,

    pub fn update(self: *CameraController, dt: f32) void;
    pub fn transitionTo(self: *CameraController, mode: CameraMode, target_pos: Vector3) void;
};
```

### 1.4 Deliverables
- [ ] All bugs fixed
- [ ] New file structure created
- [ ] StateManager implemented and working
- [ ] InputManager with ESC handling
- [ ] CameraController with smooth transitions
- [ ] Clean separation of concerns

---

## PHASE 2: VISUAL QUALITY UPGRADE
**Duration**: 2 weeks
**Goal**: Transform visuals from prototype to AAA quality

### 2.1 Terrain System Overhaul

**Replace Cube Grid with Mesh Generation**
- [ ] Implement heightmap generation (Perlin/Simplex noise)
- [ ] Generate triangle mesh from heightmap
- [ ] Add normal calculation for smooth lighting
- [ ] Implement UV mapping for textures

**Chunking & Culling**
- [ ] Divide terrain into chunks (16x16 or 32x32)
- [ ] Implement frustum culling per chunk
- [ ] Only render visible chunks
- [ ] Reduce draw calls from 20,000+ to <100

**Level of Detail (LOD)**
- [ ] Generate multiple LOD levels per chunk
- [ ] Switch LOD based on distance from camera
- [ ] Implement smooth LOD transitions (morph targets)

**Texture Splatting**
- [ ] Create texture atlas (dirt, rock, grass, sand, ice)
- [ ] Generate blend maps based on height/slope
- [ ] Implement multi-texture shader
- [ ] Add detail/normal maps

### 2.2 Rendering Enhancements

**Lighting System**
- [ ] Implement directional light (sun)
- [ ] Add point lights (for facilities)
- [ ] Implement Phong/Blinn-Phong shading
- [ ] Add ambient occlusion

**Shadow Mapping**
- [ ] Implement shadow map framebuffer
- [ ] Render scene from light's perspective
- [ ] Apply shadows in main pass
- [ ] Add PCF filtering for soft shadows

**Skybox System**
- [ ] Replace sphere with proper cubemap skybox
- [ ] Create space skybox textures
- [ ] Add star field generation
- [ ] Implement planet-specific skies

**Atmospheric Scattering**
- [ ] Implement Rayleigh scattering shader
- [ ] Add Mie scattering for haze
- [ ] Planet rim lighting
- [ ] Day/night atmosphere color

**PBR Materials**
- [ ] Implement metallic-roughness workflow
- [ ] Add albedo, normal, metallic, roughness maps
- [ ] IBL (Image-Based Lighting) for reflections
- [ ] Fresnel effects

**Post-Processing**
- [ ] Render to framebuffer texture
- [ ] Implement bloom effect
- [ ] Add HDR tone mapping
- [ ] Color grading LUT
- [ ] Optional: motion blur, depth of field

### 2.3 Visual Polish

**Camera Transitions**
- [ ] Smooth interpolation between views
- [ ] Ease-in/ease-out curves
- [ ] Camera shake for events
- [ ] Dolly zoom effects

**Planet Animations**
- [ ] Planet rotation on axis
- [ ] Smooth orbital motion
- [ ] Ring rotation for gas giants
- [ ] Cloud layer movement

**Effects**
- [ ] Orbital trail particles
- [ ] Dust/atmosphere particles on planets
- [ ] Star twinkle effect
- [ ] Warp/jump effects for travel
- [ ] Resource collection particles

**UI Elements**
- [ ] Planet name billboards (always face camera)
- [ ] Info cards with smooth fade
- [ ] Health bars for planets
- [ ] Scan lines and HUD elements

### 2.4 Planet-Specific Visual Features
- [ ] Saturn-style rings (separate mesh, alpha blending)
- [ ] Gas giant cloud patterns (procedural)
- [ ] Ice planet reflections
- [ ] Lava planet emissive glow
- [ ] Water planet ocean shader (waves, foam)

### 2.5 Deliverables
- [ ] Terrain rendering at 60 FPS
- [ ] Proper lighting and shadows
- [ ] Beautiful skyboxes
- [ ] Atmospheric effects on planets
- [ ] Smooth camera transitions
- [ ] Visual polish pass complete

---

## PHASE 3: ECOSYSTEM MECHANICS - CORE SYSTEMS
**Duration**: 2 weeks
**Goal**: Implement 6-10 interconnected ecosystem systems

### 3.1 Resource System (6 Primary Resources)

**Resource Types:**
1. **Water** 💧
   - Sources: Ice, oceans, atmosphere
   - Uses: Biomass growth, atmosphere regulation
   - Flows: Evaporation, precipitation, runoff

2. **Minerals** ⛏️
   - Sources: Mining, asteroids, geology
   - Uses: Building, technology
   - Flows: Extraction, depletion

3. **Energy** ⚡
   - Sources: Solar, geothermal, chemical
   - Uses: All processes, buildings
   - Flows: Generation, consumption, storage

4. **Atmosphere** 🌫️
   - Components: O2, CO2, N2, trace gases
   - Sources: Volcanic, biomass, processing
   - Uses: Life support, climate
   - Flows: Photosynthesis, respiration, leakage

5. **Biomass** 🌱
   - Sources: Plants, organisms, seeds
   - Uses: Food, oxygen, ecosystem stability
   - Flows: Growth, death, decay, consumption

6. **Temperature** 🌡️
   - Sources: Star distance, atmosphere, volcanic
   - Effects: All resource production rates
   - Flows: Solar radiation, greenhouse effect, convection

**Resource Implementation:**
```zig
pub const Resource = enum {
    water,
    minerals,
    energy,
    atmosphere_o2,
    atmosphere_co2,
    biomass,
    temperature,
};

pub const ResourcePool = struct {
    amount: f32,          // Current amount (0.0 - max)
    max: f32,             // Maximum capacity
    rate: f32,            // Current change rate per tick
    generation: f32,      // Base generation rate
    consumption: f32,     // Base consumption rate

    pub fn update(self: *ResourcePool, dt: f32) void;
    pub fn canConsume(self: *ResourcePool, amount: f32) bool;
    pub fn consume(self: *ResourcePool, amount: f32) bool;
    pub fn add(self: *ResourcePool, amount: f32) void;
};
```

### 3.2 Planet Biome System

**Biome Types:**
- **Desert** (hot): High temperature, low water, mineral-rich
- **Tundra** (cold): Low temperature, frozen water, slow growth
- **Ocean**: High water, moderate temperature, biomass production
- **Forest**: Balanced resources, high biomass, O2 production
- **Volcanic**: High energy, high minerals, extreme temperature
- **Barren**: Low everything, hard mode
- **Ice**: Frozen water, low energy, pristine
- **Jungle**: Extreme biomass, high water, high temperature

**Biome Implementation:**
```zig
pub const BiomeType = enum {
    desert_hot,
    desert_cold,
    ocean,
    forest,
    volcanic,
    barren,
    ice,
    jungle,
    grassland,
    mountain,
};

pub const Biome = struct {
    type: BiomeType,
    coverage: f32,                    // Percentage of planet (0.0-1.0)
    resource_modifiers: [7]f32,       // Multipliers for each resource

    pub fn getResourceRate(self: *Biome, resource: Resource) f32;
};

pub const Planet = struct {
    name: []const u8,
    biomes: []Biome,
    resources: [7]ResourcePool,
    ecosystem_health: f32,            // 0.0 - 1.0

    pub fn update(self: *Planet, dt: f32) void;
    pub fn calculateHealth(self: *Planet) f32;
};
```

### 3.3 Ecosystem Simulation

**Inter-Resource Dependencies:**
```
Water → Biomass (growth)
Biomass → O2 (photosynthesis)
Biomass + O2 → CO2 (respiration)
CO2 + Water → Biomass (photosynthesis)
Energy → All processes
Temperature → All rates (multiplier)
Minerals → Buildings → Resource generation
```

**Ecosystem Rules:**
1. Each resource has ideal range (20-80%)
2. Resources outside ideal range reduce health
3. Resource depletion (<5%) causes cascades
4. Resource overflow (>95%) causes waste
5. Balance bonus: all in ideal = health boost

**Health Calculation:**
```zig
pub fn calculateEcosystemHealth(planet: *Planet) f32 {
    var health: f32 = 0.0;
    var count: f32 = 0.0;

    // Check each resource's health contribution
    for (planet.resources) |resource| {
        const percent = resource.amount / resource.max;

        // Ideal range: 0.2 - 0.8
        if (percent >= 0.2 and percent <= 0.8) {
            health += 1.0;
        } else if (percent < 0.05 or percent > 0.95) {
            health += 0.0;  // Critical
        } else {
            health += 0.5;  // Suboptimal
        }
        count += 1.0;
    }

    // Check resource flow balance
    const flow_balance = checkFlowBalance(planet);
    health += flow_balance;
    count += 1.0;

    // Check biome diversity
    const diversity = calculateBiomeDiversity(planet);
    health += diversity;
    count += 1.0;

    return health / count;
}
```

**Solar System Level:**
```zig
pub const SolarSystem = struct {
    name: []const u8,
    planets: []Planet,
    star_type: StarType,
    system_health: f32,

    pub fn update(self: *SolarSystem, dt: f32) void {
        // Update all planets
        for (self.planets) |*planet| {
            planet.update(dt);
        }

        // Calculate system-wide health
        self.system_health = calculateSystemHealth(self);

        // Check for cascade effects
        checkCascadeEffects(self);
    }

    fn calculateSystemHealth(self: *SolarSystem) f32 {
        var total: f32 = 0.0;
        for (self.planets) |planet| {
            total += planet.ecosystem_health;
        }
        return total / @as(f32, @floatFromInt(self.planets.len));
    }
};
```

### 3.4 Growth & Harvesting Mechanics

**Planting System:**
```zig
pub const Seed = struct {
    resource_type: Resource,
    growth_time: f32,        // Real-time seconds
    yield_amount: f32,       // Amount when harvested
    requirements: []ResourceRequirement,
};

pub fn plantSeed(planet: *Planet, seed: Seed, location: Vector3) !void {
    // Check requirements
    for (seed.requirements) |req| {
        if (!planet.canConsume(req.resource, req.amount)) {
            return error.InsufficientResources;
        }
    }

    // Consume resources
    for (seed.requirements) |req| {
        planet.consume(req.resource, req.amount);
    }

    // Add growing resource
    try planet.growing_resources.append(GrowingResource{
        .seed = seed,
        .planted_at = getTime(),
        .location = location,
        .growth_progress = 0.0,
    });
}
```

**Harvesting System:**
```zig
pub fn harvestResource(planet: *Planet, growing: *GrowingResource) !f32 {
    if (growing.growth_progress < 1.0) {
        // Early harvest = reduced yield
        const penalty = 1.0 - growing.growth_progress;
        return growing.seed.yield_amount * growing.growth_progress;
    } else if (growing.growth_progress > 1.5) {
        // Over-ripe = decay started
        const decay = (growing.growth_progress - 1.5) * 0.5;
        return growing.seed.yield_amount * (1.0 - decay);
    } else {
        // Perfect harvest
        return growing.seed.yield_amount;
    }
}
```

**Balance Mechanics:**
- Over-harvesting → Resource depletion → Ecosystem collapse
- Under-harvesting → Waste → Inefficiency
- Perfect timing → Maximum yield → Bonus health
- Resource trading between planets via ships/portals

### 3.5 Deliverables
- [ ] 6 resource types implemented
- [ ] 8+ biome types working
- [ ] Ecosystem simulation running
- [ ] Health calculation accurate
- [ ] Planting mechanics functional
- [ ] Harvesting with timing mechanics
- [ ] Solar system-level simulation
- [ ] Cascade effects working

---

## PHASE 4: GAMEPLAY LOOP & PROGRESSION
**Duration**: 2 weeks
**Goal**: Complete core gameplay loop and progression systems

### 4.1 Player Actions on Planets

**Scan Mode:**
```zig
pub fn scanPlanet(planet: *Planet, player_pos: Vector3) ScanResult {
    return ScanResult{
        .biome = detectBiome(planet, player_pos),
        .resources = getNearbyResources(planet, player_pos, scan_radius),
        .ecosystem_health = planet.ecosystem_health,
        .threats = detectThreats(planet, player_pos),
        .opportunities = detectOpportunities(planet, player_pos),
    };
}
```

**Build Mode:**
```zig
pub const Building = struct {
    type: BuildingType,
    cost: []ResourceCost,
    benefits: []ResourceModifier,
    position: Vector3,
    planet: *Planet,
    health: f32,
};

pub fn placeBuild(planet: *Planet, building_type: BuildingType, pos: Vector3) !*Building {
    const blueprint = getBuildingBlueprint(building_type);

    // Check costs
    for (blueprint.costs) |cost| {
        if (!planet.canConsume(cost.resource, cost.amount)) {
            return error.InsufficientResources;
        }
    }

    // Consume resources and build
    for (blueprint.costs) |cost| {
        planet.consume(cost.resource, cost.amount);
    }

    const building = try createBuilding(planet, blueprint, pos);
    try planet.buildings.append(building);

    return building;
}
```

### 4.2 Facility System

**Building Types:**

1. **Resource Extractor**
   - Cost: 50 minerals, 20 energy
   - Benefit: +50% resource generation rate for specific resource
   - Variants: Water pump, Mine, Solar array, etc.

2. **Terraformer**
   - Cost: 100 minerals, 100 energy, 50 water
   - Benefit: Slowly changes biome type
   - Use: Convert desert → grassland, ice → ocean, etc.

3. **Greenhouse**
   - Cost: 30 minerals, 20 water
   - Benefit: Controlled biomass growth (faster, predictable)
   - Use: Guaranteed harvests, research

4. **Atmosphere Processor**
   - Cost: 80 minerals, 60 energy
   - Benefit: Converts CO2 ↔ O2
   - Use: Balance atmosphere composition

5. **Research Station**
   - Cost: 100 minerals, 50 energy
   - Benefit: Unlock tech tree upgrades
   - Use: Progression

6. **Storage Facility**
   - Cost: 40 minerals
   - Benefit: Increase resource max capacity
   - Use: Store surplus for later

7. **Trading Post**
   - Cost: 60 minerals, 40 energy
   - Benefit: Enable resource transfer between planets
   - Use: Balance across system

8. **Portal Hub**
   - Cost: 500 minerals, 500 energy, rare resources
   - Benefit: Enable interstellar travel
   - Use: Late game, unlock new systems

**Building Mechanics:**
- Costs resources to build
- Can be upgraded (3 levels typically)
- Requires periodic maintenance (consumes energy)
- Can be damaged by disasters
- Can be repaired
- Strategic placement matters (on correct biome)

### 4.3 Solar System Objectives

**Victory Conditions (per system):**
1. All planets ≥ 80% ecosystem health simultaneously
2. Maintain for 10 game cycles (e.g., 10 minutes real-time)
3. No resource below critical threshold (<5%)
4. Complete special objective (unique per system)

**Special Objectives Examples:**
- Sol: Terraform Mars to support biomass
- Alpha Centauri: Balance 3-star system gravitational effects
- Sirius: Survive extreme radiation from blue star
- Betelgeuse: Harvest exotic matter before supernova
- Custom: Each system has unique challenge

**Failure States:**
- Planet ecosystem collapse (<20% health for 5 cycles)
- Resource extinction (resource depleted, cannot recover)
- Cascade failure (one planet fails → others follow)
- Time limit exceeded (optional challenge mode)

**Victory Rewards:**
- Unlock next solar system
- Persistent tech upgrades
- Achievement unlocks
- New building types
- Cosmetic unlocks (planet skins, ship models)

### 4.4 Progression & Unlocks

**Solar System Progression:**
1. **Sol** (Tutorial) - 8 planets, balanced difficulty
2. **Alpha Centauri** (Intermediate) - 6 planets, dual-star challenges
3. **Sirius** (Advanced) - 4 planets, extreme conditions
4. **Barnard's Star** (Expert) - 12 planets, complex dependencies
5. **Betelgeuse** (Master) - 3 planets, time pressure (pre-supernova)
6. **Custom Systems** (Procedural) - Endless mode

**Tech Tree:**
```
Tier 1 (Start):
├─ Basic Extractor
├─ Small Greenhouse
└─ Manual Harvesting

Tier 2 (10 research points):
├─ Advanced Extractor (+100% rate)
├─ Atmosphere Processor
├─ Auto-Harvester
└─ Resource Storage

Tier 3 (25 research points):
├─ Terraformer
├─ Ecosystem Analyzer
├─ Trading Post
└─ Efficient Buildings (-50% upkeep)

Tier 4 (50 research points):
├─ Portal Hub
├─ Mega-Structures
├─ Ecosystem Restoration
└─ Time Acceleration

Tier 5 (100 research points):
├─ Wormhole Generator
├─ Stellar Engineering
├─ Perfect Harmony Bonus
└─ Galaxy Map Unlock
```

**Meta-Progression:**
- Research points carry between systems
- Tech unlocks persist
- Achievement bonuses (e.g., +10% energy generation)
- Unlock harder difficulty modes
- Unlock sandbox mode

### 4.5 Deliverables
- [ ] All player actions implemented
- [ ] 8+ building types functional
- [ ] Building placement and upgrades
- [ ] Victory conditions working
- [ ] Failure detection
- [ ] Solar system objectives
- [ ] Tech tree implemented
- [ ] Progression system
- [ ] Save/load system (bonus)

---

## PHASE 5: INTERSTELLAR TRAVEL SYSTEM
**Duration**: 1 week
**Goal**: Implement 3 travel methods and galaxy map

### 5.1 Hybrid Travel System

**Method 1: Gateway Network (Early Game)**
```zig
pub const Gateway = struct {
    location: Vector3,
    planet: *Planet,
    connected_systems: []SolarSystem,
    active: bool,
    energy_cost_per_use: f32,

    pub fn activate(self: *Gateway, destination: SolarSystem) !void {
        if (!self.active) return error.GatewayInactive;
        if (self.planet.resources[energy].amount < self.energy_cost_per_use) {
            return error.InsufficientEnergy;
        }

        self.planet.consume(Resource.energy, self.energy_cost_per_use);
        transitionToSystem(destination);
    }
};
```

- Build Gateway Facility on planet (costs 500 minerals, 500 energy)
- Research coordinates to discover new systems
- Instant travel but high energy cost
- Limited to adjacent systems initially
- Unlocks at game start

**Method 2: Ship Travel (Mid Game)**
```zig
pub const Starship = struct {
    name: []const u8,
    fuel: f32,
    max_fuel: f32,
    speed: f32,              // Systems per hour
    cargo_capacity: f32,
    upgrades: []ShipUpgrade,

    pub fn travelTo(self: *Starship, destination: SolarSystem) !void {
        const distance = calculateDistance(current_system, destination);
        const fuel_needed = distance * self.fuel_consumption_rate;

        if (self.fuel < fuel_needed) return error.InsufficientFuel;

        self.fuel -= fuel_needed;
        const travel_time = distance / self.speed;

        // Either real-time or skippable
        startTravelAnimation(destination, travel_time);
    }
};
```

- Construct ship (requires resources from multiple planets)
- Plan route on galaxy map
- Travel takes time (real-time or skippable)
- Fuel consumption based on distance
- Can explore unconnected systems
- Unlocks after completing first system

**Method 3: Wormhole Mastery (Late Game)**
```zig
pub const Wormhole = struct {
    entrance: WormholeEnd,
    exit: WormholeEnd,
    stability: f32,          // 0.0 - 1.0
    maintenance_cost: f32,   // Energy per cycle

    pub fn traverse(self: *Wormhole) !void {
        if (self.stability < 0.5) return error.UnstableWormhole;

        // Instant travel, no fuel cost
        // But requires maintaining both endpoints
        transitionInstant(self.exit.system);
    }
};
```

- Create stable wormholes between managed systems
- Instant travel, zero fuel cost
- Must maintain both entrance and exit (energy cost)
- Requires tech tree unlock (Tier 4)
- Endgame mechanic for efficient management

### 5.2 Galaxy Map System

**Features:**
```zig
pub const GalaxyMap = struct {
    systems: []SolarSystem,
    connections: []Connection,
    player_position: SolarSystem,
    discovered: []bool,
    camera: Camera3D,

    pub fn render(self: *GalaxyMap) void {
        // Render star field background
        // Draw each solar system as point/sphere
        // Draw connection lines
        // Highlight current system
        // Show routes
    }

    pub fn selectSystem(self: *GalaxyMap, system: SolarSystem) SystemInfo {
        return SystemInfo{
            .name = system.name,
            .planets = system.planets.len,
            .difficulty = system.difficulty,
            .distance = calculateDistance(player_position, system),
            .resources_preview = summarizeResources(system),
            .status = system.completion_status,
        };
    }
};
```

**View Modes:**
1. **Galaxy View** - Top-down/3D view of all systems
2. **System View** - Zoom to selected system, see planets
3. **Planet View** - Zoom to planet, see surface
4. **Seamless Zoom** - Smooth transitions between scales

**UI Elements:**
- System info cards
- Travel route planning
- Resource comparison chart
- Tech tree overlay
- Discovery log
- Achievement tracker

### 5.3 Procedural Solar System Generation

**Generation Algorithm:**
```zig
pub fn generateSolarSystem(seed: u64, difficulty: f32) SolarSystem {
    var rng = std.rand.DefaultPrng.init(seed);

    // Star type affects everything
    const star = generateStar(&rng, difficulty);

    // Number of planets
    const planet_count = rng.random().intRangeAtMost(u32, 3, 12);

    var planets = std.ArrayList(Planet).init(allocator);

    for (0..planet_count) |i| {
        const planet = generatePlanet(&rng, star, i, difficulty);
        planets.append(planet);
    }

    return SolarSystem{
        .name = generateSystemName(&rng),
        .star = star,
        .planets = planets.toOwnedSlice(),
        .difficulty = difficulty,
        .seed = seed,
    };
}

fn generatePlanet(rng: *RNG, star: Star, orbit_index: usize, difficulty: f32) Planet {
    const distance = calculateOrbitDistance(star, orbit_index);
    const planet_type = selectPlanetType(rng, distance, star);

    const biomes = generateBiomes(rng, planet_type, difficulty);
    const resources = initializeResources(biomes, planet_type);

    return Planet{
        .name = generatePlanetName(rng),
        .type = planet_type,
        .orbit_radius = distance,
        .size = selectPlanetSize(rng, planet_type),
        .biomes = biomes,
        .resources = resources,
        .ecosystem_health = rng.random().float(f32) * 0.3 + 0.4,  // 40-70%
    };
}
```

**Generation Parameters:**
- Star type: Red dwarf, yellow sun, blue giant
- Planet count: 3-12
- Planet types: Rocky, gas giant, ice, lava, ocean, desert
- Biome distribution: Based on star distance and planet type
- Resource balance: Difficulty affects initial health
- Special features: Rings, moons, asteroid belts, anomalies

**Difficulty Scaling:**
- Easy: High initial health, slow decay, forgiving thresholds
- Medium: Balanced, realistic ecosystem dynamics
- Hard: Low initial health, fast decay, strict thresholds
- Expert: Extreme conditions, cascades, time limits
- Master: Minimal resources, random disasters, near-impossible

### 5.4 Deliverables
- [ ] Gateway system working
- [ ] Ship construction and travel
- [ ] Wormhole mechanics (late game)
- [ ] Galaxy map UI
- [ ] Zoom navigation (galaxy → system → planet)
- [ ] Route planning
- [ ] Procedural generation algorithm
- [ ] 5+ handcrafted systems
- [ ] Infinite procedural systems

---

## PHASE 6: UI/UX & GAME FEEL
**Duration**: 1 week
**Goal**: Professional UI and satisfying game feel

### 6.1 UI System Architecture

**Solar System View UI:**
```zig
pub fn renderSolarSystemUI() void {
    // Planet info cards (hover over planet)
    if (hovered_planet) |planet| {
        renderPlanetCard(planet);
    }

    // System health overview (top bar)
    renderSystemHealthBar();

    // Quick-select radial menu (hold Q)
    if (input.isActionDown(.quick_menu)) {
        renderQuickSelectMenu();
    }

    // Objective tracker (right side)
    renderObjectivePanel();

    // Resource summary (bottom left)
    renderResourceSummary();
}
```

**Planet Surface UI:**
```zig
pub fn renderPlanetSurfaceUI() void {
    // HUD with resource levels (top)
    renderResourceHUD();

    // Ecosystem health (top right)
    renderEcosystemHealthDisplay();

    // Build menu (B key or radial)
    if (input.isActionPressed(.build_menu)) {
        renderBuildMenu();
    }

    // Action feedback (center)
    renderActionFeedback();  // "Planted", "Harvested +50", etc.

    // Minimap (bottom right)
    renderMinimap();

    // Warnings/Alerts (top center)
    if (planet.hasWarnings()) {
        renderWarnings();
    }
}
```

**Galaxy Map UI:**
```zig
pub fn renderGalaxyMapUI() void {
    // System selection info (left panel)
    if (selected_system) |system| {
        renderSystemInfoPanel(system);
    }

    // Travel options (bottom)
    renderTravelOptionsMenu();

    // Tech tree (T key)
    if (show_tech_tree) {
        renderTechTree();
    }

    // Achievements (A key)
    if (show_achievements) {
        renderAchievements();
    }

    // Legend (bottom right)
    renderLegend();
}
```

### 6.2 Audio System

**Sound Categories:**
1. **Ambient** - Space hum, planet atmospheres
2. **UI** - Button clicks, menu whooshes
3. **Gameplay** - Plant, harvest, build sounds
4. **Alerts** - Warnings, completion fanfare
5. **Music** - Dynamic background music

**Implementation:**
```zig
pub const AudioManager = struct {
    music_volume: f32,
    sfx_volume: f32,
    ambient_volume: f32,
    current_music: MusicTrack,

    pub fn playSound(self: *AudioManager, sound: Sound) void;
    pub fn playMusic(self: *AudioManager, track: MusicTrack) void;
    pub fn setMusicIntensity(self: *AudioManager, intensity: f32) void;
};
```

**Dynamic Music:**
- Calm exploration theme (solar view)
- Focused planet theme (surface)
- Tense theme (low health warnings)
- Victory fanfare (objectives complete)
- Travel theme (interstellar)

### 6.3 Game Feel (Juice)

**Visual Feedback:**
- Screen shake on important events
- Particle burst on harvest
- Glow pulse on building completion
- Color flash on warnings
- Smooth number counters (lerp)
- Progress bars with smooth fill

**Camera Feel:**
- Ease-in/ease-out on all movements
- Slight bounce on landings
- Dolly zoom on dramatic moments
- Shake on planet approach
- Smooth rotation (no snapping)

**Action Feedback:**
- Every button has sound + visual
- Hover effects (scale, glow)
- Click feedback (squash/stretch)
- Success = green flash + sound
- Failure = red flash + buzz
- Harvesting = particle shower + counter

**Timing & Polish:**
- 60 FPS mandatory
- No stutters or hitches
- Smooth transitions (0.3-0.5s typical)
- Predictable physics
- Responsive controls (<100ms input delay)

### 6.4 Tutorial System

**Progressive Tutorial:**
1. **First Launch** - Basic controls overlay
2. **Solar View** - Click planet to explore
3. **First Planet** - Movement, scanning
4. **Ecosystem Basics** - Resource explanation
5. **First Plant** - How to plant seeds
6. **First Harvest** - Timing and yield
7. **First Build** - Placing buildings
8. **Balance** - Ecosystem health explanation
9. **Victory** - Complete first system

**Implementation:**
- Tooltip overlays (can dismiss)
- Contextual hints (appear when relevant)
- Optional full tutorial mode
- Can skip if experienced
- Help menu always accessible (F1)

### 6.5 Deliverables
- [ ] Complete UI for all views
- [ ] Sound effects library
- [ ] Background music system
- [ ] All juice/polish implemented
- [ ] Tutorial system working
- [ ] Help/pause menus
- [ ] Settings (volume, graphics, controls)
- [ ] Accessibility options

---

## PHASE 7: ADVANCED FEATURES & POLISH
**Duration**: 2 weeks
**Goal**: Advanced gameplay systems and final polish

### 7.1 Advanced Ecosystem Features

**Weather Systems:**
```zig
pub const WeatherSystem = struct {
    current: WeatherType,
    intensity: f32,
    duration: f32,

    pub fn update(self: *WeatherSystem, planet: *Planet, dt: f32) void;
};

pub const WeatherType = enum {
    clear,
    rain,          // +water, -visibility
    storm,         // +water, -energy, damage buildings
    drought,       // -water, +temperature
    blizzard,      // -temperature, -movement speed
    dust_storm,    // -visibility, -solar energy
};
```

**Geological Events:**
- Earthquakes (damage buildings, expose minerals)
- Volcanic eruptions (add atmosphere, increase temperature)
- Meteor impacts (create craters, add minerals or damage)
- Tectonic shifts (change biomes over time)

**Evolutionary Events:**
- Species mutations (change resource rates)
- Invasive species (unbalanced growth)
- Disease/plague (biomass reduction)
- Symbiotic relationships (resource bonuses)

**Restoration Mechanics:**
- "Dead" planets can be revived (very expensive)
- Ecosystem reset option (nuclear option)
- Terraform completely (long-term project)
- Import life from other planets

### 7.2 Meta-Progression

**Persistent Upgrades:**
- Universal Tech Unlocks (carry over to new games)
- Ship Upgrades (better fuel efficiency, speed)
- Starting Bonuses (extra resources, buildings)
- Cosmetic Unlocks (planet skins, ship models)

**Achievement System:**
```zig
pub const Achievement = struct {
    id: []const u8,
    name: []const u8,
    description: []const u8,
    icon: Texture,
    unlocked: bool,
    progress: f32,
    reward: Reward,
};

// Examples:
// - "Green Thumb": Plant 1000 seeds
// - "Balanced Act": 100% health on all planets simultaneously
// - "Speed Runner": Complete Sol in under 1 hour
// - "Perfectionist": Complete system without any planet dropping below 70%
// - "Galaxy Master": Complete all handcrafted systems
```

**Challenge Modes:**
- **Speed Run**: Complete as fast as possible
- **Limited Resources**: Start with minimal resources
- **Hardcore**: One planet collapse = game over
- **Extreme Weather**: Constant disasters
- **Zero Waste**: Cannot let any resource go above 95%
- **Nomad**: Cannot build more than 3 buildings per planet

**Sandbox Mode:**
- Unlimited resources
- Instant travel
- No failure conditions
- Experiment with ecosystems
- Creative building
- Accessible after completing 3 systems

**Statistics Tracking:**
- Total resources harvested (all time)
- Planets saved
- Systems completed
- Buildings constructed
- Total playtime
- Fastest completion times
- Perfect balances achieved

### 7.3 Narrative Layer (Optional)

**Environmental Storytelling:**
- Ancient ruins on planets (lore text)
- Abandoned facilities (what happened?)
- Terraforming gone wrong scenarios
- Evidence of previous civilizations

**Planet Logs:**
- Each planet has hidden log entries
- Discover through exploration
- Tells story of the galaxy
- Adds mystery and depth

**Mystery Objectives:**
- Secret goals hidden in systems
- Unlock by discovering clues
- Reward unique bonuses
- Add replayability

**Multiple Endings:**
- **Harmony Ending**: Perfect balance across all systems
- **Domination Ending**: Maximum resource extraction
- **Restoration Ending**: Revive all dead planets
- **Exploration Ending**: Discover all procedural systems
- **Ascension Ending**: Unlock final tech tier, transcend

**Lore Codex:**
- Encyclopedia of resources
- Biome descriptions
- Star types explained
- Historical events
- Alien species (if applicable)

### 7.4 Optimization & Performance

**Multithreading:**
```zig
// Ecosystem simulation on separate thread
pub fn updateEcosystemsAsync(systems: []SolarSystem) void {
    var thread_pool = ThreadPool.init(allocator, num_cores);

    for (systems) |system| {
        thread_pool.spawn(updateSystemEcosystem, .{system});
    }

    thread_pool.waitAll();
}

// Terrain generation on worker threads
pub fn generateTerrainChunkAsync(chunk: *TerrainChunk) void {
    // Generate heightmap
    // Generate mesh
    // Calculate normals
    // Upload to GPU when ready
}
```

**GPU Optimization:**
- Instanced rendering for vegetation
- Terrain LOD with GPU tessellation
- Occlusion culling (GPU-based)
- Frustum culling on CPU
- Batch draw calls
- Texture atlasing

**Memory Management:**
- Object pooling for particles
- Chunk streaming (load/unload)
- Texture compression
- Mesh LOD caching
- Resource reference counting

**Profiling:**
- FPS counter and frame time graph
- Memory usage display
- Draw call counter
- CPU/GPU profiler integration
- Performance budgets

**Target Performance:**
- 60 FPS minimum (1080p)
- <2GB RAM usage
- <500MB disk space
- Load times <3 seconds
- No frame drops during transitions

### 7.5 Deliverables
- [ ] Weather system
- [ ] Geological events
- [ ] Evolution mechanics
- [ ] Restoration system
- [ ] Achievement system (20+ achievements)
- [ ] Challenge modes (5+)
- [ ] Sandbox mode
- [ ] Statistics tracking
- [ ] Optional: Narrative content
- [ ] Performance: 60 FPS locked
- [ ] Memory optimized
- [ ] Final polish pass

---

## PHASE 8: PLAYTESTING & BALANCE
**Duration**: 1 week
**Goal**: Polish, balance, and prepare for release

### 8.1 Playtesting Focus Areas

**Testing Checklist:**
- [ ] Tutorial clarity (can new players understand?)
- [ ] Difficulty curve (too easy? too hard?)
- [ ] Resource balance (can win without grinding?)
- [ ] UI clarity (is everything readable?)
- [ ] Performance (60 FPS on target hardware?)
- [ ] Bug hunting (crashes, glitches, exploits)
- [ ] Accessibility (colorblind modes, text size, etc.)

**Playtester Questions:**
1. What was confusing?
2. What was frustrating?
3. What was satisfying?
4. What would you change?
5. Would you play again?

### 8.2 Balance Adjustments

**Resource Tuning:**
- Adjust generation/consumption rates
- Tweak ideal ranges
- Balance planetary variety
- Fix degenerate strategies

**Building Costs:**
- Ensure progression feels good
- Not too cheap (trivial)
- Not too expensive (grind)
- Meaningful choices

**Tech Tree Pacing:**
- Unlock rate comfortable?
- All paths viable?
- Late game interesting?

**Difficulty Scaling:**
- Easy: Should be very forgiving
- Medium: Balanced challenge
- Hard: Requires planning
- Expert: Requires mastery
- Master: Near-perfect play

### 8.3 Final Polish

**Bug Fixing:**
- Crash bugs (priority 1)
- Gameplay bugs (priority 2)
- Visual bugs (priority 3)
- Minor issues (priority 4)

**Visual Refinement:**
- Particle effect timing
- Camera smoothness
- UI animations
- Color grading
- Shadow quality

**Audio Mixing:**
- Balance volume levels
- Remove audio pops/clicks
- Fade in/out smoothly
- Ambient loops seamless

**UX Improvements:**
- Reduce clicks to common actions
- Add keyboard shortcuts
- Improve feedback clarity
- Polish transitions

**Accessibility:**
- Colorblind modes (deuteranopia, protanopia, tritanopia)
- Text size options
- Subtitles/captions
- Rebindable controls
- Difficulty assist options
- Screen reader support (if feasible)

### 8.4 Release Preparation

**Documentation:**
- [ ] README.md updated
- [ ] Controls guide
- [ ] Strategy tips
- [ ] FAQ
- [ ] Troubleshooting

**Build Pipeline:**
- [ ] Windows build tested
- [ ] macOS build tested
- [ ] Linux build tested
- [ ] Release packages created
- [ ] Version numbering

**Marketing Materials:**
- [ ] Screenshots (10+)
- [ ] Gameplay trailer (1-2 min)
- [ ] Feature highlights
- [ ] Itch.io/Steam page
- [ ] Social media posts

### 8.5 Deliverables
- [ ] All critical bugs fixed
- [ ] Balance feels good
- [ ] Performance targets met
- [ ] Accessibility features implemented
- [ ] Documentation complete
- [ ] Release builds ready
- [ ] Marketing materials prepared
- [ ] GAME READY TO RELEASE! 🎉

---

## 📋 COMPLETE FEATURE CHECKLIST

### Core Gameplay ✅
- [x] Basic solar system visualization
- [ ] Ecosystem simulation (6 resources)
- [ ] Planet biome system (8+ types)
- [ ] Resource growth/decay
- [ ] Planting mechanics
- [ ] Harvesting mechanics
- [ ] Building/facility system (8+ types)
- [ ] Solar system objectives
- [ ] Victory/failure conditions
- [ ] Interstellar travel (3 methods)
- [ ] Galaxy map
- [ ] Procedural system generation
- [ ] Tech tree (5 tiers)
- [ ] Meta-progression

### Visual & Audio 🎨
- [ ] Terrain mesh generation
- [ ] Texture splatting
- [ ] Lighting & shadows
- [ ] Atmospheric effects
- [ ] Particle systems
- [ ] Post-processing (bloom, HDR)
- [ ] Smooth camera transitions
- [ ] Planet rotation
- [ ] UI/HUD system (all views)
- [ ] Sound effects (50+)
- [ ] Background music (5+ tracks)
- [ ] Dynamic audio

### Technical 🔧
- [ ] State machine
- [ ] Input manager
- [ ] Camera controller system
- [ ] Rendering pipeline
- [ ] LOD system
- [ ] Frustum culling
- [ ] Save/load system
- [ ] Multithreading
- [ ] Performance profiling
- [ ] Memory optimization

### Content 📦
- [ ] 5+ handcrafted solar systems
- [ ] Infinite procedural systems
- [ ] 20+ planet variations
- [ ] 8+ biome types
- [ ] 8+ building types
- [ ] Tutorial system
- [ ] 20+ achievements
- [ ] 5+ challenge modes
- [ ] Sandbox mode
- [ ] Multiple endings (optional)

### Polish & Release 💎
- [ ] All bugs fixed
- [ ] Balance tuning complete
- [ ] 60 FPS performance
- [ ] Accessibility features
- [ ] Documentation
- [ ] Builds (Win/Mac/Linux)
- [ ] Marketing materials
- [ ] READY TO SHIP! 🚀

---

## 📊 ESTIMATED TIMELINE

| Phase | Duration | Description |
|-------|----------|-------------|
| Phase 1 | 1 week | Bug fixes & foundation |
| Phase 2 | 2 weeks | Visual quality upgrade |
| Phase 3 | 2 weeks | Ecosystem mechanics |
| Phase 4 | 2 weeks | Gameplay loop & progression |
| Phase 5 | 1 week | Interstellar travel |
| Phase 6 | 1 week | UI/UX & game feel |
| Phase 7 | 2 weeks | Advanced features & polish |
| Phase 8 | 1 week | Playtesting & balance |
| **TOTAL** | **12 weeks** | **Full AAA game** |

**Alternative Timelines:**
- **MVP (6 weeks)**: Phases 1-4 only, basic but playable
- **Extended (16 weeks)**: Add narrative, more content, extra polish
- **Accelerated (8 weeks)**: Reduce scope, focus on core loop

---

## 🛠️ TECHNICAL STACK

### Core Technologies
- **Language**: Zig 0.15.2+
- **Graphics**: raylib 5.5+ (C library via @cImport)
- **Build**: Zig build system
- **Target**: Windows, macOS, Linux

### Optional Extensions
- **UI**: raygui or custom ImGui
- **Audio**: raylib audio or OpenAL
- **Physics**: Custom or lightweight library
- **Networking**: Multiplayer (future)

### Development Tools
- **Editor**: VS Code with Zig extension
- **Profiler**: Tracy or built-in
- **Version Control**: Git
- **CI/CD**: GitHub Actions
- **Testing**: Zig test framework

---

## 🎯 SUCCESS METRICS

### Technical Goals
- ✅ 60 FPS @ 1080p
- ✅ <2GB RAM usage
- ✅ <500MB disk space
- ✅ <3s load times
- ✅ Zero crashes

### Gameplay Goals
- ✅ 2-5 hour first system completion
- ✅ 10+ hour total gameplay
- ✅ Clear progression path
- ✅ Satisfying feedback loop
- ✅ High replayability

### Quality Goals
- ✅ AAA visual quality
- ✅ Professional UI/UX
- ✅ Polished game feel
- ✅ Complete tutorial
- ✅ Balanced difficulty

---

## 📝 NEXT IMMEDIATE STEPS

1. ✅ **Review this plan** - Confirm scope and approach
2. ⏳ **Create PLAN.md** - Document in repository
3. ⏹️ **Set up project structure** - Create directories
4. ⏹️ **Begin Phase 1** - Fix bugs, refactor architecture
5. ⏹️ **Iterative development** - Build, test, refine

---

## 🚀 LET'S BUILD STELLAR HARVEST!

This plan transforms a simple demo into a full AAA ecosystem management game. The balanced approach ensures both gameplay depth and visual polish develop in parallel.

**Core Philosophy**:
- Quality over quantity
- Gameplay first, graphics second (but both high quality)
- Iterative development
- Playtesting early and often
- Polish everything

**Ready to begin?** Let's start with Phase 1! 🌍✨🚀
