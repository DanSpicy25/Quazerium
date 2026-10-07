// =====================================================================
// QUAZERIUM — OBJ_HUD: Action Game In-Game Heads-Up Display
// =====================================================================

if (!instance_exists(obj_player)) exit;
var p = obj_player;

var c_panel_bg = make_color_rgb(18, 22, 28);
var c_panel_border = make_color_rgb(45, 55, 70);
var c_cyan_neon = make_color_rgb(0, 230, 255);
var c_gold = make_color_rgb(255, 215, 0);

// ---------------------------------------------------------------------
// 1. TOP-LEFT: VITALITY & ENERGY BARS
// ---------------------------------------------------------------------
var bx = 28;
var by = 28;
var bar_w = 240;

// Panel frame backing
draw_set_color(c_panel_bg);
draw_set_alpha(0.85);
draw_rectangle(bx - 8, by - 8, bx + bar_w + 16, by + 58, false);
draw_set_color(c_panel_border);
draw_set_alpha(1.0);
draw_rectangle(bx - 8, by - 8, bx + bar_w + 16, by + 58, true);

// HP Bar backing
draw_set_color(make_color_rgb(40, 20, 20));
draw_rectangle(bx, by, bx + bar_w, by + 14, false);

// HP Red Lag Bar (recently lost health)
var lag_pct = clamp(hp_lag / 100, 0, 1);
draw_set_color(make_color_rgb(180, 50, 50));
draw_rectangle(bx, by, bx + (bar_w * lag_pct), by + 14, false);

// HP Foreground Bar
var hp_pct = clamp(p.hp / 100, 0, 1);
var c_hp = (hp_pct > 0.3) ? make_color_rgb(50, 220, 120) : make_color_rgb(255, 60, 60);
draw_set_color(c_hp);
draw_rectangle(bx, by, bx + (bar_w * hp_pct), by + 14, false);

// HP Text
draw_set_color(c_white);
draw_text(bx + 6, by + 1, "HP " + string(p.hp) + " / 100");

// Energy Bar backing
var ey = by + 20;
draw_set_color(make_color_rgb(20, 35, 50));
draw_rectangle(bx, ey, bx + bar_w, ey + 10, false);

// Energy Fill
var nrg_pct = clamp(p.energy / global.cfg.energy.max, 0, 1);
var c_nrg = (p.energy >= global.cfg.energy.max) ? c_gold : c_cyan_neon;
draw_set_color(c_nrg);
draw_rectangle(bx, ey, bx + (bar_w * nrg_pct), ey + 10, false);

// Overdrive Ready / Active Status
var oy = ey + 16;
if (p.overdrive_active) {
    draw_set_color(c_gold);
    var ovr_str = "OVERDRIVE: " + string_format(p.overdrive_timer, 1, 1) + "s";
    draw_text(bx, oy, ovr_str);
} else if (p.energy >= global.cfg.energy.max) {
    var pulse = 0.7 + (sin(current_time * 0.01) * 0.3);
    draw_set_color(c_gold);
    draw_set_alpha(pulse);
    draw_text(bx, oy, "[R] OVERDRIVE READY");
    draw_set_alpha(1.0);
} else {
    draw_set_color(make_color_rgb(140, 160, 180));
    draw_text(bx, oy, "ENERGY: " + string(p.energy) + "%");
}

// ---------------------------------------------------------------------
// 2. MID-LEFT: DYNAMIC COMBO COUNTER
// ---------------------------------------------------------------------
if (p.combo_count > 0) {
    var cy = 115;
    var c_combo = c_white;
    if (p.combo_count >= 5)  c_combo = c_cyan_neon;
    if (p.combo_count >= 10) c_combo = c_gold;
    if (p.combo_count >= 15) c_combo = make_color_rgb(255, 70, 70);

    draw_set_color(c_combo);
    var combo_txt = "COMBO x" + string(p.combo_count);
    draw_text_transformed(bx, cy, combo_txt, combo_scale, combo_scale, 0);

    // Multiplier bonus tag
    var bonus_pct = round(p.combo_count * global.cfg.combat.combo_step * 100);
    draw_set_color(make_color_rgb(180, 200, 220));
    draw_text(bx, cy + 22, "+" + string(bonus_pct) + "% DMG");

    // Combo timer decay meter
    var t_pct = clamp(p.combo_timer / global.cfg.combat.combo_window, 0, 1);
    draw_set_color(make_color_rgb(40, 50, 60));
    draw_rectangle(bx, cy + 40, bx + 120, cy + 44, false);
    draw_set_color(c_combo);
    draw_rectangle(bx, cy + 40, bx + (120 * t_pct), cy + 44, false);
}

