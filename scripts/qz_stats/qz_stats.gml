// =====================================================================
// QUAZERIUM — STATS & MODIFIERS: Dynamic stat calculation.
// Allows buffs, debuffs, Overdrive, elemental bonuses without hardcoding.
// =====================================================================

function StatModifierContainer() constructor {
    modifiers = []; // array of { id, stat, mult, add, duration, timer }

    static add = function(_id, _stat, _mult, _add, _duration) {
        // Replace existing modifier with same id if present
        for (var i = 0; i < array_length(modifiers); i++) {
            if (modifiers[i].id == _id && modifiers[i].stat == _stat) {
                modifiers[i].mult = _mult;
                modifiers[i].add = _add;
                modifiers[i].duration = _duration;
                modifiers[i].timer = _duration;
                return;
            }
        }
        array_push(modifiers, {
            id: _id,
            stat: _stat,
            mult: _mult,
            add: _add,
            duration: _duration,
            timer: _duration
        });
    };

    static remove = function(_id) {
        for (var i = array_length(modifiers) - 1; i >= 0; i--) {
            if (modifiers[i].id == _id) {
                array_delete(modifiers, i, 1);
            }
        }
    };

    static update = function(dt) {
        for (var i = array_length(modifiers) - 1; i >= 0; i--) {
            var m = modifiers[i];
            if (m.duration > 0) {
                m.timer -= dt;
                if (m.timer <= 0) {
                    array_delete(modifiers, i, 1);
                }
            }
        }
    };

    static evaluate = function(_stat, _base_value) {
        var mult_total = 1.0;
        var add_total = 0.0;
        var n = array_length(modifiers);
        for (var i = 0; i < n; i++) {
            var m = modifiers[i];
            if (m.stat == _stat) {
                mult_total *= m.mult;
                add_total += m.add;
            }
        }
        return (_base_value * mult_total) + add_total;
    };

    static clear = function() {
        modifiers = [];
    };
}

