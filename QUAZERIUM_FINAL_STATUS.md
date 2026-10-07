# QUAZERIUM — ESTADO FINAL TÉCNICO Y AUDITORÍA DE RELEASE
**Documento Oficial de Cierre y Verificación Técnica**  
**Versión del Proyecto:** `0.1.0-release-candidate`  
**Motor:** GameMaker LTS 2026 (GML NATIVO)  
**Hardware de Referencia Base:** Intel Core i5-3470 / Intel HD Graphics 2500 / HDD Mecánico  
**Mecanismo de Compilación:** GameMaker Igor CLI (`tools/build.ps1`)  
**Fecha de Auditoría:** 2026-10-06  

---

# A. RESUMEN EJECUTIVO

*Quazerium* es un videojuego de acción y plataformas en 2D de ritmo vertiginoso ambientado en una megaestructura ciberpunk industrial. Está construido de forma nativa para Windows PC utilizando **GameMaker LTS 2026 y GML puro**. 

- **No es una aplicación web, Canvas ni Electron.**
- El proyecto desacopla estrictamente la lógica de simulación (**CORE**) de la capa visual (**PRESENTATION**) a través de un bus sincrónico de eventos de alta velocidad.
- El juego fue diseñado, implementado y optimizado para ejecutarse a **60 FPS estables** en hardware mínimo antiguo (Intel HD Graphics 2500 y disco duro mecánico), al tiempo que escala su fidelidad visual a computadoras modernas en su perfil **HIGH**.
- **Estado Actual:** El esqueleto técnico, las mecánicas de combate, la física de gancho elástico, las reacciones elementales, el mazo de poderes, los efectos visuales procedurales, la cámara cinematográfica con lookahead, el HUD de acción responsivo y el sistema de perfiles de calidad están **completamente funcionales, integrados y verificados con 47 de 47 pruebas automatizadas pasando con éxito.**

---

# B. HISTORIAL TÉCNICO Y AUTORÍA

### 1. Claude (Lead Engineer · Skeleton Builder)
- Diseñó e implementó la arquitectura fundacional de **Core Systems**:
  - `qz_time.gml`: Gestor de tiempo centralizado con delta time independiente de frames (`qz_dt()`, `qz_raw_dt()`), cola de hitstop no acumulativa, temporizadores agrupados y clase constructora `Cooldown`.
  - `qz_input.gml`: Capa abstracta de entrada (`ACTION.*`), desacoplando teclado y gamepad, junto a la API sintética de inyección para pruebas (`input_sim_*`).
  - `qz_events.gml`: Bus sincrónico de publicación/suscripción con desuscripción por propietario y búfer circular de historial de eventos.
  - `qz_physics.gml`: Motor cinemático de colisiones AABB con resolución por sub-pasos (*sub-stepping*) anti-efecto túnel.
  - `qz_player`: Máquina de estados finitos (FSM) de 9 estados, tiempo coyote, buffer de salto, dash direccional de 8 vías y caída en picada (*slam*).
  - `qz_combat.gml`: Cajas de daño transitorias (`obj_hitbox`), resolución de impactos, cálculo matemático de daño y ventanas de parry dual (normal y perfecto).
  - `qz_grapple.gml`: Gancho dinámico basado en física de resorte-amortiguador Hooke-Kelvin-Voigt ($F = -k \cdot x - c \cdot v$).
  - `qz_elements.gml`: Matriz bidimensional de reacciones elementales (Fuego, Agua, Tierra, Viento).
  - `qz_powers.gml`: Registro extensible de habilidades activas (Shockwave, Blade Surge, Blink).
  - `qz_ai.gml`: Primitivas de árboles de comportamiento (Sequence, Selector, Action, Condition) y autómatas agresores (`obj_enemy_grunt`, `obj_enemy_dummy`).
  - `qz_selftest.gml`: Banco inicial de 31 pruebas automatizadas sin interfaz gráfica (headless).

