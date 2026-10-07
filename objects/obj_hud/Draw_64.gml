// =====================================================================
// QUAZERIUM — OBJ_HUD: Action Game In-Game Heads-Up Display
// High-legibility, tactile combat interface (Zero SaaS/Dashboard fluff).
// Virtual Canvas: 1280x720 (configured via display_set_gui_size).
// =====================================================================

if (!instance_exists(obj_player)) exit;
var p = obj_player;

// ---------------------------------------------------------------------
// COLOR PALETTE CONSTANTS
// ---------------------------------------------------------------------
var c_dark_obsidian = make_color_rgb(12, 16, 22);
var c_panel_border  = make_color_rgb(42, 54, 72);
var c_panel_accent  = make_color_rgb(26, 36, 50);
var c_cyan_neon     = make_color_rgb(0, 230, 255);
var c_gold_bright   = make_color_rgb(255, 215, 0);
var c_crimson_burn  = make_color_rgb(255, 45, 65);
var c_steel_muted   = make_color_rgb(140, 160, 180);
var c_emerald_tech  = make_color_rgb(40, 230, 130);
var c_bone          = make_color_rgb(238, 235, 224);

// =====================================================================
// 1. TOP-LEFT: VITALITY & ENERGY ENGINE
// =====================================================================
var bx = 28;
var by = 24;
var bar_w = 260;
var panel_w = bar_w + 32;
var panel_h = 74;

// Panel Base Backing with Chamfered Tactical Aesthetic
draw_set_color(c_dark_obsidian);
draw_set_alpha(0.88);
draw_rectangle(bx - 10, by - 10, bx + panel_w, by + panel_h, false);

// Panel Outer Border & Technical Corner Brackets
draw_set_color(c_panel_border);
draw_set_alpha(1.0);
draw_rectangle(bx - 10, by - 10, bx + panel_w, by + panel_h, true);

// Header Tag
draw_set_color(c_steel_muted);
draw_text(bx, by - 6, "CHASSIS INTEGRITY // QZ-CORE");

// --- A. VITALITY (HP) GAUGE ---
var hy = by + 12;
var bar_h = 16;

// HP Tray Backing (Deep burgundy)
draw_set_color(make_color_rgb(32, 14, 18));
draw_rectangle(bx, hy, bx + bar_w, hy + bar_h, false);

// HP Red Damage Lag Bar (Recently lost health shrinking to current)
var max_hp_val = max(1, p.max_hp);
var lag_pct = clamp(hp_lag / max_hp_val, 0, 1);
draw_set_color(make_color_rgb(215, 45, 45));
draw_rectangle(bx, hy, bx + (bar_w * lag_pct), hy + bar_h, false);

// HP Foreground Bar (Active Vitality)
var hp_pct = clamp(p.hp / max_hp_val, 0, 1);
var c_hp = (hp_pct > 0.3) ? c_emerald_tech : c_crimson_burn;

if (hp_pct <= 0.3) {
    // Low HP pulsing feedback
    var hp_pulse = 0.75 + (sin(current_time * 0.015) * 0.25);
    draw_set_alpha(hp_pulse);
}
draw_set_color(c_hp);
draw_rectangle(bx, hy, bx + (bar_w * hp_pct), hy + bar_h, false);
draw_set_alpha(1.0);

// Segment Ticks: 10 vertical segment dividers (10% increments)
draw_set_color(c_dark_obsidian);
draw_set_alpha(0.65);
for (var i = 1; i < 10; i++) {
    var tick_x = bx + round(bar_w * (i / 10));
    draw_line(tick_x, hy, tick_x, hy + bar_h);
}
draw_set_alpha(1.0);

// HP Bar Border
draw_set_color(c_panel_border);
draw_rectangle(bx, hy, bx + bar_w, hy + bar_h, true);

// HP Numeric Readout
draw_set_color(c_black);
draw_text(bx + 7, hy + 2, "HP " + string(ceil(p.hp)) + " / " + string(p.max_hp));
draw_set_color(c_white);
draw_text(bx + 6, hy + 1, "HP " + string(ceil(p.hp)) + " / " + string(p.max_hp));

// Critical Alert Tag
if (hp_pct <= 0.3) {
    var alert_a = 0.7 + (sin(current_time * 0.02) * 0.3);
    draw_set_color(c_crimson_burn);
    draw_set_alpha(alert_a);
    draw_text(bx + bar_w - 78, hy + 1, "CRITICAL");
    draw_set_alpha(1.0);
}

