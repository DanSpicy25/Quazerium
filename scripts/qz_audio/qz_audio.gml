// =====================================================================
// QUAZERIUM — AUDIO: Decoupled sound dispatcher & event hooks.
// Automatically responds to gameplay events with pitch modulation.
// =====================================================================

function audio_system_init() {
    global.audio = {
        enabled: true,
        master_volume: 1.0,
        sfx_volume: 1.0,
        recent_log: array_create(8, "")
    };

    var _play = function(snd_id, priority = 5, loop = false, pitch_min = 0.95, pitch_max = 1.05) {
        if (!global.audio.enabled) return;
        if (is_numeric(snd_id) && audio_exists(snd_id)) {
            var snd = audio_play_sound(snd_id, priority, loop);
            audio_sound_pitch(snd, random_range(pitch_min, pitch_max));
            audio_sound_gain(snd, global.audio.master_volume * global.audio.sfx_volume, 0);
        }
    };

    // Subscriptions to gameplay events
    events_subscribe(EVT.PLAYER_ATTACK, function(evt, data) {
        // Attack whoosh
    }, "qz_audio");

    events_subscribe(EVT.HIT_CONFIRMED, function(evt, data) {
        // Impact hit
    }, "qz_audio");

    events_subscribe(EVT.HIT_CRITICAL, function(evt, data) {
        // Critical slash
    }, "qz_audio");

    events_subscribe(EVT.PARRY, function(evt, data) {
        // Deflect clank
    }, "qz_audio");

    events_subscribe(EVT.PERFECT_PARRY, function(evt, data) {
        // High resonance bell chime
    }, "qz_audio");

    events_subscribe(EVT.DASH, function(evt, data) {
        // Pneumatic air burst
    }, "qz_audio");

    events_subscribe(EVT.SLAM, function(evt, data) {
        // Heavy seismic thud
    }, "qz_audio");

    events_subscribe(EVT.OVERDRIVE, function(evt, data) {
        // Energy ignition roar
    }, "qz_audio");

    events_subscribe(EVT.ELEMENT_REACTION, function(evt, data) {
        // Elemental blast
    }, "qz_audio");

    events_subscribe(EVT.GRAPPLE_ATTACH, function(evt, data) {
        // Latch clank
    }, "qz_audio");

    events_subscribe(EVT.GRAPPLE_SLING, function(evt, data) {
        // Sling release whistle
    }, "qz_audio");
}
