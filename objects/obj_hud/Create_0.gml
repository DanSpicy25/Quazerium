// =====================================================================
// QUAZERIUM — OBJ_HUD: Action Game HUD (Health, Energy, Combo, Elements, Powers).
// High readability, responsive visual feedback, zero SaaS clutter.
// =====================================================================

display_set_gui_size(1280, 720);

hp_lag = 100;
combo_scale = 1.0;
prev_combo = 0;

quality_notify_text = "";
quality_notify_timer = 0.0;
tutorial_banner_timer = 9.0;
is_player_dead = false;

events_subscribe(EVT.HIT_CONFIRMED, function(evt, data) {
    combo_scale = 1.35;
}, id);

events_subscribe(EVT.HIT_CRITICAL, function(evt, data) {
    combo_scale = 1.55;
}, id);

events_subscribe(EVT.QUALITY_CHANGED, function(evt, data) {
    quality_notify_text = "HARDWARE PROFILE: " + data.name;
    quality_notify_timer = 2.0;
}, id);

events_subscribe(EVT.PLAYER_DIED, function(evt, data) {
    is_player_dead = true;
}, id);
