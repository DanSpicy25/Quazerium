// =====================================================================
// QUAZERIUM — GRAPPLE: Dynamic spring-pendulum grappling hook.
// Mechanics: F = -k*x - c*v (damped spring), pendulum swing, reel & sling.
// =====================================================================

function GrappleController(player_inst) constructor {
    player = player_inst;
    state = GRAPPLE_STATE.IDLE;
    target_anchor = noone;
    hook_x = 0;
    hook_y = 0;
    target_x = 0;
    target_y = 0;
    rest_len = 0;
    current_len = 0;

    static find_target = function(aim_x, aim_y) {
        var cfg = global.cfg.grapple;
        var best_anchor = noone;
        var best_score = 999999;

        var aim_dir = point_direction(player.x, player.y, aim_x, aim_y);

        with (obj_grapple_anchor) {
            var d = point_distance(other.player.x, other.player.y, x, y);
            if (d <= cfg.range) {
                var dir = point_direction(other.player.x, other.player.y, x, y);
                var diff = abs(angle_difference(aim_dir, dir));
                if (diff <= cfg.cone_deg) {
                    var score_val = d + (diff * 2);
                    if (score_val < best_score) {
                        best_score = score_val;
                        best_anchor = id;
                    }
                }
            }
        }
        return best_anchor;
    };

    static fire = function(aim_x, aim_y) {
        var anchor = find_target(aim_x, aim_y);
        if (anchor == noone) {
            // If no anchor within cone, target straight in aim direction if within range
            var d = point_distance(player.x, player.y, aim_x, aim_y);
            if (d > global.cfg.grapple.range) {
                var dir = point_direction(player.x, player.y, aim_x, aim_y);
                aim_x = player.x + lengthdir_x(global.cfg.grapple.range, dir);
                aim_y = player.y + lengthdir_y(global.cfg.grapple.range, dir);
            }
            target_x = aim_x;
            target_y = aim_y;
            target_anchor = noone;
        } else {
            target_anchor = anchor;
            target_x = anchor.x;
            target_y = anchor.y;
        }

        hook_x = player.x;
        hook_y = player.y;
        state = GRAPPLE_STATE.FIRING;
        events_emit(EVT.GRAPPLE_FIRE, { player: player, target_x: target_x, target_y: target_y });
    };

    static update = function(dt) {
        var cfg = global.cfg.grapple;

        switch (state) {
            case GRAPPLE_STATE.IDLE:
                break;

            case GRAPPLE_STATE.FIRING:
                var fly_dist = cfg.hook_speed * dt;
                var dist_to_target = point_distance(hook_x, hook_y, target_x, target_y);
                if (dist_to_target <= fly_dist) {
                    hook_x = target_x;
                    hook_y = target_y;
                    if (target_anchor != noone) {
                        // Attached!
                        state = GRAPPLE_STATE.ATTACHED;
                        current_len = point_distance(player.x, player.y, hook_x, hook_y);
                        rest_len = current_len;
                        events_emit(EVT.GRAPPLE_ATTACH, { player: player, anchor: target_anchor, x: hook_x, y: hook_y });
                    } else {
                        // Hit nothing -> retract
                        state = GRAPPLE_STATE.RETRACTING;
                    }
                } else {
                    var dir = point_direction(hook_x, hook_y, target_x, target_y);
                    hook_x += lengthdir_x(fly_dist, dir);
                    hook_y += lengthdir_y(fly_dist, dir);
                }
                break;

            case GRAPPLE_STATE.ATTACHED:
                current_len = point_distance(player.x, player.y, hook_x, hook_y);
                var rope_dir = point_direction(player.x, player.y, hook_x, hook_y);

                // Spring physics: F = -k*x - c*v
                var stretch = current_len - rest_len;
                if (stretch > 0) {
                    // Velocity projection along rope axis
                    var v_proj = (player.vx * lengthdir_x(1, rope_dir)) + (player.vy * lengthdir_y(1, rope_dir));
                    var spring_f = (cfg.stiffness * stretch) + (cfg.damping * v_proj);

                    player.vx += lengthdir_x(spring_f * dt, rope_dir);
                    player.vy += lengthdir_y(spring_f * dt, rope_dir);

                    // Hard stretch constraint
                    var max_allowed = rest_len * cfg.max_stretch;
                    if (current_len > max_allowed) {
                        current_len = max_allowed;
                    }
                }

                // Player swing control
                var inp_x = input_axis_x();
                if (inp_x != 0) {
                    var perp_dir = rope_dir + (inp_x > 0 ? 90 : -90);
                    player.vx += lengthdir_x(cfg.swing_accel * dt, perp_dir);
                    player.vy += lengthdir_y(cfg.swing_accel * dt, perp_dir);
                }

                // Reel in
                if (input_check(ACTION.GRAPPLE) || input_check(ACTION.MOVE_UP)) {
                    rest_len = max(cfg.min_length, rest_len - (cfg.reel_speed * dt));
                }
                break;

            case GRAPPLE_STATE.RETRACTING:
                var ret_speed = cfg.hook_speed * 1.5 * dt;
                var dist_to_player = point_distance(hook_x, hook_y, player.x, player.y);
                if (dist_to_player <= ret_speed) {
                    state = GRAPPLE_STATE.IDLE;
                } else {
                    var rdir = point_direction(hook_x, hook_y, player.x, player.y);
                    hook_x += lengthdir_x(ret_speed, rdir);
                    hook_y += lengthdir_y(ret_speed, rdir);
                }
                break;
        }
    };

    static release = function(sling = false) {
        if (state == GRAPPLE_STATE.ATTACHED) {
            var cfg = global.cfg.grapple;
            if (sling) {
                // Impart sling jump boost
                player.vx *= cfg.sling_boost;
                player.vy = min(player.vy, -cfg.sling_up);
                events_emit(EVT.GRAPPLE_SLING, { player: player, vx: player.vx, vy: player.vy });
            } else {
                events_emit(EVT.GRAPPLE_RELEASE, { player: player });
            }
        }
        state = GRAPPLE_STATE.IDLE;
        target_anchor = noone;
    };
}

