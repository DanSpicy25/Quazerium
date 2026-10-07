// =====================================================================
// QUAZERIUM — ENCOUNTER DIRECTOR: Wave spawner, progression & scoring.
// Controls pacing, hand-crafted encounter composition and arena loops.
// =====================================================================

function director_system_init() {
    global.director = {
        state: ENCOUNTER_STATE.IDLE,
        state_timer: 0,
        current_encounter_idx: 0,
        current_wave_idx: 0,
        active_enemies: 0,
        wave_spawning_timer: 0,
        pending_spawns: [],

        // Statistics
        total_score: 0,
        total_time: 0,
        total_kills: 0,
        total_parries: 0,
        max_combo: 0,
        encounter_score: 0,
        encounter_time: 0,
        is_victory: false,

        // Spawn Locations in rm_arena
        spawn_points: [
            { x: 260,  y: 770 }, // 0: Floor Left
            { x: 390,  y: 620 }, // 1: Platform Low Left
            { x: 780,  y: 490 }, // 2: Platform Center
            { x: 1220, y: 390 }, // 3: Platform High Right
            { x: 1620, y: 770 }, // 4: Floor Right
            { x: 1200, y: 770 }  // 5: Floor Center
        ],

        // 5 Hand-Crafted Tactical Encounters
        encounters: [
            {
                name: "SECTOR BREACH // PROTOCOL INITIALIZATION",
                subtitle: "Combat Fundamentals & Spacing",
                waves: [
                    [ { type: "grunt", spawn: 0 }, { type: "grunt", spawn: 4 } ],
                    [ { type: "grunt", spawn: 1 }, { type: "grunt", spawn: 3 } ]
                ]
            },
            {
                name: "SWARM SKIRMISH // MOBILITY PRESSURE",
                subtitle: "Agility & Parry Timing",
                waves: [
                    [ { type: "grunt", spawn: 0 }, { type: "fast", spawn: 4 } ],
                    [ { type: "fast", spawn: 1 }, { type: "fast", spawn: 3 }, { type: "grunt", spawn: 2 } ]
                ]
            },
            {
                name: "CROSSFIRE GRID // SPACE CONTROL",
                subtitle: "Projectile Deflection & Vertical Movement",
                waves: [
                    [ { type: "grunt", spawn: 0 }, { type: "ranged", spawn: 3 } ],
                    [ { type: "fast", spawn: 0 }, { type: "ranged", spawn: 2 }, { type: "ranged", spawn: 4 } ]
                ]
            },
            {
                name: "JUGGERNAUT SIEGE // AREA DENIAL",
                subtitle: "Armor Penetration & Posture Break",
                waves: [
                    [ { type: "heavy", spawn: 2 }, { type: "grunt", spawn: 0 } ],
                    [ { type: "heavy", spawn: 4 }, { type: "fast", spawn: 0 }, { type: "ranged", spawn: 3 } ]
                ]
            },
            {
                name: "APEX OVERDRIVE // FINAL TRIAL",
                subtitle: "Elemental Synergy & Apex Enforcer",
                waves: [
                    [ { type: "elite", spawn: 2 }, { type: "grunt", spawn: 0 }, { type: "fast", spawn: 4 } ],
                    [ { type: "elite", spawn: 2 }, { type: "heavy", spawn: 0 }, { type: "ranged", spawn: 3 }, { type: "fast", spawn: 4 } ]
                ]
            }
        ]
    };

    // Event Subscriptions for Real-Time Tallying
    events_subscribe(EVT.ENTITY_KILLED, function(evt, data) {
        var d = global.director;
        var base_pts = (variable_struct_exists(data, "score") && is_numeric(data.score)) ? data.score : 100;
        var p = instance_nearest(0, 0, obj_player);
        var combo_pts = (p != noone) ? (p.combo_count * 15) : 0;
        var earned = base_pts + combo_pts;

        d.total_kills++;
        d.total_score += earned;
        d.encounter_score += earned;
        if (p != noone && p.combo_count > d.max_combo) {
            d.max_combo = p.combo_count;
        }
    }, "qz_director");

    events_subscribe(EVT.PARRY, function(evt, data) {
        global.director.total_parries++;
        global.director.total_score += 50;
        global.director.encounter_score += 50;
    }, "qz_director");

    events_subscribe(EVT.PERFECT_PARRY, function(evt, data) {
        global.director.total_parries++;
        global.director.total_score += 150;
        global.director.encounter_score += 150;
    }, "qz_director");
}

function director_start_encounter(idx) {
    var d = global.director;
    var total_enc = array_length(d.encounters);
    d.current_encounter_idx = clamp(idx, 0, total_enc - 1);
    d.current_wave_idx = 0;
    d.encounter_time = 0;
    d.encounter_score = 0;
    d.state = ENCOUNTER_STATE.INTRO;
    var intro_dur = (variable_struct_exists(global, "cfg") && variable_struct_exists(global.cfg, "director")) ? global.cfg.director.intro_duration : 1.2;
    d.state_timer = intro_dur;

    events_emit(EVT.ENCOUNTER_START, {
        index: d.current_encounter_idx,
        name: d.encounters[d.current_encounter_idx].name
    });
}

