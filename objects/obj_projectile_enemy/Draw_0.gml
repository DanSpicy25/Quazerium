// =====================================================================
// QUAZERIUM — OBJ_PROJECTILE_ENEMY: Plasma bolt render
// Distinct color feedback for hostile vs reflected player bolt.
// =====================================================================

var c_core = reflected ? make_color_rgb(0, 240, 255) : make_color_rgb(255, 60, 40);
var c_glow = reflected ? make_color_rgb(80, 180, 255) : make_color_rgb(255, 160, 40);

// Inner core
draw_set_color(c_white);
draw_circle(x, y, bbox_r * 0.5, false);

// Energy envelope
draw_set_color(c_core);
draw_circle(x, y, bbox_r, false);

// Outer pulsing ring
var ring_r = bbox_r + 2 + (sin(current_time * 0.02) * 2);
draw_set_color(c_glow);
draw_circle(x, y, ring_r, true);
