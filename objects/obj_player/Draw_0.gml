// =====================================================================
// QUAZERIUM — OBJ_PLAYER: True Procedural Stickman Modular Ceremonial
// Sacred Brutalism & Cosmic Woodcut: Chiseled bone skull mask with crest horns,
// rotating celestial relic halo, central spine line with shoulder/rib crossbars,
// articulated 2-segment stick legs with knee nodes, articulated stick arms
// gripping the monolithic executioner blade or heavy blunderbuss firearm,
// trailing prayer ribbons, and active reload tactical radial gauge.
// ABSOLUTELY ZERO SOLID RECTANGLE BODY BLOCKS!
// =====================================================================

// ---------------------------------------------------------------------
// COLOR PALETTE: Sacred Brutalism / Cosmic Woodcut
// ---------------------------------------------------------------------
var c_ink          = make_color_rgb(14, 15, 18);
var c_basalt_dark  = make_color_rgb(28, 30, 36);
var c_basalt_mid   = make_color_rgb(52, 56, 66);
var c_bone         = make_color_rgb(238, 235, 224);
var c_gold         = make_color_rgb(212, 175, 55);
var c_crimson      = make_color_rgb(180, 32, 42);
var c_ash          = make_color_rgb(95, 100, 110);
var c_earth        = make_color_rgb(140, 105, 65);

// Sacred Elemental Trim
var c_trim = c_bone;
switch (active_element) {
    case ELEMENT.FIRE:  c_trim = make_color_rgb(220, 60, 35); break; // Sacred Cinnabar
    case ELEMENT.WATER: c_trim = make_color_rgb(55, 125, 165); break; // Abyssal Cerulean
    case ELEMENT.EARTH: c_trim = make_color_rgb(195, 145, 50); break; // Relic Ocher
    case ELEMENT.WIND:  c_trim = make_color_rgb(105, 160, 130); break; // Pale Jade Mist
}

if (overdrive_active) {
    var p_pulse = sin(current_time * 0.015);
    c_trim = merge_color(c_gold, c_bone, 0.3 + (p_pulse * 0.3));
}

// ---------------------------------------------------------------------
// 1. INK RESIDUE AFTERIMAGES (Stickman Silhouette Trails)
// ---------------------------------------------------------------------
var max_ai = quality_get().trail_segments;
for (var a = 0; a < max_ai; a++) {
    var ai = afterimages[a];
    if (ai.active && ai.alpha > 0.02) {
        draw_set_alpha(ai.alpha * 0.50);
        draw_set_color(ai.color);
        // Stickman spine afterimage
        var ai_hx = ai.x;
        var ai_hy = ai.y - 12;
        draw_circle(ai_hx, ai_hy, 5, false);
        draw_line_width(ai_hx, ai_hy + 5, ai_hx, ai.y + 4, 3.0);
        draw_line_width(ai_hx - 8, ai_hy + 8, ai_hx + 8, ai_hy + 8, 2.5);
        draw_line_width(ai_hx, ai.y + 4, ai_hx - (ai.facing * 6), ai.y + 16, 2.5);
        draw_line_width(ai_hx, ai.y + 4, ai_hx + (ai.facing * 6), ai.y + 16, 2.5);
    }
}
draw_set_alpha(1.0);

// ---------------------------------------------------------------------
// 2. KINEMATIC ANATOMICAL COORDINATES
// ---------------------------------------------------------------------
var hw = bbox_hw * squash_x;
var hh = bbox_hh * squash_y;
var bob_y = (state == PSTATE.RUN) ? (abs(sin(run_anim_t)) * 3) : 0;
var py = y - bob_y;
var tilt_ox = lengthdir_x(torso_tilt, 90);

// Key Stickman Skeleton Nodes
var head_r   = 7.0;
var head_x   = x + tilt_ox;
var head_y   = py - (hh * 0.65);
var neck_y   = head_y + head_r;

var hip_x    = x + (tilt_ox * 0.4);
var hip_y    = py + (hh * 0.22);

var sh_w     = 11;
var sh_y     = neck_y + 3;
var sh_left  = head_x - sh_w;
var sh_right = head_x + sh_w;
var sh_front = (facing > 0) ? sh_right : sh_left;
var sh_back  = (facing > 0) ? sh_left  : sh_right;

