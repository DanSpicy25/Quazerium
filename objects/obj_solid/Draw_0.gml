// =====================================================================
// QUAZERIUM — OBJ_SOLID: Industrial Dark-Tech Sci-Fi Geometry Render
// Carbon plating, surface conduit illumination & bevel accents.
// =====================================================================

var c_base = make_color_rgb(26, 32, 42);
var c_plate = make_color_rgb(34, 42, 54);
var c_border = make_color_rgb(52, 64, 82);
var c_conduit = make_color_rgb(0, 200, 240);

// Base block fill
draw_set_color(c_base);
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);

// Inset plate bevel
draw_set_color(c_plate);
draw_rectangle(bbox_left + 2, bbox_top + 4, bbox_right - 2, bbox_bottom - 2, false);

// Top platform conduit strip (player walkway)
draw_set_color(c_conduit);
draw_line_width(bbox_left, bbox_top, bbox_right, bbox_top, 2);

// Perimeter structural border
draw_set_color(c_border);
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);

// Rivet studs on corners
draw_set_color(make_color_rgb(90, 110, 130));
draw_point(bbox_left + 4, bbox_top + 6);
draw_point(bbox_right - 4, bbox_top + 6);
