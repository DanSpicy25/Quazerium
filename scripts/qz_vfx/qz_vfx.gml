// =====================================================================
// QUAZERIUM — VFX: Allocation-free Particle, Combat Text & Decal Systems.
// Controlled by Hardware Quality Profiles (LOW / MEDIUM / HIGH).
// Completely decoupled: listens to EVT.* and manages visual assets.
// =====================================================================

enum VFX_SHAPE { POINT, STREAK, DUST, SHARD, RING }
enum DECAL_TYPE { SCORCH, SLASH, CRACK }

/// Master Particle Pool: fixed array, zero dynamic allocations during gameplay.
function VfxParticlePool(capacity) constructor {
    max_count = capacity;
    head = 0;
    particles = array_create(capacity);

    for (var i = 0; i < capacity; i++) {
        particles[i] = {
            active: false,
            x: 0, y: 0,
            vx: 0, vy: 0,
            ax: 0, ay: 0,
            size: 2, end_size: 0,
            col_start: c_white, col_end: c_white,
            alpha: 1.0,
            life: 0.0, max_life: 1.0,
            shape: VFX_SHAPE.POINT,
            angle: 0.0, spin: 0.0
        };
    }

    static spawn = function(px, py, pvx, pvy, pax, pay, psize, pend_size, c1, c2, plife, pshape, palpha = 1.0, pspin = 0.0) {
        var p = particles[head];
        head = (head + 1) mod max_count;

        p.active = true;
        p.x = px;
        p.y = py;
        p.vx = pvx;
        p.vy = pvy;
        p.ax = pax;
        p.ay = pay;
        p.size = psize;
        p.end_size = pend_size;
        p.col_start = c1;
        p.col_end = c2;
        p.alpha = palpha;
        p.life = plife;
        p.max_life = max(0.001, plife);
        p.shape = pshape;
        p.angle = (pvy != 0 || pvx != 0) ? point_direction(0, 0, pvx, pvy) : random(360);
        p.spin = pspin;
    };

    static update = function(dt) {
        for (var i = 0; i < max_count; i++) {
            var p = particles[i];
            if (!p.active) continue;

            p.life -= dt;
            if (p.life <= 0) {
                p.active = false;
                continue;
            }

            p.vx += p.ax * dt;
            p.vy += p.ay * dt;
            p.x += p.vx * dt;
            p.y += p.vy * dt;
            p.angle += p.spin * dt;
        }
    };

    static draw = function() {
        for (var i = 0; i < max_count; i++) {
            var p = particles[i];
            if (!p.active) continue;

            var t = 1.0 - (p.life / p.max_life); // 0.0 -> 1.0
            var cur_size = lerp(p.size, p.end_size, t);
            var cur_alpha = p.alpha * (1.0 - t);
            var cur_col = merge_color(p.col_start, p.col_end, t);

            draw_set_color(cur_col);
            draw_set_alpha(cur_alpha);

            switch (p.shape) {
                case VFX_SHAPE.POINT:
                    draw_point(p.x, p.y);
                    break;

                case VFX_SHAPE.STREAK:
                    var len = max(3, point_distance(0, 0, p.vx, p.vy) * 0.04);
                    var dx = lengthdir_x(len, p.angle);
                    var dy = lengthdir_y(len, p.angle);
                    draw_line_width(p.x - dx, p.y - dy, p.x + dx, p.y + dy, max(1, cur_size));
                    break;

                case VFX_SHAPE.DUST:
                    draw_circle(p.x, p.y, max(1, cur_size), false);
                    break;

                case VFX_SHAPE.SHARD:
                    var s = cur_size;
                    var rad = degtorad(p.angle);
                    var c = cos(rad) * s;
                    var sn = sin(rad) * s;
                    draw_triangle(p.x - c, p.y - sn, p.x + sn, p.y - c, p.x + c, p.y + sn, false);
                    break;

                case VFX_SHAPE.RING:
                    draw_circle(p.x, p.y, max(1, cur_size), true);
                    break;
            }
        }
        draw_set_alpha(1.0);
    };

    static clear = function() {
        for (var i = 0; i < max_count; i++) {
            particles[i].active = false;
        }
    };
}

