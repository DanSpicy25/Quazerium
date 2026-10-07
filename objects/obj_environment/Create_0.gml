// =====================================================================
// QUAZERIUM — OBJ_ENVIRONMENT: Arena Background & Atmospheric Layer.
// Deep industrial cyberpunk parallax, atmospheric haze & ambient dust.
// =====================================================================

depth = 500; // Far behind all gameplay geometry

// Ambient dust particles
ambient_count = (global.quality_level == QUALITY.LOW) ? 20 : 60;
dust = array_create(ambient_count);
for (var i = 0; i < ambient_count; i++) {
    dust[i] = {
        x: random(room_width),
        y: random(room_height),
        vx: random_range(-15, 25),
        vy: random_range(-10, -25),
        alpha: random_range(0.15, 0.45),
        size: random_range(1, 2.5)
    };
}
