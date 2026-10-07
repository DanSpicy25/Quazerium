# QUAZERIUM — REGISTRO DE CAMBIOS (CHANGELOG)
**Historial de Desarrollo, Hitos Técnicos y Evolución de Versiones**  
**Proyecto:** Quazerium (2D Action Platformer Nativo para PC en GameMaker LTS 2026 + GML)

---

## [0.2.0] — 2026-10-06 — FASE 08: EXPANSIÓN DE CONTENIDO Y ENCUENTROS JUGABLES
### Agregado
- **Director de Encuentros (`scripts/qz_director`, `obj_director`):** Orquestación centralizada de 5 encuentros tácticos diseñados a mano con oleadas progresivas y evaluación de victoria.
- **Catálogo de 5 Arquetipos de Enemigos:**
  - `obj_enemy_grunt`: Autómata bípedo con corte frontal básico.
  - `obj_enemy_fast`: Hostigador ultrarrápido con lunge cinético a 460 px/s y cuchillas dobles.
  - `obj_enemy_ranged`: Dron artillero flotante con lente cíclope y pernos de plasma teledirigidos.
  - `obj_enemy_heavy`: Juggernaut con blindaje de grafito y martillazo sísmico al suelo con onda expansiva.
  - `obj_enemy_elite`: Ejecutor Apex con corona dorada, sables dobles y ráfaga de combate avanzada.
- **Mecánica de Proyectiles Parriables (`obj_projectile_enemy`):**
  - Desvío con normal parry y **reflexión violenta hacia enemigos con Perfect Parry** (velocidad $+160\%$, daño multiplicado a 30, color cian neón).
- **Sistema de Spawn Seguro (`obj_enemy_spawner`):**
  - Balizas de advertencia holográfica previas de 0.75s para prevenir materializaciones injustas sobre el jugador.
- **Elementos Interactivos y Peligros de Escenario:**
  - `obj_hazard_electric`: Suelo electrificado cíclico (Dormant -> Warning -> Surge) que daña y aturde tanto a jugadores como a enemigos empujados hacia él.
  - `obj_launch_pad`: Placas de impulso neumático que lanzan al jugador o enemigos a $-860\text{ px/s}$.
  - `obj_energy_canister`: Capacitores destruibles que detonan con explosión elemental, dañan enemigos en 110 px y recargan $+25$ de energía.
- **HUD Táctico y Pantalla de Victoria Final:**
  - Conteo de hostiles activos, banner de encuentro, puntuación en tiempo real y tarjeta de victoria final con calificación de rango (D a S).
- **Expansión de la Suite de Pruebas (Tests 48 a 55):** 55 pruebas automatizadas pasando con éxito (`pass=55 fail=0`).

---

## [0.1.0-rc1] — 2026-10-06 — FASE 07: AUDITORÍA FINAL, VERIFICACIÓN Y RELEASE
### Agregado
- **Auditoría Técnica Completa:** Generación de `QUAZERIUM_FINAL_STATUS.md` con clasificación rigurosa de los 19 scripts y 13 objetos del proyecto (CORE, PRESENTATION, ENVIRONMENT, CONFIG, TEST).
- **Manual de Relevo Técnico:** Creación de `QUAZERIUM_NEXT_HANDOFF.md` para futuros desarrolladores, detallando subsistemas activos, invariantes críticas no modificables, pendientes conocidos y guía de extensión.
- **Registro Histórico de Cambios:** Creación de este documento (`QUAZERIUM_CHANGELOG.md`) documentando la progresión completa desde el esqueleto fundacional hasta la versión candidata de lanzamiento.
- **Validación Oficial de Compilación y Ejecución:**
  - `tools/build.ps1 -SelfTest`: 47 de 47 pruebas automatizadas pasando con código de salida 0.
  - `tools/build.ps1 -Timeout 5`: Compilación exitosa del paquete IFF de Windows (`Quazerium.win`) y lanzamiento verificado del ejecutable nativo sin excepciones.

---

## [0.0.7] — 2026-10-06 — FASE 06: RENDIMIENTO, PRESUPUESTOS DE HARDWARE Y QUALITY PROFILES
### Agregado
- **Presupuestos Formales de Hardware:** Definición de especificaciones y límites de memoria/renderizado para Intel Core i5-3470, Intel HD Graphics 2500 y HDD mecánico.
- **Acotación Dinámica de Pools sin Reasignación:**
  - Capacidad física fija en memoria: 2048 partículas (`VfxParticlePool`) y 128 calcas (`VfxDecalPool`).
  - Límite activo (`budget_limit`) ajustado dinámicamente según perfil de calidad:
    - LOW: 256 partículas, 16 calcas, 0 luces dinámicas, 0 distorsiones/afterimages.
    - MEDIUM: 768 partículas, 48 calcas, 2 luces volumétricas, 4 afterimages.
    - HIGH: 2048 partículas, 128 calcas, 6 luces volumétricas, 8 afterimages.
