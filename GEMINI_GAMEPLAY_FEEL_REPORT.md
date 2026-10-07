# QUAZERIUM — GAMEPLAY FEEL + PHYSICS + COMBAT + VISUAL FOUNDATION REPORT
## Focus: "Outsider No More: Echoes of the God" Gameplay Skeleton Refinement

---

## 1. Executive Summary

This report documents the deep gameplay feel, kinetic physics, combat tuning, hitbox architecture, and visual styling refinement executed on the **Quazerium** native GameMaker LTS 2026 engine.

The core technical skeleton has transitioned from a rigid, floaty prototype into an agile, highly tactile action foundation engineered for *"Outsider No More: Echoes of the God"*. The game now features fluid momentum-based air mobility, responsive combat cancels, generous point-blank hitbox coverage with decoupled hurtboxes, stabilized pendulum grapple physics with angular governor clamping, and an aesthetic pivot to **Sacred Brutalism & Cosmic Woodcut**.

All 63 automated headless tests pass (`pass=63, fail=0`), and standalone Windows execution has been verified directly via the native runtime.

---

## 2. Problems Identified & Root Causes

### 2.1 Movement & Air Jumps
- **Problem:** Double jump felt unresponsive or would be accidentally consumed on ground takeoff, leaving the player with no air recovery options.
- **Root Cause:** Single jump state without discrete air-jump counters; landing logic did not explicitly restore an independent air jump allowance.

### 2.2 Dash & Action Chaining
- **Problem:** Dash locked the player into a fixed duration, preventing fluid combat cancels or momentum conversions.
- **Root Cause:** `PSTATE.DASH` lacked cancel interrupts for incoming attacks (`ACTION.ATTACK`) and grounded jump buffering (`ACTION.JUMP`).

### 2.3 Grapple "Runaway Spin" & Orbital Loop Bug
- **Problem:** When latching onto a ceiling grapple point and holding lateral movement keys, the player would enter an accelerating infinite circular spin around the anchor point.
- **Root Cause:** Radial spring physics continuously applied tangential acceleration on every frame without angular velocity clamping or angular drag. Once angular speed exceeded a critical threshold, centrifugal velocity overcame gravity, locking the entity into endless orbital rotation.

### 2.4 Camera Grapple Viewport Jerking
- **Problem:** Swinging on a grapple caused the camera to fight the player, jerking violently towards the anchor point instead of tracking trajectory.
- **Root Cause:** `obj_camera/Step_2.gml` was lerping the viewport camera center towards `p.grapple.hook_x` by 22% every frame (`lerp(target_x, hook_x, 0.22)`), pulling the screen toward the ceiling anchor rather than looking ahead in the player's movement direction.

### 2.5 Close-Range Sword "Ghost Swing" Deadzone
- **Problem:** When an enemy was hugging or touching the player directly, sword attacks would pass right through them without dealing damage or registering hits.
- **Root Cause:** Attack chain hitboxes were positioned at `ox = 30` with `w = 48..60`, while the player half-width was `bbox_hw = 12`. Any enemy standing between the player center (`x`) and `x + 30` fell inside an absolute blind spot between the player core and the hitbox starting position.

### 2.6 Hitbox / Hurtbox Architectural Coupling
- **Problem:** Collision detection for attacks was directly querying physical bounding boxes (`bbox_left`, `bbox_top`, etc.), which were sized strictly for obstacle navigation and ledge walking.
- **Root Cause:** Lack of decoupled combat hurtboxes. Physical collision bodies must be slim to prevent platform snagging, whereas combat hurtboxes require slightly larger, generous registration volumes to feel fair and satisfying.

---

## 3. Engineering & Gameplay Solutions Implemented

### 3.1 Movement & Double Jump
- **Independent Resource:** Added `air_jumps_left` initialized from `global.cfg.player.max_air_jumps = 1`.
- **Takeoff Protection:** Ground jump only consumes ground state and preserves `air_jumps_left`. Double jump is strictly triggered in air (`!on_ground`) after exhausting coyote time (`coyote_timer <= 0`), consuming `air_jumps_left`.
- **Ground & Wall Reset:** Landing on solid ground (`on_ground == true`) or performing a wall-jump immediately replenishes `air_jumps_left = 1`.
- **Kinetic Feedback:** Distinct vertical squash & stretch applied on double jump (`0.70x / 1.45y`), dispatching event payload `EVT.JUMP` with `{ double_jump: true }`.

