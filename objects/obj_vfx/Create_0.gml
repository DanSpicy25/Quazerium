// =====================================================================
// QUAZERIUM — OBJ_VFX: Master Presentation Visual Effects Controller.
// Listens to EVT.* and coordinates particles, combat text, decals & screen flashes.
// =====================================================================

var q = quality_get();

particle_pool = new VfxParticlePool(q.max_particles);
text_pool = new VfxCombatTextPool(32);
decal_pool = new VfxDecalPool(clamp(round(q.max_particles / 15), 16, 64));

flash_color = c_white;
flash_alpha = 0.0;
flash_decay = 8.0;

trigger_flash = function(col, a, decay_spd = 8.0) {
    if (!quality_get().enable_shaders && a > 0.3) a = 0.3; // softened for low-end
    flash_color = col;
    flash_alpha = max(flash_alpha, a);
    flash_decay = decay_spd;
};

// 1. Hit Confirmed
events_subscribe(EVT.HIT_CONFIRMED, function(evt, data) {
    var tx = (is_struct(data.target) || instance_exists(data.target)) ? data.target.x : x;
    var ty = (is_struct(data.target) || instance_exists(data.target)) ? data.target.y : y;

    // Sparks
    var spk_count = (global.quality_level == QUALITY.LOW) ? 5 : 12;
    for (var i = 0; i < spk_count; i++) {
        var ang = random(360);
        var spd = random_range(120, 340);
        particle_pool.spawn(tx, ty, lengthdir_x(spd, ang), lengthdir_y(spd, ang), 0, 400,
                            2, 0.5, c_white, c_yellow, random_range(0.1, 0.25), VFX_SHAPE.STREAK, 1.0);
    }

    // Damage Number
    text_pool.spawn(tx, ty, data.damage, c_white, 1.0, 0.7);

    // Elemental Sparks if any
    if (data.element != ELEMENT.NONE) {
        var c_elem = c_white;
        switch (data.element) {
            case ELEMENT.FIRE:  c_elem = c_orange; break;
            case ELEMENT.WATER: c_elem = c_aqua; break;
            case ELEMENT.EARTH: c_elem = make_color_rgb(180, 130, 70); break;
            case ELEMENT.WIND:  c_elem = c_lime; break;
        }
        for (var k = 0; k < 6; k++) {
            var e_ang = random(360);
            var e_spd = random_range(60, 200);
            particle_pool.spawn(tx, ty, lengthdir_x(e_spd, e_ang), lengthdir_y(e_spd, e_ang), 0, 150,
                                3, 1, c_elem, c_white, 0.3, VFX_SHAPE.POINT, 0.9);
        }
    }
}, id);

// 2. Hit Critical
events_subscribe(EVT.HIT_CRITICAL, function(evt, data) {
    var tx = (is_struct(data.target) || instance_exists(data.target)) ? data.target.x : x;
    var ty = (is_struct(data.target) || instance_exists(data.target)) ? data.target.y : y;

    // Golden Spark burst + Ring
    var spk_count = (global.quality_level == QUALITY.LOW) ? 8 : 22;
    for (var i = 0; i < spk_count; i++) {
        var ang = random(360);
        var spd = random_range(180, 480);
        particle_pool.spawn(tx, ty, lengthdir_x(spd, ang), lengthdir_y(spd, ang), 0, 300,
                            3, 0.5, c_white, c_yellow, random_range(0.15, 0.35), VFX_SHAPE.STREAK, 1.0);
    }
    particle_pool.spawn(tx, ty, 0, 0, 0, 0, 8, 48, c_yellow, c_orange, 0.18, VFX_SHAPE.RING, 1.0);

    // Damage text
    text_pool.spawn(tx, ty, "CRIT " + string(data.damage), make_color_rgb(255, 220, 50), 1.35, 0.9);

    // Screen flash & Slash Decal
    trigger_flash(c_yellow, 0.22, 10.0);
    decal_pool.spawn(tx, ty, DECAL_TYPE.SLASH, c_red, random(360), 18, quality_get().decal_life);
}, id);

// 3. Parry
events_subscribe(EVT.PARRY, function(evt, data) {
    var def_x = (is_struct(data.defender) || instance_exists(data.defender)) ? data.defender.x : x;
    var def_y = (is_struct(data.defender) || instance_exists(data.defender)) ? data.defender.y : y;

    // Expanding Cyan Ring + Deflection Sparks
    particle_pool.spawn(def_x, def_y, 0, 0, 0, 0, 10, 60, c_aqua, c_white, 0.22, VFX_SHAPE.RING, 1.0);
    for (var i = 0; i < 14; i++) {
        var ang = random_range(-60, 60);
        var spd = random_range(200, 400);
        particle_pool.spawn(def_x, def_y, lengthdir_x(spd, ang), lengthdir_y(spd, ang), 0, 0,
                            2, 0.5, c_white, c_aqua, 0.25, VFX_SHAPE.STREAK, 1.0);
    }
    text_pool.spawn(def_x, def_y - 20, "PARRY!", c_aqua, 1.2, 0.8);
}, id);

