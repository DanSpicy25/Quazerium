// =====================================================================
// QUAZERIUM — OBJ_ENVIRONMENT: Arena Background, Lighting & Foreground Layer.
// 4-plane composition: Deep skyline, mid industrial trusses, playspace lighting & foreground framing.
// =====================================================================

depth = 500; // Far background layer

time_t = 0;

// Ambient atmospheric dust motes (Pre-allocated pool of 100, active count scaled by quality profile)
dust = array_create(100);
for (var i = 0; i < 100; i++) {
    dust[i] = {
        x: random(room_width),
        y: random(room_height),
        vx: random_range(-18, 28),
        vy: random_range(-12, -30),
        alpha: random_range(0.12, 0.40),
        size: random_range(1, 2.5)
    };
}

// Industrial arena spotlights over key platforms
spotlights = [
    { x: 390,  y: 400, span: 180, col: make_color_rgb(0, 180, 220), alpha: 0.12 },
    { x: 800,  y: 300, span: 220, col: make_color_rgb(255, 200, 80), alpha: 0.10 },
    { x: 1200, y: 220, span: 200, col: make_color_rgb(0, 200, 240), alpha: 0.12 },
    { x: 1550, y: 350, span: 210, col: make_color_rgb(255, 120, 40), alpha: 0.10 }
];
