// =====================================================================
// QUAZERIUM — OBJ_VFX: Master Presentation Visual Effects Controller.
// Listens to EVT.* and coordinates particles, combat text, decals & screen flashes.
// Performance-budgeted across LOW / MEDIUM / HIGH quality profiles.
// =====================================================================

var q = quality_get();

particle_pool = new VfxParticlePool(2048);
text_pool = new VfxCombatTextPool(32);
decal_pool = new VfxDecalPool(128);

flash_color = c_white;
flash_alpha = 0.0;
flash_decay = 8.0;

trigger_flash = function(col, a, decay_spd = 8.0) {
    if (!quality_get().enable_shaders && a > 0.3) a = 0.3; // softened for low-end
    flash_color = col;
    flash_alpha = max(flash_alpha, a);
    flash_decay = decay_spd;
};

events_subscribe(EVT.QUALITY_CHANGED, function(evt, data) {
    var prof = quality_get();
    particle_pool.set_budget(prof.max_particles);
    decal_pool.set_budget(prof.max_decals);
}, id);

// ---------------------------------------------------------------------
// 1. HIT CONFIRMED (Normal Combat Hit)
// ---------------------------------------------------------------------
events_subscribe(EVT.HIT_CONFIRMED, function(evt, data) {
    var tx = (is_struct(data.target) || instance_exists(data.target)) ? data.target.x : x;
    var ty = (is_struct(data.target) || instance_exists(data.target)) ? data.target.y : y;
    var ax = (is_struct(data.attacker) || instance_exists(data.attacker)) ? data.attacker.x : tx - 20;
    var ay = (is_struct(data.attacker) || instance_exists(data.attacker)) ? data.attacker.y : ty;

    // Visual hit flash on target entity
    if (qz_entity_exists(data.target) && qz_var_exists(data.target, "hit_flash")) {
        data.target.hit_flash = 0.08;
    }

    // Directional hit angle (from attacker to target)
    var hit_ang = point_direction(ax, ay, tx, ty);
    var b_mult = vfx_get_budget();

    // Directional impact sparks
    var spk_count = round(8 * b_mult);
    for (var i = 0; i < spk_count; i++) {
        var ang = hit_ang + random_range(-40, 40);
        var spd = random_range(160, 380);
        particle_pool.spawn(tx, ty, lengthdir_x(spd, ang), lengthdir_y(spd, ang), 0, 350,
                            2, 0.5, c_white, c_yellow, random_range(0.12, 0.24), VFX_SHAPE.STREAK, 1.0);
    }

    // Perpendicular slash cut sparks
    var cut_count = round(4 * b_mult);
    for (var j = 0; j < cut_count; j++) {
        var c_side = (j mod 2 == 0) ? 90 : -90;
        var c_ang = hit_ang + c_side + random_range(-15, 15);
        var c_spd = random_range(100, 240);
        particle_pool.spawn(tx, ty, lengthdir_x(c_spd, c_ang), lengthdir_y(c_spd, c_ang), 0, 200,
                            2.5, 0.5, c_yellow, c_orange, random_range(0.1, 0.2), VFX_SHAPE.STREAK, 0.9);
    }

    // Floating Damage Number (clean white/silver)
    text_pool.spawn(tx, ty, data.damage, c_white, 1.0, 0.7);

    // Elemental Infusion Sparks if element is active
    if (data.element != ELEMENT.NONE) {
        var c_elem1 = c_white;
        var c_elem2 = c_white;
        var shp = VFX_SHAPE.POINT;
        var elem_ay = 0;

        switch (data.element) {
            case ELEMENT.FIRE:
                c_elem1 = make_color_rgb(255, 120, 20);
                c_elem2 = c_red;
                elem_ay = -160;
                shp = VFX_SHAPE.DUST;
                break;
            case ELEMENT.WATER:
                c_elem1 = make_color_rgb(40, 180, 255);
                c_elem2 = c_aqua;
                elem_ay = 200;
                shp = VFX_SHAPE.DUST;
                break;
            case ELEMENT.EARTH:
                c_elem1 = make_color_rgb(200, 140, 60);
                c_elem2 = make_color_rgb(130, 80, 30);
                elem_ay = 400;
                shp = VFX_SHAPE.SHARD;
                break;
            case ELEMENT.WIND:
                c_elem1 = make_color_rgb(100, 255, 180);
                c_elem2 = c_white;
                elem_ay = 0;
                shp = VFX_SHAPE.STREAK;
                break;
        }

        var elem_count = round(6 * b_mult);
        for (var k = 0; k < elem_count; k++) {
            var e_ang = random(360);
            var e_spd = random_range(80, 220);
            particle_pool.spawn(tx, ty, lengthdir_x(e_spd, e_ang), lengthdir_y(e_spd, e_ang), 0, elem_ay,
                                3, 0.8, c_elem1, c_elem2, 0.3, shp, 0.95);
        }
    }
}, id);

