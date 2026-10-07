// =====================================================================
// QUAZERIUM — OBJ_ENVIRONMENT: Step event
// Updates ambient dust motes drifting across the arena.
// =====================================================================

var dt = qz_raw_dt();

for (var i = 0; i < ambient_count; i++) {
    var d = dust[i];
    d.x += d.vx * dt;
    d.y += d.vy * dt;

    if (d.x < 0) d.x += room_width;
    if (d.x > room_width) d.x -= room_width;
    if (d.y < 0) d.y += room_height;
    if (d.y > room_height) d.y -= room_height;
}

