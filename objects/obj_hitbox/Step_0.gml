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

// Pellet movement & solid collision
if (is_pellet && (vx != 0 || vy != 0)) {
    var next_x = x + (vx * dt);
    var next_y = y + (vy * dt);
    if (collision_line(x, y, next_x, next_y, obj_solid, true, true) != noone) {
        instance_destroy();
        exit;
    }
    x = next_x;
    y = next_y;
}

var hx1 = x;
var hy1 = y;
var hx2 = x + bbox_w;
var hy2 = y + bbox_h;

if (team == TEAM.PLAYER) {
    // Check collision against all active enemies via decoupled hurtbox
    with (obj_enemy_base) {
        var hurtbox = entity_get_hurtbox(id);
        if (qz_aabb_overlap(hx1, hy1, hx2, hy2, hurtbox.x1, hurtbox.y1, hurtbox.x2, hurtbox.y2)) {
            combat_resolve_hit(other.id, id);
        }
    }
} else if (team == TEAM.ENEMY) {
    // Check collision against player via decoupled hurtbox
    with (obj_player) {
        var hurtbox = entity_get_hurtbox(id);
        if (qz_aabb_overlap(hx1, hy1, hx2, hy2, hurtbox.x1, hurtbox.y1, hurtbox.x2, hurtbox.y2)) {
            combat_resolve_hit(other.id, id);
        }
    }
}

