# QUAZERIUM — GAMEPLAY FEEL, REDISEÑO, ARENA, PERSONAJE Y ARMAMENTO
## Reporte Técnico y de Diseño: "Outsider No More: Echoes of the God"

---

## 1. Estado Inicial

Al iniciar esta fase, Quazerium contaba con:
- Una máquina de estados finitos (FSM) para el jugador con 9 estados (`PSTATE`).
- Sistemas de colisiones cinemáticas por barrido con sub-stepping.
- Un gancho de agarre con física radial básica basada en resortes (`F = -k*x - c*v`).
- Combate inicial con espada y combos en cadena.
- Una arena de pruebas en `rm_arena` configurada a 1920x1080 con plataformas dispersas y un pilar vertical en $x=950$ que dividía la sala.
- Una cámara con vista a 1280x720 siguiendo al jugador con lookahead horizontal.
- 63 pruebas unitarias automatizadas (`qz_selftest`) pasando con 0 fallos.

---

## 2. Problemas Detectados

A pesar de que el código base compilaba y funcionaba, la experiencia de juego ("gameplay feel") presentaba fricciones críticas:

1. **Geometría de la Arena y Gancho Descontrolado:**
   - La arena de 1920x1080 era demasiado espaciosa y difusa.
   - Existía un pilar vertical intermedio (`x=950, y=580`, 224px de altura) colocado en medio del espacio aéreo.
   - El sistema de gancho (`find_target`) no realizaba comprobaciones de línea de visión (`collision_line`), lo que permitía anclarse a objetivos detrás del muro. Al tensarse la cuerda a través de la esquina sólida, el jugador quedaba atrapado en oscilaciones circulares infinitas o giros erráticos.
2. **Falta de Control en la Cuerda:**
   - La física del gancho no permitía extender la cuerda o liberarse de forma segura al chocar o rozar obstáculos.
3. **Identidad Visual del Personaje:**
   - El renderizado procedural del jugador era un bloque genérico estilo cibernético que no transmitía la visión artística de *"Sacred Brutalism / Cosmic Woodcut"*.
4. **Armamento Limitado a Espada:**
   - No existía un arma a distancia con peso e impacto cinético que contrastara con la espada de corto alcance.
5. **Resolución y Escalado de Ventana:**
   - No había inicialización explícita de `window_set_size(1280, 720)` ni `surface_resize(application_surface, 1280, 720)` en `obj_game`, lo que podía producir discrepancias en el aspect ratio de la ventana y los bordes del HUD.

---

## 3. Cambios Realizados y Archivos Modificados

