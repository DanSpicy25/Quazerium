// =====================================================================
// QUAZERIUM — OBJ_GRAPPLE_ANCHOR: High-Tech Magnetic Node Render
// Rotating bracket halo, reactor core, targeting lock-on tether & proximity reticle.
// =====================================================================

pulse_timer += qz_raw_dt() * 3.5;

var c_core   = make_color_rgb(0, 245, 255);
var c_corona = make_color_rgb(0, 160, 230);
var c_standby = make_color_rgb(0, 90, 140);

// Check player proximity
var p = instance_nearest(x, y, obj_player);
var is_in_range = false;
var p_dist = 99999;
if (p != noone) {
    p_dist = point_distance(x, y, p.x, p.y);
    if (p_dist <= global.cfg.grapple.range) {
        is_in_range = true;
    }
}

// 1. Proximity Targeting Reticle & Lock-on Tether
if (is_in_range) {
    // Dynamic luminous tether
    var t_alpha = 0.20 + (sin(pulse_timer * 2.5) * 0.12);
    draw_set_color(c_core);
    draw_set_alpha(t_alpha);
    draw_line_width(x, y, p.x, p.y, 2);
    draw_set_alpha(1.0);

    // Lock-on brackets around node
    var ret_size = radius + 10 + (sin(pulse_timer * 3.0) * 2);
    draw_set_color(c_core);
    draw_circle(x, y, ret_size, true);
}

// 2. Outer Rotating Magnetic Brackets
var r_ring = radius + (sin(pulse_timer) * 1.5);
draw_set_color(is_in_range ? c_corona : c_standby);
draw_circle(x, y, r_ring, true);

for (var k = 0; k < 4; k++) {
    var ang = (pulse_timer * 35) + (k * 90);
    var kx = x + lengthdir_x(r_ring + 4, ang);
    var ky = y + lengthdir_y(r_ring + 4, ang);
    draw_set_color(is_in_range ? c_core : c_standby);
    draw_circle(kx, ky, 2.5, false);
    // Bracket tooth prong
    var px2 = x + lengthdir_x(r_ring + 8, ang);
    var py2 = y + lengthdir_y(r_ring + 8, ang);
    draw_line_width(kx, ky, px2, py2, 2);
}

// 3. Glowing Core Reactor
draw_set_color(is_in_range ? c_corona : c_standby);
draw_circle(x, y, 7, false);
draw_set_color(is_in_range ? c_core : make_color_rgb(0, 180, 240));
draw_circle(x, y, 4.5, false);
draw_set_color(c_white);
draw_circle(x, y, 2.0, false);
