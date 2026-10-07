// =====================================================================
// QUAZERIUM — OBJ_ENEMY_FAST: High-mobility skirmisher.
// Quick dash lunges, low HP, punishes poor spacing.
// =====================================================================

event_inherited();

name = "Skirmisher";
var cfg = global.cfg.enemy.fast;
hp = cfg.hp;
max_hp = cfg.hp;
bbox_hw = cfg.hw;
bbox_hh = cfg.hh;
speed_val = cfg.speed;
accel_val = cfg.accel;
aggro_range = cfg.aggro_range;
attack_range = cfg.attack_range;
windup_val = cfg.windup;
active_val = cfg.active;
recover_val = cfg.recover;
attack_cooldown_val = cfg.attack_cooldown;
damage_val = cfg.damage;
kb_val = cfg.kb;
kb_up_val = cfg.kb_up;
atk_w_val = cfg.atk_w;
atk_h_val = cfg.atk_h;
hitstop_val = cfg.hitstop;
score_val = cfg.score;

// Skirmisher attack: quick lunge forward
attack_execute_fn = function() {
    vx = facing * 460;
    var ox = (facing > 0) ? x + 6 : x - 6 - atk_w_val;
    hitbox_spawn(id, TEAM.ENEMY, ox, y - 12, atk_w_val, atk_h_val,
                 damage_val, kb_val * facing, -kb_up_val,
                 hitstop_val, element_status, true, attack_timer);
};

draw_body_fn = function(c_body, c_rim) {
    var front_x = x + (facing * bbox_hw);
    var back_x  = x - (facing * bbox_hw);
    var top_y   = y - bbox_hh;
    var bot_y   = y + bbox_hh;

    draw_set_color(c_body);
    draw_triangle(front_x, y, back_x, top_y, back_x, bot_y, false);
    draw_set_color(c_rim);
    draw_triangle(front_x, y, back_x, top_y, back_x, bot_y, true);

    // Dual forward plasma blades
    draw_set_color(make_color_rgb(255, 210, 40));
    draw_line_width(front_x, y - 4, front_x + (facing * 8), y - 2, 2);
    draw_line_width(front_x, y + 4, front_x + (facing * 8), y + 2, 2);

    // Center optical sensor
    draw_set_color(c_white);
    draw_circle(x, y, 2.5, false);
};
