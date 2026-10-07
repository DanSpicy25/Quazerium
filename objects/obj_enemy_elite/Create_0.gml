// =====================================================================
// QUAZERIUM — OBJ_ENEMY_ELITE: Apex Enforcer Automaton.
// High pressure, dual-blade flurry, gold trim and radiant energy crown.
// =====================================================================

event_inherited();

name = "Apex Enforcer";
var cfg = global.cfg.enemy.elite;
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
kb_resist = cfg.kb_resist;

// Two-hit blade strike
attack_execute_fn = function() {
    var ox = (facing > 0) ? x + 10 : x - 10 - atk_w_val;
    // Hitbox 1: Cross slash
    hitbox_spawn(id, TEAM.ENEMY, ox, y - 16, atk_w_val, atk_h_val,
                 damage_val, kb_val * facing, -kb_up_val,
                 hitstop_val, element_status, true, attack_timer);

    // Forward kinetic surge
    vx = facing * 320;
};

draw_body_fn = function(c_body, c_rim) {
    // Apex chassis with golden ornamental crest
    var c_elite_body = make_color_rgb(28, 22, 38);
    var c_gold_crest = make_color_rgb(255, 215, 0);

    draw_set_color(c_elite_body);
    draw_rectangle(x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh, false);
    draw_set_color(c_gold_crest);
    draw_rectangle(x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh, true);

    // V-shaped champion crest
    draw_set_color(c_gold_crest);
    draw_triangle(x, y - bbox_hh - 8, x - 8, y - bbox_hh + 2, x + 8, y - bbox_hh + 2, false);

    // Twin energy sabers at hip
    var saber_ox = x + (facing * 4);
    draw_set_color(make_color_rgb(255, 60, 80));
    draw_line_width(saber_ox - 4, y + 2, saber_ox + (facing * 14), y - 10, 2);
    draw_line_width(saber_ox - 6, y + 6, saber_ox + (facing * 12), y - 6, 2);

    // Dual-core reactor
    draw_set_color(c_gold_crest);
    draw_circle(x - 3, y - 2, 2.5, false);
    draw_set_color(make_color_rgb(255, 80, 80));
    draw_circle(x + 3, y - 2, 2.5, false);

    // Sensor eye
    var eye_x = x + (facing * (bbox_hw - 4));
    draw_set_color(c_white);
    draw_circle(eye_x, y - 8, 2, false);
};
