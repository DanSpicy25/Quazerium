// =====================================================================
// QUAZERIUM — OBJ_SOLID: Sacred Brutalism & Monolithic Basalt Render
// Carved megalithic slabs, woodcut diagonal hatchings, bone-white ledge trim,
// and chiseled relic-gold runic inlays. Stark clarity without sci-fi clutter.
// =====================================================================

var c_ink_shadow = make_color_rgb(10, 12, 16);
var c_basalt_bg  = make_color_rgb(22, 24, 30);
var c_slab_face  = make_color_rgb(32, 35, 44);
var c_seam_dark  = make_color_rgb(14, 16, 20);
var c_hatch      = make_color_rgb(46, 50, 62);
var c_bone_edge  = make_color_rgb(238, 235, 224);
var c_rune_gold  = make_color_rgb(180, 145, 60);
var c_moss_base  = make_color_rgb(52, 64, 48);

var x1 = variable_instance_exists(id, "solid_x1") ? solid_x1 : x;
var y1 = variable_instance_exists(id, "solid_y1") ? solid_y1 : y;
var x2 = variable_instance_exists(id, "solid_x2") ? solid_x2 : (x + 64);
var y2 = variable_instance_exists(id, "solid_y2") ? solid_y2 : (y + 32);

var p_w = x2 - x1;
var p_h = y2 - y1;

// 1. Ambient Drop-Shadow beneath floating monolithic slabs
if (y2 < room_height - 64) {
    draw_set_color(c_ink_shadow);
    draw_set_alpha(0.45);
    draw_rectangle(x1 + 4, y2, x2 - 4, y2 + 16, false);
    draw_set_alpha(1.0);
}

// 2. Base Monolithic Basalt Slab Body
draw_set_color(c_basalt_bg);
draw_rectangle(x1, y1, x2, y2, false);

// 3. Segmented Megalithic Blocks with Chiseled Seams & Woodcut Hatchings
var block_w = 64;
var num_blocks = max(1, floor(p_w / block_w));

for (var b = 0; b < num_blocks; b++) {
    var bx1 = x1 + (b * block_w) + 2;
    var bx2 = min(x2 - 2, x1 + ((b + 1) * block_w) - 2);
    
    if (bx2 > bx1) {
        // Block Face
        draw_set_color(c_slab_face);
        draw_rectangle(bx1, y1 + 3, bx2, y2 - 3, false);
        
        // Woodcut Diagonal Shadow Hatching
        draw_set_color(c_hatch);
        var hatch_start = bx1 + 4;
        var hatch_end   = bx2 - 4;
        for (var hx = hatch_start; hx < hatch_end; hx += 10) {
            var hy_top = y1 + 6;
            var hy_bot = min(y2 - 6, y1 + 6 + (bx2 - hx));
            var hx_bot = min(bx2 - 2, hx + (hy_bot - hy_top));
            draw_line(hx, hy_top, hx_bot, hy_bot);
        }
        
        // Chiseled Vertical Megalith Joint Seam
        draw_set_color(c_seam_dark);
        draw_line_width(bx2 + 1, y1, bx2 + 1, y2, 2);
    }
}

// 4. Muted Weathered Moss along Bottom Foundation
if (p_h >= 32) {
    draw_set_color(c_moss_base);
    draw_set_alpha(0.35);
    draw_rectangle(x1 + 2, y2 - 6, x2 - 2, y2 - 1, false);
    draw_set_alpha(1.0);
}

// 5. Monolithic Outer Perimeter Chisel Border
draw_set_color(c_seam_dark);
draw_rectangle(x1, y1, x2, y2, true);

// 6. Sacred Bone-White Top Platform Rail (100% Collision & Jump Readability)
draw_set_color(c_bone_edge);
draw_line_width(x1, y1, x2, y1, 2);

// Corner Bone Accents (Chiseled keystones on edges)
draw_point(x1, y1 + 1);
draw_point(x1 + 1, y1);
draw_point(x2 - 1, y1);
draw_point(x2, y1 + 1);

// 7. Chiseled Relic-Gold Geometric Runic Inlays on Substantial Slabs
if (p_w >= 64 && p_h >= 48) {
    var rune_cx = x1 + (p_w * 0.5);
    var rune_cy = y1 + (p_h * 0.5);
    var r_size  = 8;
    
    draw_set_color(c_rune_gold);
    draw_set_alpha(0.65);
    // Diamond rune glyph
    draw_line(rune_cx, rune_cy - r_size, rune_cx + r_size, rune_cy);
    draw_line(rune_cx + r_size, rune_cy, rune_cx, rune_cy + r_size);
    draw_line(rune_cx, rune_cy + r_size, rune_cx - r_size, rune_cy);
    draw_line(rune_cx - r_size, rune_cy, rune_cx, rune_cy - r_size);
    // Center point
    draw_point(rune_cx, rune_cy);
    draw_set_alpha(1.0);
}
