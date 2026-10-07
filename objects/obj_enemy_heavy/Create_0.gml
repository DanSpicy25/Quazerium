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
    // Heavy reinforced chassis with shoulder plating
    draw_set_color(c_body);
    draw_rectangle(x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh, false);
    draw_set_color(c_rim);
    draw_rectangle(x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh, true);

    // Heavy shoulder pauldrons
    draw_set_color(make_color_rgb(60, 30, 36));
    draw_rectangle(x - bbox_hw - 4, y - bbox_hh - 4, x - bbox_hw + 8, y - bbox_hh + 6, false);
    draw_rectangle(x + bbox_hw - 8, y - bbox_hh - 4, x + bbox_hw + 4, y - bbox_hh + 6, false);
    draw_set_color(c_rim);
    draw_rectangle(x - bbox_hw - 4, y - bbox_hh - 4, x - bbox_hw + 8, y - bbox_hh + 6, true);
    draw_rectangle(x + bbox_hw - 8, y - bbox_hh - 4, x + bbox_hw + 4, y - bbox_hh + 6, true);

    // Blast shield visor
    var visor_x = x + (facing * 6);
    draw_set_color(make_color_rgb(255, 120, 20));
    draw_line_width(visor_x - 6, y - 10, visor_x + 6, y - 10, 3);

    // Reactor vent slits
    draw_set_color(make_color_rgb(20, 24, 32));
    draw_line(x - 8, y + 2, x + 8, y + 2);
    draw_line(x - 8, y + 6, x + 8, y + 6);
};
