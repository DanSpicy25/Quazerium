// =====================================================================
// QUAZERIUM — OBJ_PLAYER: Main FSM update & kinematic integration
// =====================================================================

var dt = qz_dt();
if (dt <= 0) exit;

var pcfg = global.cfg.player;
var ccfg = global.cfg.combat;

// 1. Timers & Cooldowns
if (iframes > 0) iframes = max(0, iframes - dt);
dash_cd.tick(dt);
for (var i = 0; i < POWER_ID.COUNT; i++) power_cooldowns[i].tick(dt);
if (wall_jump_lock_timer > 0) wall_jump_lock_timer -= dt;
element_update_entity(id, dt);
stat_mods.update(dt);

if (combo_timer > 0) {
    combo_timer -= dt;
    if (combo_timer <= 0) combo_count = 0;
}

// 2. Overdrive update & activation
if (overdrive_active) {
    overdrive_timer -= dt;
    if (overdrive_timer <= 0) {
        overdrive_active = false;
        stat_mods.remove("overdrive");
        events_emit(EVT.OVERDRIVE_END, id);
    }
} else if (energy >= global.cfg.energy.max && input_check_pressed(ACTION.OVERDRIVE)) {
    energy = 0;
    overdrive_active = true;
    overdrive_timer = global.cfg.overdrive.duration;
    stat_mods.add("overdrive", "damage_mult", 1.6, 0, overdrive_timer);
    stat_mods.add("overdrive", "speed_mult", 1.2, 0, overdrive_timer);
    stat_mods.add("overdrive", "dash_cd_mult", 0.5, 0, overdrive_timer);
    stat_mods.add("overdrive", "air_dashes", 1, 1, overdrive_timer);
    events_emit(EVT.OVERDRIVE, id);
}

// 3. Element cycle (Tab)
if (input_check_pressed(ACTION.ELEMENT)) {
    var cur_idx = 0;
    for (var i = 0; i < array_length(global.cfg.elements.cycle); i++) {
        if (global.cfg.elements.cycle[i] == active_element) cur_idx = i;
    }
    var next_idx = (cur_idx + 1) mod array_length(global.cfg.elements.cycle);
    active_element = global.cfg.elements.cycle[next_idx];
    events_emit(EVT.ELEMENT_CHANGED, { player: id, element: active_element });
}

// 4. Power cycle & activation (1, 2, 3 or Q/F)
if (input_check_pressed(ACTION.POWER_SELECT)) {
    if (keyboard_check_pressed(ord("1"))) selected_power_id = POWER_ID.SHOCKWAVE;
    if (keyboard_check_pressed(ord("2"))) selected_power_id = POWER_ID.BLADE_SURGE;
    if (keyboard_check_pressed(ord("3"))) selected_power_id = POWER_ID.BLINK;
    events_emit(EVT.POWER_SELECTED, selected_power_id);
}

if (input_check_pressed(ACTION.POWER)) {
    power_try_activate(id, selected_power_id);
}

// Update active power lifecycle (e.g. Blade Surge)
var cur_pow = power_get(active_power_id);
if (cur_pow != undefined) {
    cur_pow.update(id, dt);
}

// 5. Ground / Coyote / Jump Buffers
if (on_ground) {
    coyote_timer = pcfg.coyote_time;
    air_dashes_left = stat_mods.evaluate("air_dashes", pcfg.air_dashes);
} else {
    coyote_timer = max(0, coyote_timer - dt);
}

if (input_check_pressed(ACTION.JUMP)) {
    jump_buffer_timer = pcfg.jump_buffer;
} else if (jump_buffer_timer > 0) {
    jump_buffer_timer -= dt;
}

// 6. Grapple trigger & update
if (input_check_pressed(ACTION.GRAPPLE)) {
    grapple.fire(input_aim_x(), input_aim_y());
}
grapple.update(dt);

if (grapple.state == GRAPPLE_STATE.ATTACHED) {
    state = PSTATE.HOOK;
    if (input_check_pressed(ACTION.JUMP)) {
        grapple.release(true); // sling jump!
        state = PSTATE.JUMP;
    } else if (input_check_released(ACTION.GRAPPLE)) {
        grapple.release(false);
        state = PSTATE.FALL;
    }
}

// 7. Input reading for horizontal movement
var move_inp = 0;
if (wall_jump_lock_timer <= 0) {
    move_inp = input_axis_x();
    if (move_inp != 0) facing = sign(move_inp);
}

var max_run = stat_mods.evaluate("speed_mult", pcfg.run_speed);

