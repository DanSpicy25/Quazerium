// =====================================================================
// QUAZERIUM — OBJ_ENVIRONMENT: Foreground Layer & Dynamic 2D Lighting (Draw End)
// Executes in world coordinates on top of all gameplay entities.
// Provides foreground parallax (1.18x), volumetric spotlights, and entity glows.
// =====================================================================

var cam = view_camera[0];
var cx = camera_get_view_x(cam);
var cy = camera_get_view_y(cam);
var cw = camera_get_view_width(cam);
var ch = camera_get_view_height(cam);

// ---------------------------------------------------------------------
// 1. DYNAMIC VOLUMETRIC LIGHTING PASS (Quality-controlled)
// ---------------------------------------------------------------------
if (quality_get().enable_lighting) {
    gpu_set_blendmode(bm_add);

    // 1.1 Arena Industrial Downward Spotlight Cones
    for (var s = 0; s < array_length(spotlights); s++) {
        var sp = spotlights[s];
        var s_alpha = sp.alpha * (0.85 + (sin((time_t * 2.0) + s) * 0.15));
        draw_set_color(sp.col);
        draw_set_alpha(s_alpha);

        // Downward atmospheric light trapezoid / cone
        draw_triangle(sp.x, sp.y - 180, sp.x - (sp.span * 0.5), sp.y + 220, sp.x + (sp.span * 0.5), sp.y + 220, false);
        draw_set_alpha(s_alpha * 0.5);
        draw_circle(sp.x, sp.y + 200, sp.span * 0.45, false);
    }

    // 1.2 Entity Luminescence & Readability Anchors
    if (instance_exists(obj_player)) {
        var p = obj_player;
        var p_col = p.overdrive_active ? make_color_rgb(255, 215, 0) : make_color_rgb(0, 220, 255);
        var p_rad = p.overdrive_active ? 48 : 28;
        var p_alpha = p.overdrive_active ? 0.28 : 0.14;

        draw_set_color(p_col);
        draw_set_alpha(p_alpha);
        draw_circle(p.x, p.y, p_rad, false);
    }

    // Enemy warning glows
    with (obj_enemy_base) {
        var e_col = (state == ESTATE.WINDUP) ? make_color_rgb(255, 60, 20) : make_color_rgb(220, 40, 40);
        var e_rad = (state == ESTATE.WINDUP) ? 42 : 24;
        var e_alpha = (state == ESTATE.WINDUP) ? 0.25 : 0.12;

        draw_set_color(e_col);
        draw_set_alpha(e_alpha);
        draw_circle(x, y - 2, e_rad, false);
    }

    // Grapple node magnetic halos
    with (obj_grapple_anchor) {
        draw_set_color(make_color_rgb(0, 240, 255));
        draw_set_alpha(0.12 + (sin(pulse_timer * 2.0) * 0.06));
        draw_circle(x, y, 32, false);
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1.0);
}

// ---------------------------------------------------------------------
// 2. FOREGROUND SILHOUETTE FRAMING (1.18x Faster Parallax)
// ---------------------------------------------------------------------
var px_fg = cx * 0.18;
var c_fg_pillar = make_color_rgb(8, 10, 14);

// Subtle foreground vertical pillars framing the camera edges
var fg_spacing = 720;
var fg_start = floor((cx - px_fg - 100) / fg_spacing);
var fg_end   = ceil((cx - px_fg + cw + 100) / fg_spacing);

draw_set_color(c_fg_pillar);
for (var f = fg_start; f <= fg_end; f++) {
    var fx = (f * fg_spacing) + px_fg;
    // Structural foreground diagonal strut
    draw_line_width(fx, cy - 20, fx + 120, cy + ch + 20, 14);
    // Suspended cable bundle
    draw_line_width(fx + 24, cy - 20, fx + 30, cy + ch + 20, 3);
}

// ---------------------------------------------------------------------
// 3. CINEMATIC CAMERA VIGNETTE (Focus Play Space)
// ---------------------------------------------------------------------
var v_thick = 36;
draw_set_color(make_color_rgb(4, 6, 10));
draw_set_alpha(0.35);
draw_rectangle(cx, cy, cx + cw, cy + v_thick, false);
draw_rectangle(cx, cy + ch - v_thick, cx + cw, cy + ch, false);
draw_rectangle(cx, cy, cx + v_thick, cy + ch, false);
draw_rectangle(cx + cw - v_thick, cy, cx + cw, cy + ch, false);
draw_set_alpha(1.0);