// ---------------------------------------------------------------------
// 2. HIT CRITICAL (Overdrive Hit / High Power Reaction)
// ---------------------------------------------------------------------
events_subscribe(EVT.HIT_CRITICAL, function(evt, data) {
    var tx = (is_struct(data.target) || instance_exists(data.target)) ? data.target.x : x;
    var ty = (is_struct(data.target) || instance_exists(data.target)) ? data.target.y : y;
    var ax = (is_struct(data.attacker) || instance_exists(data.attacker)) ? data.attacker.x : tx - 20;
    var ay = (is_struct(data.attacker) || instance_exists(data.attacker)) ? data.attacker.y : ty;

    // Visual hit flash on target entity (intense)
    if (qz_entity_exists(data.target) && qz_var_exists(data.target, "hit_flash")) {
        data.target.hit_flash = 0.16;
    }

    var hit_ang = point_direction(ax, ay, tx, ty);
    var b_mult = vfx_get_budget();

    // Golden Spark dual-cone burst along slash arc
    var spk_count = round(20 * b_mult);
    for (var i = 0; i < spk_count; i++) {
        var ang = hit_ang + random_range(-55, 55);
        var spd = random_range(200, 520);
        particle_pool.spawn(tx, ty, lengthdir_x(spd, ang), lengthdir_y(spd, ang), 0, 250,
                            3, 0.5, c_white, c_yellow, random_range(0.18, 0.36), VFX_SHAPE.STREAK, 1.0);
    }

    // Expanding Golden Shockwave Ring
    particle_pool.spawn(tx, ty, 0, 0, 0, 0, 8, 56, c_yellow, c_orange, 0.20, VFX_SHAPE.RING, 1.0);

    // High Hierarchy Damage Text (CRIT badge in gold)
    text_pool.spawn(tx, ty, "CRIT " + string(data.damage), make_color_rgb(255, 220, 40), 1.4, 0.9);

    // Screen flash & Slash Decal
    trigger_flash(make_color_rgb(255, 230, 80), 0.22, 10.0);
    decal_pool.spawn(tx, ty, DECAL_TYPE.SLASH, make_color_rgb(180, 30, 30), hit_ang, 20);
}, id);

// ---------------------------------------------------------------------
// 3. PARRY (Standard Aegis Deflection)
// ---------------------------------------------------------------------
events_subscribe(EVT.PARRY, function(evt, data) {
    var def_x = (is_struct(data.defender) || instance_exists(data.defender)) ? data.defender.x : x;
    var def_y = (is_struct(data.defender) || instance_exists(data.defender)) ? data.defender.y : y;

    // Expanding Cyan Ring + Deflection Sparks
    particle_pool.spawn(def_x, def_y, 0, 0, 0, 0, 10, 65, c_aqua, c_white, 0.22, VFX_SHAPE.RING, 1.0);
    for (var i = 0; i < 14; i++) {
        var ang = random_range(-60, 60);
        var spd = random_range(220, 440);
        particle_pool.spawn(def_x, def_y, lengthdir_x(spd, ang), lengthdir_y(spd, ang), 0, 0,
                            2.5, 0.5, c_white, c_aqua, 0.25, VFX_SHAPE.STREAK, 1.0);
    }
    text_pool.spawn(def_x, def_y - 20, "PARRY!", c_aqua, 1.25, 0.85);
}, id);

