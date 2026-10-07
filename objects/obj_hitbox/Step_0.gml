// =====================================================================
// QUAZERIUM — OBJ_HITBOX: Collision sweep & lifetime
// =====================================================================

var dt = qz_dt();
if (dt <= 0) exit;

if (variable_instance_exists(id, "startup") && startup > 0) {
    startup -= dt;
    exit;
}

timer -= dt;
if (timer <= 0) {
    instance_destroy();
    exit;
}

var hx1 = x;
var hy1 = y;
var hx2 = x + bbox_w;
var hy2 = y + bbox_h;

if (team == TEAM.PLAYER) {
    // Check collision against all active enemies
    with (obj_enemy_base) {
        if (qz_aabb_overlap(hx1, hy1, hx2, hy2, x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh)) {
            combat_resolve_hit(other.id, id);
        }
    }
} else if (team == TEAM.ENEMY) {
    // Check collision against player
    with (obj_player) {
        if (qz_aabb_overlap(hx1, hy1, hx2, hy2, x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh)) {
            combat_resolve_hit(other.id, id);
        }
    }
}

