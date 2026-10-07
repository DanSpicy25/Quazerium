// =====================================================================
// QUAZERIUM — OBJ_PROJECTILE_ENEMY: Step event
// Motion, boundary checks, player collision and parry reflection.
// =====================================================================

var dt = qz_dt();
if (dt <= 0) exit;

timer -= dt;
if (timer <= 0) {
    instance_destroy();
    exit;
}

// Kinetic update
x += vx * dt;
y += vy * dt;

// Wall collision
var half_r = bbox_r;
if (physics_place_meeting(x, y, obj_solid)) {
    events_emit(EVT.HIT_CONFIRMED, { x: x, y: y, element: element, heavy: false });
    instance_destroy();
    exit;
}

// Combat collision
if (team == TEAM.ENEMY) {
    with (obj_player) {
        if (qz_aabb_overlap(other.x - half_r, other.y - half_r, other.x + half_r, other.y + half_r,
                            x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh)) {
            // Check parry posture
            if (is_parrying) {
                var parry_t = parry_timer;
                if (parry_t <= global.cfg.parry.perfect_window) {
                    // PERFECT PARRY: REFLECT PROJECTILE!
                    time_hitstop(global.cfg.parry.hitstop_perfect);
                    energy = min(energy + global.cfg.parry.energy_perfect, global.cfg.energy.max);
                    events_emit(EVT.PERFECT_PARRY, { defender: id, attacker: other.owner, hitbox: other.id });

                    other.team = TEAM.PLAYER;
                    other.owner = id;
                    other.damage = round(other.damage * 2.5);
                    other.vx = -other.vx * 1.6;
                    other.vy = -other.vy * 1.6;
                    other.reflected = true;
                    other.can_be_parried = false;
                    other.timer = 3.0;
                    other.hit_targets = [];
                    return;
                } else if (parry_t <= global.cfg.parry.window) {
                    // NORMAL PARRY: DEFLECT AND DISSOLVE
                    time_hitstop(global.cfg.parry.hitstop_normal);
                    energy = min(energy + global.cfg.parry.energy_normal, global.cfg.energy.max);
                    events_emit(EVT.PARRY, { defender: id, attacker: other.owner, hitbox: other.id });
                    instance_destroy(other);
                    return;
                }
            }

            // Unblocked impact
            combat_resolve_hit(other.id, id);
            instance_destroy(other);
            break;
        }
    }
} else if (team == TEAM.PLAYER) {
    // Reflected projectile seeking enemies
    with (obj_enemy_base) {
        if (qz_aabb_overlap(other.x - half_r, other.y - half_r, other.x + half_r, other.y + half_r,
                            x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh)) {
            combat_resolve_hit(other.id, id);
            instance_destroy(other);
            break;
        }
    }
}
