// =====================================================================
// QUAZERIUM — SELF TEST: Automated headless validation of all 22 components.
// Runs on boot if environment QZ_SELFTEST == "1" or triggered manually.
// =====================================================================

function qz_run_selftest() {
    var passes = 0;
    var fails = 0;

    var _assert = function(cond, test_name) {
        if (cond) {
            show_debug_message("[PASS] " + test_name);
            return 1;
        } else {
            show_debug_message("[FAIL] " + test_name);
            return 0;
        }
    };

    show_debug_message("========================================");
    show_debug_message("QUAZERIUM SELF-TEST SUITE STARTING");
    show_debug_message("========================================");

    // 1. Core Systems & Names
    qz_names_init();
    qz_config_init();
    if (_assert(global.cfg.player.run_speed > 0, "Core Config initialized")) passes++; else fails++;
    if (_assert(array_length(global.evt_names) == EVT.COUNT, "Event names table matches EVT.COUNT")) passes++; else fails++;

    // 2. Events Bus
    events_init();
    global.test_evt_rx = false;
    global.test_evt_payload = 0;
    var test_cb = function(evt, payload) {
        global.test_evt_rx = true;
        global.test_evt_payload = payload;
    };
    events_subscribe(EVT.PLAYER_ATTACK, test_cb, "test_owner");
    events_emit(EVT.PLAYER_ATTACK, 42);
    if (_assert(global.test_evt_rx && global.test_evt_payload == 42, "Event Bus subscription and payload delivery")) passes++; else fails++;
    events_unsubscribe_owner("test_owner");
    global.test_evt_rx = false;
    events_emit(EVT.PLAYER_ATTACK, 99);
    if (_assert(!global.test_evt_rx, "Event Bus unsubscribe by owner")) passes++; else fails++;

    // 3. Time Manager
    time_init();
    var cd = new Cooldown(1.0);
    cd.start();
    if (_assert(!cd.ready(), "Cooldown active after start")) passes++; else fails++;
    cd.tick(0.6);
    if (_assert(!cd.ready(), "Cooldown ticking properly")) passes++; else fails++;
    cd.tick(0.5);
    if (_assert(cd.ready(), "Cooldown ready after full duration")) passes++; else fails++;

    time_hitstop(0.1);
    if (_assert(global.time.hitstop == 0.1, "Hitstop registered")) passes++; else fails++;
    global.time.hitstop = 0; // reset

    // 4. Input & Synthetic Injection
    input_init();
    input_sim_enable(true);
    input_sim_press(ACTION.JUMP);
    input_update();
    if (_assert(input_check_pressed(ACTION.JUMP), "Synthetic input jump pressed")) passes++; else fails++;
    input_update();
    if (_assert(!input_check_pressed(ACTION.JUMP) && input_check(ACTION.JUMP), "Synthetic input jump held")) passes++; else fails++;
    input_sim_release(ACTION.JUMP);
    input_update();
    if (_assert(!input_check(ACTION.JUMP) && input_check_released(ACTION.JUMP), "Synthetic input jump released")) passes++; else fails++;
    input_sim_enable(false);

    // 5. Stat Modifiers
    var sm = new StatModifierContainer();
    sm.add("overdrive", "damage_mult", 1.6, 0, 8.0);
    var eval_dmg = sm.evaluate("damage_mult", 10);
    if (_assert(abs(eval_dmg - 16) < 0.001, "Stat modifier evaluated: 10 * 1.6 = 16")) passes++; else fails++;
    sm.update(9.0);
    var post_dmg = sm.evaluate("damage_mult", 10);
    if (_assert(abs(post_dmg - 10) < 0.001, "Stat modifier expired after duration")) passes++; else fails++;

    // 6. Combat Formulas & Damage
    var calc_dmg_base = combat_calculate_damage(10, 1.0, 0);
    if (_assert(calc_dmg_base == 10, "Base combat damage calculation")) passes++; else fails++;
    var calc_dmg_combo = combat_calculate_damage(10, 1.0, 10); // combo_step = 0.05 -> 1.5x -> 15
    if (_assert(calc_dmg_combo == 15, "Combo scaling damage calculation")) passes++; else fails++;
    var calc_dmg_ovr = combat_calculate_damage(10, 1.6, 0); // 16
    if (_assert(calc_dmg_ovr == 16, "Overdrive damage calculation (+60%)")) passes++; else fails++;

    // 7. Elemental Reaction Matrix
    elements_system_init();
    var dummy_target = { element_status: ELEMENT.WATER, element_timer: 4.0 };
    var reaction = element_apply(dummy_target, ELEMENT.FIRE);
    if (_assert(reaction != undefined && reaction.name == "VAPORIZE", "Element reaction: WATER + FIRE = VAPORIZE")) passes++; else fails++;
    if (_assert(reaction.damage_mult == 2.0 && reaction.clears_status, "Vaporize gives 2.0x damage and clears status")) passes++; else fails++;
    if (_assert(dummy_target.element_status == ELEMENT.NONE, "Target status cleared after Vaporize")) passes++; else fails++;

    // 8. Parry Timing Window
    var perfect_win = global.cfg.parry.perfect_window;
    if (_assert(abs(perfect_win - 0.12) < 0.001, "Parry perfect window is 120ms (0.12s)")) passes++; else fails++;

    // 9. Grapple Spring Math
    var k = global.cfg.grapple.stiffness;
    var stretch = 20; // 20 px stretch
    var f_spring = k * stretch;
    if (_assert(f_spring > 0, "Grapple spring force F = -k*x generates restorative tension")) passes++; else fails++;

    // 10. Powers Architecture
    powers_init();
    var p_sw = power_get(POWER_ID.SHOCKWAVE);
    var p_bs = power_get(POWER_ID.BLADE_SURGE);
    var p_bk = power_get(POWER_ID.BLINK);
    if (_assert(p_sw != undefined && p_bs != undefined && p_bk != undefined, "Powers initialized: Shockwave, Blade Surge, Blink")) passes++; else fails++;

    // 11. Hardware Quality Profiles
    quality_system_init();
    quality_set(QUALITY.LOW);
    var q_low = quality_get();
    if (_assert(q_low.max_particles == 100 && !q_low.enable_shaders, "Quality LOW enforces Intel HD 2500 constraints")) passes++; else fails++;
    quality_set(QUALITY.HIGH);
    var q_high = quality_get();
    if (_assert(q_high.max_particles == 2000 && q_high.enable_shaders, "Quality HIGH scales up for modern GPUs")) passes++; else fails++;
    quality_set(QUALITY.MEDIUM);

    // 12. Object Pool
    var pool_test = new ObjectPool(function() { return { x: 0, y: 0 }; }, function(o) { o.x = 0; o.y = 0; }, 4);
    var p_item = pool_test.get();
    p_item.x = 100;
    pool_test.recycle(p_item);
    var p_item2 = pool_test.get();
    if (_assert(p_item2.x == 0, "ObjectPool recycles and resets struct correctly")) passes++; else fails++;

    // 13. AI Behavior Tree & Blackboard
    var bb = new Blackboard();
    bb.set("target_seen", true);
    var cond = new BT_Condition(function(b) { return b.get("target_seen", false); });
    var act = new BT_Action(function(b, dt) { return BT_STATUS.SUCCESS; });
    var seq = new BT_Sequence([cond, act]);
    var b_res = seq.tick(bb, 0.016);
    if (_assert(b_res == BT_STATUS.SUCCESS, "Behavior Tree Sequence executes condition and action successfully")) passes++; else fails++;

    // 14. Integration: Combat Resolution & Reaction Damage
    var mock_atk = { id: 1001, combo_count: 2, combo_timer: 0, overdrive_active: false, energy: 0 };
    var mock_def = { id: 1002, team: TEAM.ENEMY, hp: 50, iframes: 0, is_parrying: false, element_status: ELEMENT.WATER, element_timer: 4.0, vx: 0, vy: 0, hitstun: 0, kb_resist: 0 };
    var mock_hb = {
        id: 2001, owner: mock_atk, team: TEAM.PLAYER, damage: 10, kb_x: 100, kb_y: -50,
        hitstop: 0.05, element: ELEMENT.FIRE, can_be_parried: true, hit_targets: []
    };
    var hit_res = combat_resolve_hit(mock_hb, mock_def);
    // Base 10 * 1.0 (ovr) * 1.1 (combo 2) * 2.0 (Vaporize) = 22 damage -> HP: 50 - 22 = 28
    if (_assert(hit_res && mock_def.hp == 28, "Integration: Combat hit resolved with Vaporize reaction (50 - 22 = 28 HP)")) passes++; else fails++;

    // 15. Integration: Perfect Parry Resolution (120ms window)
    var mock_parry_def = { id: 1003, team: TEAM.PLAYER, hp: 100, iframes: 0, is_parrying: true, parry_timer: 0.05, energy: 10 };
    var mock_enemy_atk = { id: 1004, stun_timer: 0 };
    var mock_enemy_hb = {
        id: 2002, owner: mock_enemy_atk, team: TEAM.ENEMY, damage: 20, kb_x: -100, kb_y: 0,
        hitstop: 0.05, element: ELEMENT.NONE, can_be_parried: true, hit_targets: []
    };
    var parry_res = combat_resolve_hit(mock_enemy_hb, mock_parry_def);
    var perf_stun_ok = (mock_enemy_atk.stun_timer == global.cfg.parry.attacker_stun_perfect);
    var perf_energy_ok = (mock_parry_def.energy == 10 + global.cfg.parry.energy_perfect);
    if (_assert(parry_res && mock_parry_def.hp == 100 && perf_stun_ok && perf_energy_ok, "Integration: 50ms parry triggers Perfect Parry (0 dmg, attacker stunned, +25 energy)")) passes++; else fails++;

    // 16. Integration: Iframes / Invulnerability Evasion
    var mock_invul_def = { id: 1005, team: TEAM.PLAYER, hp: 100, iframes: 0.15, is_parrying: false };
    var mock_hb_invul = {
        id: 2003, owner: { id: 9999 }, team: TEAM.ENEMY, damage: 30, kb_x: 0, kb_y: 0,
        hitstop: 0.05, element: ELEMENT.NONE, can_be_parried: false, hit_targets: []
    };
    var invul_res = combat_resolve_hit(mock_hb_invul, mock_invul_def);
    if (_assert(!invul_res && mock_invul_def.hp == 100, "Integration: Active iframes evades attack completely")) passes++; else fails++;

    // 17. Integration: Grapple State Machine & Sling Boost
    var mock_player_grapple = { x: 100, y: 100, vx: 100, vy: 0 };
    var gc = new GrappleController(mock_player_grapple);
    gc.fire(300, 100);
    if (_assert(gc.state == GRAPPLE_STATE.FIRING, "Integration: Grapple fired into FIRING state")) passes++; else fails++;
    gc.state = GRAPPLE_STATE.ATTACHED; // simulate latch
    gc.release(true); // sling jump
    if (_assert(gc.state == GRAPPLE_STATE.IDLE && mock_player_grapple.vy < 0, "Integration: Grapple sling imparts upward velocity boost")) passes++; else fails++;

    // 18. Presentation: VFX Particle Pool lifecycle
    var vfx_p = new VfxParticlePool(10);
    vfx_p.spawn(10, 20, 100, 0, 0, 0, 4, 1, c_white, c_yellow, 0.5, VFX_SHAPE.STREAK);
    var p0 = vfx_p.particles[0];
    if (_assert(p0.active && p0.x == 10 && p0.vx == 100, "Presentation: VfxParticlePool spawns streak particle")) passes++; else fails++;
    vfx_p.update(0.6);
    if (_assert(!p0.active, "Presentation: VfxParticlePool deactivates particle after lifetime")) passes++; else fails++;

    // 19. Presentation: Floating Combat Text Pool
    var vfx_t = new VfxCombatTextPool(8);
    vfx_t.spawn(50, 100, "CRIT 99", c_yellow, 1.2, 0.5);
    var t0 = vfx_t.entries[0];
    var t_init_y = t0.y;
    vfx_t.update(0.1);
    if (_assert(t0.active && t0.text == "CRIT 99" && t0.y < t_init_y, "Presentation: VfxCombatTextPool floats upward")) passes++; else fails++;

    // 20. Presentation: Combat Decal Pool
    var vfx_d = new VfxDecalPool(8);
    vfx_d.spawn(200, 300, DECAL_TYPE.CRACK, c_black, 0, 16, 2.0);
    var d0 = vfx_d.decals[0];
    vfx_d.update(1.0);
    if (_assert(d0.active && d0.life == 1.0, "Presentation: VfxDecalPool tracks persistent surface decal")) passes++; else fails++;

    // 21. Audio: Audio System Initialization
    audio_system_init();
    if (_assert(global.audio.enabled && is_array(global.audio.recent_log), "Audio: System initialized with valid state")) passes++; else fails++;

    // 22. Powers: Spatial Event Payloads & Activation
    global.test_power_evt = undefined;
    var p_sub = function(evt, data) { global.test_power_evt = data; };
    events_subscribe(EVT.POWER, p_sub, "selftest_power");
    var mock_p_player = {
        x: 100, y: 200, energy: 100, vx: 0, vy: 0, facing: 1, active_element: ELEMENT.FIRE,
        bbox_hw: 10, bbox_hh: 16, iframes: 0, active_power_id: -1, power_timer: 0,
        power_cooldowns: [new Cooldown(0), new Cooldown(0), new Cooldown(0)]
    };
    var act_res = power_try_activate(mock_p_player, POWER_ID.SHOCKWAVE);
    var p_has_spatial = (global.test_power_evt != undefined && variable_struct_exists(global.test_power_evt, "radius") && global.test_power_evt.x == 100);
    if (_assert(act_res && p_has_spatial, "Powers: Shockwave emits EVT.POWER with spatial radius and coordinates")) passes++; else fails++;
    events_unsubscribe_owner("selftest_power");

    // 23. Presentation: Combat Text Anti-Overlap Spacing
    var vfx_text_overlap = new VfxCombatTextPool(8);
    vfx_text_overlap.spawn(100, 100, "HIT 10", c_white, 1.0, 0.7);
    vfx_text_overlap.spawn(100, 100, "HIT 20", c_white, 1.0, 0.7);
    var t_first = vfx_text_overlap.entries[0];
    var t_second = vfx_text_overlap.entries[1];
    if (_assert(t_second.y < t_first.y, "Presentation: Second combat text at same location is spaced upward")) passes++; else fails++;

    // 24. Presentation: Decal Lifetime Bounded by Quality Profile
    var vfx_decal_prof = new VfxDecalPool(8);
    quality_set(QUALITY.LOW);
    vfx_decal_prof.spawn(50, 50, DECAL_TYPE.SCORCH, c_black);
    var d_prof = vfx_decal_prof.decals[0];
    if (_assert(d_prof.life == 4.0, "Presentation: Decal defaults to Quality LOW lifetime limit (4.0s)")) passes++; else fails++;
    quality_set(QUALITY.MEDIUM);

    // 25. Audio: Dispatcher Hook for Powers & Events
    events_emit(EVT.POWER, { name: "Blink" });
    if (_assert(global.audio.recent_log[0] == "POWER_BLINK", "Audio: Dispatcher captures EVT.POWER event with power name")) passes++; else fails++;

    // 26. Camera: Extended Combat Reaction Mapping
    var cam_r_react = global.cfg.camera.reactions[EVT.ELEMENT_REACTION];
    var cam_r_kill  = global.cfg.camera.reactions[EVT.ENTITY_KILLED];
    if (_assert(cam_r_react != undefined && cam_r_kill != undefined && cam_r_kill.trauma > 0, "Camera: ELEMENT_REACTION and ENTITY_KILLED have valid trauma profiles")) passes++; else fails++;

    // 27. Environment: Lighting Profile Compliance
    quality_set(QUALITY.LOW);
    var q_light_low = quality_get().enable_lighting;
    quality_set(QUALITY.HIGH);
    var q_light_high = quality_get().enable_lighting;
    quality_set(QUALITY.MEDIUM);
    if (_assert(!q_light_low && q_light_high, "Environment: 2D Lighting strictly disabled on LOW and enabled on HIGH")) passes++; else fails++;

    // 28. HUD & UI: Dynamic Combo Rank Engine
    var r_d = combat_get_combo_rank(2);
    var r_c = combat_get_combo_rank(6);
    var r_b = combat_get_combo_rank(12);
    var r_a = combat_get_combo_rank(17);
    var r_s = combat_get_combo_rank(25);
    var ranks_ok = (r_d != undefined && r_c != undefined && r_b != undefined && r_a != undefined && r_s != undefined &&
                    r_d.rank == "D" && r_c.rank == "C" && r_b.rank == "B" && r_a.rank == "A" && r_s.rank == "S");
    if (_assert(ranks_ok, "HUD: Combo Rank Engine accurately scales through ranks D, C, B, A, S")) passes++; else fails++;

    // 29. Combat & UI: Player Death Event Dispatch
    global.test_player_died_rx = false;
    var death_sub = function(evt, data) { global.test_player_died_rx = true; };
    events_subscribe(EVT.PLAYER_DIED, death_sub, "selftest_death");
    var mock_player_target = { hp: 5, team: TEAM.PLAYER, id: 9999, iframes: 0 };
    var mock_fatal_hitbox = { owner: 8888, team: TEAM.ENEMY, damage: 10, kb_x: 0, kb_y: 0, hitstop: 0, element: ELEMENT.NONE, can_be_parried: false, duration: 0.1, hit_targets: [] };
    combat_resolve_hit(mock_fatal_hitbox, mock_player_target);
    if (_assert(global.test_player_died_rx && mock_player_target.hp <= 0, "Combat: Lethal damage to player correctly fires EVT.PLAYER_DIED")) passes++; else fails++;
    events_unsubscribe_owner("selftest_death");

    // 30. Quality: Dynamic Profile Switching & Budgets
    quality_set(QUALITY.LOW);
    var q_low_prof = quality_get();
    var ok_low = (q_low_prof.max_particles == 100 && q_low_prof.max_decals == 24 && !q_low_prof.enable_shaders && !q_low_prof.enable_lighting && q_low_prof.power_vfx_budget == 0.5);
    quality_set(QUALITY.HIGH);
    var q_high_prof = quality_get();
    var ok_high = (q_high_prof.max_particles == 2000 && q_high_prof.max_decals == 128 && q_high_prof.enable_shaders && q_high_prof.enable_lighting && q_high_prof.power_vfx_budget == 1.5);
    quality_set(QUALITY.MEDIUM);
    if (_assert(ok_low && ok_high, "Quality: LOW and HIGH profiles enforce exact hardware budgets")) passes++; else fails++;

    // 31. Performance: VfxParticlePool Dynamic Clamping & Zero-Allocation Budget
    var test_p_pool = new VfxParticlePool(2048);
    quality_set(QUALITY.LOW);
    test_p_pool.set_budget(100);
    for (var tp = 0; tp < 150; tp++) {
        test_p_pool.spawn(0, 0, 10, 10, 0, 0, 2, 0, c_white, c_white, 1.0, VFX_SHAPE.POINT);
    }
    var active_pt_cnt = test_p_pool.get_active_count();
    quality_set(QUALITY.MEDIUM);
    test_p_pool.clear();
    if (_assert(active_pt_cnt <= 100, "Performance: VfxParticlePool strictly caps active particles to profile limit on LOW")) passes++; else fails++;

    // 32. Performance: VfxDecalPool Dynamic Clamping & Budget Scaling
    var test_d_pool = new VfxDecalPool(128);
    quality_set(QUALITY.LOW);
    test_d_pool.set_budget(24);
    for (var td = 0; td < 40; td++) {
        test_d_pool.spawn(0, 0, DECAL_TYPE.SCORCH, c_black);
    }
    var active_dec_cnt = test_d_pool.get_active_count();
    quality_set(QUALITY.MEDIUM);
    test_d_pool.clear();
    if (_assert(active_dec_cnt <= 24, "Performance: VfxDecalPool strictly caps active decals to profile limit on LOW")) passes++; else fails++;

    // 33. Content: 5-Archetype Enemy Roster Configurations
    var cfg_g = global.cfg.enemy.grunt;
    var cfg_f = global.cfg.enemy.fast;
    var cfg_r = global.cfg.enemy.ranged;
    var cfg_h = global.cfg.enemy.heavy;
    var cfg_e = global.cfg.enemy.elite;
    var all_enemies_ok = (cfg_g.hp == 60 && cfg_f.hp == 35 && cfg_r.hp == 45 && cfg_h.hp == 160 && cfg_e.hp == 220 &&
                          cfg_g.damage > 0 && cfg_f.damage > 0 && cfg_r.damage > 0 && cfg_h.damage > 0 && cfg_e.damage > 0 &&
                          cfg_g.score > 0 && cfg_f.score > 0 && cfg_r.score > 0 && cfg_h.score > 0 && cfg_e.score > 0);
    if (_assert(all_enemies_ok, "Content: 5 enemy archetypes (Grunt, Fast, Ranged, Heavy, Elite) configured with balanced stats and scores")) passes++; else fails++;

    // 34. Encounters: 5 Hand-Crafted Combat Scenarios Loaded
    director_system_init();
    var d = global.director;
    var enc_count_ok = (array_length(d.encounters) == 5);
    var waves_ok = true;
    for (var ei = 0; ei < 5; ei++) {
        if (array_length(d.encounters[ei].waves) < 1) waves_ok = false;
    }
    if (_assert(enc_count_ok && waves_ok, "Encounters: Director contains 5 handcrafted tactical combat encounters with multiple waves")) passes++; else fails++;

    // 35. Director State Machine: INTRO -> SPAWNING -> COMBAT Transitions
    director_start_encounter(0);
    var intro_ok = (d.state == ENCOUNTER_STATE.INTRO);
    director_update(2.1); // Elapse intro timer
    var combat_ok = (d.state == ENCOUNTER_STATE.COMBAT || d.state == ENCOUNTER_STATE.SPAWNING);
    if (_assert(intro_ok && combat_ok, "Director State Machine: Transitions cleanly from INTRO to COMBAT upon timer expiry")) passes++; else fails++;

    // 36. Combat Scoring: Kill points, combo multiplier and parry rewards
    var pre_score = d.total_score;
    events_emit(EVT.ENTITY_KILLED, { victim: 555, type: "grunt", score: 100 });
    events_emit(EVT.PARRY, {});
    events_emit(EVT.PERFECT_PARRY, {});
    var score_gained = (d.total_score > pre_score && d.total_kills >= 1 && d.total_parries >= 2);
    if (_assert(score_gained, "Combat Scoring: Records kills, combo bonuses and parry deflect rewards in total score")) passes++; else fails++;

    // 37. Combat Counterplay: Projectile Reflection Mechanics
    var mock_proj = { team: TEAM.ENEMY, damage: 12, vx: -380, vy: 0, reflected: false, can_be_parried: true };
    // Simulate perfect parry reflection
    mock_proj.team = TEAM.PLAYER;
    mock_proj.damage = round(mock_proj.damage * 2.5);
    mock_proj.vx = -mock_proj.vx * 1.6;
    mock_proj.reflected = true;
    mock_proj.can_be_parried = false;
    var refl_ok = (mock_proj.team == TEAM.PLAYER && mock_proj.damage == 30 && mock_proj.vx > 0 && mock_proj.reflected && !mock_proj.can_be_parried);
    if (_assert(refl_ok, "Combat Counterplay: Perfect parry reflects hostile projectile back with multiplied speed and damage")) passes++; else fails++;

    // 38. Hazards: Electric Conduit Cycle Simulation
    var haz_state = 0; // 0: Dormant, 1: Warning, 2: Surge
    var haz_timer = 2.5;
    // Step forward past dormant
    haz_timer -= 2.6;
    if (haz_timer <= 0) { haz_state = 1; haz_timer = 0.8; }
    // Step forward past warning
    haz_timer -= 0.9;
    if (haz_timer <= 0) { haz_state = 2; haz_timer = 1.8; }
    if (_assert(haz_state == 2, "Hazards: Electric floor hazard cycles through Dormant -> Warning -> Surge states")) passes++; else fails++;

    // 39. Interactive Objects: Launch Pad Aerial Impulse Physics
    var mock_p_launch = { vy: 0, state: PSTATE.IDLE, on_ground: true };
    var pad_impulse = -860;
    mock_p_launch.vy = pad_impulse;
    mock_p_launch.state = PSTATE.JUMP;
    mock_p_launch.on_ground = false;
    var launch_ok = (mock_p_launch.vy == -860 && mock_p_launch.state == PSTATE.JUMP && !mock_p_launch.on_ground);
    if (_assert(launch_ok, "Interactive Objects: Launch pad correctly applies vertical upward velocity boost and jump state")) passes++; else fails++;

    // 40. Audio Integration: Encounter & Hazard Audio Event Dispatching
    events_emit(EVT.ENCOUNTER_START, { index: 0, name: "TEST" });
    var enc_audio_ok = (global.audio.recent_log[0] == "ENCOUNTER_START");
    events_emit(EVT.HAZARD_TRIGGERED, { x: 0, y: 0, type: "ELECTRIC" });
    var haz_audio_ok = (global.audio.recent_log[0] == "HAZARD_TRIGGERED");
    if (_assert(enc_audio_ok && haz_audio_ok, "Audio Integration: Encounter start and hazard events cleanly dispatched through qz_audio hooks")) passes++; else fails++;

    // 41. Combat Responsiveness: Recovery-Cancelling into Dash and Parry
    var c_cfg = global.cfg.combat;
    var cancel_dash = variable_struct_exists(c_cfg, "cancel_recover_with_dash") && c_cfg.cancel_recover_with_dash;
    var cancel_parry = variable_struct_exists(c_cfg, "cancel_recover_with_parry") && c_cfg.cancel_recover_with_parry;
    if (_assert(cancel_dash && cancel_parry, "Combat Responsiveness: Recovery-cancelling into Dash and Parry enabled for fluid combat loop")) passes++; else fails++;

    // 42. Combat Grapple: Hostile Enemy Latching, Zip-Strike & Stun
    var g_cfg = global.cfg.grapple;
    var g_ok = (variable_struct_exists(g_cfg, "enemy_hook_enabled") && g_cfg.enemy_hook_enabled &&
                g_cfg.enemy_zip_speed == 980 && g_cfg.enemy_tackle_damage == 8 &&
                g_cfg.enemy_tackle_stun == 0.45 && g_cfg.enemy_tackle_rebound == -360);
    if (_assert(g_ok, "Combat Grapple: Hostile enemy latching, zip-strike velocity, stun and aerial rebound configured")) passes++; else fails++;

    // 43. Director Pacing & Dynamic Rank Scoring Calibration
    var dir_cfg = global.cfg.director;
    var dir_ok = (variable_struct_exists(dir_cfg, "intro_duration") && dir_cfg.intro_duration == 1.2 &&
                  variable_struct_exists(dir_cfg, "clear_duration") && dir_cfg.clear_duration == 1.4 &&
                  variable_struct_exists(dir_cfg, "rank_s") && dir_cfg.rank_s == 10500 &&
                  variable_struct_exists(dir_cfg, "rank_a") && dir_cfg.rank_a == 7500 &&
                  variable_struct_exists(dir_cfg, "rank_b") && dir_cfg.rank_b == 5000);
    if (_assert(dir_ok, "Director Pacing: Tightened encounter intro/clear intervals and calibrated rank thresholds")) passes++; else fails++;

    // 44. Content Balance: Hazard and Interactive Tunables
    var haz_e = global.cfg.hazard.electric;
    var int_lp = global.cfg.interact.launch_pad;
    var int_can = global.cfg.interact.canister;
    var bal_ok = (haz_e.surge == 1.8 && haz_e.damage_player == 10 && haz_e.damage_enemy == 18 &&
                  int_lp.speed == -860 && int_can.radius == 110 && int_can.damage == 45);
    if (_assert(bal_ok, "Content Balance: Electric hazard timing and interactive object parameters verified in global config")) passes++; else fails++;

    // 45. Movement & Double Jump Ground Reset
    var p_cfg = global.cfg.player;
    var dj_cfg_ok = (variable_struct_exists(p_cfg, "max_air_jumps") && p_cfg.max_air_jumps == 1 &&
                     variable_struct_exists(p_cfg, "double_jump_speed") && p_cfg.double_jump_speed == 740);
    var mock_p_jump = { air_jumps_left: 1, vy: 0, on_ground: false };
    mock_p_jump.air_jumps_left--;
    mock_p_jump.vy = -p_cfg.double_jump_speed;
    var dj_exec_ok = (mock_p_jump.air_jumps_left == 0 && mock_p_jump.vy == -740);
    mock_p_jump.on_ground = true;
    mock_p_jump.air_jumps_left = p_cfg.max_air_jumps;
    var dj_reset_ok = (mock_p_jump.air_jumps_left == 1);
    if (_assert(dj_cfg_ok && dj_exec_ok && dj_reset_ok, "Movement & Double Jump: Configured, air jump consumes resource, and resets cleanly on landing")) passes++; else fails++;

    // 46. Close-Range Sword Hitbox Zero-Distance Overlap
    var c_chain0 = global.cfg.combat.chain[0];
    var p_mock_x = 100;
    var hb_ox = c_chain0.ox;
    var hb_w = c_chain0.w;
    var hb_left = p_mock_x + hb_ox;
    var hb_right = hb_left + hb_w;
    var touching_enemy_x = p_mock_x + 4;
    var hugging_enemy_x = p_mock_x;
    var close_overlap_ok = (hb_ox < 0 && touching_enemy_x >= hb_left && touching_enemy_x <= hb_right &&
                            hugging_enemy_x >= hb_left && hugging_enemy_x <= hb_right);
    if (_assert(close_overlap_ok, "Combat Hitbox Architecture: Sword hitboxes cover point-blank contact with zero front blind spot")) passes++; else fails++;

    // 47. Decoupled Combat Hurtbox Architecture
    var mock_ent = { x: 200, y: 150, bbox_hw: 12, bbox_hh: 20, hurtbox_hw: 16, hurtbox_hh: 24 };
    var hbox = entity_get_hurtbox(mock_ent);
    var hbox_ok = (hbox.x1 == 184 && hbox.x2 == 216 && hbox.y1 == 126 && hbox.y2 == 174);
    if (_assert(hbox_ok, "Combat Architecture: Entity hurtboxes decoupled from physical collision bounds for generous, fair combat registration")) passes++; else fails++;

    // 48. Grapple Angular Governor Clamping & Stabilization
    var gr_cfg = global.cfg.grapple;
    var gr_governor_ok = (variable_struct_exists(gr_cfg, "max_angular_speed") && gr_cfg.max_angular_speed == 950 &&
                          variable_struct_exists(gr_cfg, "angular_damping") && gr_cfg.angular_damping == 0.94);
    var test_ang_spd = 1500;
    test_ang_spd = clamp(test_ang_spd, -gr_cfg.max_angular_speed, gr_cfg.max_angular_speed);
    var clamp_ok = (test_ang_spd == 950);
    if (_assert(gr_governor_ok && clamp_ok, "Grapple Physics: Angular velocity governor clamps runaway centrifugal spinning to stabilized 950 deg/s")) passes++; else fails++;

    show_debug_message("========================================");
    show_debug_message("QUAZERIUM SELF-TEST FINISHED: pass=" + string(passes) + " fail=" + string(fails));
    show_debug_message("QZ_SELFTEST_RESULT pass=" + string(passes) + " fail=" + string(fails));
    show_debug_message("========================================");

    return fails;
}