var hp_w     = 8;
var leg_bot  = y + bbox_hh;

// Ground Contact Shadow
if (on_ground) {
    draw_set_color(c_black);
    draw_set_alpha(0.55);
    draw_ellipse(x - (hw * 1.1), y + bbox_hh - 2, x + (hw * 1.1), y + bbox_hh + 2, false);
    draw_set_alpha(1.0);
}

// ---------------------------------------------------------------------
// 3. CELESTIAL RELIC HALO (Rotating Solar Crown)
// ---------------------------------------------------------------------
var halo_y = head_y - head_r - 6;
var halo_r = 12;
var halo_active = overdrive_active || shotgun_empowered;

draw_set_color(halo_active ? c_gold : c_basalt_mid);
draw_circle(head_x, halo_y, halo_r, true);

for (var hp = 0; hp < 4; hp++) {
    var hp_ang = halo_rot + (hp * 90);
    var hpx = head_x + lengthdir_x(halo_r, hp_ang);
    var hpy = halo_y + lengthdir_y(halo_r, hp_ang);
    draw_set_color(halo_active ? c_gold : c_bone);
    draw_point(hpx, hpy);
}

if (halo_active) {
    draw_set_color(c_gold);
    draw_set_alpha(0.25);
    draw_circle(head_x, halo_y, halo_r * 0.7, false);
    draw_set_alpha(1.0);
}

// ---------------------------------------------------------------------
// 4. TALISMAN STREAMER RIBBONS (Trailing Prayer Ribbons)
// ---------------------------------------------------------------------
if (variable_instance_exists(id, "talisman_ribbons")) {
    var prev_rx = head_x - (facing * 4);
    var prev_ry = neck_y;
    for (var r_idx = 0; r_idx < 4; r_idx++) {
        var cur_rx = talisman_ribbons[r_idx].x;
        var cur_ry = talisman_ribbons[r_idx].y;

        draw_set_color(c_bone);
        draw_line_width(prev_rx, prev_ry, cur_rx, cur_ry, 2.5);
        draw_set_color(c_ink);
        draw_point((prev_rx + cur_rx) * 0.5, (prev_ry + cur_ry) * 0.5);

        prev_rx = cur_rx;
        prev_ry = cur_ry;
    }
}

// ---------------------------------------------------------------------
// 5. STICKMAN LEGS (Articulated 2-Segment Limbs with Bone Knees)
// ---------------------------------------------------------------------
draw_set_color(c_bone);

var hip_l = hip_x - (hp_w * 0.7);
var hip_r = hip_x + (hp_w * 0.7);

var k1_x = hip_l; var k1_y = hip_y + 9; var f1_x = hip_l; var f1_y = leg_bot;
var k2_x = hip_r; var k2_y = hip_y + 9; var f2_x = hip_r; var f2_y = leg_bot;

