// =====================================================================
// QUAZERIUM — POOL: Allocation-free object & struct recycling.
// Prevents GC hiccups and HDD thrashing on low-end hardware.
// =====================================================================

function ObjectPool(_create_fn, _reset_fn, _initial_size = 16) constructor {
    create_fn = _create_fn;
    reset_fn = _reset_fn;
    items = [];

    // Pre-populate
    for (var i = 0; i < _initial_size; i++) {
        array_push(items, create_fn());
    }

    static get = function() {
        var item;
        if (array_length(items) > 0) {
            item = array_pop(items);
        } else {
            item = create_fn();
        }
        if (reset_fn != undefined) reset_fn(item);
        return item;
    };

    static recycle = function(item) {
        array_push(items, item);
    };

    static clear = function() {
        items = [];
    };
}