| Archivo | Modificación Principal |
| :--- | :--- |
| `scripts/qz_macros/qz_macros.gml` | Enums `WEAPON_ID` (SWORD, SHOTGUN), `RELOAD_STATE` (IDLE, RELOADING, RECOVERING); acciones `WEAPON_SWAP`, `RELOAD`; nuevos eventos de escopeta en `EVT`. |
| `scripts/qz_config/qz_config.gml` | Bloque `global.cfg.shotgun` (daño, dispersión, pellets, retroceso de -420px, ventana de recarga activa perfecta de 0.46 a 0.58); reacciones de cámara ante disparos. |
| `scripts/qz_input/qz_input.gml` | Mapeo de `WEAPON_SWAP` (`Q`, `1`/`2`, rueda de ratón) y `RELOAD` (`R`); remapeo de `OVERDRIVE` (`V`/`G`). |
| `scripts/qz_combat/qz_combat.gml` | `combat_shotgun_fire(p)`, `combat_shotgun_reload_start(p)`, `combat_shotgun_reload_press(p)`, `combat_shotgun_reload_update(p, dt)`. |
| `scripts/qz_grapple/qz_grapple.gml` | Filtrado estricto por línea de visión en `find_target`; desacople seguro ante oclusión de obstáculos en `ATTACHED`; control de longitud de cuerda (`MOVE_UP` / `MOVE_DOWN`). |
| `objects/obj_grapple_anchor/Draw_0.gml` | Rediseño a Llave Reliquiaria de Basalto y Hueso (*Sacred Brutalism*); comprobación de oclusión visual en el hilo de apuntado. |
| `objects/obj_player/Create_0.gml` | Variables de armamento, estado de recarga activa, temporizador de retroceso, rotación de halo y torsión del torso. |
| `objects/obj_player/Step_0.gml` | Gestión de cambio de arma; disparo de escopeta y recarga activa; cancelación de dash con escopeta; actualización cinemática procedural. |
| `objects/obj_player/Draw_0.gml` | Rediseño completo a **Stickman Modular Ceremonial** (máscara de hueso con cuernos de cresta, halo celestial rotatorio, torso de tinta segmentado, piernas articuladas con rodilleras de hueso, cintas de talismán rituales, trabuco de basalto con fogonazo xilográfico y reloj radial de recarga activa). |
| `objects/obj_hitbox/Create_0.gml` | Soporte para proyectiles con propiedades `is_pellet`, `vx`, `vy`, `color`. |
| `objects/obj_hitbox/Step_0.gml` | Simulación de trayectoria balística e impacto contra `obj_solid`. |
| `objects/obj_hitbox/Draw_0.gml` | Renderizado de estela de trazador de grabado xilográfico (núcleo blanco hueso con sombra de tinta). |
| `objects/obj_hud/Draw_64.gml` | Módulo de armamento activo, contador de cartuchos con brillo dorado para disparos potenciados y atajos actualizados. |
| `tools/manifest.json` | Rediseño total de `rm_arena` a un formato compacto (1440x810) sin muros divisorios centrales, con plataformas megalíticas y 3 anclas aéreas calculadas. |
| `objects/obj_game/Create_0.gml` | Configuración explícita de presentación 16:9 (`1280x720`). |
| `scripts/qz_selftest/qz_selftest.gml` | Ampliación a 68 pruebas automatizadas cubriendo escopeta, recarga activa (perfecta/fallida), cambio de arma y oclusión de gancho. |

---

## 4. Movimiento

- **Respuesta inmediata:** Fricción terrestre calibrada a 5200 px/s² y aceleración a 4200 px/s² para arranques y frenadas instantáneas sin inercia flotante.
- **Salto y Doble Salto:** Coyote time de 120 ms, buffer de salto de 120 ms. El salto terrestre preserva el contador `air_jumps_left = 1`. El doble salto aéreo se consume de forma explícita y se reinicia de inmediato al tocar el suelo o rebotar en paredes.
- **Dash:** 8 direcciones con suspensión de gravedad durante 0.14 s. Cancela de inmediato hacia ataque (espada o escopeta) o hacia salto rasante de conservación de inercia (*wave-dash*).

---

## 5. Gancho: Solución Integral de Control y Oscilación

Se atacó la combinación **Geometría + Detección + Dinámica de Cuerda**:
1. **Línea de Visión Obligatoria:** `find_target` descarta cualquier ancla u objetivo cuya línea directa de visión esté interrumpida por un `obj_solid` (`collision_line(player.x, player.y, anchor.x, anchor.y, obj_solid, true, true)`).
2. **Desconexión Segura por Oclusión:** Durante el estado de balanceo (`ATTACHED`), si la cuerda choca con una arista de un muro sólido, el gancho se suelta automáticamente impartiendo un impulso frontal seguro (`player.vx *= 1.12`), evitando que el jugador se enrolle o quede atrapado en esquinas.
3. **Control Activo del Balanceo:** El jugador acelera o frena activamente la velocidad tangencial con las teclas de dirección. La velocidad angular se encuentra gobernada por un tope de 950°/s con amortiguación angular (`0.94`).
4. **Gestión de Longitud de Cuerda:** Mantener `MOVE_UP` o el botón de gancho recoge la cuerda (`reel_speed = 460 px/s`), mientras que presionar `MOVE_DOWN` suelta cuerda hasta el rango máximo, otorgando dominio total del radio de giro.