### 3.2 Responsive Dash & Wave-Dash
- **Attack Cancelling:** Inside `PSTATE.DASH`, pressing `ACTION.ATTACK` immediately transitions into `PSTATE.ATTACK` (clearing dash timer and preserving horizontal momentum for forward lunging slashes).
- **Grounded Wave-Dash (Jump Cancel):** Pressing `ACTION.JUMP` during a grounded dash immediately converts horizontal dash speed into a low-angle forward aerial launch (`vy = -pcfg.jump_speed`, preserving high lateral velocity).
- **Hook Dash Cancel:** In `PSTATE.HOOK`, pressing `ACTION.DASH` immediately severs grapple tension and bursts the player in the aimed direction.

### 3.3 Physics-Assisted Pendulum Grapple
- **Vector Decomposition:** Decomposed swing velocity into radial tension and tangential velocity components (`tang_x = -sin_t`, `tang_y = cos_t`).
- **Active Directional Assistance:** Player input along the swing trajectory applies active tangential acceleration (`cfg.swing_accel = 850`), allowing dynamic pumping of swing height.
- **Counter-Braking:** Pressing opposite to the current tangential motion applies active counter-braking drag (`tang_v *= 0.88`), allowing instant arrest of unwanted swings.
- **Angular Velocity Governor:** Clamped tangential speed via `max_angular_speed = 950 deg/s` and applied constant angular damping (`angular_damping = 0.94`).
- **Anti-Loop Apex Dissipation:** When entity angle rises above the horizontal plane towards the ceiling anchor (`sin_t < -0.85`), vertical lift is softly attenuated by `0.78`, breaking runaway loop-the-loop orbits and ensuring a natural parabolic release.

### 3.4 Camera Tracking & Swing Framing
- **Eliminated Anchor Pull:** Removed the artificial 22% camera pull towards the grapple anchor.
- **Velocity-Directed Lookahead:** Replaced with smooth lookahead based on player velocity (`target_x += clamp(p.vx * 0.22, -180, 180)`), framing the player's upcoming trajectory while preserving smooth framing during acrobatic swings.

### 3.5 Sword Deadzone Fix & Generous Hitbox Geometry
- **Offset Calibration:** Repositioned attack offsets in `scripts/qz_config/qz_config.gml`:
  - Attack 1: `ox: -8`, `w: 64`, `h: 40`, `y: -18` (covers point-blank, player core, and front reach).
  - Attack 2: `ox: -10`, `w: 72`, `h: 46`, `y: -22` (rising sweep covering upper body and hugging targets).
  - Attack 3 (Finisher): `ox: -12`, `w: 96`, `h: 52`, `y: -26` (monolithic heavy cleave).
  - Charged Attack: `ox: -14`, `w: 110`, `h: 58`, `y: -28`.
- **Zero Deadzone:** Touching or hugging enemies (`dist <= 6px`) now cleanly fall inside the hitbox bounding area.

### 3.6 Decoupled Hurtbox Architecture
- **Hurtbox Accessor:** Created `entity_get_hurtbox(inst)` in `scripts/qz_combat/qz_combat.gml`:
  - Returns explicit `hurtbox_hw` / `hurtbox_hh` if defined on entity.
  - Defaults to `bbox_hw + 2` / `bbox_hh + 2` if not set.
- **Physical Decoupling:** Physical collision body (`bbox_hw = 12`) remains tight for smooth ledge and gap traversal, while combat hurtbox (`hurtbox_hw = 16`, `hurtbox_hh = 24`) provides fair, consistent attack registration.
- **Attacker Micro-Recoil:** Registered hits apply a discrete micro-recoil deceleration (`attacker.vx *= 0.55`) alongside global hitstop, delivering visceral kinetic weight.

### 3.7 Visual Foundation: Sacred Brutalism & Cosmic Woodcut
- **Color Palette:**
  - Ink Black: `make_color_rgb(14, 15, 18)`
  - Basalt Stone Dark: `make_color_rgb(28, 30, 36)`
  - Basalt Stone Mid: `make_color_rgb(52, 56, 66)`
  - Bone White: `make_color_rgb(238, 235, 224)`
  - Relic Gold: `make_color_rgb(212, 175, 55)`
  - Sacred Crimson: `make_color_rgb(180, 32, 42)`
  - Muted Moss: `make_color_rgb(52, 64, 48)`
- **Player Aesthetics (`obj_player/Draw_0.gml`):**
  - Monolithic carved basalt chassis with woodcut diagonal etch hatchings.
  - Stark bone mask with narrow hollow eye slit emitting a cosmic amber/crimson ember.
  - Procedural Prayer Talisman Streamer Ribbons: 4-segment trailing prayer cloth ribbons undulating with player velocity, marked with ink calligraphy ticks.
  - Monolithic Executioner Greatblade: Weathered stone core with razor bone cutting edge and sweeping woodcut ink-and-bone brush crescent arcs during swings.
  - Sacred Geometric Mandala Parry Aegis: Concentric rotating diamond/circle stone seal in relic gold and bone white.
  - Grapple Chain & Reliquary Harpoon: Braided dark iron chain links interspersed with bone prayer beads, terminating in a barbed three-pronged ancient harpoon.
