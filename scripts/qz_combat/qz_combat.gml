// =====================================================================
// QUAZERIUM — COMBAT: Damage calculation, combo system, hitbox resolution.
// Decoupled from VFX: Core resolves math and emits events.
// Presentation decides screenshake, particles, audio, numbers.
// =====================================================================

function combat_calculate_damage(base_dmg, overdrive_mult, combo_count, reaction_mult = 1.0) {
    var c_step = global.cfg.combat.combo_step;
    var c_cap = global.cfg.combat.combo_cap;
    var combo_mult = 1.0 + (min(combo_count, c_cap) * c_step);
    var final_dmg = base_dmg * overdrive_mult * combo_mult * reaction_mult;
    return max(1, round(final_dmg));
}

/// Creates a combat hitbox.
function hitbox_spawn(owner_inst, team, xpos, ypos, width, height, damage, kb_x, kb_y, hitstop, element = ELEMENT.NONE, can_parry = true, duration = 0.08, startup = 0) {
    var hb = instance_create_layer(xpos, ypos, "Instances", obj_hitbox);
    hb.owner = owner_inst;
    hb.team = team;
    hb.bbox_w = width;
    hb.bbox_h = height;
    hb.damage = damage;
    hb.kb_x = kb_x;
    hb.kb_y = kb_y;
    hb.hitstop = hitstop;
    hb.element = element;
    hb.can_be_parried = can_parry;
    hb.duration = duration;
    hb.timer = duration + startup;
    hb.startup = startup;
    hb.hit_targets = [];
    return hb;
}

/// Retrieves the decoupled combat hurtbox of an entity
function entity_get_hurtbox(inst) {
    if (!qz_entity_exists(inst)) return { x1: 0, y1: 0, x2: 0, y2: 0 };
    var hw = qz_var_exists(inst, "hurtbox_hw") ? inst.hurtbox_hw : (qz_var_exists(inst, "bbox_hw") ? inst.bbox_hw + 2 : 16);
    var hh = qz_var_exists(inst, "hurtbox_hh") ? inst.hurtbox_hh : (qz_var_exists(inst, "bbox_hh") ? inst.bbox_hh + 2 : 24);
    return {
        x1: inst.x - hw,
        y1: inst.y - hh,
        x2: inst.x + hw,
        y2: inst.y + hh
    };
}

