// =====================================================================
// QUAZERIUM — OBJ_PLAYER: Stickman Modular Ceremonial Render
// Sacred Brutalism & Cosmic Woodcut: Chiseled bone mask with crest horns,
// celestial relic halo, segmented ink torso, kinetic articulated limbs,
// trailing prayer streamers, monolithic executioner blade, heavy relic
// blunderbuss with recoil kickback, and active reload radial combat gauge.
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
// 1. INK RESIDUE AFTERIMAGES (Dash / Overdrive)
// ---------------------------------------------------------------------
var max_ai = quality_get().trail_segments;
for (var a = 0; a < max_ai; a++) {
    var ai = afterimages[a];
    if (ai.active && ai.alpha > 0.02) {
        draw_set_alpha(ai.alpha * 0.55);
        draw_set_color(c_ink);
        draw_rectangle(ai.x - bbox_hw, ai.y - bbox_hh, ai.x + bbox_hw, ai.y + bbox_hh, false);
        draw_set_color(c_basalt_mid);
        draw_rectangle(ai.x - bbox_hw, ai.y - bbox_hh, ai.x + bbox_hw, ai.y + bbox_hh, true);
    }
}
draw_set_alpha(1.0);

// ---------------------------------------------------------------------
// 2. CELESTIAL RELIC HALO (Rotating Solar Crown)
// ---------------------------------------------------------------------
var halo_y = y - bbox_hh - 6;
var halo_r = 13;
var halo_active = overdrive_active || shotgun_empowered;

// Rotating halo ring
draw_set_color(halo_active ? c_gold : c_basalt_mid);
draw_circle(x, halo_y, halo_r, true);

// 4 Cardinal Star Points on Halo
for (var hp = 0; hp < 4; hp++) {
    var hp_ang = halo_rot + (hp * 90);
    var hpx = x + lengthdir_x(halo_r, hp_ang);
    var hpy = halo_y + lengthdir_y(halo_r, hp_ang);
    draw_set_color(halo_active ? c_gold : c_bone);
    draw_point(hpx, hpy);
}

if (halo_active) {
    draw_set_color(c_gold);
    draw_set_alpha(0.25);
    draw_circle(x, halo_y, halo_r * 0.7, false);
    draw_set_alpha(1.0);
}

// ---------------------------------------------------------------------
// 3. SQUASH & STRETCH ANATOMY
// ---------------------------------------------------------------------
var hw = bbox_hw * squash_x;
var hh = bbox_hh * squash_y;
var bob_y = (state == PSTATE.RUN) ? (abs(sin(run_anim_t)) * 3) : 0;
var py = y - bob_y;

// Ground Shadow
if (on_ground) {
    draw_set_color(c_black);
    draw_set_alpha(0.5);
    draw_ellipse(x - (hw * 1.3), y + hh - 2, x + (hw * 1.3), y + hh + 2, false);
    draw_set_alpha(1.0);
}

// ---------------------------------------------------------------------
// 4. TALISMAN STREAMER RIBBONS (Trailing Physics)
// ---------------------------------------------------------------------
if (variable_instance_exists(id, "talisman_ribbons")) {
    var prev_rx = x - (facing * (hw * 0.4));
    var prev_ry = py - (hh * 0.3);
    for (var r_idx = 0; r_idx < 4; r_idx++) {
        var cur_rx = talisman_ribbons[r_idx].x;
        var cur_ry = talisman_ribbons[r_idx].y;

        draw_set_color(c_bone);
        draw_line_width(prev_rx, prev_ry, cur_rx, cur_ry, 3);
        draw_set_color(c_ink);
        draw_point((prev_rx + cur_rx) * 0.5, (prev_ry + cur_ry) * 0.5);

        prev_rx = cur_rx;
        prev_ry = cur_ry;
    }
}

