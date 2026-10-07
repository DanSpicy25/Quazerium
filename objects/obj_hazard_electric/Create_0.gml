// =====================================================================
// QUAZERIUM — OBJ_HAZARD_ELECTRIC: Environmental electrified conduit floor.
// Cyclical surge hazards: Dormant -> Warning -> Active Surge.
// Damages both careless players and knocked-in enemies!
// =====================================================================

hazard_w = 140;
hazard_h = 14;
cycle_state = 0; // 0: Dormant (2.5s), 1: Warning (0.8s), 2: Surge (1.8s)
timer = 2.5;
damage = 10;
tick_cd = 0;
