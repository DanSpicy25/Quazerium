// =====================================================================
// QUAZERIUM — OBJ_ENEMY_DUMMY: Periodic attack practice loop
// =====================================================================

var dt = qz_dt();
if (dt <= 0) exit;

// Cycle attack to allow player parry practice
if (state == ESTATE.IDLE) {
    dummy_cycle_timer -= dt;
    if (dummy_cycle_timer <= 0) {
        dummy_cycle_timer = global.cfg.enemy.dummy.attack_interval;
        state = ESTATE.WINDUP;
        windup_timer = global.cfg.enemy.dummy.windup;
        events_emit(EVT.ENEMY_ATTACK_WINDUP, id);
    }
}

event_inherited();

