// =====================================================================
// QUAZERIUM — OBJ_CAMERA: End Step tracking & post-simulation render positioning
// =====================================================================

var dt = qz_raw_dt(); // Camera always updates with real time to allow smooth shake during hitstop
var cfg = global.cfg.camera;

// 1. Follow Target (Player)
if (instance_exists(obj_player)) {
    var p = obj_player;

    // Look-ahead based on facing and horizontal velocity
    var target_look = p.facing * cfg.lookahead_x;
    lookahead_x = qz_damp(lookahead_x, target_look, cfg.lookahead_half_life, dt);

    target_x = p.x + lookahead_x;
    target_y = p.y + cfg.offset_y;

    // Follow smoothing (freeze if configured during hitstop)
    if (!global.time.in_hitstop || !cfg.hitstop_freeze_follow) {
        cam_x = qz_damp(cam_x, target_x, cfg.follow_half_life, dt);
        cam_y = qz_damp(cam_y, target_y, cfg.follow_half_life, dt);
    }
}

// 2. Spring Impulses: F = -k*x - c*v
var fx = (-cfg.impulse_k * impulse_x) - (cfg.impulse_c * impulse_vx);
var fy = (-cfg.impulse_k * impulse_y) - (cfg.impulse_c * impulse_vy);
impulse_vx += fx * dt;
impulse_vy += fy * dt;
impulse_x += impulse_vx * dt;
impulse_y += impulse_vy * dt;

// 3. Trauma Decay & Shake
if (trauma > 0) {
    trauma = max(0, trauma - (cfg.trauma_decay * dt));
}
var shake_amount = power(trauma, 2) * cfg.max_shake;
var shake_ox = (random_range(-1, 1) * shake_amount);
var shake_oy = (random_range(-1, 1) * shake_amount);

// 4. Zoom Pulse Decay
if (zoom_pulse > 0) {
    zoom_pulse = max(0, zoom_pulse - (cfg.zoom_pulse_decay * dt));
}
var effective_zoom = cfg.zoom - zoom_pulse;
var cur_w = view_w / effective_zoom;
var cur_h = view_h / effective_zoom;

// 5. Apply Final Camera Position & Bounds Clamp
var final_x = cam_x - (cur_w / 2) + impulse_x + shake_ox;
var final_y = cam_y - (cur_h / 2) + impulse_y + shake_oy;

final_x = clamp(final_x, 0, max(0, room_width - cur_w));
final_y = clamp(final_y, 0, max(0, room_height - cur_h));

camera_set_view_size(view_camera[0], cur_w, cur_h);
camera_set_view_pos(view_camera[0], final_x, final_y);