// ---------------------------------------------------------------------
// 5. STICKMAN CEREMONIAL: SEGMENTED TORSO & ARTICULATED LIMBS
// ---------------------------------------------------------------------
// Torso tilt calculation
var tilt_ox = lengthdir_x(torso_tilt, 90);

// Torso Chassis (Carved Basalt Core)
draw_set_color(c_ink);
draw_rectangle(x - hw + tilt_ox, py - hh, x + hw + tilt_ox, py + hh, false);

// Basalt Core Inlay & Woodcut Etchings
draw_set_color(c_basalt_dark);
draw_rectangle(x - hw + 2 + tilt_ox, py - hh + 2, x + hw - 2 + tilt_ox, py + (hh * 0.35), false);

draw_set_color(c_basalt_mid);
for (var hx_line = -hw + 4; hx_line < hw - 2; hx_line += 5) {
    draw_line(x + hx_line + tilt_ox, py - hh + 3, x + hx_line + 4 + tilt_ox, py + (hh * 0.3));
}

// Asymmetric Ceremonial Mantle (Draped over back shoulder)
draw_set_color(c_ash);
draw_triangle(x - (facing * (hw + 1)) + tilt_ox, py - hh,
              x - (facing * (hw - 4)) + tilt_ox, py - hh + 10,
              x + tilt_ox, py - hh + 4, false);
draw_set_color(c_bone);
draw_line(x - (facing * (hw + 1)) + tilt_ox, py - hh, x - (facing * (hw - 4)) + tilt_ox, py - hh + 10);

// Outer Perimeter Chisel Border
draw_set_color(c_basalt_mid);
draw_rectangle(x - hw + tilt_ox, py - hh, x + hw + tilt_ox, py + hh, true);

// Articulated Segmented Limbs with Bone Joint Nodes
var leg_bot = y + bbox_hh;
draw_set_color(c_ink);

if (state == PSTATE.RUN) {
    // 2-segment running legs
    var leg_swing = sin(run_anim_t) * 10;
    var knee1_x = x - 4 + (leg_swing * facing * 0.5);
    var knee1_y = py + (hh * 0.6);
    var foot1_x = x - 4 + (leg_swing * facing);
    var foot1_y = leg_bot;

    var knee2_x = x + 4 - (leg_swing * facing * 0.5);
    var knee2_y = py + (hh * 0.6);
    var foot2_x = x + 4 - (leg_swing * facing);
    var foot2_y = leg_bot;

    draw_line_width(x - 4 + tilt_ox, py + (hh * 0.3), knee1_x, knee1_y, 3);
    draw_line_width(knee1_x, knee1_y, foot1_x, foot1_y, 2.5);

    draw_line_width(x + 4 + tilt_ox, py + (hh * 0.3), knee2_x, knee2_y, 3);
    draw_line_width(knee2_x, knee2_y, foot2_x, foot2_y, 2.5);

    // Bone knee joints
    draw_set_color(c_bone);
    draw_circle(knee1_x, knee1_y, 2, false);
    draw_circle(knee2_x, knee2_y, 2, false);
} else if (state == PSTATE.JUMP) {
    // Tucked jump legs
    var k1_x = x - 4 - (facing * 2);
    var k1_y = py + hh + 3;
    draw_line_width(x - 4 + tilt_ox, py + (hh * 0.3), k1_x, k1_y, 3);
    draw_line_width(k1_x, k1_y, k1_x - (facing * 4), k1_y + 4, 2.5);

    var k2_x = x + 4 - (facing * 3);
    var k2_y = py + hh + 4;
    draw_line_width(x + 4 + tilt_ox, py + (hh * 0.3), k2_x, k2_y, 3);
    draw_line_width(k2_x, k2_y, k2_x - (facing * 5), k2_y + 5, 2.5);

    draw_set_color(c_bone);
    draw_circle(k1_x, k1_y, 2, false);
    draw_circle(k2_x, k2_y, 2, false);
} else if (state == PSTATE.FALL) {
    draw_line_width(x - 4 + tilt_ox, py + (hh * 0.3), x - 6, py + hh + 4, 3);
    draw_line_width(x + 4 + tilt_ox, py + (hh * 0.3), x + 6, py + hh + 4, 3);
    draw_set_color(c_bone);
    draw_circle(x - 6, py + hh + 4, 2, false);
    draw_circle(x + 6, py + hh + 4, 2, false);
} else if (state == PSTATE.DASH) {
    var ddx = dash_dir_x;
    var ddy = dash_dir_y;
    draw_line_width(x - 4 + tilt_ox, py + (hh * 0.3), x - (ddx * 15), py - (ddy * 15), 4);
    draw_set_color(c_bone);
    draw_circle(x - (ddx * 8), py - (ddy * 8), 2, false);
} else if (state == PSTATE.SLAM) {
    draw_line_width(x - 3 + tilt_ox, py + hh, x - 3, py + hh + 8, 3);
    draw_line_width(x + 3 + tilt_ox, py + hh, x + 3, py + hh + 8, 3);
    draw_set_color(c_basalt_dark);
    draw_line_width(x + tilt_ox, py + hh, x + tilt_ox, py + hh + 22, 4);
    draw_set_color(c_bone);
    draw_line_width(x + tilt_ox, py + hh, x + tilt_ox, py + hh + 22, 2);
} else {
    // Grounded braced martial stance
    draw_line_width(x - 4 + tilt_ox, py + (hh * 0.3), x - 6, leg_bot, 3);
    draw_line_width(x + 4 + tilt_ox, py + (hh * 0.3), x + 6, leg_bot, 3);
    draw_set_color(c_bone);
    draw_circle(x - 5, py + (hh * 0.65), 2, false);
    draw_circle(x + 5, py + (hh * 0.65), 2, false);
}