// 4. Perfect Parry
events_subscribe(EVT.PERFECT_PARRY, function(evt, data) {
    var def_x = (is_struct(data.defender) || instance_exists(data.defender)) ? data.defender.x : x;
    var def_y = (is_struct(data.defender) || instance_exists(data.defender)) ? data.defender.y : y;

    // Golden Shockwave Ring + 360 burst
    particle_pool.spawn(def_x, def_y, 0, 0, 0, 0, 12, 110, c_yellow, c_white, 0.32, VFX_SHAPE.RING, 1.0);
    particle_pool.spawn(def_x, def_y, 0, 0, 0, 0, 6, 80, c_white, c_yellow, 0.25, VFX_SHAPE.RING, 0.8);

    for (var i = 0; i < 28; i++) {
        var ang = random(360);
        var spd = random_range(250, 560);
        particle_pool.spawn(def_x, def_y, lengthdir_x(spd, ang), lengthdir_y(spd, ang), 0, 0,
                            3, 0.5, c_white, c_yellow, 0.35, VFX_SHAPE.STREAK, 1.0);
    }
    trigger_flash(c_white, 0.40, 5.0);
    text_pool.spawn(def_x, def_y - 28, "PERFECT PARRY!", make_color_rgb(255, 215, 0), 1.5, 1.1);
}, id);

// 5. Dash
events_subscribe(EVT.DASH, function(evt, data) {
    var px = (is_struct(data.player) || instance_exists(data.player)) ? data.player.x : x;
    var py = (is_struct(data.player) || instance_exists(data.player)) ? data.player.y : y;

    for (var i = 0; i < 6; i++) {
        var vx = -data.dir_x * random_range(40, 160) + random_range(-20, 20);
        var vy = -data.dir_y * random_range(40, 160) + random_range(-20, 20);
        particle_pool.spawn(px, py + 8, vx, vy, 0, -20, 5, 1, c_ltgray, c_dkgray, 0.25, VFX_SHAPE.DUST, 0.7);
    }
}, id);

// 6. Slam
events_subscribe(EVT.SLAM, function(evt, data) {
    var sx = data.x;
    var sy = data.y;

    // Shockwave Ring + Dust Waves
    particle_pool.spawn(sx, sy, 0, 0, 0, 0, 10, 90, c_white, c_gray, 0.25, VFX_SHAPE.RING, 0.9);
    for (var i = 0; i < 16; i++) {
        var dir = (i mod 2 == 0) ? -1 : 1;
        var spd = random_range(100, 320) * dir;
        particle_pool.spawn(sx, sy, spd, random_range(-40, -120), 0, 400,
                            6, 1, c_ltgray, c_dkgray, random_range(0.2, 0.45), VFX_SHAPE.DUST, 0.8);
    }
    decal_pool.spawn(sx, sy, DECAL_TYPE.CRACK, c_black, 0, 24, quality_get().decal_life);
    trigger_flash(c_white, 0.18, 12.0);
}, id);

// 7. Elemental Reaction
events_subscribe(EVT.ELEMENT_REACTION, function(evt, data) {
    var tx = (is_struct(data.target) || instance_exists(data.target)) ? data.target.x : x;
    var ty = (is_struct(data.target) || instance_exists(data.target)) ? data.target.y : y;

    var r_name = data.reaction.name;
    var c_banner = c_white;

    switch (r_name) {
        case "VAPORIZE": c_banner = make_color_rgb(255, 120, 40); break;
        case "FREEZE":   c_banner = make_color_rgb(100, 220, 255); break;
        case "SWIRL":    c_banner = make_color_rgb(120, 255, 180); break;
        case "MAGMA":    c_banner = make_color_rgb(255, 80, 20); break;
        case "MUD":      c_banner = make_color_rgb(160, 120, 60); break;
        case "EROSION":  c_banner = make_color_rgb(200, 200, 100); break;
    }

    text_pool.spawn(tx, ty - 32, r_name + "!", c_banner, 1.35, 1.0);
    particle_pool.spawn(tx, ty, 0, 0, 0, 0, 10, 75, c_banner, c_white, 0.28, VFX_SHAPE.RING, 1.0);

    for (var i = 0; i < 18; i++) {
        var ang = random(360);
        var spd = random_range(100, 350);
        particle_pool.spawn(tx, ty, lengthdir_x(spd, ang), lengthdir_y(spd, ang), 0, 200,
                            3, 0.5, c_banner, c_white, 0.35, VFX_SHAPE.STREAK, 1.0);
    }
}, id);

