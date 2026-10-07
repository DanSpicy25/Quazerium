# QUAZERIUM — GEMINI PHASE 06 REPORT
**Performance, Quality Scaling & Zero-Allocation Hardening**  
**Runtime:** GameMaker LTS 2026 (GML)  
**Target Hardware Baseline:** Intel Core i5-3470 / Intel HD Graphics 2500 / Mechanical HDD  
**Status:** **BUILD = PASS · SELFTEST = 47/47 PASS (0 FAILURES)**

---

## 1. Misión de Fase 06 y Diagnóstico de Estado Real

El objetivo central de la Fase 06 fue someter a Quazerium a una auditoría técnica profunda de **rendimiento, consumo de memoria y adaptabilidad de hardware**, garantizando que el juego funcione de manera estable a 60 FPS en hardware mínimo de oficina antigua (Intel Core i5-3470 con gráfica integrada Intel HD Graphics 2500 y disco mecánico HDD), al tiempo que el perfil **HIGH** despliega toda su densidad visual y juego de luces sin limitaciones artificiales.

---

## 2. Problemas Encontrados y Soluciones de Arquitectura

### 2.1. Desacoplamiento Estático de Pools de Partículas y Calcas
- **Problema:** En fases anteriores, `VfxParticlePool` y `VfxDecalPool` se inicializaban tomando `q.max_particles` y `q.max_decals` una única vez durante el evento Create. Si el jugador cambiaba de perfil de hardware en caliente mediante **F2**, la capacidad máxima interna y los ciclos de iteración permanecían fijos en el tamaño original. Además, en `obj_vfx`, los eventos de combate aplicaban multiplicadores locales arbitrarios (`0.5` o `1.0`) ignorando el multiplicador de escala del perfil `HIGH` (`1.5x`).
- **Solución:**
  - Los pools se pre-asignan **una sola vez** al inicio con la capacidad máxima (`2048` partículas, `128` calcas, `32` textos flotantes), ocupando un espacio en RAM despreciable (< 200 KB) con **cero asignaciones dinámicas en caliente ni recolección de basura (0 GC)**.
  - Se introdujo `vfx_get_budget()` y delimitadores dinámicos `min(max_count, quality_get().max_particles)` en los métodos `spawn()`, `update()` y `draw()`.
  - En **LOW**, el motor únicamente itera sobre 100 partículas y 24 calcas, reduciendo la carga de CPU de los bucles por frame en más de un 80%.
  - Se implementó `set_budget(new_limit)` y suscripción directa al evento `EVT.QUALITY_CHANGED`, garantizando que cambiar de perfil reasigne los punteros modulares y purgue partículas excedentes sin recrear estructuras en memoria.

### 2.2. Sobrecarga de Renderizado en Entorno y Fondo
- **Problema:** `obj_environment` ejecutaba la actualización y dibujo de 50 a 100 motas de polvo atmosférico (`ambient_count`) de forma estática, calculaba ventanas lejanas en rascacielos y ejecutaba conos de luz volumétrica aditiva (`bm_add`) independientemente de la capacidad de la GPU.
- **Solución:**
  - En **LOW**, la iluminación volumétrica aditiva (`enable_lighting = false`) y los cálculos de ventanas de rascacielos (`draw_distant_windows = false`) se desactivan por completo, ahorrando cambios de estado de GPU y mezclas aditivas en Intel HD 2500.
  - El recuento de motas de polvo ahora escala dinámicamente: **15 en LOW**, **40 en MEDIUM** y **80 en HIGH**, consultado directamente desde `quality_get().ambient_dust` sin costo de suscripción.

### 2.3. Estelas de Afterimages del Jugador
- **Problema:** El bucle de actualización y dibujo de estelas fantasma del dash/overdrive (`afterimages`) iteraba fixed sobre 6 elementos, provocando sobrecarga de dibujado en ráfagas rápidas.
- **Solución:** Las estelas ahora respetan estrictamente `quality_get().trail_segments`:
  - **LOW:** 2 estelas fantasma (máxima ligereza cinemática).
  - **MEDIUM:** 4 estelas fantasma (equilibrio arcade).
  - **HIGH:** 6 estelas fantasma (máxima fluidez visual).

### 2.4. Garantía de Compatibilidad con Discos Mecánicos (HDD)
- **Auditoría de I/O de Archivos:** Se comprobó que el juego no realiza ninguna llamada a `file_text_*`, `buffer_load_*` ni carga sincrónica de texturas durante el bucle de juego. Todos los sistemas, parámetros y tablas operan de forma 100% residente en RAM desde el arranque, eliminando tirones (*micro-stutters*) por acceso al cabezal del HDD.

---

## 3. Matriz de Perfiles de Calidad y Presupuestos (Budgets)

| Métrica / Parámetro | LOW (Intel HD 2500) | MEDIUM (PC Estándar) | HIGH (PC Potente) | Impacto Técnico |
| :--- | :---: | :---: | :---: | :--- |
| **Límite Máximo de Partículas** | **100** | **500** | **2000** | Bounded array cycling, 0 allocs |
| **Límite Máximo de Calcas** | **24** | **64** | **128** | Bounded array cycling, 0 allocs |
| **Vida Útil de Calcas** | **4.0s** | **7.0s** | **12.0s** | Desvanecimiento temporal controlado |
| **Multiplicador VFX / Chispas** | **0.5x** | **1.0x** | **1.5x** | `vfx_get_budget()` escala conteo de emisión |
| **Iluminación 2D Volumétrica** | **Desactivada** | **Activada** | **Activada** | Evita pases de mezcla aditiva `bm_add` |
| **Shaders / Mezcla Aditiva** | **Desactivada** | **Activada** | **Activada** | Cero cambios de shader/estado en GPU |
| **Segmentos de Afterimage** | **2** | **4** | **6** | Reduce polígonos de estelas en dash |
| **Motas de Polvo Ambiental** | **15** | **40** | **80** | Reduce primitivas de fondo |
| **Ventanas de Rascacielos** | **Desactivadas** | **Activadas** | **Activadas** | Elimina micro-rectángulos lejanos |
| **Multiplicador de Shake** | **0.8x** | **1.0x** | **1.2x** | Ajuste cinemático de trauma |