if (state == PSTATE.RUN) {
    // Dynamic running scissor cycle
    var l_sw1 = sin(run_anim_t) * 13;
    var l_sw2 = sin(run_anim_t + pi) * 13;

    k1_x = hip_l + (l_sw1 * facing * 0.65);
    k1_y = hip_y + 8 - (abs(cos(run_anim_t)) * 3);
    f1_x = hip_l + (l_sw1 * facing * 1.15);
    f1_y = min(leg_bot, k1_y + 9 + (cos(run_anim_t) * 4));

    k2_x = hip_r + (l_sw2 * facing * 0.65);
    k2_y = hip_y + 8 - (abs(cos(run_anim_t + pi)) * 3);
    f2_x = hip_r + (l_sw2 * facing * 1.15);
    f2_y = min(leg_bot, k2_y + 9 + (cos(run_anim_t + pi) * 4));
} else if (state == PSTATE.JUMP) {
    // Aerial ninja knee-tuck
    k1_x = hip_l - (facing * 3);
    k1_y = hip_y + 6;
    f1_x = k1_x - (facing * 4);
    f1_y = k1_y + 8;

    k2_x = hip_r - (facing * 2);
    k2_y = hip_y + 7;
    f2_x = k2_x - (facing * 5);
    f2_y = k2_y + 9;
} else if (state == PSTATE.FALL) {
    // Trailing wind-drag legs
    k1_x = hip_l - 2;
    k1_y = hip_y + 11;
    f1_x = hip_l - 4;
    f1_y = leg_bot + 3;

    k2_x = hip_r + 2;
    k2_y = hip_y + 11;
    f2_x = hip_r + 4;
    f2_y = leg_bot + 3;
} else if (state == PSTATE.DASH) {
    // Aerodynamic horizontal trailing legs
    var ddx = dash_dir_x;
    var ddy = dash_dir_y;
    k1_x = hip_l - (ddx * 10);
    k1_y = hip_y - (ddy * 10);
    f1_x = hip_l - (ddx * 18);
    f1_y = hip_y - (ddy * 18);

    k2_x = hip_r - (ddx * 8);
    k2_y = hip_y - (ddy * 8);
    f2_x = hip_r - (ddx * 16);
    f2_y = hip_y - (ddy * 16);
} else if (state == PSTATE.SLAM) {
    // Downward spear dive legs
    k1_x = hip_l; k1_y = hip_y + 8; f1_x = hip_l; f1_y = hip_y + 16;
    k2_x = hip_r; k2_y = hip_y + 8; f2_x = hip_r; f2_y = hip_y + 16;
} else {
    // Martial grounded stance
    k1_x = hip_l - 2; k1_y = hip_y + 9; f1_x = hip_l - 4; f1_y = leg_bot;
    k2_x = hip_r + 2; k2_y = hip_y + 9; f2_x = hip_r + 4; f2_y = leg_bot;
}

// Draw Leg Segments
draw_set_color(c_bone);
draw_line_width(hip_l, hip_y, k1_x, k1_y, 3.5);
draw_line_width(k1_x, k1_y, f1_x, f1_y, 3.0);
draw_line_width(hip_r, hip_y, k2_x, k2_y, 3.5);
draw_line_width(k2_x, k2_y, f2_x, f2_y, 3.0);

// Inner Ink Lining for High Contrast
draw_set_color(c_ink);
draw_line_width(hip_l, hip_y, k1_x, k1_y, 1.5);
draw_line_width(k1_x, k1_y, f1_x, f1_y, 1.5);
draw_line_width(hip_r, hip_y, k2_x, k2_y, 1.5);
draw_line_width(k2_x, k2_y, f2_x, f2_y, 1.5);

// Bone Knee Joint Nodes
draw_set_color(c_bone);
draw_circle(k1_x, k1_y, 2.5, false);
draw_circle(k2_x, k2_y, 2.5, false);
draw_set_color(c_ink);
draw_circle(k1_x, k1_y, 1.0, false);
draw_circle(k2_x, k2_y, 1.0, false);

// ---------------------------------------------------------------------
// 6. STICKMAN TORSO / SPINE (NO RECTANGLE BODY!)
// ---------------------------------------------------------------------
// Central Vertical Spine
draw_set_color(c_bone);
draw_line_width(head_x, neck_y, hip_x, hip_y, 4.0);
draw_set_color(c_ink);
draw_line_width(head_x, neck_y, hip_x, hip_y, 2.0);

// Horizontal Shoulder Bar
draw_set_color(c_bone);
draw_line_width(sh_left, sh_y, sh_right, sh_y, 3.5);
draw_set_color(c_ink);
draw_line_width(sh_left, sh_y, sh_right, sh_y, 1.5);

// Pelvic Crossbar
draw_set_color(c_bone);
draw_line_width(hip_x - hp_w, hip_y, hip_x + hp_w, hip_y, 3.0);
draw_set_color(c_ink);
draw_line_width(hip_x - hp_w, hip_y, hip_x + hp_w, hip_y, 1.5);

// Cosmic Woodcut Rib Crossbars
var r1_y = lerp(sh_y, hip_y, 0.38);
var r2_y = lerp(sh_y, hip_y, 0.70);
draw_set_color(c_bone);
draw_line_width(head_x - 5, r1_y, head_x + 5, r1_y, 2.0);
draw_line_width(head_x - 4, r2_y, head_x + 4, r2_y, 2.0);

