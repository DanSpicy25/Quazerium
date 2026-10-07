// =====================================================================
// QUAZERIUM — OBJ_ENEMY_SPAWNER: Draw Event
// Futuristic holographic warp column and contracting warning ring.
// =====================================================================

var prog = clamp(1.0 - (timer / max(0.01, total_time)), 0, 1);
var alpha_pulse = 0.5 + (sin(current_time * 0.03) * 0.3);

// Vertical laser indicator
draw_set_color(make_color_rgb(255, 45, 65));
draw_set_alpha(alpha_pulse * 0.7);
draw_line_width(x, y - 120, x, y + 10, 2);

// Contracting ground ring
var ring_r = 28 * (1.0 - prog * 0.7);
draw_set_color(make_color_rgb(255, 200, 40));
draw_set_alpha(alpha_pulse);
draw_circle(x, y + 6, ring_r, true);

// Ground crosshair
draw_set_color(make_color_rgb(255, 60, 80));
draw_line(x - 12, y + 6, x + 12, y + 6);
draw_line(x, y - 6, x, y + 18);
draw_set_alpha(1.0);