/// Evaluates hit resolution between a hitbox and a hurtbox entity.
function combat_resolve_hit(hb, target) {
    if (!qz_entity_exists(hb) || !qz_entity_exists(target)) return false;
    if (hb.owner == target) return false;
    if (qz_var_exists(hb, "team") && qz_var_exists(target, "team") && hb.team == target.team) return false;

    // Check if already hit by this specific hitbox
    var target_id = (is_struct(target) && variable_struct_exists(target, "id")) ? target.id : target;
    if (qz_var_exists(hb, "hit_targets")) {
        for (var i = 0; i < array_length(hb.hit_targets); i++) {
            if (hb.hit_targets[i] == target_id) return false;
        }
        array_push(hb.hit_targets, target_id);
    }

    // Invulnerability check
    if (qz_var_exists(target, "iframes") && target.iframes > 0) {
        events_emit(EVT.HIT_EVADED, { target: target, hitbox: hb });
        return false;
    }

    // Parry resolution
    var can_parry = qz_var_exists(hb, "can_be_parried") ? hb.can_be_parried : true;
    if (can_parry && qz_var_exists(target, "is_parrying") && target.is_parrying) {
        var parry_t = qz_var_exists(target, "parry_timer") ? target.parry_timer : 0;
        var perfect_window = global.cfg.parry.perfect_window; // ~120ms
        var normal_window = global.cfg.parry.window;

        if (parry_t <= perfect_window) {
            // PERFECT PARRY
            time_hitstop(global.cfg.parry.hitstop_perfect);
            if (qz_var_exists(target, "energy")) {
                target.energy = min(target.energy + global.cfg.parry.energy_perfect, global.cfg.energy.max);
            }
            if (qz_entity_exists(hb.owner) && qz_var_exists(hb.owner, "stun_timer")) {
                hb.owner.stun_timer = global.cfg.parry.attacker_stun_perfect;
            }
            events_emit(EVT.PERFECT_PARRY, { defender: target, attacker: hb.owner, hitbox: hb });
            if (!is_struct(hb) && instance_exists(hb)) instance_destroy(hb);
            return true;
        } else if (parry_t <= normal_window) {
            // NORMAL PARRY
            time_hitstop(global.cfg.parry.hitstop_normal);
            if (qz_var_exists(target, "energy")) {
                target.energy = min(target.energy + global.cfg.parry.energy_normal, global.cfg.energy.max);
            }
            if (qz_entity_exists(hb.owner) && qz_var_exists(hb.owner, "stun_timer")) {
                hb.owner.stun_timer = global.cfg.parry.attacker_stun_normal;
            }
            events_emit(EVT.PARRY, { defender: target, attacker: hb.owner, hitbox: hb });
            if (!is_struct(hb) && instance_exists(hb)) instance_destroy(hb);
            return true;
        }
    }

    // Elemental reaction check
    var react_mult = 1.0;
    var reaction = undefined;
    var hb_elem = qz_var_exists(hb, "element") ? hb.element : ELEMENT.NONE;
    if (qz_var_exists(target, "element_status")) {
        reaction = element_apply(target, hb_elem);
        if (reaction != undefined) {
            react_mult = reaction.damage_mult;
        }
    }

    // Calculate final damage
    var ovr_mult = 1.0;
    var combo_cnt = 0;
    if (qz_entity_exists(hb.owner)) {
        if (qz_var_exists(hb.owner, "overdrive_active") && hb.owner.overdrive_active) {
            ovr_mult = 1.6;
        }
        if (qz_var_exists(hb.owner, "combo_count")) {
            combo_cnt = hb.owner.combo_count;
        }
    }

    var base_dmg = qz_var_exists(hb, "damage") ? hb.damage : 1;
    var final_dmg = combat_calculate_damage(base_dmg, ovr_mult, combo_cnt, react_mult);

    // Apply Damage
    if (qz_var_exists(target, "hp")) {
        target.hp -= final_dmg;
    }

    // Apply Knockback
    if (qz_var_exists(target, "vx") && qz_var_exists(target, "vy")) {
        var kb_res = qz_var_exists(target, "kb_resist") ? target.kb_resist : 0;
        var kb_factor = max(0, 1.0 - kb_res);
        if (reaction != undefined) kb_factor *= reaction.knockback_mult;
        var kb_x = qz_var_exists(hb, "kb_x") ? hb.kb_x : 0;
        var kb_y = qz_var_exists(hb, "kb_y") ? hb.kb_y : 0;
        target.vx = kb_x * kb_factor;
        target.vy = kb_y * kb_factor;
    }

    // Stun
    if (qz_var_exists(target, "hitstun")) {
        target.hitstun = global.cfg.player.hitstun;
        if (reaction != undefined && reaction.stun_time > 0) {
            target.hitstun += reaction.stun_time;
        }
    }

    // Hitstop & Attacker Kinetic Resistance
    var hb_hitstop = qz_var_exists(hb, "hitstop") ? hb.hitstop : 0.05;
    time_hitstop(hb_hitstop);
    if (qz_entity_exists(hb.owner) && qz_var_exists(hb.owner, "vx")) {
        hb.owner.vx *= 0.55;
    }

    // Attacker rewards (combo, energy)
    if (qz_entity_exists(hb.owner)) {
        if (qz_var_exists(hb.owner, "combo_count")) {
            hb.owner.combo_count++;
            if (qz_var_exists(hb.owner, "combo_timer")) {
                hb.owner.combo_timer = global.cfg.combat.combo_window;
            }
        }
        if (qz_var_exists(hb.owner, "energy")) {
            var egain = (base_dmg >= global.cfg.combat.charged.damage) ?
                        global.cfg.combat.energy_per_charged_hit : global.cfg.combat.energy_per_hit;
            hb.owner.energy = min(hb.owner.energy + egain, global.cfg.energy.max);
            if (hb.owner.energy >= global.cfg.energy.max) {
                events_emit(EVT.ENERGY_FULL, hb.owner);
            }
        }
    }

    // Emit Hit Confirmed event
    var is_crit = (ovr_mult > 1.0 || (reaction != undefined && reaction.damage_mult > 1.0));
    events_emit(is_crit ? EVT.HIT_CRITICAL : EVT.HIT_CONFIRMED, {
        attacker: hb.owner,
        target: target,
        damage: final_dmg,
        is_crit: is_crit,
        element: hb_elem,
        reaction: reaction
    });

    // Check Death
    if (qz_var_exists(target, "hp") && target.hp <= 0) {
        events_emit(EVT.ENTITY_KILLED, { victim: target, killer: hb.owner });
        if (qz_var_exists(target, "team") && target.team == TEAM.PLAYER) {
            events_emit(EVT.PLAYER_DIED, target);
        }
    }

    return true;
}