function director_spawn_wave(enc_idx, wave_idx) {
    var d = global.director;
    var enc = d.encounters[enc_idx];
    if (wave_idx >= array_length(enc.waves)) return;

    var wave_list = enc.waves[wave_idx];
    d.pending_spawns = [];

    for (var i = 0; i < array_length(wave_list); i++) {
        var item = wave_list[i];
        var s_idx = item.spawn mod array_length(d.spawn_points);
        var pt = d.spawn_points[s_idx];
        array_push(d.pending_spawns, {
            type: item.type,
            x: pt.x,
            y: pt.y,
            delay: i * 0.25 // staggered spawning
        });
    }

    d.state = ENCOUNTER_STATE.SPAWNING;
    d.wave_spawning_timer = 0;
    events_emit(EVT.ENCOUNTER_WAVE, { encounter: enc_idx, wave: wave_idx });
}

function director_spawn_enemy(type_name, spawn_x, spawn_y) {
    var enemy_obj = obj_enemy_grunt;
    switch (type_name) {
        case "fast":   enemy_obj = obj_enemy_fast; break;
        case "ranged": enemy_obj = obj_enemy_ranged; break;
        case "heavy":  enemy_obj = obj_enemy_heavy; break;
        case "elite":  enemy_obj = obj_enemy_elite; break;
        default:       enemy_obj = obj_enemy_grunt; break;
    }

    var spawner = instance_create_layer(spawn_x, spawn_y, "Instances", obj_enemy_spawner);
    spawner.enemy_obj = enemy_obj;
    return spawner;
}

function director_count_active_enemies() {
    var cnt = 0;
    cnt += instance_number(obj_enemy_grunt);
    cnt += instance_number(obj_enemy_fast);
    cnt += instance_number(obj_enemy_ranged);
    cnt += instance_number(obj_enemy_heavy);
    cnt += instance_number(obj_enemy_elite);
    cnt += instance_number(obj_enemy_spawner);
    return cnt;
}

function director_update(dt) {
    var d = global.director;
    if (dt <= 0) return;

    d.total_time += dt;

    switch (d.state) {
        case ENCOUNTER_STATE.IDLE:
            // Auto start first encounter if idle
            director_start_encounter(0);
            break;

        case ENCOUNTER_STATE.INTRO:
            d.state_timer -= dt;
            if (d.state_timer <= 0) {
                director_spawn_wave(d.current_encounter_idx, d.current_wave_idx);
            }
            break;

        case ENCOUNTER_STATE.SPAWNING:
            d.wave_spawning_timer += dt;
            var remain_pending = [];
            for (var p = 0; p < array_length(d.pending_spawns); p++) {
                var item = d.pending_spawns[p];
                if (d.wave_spawning_timer >= item.delay) {
                    director_spawn_enemy(item.type, item.x, item.y);
                } else {
                    array_push(remain_pending, item);
                }
            }
            d.pending_spawns = remain_pending;
            if (array_length(d.pending_spawns) == 0) {
                d.state = ENCOUNTER_STATE.COMBAT;
            }
            break;

        case ENCOUNTER_STATE.COMBAT:
            d.encounter_time += dt;
            d.active_enemies = director_count_active_enemies();

            if (d.active_enemies <= 0) {
                var enc = d.encounters[d.current_encounter_idx];
                var next_wave = d.current_wave_idx + 1;
                if (next_wave < array_length(enc.waves)) {
                    // Advance to next wave
                    d.current_wave_idx = next_wave;
                    director_spawn_wave(d.current_encounter_idx, d.current_wave_idx);
                } else {
                    // Encounter Cleared!
                    d.state = ENCOUNTER_STATE.CLEAR;
                    var clear_dur = (variable_struct_exists(global, "cfg") && variable_struct_exists(global.cfg, "director")) ? global.cfg.director.clear_duration : 1.4;
                    d.state_timer = clear_dur;
                    events_emit(EVT.ENCOUNTER_CLEAR, {
                        index: d.current_encounter_idx,
                        score: d.encounter_score,
                        time: d.encounter_time
                    });
                }
            }
            break;

        case ENCOUNTER_STATE.CLEAR:
            d.state_timer -= dt;
            if (d.state_timer <= 0) {
                var next_enc = d.current_encounter_idx + 1;
                if (next_enc < array_length(d.encounters)) {
                    director_start_encounter(next_enc);
                } else {
                    // VICTORY! All 5 encounters completed
                    d.state = ENCOUNTER_STATE.VICTORY;
                    d.is_victory = true;
                    events_emit(EVT.ENCOUNTER_VICTORY, {
                        total_score: d.total_score,
                        total_time: d.total_time,
                        max_combo: d.max_combo,
                        total_parries: d.total_parries
                    });
                }
            }
            break;

        case ENCOUNTER_STATE.VICTORY:
            // Waiting for player restart (R key handled in obj_game / obj_director)
            break;
    }
}

function director_reset() {
    var d = global.director;
    d.state = ENCOUNTER_STATE.IDLE;
    d.state_timer = 0;
    d.current_encounter_idx = 0;
    d.current_wave_idx = 0;
    d.total_score = 0;
    d.total_time = 0;
    d.total_kills = 0;
    d.total_parries = 0;
    d.max_combo = 0;
    d.encounter_score = 0;
    d.encounter_time = 0;
    d.is_victory = false;
    d.pending_spawns = [];
}
