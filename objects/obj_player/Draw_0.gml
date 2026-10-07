// =====================================================================
// QUAZERIUM — OBJ_PLAYER: High-Impact Cyber-Ronin Stylized Render
// Distinct silhouette, dynamic squash/stretch, afterimages, attack arcs & parry aegis.
// =====================================================================

var c_trim = make_color_rgb(0, 230, 255); // Default Cyan

switch (active_element) {
    case ELEMENT.FIRE:  c_trim = make_color_rgb(255, 110, 30); break;
    case ELEMENT.WATER: c_trim = make_color_rgb(40, 190, 255); break;
    case ELEMENT.EARTH: c_trim = make_color_rgb(220, 160, 60); break;
    case ELEMENT.WIND:  c_trim = make_color_rgb(80, 240, 160); break;
}

if (overdrive_active) {
    c_trim = make_color_rgb(255, 215, 0); // Gold
}

// ---------------------------------------------------------------------
// 1. GHOST AFTERIMAGES (Dash / Overdrive)
// ---------------------------------------------------------------------
for (var a = 0; a < 6; a++) {
    var ai = afterimages[a];
    if (ai.active && ai.alpha > 0.02) {
        draw_set_alpha(ai.alpha * 0.5);
        draw_set_color(ai.color);
        draw_rectangle(ai.x - bbox_hw, ai.y - bbox_hh, ai.x + bbox_hw, ai.y + bbox_hh, false);
    }
}
draw_set_alpha(1.0);

// ---------------------------------------------------------------------
// 2. OVERDRIVE AURA FLAME
// ---------------------------------------------------------------------
if (overdrive_active) {
    draw_set_color(c_yellow);
    var aura_r = bbox_hh + 8 + (sin(current_time * 0.015) * 4);
    draw_circle(x, y, aura_r, true);
    draw_set_alpha(0.3);
    draw_circle(x, y, aura_r * 0.7, false);
    draw_set_alpha(1.0);
}

// ---------------------------------------------------------------------
// 3. SQUASH & STRETCH ANATOMY
// ---------------------------------------------------------------------
var hw = bbox_hw * squash_x;
var hh = bbox_hh * squash_y;
var bob_y = (state == PSTATE.RUN) ? (abs(sin(run_anim_t)) * 3) : 0;
var py = y - bob_y;

var c_chassis_dark = make_color_rgb(24, 28, 36);
var c_chassis_mid  = make_color_rgb(38, 46, 60);

// Shadow beneath entity
if (on_ground) {
    draw_set_color(c_black);
    draw_set_alpha(0.4);
    draw_ellipse(x - (hw * 1.2), y + hh - 2, x + (hw * 1.2), y + hh + 2, false);
    draw_set_alpha(1.0);
}

// Torso / Armored Chassis
draw_set_color(c_chassis_dark);
draw_rectangle(x - hw, py - hh, x + hw, py + hh, false);

// Armor Plate Highlights
draw_set_color(c_chassis_mid);
draw_rectangle(x - hw + 2, py - hh + 2, x + hw - 2, py + (hh * 0.4), false);

// Elemental Conduit Edge Line
draw_set_color(c_trim);
draw_line_width(x - (hw * 0.6), py - hh + 4, x - (hw * 0.6), py + (hh * 0.6), 2);
draw_line_width(x + (hw * 0.6), py - hh + 4, x + (hw * 0.6), py + (hh * 0.6), 2);

// Outer Armor Rim
draw_set_color(c_trim);
draw_rectangle(x - hw, py - hh, x + hw, py + hh, true);

// Articulated Cybernetic Limbs (Pose-aware)
draw_set_color(c_chassis_dark);
var leg_bot = y + bbox_hh;
if (state == PSTATE.RUN) {
    var leg_swing = sin(run_anim_t) * 9;
    draw_line_width(x - 4, py + hh, x - 4 + (leg_swing * facing), leg_bot, 3);
    draw_line_width(x + 4, py + hh, x + 4 - (leg_swing * facing), leg_bot, 3);
    draw_set_color(c_trim);
    draw_point(x - 4 + (leg_swing * facing), leg_bot);
    draw_point(x + 4 - (leg_swing * facing), leg_bot);
} else if (state == PSTATE.JUMP) {
    draw_line_width(x - 4, py + hh, x - 4 - (facing * 2), py + hh + 6, 3);
    draw_line_width(x + 4, py + hh, x + 4 - (facing * 4), py + hh + 8, 3);
} else if (state == PSTATE.FALL) {
    draw_line_width(x - 4, py + hh, x - 6, py + hh + 4, 3);
    draw_line_width(x + 4, py + hh, x + 6, py + hh + 4, 3);
} else if (state == PSTATE.DASH) {
    draw_line_width(x - 4, py + hh, x - (dash_dir_x * 14), py - (dash_dir_y * 14), 3);
} else if (state == PSTATE.SLAM) {
    draw_line_width(x - 3, py + hh, x - 3, py + hh + 8, 3);
    draw_line_width(x + 3, py + hh, x + 3, py + hh + 8, 3);
    // Vertical descent blade
    draw_set_color(c_white);
    draw_line_width(x, py + hh, x, py + hh + 22, 3);
    draw_set_color(c_trim);
    draw_line_width(x, py + hh, x, py + hh + 22, 5);
} else {
    // Braced combat idle stance
    draw_line_width(x - 4, py + hh, x - 6, leg_bot, 3);
    draw_line_width(x + 4, py + hh, x + 6, leg_bot, 3);
}

