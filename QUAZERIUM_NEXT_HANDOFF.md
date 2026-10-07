# QUAZERIUM — MANUAL DE RELEVO TÉCNICO (NEXT HANDOFF)
**Guía para el Próximo Ingeniero, Diseñador o Artista Técnico**  
**Versión del Proyecto:** `0.1.0-release-candidate`  
**Motor:** GameMaker LTS 2026 (GML Nativo)  
**Target:** Windows PC (Arquitectura x64)

---

## 1. INTRODUCCIÓN Y PROPÓSITO

Este documento es la **guía maestra de relevo técnico** para cualquier desarrollador, artista técnico o diseñador que asuma el proyecto *Quazerium* a partir de este punto.

El proyecto ha completado exitosamente su **Fase 07**. El esqueleto técnico (Core), los sistemas de combate, física de gancho, reacciones elementales, habilidades, presentación procedural, HUD responsivo, perfiles de hardware y suite de pruebas automatizadas están **100% funcionales, integrados y compilando nativamente** con GameMaker Igor CLI.

---

## 2. ARQUITECTURA GENERAL Y CONTRATO DE DISEÑO

### Regla de Oro: Desacoplamiento Core vs. Presentation
*Quazerium* mantiene una separación estricta entre la **simulación lógica** y el **renderizado visual**:

```text
┌──────────────────────────────────────────────┐
│                    CORE                      │
│   (Física, Hitboxes, Input, Tiempo, IA,      │
│    Estadísticas, Elementos, FSM de Jugador)  │
└──────────────────────┬───────────────────────┘
                       │ Emite eventos sincrónicos
                       ▼ events_emit(EVT.*, payload)
┌──────────────────────────────────────────────┐
│                PRESENTATION                  │
│   (obj_player Draw, obj_camera, obj_vfx,     │
│    obj_hud, obj_environment, qz_audio)      │
└──────────────────────────────────────────────┘
```

1. **El Core NUNCA debe saber que existe el HUD, las partículas o la cámara.**
2. Ningún script de física o combate debe llamar funciones de dibujo (`draw_*`), ni consultar el estado de una animación o partícula.
3. Si ocurre algo relevante en la simulación (impacto, parry, salto, cambio de estado, muerte), el Core invoca `events_emit(EVT_..., struct)`. Los oyentes de presentación reaccionan en consecuencia.

---

## 3. MAPA DE ARCHIVOS Y ESTRUCTURA DEL CÓDIGO

### Scripts (`scripts/`)
| Archivo | Dominio | Propósito |
| :--- | :--- | :--- |
| `qz_macros.gml` | Arquitectura | Enumeraciones globales (`ACTION`, `STATE`, `EVT`, `ELEMENT`, `QUALITY`, `POWER_ID`). |
| `qz_config.gml` | Ajustes | Parámetros ajustables de física, combate, cámara, tiempos de parry y presupuestos. |
| `qz_math.gml` | Matemáticas | Utilidades vectoriales, funciones clamp, lerp angular y distancia Manhattan. |
| `qz_time.gml` | Núcleo | Delta time suavizado (`qz_dt()`), time scale, hitstop no acumulativo y constructor `Cooldown`. |
| `qz_input.gml` | Entrada | Capa abstracta `input_check`, `input_check_pressed`, soporte gamepad e inyección sintética para tests. |
| `qz_events.gml` | Comunicación | Bus de eventos sincrónico `events_subscribe`, `events_emit`, `events_unsubscribe_owner`. |
| `qz_physics.gml` | Cinemática | Resolución de colisiones AABB con sub-stepping para proyectiles y movimiento a alta velocidad. |
| `qz_stats.gml` | Jugador/Enemigos | Modificadores de daño, energía, multiplicadores de combo y consumo de recursos. |
| `qz_combat.gml` | Combate | Instanciación de `obj_hitbox`, resolución de impactos y cálculo matemático de daño/parry. |
| `qz_grapple.gml` | Gancho | Simulación física de resorte-amortiguador Kelvin-Voigt ($F = -k \cdot x - c \cdot v$). |
| `qz_elements.gml` | Elementos | Matriz bidimensional de reacciones elementales (Fuego, Agua, Tierra, Viento). |
| `qz_powers.gml` | Habilidades | Registro y ejecución de habilidades activas (Shockwave, Blade Surge, Blink). |
| `qz_ai.gml` | IA | Árboles de comportamiento modulares (Sequence, Selector, Action, Condition). |
| `qz_pool.gml` | Memoria | Estructuras de pooling de tamaño fijo para objetos reutilizables. |
| `qz_vfx_pool.gml` | Renderizado | Implementación de `VfxParticlePool`, `VfxDecalPool` y `VfxCombatTextPool`. |
| `qz_quality.gml` | Hardware | Perfiles LOW, MEDIUM, HIGH con presupuestos de partículas, calcas y luces. |
| `qz_audio.gml` | Sonido | Despachador de eventos sonoros con modulación procedural de tono. |
| `qz_selftest.gml` | QA | Suite de 47 pruebas automatizadas headless ejecutables en boot. |

