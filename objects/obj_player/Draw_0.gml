// =====================================================================
// QUAZERIUM — OBJ_PLAYER: Sacred Brutalism & Cosmic Woodcut Render
// Monolithic silhouette, carved basalt chassis, chiseled bone mask,
// prayer talisman streamers, heavy executioner blade & sacred mandala aegis.
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
var c_earth        = make_color_rgb(140, 105, 65);

// Sacred Elemental Inlay Accents
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
        // Deep ink silhouette shadow with bone rim
        draw_set_alpha(ai.alpha * 0.6);
        draw_set_color(c_ink);
        draw_rectangle(ai.x - bbox_hw, ai.y - bbox_hh, ai.x + bbox_hw, ai.y + bbox_hh, false);
        draw_set_color(c_basalt_mid);
        draw_rectangle(ai.x - bbox_hw, ai.y - bbox_hh, ai.x + bbox_hw, ai.y + bbox_hh, true);
    }
}
draw_set_alpha(1.0);

// ---------------------------------------------------------------------
// 2. OVERDRIVE: SOLAR RELIC HALO & CROWN OF THORNS
// ---------------------------------------------------------------------
if (overdrive_active) {
    var p_pulse = sin(current_time * 0.018);
    var halo_y = y - bbox_hh - 12;
    var halo_r = 16 + (p_pulse * 3);
    
    draw_set_color(c_gold);
    draw_circle(x, halo_y, halo_r, true);
    draw_set_color(c_bone);
    draw_circle(x, halo_y, halo_r * 0.7, true);
    
    // Radiating celestial thorn rays
    var num_spikes = 8;
    var rot_base = current_time * 0.002;
    for (var sp = 0; sp < num_spikes; sp++) {
        var sp_ang = rot_base + (sp * (2 * pi / num_spikes));
        var sx1 = x + (cos(sp_ang) * halo_r);
        var sy1 = halo_y + (sin(sp_ang) * halo_r);
        var sx2 = x + (cos(sp_ang) * (halo_r + 8));
        var sy2 = halo_y + (sin(sp_ang) * (halo_r + 8));
        draw_set_color(c_gold);
        draw_line_width(sx1, sy1, sx2, sy2, 2);
    }
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

// Prayer Talisman Streamer Ribbons (trailing behind movement)
if (variable_instance_exists(id, "talisman_ribbons")) {
    var prev_rx = x - (facing * (hw * 0.4));
    var prev_ry = py - (hh * 0.3);
    for (var r_idx = 0; r_idx < 4; r_idx++) {
        var cur_rx = talisman_ribbons[r_idx].x;
        var cur_ry = talisman_ribbons[r_idx].y;
        
        // Ribbon body (Bone white with ink border)
        draw_set_color(c_bone);
        draw_line_width(prev_rx, prev_ry, cur_rx, cur_ry, 3);
        // Miniature sacred ink glyph tick along ribbon
        draw_set_color(c_ink);
        draw_point((prev_rx + cur_rx) * 0.5, (prev_ry + cur_ry) * 0.5);
        
        prev_rx = cur_rx;
        prev_ry = cur_ry;
    }
}

// Torso: Monolithic Carved Basalt Slab
draw_set_color(c_ink);
draw_rectangle(x - hw, py - hh, x + hw, py + hh, false);

// Basalt Core Plates
draw_set_color(c_basalt_dark);
draw_rectangle(x - hw + 2, py - hh + 2, x + hw - 2, py + (hh * 0.4), false);

// Woodcut Diagonal Hatch Engravings on Chassis
draw_set_color(c_basalt_mid);
for (var hx_line = -hw + 4; hx_line < hw - 2; hx_line += 5) {
    draw_line(x + hx_line, py - hh + 3, x + hx_line + 4, py + (hh * 0.3));
}

// Sacred Relic Chisel Inlays (Vertical glyph lines)
draw_set_color(c_trim);
draw_line_width(x - (hw * 0.5), py - (hh * 0.6), x - (hw * 0.5), py + (hh * 0.5), 1);
draw_line_width(x + (hw * 0.5), py - (hh * 0.6), x + (hw * 0.5), py + (hh * 0.5), 1);

// Monolithic Chassis Outer Edge
draw_set_color(c_basalt_mid);
draw_rectangle(x - hw, py - hh, x + hw, py + hh, true);

// Articulated Chiseled Limbs (Pose-aware)
draw_set_color(c_ink);
var leg_bot = y + bbox_hh;
if (state == PSTATE.RUN) {
    var leg_swing = sin(run_anim_t) * 9;
    draw_line_width(x - 4, py + hh, x - 4 + (leg_swing * facing), leg_bot, 3);
    draw_line_width(x + 4, py + hh, x + 4 - (leg_swing * facing), leg_bot, 3);
    // Bone knee studs
    draw_set_color(c_bone);
    draw_point(x - 4 + (leg_swing * facing), leg_bot);
    draw_point(x + 4 - (leg_swing * facing), leg_bot);
} else if (state == PSTATE.JUMP) {
    draw_line_width(x - 4, py + hh, x - 4 - (facing * 2), py + hh + 6, 3);
    draw_line_width(x + 4, py + hh, x + 4 - (facing * 4), py + hh + 8, 3);
    draw_set_color(c_bone);
    draw_point(x - 4 - (facing * 2), py + hh + 6);
} else if (state == PSTATE.FALL) {
    draw_line_width(x - 4, py + hh, x - 6, py + hh + 5, 3);
    draw_line_width(x + 4, py + hh, x + 6, py + hh + 5, 3);
} else if (state == PSTATE.DASH || active_power_id == POWER_ID.BLADE_SURGE) {
    var ddx = (state == PSTATE.DASH) ? dash_dir_x : facing;
    var ddy = (state == PSTATE.DASH) ? dash_dir_y : 0;
    draw_line_width(x - 4, py + hh, x - (ddx * 14), py - (ddy * 14), 4);
} else if (state == PSTATE.SLAM) {
    draw_line_width(x - 3, py + hh, x - 3, py + hh + 8, 3);
    draw_line_width(x + 3, py + hh, x + 3, py + hh + 8, 3);
    // Heavy plunging executioner blade
    draw_set_color(c_basalt_dark);
    draw_line_width(x, py + hh, x, py + hh + 22, 4);
    draw_set_color(c_bone);
    draw_line_width(x, py + hh, x, py + hh + 22, 2);
} else {
    // Braced combat stance
    draw_line_width(x - 4, py + hh, x - 6, leg_bot, 3);
    draw_line_width(x + 4, py + hh, x + 6, leg_bot, 3);
    draw_set_color(c_bone);
    draw_point(x - 6, leg_bot);
    draw_point(x + 6, leg_bot);
}

// Chiseled Bone Mask & Hollow Soul Visage
var mask_x = x + (facing * (hw - 3));
var mask_y = py - (hh * 0.45);

// Bone Mask Shell
draw_set_color(c_bone);
draw_rectangle(mask_x - 3, mask_y - 4, mask_x + 3, mask_y + 4, false);
draw_set_color(c_ink);
draw_rectangle(mask_x - 3, mask_y - 4, mask_x + 3, mask_y + 4, true);

// Hollow Eye Slit & Soul Ember
var eye_x = mask_x + (facing * 1);
var eye_y = mask_y - 1;
draw_set_color(overdrive_active ? c_gold : c_crimson);
draw_circle(eye_x, eye_y, 2, false);
draw_set_color(c_bone);
draw_point(eye_x, eye_y);

// Woodcut ink trail behind eye during slashes
if (state == PSTATE.ATTACK) {
    draw_set_color(c_crimson);
    draw_set_alpha(0.65);
    draw_line_width(eye_x, eye_y, eye_x - (facing * 14), eye_y, 2);
    draw_set_alpha(1.0);
}

// ---------------------------------------------------------------------
// 4. WEAPON: MONOLITHIC EXECUTIONER BLADE & WOODCUT ARCS
// ---------------------------------------------------------------------
var hx = x + (facing * (hw + 4));
var hy = py - 2;

if (state == PSTATE.ATTACK) {
    // Dynamic Woodcut Brush Arc
    var arc_r = 44 + (attack_step * 8);
    var start_ang = 0;
    var sweep_span = 135;

    switch (attack_step) {
        case 0: // Horizontal Executioner Cleave
            start_ang = (facing == 1) ? 30 : 150;
            break;
        case 1: // Rising Cleave
            start_ang = (facing == 1) ? 290 : 250;
            break;
        case 2: // Overhead Greatblade Smite
            start_ang = (facing == 1) ? 80 : 100;
            arc_r += 14;
            break;
    }

    // High-contrast Woodcut Brush Arc: Deep ink backdrop with bone cutting razor edge
    for (var k = 0; k < 6; k++) {
        var a1 = start_ang + (k * (sweep_span / 6) * facing);
        var a2 = start_ang + ((k + 1) * (sweep_span / 6) * facing);
        var x1 = x + lengthdir_x(arc_r, a1);
        var y1 = py + lengthdir_y(arc_r, a1);
        var x2 = x + lengthdir_x(arc_r, a2);
        var y2 = py + lengthdir_y(arc_r, a2);
        
        // Deep ink mass
        draw_set_color(c_ink);
        draw_set_alpha(0.4 + (k * 0.1));
        draw_line_width(x1, y1, x2, y2, 6 + (k * 0.5));
        
        // Bone razor fringe
        draw_set_color(c_bone);
        draw_set_alpha(0.6 + (k * 0.08));
        draw_line_width(x1, y1, x2, y2, 2);
        
        // Elemental cinnabar/gold runic accent
        if (c_trim != c_bone) {
            draw_set_color(c_trim);
            draw_set_alpha(0.3 + (k * 0.12));
            draw_line_width(x1, y1, x2, y2, 4);
        }
    }
    draw_set_alpha(1.0);

    // Monolithic Chiseled Executioner Blade Core
    var blade_tip_x = x + lengthdir_x(arc_r, start_ang + (sweep_span * facing));
    var blade_tip_y = py + lengthdir_y(arc_r, start_ang + (sweep_span * facing));
    
    // Blade Body: Basalt slab
    draw_set_color(c_basalt_dark);
    draw_line_width(hx, hy, blade_tip_x, blade_tip_y, 5);
    // Bone Razor Edge
    draw_set_color(c_bone);
    draw_line_width(hx, hy, blade_tip_x, blade_tip_y, 2);
    // Sacred Inlay Stroke
    draw_set_color(c_trim);
    draw_line_width(hx, hy, blade_tip_x, blade_tip_y, 1);
    
    if (overdrive_active) {
        draw_set_color(c_gold);
        draw_set_alpha(0.4);
        draw_line_width(hx, hy, blade_tip_x, blade_tip_y, 9);
        draw_set_alpha(1.0);
    }
} else {
    // Sheathed Blade strapped to back in sacred ropes
    var scabbard_len = 26;
    var scabbard_ang = (facing == 1) ? 135 : 45;
    var bx2 = x + lengthdir_x(scabbard_len, scabbard_ang);
    var by2 = py - 4 + lengthdir_y(scabbard_len, scabbard_ang);
    
    // Scabbard basalt spine
    draw_set_color(c_basalt_dark);
    draw_line_width(x, py - 4, bx2, by2, 4);
    // Bone edge trim
    draw_set_color(c_bone);
    draw_line_width(x, py - 4, bx2, by2, 1);
    // Relic pommel skull / ring
    draw_set_color(c_gold);
    draw_circle(bx2, by2, 2.5, false);
}

// Attack charge condensation: sacred concentric geometric ring
if (is_charging && charge_timer > 0) {
    var c_pct = clamp(charge_timer / global.cfg.combat.charge_time, 0, 1);
    var cr_radius = (40 * (1.0 - c_pct)) + 8;
    draw_set_color(c_gold);
    draw_set_alpha(c_pct);
    draw_circle(hx, hy, cr_radius, true);
    // Inner diamond glyph
    draw_line(hx - (cr_radius * 0.7), hy, hx, hy - (cr_radius * 0.7));
    draw_line(hx, hy - (cr_radius * 0.7), hx + (cr_radius * 0.7), hy);
    draw_line(hx + (cr_radius * 0.7), hy, hx, hy + (cr_radius * 0.7));
    draw_line(hx, hy + (cr_radius * 0.7), hx - (cr_radius * 0.7), hy);
    draw_set_alpha(1.0);
}

// ---------------------------------------------------------------------
// 5. PARRY AEGIS: SACRED GEOMETRIC MANDALA & STONE SEAL
// ---------------------------------------------------------------------
if (is_parrying) {
    var is_perf = (parry_timer <= global.cfg.parry.perfect_window);
    var c_aegis = is_perf ? c_gold : c_bone;
    var shield_x = x + (facing * (hw + 14));
    var shield_h = hh * 1.6;

    // Outer sacred vertical glyph pillar
    draw_set_color(c_aegis);
    draw_set_alpha(is_perf ? 0.95 : 0.75);
    draw_line_width(shield_x, py - shield_h, shield_x, py + shield_h, 3);

    // Sacred Diamond Mandala Teeth
    var m_rad = 14;
    draw_line_width(shield_x, py - m_rad, shield_x + (facing * m_rad), py, 2);
    draw_line_width(shield_x + (facing * m_rad), py, shield_x, py + m_rad, 2);
    draw_line_width(shield_x, py + m_rad, shield_x - (facing * m_rad), py, 2);
    draw_line_width(shield_x - (facing * m_rad), py, shield_x, py - m_rad, 2);

    // Inner concentric circle seal
    draw_circle(shield_x, py, 7, true);
    draw_set_alpha(0.2);
    draw_circle(shield_x, py, 7, false);
    draw_set_alpha(1.0);
}

// ---------------------------------------------------------------------
// 6. GRAPPLE: BRAIDED BINDING CHAIN & RELIQUARY HARPOON
// ---------------------------------------------------------------------
if (grapple.state != GRAPPLE_STATE.IDLE) {
    var gx = grapple.hook_x;
    var gy = grapple.hook_y;
    var cable_dist = point_distance(hx, hy, gx, gy);

    // Dark iron chain core
    draw_set_color(c_ink);
    draw_line_width(hx, hy, gx, gy, 3);
    draw_set_color(c_basalt_mid);
    draw_line_width(hx, hy, gx, gy, 1.5);

    // Prayer bead links along the chain
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
    // Barbed side flukes
    var h_ang = point_direction(hx, hy, gx, gy);
    var flk1_x = gx + lengthdir_x(8, h_ang + 150);
    var flk1_y = gy + lengthdir_y(8, h_ang + 150);
    var flk2_x = gx + lengthdir_x(8, h_ang - 150);
    var flk2_y = gy + lengthdir_y(8, h_ang - 150);
    draw_line_width(gx, gy, flk1_x, flk1_y, 2);
    draw_line_width(gx, gy, flk2_x, flk2_y, 2);
}
