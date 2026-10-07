// =====================================================================
// QUAZERIUM — OBJ_SOLID: Industrial Dark-Tech Sci-Fi Geometry Render
// High-clarity platform surface, ledge hazard chevrons, carbon plating & drop-shadow.
// =====================================================================

var c_base    = make_color_rgb(20, 25, 34);
var c_plate   = make_color_rgb(28, 36, 48);
var c_border  = make_color_rgb(48, 60, 78);
var c_conduit = make_color_rgb(0, 220, 255);
var c_hazard  = make_color_rgb(240, 190, 20);
var c_dark    = make_color_rgb(12, 16, 22);

var x1 = variable_instance_exists(id, "solid_x1") ? solid_x1 : x;
var y1 = variable_instance_exists(id, "solid_y1") ? solid_y1 : y;
var x2 = variable_instance_exists(id, "solid_x2") ? solid_x2 : (x + 64);
var y2 = variable_instance_exists(id, "solid_y2") ? solid_y2 : (y + 32);

var p_w = x2 - x1;
var p_h = y2 - y1;

// 1. Ambient Drop-Shadow beneath floating platforms
if (y2 < room_height - 64) {
    draw_set_color(c_black);
    draw_set_alpha(0.35);
    draw_rectangle(x1 + 4, y2, x2 - 4, y2 + 14, false);
    draw_set_alpha(1.0);
}

// 2. Base Structural Chassis
draw_set_color(c_base);
draw_rectangle(x1, y1, x2, y2, false);

// 3. Segmented Carbon Armor Panels
var tile_w = 64;
var num_tiles = max(1, floor(p_w / tile_w));
draw_set_color(c_plate);
for (var i = 0; i < num_tiles; i++) {
    var t_x1 = x1 + (i * tile_w) + 2;
    var t_x2 = min(x2 - 2, x1 + ((i + 1) * tile_w) - 2);
    if (t_x2 > t_x1) {
        draw_rectangle(t_x1, y1 + 4, t_x2, y2 - 4, false);
        // Vertical seam line
        draw_set_color(c_dark);
        draw_line(t_x2 + 1, y1 + 4, t_x2 + 1, y2 - 4);
        draw_set_color(c_plate);
    }
}

// 4. Perimeter Structural Frame
draw_set_color(c_border);
draw_rectangle(x1, y1, x2, y2, true);

// 5. Corner Reinforced Rivet Studs
draw_set_color(make_color_rgb(100, 130, 160));
draw_point(x1 + 4, y1 + 6);
draw_point(x2 - 4, y1 + 6);
if (p_h > 32) {
    draw_point(x1 + 4, y2 - 6);
    draw_point(x2 - 4, y2 - 6);
}

// 6. Ledge Hazard Warning Chevrons (Crucial Platform Edge Cue!)
if (p_w >= 48) {
    var h_strip_w = 24;
    // Left edge hazard chevrons
    for (var lz = 0; lz < h_strip_w; lz += 6) {
        draw_set_color(c_hazard);
        draw_line_width(x1 + lz, y1 + 1, x1 + lz + 4, y1 + 5, 2);
    }
    // Right edge hazard chevrons
    for (var rz = 0; rz < h_strip_w; rz += 6) {
        draw_set_color(c_hazard);
        draw_line_width(x2 - rz - 4, y1 + 1, x2 - rz, y1 + 5, 2);
    }
}

// 7. Top Walkway Neon Conduit Rail (100% Collision Readability)
draw_set_color(c_conduit);
draw_line_width(x1, y1, x2, y1, 2);

// Cable junction LED accents on thick pillars
if (p_h >= 64) {
    draw_set_color(c_dark);
    draw_rectangle(x1 + 6, y1 + 18, x2 - 6, y1 + 26, false);
    draw_set_color(c_conduit);
    draw_circle(x1 + (p_w * 0.5), y1 + 22, 2, false);
}
