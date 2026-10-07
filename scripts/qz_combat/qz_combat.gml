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
function hitbox_spawn(owner_inst, team, xpos, ypos, width, height, damage, kb_x, kb_y, hitstop, element = ELEMENT.NONE, can_parry = true, duration = 0.08) {
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
    hb.timer = duration;
    hb.hit_targets = [];
    return hb;
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

    // Hitstop
    var hb_hitstop = qz_var_exists(hb, "hitstop") ? hb.hitstop : 0.05;
    time_hitstop(hb_hitstop);

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
    }

    return true;
}
