// =====================================================================
// QUAZERIUM — CORE: math helpers (allocation-free).
// =====================================================================
function qz_approach(v, target, amount) {
    return (v < target) ? min(v + amount, target) : max(v - amount, target);
}

/// Frame-rate independent exponential smoothing by half-life (seconds).
function qz_damp(current, target, half_life, dt) {
    if (half_life <= 0) return target;
    return target + (current - target) * power(2, -dt / half_life);
}

function qz_aabb_overlap(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2) {
    return (ax1 < bx2) && (ax2 > bx1) && (ay1 < by2) && (ay2 > by1);
}

/// Checks existence of an entity (GameMaker instance or data struct).
function qz_entity_exists(entity) {
    if (is_undefined(entity) || entity == noone) return false;
    if (is_struct(entity)) return true;
    return instance_exists(entity);
}

/// Checks if a variable exists on either a struct or a GameMaker instance safely.
function qz_var_exists(entity, varname) {
    if (is_undefined(entity) || entity == noone) return false;
    if (is_struct(entity)) return variable_struct_exists(entity, varname);
    if (!instance_exists(entity)) return false;
    return variable_instance_exists(entity, varname);
}

