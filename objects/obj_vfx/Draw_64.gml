// =====================================================================
// QUAZERIUM — OBJ_VFX: GUI Screen Overlay (Flashes, Vignettes)
// =====================================================================

var gw = display_get_gui_width();
var gh = display_get_gui_height();

// 1. Impact / Reaction screen flash
if (flash_alpha > 0) {
    draw_set_color(flash_color);
    draw_set_alpha(flash_alpha);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1.0);
}

// 2. Overdrive Edge Vignette
if (instance_exists(obj_player) && obj_player.overdrive_active) {
    var v_alpha = 0.15 + (sin(current_time * 0.008) * 0.08);
    draw_set_color(c_yellow);
    draw_set_alpha(v_alpha);
    // Draw 4-side border glow
    var b_thick = 16;
    draw_rectangle(0, 0, gw, b_thick, false);
    draw_rectangle(0, gh - b_thick, gw, gh, false);
    draw_rectangle(0, 0, b_thick, gh, false);
    draw_rectangle(gw - b_thick, 0, gw, gh, false);
    draw_set_alpha(1.0);
}

