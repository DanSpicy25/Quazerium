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
            return (player.energy >= cfg.cost && player.power_cooldowns[POWER_ID.SHOCKWAVE].ready());
        },
        activate: function(player) {
            player.energy -= cfg.cost;
            player.power_cooldowns[POWER_ID.SHOCKWAVE].start();

            // Spawn radial burst hitbox centered on player
            var r = cfg.radius;
            hitbox_spawn(player, TEAM.PLAYER, player.x - r, player.y - r, r * 2, r * 2,
                         cfg.damage, cfg.knockback * player.facing, -cfg.knock_up,
                         cfg.hitstop, player.active_element, false, cfg.duration);

            events_emit(EVT.POWER, { player: player, power_id: POWER_ID.SHOCKWAVE, name: "Shockwave" });
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
            return (player.energy >= cfg.cost && player.power_cooldowns[POWER_ID.BLADE_SURGE].ready());
        },
        activate: function(player) {
            player.energy -= cfg.cost;
            player.power_cooldowns[POWER_ID.BLADE_SURGE].start();

            player.vx = cfg.speed * player.facing;
            player.vy = 0;
            player.iframes = cfg.duration;
            player.power_timer = cfg.duration;
            player.active_power_id = POWER_ID.BLADE_SURGE;

            // Spawn surge hitbox
            hitbox_spawn(player, TEAM.PLAYER, player.x - (cfg.w / 2), player.y - (cfg.h / 2),
                         cfg.w, cfg.h, cfg.damage, cfg.knockback * player.facing, -80,
                         cfg.hitstop, player.active_element, true, cfg.duration);

            events_emit(EVT.POWER, { player: player, power_id: POWER_ID.BLADE_SURGE, name: "Blade Surge" });
            return true;
        },
        update: function(player, dt) {
            if (player.active_power_id == POWER_ID.BLADE_SURGE) {
                player.power_timer -= dt;
                player.vx = cfg.speed * player.facing;
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
            return (player.energy >= cfg.cost && player.power_cooldowns[POWER_ID.BLINK].ready());
        },
        activate: function(player) {
            player.energy -= cfg.cost;
            player.power_cooldowns[POWER_ID.BLINK].start();

            var dir_x = player.facing;
            if (abs(player.vx) > 10) dir_x = sign(player.vx);
            var max_dist = cfg.distance;
            var step = cfg.step;
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
            player.vx *= cfg.keep_velocity;
            player.iframes = cfg.iframes;

            events_emit(EVT.POWER, { player: player, power_id: POWER_ID.BLINK, name: "Blink" });
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