- **Environment Aesthetics (`obj_solid/Draw_0.gml`):**
  - Megalithic carved basalt slabs with deep chiseled seam joints and woodcut shadow hatchings.
  - Crisp bone-white top platform rail (width 2) guaranteeing 100% platforming contrast and readability.
  - Geometric relic-gold runic inlays etched into substantial slabs.
  - Weathered moss creeping along bottom foundations; zero generic caution tape or sci-fi conduits.

---

## 4. Automated Verification & Testing

### 4.1 Test Suite Expansion
Added tests 45 through 48 in `scripts/qz_selftest/qz_selftest.gml`:
- **Test 45:** Movement & Double Jump Ground Reset (verifies consumption of air jump resource and instant reset on landing).
- **Test 46:** Close-Range Sword Hitbox Zero-Distance Overlap (verifies `ox = -8, w = 64` eliminates point-blank blind spot).
- **Test 47:** Decoupled Combat Hurtbox Architecture (verifies `entity_get_hurtbox` isolates combat volume from physical body).
- **Test 48:** Grapple Angular Governor Clamping (verifies `max_angular_speed = 950` and `angular_damping = 0.94` stabilize swings).

### 4.2 Test Execution Results
```powershell
powershell -ExecutionPolicy Bypass -File tools/build.ps1 -SelfTest
```
**Output:**
```text
QZ_SELFTEST_RESULT pass=63 fail=0
SELFTEST pass=63 fail=0
```

### 4.3 Standalone Build & Native Execution
```powershell
powershell -ExecutionPolicy Bypass -File tools/build.ps1
```
**Output:**
```text
BUILD SUCCESSFUL
Executable: C:\Users\Valdez\Documents\Quazerium\build\Quazerium\Quazerium.exe
```

Runtime launch verification confirmed the executable initializes, loads assets, starts GameMaker game loop, and runs natively on Windows without crashes.

---

## 5. File Modification Ledger

| File Path | Description of Changes |
| :--- | :--- |
| `scripts/qz_config/qz_config.gml` | Added `double_jump_speed: 740`, `max_air_jumps: 1`; tuned grapple angular damping (`0.94`) and angular speed limit (`950`); repositioned sword attack hitbox chain with negative x-offsets (`ox: -8..-14`). |
| `scripts/qz_combat/qz_combat.gml` | Added `entity_get_hurtbox(inst)` to decouple combat hurtboxes from physical collision bounding boxes; added attacker kinetic micro-recoil (`attacker.vx *= 0.55`). |
| `scripts/qz_grapple/qz_grapple.gml` | Implemented tangential vector decomposition, directional swing assist, active counter-braking, angular velocity governor, and anti-loop apex damping. |
| `scripts/qz_selftest/qz_selftest.gml` | Expanded self-test suite from 44 to 48 component test blocks (63 total passing unit assertions). |
| `objects/obj_player/Create_0.gml` | Initialized `air_jumps_left`, decoupled `hurtbox_hw/hh`, and added `talisman_ribbons` array for procedural ribbon physics. |
| `objects/obj_player/Step_0.gml` | Implemented double-jump air check & ground reset; added attack/jump cancels during Dash; added dash cancel during Grapple Hook; added ribbon trailing physics. |
| `objects/obj_player/Draw_0.gml` | Complete procedural render pivot to Sacred Brutalism & Cosmic Woodcut (carved basalt chassis, bone mask, talisman streamers, woodcut executioner blade, sacred mandala aegis). |
| `objects/obj_solid/Draw_0.gml` | Procedural render pivot to Monolithic Carved Basalt Megaliths with woodcut diagonal hatchings, bone-white ledge rail, and relic-gold runic inlays. |
| `objects/obj_enemy_base/Create_0.gml` | Initialized explicit `hurtbox_hw/hh` decoupled combat hurtbox dimensions. |
| `objects/obj_enemy_base/Draw_0.gml` | Added woodcut diagonal hatch etchings and occult eye ember styling. |
| `objects/obj_hitbox/Step_0.gml` | Integrated `entity_get_hurtbox` in collision sweep loops for player and enemy targets. |
| `objects/obj_camera/Step_2.gml` | Removed jarring anchor pin camera pull during grapple; implemented smooth velocity-directed lookahead. |
| `tools/test_launch.ps1` | Created automated native executable launch and lifecycle verification utility. |

---

## 6. Conclusion

The gameplay feel, physics, combat geometry, and visual foundation are now completely aligned with the aesthetic and mechanical vision of *"Outsider No More: Echoes of the God"*. The project compiles cleanly, all 63 unit tests pass without regressions, and the standalone Windows executable is built and verified.