// ---------------------------------------------------------------------
// 4. PERFECT PARRY (High Resonance Counter)
// ---------------------------------------------------------------------
events_subscribe(EVT.PERFECT_PARRY, function(evt, data) {
    var def_x = (is_struct(data.defender) || instance_exists(data.defender)) ? data.defender.x : x;
    var def_y = (is_struct(data.defender) || instance_exists(data.defender)) ? data.defender.y : y;

    // Dual Golden & Cyan Shockwave Rings
    particle_pool.spawn(def_x, def_y, 0, 0, 0, 0, 12, 120, c_yellow, c_white, 0.32, VFX_SHAPE.RING, 1.0);
    particle_pool.spawn(def_x, def_y, 0, 0, 0, 0, 6, 85, c_white, c_aqua, 0.26, VFX_SHAPE.RING, 0.9);

    // 360-degree radiant streak blast
    var count = round(28 * vfx_get_budget());
    for (var i = 0; i < count; i++) {
        var ang = random(360);
        var spd = random_range(260, 580);
        particle_pool.spawn(def_x, def_y, lengthdir_x(spd, ang), lengthdir_y(spd, ang), 0, 0,
                            3, 0.5, c_white, c_yellow, 0.35, VFX_SHAPE.STREAK, 1.0);
    }
    trigger_flash(c_white, 0.38, 5.0);
    text_pool.spawn(def_x, def_y - 28, "PERFECT PARRY!", make_color_rgb(255, 215, 0), 1.55, 1.15);
}, id);

