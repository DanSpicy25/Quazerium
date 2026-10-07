// =====================================================================
// QUAZERIUM — CORE: centralized time (delta, scale, hit stop, timers, cooldowns).
// Gameplay uses qz_dt() (scaled, 0 during hit stop). UI/camera use qz_raw_dt().
// =====================================================================
function time_init() {
    global.time = {
        raw_dt: 1 / QZ_REF_FPS, dt: 1 / QZ_REF_FPS, scale: 1,
        hitstop: 0, in_hitstop: false, fixed_dt: 0,
        game_time: 0, real_time: 0, game_frame: 0,
    };
    var cap = 64;
    global.timers = { items: array_create(cap), cap: cap };
    for (var i = 0; i < cap; i++) global.timers.items[i] = { active: false, t: 0, fn: undefined, scaled: true };
}

function time_update() {
    var T = global.time;
    var raw = (T.fixed_dt > 0) ? T.fixed_dt : delta_time / 1000000;
    raw = min(raw, global.cfg.time.max_dt);
    T.raw_dt = raw;
    T.real_time += raw;
    if (T.hitstop > 0) {
        T.hitstop = max(0, T.hitstop - raw);
        T.dt = 0;
        T.in_hitstop = true;
    } else {
        T.dt = raw * T.scale;
        T.in_hitstop = false;
    }
    if (T.dt > 0) { T.game_time += T.dt; T.game_frame++; }
    timers_update(T.dt, raw);
}

function qz_dt()     { return global.time.dt; }
function qz_raw_dt() { return global.time.raw_dt; }
function time_set_scale(s) { global.time.scale = max(0, s); }
/// Deterministic stepping (tests / replays). 0 = use real delta_time.
function time_set_fixed(dt) { global.time.fixed_dt = dt; }
function time_frames_to_seconds(frames) { return frames / QZ_REF_FPS; }

/// Hit stop: freezes gameplay dt. Longest request wins (no stacking).
function time_hitstop(seconds) {
    if (seconds <= 0) return;
    if (seconds > global.time.hitstop) {
        global.time.hitstop = seconds;
        events_emit(EVT.HITSTOP, seconds);
    }
}

// ---------------- timers (pooled, no per-call allocation except callback) ----------------
function qz_timer_after(seconds, callback, scaled = true) {
    var P = global.timers;
    for (var i = 0; i < P.cap; i++) {
        var it = P.items[i];
        if (!it.active) { it.active = true; it.t = seconds; it.fn = callback; it.scaled = scaled; return i; }
    }
    // grow (rare)
    array_push(P.items, { active: true, t: seconds, fn: callback, scaled: scaled });
    P.cap++;
    return P.cap - 1;
}

function qz_timer_cancel(handle) {
    if (handle >= 0 && handle < global.timers.cap) { global.timers.items[handle].active = false; global.timers.items[handle].fn = undefined; }
}

function timers_update(dt, raw) {
    var P = global.timers;
    for (var i = 0; i < P.cap; i++) {
        var it = P.items[i];
        if (!it.active) continue;
        it.t -= it.scaled ? dt : raw;
        if (it.t <= 0) { it.active = false; var f = it.fn; it.fn = undefined; if (f != undefined) f(); }
    }
}

// ---------------- cooldown ----------------
function Cooldown(_duration) constructor {
    duration = _duration;
    remaining = 0;
    static start    = function(mult = 1) { remaining = duration * mult; };
    static tick     = function(dt) { if (remaining > 0) remaining = max(0, remaining - dt); };
    static ready    = function() { return remaining <= 0; };
    static reset    = function() { remaining = 0; };
    static progress = function() { return (duration <= 0) ? 1 : 1 - remaining / duration; };
}

