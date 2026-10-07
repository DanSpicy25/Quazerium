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

// Two-hit blade strike: Staggered double slash rhythm
attack_execute_fn = function() {
    var ox = (facing > 0) ? x + 10 : x - 10 - atk_w_val;
    // Hitbox 1: Cross slash (Immediate primary strike)
    hitbox_spawn(id, TEAM.ENEMY, ox, y - 16, atk_w_val, atk_h_val,
                 damage_val * 0.6, kb_val * 0.5 * facing, -kb_up_val * 0.5,
                 hitstop_val, element_status, true, 0.08, 0);

    // Forward kinetic surge
    vx = facing * 320;

    // Hitbox 2: Twin Saber Upper Strike (120ms delayed secondary strike for parry/dash cadence)
    var ox2 = (facing > 0) ? x + 16 : x - 16 - (atk_w_val * 1.1);
    hitbox_spawn(id, TEAM.ENEMY, ox2, y - 22, atk_w_val * 1.1, atk_h_val * 1.2,
                 damage_val * 0.8, kb_val * facing, -kb_up_val * 1.2,
                 hitstop_val * 1.2, element_status, true, 0.10, 0.12);
};

draw_body_fn = function(c_body, c_rim) {
    // Apex Golden-Crowned Stickman with dual energy sabers
    var c_gold_crest = make_color_rgb(255, 215, 0);
    var c_saber      = make_color_rgb(255, 60, 80);

    var eh_x   = x;
    var eh_y   = y - (bbox_hh * 0.65);
    var eh_r   = 7.0;
    var e_neck = eh_y + eh_r;
    var e_hip_y = y + (bbox_hh * 0.22);
    var e_sh_w = 11;
    var e_sh_y = e_neck + 3;
    var e_hp_w = 8;
    var e_foot_y = y + bbox_hh;

    // Legs
    var e_hip_l = eh_x - (e_hp_w * 0.7);
    var e_hip_r = eh_x + (e_hp_w * 0.7);
    var ek1_x = e_hip_l - 3; var ek1_y = e_hip_y + 9; var ef1_x = e_hip_l - 5; var ef1_y = e_foot_y;
    var ek2_x = e_hip_r + 3; var ek2_y = e_hip_y + 9; var ef2_x = e_hip_r + 5; var ef2_y = e_foot_y;

    if (state == ESTATE.CHASE) {
        var e_walk = current_time * 0.015;
        ek1_x = e_hip_l + (sin(e_walk) * 8 * facing); ef1_x = e_hip_l + (sin(e_walk) * 14 * facing);
        ek2_x = e_hip_r + (sin(e_walk + pi) * 8 * facing); ef2_x = e_hip_r + (sin(e_walk + pi) * 14 * facing);
    }

    draw_set_color(c_gold_crest);
    draw_line_width(e_hip_l, e_hip_y, ek1_x, ek1_y, 3.5);
    draw_line_width(ek1_x, ek1_y, ef1_x, ef1_y, 3.0);
    draw_line_width(e_hip_r, e_hip_y, ek2_x, ek2_y, 3.5);
    draw_line_width(ek2_x, ek2_y, ef2_x, ef2_y, 3.0);
    draw_circle(ek1_x, ek1_y, 2.5, false);
    draw_circle(ek2_x, ek2_y, 2.5, false);

    // Golden Spine & Shoulders
    draw_set_color(c_gold_crest);
    draw_line_width(eh_x, e_neck, eh_x, e_hip_y, 4.0);
    draw_line_width(eh_x - e_sh_w, e_sh_y, eh_x + e_sh_w, e_sh_y, 3.5);
    draw_line_width(eh_x - e_hp_w, e_hip_y, eh_x + e_hp_w, e_hip_y, 3.0);

    // Rib crossbars
    draw_line_width(eh_x - 6, lerp(e_sh_y, e_hip_y, 0.4), eh_x + 6, lerp(e_sh_y, e_hip_y, 0.4), 2.0);
    draw_line_width(eh_x - 5, lerp(e_sh_y, e_hip_y, 0.7), eh_x + 5, lerp(e_sh_y, e_hip_y, 0.7), 2.0);

    // Head & Champion Crown
    draw_set_color(c_body);
    draw_circle(eh_x, eh_y, eh_r, false);
    draw_set_color(c_gold_crest);
    draw_circle(eh_x, eh_y, eh_r, true);

    // V-shaped champion golden crest
    draw_triangle(eh_x, eh_y - eh_r - 9, eh_x - 7, eh_y - eh_r + 1, eh_x + 7, eh_y - eh_r + 1, false);

    // Eye
    draw_set_color(c_white);
    draw_circle(eh_x + (facing * 3), eh_y, 2, false);

    // Arms Holding Twin Energy Sabers
    var sh_front = (facing > 0) ? (eh_x + e_sh_w) : (eh_x - e_sh_w);
    var sh_back  = (facing > 0) ? (eh_x - e_sh_w) : (eh_x + e_sh_w);
    var h1_x = sh_front + (facing * 10);
    var h1_y = y - 2;
    var h2_x = sh_back + (facing * 6);
    var h2_y = y + 2;

    draw_set_color(c_gold_crest);
    draw_line_width(sh_front, e_sh_y, h1_x, h1_y, 2.5);
    draw_line_width(sh_back, e_sh_y, h2_x, h2_y, 2.5);

    // Glowing energy sabers
    draw_set_color(c_saber);
    draw_line_width(h1_x, h1_y, h1_x + (facing * 18), h1_y - 12, 3.0);
    draw_line_width(h2_x, h2_y, h2_x + (facing * 14), h2_y - 8, 2.5);
    draw_set_color(c_white);
    draw_line_width(h1_x, h1_y, h1_x + (facing * 18), h1_y - 12, 1.0);
};
