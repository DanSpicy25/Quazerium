// =====================================================================
// QUAZERIUM — OBJ_HUD: Step event
// Smoothly interpolates damage lag bar, combo scale animation & notification timers.
// =====================================================================

var dt = qz_raw_dt();

if (instance_exists(obj_player)) {
    var p = obj_player;
    if (hp_lag > p.hp) {
        hp_lag = qz_approach(hp_lag, p.hp, 45 * dt);
    } else {
        hp_lag = p.hp;
    }
    if (p.hp <= 0) is_player_dead = true;
}

if (combo_scale > 1.0) {
    combo_scale = qz_approach(combo_scale, 1.0, 3.5 * dt);
}

if (quality_notify_timer > 0) {
    quality_notify_timer = max(0, quality_notify_timer - dt);
}

if (tutorial_banner_timer > 0) {
    tutorial_banner_timer = max(0, tutorial_banner_timer - dt);
}

if (is_player_dead) {
    if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("R"))) {
        room_restart();
    }
}