// Asymmetric Ceremonial Mantle (Scarf Draping over Back Shoulder)
var mantle_x = head_x - (facing * 6);
var mantle_tip_x = mantle_x - (facing * 9) - (vx * 0.03);
var mantle_tip_y = sh_y + 11 - (vy * 0.02);
draw_set_color(c_ash);
draw_triangle(mantle_x, sh_y - 2, mantle_x + (facing * 3), sh_y + 3, mantle_tip_x, mantle_tip_y, false);
draw_set_color(c_bone);
draw_line(mantle_x, sh_y - 2, mantle_tip_x, mantle_tip_y);

// ---------------------------------------------------------------------
// 7. CHISELED BONE MASK HEAD & CREST HORNS
// ---------------------------------------------------------------------
// Bone Skull Mask Circle
draw_set_color(c_bone);
draw_circle(head_x, head_y, head_r, false);
draw_set_color(c_ink);
draw_circle(head_x, head_y, head_r, true);

// Curved Sharp Bone Horns Jutting Upwards/Backwards
draw_set_color(c_bone);
draw_line_width(head_x - 3, head_y - head_r + 2, head_x - (facing * 4) - 2, head_y - head_r - 7, 2.5);
draw_line_width(head_x + 3, head_y - head_r + 2, head_x + (facing * 3) + 3, head_y - head_r - 6, 2.0);
draw_set_color(c_ink);
draw_line(head_x - 3, head_y - head_r + 2, head_x - (facing * 4) - 2, head_y - head_r - 7);
draw_line(head_x + 3, head_y - head_r + 2, head_x + (facing * 3) + 3, head_y - head_r - 6);

// Hollow Soul Ember Eye Slit
var eye_x = head_x + (facing * 3);
var eye_y = head_y - 1;
draw_set_color((overdrive_active || shotgun_empowered) ? c_gold : c_crimson);
draw_circle(eye_x, eye_y, 2.0, false);
draw_set_color(c_bone);
draw_point(eye_x, eye_y);

// Eye Motion Trail during Sword Attack
if (state == PSTATE.ATTACK) {
    draw_set_color(c_crimson);
    draw_set_alpha(0.65);
    draw_line_width(eye_x, eye_y, eye_x - (facing * 14), eye_y, 2);
    draw_set_alpha(1.0);
}

// ---------------------------------------------------------------------
// 8. WEAPON RENDERING & ARTICULATED STICK ARMS
// ---------------------------------------------------------------------
var hx = head_x + (facing * 12);
var hy = py - 2;