// ---------------------------------------------------------------------
// 6. CHISELED BONE MASK WITH CREST HORNS & HOLLOW SOUL EMBER
// ---------------------------------------------------------------------
var mask_x = x + (facing * (hw - 3)) + tilt_ox;
var mask_y = py - (hh * 0.5);

// Bone Mask Shell
draw_set_color(c_bone);
draw_rectangle(mask_x - 3, mask_y - 5, mask_x + 3, mask_y + 4, false);
draw_set_color(c_ink);
draw_rectangle(mask_x - 3, mask_y - 5, mask_x + 3, mask_y + 4, true);

// Sharp Crest Horns on Mask
draw_set_color(c_bone);
draw_triangle(mask_x - 3, mask_y - 5, mask_x - 1, mask_y - 9, mask_x, mask_y - 5, false);
draw_triangle(mask_x, mask_y - 5, mask_x + 2, mask_y - 8, mask_x + 3, mask_y - 5, false);
draw_set_color(c_ink);
draw_line(mask_x - 3, mask_y - 5, mask_x - 1, mask_y - 9);
draw_line(mask_x + 3, mask_y - 5, mask_x + 2, mask_y - 8);

// Hollow Angular Eye Slit & Soul Ember
var eye_x = mask_x + (facing * 1);
var eye_y = mask_y - 1;
draw_set_color((overdrive_active || shotgun_empowered) ? c_gold : c_crimson);
draw_circle(eye_x, eye_y, 2, false);
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
// 7. WEAPON RENDERING (SWORD VS SHOTGUN)
// ---------------------------------------------------------------------
var hx = x + (facing * (hw + 4)) + tilt_ox;
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
    } else {
        // Sheathed Blade strapped on back
        var scabbard_len = 26;
        var scabbard_ang = (facing == 1) ? 135 : 45;
        var bx2 = x + lengthdir_x(scabbard_len, scabbard_ang);
        var by2 = py - 4 + lengthdir_y(scabbard_len, scabbard_ang);

        draw_set_color(c_basalt_dark);
        draw_line_width(x + tilt_ox, py - 4, bx2, by2, 4);
        draw_set_color(c_bone);
        draw_line_width(x + tilt_ox, py - 4, bx2, by2, 1);
        draw_set_color(c_gold);
        draw_circle(bx2, by2, 2.5, false);
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
    var gun_x = hx + weapon_recoil_x;
    var gun_y = hy + 2;
    var barrel_len = 18;
    var bx_tip = gun_x + (facing * barrel_len);

    // Carved Basalt Stock
    draw_set_color(c_basalt_dark);
    draw_rectangle(gun_x - (facing * 4), gun_y - 3, gun_x + (facing * 4), gun_y + 4, false);
    draw_set_color(c_ink);
    draw_rectangle(gun_x - (facing * 4), gun_y - 3, gun_x + (facing * 4), gun_y + 4, true);

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

        // Stark woodcut blast cone
        draw_set_color(shotgun_empowered ? c_gold : c_bone);
        draw_triangle(mx1, my1, mx2, my2_top, mx2, my2_bot, false);
        draw_set_color(c_crimson);
        draw_triangle(mx1, my1, mx2 - (facing * 6), my2_top + 4, mx2 - (facing * 6), my2_bot - 4, false);
        draw_set_color(c_ink);
        draw_triangle(mx1, my1, mx2, my2_top, mx2, my2_bot, true);
    }
}

