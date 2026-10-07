// =====================================================================
// QUAZERIUM — CORE: central configuration (all tunables live here).
// Units: pixels, seconds. CORE values are quality-independent.
// =====================================================================
function qz_config_init() {
    global.cfg = {
        time: { max_dt: 1 / 20 },

        physics: { gravity: 2600, max_fall: 1500, max_step: 6 },

        player: {
            hw: 12, hh: 22, max_hp: 100,
            run_speed: 330, ground_accel: 4200, ground_decel: 5200, air_accel: 2600, air_decel: 1400, turn_mult: 1.6,
            jump_speed: 820, jump_cut: 0.45, coyote_time: 0.1, jump_buffer: 0.12,
            fall_gravity_mult: 1.55, apex_threshold: 90, apex_gravity_mult: 0.55,
            dash_speed: 980, dash_time: 0.14, dash_cooldown: 0.45, dash_exit_mult: 0.45,
            dash_iframes_extra: 0.04, air_dashes: 1, dash_buffer: 0.1,
            slam_hang: 0.06, slam_speed: 1500, slam_recover: 0.14, slam_radius: 90, slam_damage: 14, slam_knockback: 520,
            hurt_iframes: 0.5, hitstun: 0.18,
            wall_slide_speed: 180, wall_jump_vx: 420, wall_jump_vy: 760, wall_jump_lock: 0.14,
        },

        combat: {
            attack_buffer: 0.15, chain_window: 0.3,
            // Attack chain (combo strings). Frame-based authoring: use time_frames_to_seconds(n).
            chain: [
                { damage: 8,  windup: 0.05, active: 0.08, recover: 0.14, w: 52, h: 34, ox: 30, oy: -2, kb: 240, kb_up: 60,  hitstop: 0.04, lunge: 120 },
                { damage: 10, windup: 0.05, active: 0.08, recover: 0.16, w: 56, h: 36, ox: 32, oy: -2, kb: 280, kb_up: 80,  hitstop: 0.045, lunge: 140 },
                { damage: 14, windup: 0.07, active: 0.10, recover: 0.24, w: 64, h: 40, ox: 34, oy: -4, kb: 420, kb_up: 180, hitstop: 0.07, lunge: 180 },
            ],
            charged: { damage: 20, windup: 0.06, active: 0.12, recover: 0.25, w: 80, h: 48, ox: 40, oy: -4, kb: 640, kb_up: 240, hitstop: 0.09, lunge: 260 },
            charge_time: 0.45, charge_move_mult: 0.35,
            combo_window: 1.2, combo_step: 0.05, combo_cap: 20,
            energy_per_hit: 4, energy_per_charged_hit: 10,
            air_attack_gravity_mult: 0.35,
            cancel_recover_with_dash: true,
            cancel_recover_with_parry: true,
        },

        parry: {
            window: 0.30, perfect_window: 0.12, recover: 0.22, buffer: 0.05,
            energy_normal: 8, energy_perfect: 25,
            hitstop_normal: 0.05, hitstop_perfect: 0.12,
            normal_damage_mult: 0, attacker_stun_normal: 0.35, attacker_stun_perfect: 0.9,
            requires_facing: false,
        },

        // Rope: F = -k*x - c*v (tension only) + hard stretch limit for stability.
        grapple: {
            range: 380, cone_deg: 40, hook_speed: 2400, stiffness: 180, damping: 12,
            min_length: 36, reel_speed: 420, max_stretch: 1.12, swing_accel: 900,
            sling_boost: 1.15, sling_up: 380, zip_speed: 900, fire_buffer: 0.1,
            enemy_hook_enabled: true, enemy_zip_speed: 980, enemy_tackle_damage: 8,
            enemy_tackle_stun: 0.45, enemy_tackle_rebound: -360,
        },

        director: {
            intro_duration: 1.2,
            clear_duration: 1.4,
            rank_s: 10500,
            rank_a: 7500,
            rank_b: 5000,
        },

        hazard: {
            electric: { dormant: 2.5, warning: 0.8, surge: 1.8, damage_player: 10, damage_enemy: 18, stun_enemy: 0.9 },
        },

        interact: {
            launch_pad: { speed: -860, cooldown: 0.25 },
            canister: { radius: 110, damage: 45, energy_reward: 25 },
        },

        powers: {
            list: [POWER_ID.SHOCKWAVE, POWER_ID.BLADE_SURGE, POWER_ID.BLINK],
            shockwave:   { cost: 20, cooldown: 2.0, radius: 130, damage: 12, knockback: 560, knock_up: 220, hitstop: 0.06, duration: 0.12, interruptible: false },
            blade_surge: { cost: 25, cooldown: 2.5, speed: 1150, duration: 0.2, damage: 18, knockback: 380, w: 60, h: 40, hitstop: 0.05, interruptible: true },
            blink:       { cost: 15, cooldown: 1.2, distance: 170, step: 4, iframes: 0.12, keep_velocity: 0.5, interruptible: false },
            buffer: 0.12,
        },

        energy: { max: 100 },

        overdrive: {
            duration: 8.0,
            modifiers: [
                { stat: "damage_mult",        mult: 1.6,  add: 0 },
                { stat: "move_speed_mult",    mult: 1.2,  add: 0 },
                { stat: "jump_mult",          mult: 1.08, add: 0 },
                { stat: "dash_cooldown_mult", mult: 0.5,  add: 0 },
                { stat: "air_dashes_add",     mult: 1,    add: 1 },
            ],
        },

        elements: { status_duration: 4.0, cycle: [ELEMENT.NONE, ELEMENT.FIRE, ELEMENT.EARTH, ELEMENT.WATER, ELEMENT.WIND] },

        walltech: { enabled: true },

        enemy: {
            grunt: { hw: 16, hh: 16, hp: 60, speed: 140, accel: 1400, aggro_range: 420, attack_range: 56,
                     windup: 0.45, active: 0.12, recover: 0.5, attack_cooldown: 1.0, damage: 10, kb: 380, kb_up: 120,
                     atk_w: 44, atk_h: 30, atk_ox: 28, atk_oy: 0, hitstop: 0.05, stationary: false, attack_interval: 0, kb_resist: 0, score: 100 },
            fast: { hw: 13, hh: 13, hp: 35, speed: 250, accel: 2400, aggro_range: 520, attack_range: 85,
                    windup: 0.22, active: 0.10, recover: 0.30, attack_cooldown: 0.70, damage: 8, kb: 260, kb_up: 80,
                    atk_w: 36, atk_h: 24, atk_ox: 22, atk_oy: 0, hitstop: 0.04, stationary: false, attack_interval: 0, kb_resist: 0, score: 150 },
            ranged: { hw: 14, hh: 16, hp: 45, speed: 110, accel: 1000, aggro_range: 680, attack_range: 520, keep_dist: 260,
                      windup: 0.65, active: 0.10, recover: 0.65, attack_cooldown: 1.8, damage: 12, kb: 220, kb_up: 60,
                      atk_w: 16, atk_h: 16, atk_ox: 0, atk_oy: 0, hitstop: 0.05, stationary: false, attack_interval: 0, kb_resist: 0.1, score: 200,
                      projectile_speed: 380 },
            heavy: { hw: 22, hh: 26, hp: 160, speed: 75, accel: 800, aggro_range: 400, attack_range: 75,
                     windup: 0.85, active: 0.20, recover: 0.85, attack_cooldown: 1.8, damage: 24, kb: 520, kb_up: 220,
                     atk_w: 68, atk_h: 36, atk_ox: 34, atk_oy: 0, hitstop: 0.08, stationary: false, attack_interval: 0, kb_resist: 0.70, score: 350 },
            elite: { hw: 18, hh: 22, hp: 220, speed: 175, accel: 1800, aggro_range: 550, attack_range: 65,
                     windup: 0.35, active: 0.14, recover: 0.40, attack_cooldown: 0.85, damage: 16, kb: 420, kb_up: 140,
                     atk_w: 52, atk_h: 32, atk_ox: 30, atk_oy: 0, hitstop: 0.06, stationary: false, attack_interval: 0, kb_resist: 0.40, score: 500 },
            dummy: { hw: 18, hh: 20, hp: 99999, speed: 0, accel: 0, aggro_range: 300, attack_range: 60,
                     windup: 0.5, active: 0.12, recover: 0.6, attack_cooldown: 2.5, damage: 8, kb: 300, kb_up: 100,
                     atk_w: 44, atk_h: 30, atk_ox: 28, atk_oy: 0, hitstop: 0.05, stationary: true, attack_interval: 2.5, kb_resist: 1, score: 0 },
        },

        camera: {
            view_w: 1280, view_h: 720,
            follow_half_life: 0.10, lookahead_x: 110, lookahead_half_life: 0.25, offset_y: -60,
            zoom: 1.0, zoom_half_life: 0.15, zoom_pulse_decay: 2.5,
            trauma_decay: 1.5, max_shake: 18,
            impulse_k: 260, impulse_c: 22,
            hitstop_freeze_follow: true,
            reactions: undefined, // filled below (indexed by EVT)
        },

        debug: { start_visible: false },
    };

    // Camera reactions: data-driven mapping EVT -> { trauma, impulse(px), zoom(pulse) }.
    var r = array_create(EVT.COUNT, undefined);
    r[EVT.PLAYER_ATTACK] = { trauma: 0.00, impulse: 4,  zoom: 0 };
    r[EVT.HIT_CONFIRMED] = { trauma: 0.18, impulse: 8,  zoom: 0 };
    r[EVT.HIT_CRITICAL]  = { trauma: 0.35, impulse: 14, zoom: 0.04 };
    r[EVT.PARRY]         = { trauma: 0.20, impulse: 6,  zoom: 0.02 };
    r[EVT.PERFECT_PARRY] = { trauma: 0.40, impulse: 10, zoom: 0.08 };
    r[EVT.DASH]          = { trauma: 0.00, impulse: 10, zoom: 0 };
    r[EVT.SLAM]          = { trauma: 0.50, impulse: 16, zoom: 0.03 };
    r[EVT.OVERDRIVE]        = { trauma: 0.45, impulse: 0,  zoom: 0.10 };
    r[EVT.POWER]            = { trauma: 0.25, impulse: 8,  zoom: 0.02 };
    r[EVT.ELEMENT_REACTION] = { trauma: 0.22, impulse: 8,  zoom: 0.02 };
    r[EVT.ENTITY_KILLED]    = { trauma: 0.28, impulse: 10, zoom: 0.03 };
    r[EVT.ENCOUNTER_START]  = { trauma: 0.20, impulse: 0,  zoom: 0.05 };
    r[EVT.ENCOUNTER_CLEAR]  = { trauma: 0.25, impulse: 0,  zoom: 0.06 };
    r[EVT.ENCOUNTER_VICTORY]= { trauma: 0.40, impulse: 0,  zoom: 0.10 };
    r[EVT.HAZARD_TRIGGERED] = { trauma: 0.30, impulse: 8,  zoom: 0.02 };
    global.cfg.camera.reactions = r;
}

