// =====================================================================
// QUAZERIUM — OBJ_HAZARD_ELECTRIC: Step Event
// State cycle logic and entity collision detection.
// =====================================================================

var dt = qz_dt();
if (dt <= 0) exit;

timer -= dt;
if (tick_cd > 0) tick_cd -= dt;

if (timer <= 0) {
    if (cycle_state == 0) {
        cycle_state = 1; // Enter warning
        timer = 0.8;
    } else if (cycle_state == 1) {
        cycle_state = 2; // Enter active surge
        timer = 1.8;
    } else {
        cycle_state = 0; // Return to dormant
        timer = 2.5;
    }
}

// Active hazard damage sweep
if (cycle_state == 2 && tick_cd <= 0) {
    var x1 = x;
    var y1 = y;
    var x2 = x + hazard_w;
    var y2 = y + hazard_h;

    // Check player
    with (obj_player) {
        if (qz_aabb_overlap(x1, y1, x2, y2, x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh)) {
            if (iframes <= 0) {
                hp = max(0, hp - other.damage);
                vy = -420;
                iframes = 0.6;
                time_hitstop(0.08);
                events_emit(EVT.HAZARD_TRIGGERED, { x: x, y: y, type: "ELECTRIC" });
                other.tick_cd = 0.4;
            }
        }
    }

    // Check enemies (player can knock enemies into hazard!)
    with (obj_enemy_base) {
        if (qz_aabb_overlap(x1, y1, x2, y2, x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh)) {
            hp -= 18;
            vy = -340;
            stun_timer = 0.9;
            hit_flash = 0.2;
            events_emit(EVT.HAZARD_TRIGGERED, { x: x, y: y, type: "ELECTRIC" });
            other.tick_cd = 0.4;
        }
    }
}