/// Evaluates player combo count into distinct action game combat ranks (D, C, B, A, S).
function combat_get_combo_rank(count) {
    if (count >= 20) return { rank: "S", title: "SUPREME",    r: 255, g: 45,  b: 95  };
    if (count >= 15) return { rank: "A", title: "ANARCHY",    r: 255, g: 205, b: 30  };
    if (count >= 10) return { rank: "B", title: "BRUTAL",     r: 40,  g: 240, b: 130 };
    if (count >= 5)  return { rank: "C", title: "CHARGED",    r: 45,  g: 185, b: 255 };
    if (count >= 1)  return { rank: "D", title: "DISRUPTOR",  r: 165, g: 180, b: 195 };
    return undefined;
}

/// Fires the shotgun weapon with multi-pellet blast and visceral recoil
function combat_shotgun_fire(p) {
    if (!qz_entity_exists(p)) return false;
    var cfg = global.cfg.shotgun;
    if (p.shotgun_ammo <= 0) {
        combat_shotgun_reload_start(p);
        return false;
    }

    var is_emp = p.shotgun_empowered;
    p.shotgun_ammo--;
    p.shotgun_empowered = false;

    var num_pellets = is_emp ? cfg.pellets_empowered : cfg.pellets_normal;
    var spread_deg  = is_emp ? cfg.spread_empowered : cfg.spread_normal;
    var dmg_pellet  = is_emp ? cfg.damage_empowered : cfg.damage_normal;
    var p_range     = is_emp ? cfg.range_empowered : cfg.range_normal;
    var hitstop_val = is_emp ? cfg.hitstop_empowered : cfg.hitstop_normal;
    var p_color     = is_emp ? make_color_rgb(212, 175, 55) : make_color_rgb(238, 235, 224);

    var base_ang = (p.facing > 0) ? 0 : 180;
    var spawn_x  = p.x + (p.facing * (p.bbox_hw + 14));
    var spawn_y  = p.y - 4;

    // Backward visceral recoil kick on player
    p.vx = -p.facing * abs(cfg.recoil_player_vx);
    p.vy = min(p.vy, cfg.recoil_player_vy);
    p.shotgun_recoil_timer = 0.20;

    // Spawn pellets
    for (var i = 0; i < num_pellets; i++) {
        var spread_t = (num_pellets > 1) ? (i / (num_pellets - 1)) - 0.5 : 0;
        var p_ang = base_ang + (spread_t * spread_deg) + random_range(-2, 2);
        var hb = instance_create_layer(spawn_x, spawn_y, "Instances", obj_hitbox);
        hb.owner = p;
        hb.team = TEAM.PLAYER;
        hb.bbox_w = 12;
        hb.bbox_h = 12;
        hb.damage = dmg_pellet;
        hb.kb_x = lengthdir_x(is_emp ? 460 : 320, p_ang);
        hb.kb_y = lengthdir_y(is_emp ? 240 : 160, p_ang) - 80;
        hb.hitstop = hitstop_val;
        hb.element = p.active_element;
        hb.can_be_parried = false;
        hb.duration = p_range / cfg.pellet_speed;
        hb.timer = hb.duration;
        hb.is_pellet = true;
        hb.vx = lengthdir_x(cfg.pellet_speed, p_ang);
        hb.vy = lengthdir_y(cfg.pellet_speed, p_ang);
        hb.color = p_color;
    }

    events_emit(EVT.SHOTGUN_FIRE, { player: p, empowered: is_emp, pellets: num_pellets });
    return true;
}