// --- B. ENERGY & OVERDRIVE GAUGE ---
var ey = hy + 22;
var nrg_h = 10;

// Energy Tray Backing
draw_set_color(make_color_rgb(14, 26, 38));
draw_rectangle(bx, ey, bx + bar_w, ey + nrg_h, false);

if (p.overdrive_active) {
    // Overdrive Active: Drain Bar
    var ovr_dur = max(0.1, global.cfg.overdrive.duration);
    var ovr_pct = clamp(p.overdrive_timer / ovr_dur, 0, 1);
    draw_set_color(c_gold_bright);
    draw_rectangle(bx, ey, bx + (bar_w * ovr_pct), ey + nrg_h, false);
} else {
    // Standard Energy Accumulation
    var nrg_pct = clamp(p.energy / global.cfg.energy.max, 0, 1);
    var c_nrg = (p.energy >= global.cfg.energy.max) ? c_gold_bright : c_cyan_neon;
    draw_set_color(c_nrg);
    draw_rectangle(bx, ey, bx + (bar_w * nrg_pct), ey + nrg_h, false);
}

// Energy Segment Ticks (4 segments: 25%, 50%, 75%)
draw_set_color(c_dark_obsidian);
draw_set_alpha(0.65);
for (var k = 1; k < 4; k++) {
    var tick_nrg = bx + round(bar_w * (k / 4));
    draw_line(tick_nrg, ey, tick_nrg, ey + nrg_h);
}
draw_set_alpha(1.0);

// Energy Bar Border
draw_set_color(p.overdrive_active ? c_gold_bright : c_panel_border);
draw_rectangle(bx, ey, bx + bar_w, ey + nrg_h, true);

// Energy / Overdrive Status Text
var sy = ey + 14;
if (p.overdrive_active) {
    draw_set_color(c_gold_bright);
    draw_text(bx, sy, "OVERDRIVE ACTIVE // " + string_format(p.overdrive_timer, 1, 1) + "s");
} else if (p.energy >= global.cfg.energy.max) {
    var od_pulse = 0.7 + (sin(current_time * 0.012) * 0.3);
    draw_set_color(c_gold_bright);
    draw_set_alpha(od_pulse);
    draw_text(bx, sy, "[V] OVERDRIVE READY");
    draw_set_alpha(1.0);
} else {
    draw_set_color(c_steel_muted);
    draw_text(bx, sy, "ENERGY: " + string(floor(p.energy)) + "%");
}

// --- C. WEAPON & ARMAMENT LOADOUT MODULE ---
var wy = sy + 18;
var is_sg = (p.current_weapon == WEAPON_ID.SHOTGUN);

// Weapon 1: Executioner Blade Tab
var w1_w = (bar_w / 2) - 3;
draw_set_color(c_dark_obsidian);
draw_set_alpha(0.88);
draw_rectangle(bx, wy, bx + w1_w, wy + 26, false);
draw_set_color(!is_sg ? c_gold_bright : c_panel_border);
draw_set_alpha(1.0);
draw_rectangle(bx, wy, bx + w1_w, wy + 26, true);
if (!is_sg) {
    draw_set_color(c_gold_bright);
    draw_line_width(bx, wy - 2, bx + w1_w, wy - 2, 2);
}
draw_set_color(!is_sg ? c_white : c_steel_muted);
draw_text(bx + 6, wy + 5, "[1] SWORD");

// Weapon 2: Relic Blunderbuss Tab
var w2_x = bx + w1_w + 6;
var w2_w = w1_w;
draw_set_color(c_dark_obsidian);
draw_set_alpha(0.88);
draw_rectangle(w2_x, wy, w2_x + w2_w, wy + 26, false);
draw_set_color(is_sg ? (p.shotgun_empowered ? c_gold_bright : c_cyan_neon) : c_panel_border);
draw_set_alpha(1.0);
draw_rectangle(w2_x, wy, w2_x + w2_w, wy + 26, true);
if (is_sg) {
    draw_set_color(p.shotgun_empowered ? c_gold_bright : c_cyan_neon);
    draw_line_width(w2_x, wy - 2, w2_x + w2_w, wy - 2, 2);
}
draw_set_color(is_sg ? (p.shotgun_empowered ? c_gold_bright : c_cyan_neon) : c_steel_muted);
draw_text(w2_x + 6, wy + 5, p.shotgun_empowered ? "[2] SHOTGUN*" : "[2] SHOTGUN");

