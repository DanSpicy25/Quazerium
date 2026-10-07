// =====================================================================
// QUAZERIUM — OBJ_ENEMY_BASE: Occult Adversary Stickman Render
// True procedural stickman silhouette with horned effigy mask, central spine,
// articulated 2-segment stick legs with knee nodes, articulated stick arms
// holding a jagged cleaver, telegraph cues, stun stars, and floating health.
// ABSOLUTELY ZERO SOLID RECTANGLE BODY BLOCKS!
// =====================================================================

var c_body = make_color_rgb(32, 18, 24);
var c_rim  = make_color_rgb(240, 50, 60);

if (hit_flash > 0) {
    c_body = c_white;
    c_rim  = c_white;
} else if (state == ESTATE.WINDUP) {
    c_rim  = make_color_rgb(255, 140, 20); // Orange warning cue
    c_body = make_color_rgb(50, 25, 15);
} else if (state == ESTATE.STUNNED) {
    c_body = make_color_rgb(26, 32, 60);
    c_rim  = make_color_rgb(100, 140, 255); // Electric blue
}

// 1. Procedural Stickman Effigy (or custom specialized stickman if draw_body_fn is provided)
if (is_callable(draw_body_fn)) {
    draw_body_fn(c_body, c_rim);
} else {
    // --- STICKMAN ADVERSARY ANATOMY ---
    var eh_x   = x;
    var eh_y   = y - (bbox_hh * 0.65);
    var eh_r   = 6.5;
    var e_neck = eh_y + eh_r;
    var e_hip_y = y + (bbox_hh * 0.22);
    var e_sh_w = 10;
    var e_sh_y = e_neck + 3;
    var e_hp_w = 7;
    var e_foot_y = y + bbox_hh;

    // Ground Contact Shadow
    draw_set_color(c_black);
    draw_set_alpha(0.50);
    draw_ellipse(x - (bbox_hw * 0.9), y + bbox_hh - 2, x + (bbox_hw * 0.9), y + bbox_hh + 2, false);
    draw_set_alpha(1.0);

    // --- LEGS (Articulated 2-segment with knees) ---
    var e_hip_l = eh_x - (e_hp_w * 0.7);
    var e_hip_r = eh_x + (e_hp_w * 0.7);
    var ek1_x = e_hip_l; var ek1_y = e_hip_y + 8; var ef1_x = e_hip_l; var ef1_y = e_foot_y;
    var ek2_x = e_hip_r; var ek2_y = e_hip_y + 8; var ef2_x = e_hip_r; var ef2_y = e_foot_y;

    if (state == ESTATE.CHASE) {
        var e_walk = current_time * 0.012;
        var ew_sw1 = sin(e_walk) * 11;
        var ew_sw2 = sin(e_walk + pi) * 11;

        ek1_x = e_hip_l + (ew_sw1 * facing * 0.6);
        ek1_y = e_hip_y + 8;
        ef1_x = e_hip_l + (ew_sw1 * facing);
        ef1_y = e_foot_y;

        ek2_x = e_hip_r + (ew_sw2 * facing * 0.6);
        ek2_y = e_hip_y + 8;
        ef2_x = e_hip_r + (ew_sw2 * facing);
        ef2_y = e_foot_y;
    } else if (state == ESTATE.STUNNED) {
        // Buckled, trembling knees
        var trem = sin(current_time * 0.04) * 2;
        ek1_x = e_hip_l - 4 + trem; ek1_y = e_hip_y + 10; ef1_x = e_hip_l - 6; ef1_y = e_foot_y;
        ek2_x = e_hip_r + 4 - trem; ek2_y = e_hip_y + 10; ef2_x = e_hip_r + 6; ef2_y = e_foot_y;
    } else {
        // Sinister martial crouch
        ek1_x = e_hip_l - 3; ek1_y = e_hip_y + 9; ef1_x = e_hip_l - 5; ef1_y = e_foot_y;
        ek2_x = e_hip_r + 3; ek2_y = e_hip_y + 9; ef2_x = e_hip_r + 5; ef2_y = e_foot_y;
    }

    draw_set_color(c_rim);
    draw_line_width(e_hip_l, e_hip_y, ek1_x, ek1_y, 3.0);
    draw_line_width(ek1_x, ek1_y, ef1_x, ef1_y, 2.5);
    draw_line_width(e_hip_r, e_hip_y, ek2_x, ek2_y, 3.0);
    draw_line_width(ek2_x, ek2_y, ef2_x, ef2_y, 2.5);

    draw_set_color(c_body);
    draw_line_width(e_hip_l, e_hip_y, ek1_x, ek1_y, 1.5);
    draw_line_width(ek1_x, ek1_y, ef1_x, ef1_y, 1.2);
    draw_line_width(e_hip_r, e_hip_y, ek2_x, ek2_y, 1.5);
    draw_line_width(ek2_x, ek2_y, ef2_x, ef2_y, 1.2);

    draw_set_color(c_rim);
    draw_circle(ek1_x, ek1_y, 2.0, false);
    draw_circle(ek2_x, ek2_y, 2.0, false);

    // --- TORSO / SPINE ---
    // Central Spine
    draw_set_color(c_rim);
    draw_line_width(eh_x, e_neck, eh_x, e_hip_y, 3.5);
    draw_set_color(c_body);
    draw_line_width(eh_x, e_neck, eh_x, e_hip_y, 1.8);

    // Shoulders
    draw_set_color(c_rim);
    draw_line_width(eh_x - e_sh_w, e_sh_y, eh_x + e_sh_w, e_sh_y, 3.0);
    draw_set_color(c_body);
    draw_line_width(eh_x - e_sh_w, e_sh_y, eh_x + e_sh_w, e_sh_y, 1.5);

    // Pelvis
    draw_set_color(c_rim);
    draw_line_width(eh_x - e_hp_w, e_hip_y, eh_x + e_hp_w, e_hip_y, 2.5);

    // Jagged Rib Barbs
    var er1 = lerp(e_sh_y, e_hip_y, 0.40);
    var er2 = lerp(e_sh_y, e_hip_y, 0.70);
    draw_line_width(eh_x - 5, er1, eh_x + 5, er1, 2.0);
    draw_line_width(eh_x - 4, er2, eh_x + 4, er2, 2.0);

    // Occult Core Relic at Sternum
    draw_set_color(c_rim);
    draw_circle(eh_x, er1, 2.5, false);

    // --- HEAD & HORNS ---
    draw_set_color(c_body);
    draw_circle(eh_x, eh_y, eh_r, false);
    draw_set_color(c_rim);
    draw_circle(eh_x, eh_y, eh_r, true);

    // Jagged Curved Horns
    draw_line_width(eh_x - 3, eh_y - eh_r + 2, eh_x - (facing * 4) - 3, eh_y - eh_r - 7, 2.5);
    draw_line_width(eh_x + 3, eh_y - eh_r + 2, eh_x + (facing * 4) + 3, eh_y - eh_r - 7, 2.5);
    draw_set_color(c_body);
    draw_line(eh_x - 3, eh_y - eh_r + 2, eh_x - (facing * 4) - 3, eh_y - eh_r - 7);
    draw_line(eh_x + 3, eh_y - eh_r + 2, eh_x + (facing * 4) + 3, eh_y - eh_r - 7);

    // Optic Eye Ember
    var eye_x = eh_x + (facing * 3);
    var eye_y = eh_y;
    draw_set_color(c_white);
    draw_circle(eye_x, eye_y, 2, false);
    draw_set_color(c_rim);
    draw_point(eye_x, eye_y);

    // --- ARMS & JAGGED CLEAVER ---
    var sh_front = (facing > 0) ? (eh_x + e_sh_w) : (eh_x - e_sh_w);
    var sh_back  = (facing > 0) ? (eh_x - e_sh_w) : (eh_x + e_sh_w);

    if (state == ESTATE.WINDUP) {
        // Arms raised menacingly high overhead preparing to strike
        var wp_hand_x = eh_x + (facing * 4);
        var wp_hand_y = eh_y - 12;
        var wp_blade_x = wp_hand_x + (facing * 16);
        var wp_blade_y = wp_hand_y - 14;

        draw_set_color(c_rim);
        draw_line_width(sh_front, e_sh_y, wp_hand_x, wp_hand_y, 3.0);
        draw_line_width(sh_back, e_sh_y, wp_hand_x, wp_hand_y, 3.0);

        // Cleaver blade raised high with warning glow
        draw_set_color(make_color_rgb(255, 140, 20));
        draw_line_width(wp_hand_x, wp_hand_y, wp_blade_x, wp_blade_y, 4.5);
        draw_set_color(c_white);
        draw_line_width(wp_hand_x, wp_hand_y, wp_blade_x, wp_blade_y, 1.5);
    } else if (state == ESTATE.ATTACK) {
        // Lunging cleaver thrust
        var atk_hand_x = eh_x + (facing * 16);
        var atk_hand_y = y - 2;
        var atk_blade_x = atk_hand_x + (facing * 18);
        var atk_blade_y = atk_hand_y;

        draw_set_color(c_rim);
        draw_line_width(sh_front, e_sh_y, atk_hand_x, atk_hand_y, 3.0);
        draw_set_color(make_color_rgb(255, 60, 60));
        draw_line_width(atk_hand_x, atk_hand_y, atk_blade_x, atk_blade_y, 5.0);
        draw_set_color(c_white);
        draw_line_width(atk_hand_x, atk_hand_y, atk_blade_x, atk_blade_y, 1.5);
    } else if (state == ESTATE.STUNNED) {
        // Limp drooping arms
        draw_set_color(c_rim);
        draw_line_width(sh_front, e_sh_y, sh_front + 2, e_sh_y + 14, 2.5);
        draw_line_width(sh_back, e_sh_y, sh_back - 2, e_sh_y + 14, 2.5);
    } else {
        // Predatory stalking posture holding cleaver
        var idl_elbow_x = sh_front + (facing * 6);
        var idl_elbow_y = e_sh_y + 6;
        var idl_hand_x  = sh_front + (facing * 10);
        var idl_hand_y  = y - 2;
        var idl_tip_x   = idl_hand_x + (facing * 12);
        var idl_tip_y   = idl_hand_y - 8;

        draw_set_color(c_rim);
        draw_line_width(sh_front, e_sh_y, idl_elbow_x, idl_elbow_y, 2.5);
        draw_line_width(idl_elbow_x, idl_elbow_y, idl_hand_x, idl_hand_y, 2.5);

        // Dark iron cleaver
        draw_set_color(make_color_rgb(18, 14, 20));
        draw_line_width(idl_hand_x, idl_hand_y, idl_tip_x, idl_tip_y, 4.0);
        draw_set_color(c_rim);
        draw_line_width(idl_hand_x, idl_hand_y, idl_tip_x, idl_tip_y, 1.5);
    }
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
