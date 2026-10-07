// =====================================================================
// QUAZERIUM — OBJ_ENEMY_DUMMY: Training dummy with parry training loop.
// =====================================================================

event_inherited();

name = "Training Dummy";
var cfg = global.cfg.enemy.dummy;
hp = cfg.hp;
max_hp = cfg.hp;
speed_val = cfg.speed;
accel_val = cfg.accel;
kb_resist = cfg.kb_resist;
dummy_cycle_timer = cfg.attack_interval;