/// Floating Combat Text (Damage numbers, reaction titles, status cues).
function VfxCombatTextPool(capacity = 32) constructor {
    max_count = capacity;
    head = 0;
    entries = array_create(capacity);

    for (var i = 0; i < capacity; i++) {
        entries[i] = {
            active: false,
            x: 0, y: 0,
            vy: -80,
            text: "",
            color: c_white,
            scale: 1.0,
            life: 0.0,
            max_life: 0.8
        };
    }

    static spawn = function(px, py, txt, col, pscale = 1.0, plife = 0.75) {
        // Anti-overlap: check existing active entries near px, py
        var overlap_count = 0;
        for (var i = 0; i < max_count; i++) {
            var ent = entries[i];
            if (ent.active && point_distance(ent.x, ent.y, px, py) < 28) {
                overlap_count++;
            }
        }

        var e = entries[head];
        head = (head + 1) mod max_count;

        e.active = true;
        e.x = px + random_range(-8, 8);
        e.y = py - 10 - (overlap_count * 14);
        e.vy = -110 - (overlap_count * 10);
        e.text = string(txt);
        e.color = col;
        e.scale = pscale;
        e.life = plife;
        e.max_life = max(0.001, plife);
    };

    static update = function(dt) {
        for (var i = 0; i < max_count; i++) {
            var e = entries[i];
            if (!e.active) continue;

            e.life -= dt;
            if (e.life <= 0) {
                e.active = false;
                continue;
            }

            e.y += e.vy * dt;
            e.vy = qz_approach(e.vy, -20, 200 * dt); // upwards float decel
        }
    };

    static draw = function() {
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        for (var i = 0; i < max_count; i++) {
            var e = entries[i];
            if (!e.active) continue;

            var t = 1.0 - (e.life / e.max_life);
            var a = (t < 0.7) ? 1.0 : (1.0 - ((t - 0.7) / 0.3));
            var s = e.scale * (1.0 + (0.35 * (1.0 - clamp(t * 3.5, 0, 1.0))));

            // 4-way black outline for maximum contrast against any arena background
            draw_set_color(c_black);
            draw_set_alpha(a * 0.9);
            draw_text_transformed(e.x - 1, e.y, e.text, s, s, 0);
            draw_text_transformed(e.x + 1, e.y, e.text, s, s, 0);
            draw_text_transformed(e.x, e.y - 1, e.text, s, s, 0);
            draw_text_transformed(e.x, e.y + 1, e.text, s, s, 0);

            // Core colored text
            draw_set_color(e.color);
            draw_set_alpha(a);
            draw_text_transformed(e.x, e.y, e.text, s, s, 0);
        }

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(1.0);
    };
}

/// Persistent Combat Decals (scars on surfaces, blast marks).
function VfxDecalPool(capacity = 48) constructor {
    max_count = capacity;
    head = 0;
    decals = array_create(capacity);

    for (var i = 0; i < capacity; i++) {
        decals[i] = {
            active: false,
            x: 0, y: 0,
            angle: 0,
            radius: 8,
            type: DECAL_TYPE.SCORCH,
            color: c_black,
            life: 0.0,
            max_life: 8.0
        };
    }

    static spawn = function(px, py, ptype, pcol, pangle = 0, pradius = 10, plife = undefined) {
        var d = decals[head];
        head = (head + 1) mod max_count;

        var q = quality_get();
        var safe_life = (is_numeric(plife) && plife > 0) ? plife : (variable_struct_exists(q, "decal_life") ? q.decal_life : 7.0);

        d.active = true;
        d.x = px;
        d.y = py;
        d.type = ptype;
        d.color = pcol;
        d.angle = pangle;
        d.radius = pradius;
        d.life = safe_life;
        d.max_life = max(0.001, safe_life);
    };

    static update = function(dt) {
        for (var i = 0; i < max_count; i++) {
            var d = decals[i];
            if (!d.active) continue;

            d.life -= dt;
            if (d.life <= 0) {
                d.active = false;
            }
        }
    };

    static draw = function() {
        for (var i = 0; i < max_count; i++) {
            var d = decals[i];
            if (!d.active) continue;

            var a = clamp(d.life / (d.max_life * 0.4), 0, 0.55);
            draw_set_alpha(a);
            draw_set_color(d.color);

            switch (d.type) {
                case DECAL_TYPE.SCORCH:
                    draw_circle(d.x, d.y, d.radius, false);
                    draw_set_alpha(a * 0.35);
                    draw_circle(d.x, d.y, d.radius * 1.4, true);
                    break;
                case DECAL_TYPE.SLASH:
                    var dx = lengthdir_x(d.radius, d.angle);
                    var dy = lengthdir_y(d.radius, d.angle);
                    draw_line_width(d.x - dx, d.y - dy, d.x + dx, d.y + dy, 3);
                    // Perpendicular gouge ticks
                    var tx = lengthdir_x(d.radius * 0.35, d.angle + 90);
                    var ty = lengthdir_y(d.radius * 0.35, d.angle + 90);
                    draw_line(d.x - tx, d.y - ty, d.x + tx, d.y + ty);
                    break;
                case DECAL_TYPE.CRACK:
                    for (var k = 0; k < 4; k++) {
                        var k_ang = d.angle + (k * 90) + (k * 7);
                        var kx = lengthdir_x(d.radius, k_ang);
                        var ky = lengthdir_y(d.radius, k_ang);
                        draw_line(d.x, d.y, d.x + kx, d.y + ky);
                        var bx = kx * 0.6 + lengthdir_x(d.radius * 0.4, k_ang + 35);
                        var by = ky * 0.6 + lengthdir_y(d.radius * 0.4, k_ang + 35);
                        draw_line(d.x + (kx * 0.6), d.y + (ky * 0.6), d.x + bx, d.y + by);
                    }
                    break;
            }
        }
        draw_set_alpha(1.0);
    };
}

