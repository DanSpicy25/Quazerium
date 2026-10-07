// =====================================================================
// QUAZERIUM — OBJ_ENEMY_SPAWNER: Step Event
// Countdown to entity materialization.
// =====================================================================

var dt = qz_dt();
if (dt <= 0) exit;

timer -= dt;
if (timer <= 0) {
    if (object_exists(enemy_obj)) {
        instance_create_layer(x, y, "Instances", enemy_obj);
    }
    instance_destroy();
}
