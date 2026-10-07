# QUAZERIUM — TECHNICAL SKELETON & GEMINI HANDOFF MANUAL
**Version:** 0.1.0-skeleton  
**Engine:** GameMaker LTS 2026 (GML)  
**Target Hardware:** Native Windows PC (Validated for Intel Core i5-3470 / Intel HD Graphics 2500 / HDD)  
**Status:** **SKELETON COMPLETE · 31/31 AUTOMATED TESTS PASSING**

---

## 1. Executive Summary & Architect Contract

Claude has engineered the complete **Core Engine, Gameplay Systems, Physics, and Test Harness** for *Quazerium*. The project is a pure native GameMaker/GML project (`Quazerium.yyp`), compiled and verified natively via Igor CLI and GameMaker LTS 2026.

### The Decoupling Contract
```
┌────────────────────────────────────────────────────────────────────────┐
│                        CORE (Claude's Domain)                          │
│  State Machines · Kinematic Physics · Event Bus · Time/Hitstop         │
│  Combat Math · 2D Elemental Matrix · Behavior Trees · Object Pools     │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │ Emits Synchronous Events (EVT.*)
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│                    PRESENTATION (Gemini's Domain)                      │
│  Sprite Animations · Particle Systems · GLSL Shaders · Audio / SFX     │
│  Screen Shakes / Flash · Floating Combat Text · Polished HUD / UI      │
└────────────────────────────────────────────────────────────────────────┘
```
**Strict Rule:** Core gameplay logic **never** queries presentation assets (e.g., does not check if a particle exists or if a sprite has finished playing to resolve damage). Core resolves hits, elements, and cooldowns immediately, then emits events on `events_emit(EVT.*, payload)`. Presentation listens to these events and renders visual/audio feedback.

---

## 2. Directory & Component Structure

### Scripts (`scripts/`)
| Script | Folder | Responsibility |
| :--- | :--- | :--- |
| `qz_macros.gml` | `Scripts/Core` | Enums (`ACTION`, `EVT`, `PSTATE`, `ESTATE`, `ELEMENT`, `POWER_ID`, `QUALITY`, `BT_STATUS`), version and debug macros. |
| `qz_config.gml` | `Scripts/Core` | Centralized game tuning parameters (`global.cfg`). Frame-independent values (seconds/pixels). |
| `qz_math.gml` | `Scripts/Core` | Allocation-free math helpers: `qz_approach`, `qz_damp`, `qz_aabb_overlap`, `qz_entity_exists`, `qz_var_exists`. |
| `qz_events.gml` | `Scripts/Core` | Synchronous event dispatcher with owner unsubscription and circular event history ring buffer. |
| `qz_time.gml` | `Scripts/Core` | Delta time manager (`qz_dt()`, `qz_raw_dt()`), time scale, hitstop queue, cooldown object (`new Cooldown()`). |
| `qz_input.gml` | `Scripts/Core` | Abstract input layer (`ACTION.*`). Decouples hardware keys and gamepads. Includes synthetic simulation API (`input_sim_*`). |
| `qz_stats.gml` | `Scripts/Gameplay` | `StatModifierContainer` for data-driven, timed buffs/debuffs (e.g., Overdrive +60% damage, +20% move speed). |
| `qz_combat.gml` | `Scripts/Gameplay` | Combat resolution, damage formula (`base * overdrive * combo * reaction`), hitbox spawner, parry window evaluator. |
| `qz_elements.gml` | `Scripts/Gameplay` | 2D lookup reaction matrix (FIRE, EARTH, WATER, WIND) yielding Vaporize, Swirl, Magma, Mud, Freeze, Erosion. |
| `qz_powers.gml` | `Scripts/Gameplay` | Extensible abilities registry (Shockwave, Blade Surge, Blink) with costs, cooldowns, and lifecycle callbacks. |
| `qz_grapple.gml` | `Scripts/Gameplay` | Dynamic spring-pendulum grapple hook (`F = -k*x - c*v`), reel in, angle swing, sling release jump. |
| `qz_physics.gml` | `Scripts/Gameplay` | Kinematic sub-stepped AABB collision resolver against `obj_solid` to prevent tunneling. |
| `qz_interaction.gml`| `Scripts/Gameplay` | Wall-Tech mechanics (wall slide friction, wall jump velocity impulse, input lock duration). |
| `qz_ai.gml` | `Scripts/AI` | Behavior Trees (`BT_Sequence`, `BT_Selector`, `BT_Action`, `BT_Condition`) and `Blackboard` data container. |
| `qz_quality.gml` | `Scripts/Performance` | Hardware quality profiles (`LOW`, `MEDIUM`, `HIGH`) tuning particle limits, shaders, and visual density. |
| `qz_pool.gml` | `Scripts/Performance` | Allocation-free generic object/struct recycling pool (`ObjectPool`). |
| `qz_selftest.gml` | `Scripts/Debug` | 31 headless unit and integration test assertions covering all 17 subsystems. |