### Objetos (`objects/`)
- `obj_bootstrap`: Punto de entrada del juego (`rm_boot`). Inicializa subsistemas, ejecuta self-test si se solicita y transiciona a `rm_arena`.
- `obj_player`: Entidad del jugador. Posee FSM de 9 estados, cinemática y renderizado procedural de cyber-ronin.
- `obj_solid`: Plataformas colisionables del escenario con textura de blindaje de carbono y chevrons de advertencia.
- `obj_grapple_anchor`: Puntos de enganche para la cuerda del gancho con retícula magnética de proximidad.
- `obj_hitbox`: Cajas de daño transitorias generadas por ataques del jugador o enemigos.
- `obj_enemy_dummy`: Maniquí de entrenamiento inmóvil con estadísticas de vida y registro de daño para pruebas.
- `obj_enemy_grunt`: Enemigo bípedo con árbol de comportamiento (patrulla, persecución, ataque cuerpo a cuerpo).
- `obj_camera`: Cámara cinematográfica con suavizado lerp, anticipación por velocidad (*lookahead*), sesgo hacia el gancho y trauma shake cuadrático.
- `obj_vfx`: Singleton de efectos visuales. Gestiona pools de partículas, calcas en suelo y textos flotantes.
- `obj_hud`: Singleton de interfaz de usuario. Renderiza barra de vida, energía, rangos de combo (D-S), capacitor elemental y cartas de habilidad en lienzo de $1280 \times 720$.
- `obj_environment`: Singleton de ambiente. Dibuja el fondo parallax de 4 planos y las luces 2D aditivas.

---

## 4. LO QUE FUNCIONA (SUBSISTEMAS VERIFICADOS)

1. **Movimiento del Jugador:** Correr, acelerar, frenar, salto variable, caída rápida, tiempo coyote (90 ms), buffer de salto (120 ms), salto de pared con bloqueo direccional, dash en 8 direcciones y caída en picada (*slam*).
2. **Combate Cuerpo a Cuerpo:** Cadena de 3 cortes con sable de plasma, golpe cargado, ventana dual de parry (Normal $\le 300\text{ ms}$, Perfecto $\le 120\text{ ms}$) y estado Overdrive al 100% de energía.
3. **Gancho Dinámico:** Detección de anclaje más cercano en cono frontal, proyección elástica de cable Kelvin-Voigt con impulso tangencial al soltar.
4. **Alquimia Elemental:** Reacciones bidireccionales entre Fuego, Agua, Tierra y Viento con multiplicadores de daño y efectos visuales dedicados.
5. **Habilidades Activas:** Shockwave (aturdimiento radial), Blade Surge (tajo de traslación rápida) y Blink (teletransporte horizontal).
6. **Cámara Cinematográfica:** Seguimiento cinético con lookahead por velocidad horizontal y decaimiento de sacudida exponencial.
7. **Presentación Procedural y VFX:** Deformación squash & stretch en sprites vectoriales, estelas fantasma de dash, chispas direccionales, calcas de suelo y textos flotantes.
8. **HUD de Acción:** Lienzo virtual independiente de la resolución de ventana, barra de daño diferido (*hp lag*), medidor de combo con rangos D, C, B, A, S y persianas de tiempo de recarga en iconos de habilidades.
9. **Perfiles de Rendimiento:** Cambio fluido entre LOW, MEDIUM y HIGH en caliente (F2, F3, F4) con acotación de pools sin reasignación de memoria.
10. **Suite de Pruebas:** 47 de 47 pruebas unitarias pasando (`tools/build.ps1 -SelfTest`).

---

## 5. LO QUE FALTA O REQUIERE TRABAJO FUTURO

