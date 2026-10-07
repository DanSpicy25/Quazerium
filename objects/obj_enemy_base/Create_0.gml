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

blackboard = new Blackboard();
blackboard.set("target", noone);

