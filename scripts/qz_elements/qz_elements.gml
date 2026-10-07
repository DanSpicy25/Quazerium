// =====================================================================
// QUAZERIUM — ELEMENTS: Elemental status & reaction matrix.
// Elements: FIRE, EARTH, WATER, WIND.
// Reactions are data-driven via a 2D lookup matrix.
// =====================================================================

function elements_system_init() {
    global.element_matrix = array_create(ELEMENT.COUNT);
    for (var i = 0; i < ELEMENT.COUNT; i++) {
        global.element_matrix[i] = array_create(ELEMENT.COUNT, undefined);
    }

    // Register reactions (bidirectional by default)
    var _reg = function(e1, e2, name, dmg_mult, stun, slow, kb_mult, clear_stat) {
        var res = {
            name: name,
            damage_mult: dmg_mult,
            stun_time: stun,
            slow_mult: slow,
            knockback_mult: kb_mult,
            clears_status: clear_stat
        };
        global.element_matrix[e1][e2] = res;
        global.element_matrix[e2][e1] = res;
    };

    _reg(ELEMENT.FIRE, ELEMENT.WATER, "VAPORIZE", 2.0, 0.0, 1.0, 1.2, true);
    _reg(ELEMENT.FIRE, ELEMENT.WIND,  "SWIRL",    1.4, 0.0, 1.0, 1.5, false);
    _reg(ELEMENT.FIRE, ELEMENT.EARTH, "MAGMA",    1.5, 0.2, 0.8, 1.0, false);
    _reg(ELEMENT.WATER, ELEMENT.EARTH,"MUD",      1.2, 0.0, 0.5, 0.8, false);
    _reg(ELEMENT.WATER, ELEMENT.WIND, "FREEZE",   1.3, 0.8, 0.2, 0.5, true);
    _reg(ELEMENT.EARTH, ELEMENT.WIND, "EROSION",  1.3, 0.3, 1.0, 2.0, true);
}

/// Applies an element to a target entity with elemental capability.
/// Returns reaction struct if a reaction occurred, or undefined if only applied.
function element_apply(target, new_elem) {
    if (new_elem == ELEMENT.NONE || target == noone) return undefined;

    var cur = target.element_status;
    if (cur == ELEMENT.NONE || cur == new_elem) {
        target.element_status = new_elem;
        target.element_timer = global.cfg.elements.status_duration;
        events_emit(EVT.ELEMENT_APPLIED, { target: target, element: new_elem });
        return undefined;
    }

    // Trigger reaction from matrix
    var reaction = global.element_matrix[cur][new_elem];
    if (reaction != undefined) {
        if (reaction.clears_status) {
            target.element_status = ELEMENT.NONE;
            target.element_timer = 0;
        } else {
            target.element_status = new_elem;
            target.element_timer = global.cfg.elements.status_duration;
        }
        events_emit(EVT.ELEMENT_REACTION, { target: target, reaction: reaction, element_a: cur, element_b: new_elem });
        return reaction;
    }

    target.element_status = new_elem;
    target.element_timer = global.cfg.elements.status_duration;
    events_emit(EVT.ELEMENT_APPLIED, { target: target, element: new_elem });
    return undefined;
}

function element_update_entity(target, dt) {
    if (target.element_status != ELEMENT.NONE) {
        target.element_timer -= dt;
        if (target.element_timer <= 0) {
            target.element_status = ELEMENT.NONE;
            target.element_timer = 0;
        }
    }
}