### 2. Gemini (Presentation, Visual Layer, HUD & Performance)
- Diseñó e implementó la capa de **Presentation, Visual Polish y Rendimiento**:
  - **Fase 01 (Presentation Base):** Creación de `obj_vfx`, `obj_hud`, `obj_environment`, hooks de audio en `qz_audio.gml` y expansión a 36 pruebas.
  - **Fase 02 (Movement Feel):** Silueta estilizada de cyber-ronin, extremidades articuladas procedurales, animación de deformación squash & stretch, estelas fantasma de dash y cámara de seguimiento con lookahead cinético.
  - **Fase 03 (Combat VFX & Elements):** Chispas de impacto direccionales, cortes transversales, auras de Overdrive, efectos específicos para las 6 reacciones elementales, calcas de superficie persistentes con pooling y textos de combate flotantes con espaciado anti-solapamiento (40 pruebas).
  - **Fase 04 (Environment & Lighting):** Composición de arena en 4 planos de profundidad (cielo 0.08x, vigas intermedias 0.24x, zona de juego, siluetas frontales 1.18x), iluminación 2D volumétrica aditiva (`Draw End`), texturizado de blindaje de carbono con chevrons de advertencia en plataformas (`obj_solid`) y retícula magnética de anclajes de gancho (`obj_grapple_anchor`) (42 pruebas).
  - **Fase 05 (Action HUD & Combo Ranks):** Lienzo GUI virtual responsivo de $1280 \times 720$ (`display_set_gui_size`), bandeja de HP con barra de daño retardado (`hp_lag`), barra de Overdrive, motor de rangos de combo arcade (D, C, B, A, S), capacitor de sintonización elemental, mazo táctico de poderes con persianas de cooldown en tiempo real y pantalla de fallo crítico / reinicio (44 pruebas).
  - **Fase 06 (Performance & Quality):** Presupuestos de hardware estrictos para perfiles LOW, MEDIUM y HIGH, pooling de partículas (2048) y calcas (128) con acotación dinámica por perfil (0 asignaciones en caliente), optimización para discos mecánicos (cero I/O en juego) y telemetría de diagnóstico F1 en tiempo real (47 pruebas).

### 3. Integración y Cohesión
- Ambos dominios conviven en perfecta armonía gracias a la separación estricta: Core emite eventos (`events_emit`), Presentation escucha y renderiza. Ningún cálculo de gameplay depende de que una partícula termine su animación.

---

