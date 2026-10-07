// =====================================================================
// QUAZERIUM — QUALITY & PERFORMANCE: Hardware scaling (LOW, MEDIUM, HIGH).
// Protects low-end target (Intel HD 2500 / i5-3470 / HDD).
// Gameplay remains strictly identical across all profiles.
// =====================================================================

function quality_system_init() {
    global.quality_level = QUALITY.MEDIUM;
    global.quality_profiles = array_create(QUALITY.COUNT);

    // LOW: Minimal particles, no heavy shaders, capped decals, strict allocation bounds
    global.quality_profiles[QUALITY.LOW] = {
        max_particles: 100,
        max_decals: 50,
        enable_shaders: false,
        enable_lighting: false,
        shake_mult: 0.8,
        trail_segments: 4
    };

    // MEDIUM: Balanced for standard PC
    global.quality_profiles[QUALITY.MEDIUM] = {
        max_particles: 500,
        max_decals: 200,
        enable_shaders: true,
        enable_lighting: true,
        shake_mult: 1.0,
        trail_segments: 10
    };

    // HIGH: Rich visual effects and full post-processing
    global.quality_profiles[QUALITY.HIGH] = {
        max_particles: 2000,
        max_decals: 1000,
        enable_shaders: true,
        enable_lighting: true,
        shake_mult: 1.2,
        trail_segments: 24
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