> **Principio de Invarianza de Gameplay:** El motor de físicas cinemáticas (`qz_physics`), la máquina de estados del jugador (`obj_player`), las cajas de colisión (`obj_hitbox`), los árboles de comportamiento de IA (`obj_enemy_base`), el gancho de tracción elástica (`qz_grapple`) y las fórmulas de daño y combos (`qz_combat`) son **exactamente idénticos** en todos los perfiles de calidad.

---

## 4. Telemetría y Métricas en Tiempo Real (`obj_debug/Draw_64.gml`)

Se integró una sección completa de **HARDWARE & VFX BUDGETS** en el overlay de diagnóstico (activable mediante la tecla **F1**), permitiendo monitorear empíricamente durante las sesiones de prueba:
- **FPS Real & Frame Time (ms):** Monitoreo directo de tiempo de cuadro de CPU y GPU.
- **Perfil Activo & Ciclo F2:** Indicación instantánea de LOW / MEDIUM / HIGH.
- **Conteo de Instancias & Entidades:** `Instances: N | Entities: N`.
- **Presupuesto de Partículas Activas:** `Particles: {activas} / {max_budget} (Budget: Nx)`.
- **Presupuesto de Calcas y Textos:** `Decals: {activas} / {max_budget} | Combat Text: {activos} / 32`.
- **Estado de Iluminación y Shaders:** `2D Lighting: ON/OFF | Shaders: ON/OFF`.

---

## 5. Pruebas Automatizadas y Validación Técnica

Se expandió el banco de pruebas automatizadas en [`scripts/qz_selftest/qz_selftest.gml`](file:///c:/Users/Valdez/Documents/Quazerium/scripts/qz_selftest/qz_selftest.gml) con 3 pruebas rigurosas de verificación de presupuestos:
- **Prueba 30 (Quality Profile Switching & Budgets):** Valida que el cambio dinámico entre `QUALITY.LOW` y `QUALITY.HIGH` aplique con exactitud los presupuestos de partículas, calcas, shaders, iluminación y multiplicadores de VFX.
- **Prueba 31 (VfxParticlePool Dynamic Clamping & Zero-Allocation):** Valida que al forzar la emisión de 150 partículas en perfil `LOW`, el pool limite estrictamente el recuento de partículas activas al tope de 100 sin desbordamiento ni asignaciones.
- **Prueba 32 (VfxDecalPool Dynamic Clamping & Budget Scaling):** Valida que al forzar la creación de 40 calcas en perfil `LOW`, el pool limite estrictamente las calcas activas al tope de 24.

### Registro Oficial de Ejecución de Pruebas:
```text
[gm_gen] resources=34 folders=16 changed=0
Saving IFF file... C:\Users\Valdez\AppData\Local\Temp\qz_build\out\Quazerium.win
Reading File C:\Users\Valdez\AppData\Local\Temp\qz_build\out\Quazerium.win took 0 ms
QZ_SELFTEST_RESULT pass=47 fail=0
###game_end###0
SELFTEST pass=47 fail=0
Exit Code: 0 (SUCCESS)
```

**Resultado:** **47 de 47 pruebas unitarias aprobadas (0 fallos).**

---

## 6. Archivos Modificados
- `scripts/qz_quality/qz_quality.gml`: Presupuestos exactos de hardware para LOW, MEDIUM y HIGH (partículas, calcas, vida de calcas, estelas, polvo, shaders, luces).
- `scripts/qz_vfx/qz_vfx.gml`: Implementación de `vfx_get_budget()`, métodos `set_budget()` y `get_active_count()` en `VfxParticlePool`, `VfxDecalPool` y `VfxCombatTextPool`, con bucles acotados dinámicamente al perfil activo.
- `objects/obj_vfx/Create_0.gml`: Pre-asignación fija de 2048 partículas y 128 calcas, suscripción a `EVT.QUALITY_CHANGED`, y sustitución de multiplicadores fijos por `vfx_get_budget()`.
- `objects/obj_vfx/Step_0.gml`: Escala de emisión continua de aura de Overdrive según el presupuesto de calidad.
- `objects/obj_environment/Create_0.gml`, `Step_0.gml`, `Draw_0.gml`: Pre-asignación de 100 motas de polvo con conteo dinámico (`ambient_dust`), y desactivación de ventanas lejanas en LOW (`draw_distant_windows`).
- `objects/obj_player/Step_0.gml`, `Draw_0.gml`: Acotación dinámica de bucles de actualización y dibujo de afterimages según `trail_segments`.
- `objects/obj_debug/Draw_64.gml`: Incorporación de sección de telemetría de presupuestos de hardware en tiempo real (F1).
- `scripts/qz_selftest/qz_selftest.gml`: Incorporación de pruebas 30, 31 y 32 de aseguramiento de calidad y rendimiento.
