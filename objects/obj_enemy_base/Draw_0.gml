// =====================================================================
// QUAZERIUM — OBJ_ENEMY_BASE: Procedural enemy render & HUD
// =====================================================================

var c_body = make_color_rgb(220, 60, 60);
if (state == ESTATE.WINDUP) c_body = make_color_rgb(255, 140, 0); // Orange flash during windup (parry cue!)
if (state == ESTATE.STUNNED) c_body = make_color_rgb(120, 120, 220); // Blue when stunned

// Body
draw_set_color(c_body);
draw_rectangle(x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh, false);
draw_set_color(c_black);
draw_rectangle(x - bbox_hw, y - bbox_hh, x + bbox_hw, y + bbox_hh, true);

// Eye / Facing visor
draw_set_color(c_yellow);
var eye_x = x + (facing * (bbox_hw - 4));
draw_circle(eye_x, y - 4, 3, false);

// Health bar
if (hp < max_hp && max_hp < 9999) {
    var bar_w = 32;
    var bar_h = 4;
    var bx = x - (bar_w / 2);
    var by = y - bbox_hh - 8;
    var pct = clamp(hp / max_hp, 0, 1);

    draw_set_color(c_black);
    draw_rectangle(bx - 1, by - 1, bx + bar_w + 1, by + bar_h + 1, false);
    draw_set_color(c_red);
    draw_rectangle(bx, by, bx + (bar_w * pct), by + bar_h, false);
}

// Element indicator badge
if (element_status != ELEMENT.NONE) {
    var c_elem = c_white;
    switch (element_status) {
        case ELEMENT.FIRE:  c_elem = c_orange; break;
        case ELEMENT.WATER: c_elem = c_aqua; break;
        case ELEMENT.EARTH: c_elem = make_color_rgb(160, 110, 60); break;
        case ELEMENT.WIND:  c_elem = c_lime; break;
    }
    draw_set_color(c_elem);
    draw_circle(x, y - bbox_hh - 12, 4, false);
}

