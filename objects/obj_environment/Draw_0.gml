// =====================================================================
// QUAZERIUM — OBJ_ENVIRONMENT: Background Parallax & Scenery Render
// =====================================================================

var cam = view_camera[0];
var cx = camera_get_view_x(cam);
var cy = camera_get_view_y(cam);
var cw = camera_get_view_width(cam);
var ch = camera_get_view_height(cam);

// 1. Far Skyline Layer (0.12x Parallax)
var c_sky_top = make_color_rgb(10, 14, 22);
var c_sky_bot = make_color_rgb(22, 28, 42);
draw_rectangle_color(cx, cy, cx + cw, cy + ch, c_sky_top, c_sky_top, c_sky_bot, c_sky_bot, false);

var px1 = cx * 0.12;
var c_bldg1 = make_color_rgb(16, 20, 30);
var c_bldg_edge = make_color_rgb(32, 40, 58);

// Procedural repeating skyline silhouettes
var bldg_w = 140;
var start_idx = floor((cx - px1 - 200) / bldg_w);
var end_idx = ceil((cx - px1 + cw + 200) / bldg_w);

for (var k = start_idx; k <= end_idx; k++) {
    var bx = (k * bldg_w) + px1;
    // Deterministic procedural heights based on index
    var h_hash = ((k * 137) mod 180) + 260;
    var by = room_height - h_hash;

    draw_set_color(c_bldg1);
    draw_rectangle(bx, by, bx + bldg_w - 6, room_height, false);
    draw_set_color(c_bldg_edge);
    draw_rectangle(bx, by, bx + bldg_w - 6, room_height, true);

    // Antenna & red warning beacon
    var ant_x = bx + (bldg_w / 2);
    draw_set_color(c_bldg_edge);
    draw_line(ant_x, by, ant_x, by - 24);
    draw_set_color(make_color_rgb(255, 60, 60));
    draw_circle(ant_x, by - 24, 2, false);
}

// 2. Midground Industrial Truss & Conduits (0.35x Parallax)
var px2 = cx * 0.35;
var c_truss = make_color_rgb(26, 32, 46);
var truss_spacing = 280;
var t_start = floor((cx - px2 - 200) / truss_spacing);
var t_end = ceil((cx - px2 + cw + 200) / truss_spacing);

draw_set_color(c_truss);
for (var m = t_start; m <= t_end; m++) {
    var tx = (m * truss_spacing) + px2;
    draw_line_width(tx, 0, tx + 60, room_height, 4);
    draw_line_width(tx + 60, 0, tx, room_height, 4);
    draw_line_width(tx - 40, 200, tx + 100, 200, 3);
}

// 3. Ambient floating dust / motes
draw_set_color(make_color_rgb(180, 220, 255));
for (var i = 0; i < ambient_count; i++) {
    var d = dust[i];
    if (d.x >= cx - 20 && d.x <= cx + cw + 20 && d.y >= cy - 20 && d.y <= cy + ch + 20) {
        draw_set_alpha(d.alpha);
        draw_circle(d.x, d.y, d.size, false);
    }
}
draw_set_alpha(1.0);

