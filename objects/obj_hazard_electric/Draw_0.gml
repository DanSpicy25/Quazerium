// =====================================================================
// QUAZERIUM — OBJ_HAZARD_ELECTRIC: Draw Event
// Conductive industrial grid with electric discharge arcs.
// =====================================================================

var c_base = make_color_rgb(18, 22, 28);
var c_border = make_color_rgb(45, 55, 70);

// Base conductive plate
draw_set_color(c_base);
draw_rectangle(x, y, x + hazard_w, y + hazard_h, false);
draw_set_color(c_border);
draw_rectangle(x, y, x + hazard_w, y + hazard_h, true);

if (cycle_state == 1) {
    // Warning state: pulsing amber hazard stripes
    var pulse = 0.5 + (sin(current_time * 0.04) * 0.4);
    draw_set_color(make_color_rgb(255, 160, 20));
    draw_set_alpha(pulse);
    for (var s = x + 10; s < x + hazard_w; s += 20) {
        draw_line_width(s, y + 2, s + 8, y + hazard_h - 2, 2);
    }
    draw_set_alpha(1.0);
} else if (cycle_state == 2) {
    // Active Surge: crackling electric arcs and high-voltage blue discharge
    draw_set_color(make_color_rgb(0, 210, 255));
    draw_rectangle(x + 2, y + 2, x + hazard_w - 2, y + hazard_h - 2, false);

    // Jagged electric arcs
    draw_set_color(c_white);
    var t_step = current_time * 0.01;
    for (var a = 0; a < 3; a++) {
        var start_x = x + (a * 45) + 10;
        var mid_x   = start_x + 15 + (sin(t_step + a) * 8);
        var end_x   = start_x + 35;
        var arc_y   = y - 6 - (sin(t_step * 2 + a) * 8);
        draw_line(start_x, y + 4, mid_x, arc_y);
        draw_line(mid_x, arc_y, end_x, y + 4);
    }
}