// ---------------------------------------------------------------------
// 5. POWERS (Shockwave, Blade Surge, Blink)
// ---------------------------------------------------------------------
events_subscribe(EVT.POWER, function(evt, data) {
    var pid = data.power_id;
    var b_mult = vfx_get_budget();

    switch (pid) {
        case POWER_ID.SHOCKWAVE:
            var px = variable_struct_exists(data, "x") ? data.x : (instance_exists(data.player) ? data.player.x : x);
            var py = variable_struct_exists(data, "y") ? data.y : (instance_exists(data.player) ? data.player.y : y);
            var r = variable_struct_exists(data, "radius") ? data.radius : 80;

            // Expanding electric shockwave ring
            particle_pool.spawn(px, py, 0, 0, 0, 0, 10, r * 1.5, c_aqua, c_white, 0.30, VFX_SHAPE.RING, 1.0);
            particle_pool.spawn(px, py, 0, 0, 0, 0, 6, r, c_white, c_yellow, 0.22, VFX_SHAPE.RING, 0.85);

            // 360-degree radial blast streaks
            var sw_count = round(24 * b_mult);
            for (var i = 0; i < sw_count; i++) {
                var ang = random(360);
                var spd = random_range(180, 480);
                particle_pool.spawn(px, py, lengthdir_x(spd, ang), lengthdir_y(spd, ang), 0, 150,
                                    3, 0.5, c_white, c_aqua, 0.28, VFX_SHAPE.STREAK, 1.0);
            }

            // Ground crack decal directly beneath player
            decal_pool.spawn(px, py + 16, DECAL_TYPE.CRACK, c_black, 0, 24);

            // Lateral dust billows
            for (var d = 0; d < 8; d++) {
                var d_dir = (d mod 2 == 0) ? -1 : 1;
                particle_pool.spawn(px, py + 16, d_dir * random_range(80, 240), random_range(-20, -60), 0, 180,
                                    5, 1, c_ltgray, c_dkgray, 0.35, VFX_SHAPE.DUST, 0.75);
            }

            trigger_flash(c_aqua, 0.22, 10.0);
            text_pool.spawn(px, py - 36, "SHOCKWAVE!", c_aqua, 1.4, 0.9);
            break;

        case POWER_ID.BLADE_SURGE:
            var sx = variable_struct_exists(data, "x") ? data.x : (instance_exists(data.player) ? data.player.x : x);
            var sy = variable_struct_exists(data, "y") ? data.y : (instance_exists(data.player) ? data.player.y : y);
            var fdir = variable_struct_exists(data, "facing") ? data.facing : 1;

            // Supersonic conical cutting streaks along surge vector
            var bs_count = round(18 * b_mult);
            for (var b = 0; b < bs_count; b++) {
                var b_ang = (fdir > 0) ? random_range(-25, 25) : random_range(155, 205);
                var b_spd = random_range(300, 750);
                particle_pool.spawn(sx, sy, lengthdir_x(b_spd, b_ang), lengthdir_y(b_spd, b_ang), 0, 0,
                                    3.5, 0.5, c_white, c_aqua, 0.22, VFX_SHAPE.STREAK, 1.0);
            }

            // Ground slash decal along trajectory
            decal_pool.spawn(sx + (fdir * 20), sy + 16, DECAL_TYPE.SLASH, c_red, (fdir > 0 ? 0 : 180), 22);

            trigger_flash(c_white, 0.18, 14.0);
            text_pool.spawn(sx, sy - 30, "BLADE SURGE!", c_white, 1.35, 0.85);
            break;

        case POWER_ID.BLINK:
            var start_x = variable_struct_exists(data, "start_x") ? data.start_x : x;
            var start_y = variable_struct_exists(data, "start_y") ? data.start_y : y;
            var end_x   = variable_struct_exists(data, "end_x") ? data.end_x : (instance_exists(data.player) ? data.player.x : x);
            var end_y   = variable_struct_exists(data, "end_y") ? data.end_y : (instance_exists(data.player) ? data.player.y : y);

            // 1. Departure collapse particles (quantum implosion)
            particle_pool.spawn(start_x, start_y, 0, 0, 0, 0, 24, 2, c_aqua, c_white, 0.18, VFX_SHAPE.RING, 0.9);
            for (var dp = 0; dp < 8; dp++) {
                var d_ang = random(360);
                var d_spd = random_range(-120, -40); // inward velocity
                particle_pool.spawn(start_x + lengthdir_x(20, d_ang), start_y + lengthdir_y(20, d_ang),
                                    lengthdir_x(d_spd, d_ang), lengthdir_y(d_spd, d_ang), 0, 0,
                                    2.5, 0.5, c_aqua, c_white, 0.2, VFX_SHAPE.POINT, 0.9);
            }

            // 2. Quantum Displacement Beam (streaks connecting origin to destination)
            var beam_dist = point_distance(start_x, start_y, end_x, end_y);
            var beam_steps = clamp(round(beam_dist / 32), 3, 10);
            for (var bm = 0; bm <= beam_steps; bm++) {
                var bt = bm / beam_steps;
                var bx = lerp(start_x, end_x, bt);
                var by = lerp(start_y, end_y, bt);
                particle_pool.spawn(bx, by, random_range(-20, 20), random_range(-20, 20), 0, 0,
                                    2, 0.5, c_white, c_aqua, 0.15, VFX_SHAPE.POINT, 0.8);
            }

            // 3. Arrival explosion (quantum flash)
            particle_pool.spawn(end_x, end_y, 0, 0, 0, 0, 8, 48, c_white, c_aqua, 0.20, VFX_SHAPE.RING, 1.0);
            for (var ap = 0; ap < 12; ap++) {
                var a_ang = random(360);
                var a_spd = random_range(100, 320);
                particle_pool.spawn(end_x, end_y, lengthdir_x(a_spd, a_ang), lengthdir_y(a_spd, a_ang), 0, 0,
                                    2.5, 0.5, c_white, c_aqua, 0.22, VFX_SHAPE.STREAK, 1.0);
            }

            trigger_flash(c_aqua, 0.15, 14.0);
            text_pool.spawn(end_x, end_y - 28, "BLINK!", make_color_rgb(180, 240, 255), 1.2, 0.7);
            break;
    }
}, id);

