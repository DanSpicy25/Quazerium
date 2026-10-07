// =====================================================================
// QUAZERIUM — OBJ_SOLID: Static level geometry and collision obstacle.
// =====================================================================

// Default block dimensions if unscaled
if (image_xscale == 1 && image_yscale == 1) {
    w = 64;
    h = 32;
} else {
    w = 32 * image_xscale;
    h = 32 * image_yscale;
}

solid_x1 = x;
solid_y1 = y;
solid_x2 = x + w;
solid_y2 = y + h;

