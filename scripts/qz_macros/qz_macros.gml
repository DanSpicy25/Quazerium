// =====================================================================
// QUAZERIUM — CORE: macros, enums, name tables. No gameplay logic here.
// =====================================================================
#macro QZ_VERSION "0.1.0-skeleton"
#macro QZ_REF_FPS 60

// Debug tooling is compiled out of the Release config (Igor --config=Release).
#macro QZ_DEBUG true
#macro Release:QZ_DEBUG false

enum TEAM { NEUTRAL, PLAYER, ENEMY, WORLD }

// Abstract input actions. Gameplay reads ONLY these (never raw keys).
// MOVE_UP / MOVE_DOWN / POWER_SELECT were added: required by directional dash, slam and power choice.
enum ACTION { MOVE_LEFT, MOVE_RIGHT, MOVE_UP, MOVE_DOWN, JUMP, DASH, ATTACK, PARRY, GRAPPLE, POWER, POWER_SELECT, ELEMENT, OVERDRIVE, COUNT }

// Gameplay events (Core -> Presentation/Camera/Audio). Keep in sync with qz_names_init().
enum EVT {
    PLAYER_ATTACK, HIT_CONFIRMED, HIT_CRITICAL, HIT_EVADED,
    PARRY, PERFECT_PARRY,
    DASH, SLAM, JUMP, LAND, WALL_JUMP,
    POWER, POWER_END, POWER_CANCEL, POWER_SELECTED,
    OVERDRIVE, OVERDRIVE_END, ENERGY_FULL,
    ELEMENT_REACTION, ELEMENT_APPLIED, ELEMENT_CHANGED,
    GRAPPLE_FIRE, GRAPPLE_ATTACH, GRAPPLE_RELEASE, GRAPPLE_SLING,
    ENTITY_KILLED, PLAYER_DIED,
    ENEMY_ATTACK_WINDUP, ENEMY_ATTACK, ENEMY_STUNNED,
    HITSTOP, QUALITY_CHANGED, ENVIRONMENT_INTERACTION,
    ENCOUNTER_START, ENCOUNTER_WAVE, ENCOUNTER_CLEAR, ENCOUNTER_VICTORY, HAZARD_TRIGGERED,
    COUNT
}

enum PSTATE { IDLE, RUN, JUMP, FALL, DASH, SLAM, ATTACK, PARRY, HOOK, COUNT }
enum ESTATE { IDLE, CHASE, WINDUP, ATTACK, RECOVER, STUNNED, DEAD, COUNT }
enum ELEMENT { NONE, FIRE, EARTH, WATER, WIND, COUNT }
enum POWER_ID { SHOCKWAVE, BLADE_SURGE, BLINK, COUNT }
enum GRAPPLE_STATE { IDLE, FIRING, ATTACHED, RETRACTING }
enum QUALITY { LOW, MEDIUM, HIGH, COUNT }
enum BT_STATUS { SUCCESS, FAILURE, RUNNING }
enum ENCOUNTER_STATE { IDLE, INTRO, SPAWNING, COMBAT, CLEAR, RESULT, VICTORY, COUNT }

function qz_names_init() {
    global.evt_names = [
        "PLAYER_ATTACK", "HIT_CONFIRMED", "HIT_CRITICAL", "HIT_EVADED",
        "PARRY", "PERFECT_PARRY",
        "DASH", "SLAM", "JUMP", "LAND", "WALL_JUMP",
        "POWER", "POWER_END", "POWER_CANCEL", "POWER_SELECTED",
        "OVERDRIVE", "OVERDRIVE_END", "ENERGY_FULL",
        "ELEMENT_REACTION", "ELEMENT_APPLIED", "ELEMENT_CHANGED",
        "GRAPPLE_FIRE", "GRAPPLE_ATTACH", "GRAPPLE_RELEASE", "GRAPPLE_SLING",
        "ENTITY_KILLED", "PLAYER_DIED",
        "ENEMY_ATTACK_WINDUP", "ENEMY_ATTACK", "ENEMY_STUNNED",
        "HITSTOP", "QUALITY_CHANGED", "ENVIRONMENT_INTERACTION",
        "ENCOUNTER_START", "ENCOUNTER_WAVE", "ENCOUNTER_CLEAR", "ENCOUNTER_VICTORY", "HAZARD_TRIGGERED"
    ];
    global.pstate_names  = ["IDLE", "RUN", "JUMP", "FALL", "DASH", "SLAM", "ATTACK", "PARRY", "HOOK"];
    global.estate_names  = ["IDLE", "CHASE", "WINDUP", "ATTACK", "RECOVER", "STUNNED", "DEAD"];
    global.element_names = ["NONE", "FIRE", "EARTH", "WATER", "WIND"];
    global.power_names   = ["SHOCKWAVE", "BLADE_SURGE", "BLINK"];
    global.grapple_names = ["IDLE", "FIRING", "ATTACHED", "RETRACTING"];
    global.quality_names = ["LOW", "MEDIUM", "HIGH"];
    global.encounter_state_names = ["IDLE", "INTRO", "SPAWNING", "COMBAT", "CLEAR", "RESULT", "VICTORY"];
    global.action_names  = ["MOVE_LEFT", "MOVE_RIGHT", "MOVE_UP", "MOVE_DOWN", "JUMP", "DASH", "ATTACK", "PARRY", "GRAPPLE", "POWER", "POWER_SELECT", "ELEMENT", "OVERDRIVE"];
}

function evt_name(e) { return global.evt_names[e]; }

