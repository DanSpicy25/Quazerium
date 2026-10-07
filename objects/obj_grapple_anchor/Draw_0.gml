// =====================================================================
// QUAZERIUM — OBJ_GRAPPLE_ANCHOR: High-Tech Magnetic Node Render
// Rotating halo, pulsing reactor core & player targeting tether.
// =====================================================================

pulse_timer += qz_raw_dt() * 3.5;

var c_core = make_color_rgb(0, 240, 255);
var c_ring = make_color_rgb(0, 150, 210);

// Check player proximity
var p = instance_nearest(x, y, obj_player);
var is_in_range = false;
if (p != noone) {
    var p_dist = point_distance(x, y, p.x, p.y);
    if (p_dist <= global.cfg.grapple.range) {
        is_in_range = true;
        // Faint target tether line
        draw_set_color(c_core);
        draw_set_alpha(0.25 + (sin(pulse_timer * 2.0) * 0.15));
        draw_line(x, y, p.x, p.y);
        draw_set_alpha(1.0);
    }
}

// Outer rotating brackets
var r_ring = radius + (sin(pulse_timer) * 2);
draw_set_color(is_in_range ? c_core : c_ring);
draw_circle(x, y, r_ring, true);

for (var k = 0; k < 4; k++) {
    var ang = (pulse_timer * 30) + (k * 90);
    var kx = x + lengthdir_x(r_ring + 4, ang);
    var ky = y + lengthdir_y(r_ring + 4, ang);
    draw_circle(kx, ky, 2, false);
}

// Glowing core node
draw_set_color(c_core);
draw_circle(x, y, 5, false);
draw_set_color(c_white);
draw_circle(x, y, 2.5, false);
