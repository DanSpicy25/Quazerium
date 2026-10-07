// =====================================================================
// QUAZERIUM — OBJ_ENEMY_BASE: Cybernetic Automaton Stylized Render
// Distinct visual cues for windup telegraphs, hit flash, stun & status.
// =====================================================================

var c_body = make_color_rgb(46, 22, 28);
var c_rim  = make_color_rgb(240, 50, 60);

if (hit_flash > 0) {
    c_body = c_white;
    c_rim  = c_white;
} else if (state == ESTATE.WINDUP) {
    c_rim = make_color_rgb(255, 140, 20); // Orange warning cue
} else if (state == ESTATE.STUNNED) {
    c_body = make_color_rgb(26, 32, 60);
    c_rim  = make_color_rgb(100, 140, 255); // Electric blue
}

// 1. Armored Automaton Frame
if (is_callable(draw_body_fn)) {
    draw_body_fn(c_body, c_rim);
} else {
    draw_set_color(c_body);
    draw_rectangle(x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh, false);
    draw_set_color(c_rim);
    draw_rectangle(x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh, true);

    // Center core reactor
    draw_set_color(c_rim);
    draw_circle(x, y - 2, 4, false);

    // Sensor eye
    var eye_x = x + (facing * (bbox_hw - 4));
    var eye_y = y - 6;
    draw_set_color(c_white);
    draw_circle(eye_x, eye_y, 2.5, false);
}

// 2. Windup Telegraph Indicator (Crucial Parry Cue!)
if (state == ESTATE.WINDUP) {
    // Red danger exclamation triangle above head
    var warn_y = y - bbox_hh - 16 + (sin(current_time * 0.03) * 2);
    draw_set_color(make_color_rgb(255, 40, 40));
    draw_triangle(x, warn_y - 8, x - 6, warn_y + 4, x + 6, warn_y + 4, false);
    draw_set_color(c_white);
    draw_line_width(x, warn_y - 4, x, warn_y, 2);
    draw_point(x, warn_y + 2);

    // Directional telegraph strike zone
    var atk_w = 44;
    var ox = (facing > 0) ? x + 10 : x - 10 - atk_w;
    draw_set_color(make_color_rgb(255, 100, 20));
    draw_set_alpha(0.25);
    draw_rectangle(ox, y - 15, ox + atk_w, y + 15, false);
    draw_set_alpha(1.0);
    draw_rectangle(ox, y - 15, ox + atk_w, y + 15, true);
}

// 3. Stun Cue (Orbiting Stars / Sparks)
if (state == ESTATE.STUNNED) {
    var stun_y = y - bbox_hh - 10;
    var t_spin = current_time * 0.008;
    draw_set_color(make_color_rgb(140, 180, 255));
    for (var s = 0; s < 3; s++) {
        var sa = t_spin + (s * (2 * pi / 3));
        var sx = x + (cos(sa) * 12);
        var sy = stun_y + (sin(sa) * 4);
        draw_circle(sx, sy, 2, false);
    }
}

// 4. Modern Floating Health Bar
if (hp < max_hp && max_hp < 9999) {
    var bar_w = 34;
    var bar_h = 4;
    var bx = x - (bar_w / 2);
    var by = y - bbox_hh - 8;
    var pct = clamp(hp / max_hp, 0, 1);

    draw_set_color(make_color_rgb(15, 18, 24));
    draw_rectangle(bx - 1, by - 1, bx + bar_w + 1, by + bar_h + 1, false);

    var c_bar = (pct > 0.3) ? make_color_rgb(230, 50, 60) : make_color_rgb(255, 180, 40);
    draw_set_color(c_bar);
    draw_rectangle(bx, by, bx + (bar_w * pct), by + bar_h, false);
}

// 5. Element Status Indicator
if (element_status != ELEMENT.NONE) {
    var c_elem = c_white;
    switch (element_status) {
        case ELEMENT.FIRE:  c_elem = make_color_rgb(255, 100, 30); break;
        case ELEMENT.WATER: c_elem = make_color_rgb(40, 180, 255); break;
        case ELEMENT.EARTH: c_elem = make_color_rgb(200, 140, 60); break;
        case ELEMENT.WIND:  c_elem = make_color_rgb(80, 240, 160); break;
    }
    draw_set_color(c_elem);
    draw_circle(x, y - bbox_hh - 14, 3.5, false);
    draw_set_color(c_white);
    draw_circle(x, y - bbox_hh - 14, 1.5, false);
}
