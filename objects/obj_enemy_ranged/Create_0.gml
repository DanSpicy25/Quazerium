// =====================================================================
// QUAZERIUM — OBJ_ENEMY_RANGED: Space-control artillery drone.
// Keeps distance, telegraphs laser line, fires parriable plasma bolts.
// =====================================================================

event_inherited();

name = "Artillery Drone";
var cfg = global.cfg.enemy.ranged;
hp = cfg.hp;
max_hp = cfg.hp;
bbox_hw = cfg.hw;
bbox_hh = cfg.hh;
speed_val = cfg.speed;
accel_val = cfg.accel;
aggro_range = cfg.aggro_range;
attack_range = cfg.attack_range;
keep_dist = cfg.keep_dist;
windup_val = cfg.windup;
active_val = cfg.active;
recover_val = cfg.recover;
attack_cooldown_val = cfg.attack_cooldown;
damage_val = cfg.damage;
kb_val = cfg.kb;
kb_up_val = cfg.kb_up;
hitstop_val = cfg.hitstop;
score_val = cfg.score;
projectile_speed = cfg.projectile_speed;

// Attack hook: fire plasma bolt
attack_execute_fn = function() {
    var spawn_x = x + (facing * 14);
    var spawn_y = y - 4;
    var proj = instance_create_layer(spawn_x, spawn_y, "Instances", obj_projectile_enemy);
    proj.owner = id;
    proj.damage = damage_val;
    proj.element = element_status;

    var p = instance_nearest(x, y, obj_player);
    if (p != noone) {
        var dir = point_direction(spawn_x, spawn_y, p.x, p.y - 10);
        proj.vx = lengthdir_x(projectile_speed, dir);
        proj.vy = lengthdir_y(projectile_speed, dir);
    } else {
        proj.vx = facing * projectile_speed;
        proj.vy = 0;
    }
};

draw_body_fn = function(c_body, c_rim) {
    // Hexagonal drone chassis
    draw_set_color(c_body);
    draw_roundrect(x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh, false);
    draw_set_color(c_rim);
    draw_roundrect(x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh, true);

    // Lateral repulsor fins
    draw_set_color(make_color_rgb(120, 140, 170));
    draw_line_width(x - bbox_hw - 4, y - 6, x - bbox_hw, y - 2, 2);
    draw_line_width(x + bbox_hw, y - 2, x + bbox_hw + 4, y - 6, 2);

    // Central aiming optical eye
    var eye_x = x + (facing * 6);
    draw_set_color(make_color_rgb(255, 30, 40));
    draw_circle(eye_x, y - 4, 3.5, false);
    draw_set_color(c_white);
    draw_circle(eye_x, y - 4, 1.5, false);

    // Predictive laser sight during windup
    if (state == ESTATE.WINDUP) {
        var p = instance_nearest(x, y, obj_player);
        if (p != noone) {
            var laser_pulse = 0.4 + (sin(current_time * 0.05) * 0.3);
            draw_set_color(make_color_rgb(255, 40, 40));
            draw_set_alpha(laser_pulse);
            draw_line_width(eye_x, y - 4, p.x, p.y - 10, 1.5);
            draw_set_alpha(1.0);
        }
    }
};
