// =====================================================================
// QUAZERIUM — OBJ_ENVIRONMENT: Deep Background & Midground Architecture (Depth 500)
// High-tech industrial cyberpunk skyline, illuminated midground trusses & holographic signs.
// =====================================================================

var cam = view_camera[0];
var cx = camera_get_view_x(cam);
var cy = camera_get_view_y(cam);
var cw = camera_get_view_width(cam);
var ch = camera_get_view_height(cam);

// ---------------------------------------------------------------------
// 1. FAR SKY DOME GRADIENT (Atmospheric Night Haze)
// ---------------------------------------------------------------------
var c_sky_top = make_color_rgb(6, 9, 15);
var c_sky_bot = make_color_rgb(14, 22, 34);
draw_rectangle_color(cx, cy, cx + cw, cy + ch, c_sky_top, c_sky_top, c_sky_bot, c_sky_bot, false);

// ---------------------------------------------------------------------
// 2. DEEP MEGACITY SKYLINE (0.08x Parallax)
// ---------------------------------------------------------------------
var px_sky = cx * 0.08;
var py_sky = cy * 0.08;
var c_tower = make_color_rgb(12, 16, 24);
var c_tower_rim = make_color_rgb(22, 30, 44);
var c_beacon_on = make_color_rgb(255, 45, 55);
var c_beacon_off = make_color_rgb(60, 15, 20);

var tower_w = 120;
var t_start = floor((cx - px_sky - 200) / tower_w);
var t_end   = ceil((cx - px_sky + cw + 200) / tower_w);

for (var k = t_start; k <= t_end; k++) {
    var bx = (k * tower_w) + px_sky;
    // Deterministic pseudo-random height hash
    var h_hash = (((k * 157 + 31) mod 180) + 280);
    var by = room_height - h_hash + py_sky;

    // Megastructure silhouette
    draw_set_color(c_tower);
    draw_rectangle(bx, by, bx + tower_w - 6, room_height, false);
    draw_set_color(c_tower_rim);
    draw_rectangle(bx, by, bx + tower_w - 6, room_height, true);

    // Antenna mast & aviation hazard beacon
    var ant_x = bx + (tower_w * 0.5);
    draw_line_width(ant_x, by, ant_x, by - 28, 2);

    // Blinking hazard light (alternating phases per building)
    var blink_phase = sin((time_t * 3.5) + (k * 1.7));
    draw_set_color(blink_phase > 0.2 ? c_beacon_on : c_beacon_off);
    draw_circle(ant_x, by - 28, 2.5, false);

    // Window matrix accents (non-intrusive ambient city life)
    if (global.quality_level != QUALITY.LOW) {
        var num_floors = min(8, floor(h_hash / 40));
        for (var fl = 1; fl < num_floors; fl++) {
            var fy = by + (fl * 32);
            // Window lights on select floors
            if (((k + fl) mod 3) == 0) {
                var c_win = (((k * 7 + fl) mod 2) == 0) ? make_color_rgb(240, 180, 50) : make_color_rgb(0, 180, 220);
                draw_set_color(c_win);
                draw_set_alpha(0.35);
                draw_rectangle(bx + 14, fy, bx + 22, fy + 4, false);
                draw_rectangle(bx + 32, fy, bx + 40, fy + 4, false);
                draw_rectangle(bx + 50, fy, bx + 58, fy + 4, false);
                draw_set_alpha(1.0);
            }
        }
    }
}

// ---------------------------------------------------------------------
// 3. MIDGROUND INDUSTRIAL TRUSSES & DUCTS (0.24x Parallax)
// ---------------------------------------------------------------------
var px_mid = cx * 0.24;
var py_mid = cy * 0.24;
var c_truss = make_color_rgb(22, 28, 40);
var c_pipe  = make_color_rgb(18, 24, 34);
var c_accent = make_color_rgb(38, 48, 68);

var truss_spacing = 320;
var m_start = floor((cx - px_mid - 250) / truss_spacing);
var m_end   = ceil((cx - px_mid + cw + 250) / truss_spacing);

for (var m = m_start; m <= m_end; m++) {
    var mx = (m * truss_spacing) + px_mid;

    // Diagonal cross lattice girders
    draw_set_color(c_truss);
    draw_line_width(mx, 0, mx + 80, room_height, 4);
    draw_line_width(mx + 80, 0, mx, room_height, 4);

    // Horizontal heavy conduit bridges
    draw_set_color(c_pipe);
    draw_rectangle(mx - 80, 280 + py_mid, mx + 160, 296 + py_mid, false);
    draw_set_color(c_accent);
    draw_rectangle(mx - 80, 280 + py_mid, mx + 160, 296 + py_mid, true);

    // Vertical structural tension cables
    draw_set_color(c_accent);
    draw_line(mx + 40, 0, mx + 40, room_height);
}

// Holographic Arena Sector Signage in Midground
var sign_x = (room_width * 0.5) - (cx * 0.15);
var sign_y = 180 + py_mid;
draw_set_color(make_color_rgb(0, 200, 240));
draw_set_alpha(0.20 + (sin(time_t * 1.8) * 0.08));
draw_rectangle(sign_x - 180, sign_y - 12, sign_x + 180, sign_y + 12, true);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_transformed(sign_x, sign_y, "SECTOR-09 // CYBERNETICS PROVING GROUND", 1.0, 1.0, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1.0);

// ---------------------------------------------------------------------
// 4. AMBIENT ATMOSPHERIC DUST MOTES
// ---------------------------------------------------------------------
draw_set_color(make_color_rgb(180, 225, 255));
for (var i = 0; i < ambient_count; i++) {
    var d = dust[i];
    if (d.x >= cx - 30 && d.x <= cx + cw + 30 && d.y >= cy - 30 && d.y <= cy + ch + 30) {
        draw_set_alpha(d.alpha);
        draw_circle(d.x, d.y, d.size, false);
    }
}
draw_set_alpha(1.0);
