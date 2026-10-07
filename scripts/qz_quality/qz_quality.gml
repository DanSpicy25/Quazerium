// =====================================================================
// QUAZERIUM — QUALITY & PERFORMANCE: Hardware scaling (LOW, MEDIUM, HIGH).
// Protects low-end target (Intel HD 2500 / i5-3470 / HDD).
// Gameplay remains strictly identical across all profiles.
// =====================================================================

function quality_system_init() {
    global.quality_level = QUALITY.MEDIUM;
    global.quality_profiles = array_create(QUALITY.COUNT);

    // LOW: Minimal particles, no heavy shaders, capped decals, strict allocation bounds (Intel HD 2500)
    global.quality_profiles[QUALITY.LOW] = {
        max_particles: 100,
        max_decals: 24,
        decal_life: 4.0,
        power_vfx_budget: 0.5,
        enable_shaders: false,
        enable_lighting: false,
        shake_mult: 0.8,
        trail_segments: 2,
        ambient_dust: 15,
        draw_distant_windows: false
    };

    // MEDIUM: Balanced for standard PC
    global.quality_profiles[QUALITY.MEDIUM] = {
        max_particles: 500,
        max_decals: 64,
        decal_life: 7.0,
        power_vfx_budget: 1.0,
        enable_shaders: true,
        enable_lighting: true,
        shake_mult: 1.0,
        trail_segments: 4,
        ambient_dust: 40,
        draw_distant_windows: true
    };

    // HIGH: Rich visual effects and full post-processing
    global.quality_profiles[QUALITY.HIGH] = {
        max_particles: 2000,
        max_decals: 128,
        decal_life: 12.0,
        power_vfx_budget: 1.5,
        enable_shaders: true,
        enable_lighting: true,
        shake_mult: 1.2,
        trail_segments: 6,
        ambient_dust: 80,
        draw_distant_windows: true
    };
}

function quality_set(level) {
    if (level < 0 || level >= QUALITY.COUNT) return;
    global.quality_level = level;
    events_emit(EVT.QUALITY_CHANGED, { level: level, name: global.quality_names[level] });
}

function quality_get() {
    return global.quality_profiles[global.quality_level];
}

