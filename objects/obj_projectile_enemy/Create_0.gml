// =====================================================================
// QUAZERIUM — OBJ_PROJECTILE_ENEMY: Plasma bolt fired by ranged foes.
// Supports trajectory flight, wall collision, and parry deflection!
// =====================================================================

team = TEAM.ENEMY;
damage = 12;
speed_val = 380;
vx = 0;
vy = 0;
bbox_r = 7;
can_be_parried = true;
reflected = false;
timer = 4.0;
element = ELEMENT.NONE;
owner = noone;
hitstop = 0.05;
hit_targets = [];
