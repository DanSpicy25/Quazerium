// =====================================================================
// QUAZERIUM — OBJ_PLAYER: Lead gameplay entity & FSM controller.
// Implements responsive movement, coyote time, jump buffering, directional dash,
// slam, combo attacks, charging, parrying, grapple integration, powers & overdrive.
// =====================================================================

team = TEAM.PLAYER;
state = PSTATE.IDLE;

var cfg = global.cfg.player;
hp = cfg.max_hp;
max_hp = cfg.max_hp;
vx = 0;
vy = 0;
facing = 1;

bbox_hw = cfg.hw;
bbox_hh = cfg.hh;
hurtbox_hw = bbox_hw + 2; // Decoupled combat hurtbox
hurtbox_hh = bbox_hh + 2;
on_ground = false;
on_ceiling = false;
on_wall_left = false;
on_wall_right = false;

// Coyote Time, Jump Buffer & Double Jump
coyote_timer = 0;
jump_buffer_timer = 0;
air_jumps_left = variable_struct_exists(cfg, "max_air_jumps") ? cfg.max_air_jumps : 1;

// Dash
dash_timer = 0;
dash_dir_x = 1;
dash_dir_y = 0;
dash_cd = new Cooldown(cfg.dash_cooldown);
air_dashes_left = cfg.air_dashes;
iframes = 0;

// Slam
slam_hang_timer = 0;

// Combat
combo_count = 0;
combo_timer = 0;
attack_step = 0;
attack_phase = "none";
attack_phase_timer = 0;
charge_timer = 0;
is_charging = false;

// Parry
is_parrying = false;
parry_timer = 0;

// Grapple
grapple = new GrappleController(id);

// Powers
power_cooldowns = array_create(POWER_ID.COUNT);
for (var i = 0; i < POWER_ID.COUNT; i++) {
    var p_def = power_get(i);
    power_cooldowns[i] = new Cooldown(p_def.cfg.cooldown);
}
selected_power_id = POWER_ID.SHOCKWAVE;
active_power_id = -1;
power_timer = 0;

// Elements
active_element = ELEMENT.NONE;
element_status = ELEMENT.NONE;
element_timer = 0;

// Energy & Overdrive
energy = 0;
overdrive_active = false;
overdrive_timer = 0;

// Wall-Tech
wall_jump_lock_timer = 0;

// Stat Modifiers
stat_mods = new StatModifierContainer();

// Presentation & Animation State
squash_x = 1.0;
squash_y = 1.0;
was_on_ground = true;
run_anim_t = 0.0;
afterimage_timer = 0.0;
afterimages = array_create(6);
for (var a = 0; a < 6; a++) {
    afterimages[a] = { active: false, x: 0, y: 0, facing: 1, alpha: 0, color: c_aqua };
}
afterimage_head = 0;

// Visual Presentation: Sacred Brutalism Talisman Streamer Ribbons
talisman_ribbons = array_create(4);
for (var tr = 0; tr < 4; tr++) {
    talisman_ribbons[tr] = { x: x, y: y };
}