### A. Archivos Binarios de Audio (Prioridad P1)
- **Estado Actual:** `scripts/qz_audio/qz_audio.gml` contiene el despachador de eventos completo, las curvas de atenuación de volumen y la modulación de tono aleatoria ($\pm 5\%$). Sin embargo, las llamadas actuales hacen fallback seguro a consola porque **no se han importado archivos binarios `.wav` o `.ogg` al árbol de recursos de GameMaker**.
- **Qué hacer:**
  1. Crear o importar efectos de sonido (golpe, tajo de sable, parry, gancho, explosión elemental, salto, dash).
  2. Registrar los recursos en `Quazerium.yyp` como sonidos nativos (`snd_sword_swing`, `snd_hit_impact`, `snd_parry_perfect`, etc.).
  3. Vincular los identificadores en el mapa de `qz_audio_play_sound()`.

### B. Director de Olas y Encuentros (Prioridad P2)
- **Estado Actual:** `rm_arena` tiene una disposición estática con un maniquí (`obj_enemy_dummy`) y un enemigo bípedo (`obj_enemy_grunt`). Al eliminarlos, la sala queda vacía hasta que se reinicia con la tecla `R`.
- **Qué hacer:**
  1. Crear un objeto `obj_wave_manager` o `obj_encounter_director`.
  2. Implementar rondas progresivas que generen enemigos en puntos de spawn fuera de la vista de la cámara.
  3. Emitir eventos de inicio y finalización de oleada para mostrarlos en el HUD.

### C. Catálogo Expandido de Enemigos (Prioridad P3)
- **Estado Actual:** Existen el maniquí y el soldado bípedo cuerpo a cuerpo.
- **Qué hacer:**
  1. Implementar un dron volador (`obj_enemy_drone`) utilizando el árbol de comportamiento de `qz_ai.gml` con comportamientos de vuelo errático y proyectiles teledirigidos.
  2. Implementar un enemigo acorazado con escudo que requiera un ataque cargado o parry perfecto para romper su guardia.

### D. Interfaz de Configuración y Menú de Pausa (Prioridad P3)
- **Estado Actual:** Los perfiles de calidad se alternan con teclas de depuración (F2, F3, F4). No hay menú visual de pausa ni pantalla de inicio.
- **Qué hacer:**
  1. Diseñar un menú principal en una nueva sala `rm_menu`.
  2. Implementar pantalla de opciones con selección de resolución, pantalla completa, volumen maestro/SFX/música y perfil de calidad.
  3. Implementar reasignación de teclas para teclado y gamepad en `qz_input.gml`.

---

## 6. INVARIANTES CRÍTICAS (QUÉ NO SE DEBE ROMPER)

1. **NO Asignar Memoria en los Loops de Juego:**
   - Nunca ejecutes `new StructName()` o crees arreglos dinámicos dentro de eventos `Step`, `Draw` o `Draw GUI`.
   - Utiliza exclusivamente los pools pre-asignados (`VfxParticlePool`, `VfxDecalPool`, `VfxCombatTextPool`) en `qz_vfx_pool.gml`.
2. **NO Alterar el Tamaño Virtual del Lienzo de GUI:**
   - La GUI se inicializa con `display_set_gui_size(1280, 720)` en `obj_hud.gml`. Todo el posicionamiento de barras, fuentes y cartas asume este espacio de coordenadas virtuales de $1280 \times 720$.
3. **NO Eliminar el Sub-stepping de Física:**
   - El ciclo de sub-pasos en `qz_physics.gml` garantiza que dashes a 750 px/s o caídas a 1150 px/s no atraviesen plataformas finas.
4. **NO Mezclar Lógica de Simulación con Renderizado:**
   - Mantén todas las llamadas a `events_emit()` como el único puente de comunicación hacia la cámara, partículas, HUD y sonido.
5. **NO Modificar la Firma de `tools/build.ps1`:**
   - La suite de CI y las herramientas de automatización dependen de los parámetros `-SelfTest`, `-Run`, `-Config` y `-Timeout`.

---

## 7. CÓMO COMPILAR Y EJECUTAR

### Requisitos Previos
- Windows 10/11 x64.
- GameMaker LTS 2026 instalado en la ruta estándar (`C:\ProgramData\GameMakerStudio2\Cache\runtimes\...`).
- PowerShell 5.1 o superior.

### Comandos de Terminal