### Objects (`objects/`)
| Object | Layer | Purpose |
| :--- | :--- | :--- |
| `obj_game` | Persistent | Master bootstrapper, calls subsystems init, processes Step_1 input/time updates, handles F1/F2/F5 global hotkeys. |
| `obj_camera` | `rm_arena` | Cinematic trauma-shake camera (`trauma^2 * max_shake`), spring impulses, lookahead smoothing, and `EVT.*` reaction table. |
| `obj_debug` | `rm_arena` | F1 telemetry HUD (FPS, memory/delta, player FSM state, velocities, active cooldowns, recent event log). |
| `obj_solid` | Geometry | Static collision geometry with procedural outline accents. |
| `obj_grapple_anchor` | Environment| Grapple target with interactive distance indicator and latch anchor point. |
| `obj_hitbox` | Dynamic | Attack hitbox resolving hits against target hurtboxes via `combat_resolve_hit`. |
| `obj_player` | Entity | 9-state Player FSM (`PSTATE.*`), coyote time, jump buffering, 8-way dash, slam, 3-hit combo, parry, powers, grapple. |
| `obj_enemy_base` | Entity | Base polymorphic enemy class with health bar, hurtbox, knockback, stun recovery, and element status tracking. |
| `obj_enemy_grunt` | Entity | Aggressive melee grunt driven by Behavior Tree (chase -> windup -> attack -> recover). |
| `obj_enemy_dummy` | Entity | Heavy punching dummy for combat testing and DPS measurement. |

---

## 3. Events Reference (`EVT.*`)

Gemini should subscribe to these events using `events_subscribe(EVT, callback, owner_id)`:

```gml
// Presentation example in Gemini's VFX controller:
events_subscribe(EVT.HIT_CONFIRMED, function(evt, data) {
    // data.attacker, data.target, data.damage, data.is_crit, data.element, data.reaction
    spawn_floating_damage_number(data.target.x, data.target.y, data.damage, data.is_crit);
    spawn_hit_spark(data.target.x, data.target.y, data.element);
}, id);
```

