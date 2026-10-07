// =====================================================================
// QUAZERIUM — OBJ_HITBOX: Debug visualization
// =====================================================================

if (instance_exists(obj_debug) && obj_debug.visible) {
    draw_set_color(c_red);
    draw_rectangle(x, y, x + bbox_w, y + bbox_h, true);
    draw_set_alpha(0.2);
    draw_rectangle(x, y, x + bbox_w, y + bbox_h, false);
    draw_set_alpha(1.0);
}

