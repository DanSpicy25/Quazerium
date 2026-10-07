// =====================================================================
// QUAZERIUM — OBJ_HUD: Action Game HUD (Health, Energy, Combo, Elements, Powers).
// High readability, responsive visual feedback, zero SaaS clutter.
// =====================================================================

display_set_gui_size(1280, 720);

hp_lag = 100;
combo_scale = 1.0;
prev_combo = 0;

events_subscribe(EVT.HIT_CONFIRMED, function(evt, data) {
    combo_scale = 1.35;
}, id);

events_subscribe(EVT.HIT_CRITICAL, function(evt, data) {
    combo_scale = 1.5;
}, id);
