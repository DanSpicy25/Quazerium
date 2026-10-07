// =====================================================================
// QUAZERIUM — INPUT: Abstract input layer (Keyboard, Mouse, Gamepad, Synthetic).
// Gameplay reads ONLY abstract actions via input_check*(ACTION.*).
// NEVER query raw keyboard_check() inside gameplay entities.
// =====================================================================

function input_init() {
    global.input = {
        state: array_create(ACTION.COUNT, false),
        pressed: array_create(ACTION.COUNT, false),
        released: array_create(ACTION.COUNT, false),
        axis_x: 0,
        axis_y: 0,
        aim_x: 0,
        aim_y: 0,
        gamepad_id: 0,
        deadzone: 0.25,
        synthetic: {
            active: false,
            state: array_create(ACTION.COUNT, false),
            pressed: array_create(ACTION.COUNT, false),
            released: array_create(ACTION.COUNT, false),
            axis_x: 0,
            axis_y: 0,
            aim_x: 0,
            aim_y: 0
        }
    };
    gamepad_set_axis_deadzone(global.input.gamepad_id, global.input.deadzone);
}

function input_update() {
    var inp = global.input;
    if (inp.synthetic.active) {
        for (var a = 0; a < ACTION.COUNT; a++) {
            inp.state[a] = inp.synthetic.state[a];
            inp.pressed[a] = inp.synthetic.pressed[a];
            inp.released[a] = inp.synthetic.released[a];
            // One-frame pulse consumption for simulated pressed/released
            inp.synthetic.pressed[a] = false;
            inp.synthetic.released[a] = false;
        }
        inp.axis_x = inp.synthetic.axis_x;
        inp.axis_y = inp.synthetic.axis_y;
        inp.aim_x = inp.synthetic.aim_x;
        inp.aim_y = inp.synthetic.aim_y;
        return;
    }

    var pad = inp.gamepad_id;
    var pad_connected = gamepad_is_connected(pad);

    // Evaluate each action
    for (var a = 0; a < ACTION.COUNT; a++) {
        var is_down = false;
        switch (a) {
            case ACTION.MOVE_LEFT:
                is_down = keyboard_check(ord("A")) || keyboard_check(vk_left) ||
                          (pad_connected && (gamepad_button_check(pad, gp_padl) || gamepad_axis_value(pad, gp_axislh) < -inp.deadzone));
                break;
            case ACTION.MOVE_RIGHT:
                is_down = keyboard_check(ord("D")) || keyboard_check(vk_right) ||
                          (pad_connected && (gamepad_button_check(pad, gp_padr) || gamepad_axis_value(pad, gp_axislh) > inp.deadzone));
                break;
            case ACTION.MOVE_UP:
                is_down = keyboard_check(ord("W")) || keyboard_check(vk_up) ||
                          (pad_connected && (gamepad_button_check(pad, gp_padu) || gamepad_axis_value(pad, gp_axislv) < -inp.deadzone));
                break;
            case ACTION.MOVE_DOWN:
                is_down = keyboard_check(ord("S")) || keyboard_check(vk_down) ||
                          (pad_connected && (gamepad_button_check(pad, gp_padd) || gamepad_axis_value(pad, gp_axislv) > inp.deadzone));
                break;
            case ACTION.JUMP:
                is_down = keyboard_check(vk_space) || (pad_connected && gamepad_button_check(pad, gp_face1));
                break;
            case ACTION.DASH:
                is_down = keyboard_check(vk_shift) || (pad_connected && (gamepad_button_check(pad, gp_face2) || gamepad_button_check(pad, gp_shoulderrb)));
                break;
            case ACTION.ATTACK:
                is_down = mouse_check_button(mb_left) || keyboard_check(ord("J")) || (pad_connected && gamepad_button_check(pad, gp_face3));
                break;
            case ACTION.PARRY:
                is_down = mouse_check_button(mb_right) || keyboard_check(ord("K")) || (pad_connected && (gamepad_button_check(pad, gp_face4) || gamepad_button_check(pad, gp_shoulderl)));
                break;
            case ACTION.GRAPPLE:
                is_down = keyboard_check(ord("E")) || mouse_check_button(mb_middle) || (pad_connected && gamepad_button_check(pad, gp_shoulderr));
                break;
            case ACTION.POWER:
                is_down = keyboard_check(ord("F")) || (pad_connected && gamepad_button_check(pad, gp_shoulderlb));
                break;
            case ACTION.POWER_SELECT:
                is_down = keyboard_check(ord("3")) || keyboard_check(ord("4")) || keyboard_check(ord("5"));
                break;
            case ACTION.ELEMENT:
                is_down = keyboard_check(vk_tab) || (pad_connected && gamepad_button_check(pad, gp_select));
                break;
            case ACTION.OVERDRIVE:
                is_down = keyboard_check(ord("V")) || keyboard_check(ord("G")) || (pad_connected && gamepad_button_check(pad, gp_stickl) && gamepad_button_check(pad, gp_stickr));
                break;
            case ACTION.WEAPON_SWAP:
                is_down = keyboard_check(ord("Q")) || mouse_wheel_up() || mouse_wheel_down() || (pad_connected && gamepad_button_check(pad, gp_padu));
                break;
            case ACTION.RELOAD:
                is_down = keyboard_check(ord("R")) || (pad_connected && gamepad_button_check(pad, gp_face4));
                break;
        }

        var prev = inp.state[a];
        inp.state[a] = is_down;
        inp.pressed[a] = is_down && !prev;
        inp.released[a] = !is_down && prev;
    }

    // Axes calculation
    var ax = 0;
    var ay = 0;
    if (inp.state[ACTION.MOVE_LEFT]) ax -= 1;
    if (inp.state[ACTION.MOVE_RIGHT]) ax += 1;
    if (inp.state[ACTION.MOVE_UP]) ay -= 1;
    if (inp.state[ACTION.MOVE_DOWN]) ay += 1;

    if (pad_connected) {
        var pad_x = gamepad_axis_value(pad, gp_axislh);
        var pad_y = gamepad_axis_value(pad, gp_axislv);
        if (abs(pad_x) > inp.deadzone) ax = pad_x;
        if (abs(pad_y) > inp.deadzone) ay = pad_y;
    }

    // Clamp or normalize vector
    var len = point_distance(0, 0, ax, ay);
    if (len > 1) {
        ax /= len;
        ay /= len;
    }
    inp.axis_x = ax;
    inp.axis_y = ay;

    // Aim position (screen/room space)
    inp.aim_x = mouse_x;
    inp.aim_y = mouse_y;
}