---

## 6. Arena: Rediseño Compacto y Funcional

- **Dimensiones:** Reducida de 1920x1080 a **1440x810** (aspect ratio exacto 16:9).
- **Eliminación del Obstáculo Central Problemático:** Se retiró el muro vertical de aguja en $x=950$. El espacio aéreo central ahora está completamente despejado para vuelos y parábolas acrobáticas.
- **Topología Megalítica:**
  - Suelo principal en $y=680$.
  - Plataforma escalonada izquierda en $y=540$ ($x=160..384$).
  - Plataforma escalonada derecha en $y=540$ ($x=1024..1248$).
  - Puente ceremonial elevado central en $y=430$ ($x=480..960$).
  - Perchas elevadas laterales en $y=320$ ($x=220$ y $x=1060$).
  - Trampolines cinéticos en los extremos del suelo ($x=110$ y $x=1270$) para alcanzar las perchas altas.
  - Zona de peligro eléctrico bajo el puente central ($y=672$).
  - 3 Llaves Reliquiarias de Gancho: Izquierda ($x=360, y=180$), Cenital ($x=720, y=140$), Derecha ($x=1080, y=180$) con trayectorias de vuelo limpias hacia las plataformas.

---

## 7. Cámara y Resolución

- **Resolución Base y Viewport:** 1280x720 en GameMaker.
- **Ajuste de Ventana:** Inicializado a 1280x720 en `obj_game` junto con `surface_resize` y `display_set_gui_size(1280, 720)`.
- **Encuadre de la Arena:** Al tener una arena de 1440x810 y una vista de 1280x720, la cámara se desplaza suavemente en un rango contenido ($0..160$ en X, $0..90$ en Y). Todo el espacio de combate se mantiene visible y legible sin desorientar al jugador.
- **Deadzone y Suavizado:** Zona muerta suave central de $\pm 20$ px para evitar temblores al estar quieto; lookahead horizontal adaptativo en función de la velocidad con amortiguación exponencial (*decay* suave).

---

## 8. Personaje: Stickman Modular Ceremonial

- **Cabeza:** Máscara de hueso tallada con crestas angulares de cuerno y ranura ocular hueca con brasa de alma carmesí/dorada.
- **Halo Celestial:** Corona geométrica rotatoria detrás de la cabeza que gira a $35^\circ$/s y emite fulgor áureo al entrar en *Overdrive* o al activar un disparo potenciado.
- **Torso:** Segmentos de basalto negro tinta con grabado en espiga diagonal y manto ceremonial asimétrico sobre un hombro.
- **Extremidades Articuladas:** Muslos y pantorrillas segmentadas con nodos óseos circulares en las rodillas. Poses dinámicas procedurales para carrera, salto encogido, caída libre, dash y embate vertical.
- **Cintas de Talismán:** Cuatro tiras de tela sagrada de hueso con trazos de tinta caligráfica que ondean detrás del personaje siguiendo la inercia del movimiento.

---

## 9. Espada: Mandoble de Verdugo

- **Visual:** Hoja monolítica de basalto con filo de corte de blanco hueso e incrustaciones rúnicas.
- **Mecánica de Combate:** Hitboxes con desfase negativo ($ox: -8$ a $-12$) que engloban el centro del jugador y eliminan el punto ciego a quemarropa.
- **Arcos de Xilografía:** Trazos de pincel de alto contraste con estela de masa de tinta y borde de hueso.

---

## 10. Escopeta: Trabuco Reliquiario

- **Visual:** Culata pesada de basalto tallado con doble cañón abocinado de hueso y hierro con runas doradas grabadas.
- **Sensación de Impacto y Retroceso:**
  - Disparo normal: 6 perdigones, dispersión de $24^\circ$, daño de 5 por perdigón (hasta 30 de daño a quemarropa).
  - Retroceso cinético en el personaje: impulso brusco hacia atrás de $-420$ px/s en X y $-120$ px/s en Y.
  - Fogonazo de boca con grabado xilográfico y vibración de cámara (trauma 0.35, impulso 14 px).
  - Perdigones con velocidad balística de 1600 px/s, colisión destructiva contra muros y estelas gráficas nítidas.

