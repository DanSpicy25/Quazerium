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

var p_w = bbox_right - bbox_left;
var p_h = bbox_bottom - bbox_top;

// 1. Ambient Drop-Shadow beneath floating platforms
if (bbox_bottom < room_height - 64) {
    draw_set_color(c_black);
    draw_set_alpha(0.35);
    draw_rectangle(bbox_left + 4, bbox_bottom, bbox_right - 4, bbox_bottom + 14, false);
    draw_set_alpha(1.0);
}

// 2. Base Structural Chassis
draw_set_color(c_base);
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);

// 3. Segmented Carbon Armor Panels
var tile_w = 64;
var num_tiles = max(1, floor(p_w / tile_w));
draw_set_color(c_plate);
for (var i = 0; i < num_tiles; i++) {
    var t_x1 = bbox_left + (i * tile_w) + 2;
    var t_x2 = min(bbox_right - 2, bbox_left + ((i + 1) * tile_w) - 2);
    if (t_x2 > t_x1) {
        draw_rectangle(t_x1, bbox_top + 4, t_x2, bbox_bottom - 4, false);
        // Vertical seam line
        draw_set_color(c_dark);
        draw_line(t_x2 + 1, bbox_top + 4, t_x2 + 1, bbox_bottom - 4);
        draw_set_color(c_plate);
    }
}

// 4. Perimeter Structural Frame
draw_set_color(c_border);
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);

// 5. Corner Reinforced Rivet Studs
draw_set_color(make_color_rgb(100, 130, 160));
draw_point(bbox_left + 4, bbox_top + 6);
draw_point(bbox_right - 4, bbox_top + 6);
if (p_h > 32) {
    draw_point(bbox_left + 4, bbox_bottom - 6);
    draw_point(bbox_right - 4, bbox_bottom - 6);
}

// 6. Ledge Hazard Warning Chevrons (Crucial Platform Edge Cue!)
if (p_w >= 48) {
    var h_strip_w = 24;
    // Left edge hazard chevrons
    for (var lz = 0; lz < h_strip_w; lz += 6) {
        draw_set_color(c_hazard);
        draw_line_width(bbox_left + lz, bbox_top + 1, bbox_left + lz + 4, bbox_top + 5, 2);
    }
    // Right edge hazard chevrons
    for (var rz = 0; rz < h_strip_w; rz += 6) {
        draw_set_color(c_hazard);
        draw_line_width(bbox_right - rz - 4, bbox_top + 1, bbox_right - rz, bbox_top + 5, 2);
    }
}

// 7. Top Walkway Neon Conduit Rail (100% Collision Readability)
draw_set_color(c_conduit);
draw_line_width(bbox_left, bbox_top, bbox_right, bbox_top, 2);

// Cable junction LED accents on thick pillars
if (p_h >= 64) {
    draw_set_color(c_dark);
    draw_rectangle(bbox_left + 6, bbox_top + 18, bbox_right - 6, bbox_top + 26, false);
    draw_set_color(c_conduit);
    draw_circle(bbox_left + (p_w * 0.5), bbox_top + 22, 2, false);
}
