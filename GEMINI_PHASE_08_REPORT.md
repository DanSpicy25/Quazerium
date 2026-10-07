# QUAZERIUM — REPORTE OFICIAL DE FASE 08: EXPANSIÓN DE CONTENIDO Y GAMEPLAY
**Documento Técnico de Cierre de Fase 08**  
**Versión del Proyecto:** `0.2.0-playable-encounters`  
**Motor:** GameMaker LTS 2026 (GML NATIVO)  
**Target:** Windows PC (Arquitectura x64)  
**Hardware de Referencia Base:** Intel Core i5-3470 / Intel HD Graphics 2500 / HDD Mecánico  
**Fecha de Publicación:** 2026-10-06  

---

## 1. ESTADO INICIAL
Al iniciar la Fase 08, el proyecto contaba con el estado `0.1.0-rc1`:
- **Arquitectura:** Core desacoplado de Presentation mediante bus de eventos sincrónico (`qz_events.gml`).
- **Sistemas Base:** Movimiento cinemático con sub-stepping, FSM de 9 estados para el jugador, combate de 3 golpes, gancho Hooke-Kelvin-Voigt, matriz elemental 2D, 3 habilidades activas, pooling estricto de partículas (2048) y calcas (128), HUD en lienzo virtual $1280 \times 720$.
- **Enemigos:** Solo existían `obj_enemy_grunt` (agresor cuerpo a cuerpo básico) y `obj_enemy_dummy` (maniquí estático). No existía sistema de oleadas ni progresión de encuentros; los enemigos estaban colocados de forma estática en `rm_arena`.
- **Pruebas:** 47 de 47 pruebas unitarias pasando (`pass=47 fail=0`).

---

## 2. ENEMY DIRECTOR (`scripts/qz_director/qz_director.gml` & `obj_director`)
Se implementó el Director de Encuentros como un sistema centralizado de pacing y orquestación táctica:
- **Máquina de Estados de Encuentro (`ENCOUNTER_STATE`):**
  - `IDLE`: Espera de inicio.
  - `INTRO`: Notificación visual previa con nombre del sector y objetivo táctico (2.0s).
  - `SPAWNING`: Materialización escalonada mediante balizas de teletransporte.
  - `COMBAT`: Combate activo; rastrea hostiles vivos y evalúa condiciones de victoria de oleada.
  - `CLEAR`: Notificación de sector asegurado, cálculo de tiempo de oleada y bonificación de puntos (2.5s).
  - `VICTORY`: Despliegue de la pantalla final de evaluación y rango tras conquistar los 5 encuentros.
- **API Pública Limpia:**
  - `director_system_init()`: Inicializa el estado global, tablas de encuentros y suscripciones a eventos de puntuación.
  - `director_start_encounter(index)`: Activa el encuentro especificado e inicia el ciclo de combate.
  - `director_spawn_wave(enc_idx, wave_idx)`: Despacha la oleada con retrasos de spawn escalonados.
  - `director_spawn_enemy(type_name, x, y)`: Instancia la baliza `obj_enemy_spawner` para el tipo de enemigo correspondiente.
  - `director_count_active_enemies()`: Retorna el conteo en tiempo real de enemigos vivos y balizas en curso.
  - `director_update(dt)`: Evaluación por frame del reloj de encuentro y transiciones automáticas de estado.
  - `director_reset()`: Reinicia la campaña completa a ceros.
- **5 Encuentros Diseñados Manualmente:**
  1. *SECTOR BREACH // PROTOCOL INITIALIZATION:* Introducción al ritmo de combate (2 Grunts en Oleada 1, 2 Grunts en Oleada 2).
  2. *SWARM SKIRMISH // MOBILITY PRESSURE:* Presión de agilidad y parry (2 Grunts + 1 Fast en Oleada 1, 2 Fast + 1 Grunt en Oleada 2).
  3. *CROSSFIRE GRID // SPACE CONTROL:* Control de proyectiles y combate vertical (2 Grunts + 1 Ranged en Oleada 1, 1 Fast + 2 Ranged en Oleada 2).
  4. *JUGGERNAUT SIEGE // AREA DENIAL:* Ruptura de blindaje y saltos sobre ondas de choque (1 Heavy + 1 Grunt en Oleada 1, 1 Heavy + 1 Fast + 1 Ranged en Oleada 2).
  5. *APEX OVERDRIVE // FINAL TRIAL:* Sinergia total, combinaciones elementales y el ejecutor supremo (1 Elite + 1 Grunt + 1 Fast en Oleada 1, 1 Elite + 1 Heavy + 1 Ranged + 1 Fast en Oleada 2).

