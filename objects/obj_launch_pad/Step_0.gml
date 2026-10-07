// =====================================================================
// QUAZERIUM — OBJ_LAUNCH_PAD: Step Event
// Trigger check on player or enemy contact.
// =====================================================================

var dt = qz_dt();
if (dt <= 0) exit;

if (cooldown > 0) cooldown -= dt;
if (spring_compress > 0) spring_compress = max(0, spring_compress - 5 * dt);

if (cooldown <= 0) {
    var x1 = x;
    var y1 = y - 4;
    var x2 = x + pad_w;
    var y2 = y + pad_h;

    // Check player contact
    with (obj_player) {
        if (qz_aabb_overlap(x1, y1, x2, y2, x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh)) {
            if (vy >= -100) {
                vy = other.launch_speed;
                state = PSTATE.JUMP;
                on_ground = false;
                other.spring_compress = 1.0;
                other.cooldown = 0.25;
                events_emit(EVT.JUMP, { x: other.x + (other.pad_w / 2), y: other.y });
            }
        }
    }

    // Check enemies
    with (obj_enemy_base) {
        if (qz_aabb_overlap(x1, y1, x2, y2, x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh)) {
            if (vy >= -100) {
                vy = other.launch_speed * 0.85;
                on_ground = false;
                other.spring_compress = 1.0;
                other.cooldown = 0.25;
            }
        }
    }
}
