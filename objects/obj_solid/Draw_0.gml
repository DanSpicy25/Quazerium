// =====================================================================
// QUAZERIUM — OBJ_SOLID: Procedural clean render
// =====================================================================

var c_base = make_color_rgb(40, 44, 52);
var c_edge = make_color_rgb(70, 78, 92);
var c_top  = make_color_rgb(90, 100, 118);

draw_set_color(c_base);
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);

// Top edge accent (platform surface)
draw_set_color(c_top);
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_top + 3, false);

// Perimeter border
draw_set_color(c_edge);
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);

