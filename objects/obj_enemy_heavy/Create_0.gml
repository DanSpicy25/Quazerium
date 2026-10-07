// =====================================================================
// QUAZERIUM — OBJ_ENEMY_HEAVY: Armored Juggernaut Automaton.
// Massive armor, high knockback resist, devastating ground slam.
// =====================================================================

event_inherited();

name = "Armored Juggernaut";
var cfg = global.cfg.enemy.heavy;
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

// Ground seismic slam
attack_execute_fn = function() {
    var ox = (facing > 0) ? x + 8 : x - 8 - atk_w_val;
    hitbox_spawn(id, TEAM.ENEMY, ox, y - 8, atk_w_val, atk_h_val,
                 damage_val, kb_val * facing, -kb_up_val,
                 hitstop_val, element_status, true, attack_timer);

    // Ground impact shock
    events_emit(EVT.SLAM, { x: x + (facing * 24), y: y + bbox_hh });
};

draw_body_fn = function(c_body, c_rim) {
    // Colossal Brute Stickman with heavy greataxe
    var eh_x   = x;
    var eh_y   = y - (bbox_hh * 0.65);
    var eh_r   = 8.0;
    var e_neck = eh_y + eh_r;
    var e_hip_y = y + (bbox_hh * 0.22);
    var e_sh_w = 14;
    var e_sh_y = e_neck + 4;
    var e_hp_w = 10;
    var e_foot_y = y + bbox_hh;

    // Legs: Thick heavy braced stick legs
    var e_hip_l = eh_x - (e_hp_w * 0.7);
    var e_hip_r = eh_x + (e_hp_w * 0.7);
    var ek1_x = e_hip_l - 4; var ek1_y = e_hip_y + 10; var ef1_x = e_hip_l - 6; var ef1_y = e_foot_y;
    var ek2_x = e_hip_r + 4; var ek2_y = e_hip_y + 10; var ef2_x = e_hip_r + 6; var ef2_y = e_foot_y;

    if (state == ESTATE.CHASE) {
        var e_stomp = current_time * 0.009;
        ek1_x = e_hip_l + (sin(e_stomp) * 6 * facing); ef1_x = e_hip_l + (sin(e_stomp) * 11 * facing);
        ek2_x = e_hip_r + (sin(e_stomp + pi) * 6 * facing); ef2_x = e_hip_r + (sin(e_stomp + pi) * 11 * facing);
    }

    draw_set_color(c_rim);
    draw_line_width(e_hip_l, e_hip_y, ek1_x, ek1_y, 4.5);
    draw_line_width(ek1_x, ek1_y, ef1_x, ef1_y, 4.0);
    draw_line_width(e_hip_r, e_hip_y, ek2_x, ek2_y, 4.5);
    draw_line_width(ek2_x, ek2_y, ef2_x, ef2_y, 4.0);
    draw_circle(ek1_x, ek1_y, 3.0, false);
    draw_circle(ek2_x, ek2_y, 3.0, false);

    // Thick Basalt Spine & Shoulders
    draw_set_color(c_rim);
    draw_line_width(eh_x, e_neck, eh_x, e_hip_y, 5.5);
    draw_line_width(eh_x - e_sh_w, e_sh_y, eh_x + e_sh_w, e_sh_y, 4.5);
    draw_line_width(eh_x - e_hp_w, e_hip_y, eh_x + e_hp_w, e_hip_y, 3.5);

    // Heavy Pauldron Plates at Shoulder Tips
    draw_set_color(make_color_rgb(60, 30, 36));
    draw_circle(eh_x - e_sh_w, e_sh_y, 4.5, false);
    draw_circle(eh_x + e_sh_w, e_sh_y, 4.5, false);
    draw_set_color(c_rim);
    draw_circle(eh_x - e_sh_w, e_sh_y, 4.5, true);
    draw_circle(eh_x + e_sh_w, e_sh_y, 4.5, true);

    // Iron Rib Cage
    draw_line_width(eh_x - 8, lerp(e_sh_y, e_hip_y, 0.35), eh_x + 8, lerp(e_sh_y, e_hip_y, 0.35), 3.0);
    draw_line_width(eh_x - 7, lerp(e_sh_y, e_hip_y, 0.65), eh_x + 7, lerp(e_sh_y, e_hip_y, 0.65), 3.0);

    // Head: Fortified Skull Helmet with Visor
    draw_set_color(c_body);
    draw_circle(eh_x, eh_y, eh_r, false);
    draw_set_color(c_rim);
    draw_circle(eh_x, eh_y, eh_r, true);

    // Glowing Blast Visor
    var visor_x = eh_x + (facing * 4);
    draw_set_color(make_color_rgb(255, 120, 20));
    draw_line_width(visor_x - 4, eh_y, visor_x + 4, eh_y, 2.5);

    // Arms Holding Heavy Greataxe
    var sh_front = (facing > 0) ? (eh_x + e_sh_w) : (eh_x - e_sh_w);
    var ax_hand_x = sh_front + (facing * 10);
    var ax_hand_y = y - 2;
    var ax_head_x = ax_hand_x + (facing * 14);
    var ax_head_y = ax_hand_y - 10;

    draw_set_color(c_rim);
    draw_line_width(sh_front, e_sh_y, ax_hand_x, ax_hand_y, 3.5);
    // Heavy axe haft
    draw_set_color(make_color_rgb(70, 50, 40));
    draw_line_width(ax_hand_x - (facing * 6), ax_hand_y + 12, ax_head_x, ax_head_y, 3.0);
    // Double-headed axe blade
    draw_set_color(c_rim);
    draw_triangle(ax_head_x, ax_head_y - 8, ax_head_x + (facing * 10), ax_head_y - 4, ax_head_x, ax_head_y, false);
    draw_triangle(ax_head_x, ax_head_y, ax_head_x + (facing * 10), ax_head_y + 4, ax_head_x, ax_head_y + 8, false);
    draw_set_color(c_white);
    draw_line(ax_head_x + (facing * 10), ax_head_y - 4, ax_head_x + (facing * 10), ax_head_y + 4);
};