// ---------------------------------------------------------------------
// 8. ACTIVE RELOAD: TACTICAL COMBAT RADIAL GAUGE
// ---------------------------------------------------------------------
if (reload_state == RELOAD_STATE.RELOADING) {
    var rg_x = x - (facing * (hw + 14));
    var rg_y = py - 18;
    var rg_r = 16;
    var cfg_sg = global.cfg.shotgun;

    // Dark Stone Arc Track
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
    var fb_y = py - hh - 22;
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);

    if (reload_feedback_type == "PERFECT") {
        draw_set_color(c_gold);
        draw_text(x, fb_y, "PERFECT!");
        // Celestial Star Burst
        draw_line_width(x - 8, fb_y - 6, x + 8, fb_y - 6, 2);
        draw_line_width(x, fb_y - 14, x, fb_y + 2, 2);
    } else if (reload_feedback_type == "FAIL") {
        draw_set_color(c_crimson);
        draw_text(x, fb_y, "JAMMED");
    } else if (reload_feedback_type == "NORMAL") {
        draw_set_color(c_bone);
        draw_text(x, fb_y, "READY");
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// ---------------------------------------------------------------------
// 9. PARRY AEGIS: SACRED GEOMETRIC MANDALA & STONE SEAL
// ---------------------------------------------------------------------
if (is_parrying) {
    var is_perf = (parry_timer <= global.cfg.parry.perfect_window);
    var c_aegis = is_perf ? c_gold : c_bone;
    var shield_x = x + (facing * (hw + 14));
    var shield_h = hh * 1.6;

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
// 10. GRAPPLE: BRAIDED BINDING CHAIN & RELIQUARY HARPOON
// ---------------------------------------------------------------------
if (grapple.state != GRAPPLE_STATE.IDLE) {
    var gx = grapple.hook_x;
    var gy = grapple.hook_y;
    var cable_dist = point_distance(hx, hy, gx, gy);

    // Iron chain core
    draw_set_color(c_ink);
    draw_line_width(hx, hy, gx, gy, 3);
    draw_set_color(c_basalt_mid);
    draw_line_width(hx, hy, gx, gy, 1.5);

    // Prayer bead links along chain
    var num_beads = min(14, floor(cable_dist / 28));
    for (var b = 1; b < num_beads; b++) {
        var bt = b / num_beads;
        var bead_x = lerp(hx, gx, bt);
        var bead_y = lerp(hy, gy, bt);
        draw_set_color(c_bone);
        draw_circle(bead_x, bead_y, 2, false);
    }

    // Three-Pronged Ancient Harpoon Head
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