// Shotgun Ammo Pips inside Tab
var pip_x = w2_x + w2_w - 38;
var pip_y = wy + 7;
for (var s = 0; s < global.cfg.shotgun.ammo_max; s++) {
    var has_shell = (s < p.shotgun_ammo);
    var c_shell = has_shell ? (p.shotgun_empowered ? c_gold_bright : c_crimson_burn) : c_panel_border;
    draw_set_color(c_shell);
    draw_rectangle(pip_x + (s * 15), pip_y, pip_x + (s * 15) + 11, pip_y + 11, !has_shell);
    if (has_shell) {
        draw_set_color(p.shotgun_empowered ? c_gold_bright : c_bone);
        draw_rectangle(pip_x + (s * 15) + 2, pip_y + 2, pip_x + (s * 15) + 9, pip_y + 9, false);
    }
}

// Sub-strip: Quick Swap & Reload Hint
draw_set_color(c_steel_muted);
draw_text(bx, wy + 30, "[Q] SWAP WEAPON  |  [R] ACTIVE RELOAD");

// =====================================================================
// 2. MID-LEFT: DYNAMIC ARCADE COMBO RANK ENGINE
// =====================================================================
if (p.combo_count > 0) {
    var cx = 28;
    var cy = 126;
    var r_info = combat_get_combo_rank(p.combo_count);

    if (r_info != undefined) {
        var c_rank = make_color_rgb(r_info.r, r_info.g, r_info.b);

        // Rank Badge Frame (Square with bevel)
        var badge_size = 46;
        draw_set_color(c_dark_obsidian);
        draw_set_alpha(0.90);
        draw_rectangle(cx, cy, cx + badge_size, cy + badge_size, false);
        draw_set_color(c_rank);
        draw_set_alpha(1.0);
        draw_rectangle(cx, cy, cx + badge_size, cy + badge_size, true);

        // Rank Letter centered inside badge
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_rank);
        var letter_scale = 2.0 * combo_scale;
        draw_text_transformed(cx + (badge_size / 2), cy + (badge_size / 2) + 1, r_info.rank, letter_scale, letter_scale, 0);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        // Combo Metrics (Right of Badge)
        var tx = cx + badge_size + 12;

        // Line 1: Title (e.g. SUPREME, ANARCHY, BRUTAL)
        draw_set_color(c_rank);
        draw_text(tx, cy + 2, r_info.title);

        // Line 2: Hit Counter with Pop Animation
        draw_set_color(c_white);
        var combo_str = "COMBO x" + string(p.combo_count);
        draw_text_transformed(tx, cy + 16, combo_str, combo_scale, combo_scale, 0);

        // Line 3: Damage Multiplier Bonus
        var bonus_pct = round(min(p.combo_count, global.cfg.combat.combo_cap) * global.cfg.combat.combo_step * 100);
        draw_set_color(c_cyan_neon);
        draw_text(tx, cy + 34, "+" + string(bonus_pct) + "% DMG");

        // Combo Timer Decay Meter Bar
        var meter_y = cy + 52;
        var meter_w = 170;
        var meter_h = 5;
        var t_pct = clamp(p.combo_timer / global.cfg.combat.combo_window, 0, 1);

        draw_set_color(make_color_rgb(25, 34, 46));
        draw_rectangle(cx, meter_y, cx + meter_w, meter_y + meter_h, false);

        // Critical decay flash when combo timer is running out (<0.35s)
        var c_meter_fill = c_rank;
        if (p.combo_timer < 0.35 && (current_time mod 160 < 80)) {
            c_meter_fill = c_white;
        }
        draw_set_color(c_meter_fill);
        draw_rectangle(cx, meter_y, cx + (meter_w * t_pct), meter_y + meter_h, false);
        draw_set_color(c_panel_border);
        draw_rectangle(cx, meter_y, cx + meter_w, meter_y + meter_h, true);
    }
}

// =====================================================================
// 3. BOTTOM-LEFT: ELEMENTAL ATTUNEMENT CAPACITOR BADGE
// =====================================================================
var ely_x = 28;
var ely_y = 618;
var el_badge_w = 175;
var el_badge_h = 60;

