// =====================================================================
// QUAZERIUM — OBJ_ENERGY_CANISTER: Step Event
// Trigger check on player attack hitbox contact.
// =====================================================================

var dt = qz_dt();
if (dt <= 0) exit;

if (detonated) {
    instance_destroy();
    exit;
}

// Check player attacks
var cx = x;
var cy = y;
var hw = bbox_hw;
var hh = bbox_hh;

with (obj_hitbox) {
    if (team == TEAM.PLAYER) {
        if (qz_aabb_overlap(x, y, x + bbox_w, y + bbox_h, cx - hw, cy - hh, cx + hw, cy + hh)) {
            other.detonated = true;
            break;
        }
    }
}

if (detonated) {
    // Blast enemies in radius
    var blast_radius = 110;
    var blast_damage = 45;

    with (obj_enemy_base) {
        if (point_distance(x, y, cx, cy) <= blast_radius) {
            hp -= blast_damage;
            hit_flash = 0.25;
            stun_timer = 0.6;
            var dir = point_direction(cx, cy, x, y);
            vx = lengthdir_x(450, dir);
            vy = -280;
        }
    }

    // Award player energy
    with (obj_player) {
        energy = min(energy + 25, global.cfg.energy.max);
    }

    // Emit event feedback
    events_emit(EVT.ELEMENT_REACTION, { x: cx, y: cy, reaction_name: "Overload", mult: 2.0 });
    time_hitstop(0.08);
    instance_destroy();
}
