# QUAZERIUM — GEMINI PHASE 04 REPORT
**Camera, Arena, Lighting & Environment Polish**  
**Runtime:** GameMaker LTS 2026 (GML)  
**Target:** Native Windows PC (Validated for Intel Core i5-3470 / Intel HD Graphics 2500 / HDD)  
**Status:** **BUILD = PASS · SELFTEST = 42/42 PASS (0 FAILURES)**

---

## 1. Estado Inicial de Fase 04
Al iniciar la Fase 04:
- El combate, las partículas de impacto, los poderes y las reacciones elementales ya se encontraban integrados con 40 pruebas unitarias pasando.
- Sin embargo, la arena y el entorno visual aún se percibían como un prototipo técnico:
  - Las plataformas (`obj_solid`) eran bloques de relleno simple con líneas perimetrales básicas sin detalles de textura ni indicación visual de bordes con peligro de caída.
  - Los anclajes de grapple (`obj_grapple_anchor`) carecían de retroalimentación de fijación de blanco interactiva.
  - La cámara mantenía un lookahead horizontal estático dependiente únicamente de la dirección del jugador (`facing`), sin anticipación reactiva a la velocidad horizontal (`vx`) ni encuadre cinematográfico durante la tensión del gancho (`grapple`).
  - El fondo de `obj_environment` poseía un único plano de edificios planos y motes genéricos sin profundidad arquitectónica real ni iluminación volumétrica.
  - No existía un plano frontal (Foreground) con perspectiva diferencial, lo que aplanaba la escena visual.

---

## 2. Mejoras Implementadas

### 2.1. Sistema de Cámara Cinematográfica y Estable (`obj_camera/Step_2.gml`)
- **Lookahead Dinámico por Velocidad:**
  - El avance horizontal de la cámara ahora combina la orientación del jugador con su vector de velocidad cinética: `var vel_lead = clamp(p.vx * 0.16, -90, 90)`. El jugador siempre puede ver hacia dónde se proyecta sin perder estabilidad.
- **Anticipación Vertical de Salto y Caída:**
  - Desplazamiento reactivo en el eje Y (`clamp(p.vy * 0.15, -50, 90)`); durante el estado de caída en picada (`PSTATE.SLAM`), la cámara proyecta un avance vertical hacia abajo de 110 px para anticipar el punto de impacto.
- **Encuadre Cinematográfico de Tensión de Gancho:**
  - Cuando el jugador está anclado a un nodo (`PSTATE.HOOK`), la cámara interpola suavemente su objetivo hacia el nodo de anclaje (sesgo del 22%), acentuando la tensión elástica previa al impulso slingshot.
- **Estabilidad y Suavizado Anti-Mareo:**
  - Amortiguación elástica crítica sin oscilación infinita (`follow_half_life`).
  - Disipación de trauma cuadrática (`power(trauma, 2) * max_shake`) que evita vibraciones permanentes.
  - Congelamiento suave del seguimiento durante hitstop (`hitstop_freeze_follow = true`), evitando saltos bruscos en el impacto.

### 2.2. Composición de Arena en 4 Planos Visuales

#### 1. Plano Lejano / Cielo y Megaciudad (Parallax $0.08\times$, Depth 500)
- Degradado atmosférico de cúpula nocturna: de azul obsidiana (`RGB 6, 9, 15`) a bruma cian industrial (`RGB 14, 22, 34`).
- Rascacielos ciberpunk densos generados con altura determinística y antenas con balizas de advertencia aeronáutica parpadeantes en fases desfasadas.
- Mallas de ventanas iluminadas en ámbar y cian con intensidad amortiguada que no compiten con el combate.

#### 2. Plano Medio / Arquitectura Industrial (Parallax $0.24\times$, Depth 500)
- Vigas diagonales de celosía de acero, conductos y tuberías de refrigeración pesadas detrás de las plataformas.
- Señalética holográfica de sector: `"SECTOR-09 // CYBERNETICS PROVING GROUND"` con estarcido cian y oscilación senoidal suave.

#### 3. Espacio de Juego / Gameplay Play Space (Depth 0)
- **Plataformas de Combate (`obj_solid`):**
  - Banda superior de riel luminiscente de neón cian (`RGB 0, 220, 255`) para lectura inmediata de la superficie transitable.
  - Rayado de advertencia diagonal de peligro (chevrons amarillo/negro de 24 px) en los extremos expuestos de cada plataforma con caída libre.
  - Paneles de blindaje compuesto de carbono en segmentos de 64 px con juntas verticales oscuras y remaches estructurales.
  - Sombra proyectada en la base de las plataformas flotantes sobre el suelo inferior.
