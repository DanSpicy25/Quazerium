// =====================================================================
// QUAZERIUM — OBJ_ENEMY_BASE: Base enemy entity with AI state machine.
// Compatible with Blackboard and Behavior Trees.
// =====================================================================

team = TEAM.ENEMY;
state = ESTATE.IDLE;
name = "Enemy";

var cfg = global.cfg.enemy.grunt;
hp = cfg.hp;
max_hp = cfg.hp;
vx = 0;
vy = 0;
facing = -1;
bbox_hw = cfg.hw;
bbox_hh = cfg.hh;
on_ground = false;
on_wall_left = false;
on_wall_right = false;

element_status = ELEMENT.NONE;
element_timer = 0;
hitstun = 0;
stun_timer = 0;
iframes = 0;
hit_flash = 0;
kb_resist = cfg.kb_resist;

aggro_range = cfg.aggro_range;
attack_range = cfg.attack_range;
windup_val = cfg.windup;
active_val = cfg.active;
recover_val = cfg.recover;
attack_cooldown_val = cfg.attack_cooldown;
atk_w_val = cfg.atk_w;
atk_h_val = cfg.atk_h;
score_val = variable_struct_exists(cfg, "score") ? cfg.score : 100;
keep_dist = variable_struct_exists(cfg, "keep_dist") ? cfg.keep_dist : 0;
projectile_speed = variable_struct_exists(cfg, "projectile_speed") ? cfg.projectile_speed : 380;

attack_cd_timer = 0;
windup_timer = 0;
attack_timer = 0;
recover_timer = 0;

speed_val = cfg.speed;
accel_val = cfg.accel;
damage_val = cfg.damage;
kb_val = cfg.kb;
kb_up_val = cfg.kb_up;
hitstop_val = cfg.hitstop;

attack_execute_fn = function() {
    var ox = (facing > 0) ? x + 10 : x - 10 - atk_w_val;
    hitbox_spawn(id, TEAM.ENEMY, ox, y - 15, atk_w_val, atk_h_val,
                 damage_val, kb_val * facing, -kb_up_val,
                 hitstop_val, element_status, true, attack_timer);
};

draw_body_fn = undefined;

blackboard = new Blackboard();
blackboard.set("target", noone);