// ---------------- Public Query API ----------------
function input_check(action)          { return global.input.state[action]; }
function input_check_pressed(action)  { return global.input.pressed[action]; }
function input_check_released(action) { return global.input.released[action]; }
function input_axis_x()               { return global.input.axis_x; }
function input_axis_y()               { return global.input.axis_y; }
function input_aim_x()                { return global.input.aim_x; }
function input_aim_y()                { return global.input.aim_y; }

// ---------------- Synthetic Testing API ----------------
function input_sim_enable(enable) {
    global.input.synthetic.active = enable;
    if (!enable) input_sim_clear();
}

function input_sim_clear() {
    var syn = global.input.synthetic;
    for (var a = 0; a < ACTION.COUNT; a++) {
        syn.state[a] = false;
        syn.pressed[a] = false;
        syn.released[a] = false;
    }
    syn.axis_x = 0;
    syn.axis_y = 0;
    syn.aim_x = 0;
    syn.aim_y = 0;
}

function input_sim_press(action) {
    var syn = global.input.synthetic;
    syn.state[action] = true;
    syn.pressed[action] = true;
}

function input_sim_release(action) {
    var syn = global.input.synthetic;
    syn.state[action] = false;
    syn.released[action] = true;
}

function input_sim_hold(action, held) {
    var syn = global.input.synthetic;
    syn.state[action] = held;
}

function input_sim_axes(ax, ay) {
    global.input.synthetic.axis_x = ax;
    global.input.synthetic.axis_y = ay;
}

function input_sim_aim(x, y) {
    global.input.synthetic.aim_x = x;
    global.input.synthetic.aim_y = y;
}