// 8. FSM STATE LOGIC
switch (state) {
    case PSTATE.IDLE:
    case PSTATE.RUN:
    case PSTATE.JUMP:
    case PSTATE.FALL:
        // Horizontal acceleration / deceleration
        if (move_inp != 0) {
            var accel = on_ground ? pcfg.ground_accel : pcfg.air_accel;
            if (sign(vx) != sign(move_inp) && vx != 0) accel *= pcfg.turn_mult;
            vx = qz_approach(vx, move_inp * max_run, accel * dt);
        } else {
            var decel = on_ground ? pcfg.ground_decel : pcfg.air_decel;
            vx = qz_approach(vx, 0, decel * dt);
        }

        // Jump execution
        if (jump_buffer_timer > 0 && coyote_timer > 0) {
            jump_buffer_timer = 0;
            coyote_timer = 0;
            vy = -pcfg.jump_speed;
            state = PSTATE.JUMP;
            squash_x = 0.75;
            squash_y = 1.35;
            events_emit(EVT.JUMP, { player: id, x: x, y: y + bbox_hh });
        }

        // Variable jump cut
        if (state == PSTATE.JUMP && !input_check(ACTION.JUMP) && vy < 0) {
            vy *= pcfg.jump_cut;
        }

        // Wall-Tech: slide & jump
        var wall_dir = interaction_apply_wall_slide(id, dt);
        if (wall_dir != 0 && jump_buffer_timer > 0) {
            jump_buffer_timer = 0;
            interaction_wall_jump(id, wall_dir);
            state = PSTATE.JUMP;
            squash_x = 0.8;
            squash_y = 1.3;
        }

        // Dash trigger
        if (input_check_pressed(ACTION.DASH) && dash_cd.ready()) {
            if (on_ground || air_dashes_left > 0) {
                if (!on_ground) air_dashes_left--;
                dash_cd.start(stat_mods.evaluate("dash_cd_mult", 1.0));
                state = PSTATE.DASH;
                dash_timer = pcfg.dash_time;
                iframes = pcfg.dash_time + pcfg.dash_iframes_extra;

                // 8-way dash direction determination
                var ax = input_axis_x();
                var ay = input_axis_y();
                if (ax == 0 && ay == 0) ax = facing;
                var dlen = point_distance(0, 0, ax, ay);
                dash_dir_x = ax / dlen;
                dash_dir_y = ay / dlen;
                events_emit(EVT.DASH, { player: id, dir_x: dash_dir_x, dir_y: dash_dir_y });
            }
        }

        // Slam trigger (Down + Dash, or Down + Attack in air)
        if (!on_ground && input_check(ACTION.MOVE_DOWN) && (input_check_pressed(ACTION.DASH) || input_check_pressed(ACTION.ATTACK))) {
            state = PSTATE.SLAM;
            slam_hang_timer = pcfg.slam_hang;
            vx = 0;
            vy = 0;
            squash_x = 0.70;
            squash_y = 1.40;
        }

        // Attack trigger / Charging
        if (input_check(ACTION.ATTACK)) {
            charge_timer += dt;
            if (charge_timer >= ccfg.charge_time) is_charging = true;
        }
        if (input_check_released(ACTION.ATTACK)) {
            state = PSTATE.ATTACK;
            attack_phase = "windup";
            if (is_charging) {
                // Charged attack!
                attack_phase_timer = ccfg.charged.windup;
                is_charging = false;
                charge_timer = 0;
            } else {
                // Normal combo chain attack
                attack_step = (combo_count) mod array_length(ccfg.chain);
                attack_phase_timer = ccfg.chain[attack_step].windup;
            }
            events_emit(EVT.PLAYER_ATTACK, { player: id, step: attack_step, charged: is_charging });
        }

        // Parry trigger
        if (input_check_pressed(ACTION.PARRY)) {
            state = PSTATE.PARRY;
            is_parrying = true;
            parry_timer = 0;
            vx *= 0.2;
            events_emit(EVT.PARRY, id);
        }

        // State update based on physics
        if (state != PSTATE.DASH && state != PSTATE.SLAM && state != PSTATE.ATTACK && state != PSTATE.PARRY && state != PSTATE.HOOK) {
            if (on_ground) {
                state = (abs(vx) > 15) ? PSTATE.RUN : PSTATE.IDLE;
            } else {
                state = (vy < 0) ? PSTATE.JUMP : PSTATE.FALL;
            }
        }
        break;

    case PSTATE.DASH:
        dash_timer -= dt;
        vx = dash_dir_x * pcfg.dash_speed;
        vy = dash_dir_y * pcfg.dash_speed;
        if (dash_timer <= 0) {
            vx *= pcfg.dash_exit_mult;
            vy *= pcfg.dash_exit_mult;
            state = on_ground ? PSTATE.IDLE : PSTATE.FALL;
        }
        break;

    case PSTATE.SLAM:
        if (slam_hang_timer > 0) {
            slam_hang_timer -= dt;
            vx = 0;
            vy = 0;
        } else {
            vx = 0;
            vy = pcfg.slam_speed;
            if (on_ground) {
                // Land slam shockwave
                var r = pcfg.slam_radius;
                hitbox_spawn(id, TEAM.PLAYER, x - r, y - r, r * 2, r * 2,
                             pcfg.slam_damage, 0, -pcfg.slam_knockback, 0.08, active_element, false, 0.1);
                squash_x = 1.60;
                squash_y = 0.50;
                events_emit(EVT.SLAM, { player: id, x: x, y: y });
                events_emit(EVT.LAND, { player: id, vy: pcfg.slam_speed });
                state = PSTATE.IDLE;
            }
        }
        break;

    case PSTATE.ATTACK:
        var atk_spec = (charge_timer > 0) ? ccfg.charged : ccfg.chain[attack_step];
        attack_phase_timer -= dt;

        if (attack_phase == "windup") {
            vx = qz_approach(vx, facing * atk_spec.lunge, 4000 * dt);
            if (attack_phase_timer <= 0) {
                attack_phase = "active";
                attack_phase_timer = atk_spec.active;

                // Spawn attack hitbox
                var hx = (facing > 0) ? x + atk_spec.ox : x - atk_spec.ox - atk_spec.w;
                var hy = y + atk_spec.oy - (atk_spec.h / 2);
                hitbox_spawn(id, TEAM.PLAYER, hx, hy, atk_spec.w, atk_spec.h,
                             atk_spec.damage, atk_spec.kb * facing, -atk_spec.kb_up,
                             atk_spec.hitstop, active_element, true, atk_spec.active);
            }
        } else if (attack_phase == "active") {
            if (attack_phase_timer <= 0) {
                attack_phase = "recover";
                attack_phase_timer = atk_spec.recover;
            }
        } else if (attack_phase == "recover") {
            vx = qz_approach(vx, 0, 3000 * dt);
            if (attack_phase_timer <= 0) {
                state = on_ground ? PSTATE.IDLE : PSTATE.FALL;
                attack_phase = "none";
            }
        }
        break;

    case PSTATE.PARRY:
        parry_timer += dt;
        is_parrying = true;
        vx = qz_approach(vx, 0, 4000 * dt);
        if (parry_timer >= global.cfg.parry.window + global.cfg.parry.recover) {
            is_parrying = false;
            state = on_ground ? PSTATE.IDLE : PSTATE.FALL;
        }
        break;

    case PSTATE.HOOK:
        // Movement is handled by grapple spring & physics
        break;
}

