// =====================================================================
// QUAZERIUM — OBJ_VFX: Step event
// Updates all active particles, combat text, decals & screen flashes.
// =====================================================================

var dt = qz_raw_dt(); // Update with raw dt so effects don't stutter during hitstop

particle_pool.update(dt);
text_pool.update(dt);
decal_pool.update(dt);

if (flash_alpha > 0) {
    flash_alpha = max(0, flash_alpha - (flash_decay * dt));
}
