// =====================================================================
// QUAZERIUM — OBJ_GAME: Master lifecycle and engine bootstrapper.
// Persistent. Initializes Core, Time, Input, Events, Quality, Audio/Camera.
// =====================================================================

show_debug_message("=== QUAZERIUM BOOT INITIALIZATION ===");

// 1. Initialize all core subsystems
qz_names_init();
qz_config_init();
events_init();
time_init();
input_init();
elements_system_init();
powers_init();
quality_system_init();
audio_system_init();
director_system_init();

// 2. Check for headless self-test execution
var is_selftest = (environment_get_variable("QZ_SELFTEST") == "1");
if (is_selftest) {
    var fails = qz_run_selftest();
    game_end();
    exit;
}

// 3. Normal boot: transition from rm_boot to rm_arena
if (room == rm_boot) {
    room_goto(rm_arena);
}