// Power End (Blade Surge brake sparks)
events_subscribe(EVT.POWER_END, function(evt, data) {
    if (data.power_id == POWER_ID.BLADE_SURGE && instance_exists(data.player)) {
        var px = data.player.x;
        var py = data.player.y + data.player.bbox_hh;
        for (var i = 0; i < 6; i++) {
            particle_pool.spawn(px, py, random_range(-100, 100), random_range(-20, -60), 0, 150,
                                4, 1, c_ltgray, c_dkgray, 0.25, VFX_SHAPE.DUST, 0.6);
        }
    }
}, id);

// ---------------------------------------------------------------------
// 6. DASH & SLAM
// ---------------------------------------------------------------------
events_subscribe(EVT.DASH, function(evt, data) {
    var px = (is_struct(data.player) || instance_exists(data.player)) ? data.player.x : x;
    var py = (is_struct(data.player) || instance_exists(data.player)) ? data.player.y : y;

    for (var i = 0; i < 6; i++) {
        var vx = -data.dir_x * random_range(40, 160) + random_range(-20, 20);
        var vy = -data.dir_y * random_range(40, 160) + random_range(-20, 20);
        particle_pool.spawn(px, py + 8, vx, vy, 0, -20, 5, 1, c_ltgray, c_dkgray, 0.25, VFX_SHAPE.DUST, 0.7);
    }
}, id);

events_subscribe(EVT.SLAM, function(evt, data) {
    var sx = data.x;
    var sy = data.y;

    // Shockwave Ring + Dust Waves
    particle_pool.spawn(sx, sy, 0, 0, 0, 0, 10, 95, c_white, c_gray, 0.25, VFX_SHAPE.RING, 0.9);
    for (var i = 0; i < 16; i++) {
        var dir = (i mod 2 == 0) ? -1 : 1;
        var spd = random_range(100, 320) * dir;
        particle_pool.spawn(sx, sy, spd, random_range(-40, -120), 0, 400,
                            6, 1, c_ltgray, c_dkgray, random_range(0.2, 0.45), VFX_SHAPE.DUST, 0.8);
    }
    decal_pool.spawn(sx, sy, DECAL_TYPE.CRACK, c_black, 0, 24);
    trigger_flash(c_white, 0.18, 12.0);
}, id);

// ---------------------------------------------------------------------
// 7. ELEMENTAL SYSTEMS (Applied & 6 Reaction Signatures)
// ---------------------------------------------------------------------
events_subscribe(EVT.ELEMENT_APPLIED, function(evt, data) {
    var tx = (is_struct(data.target) || instance_exists(data.target)) ? data.target.x : x;
    var ty = (is_struct(data.target) || instance_exists(data.target)) ? data.target.y : y;

    var c_col = c_white;
    switch (data.element) {
        case ELEMENT.FIRE:  c_col = make_color_rgb(255, 120, 20); break;
        case ELEMENT.WATER: c_col = make_color_rgb(40, 180, 255); break;
        case ELEMENT.EARTH: c_col = make_color_rgb(200, 140, 60); break;
        case ELEMENT.WIND:  c_col = make_color_rgb(100, 255, 180); break;
    }

    for (var i = 0; i < 4; i++) {
        particle_pool.spawn(tx, ty - 8, random_range(-30, 30), random_range(-40, -80), 0, -50,
                            3, 1, c_col, c_white, 0.35, VFX_SHAPE.POINT, 0.85);
    }
}, id);

