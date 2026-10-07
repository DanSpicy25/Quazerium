// =====================================================================
// QUAZERIUM — OBJ_HUD: Step event
// Smoothly interpolates damage lag bar and combo scale animation.
// =====================================================================

var dt = qz_raw_dt();

if (instance_exists(obj_player)) {
    var p = obj_player;
    if (hp_lag > p.hp) {
        hp_lag = qz_approach(hp_lag, p.hp, 40 * dt);
    } else {
        hp_lag = p.hp;
    }
}

if (combo_scale > 1.0) {
    combo_scale = qz_approach(combo_scale, 1.0, 3.0 * dt);
}
