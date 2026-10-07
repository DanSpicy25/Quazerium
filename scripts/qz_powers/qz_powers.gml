// =====================================================================
// QUAZERIUM — POWERS: Extensible power architecture (Shockwave, Blade Surge, Blink).
// Interface: available(player), activate(player), update(player, dt), cancel(player)
// =====================================================================

function powers_init() {
    global.power_defs = array_create(POWER_ID.COUNT, undefined);

    // 1. SHOCKWAVE
    var p_sw = {
        id: POWER_ID.SHOCKWAVE,
        name: "Shockwave",
        cfg: global.cfg.powers.shockwave,
        available: function(player) {
            var c = global.cfg.powers.shockwave;
            return (player.energy >= c.cost && player.power_cooldowns[POWER_ID.SHOCKWAVE].ready());
        },
        activate: function(player) {
            var c = global.cfg.powers.shockwave;
            player.energy -= c.cost;
            player.power_cooldowns[POWER_ID.SHOCKWAVE].start();

            // Spawn radial burst hitbox centered on player
            var r = c.radius;
            hitbox_spawn(player, TEAM.PLAYER, player.x - r, player.y - r, r * 2, r * 2,
                         c.damage, c.knockback * player.facing, -c.knock_up,
                         c.hitstop, player.active_element, false, c.duration);

            events_emit(EVT.POWER, { player: player, power_id: POWER_ID.SHOCKWAVE, name: "Shockwave", x: player.x, y: player.y, radius: r });
            return true;
        },
        update: function(player, dt) {},
        cancel: function(player) {}
    };

    // 2. BLADE SURGE
    var p_bs = {
        id: POWER_ID.BLADE_SURGE,
        name: "Blade Surge",
        cfg: global.cfg.powers.blade_surge,
        available: function(player) {
            var c = global.cfg.powers.blade_surge;
            return (player.energy >= c.cost && player.power_cooldowns[POWER_ID.BLADE_SURGE].ready());
        },
        activate: function(player) {
            var c = global.cfg.powers.blade_surge;
            player.energy -= c.cost;
            player.power_cooldowns[POWER_ID.BLADE_SURGE].start();

            player.vx = c.speed * player.facing;
            player.vy = 0;
            player.iframes = c.duration;
            player.power_timer = c.duration;
            player.active_power_id = POWER_ID.BLADE_SURGE;

            // Spawn surge hitbox
            hitbox_spawn(player, TEAM.PLAYER, player.x - (c.w / 2), player.y - (c.h / 2),
                         c.w, c.h, c.damage, c.knockback * player.facing, -80,
                         c.hitstop, player.active_element, true, c.duration);

            events_emit(EVT.POWER, { player: player, power_id: POWER_ID.BLADE_SURGE, name: "Blade Surge", x: player.x, y: player.y, facing: player.facing, speed: c.speed });
            return true;
        },
        update: function(player, dt) {
            if (player.active_power_id == POWER_ID.BLADE_SURGE) {
                var c = global.cfg.powers.blade_surge;
                player.power_timer -= dt;
                player.vx = c.speed * player.facing;
                if (player.power_timer <= 0) {
                    player.active_power_id = -1;
                    events_emit(EVT.POWER_END, { player: player, power_id: POWER_ID.BLADE_SURGE });
                }
            }
        },
        cancel: function(player) {
            if (player.active_power_id == POWER_ID.BLADE_SURGE) {
                player.active_power_id = -1;
                events_emit(EVT.POWER_CANCEL, { player: player, power_id: POWER_ID.BLADE_SURGE });
            }
        }
    };

    // 3. BLINK
    var p_bk = {
        id: POWER_ID.BLINK,
        name: "Blink",
        cfg: global.cfg.powers.blink,
        available: function(player) {
            var c = global.cfg.powers.blink;
            return (player.energy >= c.cost && player.power_cooldowns[POWER_ID.BLINK].ready());
        },
        activate: function(player) {
            var c = global.cfg.powers.blink;
            player.energy -= c.cost;
            player.power_cooldowns[POWER_ID.BLINK].start();

            var old_x = player.x;
            var old_y = player.y;
            var dir_x = player.facing;
            if (abs(player.vx) > 10) dir_x = sign(player.vx);
            var max_dist = c.distance;
            var step = c.step;
            var target_x = player.x;
            var hw = player.bbox_hw;
            var hh = player.bbox_hh;

            // Raycast forward to find unblocked teleport position
            for (var d = 0; d <= max_dist; d += step) {
                var check_x = player.x + (d * dir_x);
                if (physics_check_solid(check_x - hw, player.y - hh, check_x + hw, player.y + hh)) {
                    break;
                }
                target_x = check_x;
            }

            player.x = target_x;
            player.vx *= c.keep_velocity;
            player.iframes = c.iframes;

            events_emit(EVT.POWER, { player: player, power_id: POWER_ID.BLINK, name: "Blink", start_x: old_x, start_y: old_y, end_x: target_x, end_y: player.y, facing: dir_x });
            return true;
        },
        update: function(player, dt) {},
        cancel: function(player) {}
    };

    global.power_defs[POWER_ID.SHOCKWAVE]   = p_sw;
    global.power_defs[POWER_ID.BLADE_SURGE] = p_bs;
    global.power_defs[POWER_ID.BLINK]       = p_bk;
}

function power_get(p_id) {
    if (p_id < 0 || p_id >= POWER_ID.COUNT) return undefined;
    return global.power_defs[p_id];
}

function power_try_activate(player, p_id) {
    var p = power_get(p_id);
    if (p == undefined) return false;
    if (p.available(player)) {
        return p.activate(player);
    }
    return false;
}