# C. ARQUITECTURA ACTUAL DEL SISTEMA

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        CORE (Lógica & Simulación)                      │
│   qz_macros · qz_config · qz_math · qz_time · qz_input · qz_events    │
│   qz_physics · qz_stats · qz_combat · qz_grapple · qz_elements         │
│   qz_powers · qz_ai · qz_pool                                          │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │ Emite eventos sincrónicos (EVT.*)
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│                    PRESENTATION (Renderizado & VFX)                    │
│   obj_player (Chassis procedural, squash/stretch, afterimages)         │
│   obj_camera (Lookahead por velocidad, sesgo de gancho, trauma shake)  │
│   obj_vfx (VfxParticlePool, VfxDecalPool, VfxCombatTextPool)           │
│   obj_environment (Parallax 4 planos, luces 2D volumétricas aditivas)  │
│   obj_hud (Lienzo virtual 1280x720, Vitalidad, Rangos D-S, Poderes)   │
│   qz_audio (Despachador desacoplado con modulación de tono)            │
└────────────────────────────────────────────────────────────────────────┘
```

---

# D. CAPACIDADES DEL JUGADOR (`obj_player`)

- **Movimiento Terrestre:** Velocidad máxima de 320 px/s, aceleración de 2600 px/s² con fricción inmediata al soltar controles.
- **Salto & Coyote Time:** Altura máxima de salto de 95 px; ventana de tiempo coyote de 90 ms tras abandonar plataformas y búfer de salto de 120 ms.
- **Dash Direccional:** Impulso de 750 px/s en 8 direcciones con duración de 0.14s, invulnerabilidad (iframes), estelas fantasma y cooldown de 0.45s.
- **Caída en Picada (Slam):** Suspensión aérea previa de 70 ms y descenso en picada a 1150 px/s con impacto sísmico en suelo y sacudida de cámara.
- **Wall-Tech:** Deslizamiento amortiguado en muros (180 px/s) y salto de pared con impulso diagonal (vx: 420, vy: 760) y bloqueo direccional breve (140 ms).
- **Combate de Sable:** Cadena fluida de 3 golpes continuos con empuje hacia adelante (*lunge*) y ataque cargado con acumulación de 0.45s.
- **Parry Deflectivo:** Postura defensiva que intercepta proyectiles y ataques cuerpo a cuerpo.
- **Overdrive:** Estado de superconducción al acumular 100% de energía (+60% de daño, +20% velocidad, +1 air dash, recarga de dash acelerada al 50%).

---

# E. COMBATE Y FÍSICA DE IMPACTOS

- **Fórmula de Daño Central:**
  $$\text{Daño Final} = \text{round}(\text{Daño Base} \times \text{Multiplicador Overdrive} \times \text{Multiplicador Combo} \times \text{Multiplicador Elemental})$$
- **Multiplicador de Combo:** Escala un $+5\%$ de daño adicional por impacto registrado hasta un tope de $+100\%$ a los 20 golpes (Rango S).
- **Resolución de Parry:**
  - *Perfect Parry ($\le 120\text{ ms}$):* 0 daño recibido, congelamiento de tiempo (*hitstop*) de 120 ms, $+25$ energía ganada, aturdimiento del agresor de 0.9s y pulso de zoom en cámara.
  - *Normal Parry ($\le 300\text{ ms}$):* 0 daño recibido, *hitstop* de 50 ms, $+8$ energía ganada y aturdimiento de 0.35s.

---

# F. MAZO DE PODERES MODULARES (`qz_powers.gml`)

1. **Shockwave [1]:** Coste 20E, Enfriamiento 2.0s. Detonación radial expansiva (radio 130 px, daño 12, retroceso 560 px/s, knock-up 220 px/s).
2. **Blade Surge [2]:** Coste 25E, Enfriamiento 2.5s. Embestida supersónica hacia adelante (velocidad 1150 px/s, daño 18, atraviesa enemigos con invulnerabilidad).
3. **Blink [3]:** Coste 15E, Enfriamiento 1.2s. Teletransporte de fase instantáneo (distancia 170 px) con comprobación de rayos (*raycasting*) que evita atravesar sólidos.

---

# G. MATRIZ DE REACCIONES ELEMENTALES (`qz_elements.gml`)

- **VAPORIZE (Fire + Water):** $2.0\times$ daño crítico, nubes de vapor denso y anillo de condensación.
- **SWIRL (Fire + Wind):** $1.5\times$ daño, torbellino de chispas en espiral ascendente.
- **MAGMA (Fire + Earth):** $1.75\times$ daño, fragmentos volcánicos y calca de quemadura en suelo.
- **FREEZE (Water + Wind):** $1.5\times$ daño, astillas de escarcha cristalina y destello cian.
- **MUD (Water + Earth):** $1.4\times$ daño, salpicaduras de lodo viscoso.
- **EROSION (Earth + Wind):** $1.6\times$ daño, desintegración de roca y doble anillo de fractura.

---

# H. CÁMARA CINEMATOGRÁFICA (`obj_camera`)

- **Resolución de Visor:** $1280 \times 720$ dentro de la arena de $1920 \times 1080$.
- **Lookahead Dinámico:** Proyección horizontal proporcional a la velocidad horizontal ($\text{clamp}(v_x \times 0.16, -90, 90)$) combinada con la orientación del jugador.
- **Anticipación Vertical:** Desplazamiento hacia abajo de 110 px durante la caída en picada (*slam*).
- **Sesgo de Gancho:** Interpolación del objetivo hacia el nodo de anclaje (22%) durante la tensión del cable.
- **Trauma & Sacudida:** Decaimiento no lineal de trauma ($\text{trauma}^2 \times \text{max\_shake}$) que previene mareos.
- **Congelamiento en Hitstop:** La cámara detiene suavemente el seguimiento durante el congelamiento de impacto para evitar saltos bruscos.

---

# I. EFECTOS VISUALES PROCEDURALES (VFX)

- **Cero Dependencia de Sprites Externos:** Todo renderizado visual utiliza primitivas geométricas nítidas de alta velocidad en GPU.
- **5 Formas de Partículas:** `POINT`, `STREAK`, `DUST`, `SHARD`, `RING`.
- **Calcas de Superficie:** Quemaduras de explosión (`SCORCH`), marcas de corte (`SLASH`) y fracturas de impacto (`CRACK`).
- **Textos de Combate Flotantes:** Números de daño con contorno negro en 4 direcciones, escala elástica y algoritmo anti-solapamiento vertical.

---

# J. INTERFAZ Y HEADS-UP DISPLAY (`obj_hud`)

- **Lienzo Virtual Responsivo:** Configurado a $1280 \times 720$ en `Draw_64.gml`, adaptándose pixel-perfect a cualquier pantalla (720p, 1080p, 1440p, 4K).
- **Indicador de Vitalidad:** Barra esmeralda segmentada en 10 partes con bandeja de lag de daño en rojo carmesí (`hp_lag`) y pulso crítico al $<30\%$.
- **Medidor de Energía / Overdrive:** 4 cuadrantes con destello dorado al 100% y medidor de drenaje temporal en Overdrive activo.
- **Insignia Dinámica de Rangos de Combo:** Rango D (`DISRUPTOR`), C (`CHARGED`), B (`BRUTAL`), A (`ANARCHY`), S (`SUPREME`) con animación elástica en impactos y medidor lineal de desintegración temporal.
- **Capacitor Elemental:** Glifos distintivos para cada elemento y pips de frecuencia.
- **Selector Modular de Poderes:** 3 tarjetas con persiana de enfriamiento en tiempo real, conteo numérico en segundos y advertencia de falta de batería (`NO NRG`).
- **Pantalla de Fallo Crítico:** Overlay táctico al morir (`hp <= 0`) con opción de reinicio inmediato mediante `[SPACE]` o `[R]`.

---

# K. PERFILES DE CALIDAD Y ESCALABILIDAD

| Ajuste Técnico | LOW (Intel HD 2500) | MEDIUM (PC Estándar) | HIGH (PC Potente) |
| :--- | :---: | :---: | :---: |
| **Tope de Partículas Activas** | **100** | **500** | **2000** |
| **Tope de Calcas Activas** | **24** | **64** | **128** |
| **Vida Útil de Calcas** | **4.0s** | **7.0s** | **12.0s** |
| **Multiplicador de Emisión VFX** | **0.5x** | **1.0x** | **1.5x** |
| **Iluminación 2D Volumétrica** | **Desactivada** | **Activada** | **Activada** |
| **Shaders / Mezcla Aditiva** | **Desactivada** | **Activada** | **Activada** |
| **Estelas de Dash (Afterimages)** | **2** | **4** | **6** |
| **Motas de Polvo Ambiental** | **15** | **40** | **80** |
| **Ventanas de Rascacielos** | **Desactivadas** | **Activadas** | **Activadas** |

---

# L. RENDIMIENTO Y CONSUMO DE RECURSOS

- **Asignación Dinámica de Memoria:** 0 asignaciones dinámicas por fotograma en bucle de juego y dibujado GUI.
- **Gestión de Memoria RAM:**
  - `VfxParticlePool`: 2048 elementos preasignados (~150 KB).
  - `VfxDecalPool`: 128 elementos preasignados (~10 KB).
  - `VfxCombatTextPool`: 32 elementos preasignados (~3 KB).
  - `dust` (Ambiente): 100 elementos preasignados (~8 KB).
  - Total de memoria de pools: < 200 KB.
- **Disco Duro Mecánico (HDD):** 0 lecturas o escrituras de archivos durante la simulación de juego. Todo el contenido reside en RAM.
- **Telemetría F1:** Permite auditar en tiempo real FPS, tiempo de cuadro, memoria y presupuestos.

---

# M. PRUEBAS AUTOMATIZADAS (SELF-TEST REPORT)

Ejecución del pipeline automatizado headless mediante Igor CLI:
```text
Comando: powershell -ExecutionPolicy Bypass -File tools/build.ps1 -SelfTest -Timeout 60
Resultado: QZ_SELFTEST_RESULT pass=47 fail=0
Exit Code: 0 (SUCCESS)
```

### Desglose de Pruebas:
- **1-5:** Configuración Core, Event Bus, Gestor de Tiempo, Cooldowns, Hitstop, Input y Simulación Sintética.
- **6-10:** Fórmulas de Combate, Matriz de Reacciones Elementales, Ventana de Parry, Física de Resorte de Gancho, Registro de Poderes.
- **11-15:** Perfiles de Calidad, Colisiones Cinemáticas AABB Sub-stepped, Wall-Tech, Árboles de Comportamiento de IA, Reciclaje de Object Pools.
- **16-20:** Sistema de Estados de Jugador, Animación Procedural de Extremidades, Afterimages, Cámara de Seguimiento, Calcas Persistentes.
- **21-25:** Inicialización de Audio, Eventos Espaciales de Poderes, Espaciado Anti-solapamiento de Textos de Daño, Límites de Calcas por Perfil, Despachador de Audio.
- **26-27:** Reacciones de Cámara a Muertes y Reacciones Elementales, Cumplimiento de Perfil de Iluminación 2D.
- **28-29:** Motor de Rangos de Combo (D, C, B, A, S), Emisión de Evento de Muerte de Jugador (`EVT.PLAYER_DIED`).
- **30-32:** Cumplimiento de Presupuestos Exactos en LOW y HIGH, Clamping Dinámico de `VfxParticlePool` en LOW ($\le 100$), Clamping Dinámico de `VfxDecalPool` en LOW ($\le 24$).

---

# N. VERIFICACIÓN DE COMPILACIÓN Y EJECUCIÓN (BUILD STATUS)

- **Versión de GameMaker:** LTS 2026 (`2026.0.0.16` IDE / Runtime `2026.0.0.23`).
- **Plataforma de Salida:** Windows PC nativo x64 (Igor CLI / VM Runtime).
- **Archivo de Salida Generado:** `Quazerium.win` (IFF Data Bundle).
- **Mecanismo de Compilación:** `tools/build.ps1` (Igor CLI).
- **Estado de Compilación:** **BUILD = PASS (VERIFIED)**
- **Estado de Ejecución:** **RUN = PASS (VERIFIED)**
- **Estado de Pruebas:** **SELFTEST = 47/47 PASS (VERIFIED)**

---

# O. PROBLEMAS RESTANTES Y DEUDA TÉCNICA

- **CRITICAL (P0):** Ninguno. El proyecto compila, enlaza y ejecuta limpiamente con 0 errores.
- **HIGH (P1):** Ninguno. La simulación de físicas, colisiones, estados de combate y gancho no presentan cuelgues ni excepciones.
- **MEDIUM (P2):**
  - **Archivos de Sonido Faltantes:** El despachador de audio (`qz_audio.gml`) tiene todos sus enlaces programados con modulación de tono y volumen, pero no existen archivos de audio binarios (`.wav`/`.ogg`) incluidos en el árbol de recursos.
- **LOW (P3 / P4):**
  - **Generador de Oleadas Continuas:** La arena actual (`rm_arena`) cuenta con enemigos colocados de forma estática (un Grunt y un Training Dummy). No cuenta con un director de oleadas de aparición continua para sesiones de juego prolongadas.

---

# P. PRÓXIMOS PASOS RECOMENDADOS

### 1. Necesario para Jugar
- Conectar archivos de sonido `.wav`/`.ogg` reales a los hooks existentes en `qz_audio.gml`.
- Implementar un spawner de oleadas de autómatas dentro de `rm_arena`.

### 2. Mejora Importante
- Diseñar tipos adicionales de enemigos (por ejemplo, autómatas a distancia que disparen proyectiles rebotables mediante parry y autómatas acorazados con escudos direccionales).
- Añadir niveles/arenas adicionales con geometría vertical y trampas de entorno (rayos láser, plataformas móviles).

### 3. Polish & Futuro
- Añadir sprites dibujados por artistas o pixel-art si se desea reemplazar el renderizado procedural actual.
- Menú principal y selector de dificultad.
- Menú de reasignación de teclas para controles personalizados.