// 9. Gravity calculation
if (state != PSTATE.DASH && state != PSTATE.SLAM && state != PSTATE.HOOK) {
    var g = global.cfg.physics.gravity;
    if (vy > 0) g *= pcfg.fall_gravity_mult;
    else if (abs(vy) < pcfg.apex_threshold) g *= pcfg.apex_gravity_mult;

    if (state == PSTATE.ATTACK && !on_ground) g *= ccfg.air_attack_gravity_mult;

    vy += g * dt;
    if (vy > global.cfg.physics.max_fall) vy = global.cfg.physics.max_fall;
}

// 10. Kinematic sub-stepped collision resolution
physics_move_and_collide(id, dt);

// 11. Presentation & Animation Updates
if (on_ground && !was_on_ground) {
    squash_x = 1.35;
    squash_y = 0.70;
    events_emit(EVT.LAND, { player: id, vy: vy });
}
was_on_ground = on_ground;

squash_x = qz_approach(squash_x, 1.0, 3.5 * dt);
squash_y = qz_approach(squash_y, 1.0, 3.5 * dt);

if (state == PSTATE.RUN) {
    run_anim_t += dt * 14.0;
} else {
    run_anim_t = 0;
}

var max_ai = quality_get().trail_segments;
for (var a = 0; a < max_ai; a++) {
    var ai = afterimages[a];
    if (ai.active) {
        ai.alpha -= 4.0 * dt;
        if (ai.alpha <= 0) ai.active = false;
    }
}

if (state == PSTATE.DASH || (overdrive_active && (abs(vx) > 100 || abs(vy) > 100))) {
    afterimage_timer -= dt;
    if (afterimage_timer <= 0) {
        afterimage_timer = 0.04;
        afterimage_head = (afterimage_head + 1) mod max_ai;
        var ai_spawn = afterimages[afterimage_head];
        ai_spawn.active = true;
        ai_spawn.x = x;
        ai_spawn.y = y;
        ai_spawn.facing = facing;
        ai_spawn.alpha = 0.65;
        ai_spawn.color = overdrive_active ? c_yellow : (active_element != ELEMENT.NONE ? c_orange : c_aqua);
    }
}

