// =====================================================================
// QUAZERIUM — OBJ_VFX: World Space Render
// Renders decals, particles and floating combat text.
// =====================================================================

// 1. Decals (faint surface marks)
decal_pool.draw();

// 2. Additive particles (sparks, shockwaves, rings)
var use_additive = quality_get().enable_shaders;
if (use_additive) {
    gpu_set_blendmode(bm_add);
}

particle_pool.draw();

if (use_additive) {
    gpu_set_blendmode(bm_normal);
}

// 3. Floating Combat Text
text_pool.draw();