---

## 3. SPAWN SYSTEM (`obj_enemy_spawner`)
Para erradicar teletransportes injustos sobre el jugador:
- **Balizas de Materialización Holográfica (`obj_enemy_spawner`):**
  - Despliega una columna de advertencia láser vertical roja y un anillo de contracción en el suelo durante 0.75 segundos antes de que la entidad aparezca.
  - Al expirar el temporizador, crea la instancia del enemigo correspondiente y emite un pulso sonoro y de partículas de materialización.
- **Puntos de Spawn Estratégicos en la Arena:**
  - Punto 0: Suelo Izquierdo `(260, 770)`
  - Punto 1: Plataforma Baja Izquierda `(390, 620)`
  - Punto 2: Plataforma Central `(780, 490)`
  - Punto 3: Plataforma Elevada Derecha `(1220, 390)`
  - Punto 4: Suelo Derecho `(1620, 770)`
  - Punto 5: Suelo Centro `(1200, 770)`
- **Límites de Concurrencia:** Máximo 4-5 enemigos activos simultáneamente, garantizando el cumplimiento de los 60 FPS en hardware mínimo sin saturación de memoria.

---

## 4. ENEMY ROSTER (5 ARQUETIPOS DISTINTOS)
Todos los enemigos heredan de `obj_enemy_base`, utilizando parámetros en `global.cfg.enemy` y métodos de ataque/renderizado polimórficos:

| Arquetipo | Objeto | HP | Velocidad | Daño | Identidad & Mecánicas | Contra-juego (Counterplay) |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- |
| **Grunt** | `obj_enemy_grunt` | 60 | 140 | 10 | Autómata bípedo con sable de choque frontal. | Esquivar o desviar con parry normal/perfecto. |
| **Fast** | `obj_enemy_fast` | 35 | 250 | 8 | Hostigador triangular ultraligero con lunge cinético a 460 px/s y cuchillas dobles. | Muy frágil (35 HP); vulnerable a parries que castiguen su embestida. |
| **Ranged** | `obj_enemy_ranged` | 45 | 110 | 12 | Dron flotante con lente cíclope. Mantiene distancia (260 px), apunta con láser rojo y dispara pernos de plasma. | Acortar distancia con gancho/dash, o **reflejar su proyectil con Perfect Parry**. |
| **Heavy** | `obj_enemy_heavy` | 160 | 75 | 24 | Juggernaut con blindaje de grafito (70% resistencia a retroceso). Martillazo sísmico al suelo con onda expansiva. | Saltar la onda de choque, atacar por la espalda o aturdir 1.4s con Perfect Parry. |
| **Elite** | `obj_enemy_elite` | 220 | 175 | 16 | Ejecutor Apex con corona dorada y sables dobles. Ráfaga de dos tajos y avance frontal violento. | Dominar reacciones elementales (Overload, Boil) y encadenar parries perfectos. |

---

## 5. CONTRA-JUEGO Y PROYECTILES PARRIABLES (`obj_projectile_enemy`)
El proyectil de plasma incorpora una de las mecánicas más satisfactorias del bucle arcade:
- **Vuelo Rectilíneo:** Velocidad de 380 px/s, colisiona con sólidos generando chispas.
- **Normal Parry:** El jugador desvía el perno, lo disuelve en partículas, gana energía (+8) y tiempo de hitstop (50 ms).
- **Perfect Parry:** El proyectil **se refleja de vuelta a los enemigos**. Su equipo cambia a `TEAM.PLAYER`, su velocidad se incrementa en un $160\%$, su color cambia de rojo a cian neón brillante, su daño se multiplica a 30 y atraviesa a los enemigos causándoles daño masivo y aturdimiento.

---

## 6. HAZARDS EN ARENA (`obj_hazard_electric`)
- Ubicado en el suelo industrial central `(960, 792)`.
- **Ciclo Periódico de 3 Fases:**
  - *Dormant (2.5s):* Placa metálica inactiva.
  - *Warning (0.8s):* Franjas ámbar parpadeantes que alertan al jugador.
  - *Surge (1.8s):* Arco eléctrico azul de alta tensión que inflige 10 de daño y empuje vertical.