if (current_weapon == WEAPON_ID.SWORD) {
    // === SWORD: MONOLITHIC EXECUTIONER BLADE ===
    if (state == PSTATE.ATTACK) {
        var arc_r = 44 + (attack_step * 8);
        var start_ang = 0;
        var sweep_span = 135;

        switch (attack_step) {
            case 0: start_ang = (facing == 1) ? 30 : 150; break;
            case 1: start_ang = (facing == 1) ? 290 : 250; break;
            case 2: start_ang = (facing == 1) ? 80 : 100; arc_r += 14; break;
        }

        // Woodcut Brush Crescent Arc
        for (var k = 0; k < 6; k++) {
            var a1 = start_ang + (k * (sweep_span / 6) * facing);
            var a2 = start_ang + ((k + 1) * (sweep_span / 6) * facing);
            var x1 = x + lengthdir_x(arc_r, a1);
            var y1 = py + lengthdir_y(arc_r, a1);
            var x2 = x + lengthdir_x(arc_r, a2);
            var y2 = py + lengthdir_y(arc_r, a2);

            draw_set_color(c_ink);
            draw_set_alpha(0.4 + (k * 0.1));
            draw_line_width(x1, y1, x2, y2, 6 + (k * 0.5));

            draw_set_color(c_bone);
            draw_set_alpha(0.6 + (k * 0.08));
            draw_line_width(x1, y1, x2, y2, 2);

            if (c_trim != c_bone) {
                draw_set_color(c_trim);
                draw_set_alpha(0.3 + (k * 0.12));
                draw_line_width(x1, y1, x2, y2, 4);
            }
        }
        draw_set_alpha(1.0);

        // Blade Core
        var blade_tip_x = x + lengthdir_x(arc_r, start_ang + (sweep_span * facing));
        var blade_tip_y = py + lengthdir_y(arc_r, start_ang + (sweep_span * facing));

        draw_set_color(c_basalt_dark);
        draw_line_width(hx, hy, blade_tip_x, blade_tip_y, 5);
        draw_set_color(c_bone);
        draw_line_width(hx, hy, blade_tip_x, blade_tip_y, 2);
        draw_set_color(c_trim);
        draw_line_width(hx, hy, blade_tip_x, blade_tip_y, 1);

        // Articulated Swung Stick Arms
        var sw_elbow_x = lerp(sh_front, hx, 0.45) + (facing * 4);
        var sw_elbow_y = lerp(sh_y, hy, 0.45) + 4;
        draw_set_color(c_bone);
        draw_line_width(sh_front, sh_y, sw_elbow_x, sw_elbow_y, 3.0);
        draw_line_width(sw_elbow_x, sw_elbow_y, hx, hy, 2.5);
        draw_set_color(c_ink);
        draw_line_width(sh_front, sh_y, sw_elbow_x, sw_elbow_y, 1.5);
        draw_line_width(sw_elbow_x, sw_elbow_y, hx, hy, 1.0);
        draw_circle(sw_elbow_x, sw_elbow_y, 2, false);
    } else {
        // Sheathed Greatblade strapped diagonally on back
        var scabbard_len = 28;
        var scabbard_ang = (facing == 1) ? 135 : 45;
        var bx2 = head_x + lengthdir_x(scabbard_len, scabbard_ang);
        var by2 = sh_y + lengthdir_y(scabbard_len, scabbard_ang);

        draw_set_color(c_basalt_dark);
        draw_line_width(head_x, sh_y, bx2, by2, 4.5);
        draw_set_color(c_bone);
        draw_line_width(head_x, sh_y, bx2, by2, 1.5);
        draw_set_color(c_gold);
        draw_circle(bx2, by2, 2.5, false);

        // Natural Martial Ready Stick Arms
        var a_elb_x = sh_front + (facing * 6);
        var a_elb_y = sh_y + 8;
        var a_hand_x = sh_front + (facing * 10);
        var a_hand_y = sh_y + 12;

        draw_set_color(c_bone);
        draw_line_width(sh_front, sh_y, a_elb_x, a_elb_y, 3.0);
        draw_line_width(a_elb_x, a_elb_y, a_hand_x, a_hand_y, 2.5);
        draw_set_color(c_ink);
        draw_line_width(sh_front, sh_y, a_elb_x, a_elb_y, 1.5);
        draw_line_width(a_elb_x, a_elb_y, a_hand_x, a_hand_y, 1.0);
        draw_circle(a_elb_x, a_elb_y, 2, false);
    }

    // Charge condensation diamond ring
    if (is_charging && charge_timer > 0) {
        var c_pct = clamp(charge_timer / global.cfg.combat.charge_time, 0, 1);
        var cr_radius = (40 * (1.0 - c_pct)) + 8;
        draw_set_color(c_gold);
        draw_set_alpha(c_pct);
        draw_circle(hx, hy, cr_radius, true);
        draw_line(hx - (cr_radius * 0.7), hy, hx, hy - (cr_radius * 0.7));
        draw_line(hx, hy - (cr_radius * 0.7), hx + (cr_radius * 0.7), hy);
        draw_line(hx + (cr_radius * 0.7), hy, hx, hy + (cr_radius * 0.7));
        draw_line(hx, hy + (cr_radius * 0.7), hx - (cr_radius * 0.7), hy);
        draw_set_alpha(1.0);
    }
} else if (current_weapon == WEAPON_ID.SHOTGUN) {
    // === SHOTGUN: HEAVY SACRED BLUNDERBUSS / RELIC HAND-CANNON ===
    var gun_x = head_x + (facing * 8) + weapon_recoil_x;
    var gun_y = sh_y + 5;
    var barrel_len = 18;
    var bx_tip = gun_x + (facing * barrel_len);

    // Carved Basalt Stock
    draw_set_color(c_basalt_dark);
    draw_line_width(gun_x - (facing * 4), gun_y + 1, gun_x, gun_y + 1, 4.0);
    draw_set_color(c_bone);
    draw_line_width(gun_x - (facing * 4), gun_y + 1, gun_x, gun_y + 1, 1.5);

    // Flared Twin Barrels
    draw_set_color(c_basalt_mid);
    draw_line_width(gun_x, gun_y - 2, bx_tip, gun_y - 2, 3);
    draw_line_width(gun_x, gun_y + 2, bx_tip, gun_y + 2, 3);

    // Flared Bone Muzzle Lip
    draw_set_color(c_bone);
    draw_line_width(bx_tip, gun_y - 4, bx_tip, gun_y + 4, 3);

    // Engraved Relic-Gold Runes on Barrel
    draw_set_color(shotgun_empowered ? c_gold : c_ash);
    draw_point(gun_x + (facing * 6), gun_y);
    draw_point(gun_x + (facing * 12), gun_y);

    // Articulated Stick Arms Holding Gun
    var g_elb_back_x = lerp(sh_back, gun_x - (facing * 2), 0.5);
    var g_elb_back_y = sh_y + 7;
    draw_set_color(c_bone);
    draw_line_width(sh_back, sh_y, g_elb_back_x, g_elb_back_y, 3.0);
    draw_line_width(g_elb_back_x, g_elb_back_y, gun_x - (facing * 2), gun_y + 2, 2.5);

    var g_elb_front_x = lerp(sh_front, gun_x + (facing * 8), 0.5);
    var g_elb_front_y = sh_y + 6;
    draw_line_width(sh_front, sh_y, g_elb_front_x, g_elb_front_y, 3.0);
    draw_line_width(g_elb_front_x, g_elb_front_y, gun_x + (facing * 8), gun_y + 1, 2.5);

    draw_set_color(c_ink);
    draw_circle(g_elb_back_x, g_elb_back_y, 1.5, false);
    draw_circle(g_elb_front_x, g_elb_front_y, 1.5, false);

    // Empowered Sacred Muzzle Aura
    if (shotgun_empowered) {
        var emp_pulse = sin(current_time * 0.02) * 3;
        draw_set_color(c_gold);
        draw_circle(bx_tip, gun_y, 6 + emp_pulse, true);
        draw_set_color(c_crimson);
        draw_circle(bx_tip, gun_y, 4, false);
    }

    // Muzzle Blast Flame on Firing Recoil
    if (shotgun_recoil_timer > 0) {
        var m_len = 22;
        var mx1 = bx_tip;
        var my1 = gun_y;
        var mx2 = bx_tip + (facing * m_len);
        var my2_top = gun_y - 12;
        var my2_bot = gun_y + 12;

        draw_set_color(shotgun_empowered ? c_gold : c_bone);
        draw_triangle(mx1, my1, mx2, my2_top, mx2, my2_bot, false);
        draw_set_color(c_crimson);
        draw_triangle(mx1, my1, mx2 - (facing * 6), my2_top + 4, mx2 - (facing * 6), my2_bot - 4, false);
        draw_set_color(c_ink);
        draw_triangle(mx1, my1, mx2, my2_top, mx2, my2_bot, true);
    }
}