// ---------------------------------------------------------------------
// 3. BOTTOM-LEFT: ELEMENTAL ATTUNEMENT BADGE
// ---------------------------------------------------------------------
var ely_x = 28;
var ely_y = 630;

var c_el = c_white;
var el_name = global.element_names[p.active_element];
switch (p.active_element) {
    case ELEMENT.FIRE:  c_el = make_color_rgb(255, 120, 40); break;
    case ELEMENT.WATER: c_el = make_color_rgb(50, 200, 255); break;
    case ELEMENT.EARTH: c_el = make_color_rgb(200, 150, 80); break;
    case ELEMENT.WIND:  c_el = make_color_rgb(100, 255, 180); break;
}

draw_set_color(c_panel_bg);
draw_set_alpha(0.85);
draw_rectangle(ely_x - 6, ely_y - 6, ely_x + 160, ely_y + 44, false);
draw_set_color(c_panel_border);
draw_set_alpha(1.0);
draw_rectangle(ely_x - 6, ely_y - 6, ely_x + 160, ely_y + 44, true);

// Diamond icon
draw_set_color(c_el);
draw_triangle(ely_x + 14, ely_y + 4, ely_x + 24, ely_y + 14, ely_x + 4, ely_y + 14, false);
draw_triangle(ely_x + 14, ely_y + 24, ely_x + 24, ely_y + 14, ely_x + 4, ely_y + 14, false);

draw_text(ely_x + 36, ely_y + 6, el_name);
draw_set_color(make_color_rgb(140, 160, 180));
draw_text(ely_x + 8, ely_y + 26, "[TAB] CYCLE");

// ---------------------------------------------------------------------
// 4. BOTTOM-CENTER: ACTIVE POWERS SELECTOR
// ---------------------------------------------------------------------
var pw_cx = 640;
var pw_cy = 645;
var slot_w = 68;
var slot_gap = 14;
var total_w = (3 * slot_w) + (2 * slot_gap);
var start_pw_x = pw_cx - (total_w / 2);

var powers_list = [POWER_ID.SHOCKWAVE, POWER_ID.BLADE_SURGE, POWER_ID.BLINK];
var power_keys = ["1", "2", "3"];

for (var k = 0; k < 3; k++) {
    var pid = powers_list[k];
    var sx = start_pw_x + (k * (slot_w + slot_gap));
    var is_sel = (p.selected_power_id == pid);

    draw_set_color(is_sel ? make_color_rgb(30, 42, 58) : c_panel_bg);
    draw_set_alpha(0.85);
    draw_rectangle(sx, pw_cy, sx + slot_w, pw_cy + 42, false);

    draw_set_color(is_sel ? c_cyan_neon : c_panel_border);
    draw_set_alpha(1.0);
    draw_rectangle(sx, pw_cy, sx + slot_w, pw_cy + 42, true);

    // Key tag & Name
    draw_set_color(is_sel ? c_white : make_color_rgb(160, 175, 190));
    draw_text(sx + 6, pw_cy + 4, "[" + power_keys[k] + "]");
    var p_info = power_get(pid);
    draw_text(sx + 6, pw_cy + 22, (pid == POWER_ID.SHOCKWAVE) ? "WAVE" : ((pid == POWER_ID.BLADE_SURGE) ? "SURGE" : "BLINK"));

    // Selection bracket
    if (is_sel) {
        draw_set_color(c_cyan_neon);
        draw_line_width(sx, pw_cy - 3, sx + slot_w, pw_cy - 3, 2);
    }
}
draw_set_color(make_color_rgb(140, 160, 180));
draw_set_halign(fa_center);
draw_text(pw_cx, pw_cy + 48, "[Q] CAST ACTIVE POWER");
draw_set_halign(fa_left);

// ---------------------------------------------------------------------
// 5. BOTTOM-RIGHT: MINIMAL COMMAND LEGEND
// ---------------------------------------------------------------------
var leg_rx = 1256;
var leg_ry = 690;
draw_set_halign(fa_right);
draw_set_color(make_color_rgb(110, 125, 140));
draw_text(leg_rx, leg_ry, "[A/D] Move  [Space] Jump  [Shift] Dash  [J] Attack  [K] Parry  [E] Grapple  [F1] Telemetry");
draw_set_halign(fa_left);