| Event | Payload Struct | Description / Presentation Hook |
| :--- | :--- | :--- |
| `EVT.PLAYER_ATTACK` | `{ player: id, attack_index: 0..2, is_charged: bool }` | Spawn weapon swing trail, slash arc, play swing sound. |
| `EVT.HIT_CONFIRMED` | `{ attacker, target, damage, is_crit, element, reaction }` | Hit spark, camera impulse, floating white damage number. |
| `EVT.HIT_CRITICAL` | `{ attacker, target, damage, is_crit, element, reaction }` | Big slash burst, camera zoom pulse, golden damage number. |
| `EVT.HIT_EVADED` | `{ target, hitbox }` | "EVADED" text or shadow blur silhouette. |
| `EVT.PARRY` | `{ defender, attacker, hitbox }` | Blue parry ring, sparks, deflection sound. |
| `EVT.PERFECT_PARRY`| `{ defender, attacker, hitbox }` | Heavy time freeze, gold shockwave, cinematic screen flash. |
| `EVT.DASH` | `{ player, dir_x, dir_y }` | Ghost trails (after-images), speed lines, dash woosh SFX. |
| `EVT.SLAM` | `{ player, x, y }` | Heavy ground impact dust, crater decal, screen shake. |
| `EVT.JUMP` | `{ player, is_wall_jump: bool }` | Jump dust puff under feet. |
| `EVT.LAND` | `{ player, vy: number }` | Landing dust, footstep audio based on fall velocity. |
| `EVT.WALL_JUMP` | `{ player, wall_dir: -1|1 }` | Wall scratch sparks, directional push trail. |
| `EVT.POWER` | `{ player, power_id, config }` | Ability visual VFX (Shockwave blast / Blade Surge dash / Blink glitch). |
| `EVT.POWER_END` | `{ player, power_id }` | Power lingering trail fades out. |
| `EVT.OVERDRIVE` | `{ player, duration }` | Aura flare, chromatic aberration or vignette pulse, energetic music transition. |
| `EVT.OVERDRIVE_END`| `{ player }` | Aura extinguish, steam particle release. |
| `EVT.ENERGY_FULL` | `player` | Overdrive meter glow, audible chime indicating readiness. |
| `EVT.ELEMENT_APPLIED`| `{ target, element }` | Elemental status tint (Fire=orange glow, Water=blue droplets, Earth=rock armor, Wind=swirl lines). |
| `EVT.ELEMENT_REACTION`| `{ target, reaction, element_a, element_b }` | Big reaction banner ("VAPORIZE!", "FREEZE!", "MAGMA!"), special explosion particles. |
| `EVT.ELEMENT_CHANGED`| `{ player, element }` | Weapon glow color changes to active element. |
| `EVT.GRAPPLE_FIRE` | `{ player, target_x, target_y }` | Project hook head / chain link rope render. |
| `EVT.GRAPPLE_ATTACH`| `{ player, anchor_x, anchor_y }` | Hook latch clank sound, taught tension rope jitter. |
| `EVT.GRAPPLE_RELEASE`| `{ player, sling_boost: bool }` | Rope retract sound, wind cone if sling boosted. |
| `EVT.GRAPPLE_SLING` | `{ player, vx, vy }` | Sling jump trail, high-altitude zoom out. |
| `EVT.ENTITY_KILLED` | `{ victim, killer }` | Death animation, disintegrate / dissolve shader, loot/particles. |
| `EVT.PLAYER_DIED` | `player` | Player defeat sequence, screen desaturation. |
| `EVT.ENEMY_ATTACK_WINDUP`| `{ enemy, duration }` | Enemy eye flash / red telegraph exclamation mark. |
| `EVT.ENEMY_ATTACK` | `{ enemy }` | Enemy attack swing animation and SFX. |
| `EVT.ENEMY_STUNNED`| `{ enemy, duration }` | Dizzy stars / stun spiral over enemy head. |
| `EVT.HITSTOP` | `duration` | Micro freeze frame (handled automatically by `qz_time`). |
| `EVT.QUALITY_CHANGED`| `new_quality_level` | Presentation re-adjusts particle caps and shader uniforms. |

---

## 4. Input & Controls

Inputs are completely decoupled via `qz_input.gml`.
Gameplay queries `input_check(ACTION.*)`, `input_check_pressed(ACTION.*)`, and `input_check_released(ACTION.*)`.