// ---------------------------------------------------------------------
// 9. ACTIVE RELOAD: TACTICAL COMBAT RADIAL GAUGE
// ---------------------------------------------------------------------
if (reload_state == RELOAD_STATE.RELOADING) {
    var rg_x = head_x - (facing * 18);
    var rg_y = head_y - 14;
    var rg_r = 16;
    var cfg_sg = global.cfg.shotgun;

    draw_set_color(c_ink);
    draw_circle(rg_x, rg_y, rg_r + 2, false);
    draw_set_color(c_basalt_mid);
    draw_circle(rg_x, rg_y, rg_r, true);

    // Perfect Window Target Sector Notch in Gold
    var p_ang1 = 180 - (cfg_sg.perfect_start * 180);
    var p_ang2 = 180 - (cfg_sg.perfect_end * 180);
    draw_set_color(c_gold);
    var pw1_x = rg_x + lengthdir_x(rg_r, p_ang1);
    var pw1_y = rg_y - lengthdir_y(rg_r, p_ang1);
    var pw2_x = rg_x + lengthdir_x(rg_r, p_ang2);
    var pw2_y = rg_y - lengthdir_y(rg_r, p_ang2);
    draw_line_width(pw1_x, pw1_y, pw2_x, pw2_y, 3);

    // Sweeping Bone Needle
    var needle_ang = 180 - (clamp(reload_progress, 0, 1) * 180);
    var nx = rg_x + lengthdir_x(rg_r - 2, needle_ang);
    var ny = rg_y - lengthdir_y(rg_r - 2, needle_ang);
    draw_set_color(c_bone);
    draw_line_width(rg_x, rg_y, nx, ny, 2);
    draw_set_color(c_gold);
    draw_circle(rg_x, rg_y, 2.5, false);

    // Text prompt cue
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_bone);
    draw_text(rg_x, rg_y - rg_r - 2, "[R]");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// Active Reload Instant Visual Feedback Prompt
