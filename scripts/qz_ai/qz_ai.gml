// =====================================================================
// QUAZERIUM — AI FOUNDATION: Blackboard & Behavior Tree architecture.
// Clean, composable, zero-overhead AI infrastructure for enemies and bosses.
// =====================================================================

function Blackboard() constructor {
    data = {};
    static set = function(k, v) { variable_struct_set(data, k, v); };
    static get = function(k, def = undefined) {
        if (variable_struct_exists(data, k)) return variable_struct_get(data, k);
        return def;
    };
    static has = function(k) { return variable_struct_exists(data, k); };
    static clear = function() { data = {}; };
}

function BT_Node() constructor {
    static tick = function(bb, dt) { return BT_STATUS.SUCCESS; };
}

function BT_Sequence(_children) : BT_Node() constructor {
    children = _children;
    cur_idx = 0;

    static tick = function(bb, dt) {
        while (cur_idx < array_length(children)) {
            var status = children[cur_idx].tick(bb, dt);
            if (status == BT_STATUS.RUNNING) return BT_STATUS.RUNNING;
            if (status == BT_STATUS.FAILURE) {
                cur_idx = 0;
                return BT_STATUS.FAILURE;
            }
            cur_idx++;
        }
        cur_idx = 0;
        return BT_STATUS.SUCCESS;
    };
}

function BT_Selector(_children) : BT_Node() constructor {
    children = _children;
    cur_idx = 0;

    static tick = function(bb, dt) {
        while (cur_idx < array_length(children)) {
            var status = children[cur_idx].tick(bb, dt);
            if (status == BT_STATUS.RUNNING) return BT_STATUS.RUNNING;
            if (status == BT_STATUS.SUCCESS) {
                cur_idx = 0;
                return BT_STATUS.SUCCESS;
            }
            cur_idx++;
        }
        cur_idx = 0;
        return BT_STATUS.FAILURE;
    };
}

function BT_Action(_fn) : BT_Node() constructor {
    fn = _fn;
    static tick = function(bb, dt) {
        return fn(bb, dt);
    };
}

function BT_Condition(_fn) : BT_Node() constructor {
    fn = _fn;
    static tick = function(bb, dt) {
        return fn(bb) ? BT_STATUS.SUCCESS : BT_STATUS.FAILURE;
    };
}