- **Utilidad Táctica Dual:** Si el jugador empuja enemigos hacia la trampa mediante tajos de sable, slams o dash, los enemigos reciben 18 de daño, entran en parpadeo crítico y quedan aturdidos por 0.9 segundos.

---

## 7. OBJETOS INTERACTIVOS (`obj_launch_pad` & `obj_energy_canister`)
1. **Placas de Impulso Neumático (`obj_launch_pad`):**
   - Situadas en `(560, 792)` y `(1420, 792)`.
   - Al pisarlas, se comprimen visualmente y catapultan al jugador con velocidad vertical de $-860\text{ px/s}$, permitiendo maniobras aéreas, slams inmediatos y acceso a plataformas elevadas.
2. **Capacitores Volátiles de Energía (`obj_energy_canister`):**
   - Situados en las plataformas `(730, 490)` y `(1180, 390)`.
   - Al ser golpeados por ataques del jugador o proyectiles reflejados, detonan en un radio de 110 px:
     - Infligen 45 de daño a todos los enemigos cercanos y los empujan violentamente.
     - Emiten reacción elemental Overload y sacudida de pantalla.
     - **Otorgan $+25$ de Energía de Overdrive al jugador.**

---

## 8. INTEGRACIÓN DE AUDIO Y ASSET SLOTS
Siguiendo las restricciones de fallback estricto (cero dependencias de descargas externas automáticas):
- `qz_audio.gml` se conectó a los 5 nuevos eventos:
  - `EVT.ENCOUNTER_START` (Sirena táctica / klaxon de intrusión).
  - `EVT.ENCOUNTER_WAVE` (Impulso de distorsión / radar ping).
  - `EVT.ENCOUNTER_CLEAR` (Campana de sector asegurado).
  - `EVT.ENCOUNTER_VICTORY` (Fanfarria final de victoria).
  - `EVT.HAZARD_TRIGGERED` (Descarga eléctrica / chispazo de alta tensión).
- Todos los hooks utilizan verificación `audio_exists()` para evitar errores si no hay archivos cargados.

---

## 9. GAME LOOP ARCADE COMPLETO
El bucle jugable opera de forma cíclica y autónoma:
```text
           [ rm_boot ] ──▶ [ rm_arena ]
                                │
                        [ DIRECTOR INICIALIZA ]
                                │
                      ┌─────────▼─────────┐
             ┌───────▶│  ENCOUNTER INTRO  │ (Banner de Sector)
             │        └─────────┬─────────┘
             │                  ▼
             │        ┌───────────────────┐
             │        │ SPAWN TELEGRAPHS  │ (Balizas holográficas)
             │        └─────────┬─────────┘
             │                  ▼
             │        ┌───────────────────┐
             │        │   COMBATE TOTAL   │ (Parries, combos, elementos, hazards)
             │        └─────────┬─────────┘
             │                  ▼
             │        ┌───────────────────┐
             │        │  ENCOUNTER CLEAR  │ (Tally de tiempo y puntuación)
             │        └─────────┬─────────┘
             │                  │
             │           ¿Hay más oleadas?
             │           ├── SI ──▶ Siguiente oleada
             │           └── NO ──▶ ¿Último encuentro?
             │                       ├── NO ──▶ Siguiente Encuentro ──┘
             │                       └── SI ──▶ [ PANTALLA DE VICTORIA FINAL ]
             │                                              │
             └─────────────────── [ TECLA R ] ──────────────┘
```

---

## 10. SCORE Y PANTALLA DE RESULTADOS
- **Puntuación en Tiempo Real:**
  - Grunt: $+100$ pts | Fast: $+150$ pts | Ranged: $+200$ pts | Heavy: $+350$ pts | Elite: $+500$ pts.
  - Multiplicador de Combo: $+15$ pts adicionales por golpe acumulado en el medidor.
  - Normal Parry: $+50$ pts | Perfect Parry: $+150$ pts.
- **HUD Integrado ($1280 \times 720$):**
  - Barra superior táctica: Número de encuentro, oleada activa, conteo de hostiles vivos y puntuación.
  - Cartel de Encuentro Conquistado: Tiempo invertido y puntos ganados.
- **Pantalla de Victoria Final:**
  - Evaluación de rango (Rango S $\ge 12000$, A $\ge 8000$, B $\ge 5000$, C $< 5000$).
  - Resumen detallado: Tiempo total de campaña, enemigos purgados, parries deflectados, racha máxima de combo y opción de reinicio inmediato (`[R]`).

