// =====================================================================
// QUAZERIUM — OBJ_CAMERA: Dynamic cinematic camera controller.
// Implements damping, look-ahead, trauma shake, impulse spring & event reactions.
// =====================================================================

var cfg = global.cfg.camera;
view_w = cfg.view_w;
view_h = cfg.view_h;

cam_x = x;
cam_y = y;
target_x = x;
target_y = y;

lookahead_x = 0;
zoom_val = 1.0;
zoom_pulse = 0.0;

trauma = 0.0;
impulse_x = 0.0;
impulse_y = 0.0;
impulse_vx = 0.0;
impulse_vy = 0.0;

// Setup GM view camera
view_enabled = true;
view_visible[0] = true;
camera_set_view_size(view_camera[0], view_w, view_h);

// Event listener for automated camera reactions
cam_event_handler = function(evt, payload) {
    var r = global.cfg.camera.reactions[evt];
    if (r != undefined) {
        // Add trauma
        var q_mult = quality_get().shake_mult;
        trauma = clamp(trauma + (r.trauma * q_mult), 0, 1.0);

        // Impulse (directional if available, otherwise omnidirectional)
        if (r.impulse > 0) {
            var dir = random(360);
            if (is_struct(payload)) {
                if (variable_struct_exists(payload, "dir_x") && variable_struct_exists(payload, "dir_y")) {
                    dir = point_direction(0, 0, payload.dir_x, payload.dir_y);
                } else if (variable_struct_exists(payload, "attacker") && variable_struct_exists(payload, "target")) {
                    var atkr = payload.attacker;
                    var trgt = payload.target;
                    if ((is_struct(atkr) || instance_exists(atkr)) && (is_struct(trgt) || instance_exists(trgt))) {
                        dir = point_direction(atkr.x, atkr.y, trgt.x, trgt.y);
                    }
                }
            } else if (evt == EVT.SLAM) {
                dir = 270; // downward thrust
            }
            impulse_vx += lengthdir_x(r.impulse * 30, dir);
            impulse_vy += lengthdir_y(r.impulse * 30, dir);
        }

        // Zoom pulse
        if (r.zoom > 0) {
            zoom_pulse = min(zoom_pulse + r.zoom, 0.25);
        }
    }
};

// Subscribe to key combat and gameplay events
for (var e = 0; e < EVT.COUNT; e++) {
    if (global.cfg.camera.reactions[e] != undefined) {
        events_subscribe(e, cam_event_handler, id);
    }
}

