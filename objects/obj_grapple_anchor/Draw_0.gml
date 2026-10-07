// =====================================================================
// QUAZERIUM — OBJ_GRAPPLE_ANCHOR: Sacred Brutalism Reliquary Keystone
// Monolithic carved basalt ring, bone tooth bevels, relic-gold core rune,
// ethereal targeting tether and trailing ceremonial prayer streamers.
// =====================================================================

pulse_timer += qz_raw_dt() * 3.5;

var c_ink     = make_color_rgb(14, 15, 18);
var c_basalt  = make_color_rgb(32, 35, 44);
var c_bone    = make_color_rgb(238, 235, 224);
var c_gold    = make_color_rgb(212, 175, 55);
var c_standby = make_color_rgb(60, 65, 75);

// Check player proximity & clear line of sight
var p = instance_nearest(x, y, obj_player);
var is_in_range = false;
var p_dist = 99999;
if (p != noone) {
    p_dist = point_distance(x, y, p.x, p.y);
    if (p_dist <= global.cfg.grapple.range) {
        // Only consider in range if not blocked by solid geometry
        if (collision_line(x, y, p.x, p.y, obj_solid, true, true) == noone) {
            is_in_range = true;
        }
    }
}

// 1. Ethereal Targeting Thread & Diamond Reticle
if (is_in_range) {
    var t_alpha = 0.22 + (sin(pulse_timer * 2.5) * 0.10);
    draw_set_color(c_bone);
    draw_set_alpha(t_alpha);
    draw_line_width(x, y, p.x, p.y, 1.5);
    draw_set_alpha(1.0);

    // Sacred Diamond Reticle around Keystone
    var ret_size = radius + 9 + (sin(pulse_timer * 3.0) * 1.5);
    draw_set_color(c_gold);
    draw_line(x, y - ret_size, x + ret_size, y);
    draw_line(x + ret_size, y, x, y + ret_size);
    draw_line(x, y + ret_size, x - ret_size, y);
    draw_line(x - ret_size, y, x, y - ret_size);
}

// 2. Trailing Prayer Talisman Streamer Hanging Below Keystone
var ribbon_len = 16 + (sin(pulse_timer * 1.2) * 2);
draw_set_color(c_bone);
draw_line_width(x, y + radius, x + (sin(pulse_timer * 0.8) * 3), y + radius + ribbon_len, 2);
draw_set_color(c_ink);
draw_point(x, y + radius + (ribbon_len * 0.5));

// 3. Monolithic Carved Basalt Ring Body
var r_ring = radius + (sin(pulse_timer) * 0.8);
draw_set_color(c_ink);
draw_circle(x, y, r_ring + 2, false);
draw_set_color(c_basalt);
draw_circle(x, y, r_ring, false);
draw_set_color(is_in_range ? c_gold : c_standby);
draw_circle(x, y, r_ring, true);

// 4. Cardinal Bone Teeth Keystones
for (var k = 0; k < 4; k++) {
    var ang = (pulse_timer * 18) + (k * 90);
    var kx = x + lengthdir_x(r_ring, ang);
    var ky = y + lengthdir_y(r_ring, ang);
    var px2 = x + lengthdir_x(r_ring + 5, ang);
    var py2 = y + lengthdir_y(r_ring + 5, ang);
    draw_set_color(c_bone);
    draw_line_width(kx, ky, px2, py2, 2);
}

// 5. Relic-Gold Soul Rune Core
draw_set_color(c_ink);
draw_circle(x, y, 6, false);
draw_set_color(is_in_range ? c_gold : c_standby);
draw_circle(x, y, 4, false);
draw_set_color(c_bone);
draw_point(x, y);
