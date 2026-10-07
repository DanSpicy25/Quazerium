// =====================================================================
// QUAZERIUM — PHYSICS: Kinematic vector physics & continuous AABB collision.
// Solves tunneling without heavy physics engine overhead.
// =====================================================================

function physics_move_and_collide(inst, dt) {
    if (dt <= 0) return;

    var hw = inst.bbox_hw;
    var hh = inst.bbox_hh;

    // 1. Horizontal movement
    var move_x = inst.vx * dt;
    var sign_x = sign(move_x);
    var remaining_x = abs(move_x);
    var step_limit = global.cfg.physics.max_step;

    inst.on_wall_left = false;
    inst.on_wall_right = false;

    while (remaining_x > 0) {
        var step_x = min(remaining_x, step_limit) * sign_x;
        var next_x = inst.x + step_x;

        // AABB check against obj_solid
        if (physics_check_solid(next_x - hw, inst.y - hh, next_x + hw, inst.y + hh)) {
            // Step pixel-by-pixel to touch solid
            while (!physics_check_solid(inst.x + sign_x - hw, inst.y - hh, inst.x + sign_x + hw, inst.y + hh)) {
                inst.x += sign_x;
            }
            if (sign_x < 0) inst.on_wall_left = true;
            if (sign_x > 0) inst.on_wall_right = true;
            inst.vx = 0;
            break;
        } else {
            inst.x = next_x;
            remaining_x -= abs(step_x);
        }
    }

    // 2. Vertical movement
    var move_y = inst.vy * dt;
    var sign_y = sign(move_y);
    var remaining_y = abs(move_y);

    inst.on_ground = false;
    inst.on_ceiling = false;

    while (remaining_y > 0) {
        var step_y = min(remaining_y, step_limit) * sign_y;
        var next_y = inst.y + step_y;

        if (physics_check_solid(inst.x - hw, next_y - hh, inst.x + hw, next_y + hh)) {
            while (!physics_check_solid(inst.x - hw, inst.y + sign_y - hh, inst.x + hw, inst.y + sign_y + hh)) {
                inst.y += sign_y;
            }
            if (sign_y > 0) inst.on_ground = true;
            if (sign_y < 0) inst.on_ceiling = true;
            inst.vy = 0;
            break;
        } else {
            inst.y = next_y;
            remaining_y -= abs(step_y);
        }
    }

    // Ground check confirmation (even when standing still)
    if (!inst.on_ground) {
        if (physics_check_solid(inst.x - hw, inst.y + 1 - hh, inst.x + hw, inst.y + 1 + hh)) {
            inst.on_ground = true;
        }
    }
}

function physics_check_solid(x1, y1, x2, y2) {
    with (obj_solid) {
        if (qz_aabb_overlap(x1, y1, x2, y2, bbox_left, bbox_top, bbox_right, bbox_bottom)) {
            return true;
        }
    }
    return false;
}

