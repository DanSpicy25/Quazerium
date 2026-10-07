// =====================================================================
// QUAZERIUM — OBJ_LAUNCH_PAD: Draw Event
// Heavy hydraulic pad with upward chevron markings.
// =====================================================================

var c_base = make_color_rgb(26, 32, 42);
var c_spring = make_color_rgb(255, 200, 30);
var compress_offset = spring_compress * 4;

// Base housing
draw_set_color(c_base);
draw_rectangle(x, y + 4, x + pad_w, y + pad_h, false);

// Spring plate
draw_set_color(c_spring);
draw_rectangle(x + 2, y + compress_offset, x + pad_w - 2, y + 4 + compress_offset, false);

// Upward directional chevrons
draw_set_color(make_color_rgb(0, 240, 255));
var mid_x = x + (pad_w / 2);
draw_triangle(mid_x, y - 4 + compress_offset, mid_x - 6, y + compress_offset, mid_x + 6, y + compress_offset, false);