- **Telemetría de Diagnóstico F1:** Overlay en tiempo real que reporta FPS reales, tiempo de frame en microsegundos, perfil de calidad activo, conteo de partículas vivas vs presupuesto, calcas y luces.
- **Pruebas Automatizadas (Tests 45 a 47):** Verificación de escalado de presupuestos de partículas, calcas y luces dinámicas entre perfiles LOW y HIGH.

### Optimizado
- Eliminación de cualquier asignación de estructuras (`new struct` o creación de arreglos) durante el ciclo de ejecución de frames (`Step` y `Draw`).
- Comprobación de cero lecturas o escrituras de disco durante el gameplay (residencia 100% en RAM).

---

## [0.0.6] — 2026-10-06 — FASE 05: ACTION GAME HUD Y PULIDO VISUAL
### Agregado
- **Lienzo Virtual Responsivo:** Configuración de GUI desacoplada a $1280 \times 720$ píxeles fijos mediante `display_set_gui_size(1280, 720)`.
- **Bandeja de Vitalidad con Barra de Daño Retardado:** Barra de HP con interpolación lerp rápida de salud actual y barra blanca/amarilla de daño reciente que drena suavemente tras una pausa de impacto.
- **Medidor de Energía y Overdrive:** Indicador luminoso de energía con estado de ignición y pulsación cuando se alcanza el 100%.
- **Sistema de Rangos de Combo Arcade:** Badges vectoriales estilizados para rangos D, C, B, A y S basados en la racha de golpes y multiplicador de daño activo.
- **Capacitor Elemental:** Indicador visual en el HUD que muestra la sintonización elemental actual (Fuego, Agua, Tierra, Viento) y su color heráldico.
- **Mazo Táctico de Habilidades:** Iconos de habilidades (Shockwave, Blade Surge, Blink) con sombras de persiana radial/vertical que representan el tiempo de recarga en tiempo real.
- **Pantalla de Fallo Crítico (Game Over):** Desvanecimiento a rojo oscuro con glitch scanline y texto de reinicio rápido (presionar R / Dash / Jump).
- **Pruebas Automatizadas (Tests 43 y 44):** Validación de cálculo de vida normalizada y avance de multiplicador de combo en HUD.

---

## [0.0.5] — 2026-10-06 — FASE 04: ESCENARIO, ILUMINACIÓN Y PARALLAX
### Agregado
- **Composición de Escenario en 4 Planos:**
  - Plano 1 (Cielo/Megaestructura lejana): Desplazamiento parallax a $0.08\times$.
  - Plano 2 (Vigas intermedias y tuberías): Desplazamiento parallax a $0.24\times$.
  - Plano 3 (Zona de Juego): Geometría colisionable de plataformas con blindaje de fibra de carbono y chevrons de advertencia industrial.
  - Plano 4 (Siluetas en primer plano): Pasarelas y cables en sombra a $1.18\times$.
- **Iluminación Volumétrica 2D Aditiva:** Renderizado de fuentes de luz suaves (`gpu_set_blendmode(bm_add)`) en `Draw End` de `obj_environment`, escalable por perfil de calidad (desactivado en LOW).
- **Retícula Dinámica de Anclajes de Gancho:** `obj_grapple_anchor` con detección de proximidad magnética y renderizado de retícula de fijación cuando el jugador está en rango de disparo.
- **Pruebas Automatizadas (Tests 41 y 42):** Validación de factores de escala de parallax e inicialización geométrica de la arena.

---

## [0.0.4] — 2026-10-06 — FASE 03: COMBATE PROCEDURAL, ELEMENTOS Y OVERDRIVE
### Agregado
- **Capa Visual de Combate:** Chispas direccionales calculadas a partir del vector del impacto del arma (`obj_hitbox`).
- **Cortes de Sable Transversales:** Dibujo de trazos de espada poligonales con degradado alfa y duración temporal de 60 ms.
- **Aura de Overdrive:** Partículas de radiación de energía ascendente y destellos de superconducción al activar Overdrive.
- **Efectos de Reacciones Elementales:**
  - Evaporate (Vapor y humo espeso).
  - Melt (Lava y brasas ardientes).
  - Overload (Arco eléctrico y chispas azules).
  - Mud (Salpicadura densa de fango).
  - Sandstorm (Remolino de polvo arenoso).
  - Boil (Burbujas presurizadas y géiser de agua).