---

## 11. Mecánica de Recarga Perfecta (*Active Reload*)

- **Capacidad:** 2 cartuchos por tambor.
- **Estados de Recarga:**
  - `IDLE` $\rightarrow$ `RELOADING` (duración base: 1.10 s).
  - Medidor de combate radial integrado flotando junto al arma del jugador.
- **Ventana de Precisión:**
  - Sector total de entrada: del 40% al 65% del progreso.
  - **Sub-ventana de Recarga Perfecta:** del 46% al 58% ($0.46 \le t \le 0.58$).
- **Resultados:**
  - **PERFECT:** Recuperación inmediata (recarga instantánea), notificación dorada flotante `PERFECT!`, destello de estrella de cuatro puntas y estado **SHOT_EMPOWERED**.
  - **SHOT_EMPOWERED (Disparo Mejorado):**
    - Cañones envueltos en aura cósmica dorada.
    - 8 perdigones (en vez de 6).
    - Dispersión reducida a $12^\circ$ (alta concentración).
    - Daño aumentado a 8 por perdigón (hasta 64 de daño a quemarropa, +113%).
    - Mayor retroceso e impacto de cámara.
  - **NORMAL:** Si se presiona dentro del sector pero fuera del núcleo perfecto, o si se deja finalizar el tiempo de forma natural, recarga normal sin bonus.
  - **FAIL / JAMMED:** Presionar demasiado pronto o demasiado tarde añade un retraso de castigo de $+0.35$ s con indicador `JAMMED` en rojo, perdiendo la oportunidad de disparo potenciado.

---

## 12. Resultados de Pruebas Unitarias (*Self-Test*)

Ejecución del pipeline de pruebas headless:
```powershell
powershell -ExecutionPolicy Bypass -File tools/build.ps1 -SelfTest
```

**Resultado:**
```text
QZ_SELFTEST_RESULT pass=68 fail=0
SELFTEST pass=68 fail=0
```
Las 5 nuevas pruebas automatizadas (49 a 53) validaron:
1. Configuración de escopeta, dispersión y retroceso de $-420$ px/s.
2. Ventana de recarga activa perfecta y aplicación del estado potenciado.
3. Penalización de recarga fallida por desincronización.
4. Conmutación táctica entre espada y escopeta.
5. Filtrado por línea de visión en el sistema de gancho ante muros sólidos.

---

## 13. Compilación y Ejecución Nativa en Windows

Ejecución de la build standalone:
```powershell
powershell -ExecutionPolicy Bypass -File tools/build.ps1
```

**Resultado:**
- Compilación: **BUILD SUCCESSFUL**
- Ejecutable generado: [`C:\Users\Valdez\Documents\Quazerium\build\Quazerium\Quazerium.exe`](file:///c:/Users/Valdez/Documents/Quazerium/build/Quazerium/Quazerium.exe)
- Archivo de datos: `build/Quazerium/data.win` (371 KB)
- Verificación de ejecución en Windows (`tools/test_launch.ps1`): **PASS** (Proceso inicia y se ejecuta de forma estable a 60 FPS sin excepciones en tiempo de ejecución).

---

## 14. Problemas Restantes

- Actualmente la arena cuenta con un muñeco de prueba (`obj_enemy_dummy`) y los spawners dinámicos del Director. No se han implementado aún proyectiles reflectables por la escopeta (la parada refleja proyectiles enemigos pero los perdigones propios no interactúan con el escudo del jugador).

---

## 15. Próximo Paso Recomendado

**Diseño de Encuentros Dinámicos con Oleadas Temáticas y Variantes de Enemigos que reaccionen a la Escopeta Potenciada y al Gancho Vertical en la Arena Rediseñada.**
