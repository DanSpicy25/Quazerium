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

// Continuous Overdrive Aura Plasma Particles
if (instance_exists(obj_player) && obj_player.overdrive_active) {
    var p = obj_player;
    var aura_count = (global.quality_level == QUALITY.LOW) ? 1 : 2;
    for (var a = 0; a < aura_count; a++) {
        particle_pool.spawn(p.x + random_range(-12, 12), p.y + random_range(-8, 16),
                            random_range(-20, 20), random_range(-80, -180), 0, -100,
                            3, 0.8, c_yellow, c_orange, random_range(0.2, 0.4), VFX_SHAPE.POINT, 0.85);
    }
}