// Element Accent Colors & Names
var c_el = c_white;
var el_name = global.element_names[p.active_element];
switch (p.active_element) {
    case ELEMENT.FIRE:  c_el = make_color_rgb(255, 115, 35); break;
    case ELEMENT.WATER: c_el = make_color_rgb(40, 195, 255); break;
    case ELEMENT.EARTH: c_el = make_color_rgb(220, 160, 60); break;
    case ELEMENT.WIND:  c_el = make_color_rgb(60, 255, 175); break;
    default:            c_el = make_color_rgb(200, 215, 230); break;
}

// Badge Frame
draw_set_color(c_dark_obsidian);
draw_set_alpha(0.88);
draw_rectangle(ely_x, ely_y, ely_x + el_badge_w, ely_y + el_badge_h, false);
draw_set_color(c_panel_border);
draw_set_alpha(1.0);
draw_rectangle(ely_x, ely_y, ely_x + el_badge_w, ely_y + el_badge_h, true);

// Procedural Geometric Element Glyph
var gx = ely_x + 20;
var gy = ely_y + 30;
draw_set_color(c_el);
switch (p.active_element) {
    case ELEMENT.FIRE:
        // Flame chevron
        draw_triangle(gx, gy - 12, gx + 10, gy + 8, gx - 10, gy + 8, false);
        draw_triangle(gx, gy - 4, gx + 6, gy + 12, gx - 6, gy + 12, false);
        break;
    case ELEMENT.WATER:
        // Diamond droplet
        draw_triangle(gx, gy - 12, gx + 9, gy, gx - 9, gy, false);
        draw_triangle(gx, gy + 12, gx + 9, gy, gx - 9, gy, false);
        break;
    case ELEMENT.EARTH:
        // Fortified trapezoid prism
        draw_rectangle(gx - 9, gy - 8, gx + 9, gy + 8, false);
        draw_rectangle(gx - 5, gy - 12, gx + 5, gy - 9, false);
        break;
    case ELEMENT.WIND:
        // Motion slashes
        draw_line_width(gx - 8, gy + 8, gx + 4, gy - 8, 3);
        draw_line_width(gx - 2, gy + 8, gx + 10, gy - 8, 3);
        break;
    default:
        // Neutral target reticle
        draw_rectangle(gx - 6, gy - 6, gx + 6, gy + 6, true);
        break;
}

// Text Labels
draw_set_color(c_steel_muted);
draw_text(ely_x + 38, ely_y + 8, "ELEMENT MATRIX");
draw_set_color(c_el);
draw_text(ely_x + 38, ely_y + 24, el_name);
draw_set_color(c_steel_muted);
draw_text(ely_x + 38, ely_y + 42, "[TAB] CYCLE");

// 4 Elemental Tuning Pips at Bottom Right of Badge
for (var ep = 1; ep < ELEMENT.COUNT; ep++) {
    var pip_x = ely_x + el_badge_w - 44 + ((ep - 1) * 10);
    var pip_y = ely_y + el_badge_h - 12;
    draw_set_color((p.active_element == ep) ? c_el : c_panel_accent);
    draw_rectangle(pip_x, pip_y, pip_x + 6, pip_y + 4, false);
}

// =====================================================================
// 4. BOTTOM-CENTER: TACTICAL MODULAR POWERS DECK
// =====================================================================
var pw_cx = 640;
var pw_cy = 628;
var card_w = 82;
var card_h = 56;
var card_gap = 12;
var deck_w = (3 * card_w) + (2 * card_gap);
var start_pw_x = pw_cx - (deck_w / 2);

var powers_list = [POWER_ID.SHOCKWAVE, POWER_ID.BLADE_SURGE, POWER_ID.BLINK];
var power_keys  = ["3", "4", "5"];
var power_names_short = ["WAVE", "SURGE", "BLINK"];