| Action (`ACTION.*`) | Keyboard Binding | Gamepad Binding | Gameplay Function |
| :--- | :--- | :--- | :--- |
| `MOVE_LEFT` | A / Left Arrow | D-Pad Left / Left Stick Left | Walk / Run Left |
| `MOVE_RIGHT` | D / Right Arrow | D-Pad Right / Right Stick Right | Walk / Run Right |
| `MOVE_UP` | W / Up Arrow | D-Pad Up / Left Stick Up | Aim Grapple Up / Up Dash |
| `MOVE_DOWN` | S / Down Arrow | D-Pad Down / Left Stick Down | Fast fall / Slam (Air) |
| `JUMP` | Space | Button South (A / Cross) | Variable height Jump / Wall Jump |
| `DASH` | Shift / C | Button East (B / Circle) / Right Trigger | 8-way directional Dash with iframes |
| `ATTACK` | J / Left Mouse | Button West (X / Square) | 3-Hit Combo Chain / Charged Attack (Hold) |
| `PARRY` | K / Right Mouse | Button North (Y / Triangle) / Left Bumper | 120ms Perfect Parry window / Counter |
| `GRAPPLE` | E / Middle Mouse | Right Bumper | Latch to Anchor / Swing / Sling Jump |
| `POWER` | Q / F | Left Trigger | Cast Selected Power |
| `POWER_SELECT`| 1, 2, 3 | D-Pad Left / Up / Right | Select Shockwave (1), Blade Surge (2), Blink (3) |
| `ELEMENT` | Tab | Right Stick Press (R3) | Cycle Elements (None -> Fire -> Earth -> Water -> Wind) |
| `OVERDRIVE` | R / Space+Shift | Left Stick Press (L3) + R3 | Unleash Overdrive mode (at 100 Energy) |

### Global Utility Hotkeys
- **F1:** Toggle Debug Telemetry Overlay (`obj_debug`).
- **F2:** Cycle Hardware Quality Level (`LOW` -> `MEDIUM` -> `HIGH`).
- **F5:** Quick Restart Room.
- **Escape:** Exit Game.

---

## 5. Hardware Quality Profiles (`LOW` vs `MEDIUM` vs `HIGH`)

Targeted specifically for the primary low-end benchmark (**Intel Core i5-3470 / Intel HD Graphics 2500**):

| Quality Level | Particle Budget | Shaders Enabled | Decal Lifetime | Screen Shake Mult | Post-Processing |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **LOW (HD 2500)** | 100 max | `false` | 2.0s | 0.6x | Off (Vertex blending only) |
| **MEDIUM** | 600 max | `true` | 8.0s | 1.0x | Simple bloom & distortion |
| **HIGH** | 2000 max | `true` | 30.0s | 1.2x | Full volumetric, chromatic, bloom |

Query the active profile in presentation code anytime via:
```gml
var q = quality_get();
if (q.enable_shaders) {
    // activate Gemini's custom shader
}
```

---

## 6. How to Build, Test, and Run

All build operations use the native Igor CLI script:
```powershell
# 1. Run Automated Test Suite (31 unit & integration tests)
powershell -ExecutionPolicy Bypass -File tools/build.ps1 -SelfTest

# 2. Build and launch game interactively into rm_arena
powershell -ExecutionPolicy Bypass -File tools/build.ps1
```

---

## 7. Next Steps for Gemini (Visuals, Polish & Content)

Gemini can now build entirely on top of this skeleton without modifying core logic:
1. **Art & Sprites:** Replace procedural shapes in `Draw_0` of `obj_player`, `obj_enemy_*`, and `obj_solid` with animated sprite sheets using the `state` variables (`p.state`, `enemy.state`).
2. **Juice & Particles:** Create particle types in a Presentation controller listening to `EVT.HIT_CONFIRMED`, `EVT.DASH`, `EVT.SLAM`, `EVT.PARRY`.
3. **Sound FX & Music:** Connect an audio manager to the `EVT.*` bus for hit sounds, wooshes, clanks, and dynamic Overdrive music.
4. **Shaders:** Introduce chromatic aberration on `EVT.HIT_CRITICAL`, shockwave distortion on `EVT.POWER` (Shockwave), and speed lines during `EVT.DASH` (conditioned on `quality_get().enable_shaders`).
5. **HUD Art:** Replace the prototype debug health bars and meters with final game UI.
