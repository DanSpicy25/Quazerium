// =====================================================================
// QUAZERIUM — OBJ_DEBUG: GUI diagnostic telemetry HUD (F1)
// =====================================================================

if (!visible) exit;

var pad_x = 16;
var pad_y = 16;
var line_h = 18;
var cur_y = pad_y;

// Background panel
draw_set_color(c_black);
draw_set_alpha(0.85);
draw_rectangle(8, 8, 410, 580, false);
draw_set_color(c_dkgray);
draw_rectangle(8, 8, 410, 580, true);
draw_set_alpha(1.0);

// Header
draw_set_color(c_yellow);
draw_text(pad_x, cur_y, "QUAZERIUM SKELETON [DEBUG - F1]");
cur_y += line_h * 1.5;

// Performance metrics
draw_set_color(c_white);
draw_text(pad_x, cur_y, "FPS: " + string(fps) + " / " + string(fps_real)); cur_y += line_h;
draw_text(pad_x, cur_y, "Frame Time: " + string_format(qz_raw_dt() * 1000, 1, 2) + " ms"); cur_y += line_h;
draw_text(pad_x, cur_y, "Quality Profile: " + global.quality_names[global.quality_level] + " (F2 to cycle)"); cur_y += line_h;
draw_text(pad_x, cur_y, "Time Scale: " + string_format(global.time.scale, 1, 2) + " | Hitstop: " + string_format(global.time.hitstop, 1, 3)); cur_y += line_h * 1.3;

// Hardware & VFX Budgets
if (instance_exists(obj_vfx)) {
    var vfx = obj_vfx;
    var n_pt = vfx.particle_pool.get_active_count();
    var n_dec = vfx.decal_pool.get_active_count();
    var n_txt = vfx.text_pool.get_active_count();
    var q = quality_get();
    draw_set_color(c_fuchsia);
    draw_text(pad_x, cur_y, "--- HARDWARE & VFX BUDGETS ---"); cur_y += line_h;
    draw_set_color(c_white);
    draw_text(pad_x, cur_y, "Instances: " + string(instance_count) + " | Entities: " + string(instance_number(obj_enemy_base) + 1)); cur_y += line_h;
    draw_text(pad_x, cur_y, "Particles: " + string(n_pt) + " / " + string(q.max_particles) + " (Budget: " + string_format(q.power_vfx_budget, 1, 1) + "x)"); cur_y += line_h;
    draw_text(pad_x, cur_y, "Decals: " + string(n_dec) + " / " + string(q.max_decals) + " | Combat Text: " + string(n_txt) + " / 32"); cur_y += line_h;
    draw_text(pad_x, cur_y, "2D Lighting: " + (q.enable_lighting ? "ON" : "OFF") + " | Shaders: " + (q.enable_shaders ? "ON" : "OFF")); cur_y += line_h * 1.3;
}

// Player metrics
if (instance_exists(obj_player)) {
    var p = obj_player;
    draw_set_color(c_lime);
    draw_text(pad_x, cur_y, "--- PLAYER STATE ---"); cur_y += line_h;
    draw_set_color(c_white);
    draw_text(pad_x, cur_y, "State: " + global.pstate_names[p.state]); cur_y += line_h;
    draw_text(pad_x, cur_y, "Velocity: vx=" + string_format(p.vx, 1, 1) + " vy=" + string_format(p.vy, 1, 1)); cur_y += line_h;
    draw_text(pad_x, cur_y, "Grounded: " + (p.on_ground ? "YES" : "NO") + " | Facing: " + string(p.facing)); cur_y += line_h;
    draw_text(pad_x, cur_y, "Dash CD: " + string_format(p.dash_cd.remaining, 1, 2) + "s | Air Dashes: " + string(p.air_dashes_left)); cur_y += line_h;
    draw_text(pad_x, cur_y, "Energy: " + string(p.energy) + "/100 | Overdrive: " + (p.overdrive_active ? "ACTIVE (" + string_format(p.overdrive_timer, 1, 1) + "s)" : "READY: " + string(p.energy >= 100))); cur_y += line_h;
    draw_text(pad_x, cur_y, "Combo: x" + string(p.combo_count) + " (" + string_format(p.combo_timer, 1, 2) + "s)"); cur_y += line_h;
    draw_text(pad_x, cur_y, "Element (Tab): " + global.element_names[p.active_element]); cur_y += line_h;
    draw_text(pad_x, cur_y, "Power (1/2/3/Q): " + global.power_names[p.selected_power_id]); cur_y += line_h;
    draw_text(pad_x, cur_y, "Grapple: " + global.grapple_names[p.grapple.state]); cur_y += line_h * 1.3;
}

// Recent events log
draw_set_color(c_aqua);
draw_text(pad_x, cur_y, "--- RECENT EVENTS ---"); cur_y += line_h;
draw_set_color(c_ltgray);
var n_logs = array_length(global.events.log);
for (var i = 0; i < min(5, n_logs); i++) {
    var idx = (global.events.log_head - 1 - i + n_logs) mod n_logs;
    var msg = global.events.log[idx];
    if (msg != "") {
        draw_text(pad_x, cur_y, "- " + msg);
        cur_y += line_h;
    }
}

