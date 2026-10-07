// =====================================================================
// QUAZERIUM — OBJ_ENERGY_CANISTER: Draw Event
// Pressurized canister with glowing cyan plasma liquid.
// =====================================================================

var c_hull = make_color_rgb(32, 40, 52);
var c_glow = make_color_rgb(0, 230, 255);

// Outer cylinder
draw_set_color(c_hull);
draw_roundrect(x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh, false);
draw_set_color(c_glow);
draw_roundrect(x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh, true);

// Inner liquid glass chamber
var pulse = 0.6 + (sin(current_time * 0.02) * 0.4);
draw_set_color(c_glow);
draw_set_alpha(pulse);
draw_rectangle(x - bbox_hw + 3, y - bbox_hh + 4, x + bbox_hw - 3, y + bbox_hh - 4, false);
draw_set_alpha(1.0);

// Warning lightning badge
draw_set_color(c_white);
draw_line(x - 2, y - 4, x + 2, y);
draw_line(x + 2, y, x - 1, y + 1);
draw_line(x - 1, y + 1, x + 3, y + 5);
