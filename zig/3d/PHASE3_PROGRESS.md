# Phase 3: Ecosystem Mechanics - IN PROGRESS

## Overview
Phase 3 focuses on implementing the core gameplay loop: resource management, ecosystem dynamics, and planet health systems.

## Completed Features ✅

### 1. Resource System (COMPLETE)
**Files**: `src/game/resources.zig`, `src/render/resource_ui.zig`

Implemented a complete 6-resource system with:

#### Resources
1. **Water** 💧 - Essential for biomass growth
2. **Minerals** ⛏️ - Used for energy production
3. **Energy** ⚡ - Powers growth systems
4. **Atmosphere** 🌫️ - Supports life and temperature regulation
5. **Biomass** 🌿 - Grows from water and energy, produces atmosphere
6. **Temperature** 🌡️ - Regulated by atmosphere, affects water

#### Resource Pool Features
- Current value tracking (0-100 for each resource)
- Maximum value limits
- Percentage calculations (0-1 normalized)
- Add/Remove operations with clamping
- Ecosystem health calculation (average of all resources)

#### Resource Dependencies & Interactions
**Biomass Growth**:
- Requires: Water > 20 AND Energy > 20
- Growth rate: +2.0/sec when conditions met
- Decay rate: -1.0/sec when conditions not met

**Energy Production**:
- Requires: Minerals > 10 AND Atmosphere > 30
- Production: +1.5 energy/sec
- Consumes: -0.5 minerals/sec

**Atmosphere Generation**:
- Source: Biomass > 40 → +1.0 atmosphere/sec
- Decay: Biomass < 40 → -0.5 atmosphere/sec

**Temperature Regulation**:
- Requires: Atmosphere > 50
- Effect: Moves temperature toward ideal (50) at ±2.0/sec

**Water Cycle**:
- Evaporation: Temperature > 60 → -0.8 water/sec, +0.4 atmosphere/sec
- Condensation: Temperature < 40 AND Atmosphere > 30 → +0.6 water/sec, -0.3 atmosphere/sec

### 2. Resource UI System (COMPLETE)
**File**: `src/render/resource_ui.zig`

Visual feedback system with:

#### Resource Bars
- 200×20px bars for each resource
- Fill color changes based on percentage:
  - Green/Normal: > 50%
  - Yellow/Warning: 30-50%
  - Red/Critical: < 30%
- Percentage text overlay
- Resource type labels

#### Ecosystem Health Display
- Overall health bar (average of all 6 resources)
- Color coding:
  - Green: ≥ 80% (balanced ecosystem)
  - Yellow: 50-79% (stable)
  - Orange: 30-49% (at risk)
  - Red: < 30% (critical)

#### UI Layout
- Right side of screen (x: SCREEN_WIDTH - 220)
- 6 resource bars + 1 health bar
- 25px spacing between bars
- Always visible on planet surface

### 3. Planet Integration (COMPLETE)
**File**: `src/game/planet.zig`

Each of the 8 planets now has:
- Individual `ResourcePool` instance
- Real-time ecosystem simulation via `update()` method
- Resource dynamics updated every frame

**Update Loop**:
```zig
pub fn update(self: *Planet, dt: f32, speed_multiplier: f32) void {
    self.angle += self.orbit_speed * dt * speed_multiplier;
    resources.ResourceDependencies.updateEcosystem(&self.resources, dt);
}
```

### 4. Resource Node Foundation (COMPLETE)
**File**: `src/game/resources.zig` - `ResourceNode` struct

Prepared for harvesting gameplay:
- World position (x, y, z)
- Resource type
- Amount & max amount
- Regeneration rate (5 units/sec)
- Active/depleted state
- Harvest functionality
- Distance calculation for player interaction

## Technical Implementation

### Code Statistics
**New Files**:
- `src/game/resources.zig` (240 lines)
- `src/render/resource_ui.zig` (130 lines)

**Modified Files**:
- `src/game/planet.zig` - Added ResourcePool integration
- `src/render/renderer.zig` - Added resource UI rendering
- `src/main.zig` - Updated UI calls

**Total LOC**: ~2,220 (from ~1,850)

### Performance Impact
- Resource updates: O(1) per planet (6 simple calculations)
- UI rendering: 7 rectangles + text per frame
- No measurable FPS impact (still 60+)

## Testing
All 9 unit tests still passing ✅

## What's Working

1. **Dynamic Ecosystem**: Resources change in real-time based on interactions
2. **Visual Feedback**: Players can see all 6 resources and ecosystem health
3. **Balance Challenge**: Resources interact in complex ways requiring management
4. **Per-Planet State**: Each planet has independent resource pools
5. **Critical Indicators**: UI warns when resources are low

## Example Gameplay Scenario

Starting state (all resources at 50%):

**T+0 seconds**:
- Water: 50%, Minerals: 50%, Energy: 50%
- Atmosphere: 50%, Biomass: 50%, Temperature: 50%
- Health: 50%

**T+10 seconds**:
- Biomass grows (+2/sec) → 70%
- Energy production active (+1.5/sec) → 65%
- Minerals consumed (-0.5/sec) → 45%
- Atmosphere increases from biomass → 60%
- Temperature stabilizes at 50%
- Health: ~58%

**T+30 seconds**:
- Biomass at max (100%)
- Atmosphere high (80%)
- Water stable (cycling)
- Minerals low (35%) - **Warning state**
- Health: ~65%

**Challenge**: Player must harvest minerals to maintain energy production!

## Known Limitations

1. **No player interaction yet** - Resources change automatically but player can't harvest/plant
2. **No resource nodes spawned** - Foundation exists but not placed in world
3. **No inventory system** - Can't collect or store resources
4. **No buildings** - Can't spend resources on structures
5. **Same starting values** - All planets begin with 50% resources (need variety)

## Next Steps (Remaining Phase 3 Tasks)

### Priority 1: Biome System
- Define biome types (Forest, Desert, Ocean, Mountain, Ice, Volcanic, Plains, Barren)
- Assign biomes based on planet characteristics
- Vary resource distributions by biome
- Visual terrain changes per biome

### Priority 2: Resource Node Spawning
- Generate resource nodes on planet surface
- Place based on biome type (water in oceans, minerals in mountains, etc.)
- Visual representation (colored spheres/models)
- Collision detection for harvesting

### Priority 3: Player Harvesting
- Detect nearby resource nodes
- "E to harvest" interaction
- Harvest animation/particles
- Add to inventory
- Node depletion and regeneration

### Priority 4: Inventory System
- Resource storage for player
- Capacity limits
- UI display of collected resources
- Transfer between inventory and planet pool

### Priority 5: Planting Mechanics
- Spend resources to boost planet ecosystem
- Plant biomass nodes (costs water + energy)
- Build mineral extractors
- Construct atmosphere generators

## Success Metrics for Phase 3 Completion

- [ ] 8+ biome types implemented
- [ ] Resource nodes spawn on all planets
- [ ] Player can harvest resources
- [ ] Inventory system functional
- [ ] Planting/building system working
- [ ] All planets can reach 80%+ health through player actions
- [ ] Resource balance challenging but achievable

## Dependencies for Phase 4

Phase 4 (Buildings & Facilities) requires:
- ✅ Resource system (done)
- ✅ Resource UI (done)
- ⏳ Harvesting mechanics (in progress)
- ⏳ Inventory system (in progress)
- ⏳ Planting mechanics (in progress)

---

**Current Status**: 40% complete
**Blockers**: None
**ETA**: Phase 3 completion in 3-4 more implementation cycles
