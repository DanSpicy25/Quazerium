// =====================================================================
// QUAZERIUM — OBJ_DEBUG: In-world physics & hurtbox bounds visualization
// =====================================================================

if (!visible) exit;

// Draw Player Hurtbox
if (instance_exists(obj_player)) {
    var p = obj_player;
    draw_set_color(c_lime);
    draw_rectangle(p.x - p.bbox_hw, p.y - p.bbox_hh, p.x + p.bbox_hw, p.y + p.bbox_hh, true);
}

// Draw Enemies Hurtboxes & Aggro radii
with (obj_enemy_base) {
    draw_set_color(c_red);
    draw_rectangle(x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh, true);
    draw_set_alpha(0.1);
    draw_circle(x, y, aggro_range, true);
    draw_set_alpha(1.0);
}

// Draw Grapple Range around Player
if (instance_exists(obj_player)) {
    draw_set_color(c_aqua);
    draw_set_alpha(0.15);
    draw_circle(obj_player.x, obj_player.y, global.cfg.grapple.range, true);
    draw_set_alpha(1.0);
}