events_subscribe(EVT.ELEMENT_REACTION, function(evt, data) {
    var tx = (is_struct(data.target) || instance_exists(data.target)) ? data.target.x : x;
    var ty = (is_struct(data.target) || instance_exists(data.target)) ? data.target.y : y;

    var r_name = data.reaction.name;
    var c_banner = c_white;
    var b_mult = vfx_get_budget();

    switch (r_name) {
        case "VAPORIZE": // Fire + Water: Boiling steam clouds + dual ring
            c_banner = make_color_rgb(255, 130, 40);
            particle_pool.spawn(tx, ty, 0, 0, 0, 0, 10, 85, c_banner, c_aqua, 0.30, VFX_SHAPE.RING, 1.0);
            for (var v = 0; v < round(18 * b_mult); v++) {
                particle_pool.spawn(tx, ty, random_range(-120, 120), random_range(-100, -220), 0, -80,
                                    7, 2, c_white, c_ltgray, 0.45, VFX_SHAPE.DUST, 0.8);
            }
            break;

        case "FREEZE": // Water + Wind: Ice crystal shards + frost ring
            c_banner = make_color_rgb(120, 230, 255);
            particle_pool.spawn(tx, ty, 0, 0, 0, 0, 8, 70, c_white, c_aqua, 0.28, VFX_SHAPE.RING, 1.0);
            for (var f = 0; f < round(16 * b_mult); f++) {
                var f_ang = random(360);
                var f_spd = random_range(100, 320);
                particle_pool.spawn(tx, ty, lengthdir_x(f_spd, f_ang), lengthdir_y(f_spd, f_ang), 0, 120,
                                    4, 1, c_white, c_aqua, 0.35, VFX_SHAPE.SHARD, 1.0);
            }
            trigger_flash(c_aqua, 0.20, 12.0);
            break;

        case "SWIRL": // Fire + Wind: Whirling fire cyclone streaks
            c_banner = make_color_rgb(120, 255, 180);
            for (var s = 0; s < round(20 * b_mult); s++) {
                var s_ang = random(360);
                var s_spd = random_range(160, 420);
                particle_pool.spawn(tx, ty, lengthdir_x(s_spd, s_ang), lengthdir_y(s_spd, s_ang), 0, 0,
                                    3, 0.5, make_color_rgb(255, 120, 20), c_lime, 0.35, VFX_SHAPE.STREAK, 1.0, 300);
            }
            break;

        case "MAGMA": // Fire + Earth: Molten rock shards + ground scorch
            c_banner = make_color_rgb(255, 80, 20);
            for (var m = 0; m < round(16 * b_mult); m++) {
                var m_ang = random_range(30, 150); // upward volcanic spray
                var m_spd = random_range(140, 380);
                particle_pool.spawn(tx, ty, lengthdir_x(m_spd, m_ang), -m_spd, 0, 450,
                                    4.5, 1.5, c_orange, c_red, 0.45, VFX_SHAPE.SHARD, 1.0);
            }
            decal_pool.spawn(tx, ty + 16, DECAL_TYPE.SCORCH, c_black, 0, 20);
            break;

        case "MUD": // Water + Earth: Sludge droplets + heavy drip
            c_banner = make_color_rgb(160, 120, 60);
            for (var mu = 0; mu < round(14 * b_mult); mu++) {
                particle_pool.spawn(tx, ty, random_range(-80, 80), random_range(-40, 40), 0, 350,
                                    5, 1, make_color_rgb(140, 90, 40), make_color_rgb(80, 50, 20), 0.4, VFX_SHAPE.DUST, 0.85);
            }
            break;

        case "EROSION": // Earth + Wind: Shattered rock debris + double shockwave
            c_banner = make_color_rgb(210, 210, 110);
            particle_pool.spawn(tx, ty, 0, 0, 0, 0, 10, 90, c_banner, c_white, 0.32, VFX_SHAPE.RING, 1.0);
            for (var er = 0; er < round(18 * b_mult); er++) {
                var e_ang = random(360);
                var e_spd = random_range(140, 360);
                particle_pool.spawn(tx, ty, lengthdir_x(e_spd, e_ang), lengthdir_y(e_spd, e_ang), 0, 300,
                                    3.5, 1, make_color_rgb(190, 160, 100), c_white, 0.35, VFX_SHAPE.SHARD, 1.0);
            }
            decal_pool.spawn(tx, ty + 16, DECAL_TYPE.CRACK, c_black, 0, 20);
            break;
    }

    text_pool.spawn(tx, ty - 32, r_name + "!", c_banner, 1.35, 1.0);
}, id);

