// =====================================================================
// QUAZERIUM — INTERACTION ENGINE: Environmental interactions, Wall-Tech, hazards.
// Decoupled from Player internals to allow new objects without rewriting.
// =====================================================================

function interaction_check_wall(inst) {
    if (!global.cfg.walltech.enabled) return 0;
    var hw = inst.bbox_hw;
    var hh = inst.bbox_hh;

    // Check 2 pixels to the left and right
    if (physics_check_solid(inst.x - hw - 2, inst.y - hh + 4, inst.x - hw, inst.y + hh - 4)) {
        return -1; // wall on left
    }
    if (physics_check_solid(inst.x + hw, inst.y - hh + 4, inst.x + hw + 2, inst.y + hh - 4)) {
        return 1; // wall on right
    }
    return 0;
}

function interaction_apply_wall_slide(inst, dt) {
    var wall_dir = interaction_check_wall(inst);
    if (wall_dir != 0 && !inst.on_ground && inst.vy > 0) {
        var slide_max = global.cfg.player.wall_slide_speed;
        if (inst.vy > slide_max) {
            inst.vy = qz_approach(inst.vy, slide_max, 2000 * dt);
        }
        return wall_dir;
    }
    return 0;
}

function interaction_wall_jump(inst, wall_dir) {
    var cfg = global.cfg.player;
    inst.vx = -wall_dir * cfg.wall_jump_vx;
    inst.vy = -cfg.wall_jump_vy;
    inst.facing = -wall_dir;
    inst.wall_jump_lock_timer = cfg.wall_jump_lock;
    events_emit(EVT.WALL_JUMP, { player: inst, wall_dir: wall_dir });
}