// 8. Overdrive
events_subscribe(EVT.OVERDRIVE, function(evt, data) {
    var px = (is_struct(data.player) || instance_exists(data.player)) ? data.player.x : x;
    var py = (is_struct(data.player) || instance_exists(data.player)) ? data.player.y : y;

    trigger_flash(c_yellow, 0.45, 4.0);
    text_pool.spawn(px, py - 40, "OVERDRIVE ACTIVATED!", make_color_rgb(255, 220, 0), 1.5, 1.3);

    particle_pool.spawn(px, py, 0, 0, 0, 0, 10, 140, c_yellow, c_white, 0.45, VFX_SHAPE.RING, 1.0);
    for (var i = 0; i < 30; i++) {
        var ang = random_range(60, 120); // upward plume
        var spd = random_range(180, 500);
        particle_pool.spawn(px + random_range(-16, 16), py, lengthdir_x(spd, ang), -spd, 0, -200,
                            4, 1, c_yellow, c_orange, random_range(0.3, 0.6), VFX_SHAPE.DUST, 0.85);
    }
}, id);

// 9. Grapple Attach & Sling
events_subscribe(EVT.GRAPPLE_ATTACH, function(evt, data) {
    for (var i = 0; i < 8; i++) {
        var ang = random(360);
        var spd = random_range(60, 200);
        particle_pool.spawn(data.anchor_x, data.anchor_y, lengthdir_x(spd, ang), lengthdir_y(spd, ang), 0, 0,
                            2, 0.5, c_white, c_aqua, 0.2, VFX_SHAPE.STREAK, 1.0);
    }
}, id);

events_subscribe(EVT.GRAPPLE_SLING, function(evt, data) {
    var px = (is_struct(data.player) || instance_exists(data.player)) ? data.player.x : x;
    var py = (is_struct(data.player) || instance_exists(data.player)) ? data.player.y : y;

    particle_pool.spawn(px, py, 0, 0, 0, 0, 8, 70, c_aqua, c_white, 0.22, VFX_SHAPE.RING, 0.9);
    for (var i = 0; i < 12; i++) {
        var ang = random_range(220, 320); // downward thrust
        var spd = random_range(140, 360);
        particle_pool.spawn(px, py, lengthdir_x(spd, ang), lengthdir_y(spd, ang), 0, 0,
                            3, 1, c_white, c_aqua, 0.25, VFX_SHAPE.STREAK, 0.9);
    }
}, id);

// 10. Jump, Land & Wall Jump Dust
events_subscribe(EVT.JUMP, function(evt, data) {
    var jx = is_struct(data) && variable_struct_exists(data, "x") ? data.x : x;
    var jy = is_struct(data) && variable_struct_exists(data, "y") ? data.y : y;
    for (var i = 0; i < 4; i++) {
        var spd = random_range(-60, 60);
        particle_pool.spawn(jx, jy, spd, random_range(-10, -30), 0, 80,
                            4, 1, c_ltgray, c_dkgray, 0.22, VFX_SHAPE.DUST, 0.6);
    }
}, id);

events_subscribe(EVT.LAND, function(evt, data) {
    var lx = (is_struct(data) && variable_struct_exists(data, "player") && instance_exists(data.player)) ? data.player.x : x;
    var ly = (is_struct(data) && variable_struct_exists(data, "player") && instance_exists(data.player)) ? (data.player.y + data.player.bbox_hh) : y;
    for (var i = 0; i < 8; i++) {
        var dir = (i mod 2 == 0) ? -1 : 1;
        var spd = random_range(40, 140) * dir;
        particle_pool.spawn(lx, ly, spd, random_range(-15, -40), 0, 120,
                            5, 1, c_ltgray, c_dkgray, 0.28, VFX_SHAPE.DUST, 0.65);
    }
}, id);

events_subscribe(EVT.WALL_JUMP, function(evt, data) {
    var wx = (is_struct(data) && variable_struct_exists(data, "player") && instance_exists(data.player)) ? data.player.x : x;
    var wy = (is_struct(data) && variable_struct_exists(data, "player") && instance_exists(data.player)) ? data.player.y : y;
    for (var i = 0; i < 6; i++) {
        var ang = random(360);
        var spd = random_range(60, 180);
        particle_pool.spawn(wx, wy, lengthdir_x(spd, ang), lengthdir_y(spd, ang), 0, 100,
                            2, 0.5, c_white, c_ltgray, 0.2, VFX_SHAPE.STREAK, 0.8);
    }
}, id);