/// Starts shotgun active reload process
function combat_shotgun_reload_start(p) {
    if (!qz_entity_exists(p)) return;
    if (p.reload_state == RELOAD_STATE.RELOADING) return;
    var cfg = global.cfg.shotgun;
    p.reload_state = RELOAD_STATE.RELOADING;
    p.reload_progress = 0.0;
    p.reload_duration = cfg.reload_time;
    p.reload_feedback_timer = 0;
    p.reload_feedback_type = "";
    events_emit(EVT.SHOTGUN_RELOAD_START, { player: p });
}

/// Evaluates player press during active reload
function combat_shotgun_reload_press(p) {
    if (!qz_entity_exists(p) || p.reload_state != RELOAD_STATE.RELOADING) return "";
    var cfg = global.cfg.shotgun;
    var prog = p.reload_progress;

    if (prog >= cfg.perfect_start && prog <= cfg.perfect_end) {
        // PERFECT RELOAD!
        p.shotgun_ammo = cfg.ammo_max;
        p.shotgun_empowered = true;
        p.reload_state = RELOAD_STATE.IDLE;
        p.reload_feedback_type = "PERFECT";
        p.reload_feedback_timer = 0.65;
        events_emit(EVT.SHOTGUN_RELOAD_PERFECT, { player: p });
        return "PERFECT";
    } else if (prog >= cfg.window_start && prog <= cfg.window_end) {
        // NORMAL RELOAD (early/late within window)
        p.shotgun_ammo = cfg.ammo_max;
        p.shotgun_empowered = false;
        p.reload_state = RELOAD_STATE.IDLE;
        p.reload_feedback_type = "NORMAL";
        p.reload_feedback_timer = 0.40;
        events_emit(EVT.SHOTGUN_RELOAD_COMPLETE, { player: p, empowered: false });
        return "NORMAL";
    } else {
        // FAIL / MISTIMED
        p.reload_duration += cfg.fail_penalty_time;
        p.shotgun_empowered = false;
        p.reload_feedback_type = "FAIL";
        p.reload_feedback_timer = 0.40;
        events_emit(EVT.SHOTGUN_RELOAD_FAIL, { player: p });
        return "FAIL";
    }
}

/// Updates shotgun reload state over time
function combat_shotgun_reload_update(p, dt) {
    if (!qz_entity_exists(p)) return;
    if (p.reload_feedback_timer > 0) p.reload_feedback_timer -= dt;

    if (p.reload_state != RELOAD_STATE.RELOADING) return;
    p.reload_progress += dt / max(0.01, p.reload_duration);

    if (p.reload_progress >= 1.0) {
        // Finished naturally without active press
        var cfg = global.cfg.shotgun;
        p.shotgun_ammo = cfg.ammo_max;
        p.shotgun_empowered = false;
        p.reload_state = RELOAD_STATE.IDLE;
        p.reload_feedback_type = "NORMAL";
        p.reload_feedback_timer = 0.30;
        events_emit(EVT.SHOTGUN_RELOAD_COMPLETE, { player: p, empowered: false });
    }
}