for (var k = 0; k < 3; k++) {
    var pid = powers_list[k];
    var p_def = power_get(pid);
    var sx = start_pw_x + (k * (card_w + card_gap));
    var is_sel = (p.selected_power_id == pid);
    var cd_obj = p.power_cooldowns[pid];
    var is_ready = cd_obj.ready();
    var has_nrg = (p.energy >= p_def.cfg.cost);

    // Card Backing
    draw_set_color(is_sel ? make_color_rgb(22, 34, 48) : c_dark_obsidian);
    draw_set_alpha((!has_nrg && is_ready) ? 0.60 : 0.88);
    draw_rectangle(sx, pw_cy, sx + card_w, pw_cy + card_h, false);

    // Card Border
    draw_set_color(is_sel ? c_cyan_neon : c_panel_border);
    draw_set_alpha(1.0);
    draw_rectangle(sx, pw_cy, sx + card_w, pw_cy + card_h, true);

    // Selected Top Bracket Indicator
    if (is_sel) {
        draw_set_color(c_cyan_neon);
        draw_line_width(sx, pw_cy - 3, sx + card_w, pw_cy - 3, 2);
    }

    // Key Hotkey & Energy Cost
    draw_set_color(is_sel ? c_white : c_steel_muted);
    draw_text(sx + 6, pw_cy + 4, "[" + power_keys[k] + "]");

    draw_set_halign(fa_right);
    draw_set_color(has_nrg ? c_cyan_neon : c_crimson_burn);
    draw_text(sx + card_w - 6, pw_cy + 4, string(p_def.cfg.cost) + "E");
    draw_set_halign(fa_left);

    // Power Short Name
    draw_set_halign(fa_center);
    draw_set_color(is_sel ? c_white : c_steel_muted);
    draw_text(sx + (card_w / 2), pw_cy + 22, power_names_short[k]);
    draw_set_halign(fa_left);

    // Cooldown Progress Shutter Overlay
    if (!is_ready) {
        var cd_rem = cd_obj.remaining;
        var cd_prog = cd_obj.progress(); // 0 (just used) to 1 (ready)
        var shutter_h = card_h * (1 - cd_prog);

        // Dark wipe down
        draw_set_color(c_black);
        draw_set_alpha(0.65);
        draw_rectangle(sx, pw_cy + (card_h - shutter_h), sx + card_w, pw_cy + card_h, false);

        // Numeric countdown
        draw_set_color(c_gold_bright);
        draw_set_alpha(1.0);
        draw_set_halign(fa_center);
        draw_text(sx + (card_w / 2), pw_cy + 36, string_format(cd_rem, 1, 1) + "s");
        draw_set_halign(fa_left);
    } else if (!has_nrg) {
        // Insufficient Energy Warning Tag
        draw_set_halign(fa_center);
        draw_set_color(c_crimson_burn);
        draw_text(sx + (card_w / 2), pw_cy + 36, "NO NRG");
        draw_set_halign(fa_left);
    }
}

// Powers Command Sub-label
draw_set_color(c_steel_muted);
draw_set_halign(fa_center);
draw_text(pw_cx, pw_cy + card_h + 6, "[F] CAST ACTIVE POWER  |  [3-5] SELECT POWER");
draw_set_halign(fa_left);

// =====================================================================
// 5. TOP-CENTER: HARDWARE PROFILE NOTIFICATION BANNER
// =====================================================================
if (quality_notify_timer > 0) {
    var notif_a = clamp(quality_notify_timer / 0.5, 0, 1);
    var notif_cx = 640;
    var notif_cy = 28;
    var notif_w = 340;
    var notif_h = 26;

    draw_set_color(c_dark_obsidian);
    draw_set_alpha(notif_a * 0.90);
    draw_rectangle(notif_cx - (notif_w / 2), notif_cy, notif_cx + (notif_w / 2), notif_cy + notif_h, false);

    draw_set_color(c_cyan_neon);
    draw_set_alpha(notif_a);
    draw_rectangle(notif_cx - (notif_w / 2), notif_cy, notif_cx + (notif_w / 2), notif_cy + notif_h, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(notif_cx, notif_cy + (notif_h / 2), "// " + quality_notify_text + " //");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1.0);
}

