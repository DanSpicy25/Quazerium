// =====================================================================
// QUAZERIUM — OBJ_PLAYER: Procedural functional render
// Shows state, element, overdrive, parry shield, grapple line, and charge glow.
// =====================================================================

var c_body = make_color_rgb(70, 150, 255); // Default cyan-blue

// Element color accent
switch (active_element) {
    case ELEMENT.FIRE:  c_body = make_color_rgb(255, 100, 50); break;
    case ELEMENT.WATER: c_body = make_color_rgb(50, 180, 255); break;
    case ELEMENT.EARTH: c_body = make_color_rgb(180, 130, 70); break;
    case ELEMENT.WIND:  c_body = make_color_rgb(80, 230, 160); break;
}

if (overdrive_active) {
    // Golden flaming aura in Overdrive
    c_body = make_color_rgb(255, 215, 0);
    draw_set_color(c_yellow);
    draw_circle(x, y, bbox_hh + 6 + (sin(current_time * 0.01) * 3), true);
}

// 1. Grapple rope line
if (grapple.state != GRAPPLE_STATE.IDLE) {
    draw_set_color(c_aqua);
    draw_line_width(x, y, grapple.hook_x, grapple.hook_y, 2);
    draw_set_color(c_white);
    draw_circle(grapple.hook_x, grapple.hook_y, 4, false);
}

// 2. Dash / Iframes ghosting effect
if (iframes > 0) {
    draw_set_alpha(0.6);
}

// 3. Body
draw_set_color(c_body);
draw_rectangle(x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh, false);
draw_set_color(c_white);
draw_rectangle(x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh, true);

// 4. Facing visor
draw_set_color(c_yellow);
var eye_x = x + (facing * (bbox_hw - 3));
draw_circle(eye_x, y - 6, 3, false);

// 5. Parry Shield
if (is_parrying) {
    var c_shield = (parry_timer <= global.cfg.parry.perfect_window) ? c_yellow : c_aqua;
    draw_set_color(c_shield);
    var sx = x + (facing * (bbox_hw + 8));
    draw_line_width(sx, y - bbox_hh, sx, y + bbox_hh, 4);
}

// 6. Charge Glow
if (charge_timer > 0) {
    var pct = clamp(charge_timer / global.cfg.combat.charge_time, 0, 1);
    draw_set_color(c_orange);
    draw_set_alpha(pct * 0.5);
    draw_circle(x, y, (bbox_hh * 1.2) * pct, false);
    draw_set_alpha(1.0);
}

draw_set_alpha(1.0);

