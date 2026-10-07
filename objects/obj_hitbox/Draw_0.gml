// Pellet woodcut tracer streak
if (is_pellet && (vx != 0 || vy != 0)) {
    var p_ang = point_direction(0, 0, vx, vy);
    var tail_len = 16;
    var tx = x - lengthdir_x(tail_len, p_ang);
    var ty = y - lengthdir_y(tail_len, p_ang);
    
    // Core bone streak
    draw_set_color(color);
    draw_line_width(x, y, tx, ty, 3);
    // Dark ink shadow fringe
    draw_set_color(make_color_rgb(14, 15, 18));
    draw_line_width(x, y, tx, ty, 1);
    // Tip spark
    draw_set_color(c_white);
    draw_circle(x, y, 2, false);
}

if (instance_exists(obj_debug) && obj_debug.visible) {
    draw_set_color(c_red);
    draw_rectangle(x, y, x + bbox_w, y + bbox_h, true);
    draw_set_alpha(0.2);
    draw_rectangle(x, y, x + bbox_w, y + bbox_h, false);
    draw_set_alpha(1.0);
}