// Cyber Visor / Optical Eye
var eye_x = x + (facing * (hw - 4));
var eye_y = py - (hh * 0.5);
draw_set_color(c_yellow);
draw_circle(eye_x, eye_y, 3, false);
draw_set_color(c_white);
draw_circle(eye_x, eye_y, 1.5, false);

// Motion eye streak during attack
if (state == PSTATE.ATTACK) {
    draw_set_color(c_yellow);
    draw_set_alpha(0.6);
    draw_line_width(eye_x, eye_y, eye_x - (facing * 12), eye_y, 2);
    draw_set_alpha(1.0);
}

// ---------------------------------------------------------------------
// 4. WEAPON & ATTACK ARCS (Energy Katana / Saber)
// ---------------------------------------------------------------------
var hx = x + (facing * (hw + 4));
var hy = py - 2;

if (state == PSTATE.ATTACK) {
    // Dynamic luminous weapon slash arc
    var arc_r = 42 + (attack_step * 8);
    var start_ang = 0;
    var sweep_span = 130;

    switch (attack_step) {
        case 0: // Horizontal Cleave
            start_ang = (facing == 1) ? 30 : 150;
            break;
        case 1: // Rising Slash
            start_ang = (facing == 1) ? 290 : 250;
            break;
        case 2: // Heavy Finisher Overhand Cleave
            start_ang = (facing == 1) ? 80 : 100;
            arc_r += 12;
            break;
    }

    // Draw crescent arc trail
    draw_set_color(c_trim);
    for (var k = 0; k < 6; k++) {
        var a1 = start_ang + (k * (sweep_span / 6) * facing);
        var a2 = start_ang + ((k + 1) * (sweep_span / 6) * facing);
        var x1 = x + lengthdir_x(arc_r, a1);
        var y1 = py + lengthdir_y(arc_r, a1);
        var x2 = x + lengthdir_x(arc_r, a2);
        var y2 = py + lengthdir_y(arc_r, a2);
        draw_set_alpha(0.2 + (k * 0.13));
        draw_line_width(x1, y1, x2, y2, 3 + (k * 0.5));
    }
    draw_set_alpha(1.0);

    // Blade core beam
    var blade_tip_x = x + lengthdir_x(arc_r, start_ang + (sweep_span * facing));
    var blade_tip_y = py + lengthdir_y(arc_r, start_ang + (sweep_span * facing));
    draw_set_color(c_white);
    draw_line_width(hx, hy, blade_tip_x, blade_tip_y, 3);
    draw_set_color(c_trim);
    draw_line_width(hx, hy, blade_tip_x, blade_tip_y, 5);
} else {
    // Sheathed Blade angled on back
    var scabbard_len = 24;
    var scabbard_ang = (facing == 1) ? 135 : 45;
    var bx2 = x + lengthdir_x(scabbard_len, scabbard_ang);
    var by2 = py - 4 + lengthdir_y(scabbard_len, scabbard_ang);
    draw_set_color(c_chassis_mid);
    draw_line_width(x, py - 4, bx2, by2, 3);
    draw_set_color(c_trim);
    draw_circle(bx2, by2, 2, false);
}

// Attack charge condensation ring
if (is_charging && charge_timer > 0) {
    var c_pct = clamp(charge_timer / global.cfg.combat.charge_time, 0, 1);
    var cr_radius = (40 * (1.0 - c_pct)) + 8;
    draw_set_color(c_orange);
    draw_set_alpha(c_pct);
    draw_circle(hx, hy, cr_radius, true);
    draw_set_alpha(1.0);
}

// ---------------------------------------------------------------------
// 5. PARRY AEGIS (Holographic Energy Barrier)
// ---------------------------------------------------------------------
if (is_parrying) {
    var is_perf = (parry_timer <= global.cfg.parry.perfect_window);
    var c_shield = is_perf ? c_yellow : c_aqua;
    var shield_x = x + (facing * (hw + 14));
    var shield_h = hh * 1.5;

    draw_set_color(c_shield);
    draw_set_alpha(is_perf ? 0.9 : 0.7);
    draw_line_width(shield_x, py - shield_h, shield_x, py + shield_h, 4);

    // Hexagonal / Bracket Energy Teeth
    draw_line(shield_x, py - shield_h, shield_x - (facing * 8), py - shield_h + 8);
    draw_line(shield_x, py + shield_h, shield_x - (facing * 8), py + shield_h - 8);

    draw_set_alpha(0.2);
    draw_rectangle(shield_x - (facing * 6), py - shield_h, shield_x, py + shield_h, false);
    draw_set_alpha(1.0);
}

// ---------------------------------------------------------------------
// 6. GRAPPLE CABLE WITH LINK JOINTS
// ---------------------------------------------------------------------
if (grapple.state != GRAPPLE_STATE.IDLE) {
    var gx = grapple.hook_x;
    var gy = grapple.hook_y;
    var cable_dist = point_distance(hx, hy, gx, gy);

    // Cable line
    draw_set_color(c_aqua);
    draw_line_width(hx, hy, gx, gy, 2);

    // Segmented joint beads
    var num_beads = min(12, floor(cable_dist / 30));
    draw_set_color(c_white);
    for (var b = 1; b < num_beads; b++) {
        var bt = b / num_beads;
        var bead_x = lerp(hx, gx, bt);
        var bead_y = lerp(hy, gy, bt);
        draw_circle(bead_x, bead_y, 2, false);
    }

    // Hook head claw
    draw_set_color(c_white);
    draw_circle(gx, gy, 5, false);
    draw_set_color(c_aqua);
    draw_circle(gx, gy, 7, true);
}