// ---------------------------------------------------------------------
// 8. OVERDRIVE (Activation, Aura & Vent Exhaust)
// ---------------------------------------------------------------------
events_subscribe(EVT.OVERDRIVE, function(evt, data) {
    var px = (is_struct(data) && variable_struct_exists(data, "player") && instance_exists(data.player)) ? data.player.x :
             ((is_numeric(data) && instance_exists(data)) ? data.x : x);
    var py = (is_struct(data) && variable_struct_exists(data, "player") && instance_exists(data.player)) ? data.player.y :
             ((is_numeric(data) && instance_exists(data)) ? data.y : y);

    trigger_flash(c_yellow, 0.45, 4.0);
    text_pool.spawn(px, py - 40, "OVERDRIVE ACTIVATED!", make_color_rgb(255, 220, 0), 1.55, 1.3);

    particle_pool.spawn(px, py, 0, 0, 0, 0, 10, 140, c_yellow, c_white, 0.45, VFX_SHAPE.RING, 1.0);
    for (var i = 0; i < 30; i++) {
        var ang = random_range(60, 120); // upward plume
        var spd = random_range(180, 500);
        particle_pool.spawn(px + random_range(-16, 16), py, lengthdir_x(spd, ang), -spd, 0, -200,
                            4, 1, c_yellow, c_orange, random_range(0.3, 0.6), VFX_SHAPE.DUST, 0.85);
    }
}, id);

events_subscribe(EVT.OVERDRIVE_END, function(evt, data) {
    var px = (is_numeric(data) && instance_exists(data)) ? data.x : x;
    var py = (is_numeric(data) && instance_exists(data)) ? data.y : y;

    // Vent exhaust steam puffs from both sides
    for (var i = 0; i < 12; i++) {
        var dir = (i mod 2 == 0) ? -1 : 1;
        particle_pool.spawn(px + (dir * 12), py, dir * random_range(40, 120), random_range(-10, -40), 0, -60,
                            4, 1, c_ltgray, c_dkgray, 0.4, VFX_SHAPE.DUST, 0.6);
    }
    text_pool.spawn(px, py - 30, "OVERDRIVE EXHAUSTED", make_color_rgb(150, 180, 220), 1.1, 0.8);
}, id);

// ---------------------------------------------------------------------
// 9. ENTITY KILLED & EXECUTION
// ---------------------------------------------------------------------
events_subscribe(EVT.ENTITY_KILLED, function(evt, data) {
    var vx = (is_struct(data.victim) || instance_exists(data.victim)) ? data.victim.x : x;
    var vy = (is_struct(data.victim) || instance_exists(data.victim)) ? data.victim.y : y;

    // Shrapnel destruction explosion
    var count = round(24 * vfx_get_budget());
    for (var i = 0; i < count; i++) {
        var ang = random(360);
        var spd = random_range(160, 450);
        particle_pool.spawn(vx, vy, lengthdir_x(spd, ang), lengthdir_y(spd, ang), 0, 300,
                            3.5, 0.5, c_white, make_color_rgb(255, 60, 70), random_range(0.2, 0.45), VFX_SHAPE.SHARD, 1.0);
    }

    // Ground scorch
    decal_pool.spawn(vx, vy + 12, DECAL_TYPE.SCORCH, c_black, 0, 18);

    // Fatal Execution Banner
    text_pool.spawn(vx, vy - 24, "EXECUTION!", make_color_rgb(255, 45, 65), 1.45, 1.0);
}, id);

events_subscribe(EVT.ENERGY_FULL, function(evt, data) {
    var px = (is_numeric(data) && instance_exists(data)) ? data.x : x;
    var py = (is_numeric(data) && instance_exists(data)) ? data.y : y;
    text_pool.spawn(px, py - 36, "OVERDRIVE READY!", make_color_rgb(255, 215, 0), 1.25, 0.9);
}, id);

// ---------------------------------------------------------------------
// 10. GRAPPLE & MOVEMENT PARTICLES
// ---------------------------------------------------------------------
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
