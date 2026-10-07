// =====================================================================
// QUAZERIUM — OBJ_GAME: Begin Step
// Updates time and input so all gameplay entities read synchronous state.
// =====================================================================

time_update();
input_update();

// Global utility hotkeys (F1 Debug, F2 Quality cycle, F5 Reload)
if (keyboard_check_pressed(vk_f1)) {
    if (instance_exists(obj_debug)) {
        obj_debug.visible = !obj_debug.visible;
    }
}

if (keyboard_check_pressed(vk_f2)) {
    var next_q = (global.quality_level + 1) mod QUALITY.COUNT;
    quality_set(next_q);
}

if (keyboard_check_pressed(vk_f5) || keyboard_check_pressed(ord("R"))) {
    room_restart();
}

if (keyboard_check_pressed(vk_escape)) {
    game_end();
}

