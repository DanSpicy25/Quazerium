// =====================================================================
// QUAZERIUM — OBJ_ENEMY_BASE: AI update & physics
// =====================================================================

var dt = qz_dt();
if (dt <= 0) exit;

// 1. Timers
element_update_entity(id, dt);
if (iframes > 0) iframes = max(0, iframes - dt);
if (hitstun > 0) hitstun = max(0, hitstun - dt);
if (hit_flash > 0) hit_flash = max(0, hit_flash - dt);
if (attack_cd_timer > 0) attack_cd_timer = max(0, attack_cd_timer - dt);
if (jump_cd_timer > 0) jump_cd_timer = max(0, jump_cd_timer - dt);

// 2. Stun state takes top priority
if (stun_timer > 0) {
    stun_timer -= dt;
    state = ESTATE.STUNNED;
    vx = qz_approach(vx, 0, 1500 * dt);
}

// 3. State machine logic
if (state != ESTATE.STUNNED) {
    var p = instance_nearest(x, y, obj_player);
    var dist_to_p = (p != noone) ? point_distance(x, y, p.x, p.y) : 99999;

    switch (state) {
        case ESTATE.IDLE:
            vx = qz_approach(vx, 0, accel_val * dt);
            if (p != noone && dist_to_p <= aggro_range) {
                state = ESTATE.CHASE;
            }
            break;

        case ESTATE.CHASE:
            if (p == noone || dist_to_p > aggro_range * 1.5) {
                state = ESTATE.IDLE;
            } else {
                facing = (p.x < x) ? -1 : 1;
                if (dist_to_p <= attack_range && attack_cd_timer <= 0) {
                    state = ESTATE.WINDUP;
                    windup_timer = windup_val;
                    events_emit(EVT.ENEMY_ATTACK_WINDUP, id);
                } else {
                    if (keep_dist > 0 && dist_to_p < keep_dist) {
                        vx = qz_approach(vx, -facing * speed_val, accel_val * dt);
                    } else {
                        vx = qz_approach(vx, facing * speed_val, accel_val * dt);
                    }

                    // Jump obstacle navigation: if blocked by a wall or target is above on an arena platform
                    if (p != noone && instance_exists(p) && on_ground && jump_cd_timer <= 0 && (p.y < y - 28 || (facing > 0 && on_wall_right) || (facing < 0 && on_wall_left))) {
                        vy = -540;
                        on_ground = false;
                        jump_cd_timer = 0.8;
                    }
                }
            }
            break;

        case ESTATE.WINDUP:
            vx = qz_approach(vx, 0, 3000 * dt);
            windup_timer -= dt;
            if (windup_timer <= 0) {
                state = ESTATE.ATTACK;
                attack_timer = active_val;
                events_emit(EVT.ENEMY_ATTACK, id);

                if (is_callable(attack_execute_fn)) {
                    attack_execute_fn();
                } else {
                    var ox = (facing > 0) ? x + 10 : x - 10 - atk_w_val;
                    hitbox_spawn(id, TEAM.ENEMY, ox, y - 15, atk_w_val, atk_h_val,
                                 damage_val, kb_val * facing, -kb_up_val,
                                 hitstop_val, element_status, true, attack_timer);
                }
            }
            break;

        case ESTATE.ATTACK:
            attack_timer -= dt;
            if (attack_timer <= 0) {
                state = ESTATE.RECOVER;
                recover_timer = recover_val;
            }
            break;

        case ESTATE.RECOVER:
            recover_timer -= dt;
            if (recover_timer <= 0) {
                state = ESTATE.IDLE;
                attack_cd_timer = attack_cooldown_val;
            }
            break;
    }
}

// 4. Gravity & Physics
vy += global.cfg.physics.gravity * dt;
if (vy > global.cfg.physics.max_fall) vy = global.cfg.physics.max_fall;

physics_move_and_collide(id, dt);

// 5. Death
if (hp <= 0) {
    state = ESTATE.DEAD;
    events_emit(EVT.ENTITY_KILLED, { victim: id, type: name, score: score_val, x: x, y: y });
    instance_destroy();
}