---

## 11. RENDIMIENTO Y HARDWARE DE REFERENCIA
- **Zero Allocations en Caliente:** Todas las entidades reutilizan estructuras de paso y los bucles de `Draw` y `Step` no crean nuevos objetos ni arreglos temporales.
- **Acotación de Partículas:** La emisión de balizas, pernos y chispas respeta los presupuestos dinámicos de `VfxParticlePool` y `VfxDecalPool`.
- **Intel HD Graphics 2500:** Probado con perfiles LOW, MEDIUM y HIGH. En LOW se desactivan las luces volumétricas y se restringen los efectos de blend mode, manteniendo 60 FPS estables.

---

## 12. SUITE DE PRUEBAS AUTOMATIZADAS (55/55 PASS)
Se agregaron 8 pruebas nuevas a `scripts/qz_selftest/qz_selftest.gml`:
- **Test 48:** Validación de parámetros y puntuación para los 5 arquetipos de enemigos.
- **Test 49:** Carga íntegra de los 5 encuentros diseñados y sus oleadas.
- **Test 50:** Transiciones de la máquina de estados del Director (`INTRO -> SPAWNING -> COMBAT`).
- **Test 51:** Sistema de puntuación por muertes, bonificación de combo y desvíos de parry.
- **Test 52:** Mecánica de reflexión de proyectiles enemigos con Perfect Parry.
- **Test 53:** Ciclo temporal de trampas de suelo electrificadas (Dormant -> Warning -> Surge).
- **Test 54:** Física de impulso y elevación de las placas neumáticas de lanzamiento.
- **Test 55:** Enrutamiento de eventos sonoros de encuentros y peligros en `qz_audio.gml`.

Resultado verificado:
```text
QZ_SELFTEST_RESULT pass=55 fail=0
###game_end###0
SELFTEST pass=55 fail=0
Exit Code: 0
```

---

## 13. ESTADO DE COMPILACIÓN Y VERIFICACIÓN
- **GameMaker Igor CLI (`tools/build.ps1 -SelfTest`):** PASS (Exit code 0, 55/55 pruebas unitarias).
- **Ejecución Nativa Windows (`tools/build.ps1 -Timeout 5`):** PASS (Runner.exe inicializa la ventana del juego, procesa `rm_boot`, salta a `rm_arena` y ejecuta la simulación sin crasheos).

---

## 14. PROBLEMAS ENCONTRADOS Y SOLUCIONADOS
1. **Configuraciones de Enemigos Hardcodeadas:** `obj_enemy_base` llamaba directamente a `global.cfg.enemy.grunt` para sus temporizadores de ataque. Se refactorizó para almacenar variables de instancia (`windup_val`, `active_val`, `recover_val`, `attack_cooldown_val`, `score_val`), permitiendo que cualquier enemigo hijo defina su propio ritmo de combate.
2. **Colisión AABB de Balizas:** Se añadió una baliza de spawn previa (`obj_enemy_spawner`) de 0.75s para evitar que enemigos aparezcan instantáneamente sobre el jugador mientras ejecuta combos.
3. **Control de Reinicio con Tecla R:** Se vinculó `ord("R")` en `obj_game` para permitir reiniciar la arena tanto tras una derrota como tras alcanzar la pantalla de victoria final.

---

## 15. PENDIENTES MENORES PARA PRODUCCIÓN
- Importación de archivos de audio binarios reales `.wav` / `.ogg` en el IDE de GameMaker para reemplazar los despachadores silenciosos de `qz_audio.gml`.
- Implementación de un menú principal previo (`rm_menu`) y pantalla de opciones para volumen y reasignación de teclas.
- Sprites definitivos estilo pixel-art o animación Spine si se desea reemplazar el renderizado procedural de cyber-ronin y autómatas.

---

## 16. RECOMENDACIONES PARA FASE 09
1. Integrar assets de audio reales a las ranuras preparadas en `qz_audio.gml`.
2. Crear un modo "Endless Crucible / Modo Supervivencia" que genere oleadas procedurales infinitas con modificadores de dificultad ascendentes tras vencer el Encuentro 05.
3. Añadir un jefe final con fases múltiples (Boss Fight: Cyber-Shogun) aprovechando los árboles de comportamiento de `qz_ai.gml`.