// =====================================================================
// 5B. TOP-CENTER: ENCOUNTER DIRECTOR HUD & SCORE TRACKER
// =====================================================================
if (variable_global_exists("director")) {
    var d = global.director;
    var cur_enc_idx = d.current_encounter_idx;
    var total_enc_num = array_length(d.encounters);
    var enc_data = d.encounters[cur_enc_idx];

    // --- A. TOP TACTICAL COMBAT BAR ---
    if (d.state == ENCOUNTER_STATE.COMBAT || d.state == ENCOUNTER_STATE.SPAWNING) {
        var top_bx = 400;
        var top_by = 18;
        var top_bw = 480;
        var top_bh = 30;

        draw_set_color(c_dark_obsidian);
        draw_set_alpha(0.88);
        draw_rectangle(top_bx, top_by, top_bx + top_bw, top_by + top_bh, false);
        draw_set_color(c_panel_border);
        draw_set_alpha(1.0);
        draw_rectangle(top_bx, top_by, top_bx + top_bw, top_by + top_bh, true);

        // Encounter tag
        draw_set_color(c_cyan_neon);
        draw_text(top_bx + 10, top_by + 7, "ENC " + string(cur_enc_idx + 1) + "/" + string(total_enc_num) + " W" + string(d.current_wave_idx + 1));

        // Active foes count
        var c_foe = (d.active_enemies > 0) ? c_crimson_burn : c_emerald_tech;
        draw_set_color(c_foe);
        draw_set_halign(fa_center);
        draw_text(top_bx + (top_bw / 2), top_by + 7, string(d.active_enemies) + " HOSTILES");
        draw_set_halign(fa_left);

        // Total score
        draw_set_halign(fa_right);
        draw_set_color(c_gold_bright);
        draw_text(top_bx + top_bw - 10, top_by + 7, "SCORE " + string(d.total_score));
        draw_set_halign(fa_left);
    }
    // --- B. INTRO BANNER ---
    else if (d.state == ENCOUNTER_STATE.INTRO) {
        var intro_w = 540;
        var intro_h = 60;
        var intro_x = 640 - (intro_w / 2);
        var intro_y = 120;

        draw_set_color(c_dark_obsidian);
        draw_set_alpha(0.92);
        draw_rectangle(intro_x, intro_y, intro_x + intro_w, intro_y + intro_h, false);
        draw_set_color(c_cyan_neon);
        draw_set_alpha(1.0);
        draw_rectangle(intro_x, intro_y, intro_x + intro_w, intro_y + intro_h, true);

        draw_set_halign(fa_center);
        draw_set_color(c_gold_bright);
        draw_text(640, intro_y + 10, ">> ENCOUNTER 0" + string(cur_enc_idx + 1) + " // SECTOR ACTIVE <<");
        draw_set_color(c_white);
        draw_text(640, intro_y + 32, enc_data.name);
        draw_set_halign(fa_left);
    }
    // --- C. WAVE / ENCOUNTER CLEAR BANNER ---
    else if (d.state == ENCOUNTER_STATE.CLEAR) {
        var clr_w = 480;
        var clr_h = 56;
        var clr_x = 640 - (clr_w / 2);
        var clr_y = 130;

        draw_set_color(c_dark_obsidian);
        draw_set_alpha(0.92);
        draw_rectangle(clr_x, clr_y, clr_x + clr_w, clr_y + clr_h, false);
        draw_set_color(c_emerald_tech);
        draw_set_alpha(1.0);
        draw_rectangle(clr_x, clr_y, clr_x + clr_w, clr_y + clr_h, true);

        draw_set_halign(fa_center);
        draw_set_color(c_emerald_tech);
        draw_text(640, clr_y + 8, "// SECTOR SECURED // ENCOUNTER CLEARED //");
        draw_set_color(c_white);
        draw_text(640, clr_y + 30, "TIME: " + string_format(d.encounter_time, 1, 1) + "s  |  PTS: +" + string(d.encounter_score));
        draw_set_halign(fa_left);
    }
}

// =====================================================================
// 5C. TACTICAL COMBAT TUTORIAL CARD (Active on Boot)
// =====================================================================
if (tutorial_banner_timer > 0) {
    var tut_alpha = clamp(tutorial_banner_timer / 1.0, 0, 1);
    var tc_w = 680;
    var tc_h = 76;
    var tc_x = 640 - (tc_w / 2);
    var tc_y = 190;

    draw_set_color(c_dark_obsidian);
    draw_set_alpha(tut_alpha * 0.92);
    draw_rectangle(tc_x, tc_y, tc_x + tc_w, tc_y + tc_h, false);
    draw_set_color(c_gold_bright);
    draw_set_alpha(tut_alpha);
    draw_rectangle(tc_x, tc_y, tc_x + tc_w, tc_y + tc_h, true);

    draw_set_halign(fa_center);
    draw_set_color(c_gold_bright);
    draw_text(640, tc_y + 8, "// PROTOCOL COMBAT OPERATIONAL CONTROLS //");
    draw_set_color(c_white);
    draw_text(640, tc_y + 28, "[1] SWORD  |  [2] SHOTGUN  |  [Q] SWAP WEAPON  |  [R] ACTIVE RELOAD");
    draw_set_color(c_cyan_neon);
    draw_text(640, tc_y + 48, "[L-CLICK] ATTACK  |  [R-CLICK] PARRY  |  [E] GRAPPLE  |  [SPACE] JUMP/DBL  |  [SHIFT] DASH");
    draw_set_halign(fa_left);
    draw_set_alpha(1.0);
}

