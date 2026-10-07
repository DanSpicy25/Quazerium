// =====================================================================
// QUAZERIUM — OBJ_GRAPPLE_ANCHOR: Procedural render
// =====================================================================

pulse_timer += qz_raw_dt() * 3;
var r_pulse = radius + (sin(pulse_timer) * 2);

var c_core = make_color_rgb(0, 220, 255);
var c_ring = make_color_rgb(0, 140, 200);

draw_set_color(c_ring);
draw_circle(x, y, r_pulse, true);
draw_set_color(c_core);
draw_circle(x, y, 5, false);