#### 1. Ejecutar Suite de Pruebas Automatizadas (Headless)
Ejecuta la compilación con Igor y corre las 47 pruebas unitarias sin abrir ventana visual:
```powershell
powershell -ExecutionPolicy Bypass -File tools/build.ps1 -SelfTest
```
*Salida esperada:* Código de salida 0 con línea `QZ_SELFTEST_RESULT pass=47 fail=0`.

#### 2. Compilar y Ejecutar el Juego Interactivamente
Compila el proyecto y lanza la ventana nativa de Windows:
```powershell
powershell -ExecutionPolicy Bypass -File tools/build.ps1 -Run
```

#### 3. Compilación Limpia
Fuerza una recompilación completa desde cero limpiando la caché de Igor:
```powershell
powershell -ExecutionPolicy Bypass -File tools/build.ps1 -Clean -Run
```

---

## 8. CONTROLES Y TECLAS DE DEPURACIÓN

### Controles de Jugador
- **Moverse:** `A` / `D` o Flechas Izquierda / Derecha (Stick izquierdo en Gamepad).
- **Saltar:** `Espacio` o Botón `A` en Gamepad.
- **Dash:** `Shift` o Gatillo `RT` en Gamepad (8 direcciones según movimiento sostenido).
- **Ataque con Sable:** `J` o Clic Izquierdo (Botón `X` en Gamepad). Mantener para ataque cargado.
- **Parry / Bloqueo:** `K` o Clic Derecho (Botón `B` en Gamepad).
- **Gancho:** `E` o Botón `Y` en Gamepad (Dispara al anclaje en retícula).
- **Caída en Picada (Slam):** Presionar Abajo (`S`) + Dash o Salto en el aire.
- **Habilidades (Poderes):** `1` (Shockwave), `2` (Blade Surge), `3` (Blink).
- **Cambio de Elemento:** `Q` (Cicla entre Fuego, Agua, Tierra, Viento).
- **Overdrive:** `F` (Activa superconducción al 100% de energía).
- **Reiniciar Sala:** `R`.

### Teclas de Depuración (Ingeniería)
- **`F1`:** Alternar Overlay de Telemetría (FPS reales, microsegundos de frame, conteo de partículas, calcas, luces).
- **`F2`:** Forzar Perfil de Calidad **LOW** (Ajustado para Intel HD 2500 / 0 luces / 256 partículas máx).
- **`F3`:** Forzar Perfil de Calidad **MEDIUM** (Equilibrado / 2 luces / 768 partículas máx).
- **`F4`:** Forzar Perfil de Calidad **HIGH** (Calidad máxima / 6 luces / 2048 partículas máx).

---

## 9. GUÍA RÁPIDA DE EXTENSIÓN

### ¿Cómo agregar un nuevo poder?
1. Abre `scripts/qz_macros/qz_macros.gml` y agrega el identificador al enum:
   ```gml
   enum POWER_ID {
       NONE,
       SHOCKWAVE,
       BLADE_SURGE,
       BLINK,
       TU_NUEVO_PODER // <-- Aquí
   }
   ```
2. Abre `scripts/qz_powers/qz_powers.gml` y regístralo en `qz_powers_init()`:
   ```gml
   qz_power_register(POWER_ID.TU_NUEVO_PODER, "Nombre", cooldown_segundos, coste_energia, function(_caster) {
       // Lógica de simulación del poder
       events_emit(EVT.POWER_CAST, { power_id: POWER_ID.TU_NUEVO_PODER, x: _caster.x, y: _caster.y });
   });
   ```
3. Abre `objects/obj_hud/Draw_64.gml` y asigna el icono o texto en la bandeja de cartas de habilidades.

### ¿Cómo agregar un nuevo tipo de enemigo?
1. Crea el nuevo objeto en `objects/obj_enemy_xyz/` heredando de la estructura base de enemigos.
2. En su evento `Create`, inicializa sus estadísticas (`hp`, `max_hp`, `speed`, `element`) y su árbol de IA instanciando nodos de `qz_ai.gml`:
   ```gml
   ai_root = new AiSelector([
       new AiSequence([ new AiCondition(check_attack_range), new AiAction(do_attack) ]),
       new AiSequence([ new AiCondition(check_player_spotted), new AiAction(do_chase) ]),
       new AiAction(do_patrol)
   ]);
   ```
3. En su evento `Step`, evalúa el árbol: `ai_root.tick(id)`.
4. En el evento `Draw`, dibuja la silueta o sprite respetando el perfil de calidad activo.