// =====================================================================
// 6. BOTTOM-RIGHT: MINIMALIST TACTICAL CONTROLS LEGEND
// =====================================================================
var leg_rx = 1256;
var leg_ry = 696;
draw_set_halign(fa_right);
draw_set_color(make_color_rgb(105, 120, 135));
draw_text(leg_rx, leg_ry, "[A/D] MOVE  [SPACE] JUMP/DBL  [SHIFT] DASH  [L-CLICK] ATK  [R-CLICK] PARRY  [1] SWORD  [2] SHOTGUN  [Q] SWAP  [R] RELOAD  [E] HOOK  [F] POWER");
draw_set_halign(fa_left);

// =====================================================================
// 7. CONTEXTUAL OVERLAY: CRITICAL SYSTEM FAILURE / DEATH PROTOCOL
// =====================================================================
if (is_player_dead || p.hp <= 0) {
    // Cinematic Translucent Darkness
    draw_set_color(c_black);
    draw_set_alpha(0.75);
    draw_rectangle(0, 0, 1280, 720, false);

    // Hazard Red Scanband
    draw_set_color(c_crimson_burn);
    draw_set_alpha(0.12);
    draw_rectangle(0, 270, 1280, 450, false);

    // Tactical Alert Box
    var fail_cx = 640;
    var fail_cy = 360;
    var fail_w  = 540;
    var fail_h  = 160;
    var f_x1    = fail_cx - (fail_w / 2);
    var f_y1    = fail_cy - (fail_h / 2);
    var f_x2    = fail_cx + (fail_w / 2);
    var f_y2    = fail_cy + (fail_h / 2);

    draw_set_color(c_dark_obsidian);
    draw_set_alpha(0.95);
    draw_rectangle(f_x1, f_y1, f_x2, f_y2, false);

    // Double Border
    draw_set_color(c_crimson_burn);
    draw_set_alpha(1.0);
    draw_rectangle(f_x1, f_y1, f_x2, f_y2, true);
    draw_set_color(c_panel_border);
    draw_rectangle(f_x1 + 4, f_y1 + 4, f_x2 - 4, f_y2 - 4, true);

    // Text Contents
    draw_set_halign(fa_center);

    // Title
    draw_set_color(c_crimson_burn);
    draw_text_transformed(fail_cx, f_y1 + 24, "[ CRITICAL SYSTEM FAILURE ]", 1.4, 1.4, 0);

    // Subtitle
    draw_set_color(c_steel_muted);
    draw_text(fail_cx, f_y1 + 64, "CHASSIS INTEGRITY COMPROMISED // VITALS EXTINGUISHED");

    // Pulsing Reboot Prompt
    var reboot_pulse = 0.7 + (sin(current_time * 0.012) * 0.3);
    draw_set_color(c_gold_bright);
    draw_set_alpha(reboot_pulse);
    draw_text(fail_cx, f_y1 + 106, "PRESS [SPACE] OR [R] TO REBOOT PROTOCOL");

    draw_set_halign(fa_left);
    draw_set_alpha(1.0);
}

