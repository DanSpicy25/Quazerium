// =====================================================================
// QUAZERIUM — CORE: event bus. Core emits, Presentation/Camera/Audio listen.
// Callback signature: function(evt, payload)
// Rule: gameplay NEVER depends on a listener existing.
// =====================================================================
function events_init() {
    global.events = {
        listeners: array_create(EVT.COUNT),
        counts: array_create(EVT.COUNT, 0),   // per-event emit counters (debug/tests)
        log: array_create(10, ""), log_head: 0,
    };
    for (var i = 0; i < EVT.COUNT; i++) global.events.listeners[i] = [];
}

/// @param {Real} evt EVT.*  @param {Function} callback function(evt, payload)  @param {Any} owner used by events_unsubscribe_owner
function events_subscribe(evt, callback, owner = undefined) {
    array_push(global.events.listeners[evt], { fn: callback, owner: owner });
}

function events_unsubscribe_owner(owner) {
    var L = global.events.listeners;
    for (var e = 0; e < EVT.COUNT; e++) {
        var arr = L[e];
        for (var i = array_length(arr) - 1; i >= 0; i--) {
            if (arr[i].owner == owner) array_delete(arr, i, 1);
        }
    }
}

function events_emit(evt, payload = undefined) {
    var E = global.events;
    E.counts[evt]++;
    if (QZ_DEBUG) {
        E.log[E.log_head] = evt_name(evt);
        E.log_head = (E.log_head + 1) mod array_length(E.log);
    }
    var arr = E.listeners[evt];
    var n = array_length(arr);
    for (var i = 0; i < n && i < array_length(arr); i++) arr[i].fn(evt, payload);
}