if (reload_feedback_timer > 0) {
    var fb_y = head_y - head_r - 18;
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);

    if (reload_feedback_type == "PERFECT") {
        draw_set_color(c_gold);
        draw_text(head_x, fb_y, "PERFECT!");
        draw_line_width(head_x - 8, fb_y - 6, head_x + 8, fb_y - 6, 2);
        draw_line_width(head_x, fb_y - 14, head_x, fb_y + 2, 2);
    } else if (reload_feedback_type == "FAIL") {
        draw_set_color(c_crimson);
        draw_text(head_x, fb_y, "JAMMED");
    } else if (reload_feedback_type == "NORMAL") {
        draw_set_color(c_bone);
        draw_text(head_x, fb_y, "READY");
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// ---------------------------------------------------------------------
// 10. PARRY AEGIS: SACRED GEOMETRIC MANDALA & STONE SEAL
// ---------------------------------------------------------------------
if (is_parrying) {
    var is_perf = (parry_timer <= global.cfg.parry.perfect_window);
    var c_aegis = is_perf ? c_gold : c_bone;
    var shield_x = head_x + (facing * 20);
    var shield_h = hh * 1.5;

    draw_set_color(c_aegis);
    draw_set_alpha(is_perf ? 0.95 : 0.75);
    draw_line_width(shield_x, py - shield_h, shield_x, py + shield_h, 3);

    var m_rad = 14;
    draw_line_width(shield_x, py - m_rad, shield_x + (facing * m_rad), py, 2);
    draw_line_width(shield_x + (facing * m_rad), py, shield_x, py + m_rad, 2);
    draw_line_width(shield_x, py + m_rad, shield_x - (facing * m_rad), py, 2);
    draw_line_width(shield_x - (facing * m_rad), py, shield_x, py - m_rad, 2);

    draw_circle(shield_x, py, 7, true);
    draw_set_alpha(0.2);
    draw_circle(shield_x, py, 7, false);
    draw_set_alpha(1.0);
}

// ---------------------------------------------------------------------
// 11. GRAPPLE: BRAIDED BINDING CHAIN & RELIQUARY HARPOON
// ---------------------------------------------------------------------
if (grapple.state != GRAPPLE_STATE.IDLE) {
    var gx = grapple.hook_x;
    var gy = grapple.hook_y;
    var cable_dist = point_distance(hx, hy, gx, gy);

    draw_set_color(c_ink);
    draw_line_width(hx, hy, gx, gy, 3);
    draw_set_color(c_basalt_mid);
    draw_line_width(hx, hy, gx, gy, 1.5);

    var num_beads = min(14, floor(cable_dist / 28));
    for (var b = 1; b < num_beads; b++) {
        var bt = b / num_beads;
        var bead_x = lerp(hx, gx, bt);
        var bead_y = lerp(hy, gy, bt);
        draw_set_color(c_bone);
        draw_circle(bead_x, bead_y, 2, false);
    }

    draw_set_color(c_bone);
    draw_circle(gx, gy, 5, false);
    draw_set_color(c_gold);
    draw_circle(gx, gy, 7, true);

    var h_ang = point_direction(hx, hy, gx, gy);
    var flk1_x = gx + lengthdir_x(8, h_ang + 150);
    var flk1_y = gy + lengthdir_y(8, h_ang + 150);
    var flk2_x = gx + lengthdir_x(8, h_ang - 150);
    var flk2_y = gy + lengthdir_y(8, h_ang - 150);
    draw_line_width(gx, gy, flk1_x, flk1_y, 2);
    draw_line_width(gx, gy, flk2_x, flk2_y, 2);
}