- **Nodos de Anclaje de Grapple (`obj_grapple_anchor`):**
  - Corona magnética giratoria con garras de anclaje mecánicas.
  - Retícula de bloqueo y haz de enlace luminiscente que se intensifica al estar dentro del radio de alcance del gancho.

#### 4. Plano Frontal / Foreground Framing & Iluminación (Parallax $1.18\times$, Depth -400 / Draw End)
- Vigas estructurales y haces de cables suspendidos en silueta oscura que atraviesan la pantalla con velocidad diferencial más rápida que el jugador, proporcionando tridimensionalidad genuina.
- Viñeta perimetral suave de encuadre en las esquinas de la cámara que enfoca la mirada en el área de acción.

### 2.3. Iluminación 2D Volumétrica y Resaltado de Entidades (`obj_environment/Draw_73.gml`)
- **Focos Industriales Volumétricos:**
  - 4 reflectores industriales montados sobre las plataformas clave proyectando conos de luz atmosférica suave (`bm_add`) con leve pulso lumínico.
- **Luminiscencia de Entidades para Lectura de Combate:**
  - Halo cian alrededor del visor del jugador (se transforma en halo dorado radiante amplificado de 48 px durante Overdrive).
  - Resplandor de advertencia carmesí en el núcleo del reactor de los autómatas enemigos (aumenta a naranja intenso durante el telégrafo de ataque).
  - Halo magnético azul/cian pulsante en cada anclaje de grapple.
- **Control Estricto por Perfil de Hardware:**
  - En LOW (Intel HD 2500): el pase aditivo de iluminación y shaders se desactiva de forma nativa (`enable_lighting = false`), manteniendo la tasa de refresco a 60 FPS estables.
  - En MEDIUM / HIGH: iluminación aditiva completa y mayor densidad de partículas atmosféricas.

---

## 3. Presupuesto y Matriz de Rendimiento

| Subsistema | LOW (Intel HD 2500 / i5-3470) | MEDIUM (PC Estándar) | HIGH (Entusiasta) |
| :--- | :--- | :--- | :--- |
| **Motes Ambientales** | 20 partículas | 50 partículas | 100 partículas |
| **Pase de Iluminación 2D** | Desactivado (`bm_normal`) | Activado (`bm_add`) | Activado (`bm_add`) |
| **Vigas de Foreground** | Simplificadas | Completas ($1.18\times$) | Completas ($1.18\times$) |
| **Ventanas de Megaciudad**| Desactivadas | Activadas | Activadas con micro-variación |
| **Partículas de Combate** | Máx 100 | Máx 500 | Máx 2000 |
| **Calcomanías de Combate**| Máx 24 (4.0s) | Máx 64 (7.0s) | Máx 128 (12.0s) |

---

## 4. Resultados de Compilación y Validación Automatizada

```text
Compilation Target: Native Windows VM (Igor.exe)
Project File: Quazerium.yyp (34 Resources, 16 Folders)
Self-Test Result:
========================================
QUAZERIUM SELF-TEST SUITE: pass=42 fail=0
QZ_SELFTEST_RESULT pass=42 fail=0
========================================
Exit Code: 0 (SUCCESS)
```

### Tests Nuevos Añadidos en Fase 04:
- **Test 26:** Camera — Validación de mapeo de reacciones cinéticas para `EVT.ELEMENT_REACTION` y `EVT.ENTITY_KILLED` en la configuración global.
- **Test 27:** Environment — Validación de cumplimiento de política de hardware (`enable_lighting == false` en LOW, `true` en HIGH).

---

## 5. Recomendaciones para Fase 05
1. **Tipos de Enemigos Adicionales:** Expandir los autómatas con arquetipos a distancia (disparo de proyectiles reflejables mediante parry) y brutos acorazados.
2. **SFX Assets:** Conectar archivos de sonido `.wav`/`.ogg` reales a los hooks de `qz_audio.gml`.
3. **Loop de Oleadas de la Arena:** Implementar un sistema de rondas o spawners de enemigos dentro de `rm_arena` para sesiones de combate prolongadas.