// =====================================================================
// 8. CONTEXTUAL OVERLAY: VICTORY PROTOCOL / CAMPAIGN CONQUERED
// =====================================================================
if (variable_global_exists("director") && global.director.state == ENCOUNTER_STATE.VICTORY) {
    var d = global.director;

    // Dark screen fade
    draw_set_color(c_black);
    draw_set_alpha(0.82);
    draw_rectangle(0, 0, 1280, 720, false);

    // Victory Card
    var vic_cx = 640;
    var vic_cy = 360;
    var vic_w  = 620;
    var vic_h  = 340;
    var v_x1   = vic_cx - (vic_w / 2);
    var v_y1   = vic_cy - (vic_h / 2);
    var v_x2   = vic_cx + (vic_w / 2);
    var v_y2   = vic_cy + (vic_h / 2);

    draw_set_color(c_dark_obsidian);
    draw_set_alpha(0.96);
    draw_rectangle(v_x1, v_y1, v_x2, v_y2, false);
    draw_set_color(c_gold_bright);
    draw_set_alpha(1.0);
    draw_rectangle(v_x1, v_y1, v_x2, v_y2, true);
    draw_set_color(c_panel_border);
    draw_rectangle(v_x1 + 4, v_y1 + 4, v_x2 - 4, v_y2 - 4, true);

    // Header Title
    draw_set_halign(fa_center);
    draw_set_color(c_gold_bright);
    draw_text_transformed(vic_cx, v_y1 + 22, "// ARENA TRIAL CONQUERED //", 1.3, 1.3, 0);

    draw_set_color(c_cyan_neon);
    draw_text(vic_cx, v_y1 + 54, "ALL 5 SECTORS PURIFIED // APEX PROTOCOL FULFILLED");

    // Divider Line
    draw_set_color(c_panel_border);
    draw_line(v_x1 + 30, v_y1 + 78, v_x2 - 30, v_y1 + 78);

    // Rating Badge
    var rank_str = "S";
    var c_badge = c_gold_bright;
    var s_thresh = (variable_struct_exists(global, "cfg") && variable_struct_exists(global.cfg, "director")) ? global.cfg.director.rank_s : 10500;
    var a_thresh = (variable_struct_exists(global, "cfg") && variable_struct_exists(global.cfg, "director")) ? global.cfg.director.rank_a : 7500;
    var b_thresh = (variable_struct_exists(global, "cfg") && variable_struct_exists(global.cfg, "director")) ? global.cfg.director.rank_b : 5000;
    if (d.total_score >= s_thresh) { rank_str = "S"; c_badge = c_gold_bright; }
    else if (d.total_score >= a_thresh) { rank_str = "A"; c_badge = c_crimson_burn; }
    else if (d.total_score >= b_thresh) { rank_str = "B"; c_badge = c_cyan_neon; }
    else { rank_str = "C"; c_badge = c_emerald_tech; }

    draw_set_color(c_badge);
    draw_text_transformed(vic_cx - 180, v_y1 + 130, rank_str, 3.5, 3.5, 0);
    draw_set_color(c_steel_muted);
    draw_text(vic_cx - 180, v_y1 + 200, "FINAL RANK");

    // Statistics Grid
    draw_set_halign(fa_left);
    var stat_x = vic_cx - 60;
    var stat_y = v_y1 + 104;
    var line_gap = 26;

    draw_set_color(c_steel_muted); draw_text(stat_x, stat_y, "FINAL SCORE:");
    draw_set_color(c_gold_bright); draw_text(stat_x + 160, stat_y, string(d.total_score));

    draw_set_color(c_steel_muted); draw_text(stat_x, stat_y + line_gap, "TOTAL TIME:");
    draw_set_color(c_white); draw_text(stat_x + 160, stat_y + line_gap, string_format(d.total_time, 1, 1) + "s");

    draw_set_color(c_steel_muted); draw_text(stat_x, stat_y + (line_gap * 2), "HOSTILES PURGED:");
    draw_set_color(c_white); draw_text(stat_x + 160, stat_y + (line_gap * 2), string(d.total_kills));

    draw_set_color(c_steel_muted); draw_text(stat_x, stat_y + (line_gap * 3), "PARRIES DEFLECTED:");
    draw_set_color(c_white); draw_text(stat_x + 160, stat_y + (line_gap * 3), string(d.total_parries));

    draw_set_color(c_steel_muted); draw_text(stat_x, stat_y + (line_gap * 4), "MAX COMBO CHAIN:");
    draw_set_color(c_white); draw_text(stat_x + 160, stat_y + (line_gap * 4), string(d.max_combo) + " HITS");

    // Reboot prompt
    draw_set_halign(fa_center);
    var replay_pulse = 0.7 + (sin(current_time * 0.015) * 0.3);
    draw_set_color(c_gold_bright);
    draw_set_alpha(replay_pulse);
    draw_text(vic_cx, v_y2 - 38, "PRESS [R] OR [SPACE] TO REPLAY TRIAL");
    draw_set_alpha(1.0);
    draw_set_halign(fa_left);
}

// ---------------------------------------------------------------------
// CLEANUP DRAW STATE
// ---------------------------------------------------------------------
draw_set_alpha(1.0);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