- **Textos de Combate Flotantes:** `VfxCombatTextPool` con tipografía de alto contraste, movimiento parabólico y dispersión angular anti-solapamiento.
- **Calcas de Impacto en Superficies:** `VfxDecalPool` con quemaduras de energía y cortes grabados en el suelo que desvanecen lentamente.
- **Pruebas Automatizadas (Tests 39 y 40):** Validación de emisión de eventos de combate y consistencia del estado Overdrive.

---

## [0.0.3] — 2026-10-06 — FASE 02: MOVIMIENTO, GAME-FEEL Y CÁMARA LOOKAHEAD
### Agregado
- **Chassis Procedural de Cyber-Ronin:** Renderizado vectorial en tiempo real del jugador (`obj_player`), eliminando placeholders estáticos.
  - Articulación procedural de extremidades (torso, cabeza, bufanda aerodinámica con física de resortes, sable de plasma).
  - Deformación squash & stretch en saltos, caídas y aterrizajes bruscos.
- **Estelas Fantasma (Afterimages):** Copias translúcidas del jugador coloreadas por cian o carmesí durante el dash y overdrive.
- **Partículas de Polvo Cinético:** Emisión de polvo al correr, deslizarse en paredes, saltar y estrellarse en picada (*slam*).
- **Cámara Cinematográfica con Lookahead Dinámico:**
  - Desplazamiento anticipado basado en el vector de velocidad horizontal del jugador.
  - Sesgo hacia el objetivo de anclaje durante el uso del gancho.
  - Decaimiento de trauma exponencial de sacudida (*shake* = $T^2$).
- **Pruebas Automatizadas (Tests 37 y 38):** Validación de cálculo de lookahead y amortiguación de cámara.

---

## [0.0.2] — 2026-10-06 — FASE 01: CAPA VISUAL BASE Y DESPACHADOR DE AUDIO
### Agregado
- **Arquitectura de Presentación:** Creación de los objetos singleton de renderizado `obj_vfx`, `obj_hud` y `obj_environment`.
- **Despachador de Audio Desacoplado (`qz_audio.gml`):** Enrutamiento de 15 eventos de gameplay a disparadores de sonido con variación procedural de pitch ($\pm 5\%$) y curvas de volumen.
- **Pruebas Automatizadas (Tests 32 a 36):** Ampliación de la suite de pruebas a 36 casos cubriendo el bus de audio y la inicialización de presentación.

---

## [0.0.1] — 2026-10-06 — ESQUELETO TÉCNICO FUNDACIONAL (CLAUDE)
### Agregado
- **Proyecto GameMaker Nativo:** Creación del árbol de directorios `Quazerium.yyp`, salas `rm_boot` y `rm_arena`.
- **Gestión de Tiempo (`qz_time.gml`):** Delta time independiente (`qz_dt()`), escala de tiempo dinámica, temporizadores de hitstop y clase `Cooldown`.
- **Entrada Abstracta (`qz_input.gml`):** Mapeo de acciones `ACTION.*` (Jump, Dash, Attack, Parry, Grapple, Power, Element, Overdrive) con soporte para teclado, ratón y gamepad.
- **Bus de Eventos Sincrónico (`qz_events.gml`):** Sistema Pub/Sub con registro `events_subscribe` y emisión inmediata `events_emit`.
- **Física Cinemática AABB (`qz_physics.gml`):** Movimiento por sub-pasos para prevenir atravesamiento a velocidades supersónicas.
- **Máquina de Estados del Jugador (`obj_player`):** FSM completa (IDLE, RUN, JUMP, FALL, WALL_SLIDE, DASH, SLAM, ATTACK, PARRY, GRAPPLE).
- **Sistema de Combate (`qz_combat.gml`, `obj_hitbox`):** Resolución de impactos, cajas transitorias de ataque y ventanas de parry dual (normal y perfecto).
- **Física de Gancho (`qz_grapple.gml`):** Simulación de resorte-amortiguador Kelvin-Voigt ($F = -k \cdot x - c \cdot v$).
- **Matriz Elemental (`qz_elements.gml`):** Matriz $4 \times 4$ de afinidades y reacciones químicas/energéticas.
- **Mazo de Habilidades (`qz_powers.gml`):** Registro de habilidades de combate (Shockwave, Blade Surge, Blink).
- **Inteligencia Artificial (`qz_ai.gml`, `obj_enemy_grunt`, `obj_enemy_dummy`):** Árboles de comportamiento con nodos de secuencia, selector y acción.
- **Suite de Pruebas Headless (`qz_selftest.gml`):** 31 pruebas unitarias automatizadas ejecutadas en el arranque.
- **Automatización de Compilación:** Script de PowerShell `tools/build.ps1` orquestando Igor LTS 2026.
