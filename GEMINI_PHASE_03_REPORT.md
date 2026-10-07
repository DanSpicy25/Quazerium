# QUAZERIUM — GEMINI PHASE 03 REPORT
**Combat VFX, Powers & Elements Enhancement**  
**Runtime:** GameMaker LTS 2026 (GML)  
**Target:** Native Windows PC (Validated for Intel Core i5-3470 / Intel HD Graphics 2500 / HDD)  
**Status:** **BUILD = PASS · SELFTEST = 40/40 PASS (0 FAILURES)**

---

## 1. Estado Inicial de Fase 03
Al iniciar la Fase 03:
- El movimiento del jugador y la cinemática procedural básica habían quedado integrados y probados en la Fase 02 con 36 pruebas unitarias exitosas.
- El combate en `qz_combat.gml` resolvía correctamente fórmulas matemáticas, hitstop, parry, retroceso y reacciones elementales en el Core.
- Sin embargo, la capa visual de combate presentaba carencias críticas:
  - Los impactos normales y críticos carecían de ángulo de dispersión direccional (emitían chispas estocásticas sin relación con el vector atacante-víctima).
  - Las entidades enemigas no activaban el parpadeo visual blanco (`hit_flash`) al ser impactadas.
  - Los números de combate flotantes no tenían jerarquía estilizada, carecían de borde de alto contraste (shadow de 4 vías) y se encimaban cuando ocurrían golpes rápidos sucesivos.
  - Los tres poderes existentes (**Shockwave**, **Blade Surge**, **Blink**) no tenían identidad visual individual conectada al sistema de partículas o decals.
  - Los elementos (Fuego, Agua, Tierra, Viento) y sus 6 reacciones asociadas (Vaporize, Freeze, Swirl, Magma, Mud, Erosion) carecían de VFX diferenciados por comportamiento físico (gravedad, rotación, forma de partículas).
  - El estado de **Overdrive** carecía de aura continua en tiempo real, disipación de escape al expirar y feedback amplificado en el arma.
  - El pool de calcomanías (`VfxDecalPool`) no respetaba la duración dinámica por perfil de hardware (`decal_life`), provocando valores `undefined` en bajo rendimiento.
  - Los eventos de combate, poderes y muerte no estaban conectados al despachador de audio ni al sistema de trauma de cámara.

---

## 2. Sistemas y Mejoras Implementadas

### 2.1. Feedback de Impacto y Legibilidad de Combate
- **Hit Confirmed (`EVT.HIT_CONFIRMED`):**
  - Cálculo del ángulo de impacto atacante-víctima (`hit_ang = point_direction(ax, ay, tx, ty)`).
  - Chispas direccionales proyectadas en un cono de ±40° en la dirección del impacto, más chispas perpendiculares de corte en ±90°.
  - Activación inmediata de `hit_flash = 0.08` sobre la entidad defensora.
  - Infusión de partículas elementales reactivas si el golpe porta un elemento activo.
- **Hit Critical (`EVT.HIT_CRITICAL`):**
  - Chispas doradas de alta velocidad (200–520 px/s) a lo largo del arco de corte.
  - Anillo de choque dorado expansivo (`VFX_SHAPE.RING`) con radio de 8 a 56 px.
  - Flash de pantalla suave dorado (`c_yellow`, alpha 0.22).
  - Calcomanía de corte tajante (`DECAL_TYPE.SLASH`) en la superficie.
  - Trauma direccional en la cámara con impulso cinético.
- **Parry Normal vs. Perfect Parry:**
  - *Normal Parry:* Anillo de deflexión cian, chispas frontales de bloqueo, banner de texto "PARRY!" en cian y hook de audio metálico.
  - *Perfect Parry:* Anillo dual dorado y cian expansivo (hasta 120 px de radio), ráfaga radial de 360° con 28 estelas, flash de pantalla blanco puro (alpha 0.38), banner dorado brillante "PERFECT PARRY!" (escala 1.55), impulso de cámara y campana resonante.

### 2.2. Jerarquía y Anti-Superposición de Números de Daño (`VfxCombatTextPool`)
- **Jerarquía Visual:**
  - *Normal Hit:* Blanco/plata nítido, escala 1.0, duración 0.7s.
  - *Critical Hit:* Dorado/ámbar con prefijo "CRIT [daño]", escala 1.4, duración 0.9s, efecto pop-in.
  - *Reacciones Elementales:* Banners con nombres temáticos coloreados (Vaporize, Freeze, Swirl, etc.).
  - *Perfect Parry:* Dorado radiante con escala 1.55.
  - *Execution / Kill:* Banners carmesí "EXECUTION!" al aniquilar enemigos.
  - *Overdrive:* Banner de alta prioridad "OVERDRIVE ACTIVATED!" / "OVERDRIVE READY!".
- **Contraste Extremo:** Delineado de sombra cuádruple en negro (`x±1, y±1`) dibujado antes del texto central, garantizando legibilidad perfecta sobre cualquier fondo o explosión.
- **Algoritmo Anti-Overlap:** Al generarse un número cerca de otro existente (<28 px), el sistema detecta la superposición y desplaza automáticamente el nuevo texto hacia arriba (`py - 14 * overlap_count`) con dispersión estocástica en X.

### 2.3. Identidad Visual Individual de Poderes (`EVT.POWER`)
- **Shockwave (`POWER_ID.SHOCKWAVE`):**
  - Anillo de choque eléctrico expansivo cian y blanco (de radio 10 a 120 px).
  - Ráfaga radial omnidireccional de 24 estelas luminosas.
  - Calcomanía de fractura en el piso (`DECAL_TYPE.CRACK`).
  - Ondas de polvo lateral a izquierda y derecha.
  - Flash de pantalla y banner "SHOCKWAVE!".
- **Blade Surge (`POWER_ID.BLADE_SURGE`):**
  - Estelas de corte supersónicas proyectadas en el vector de avance (velocidad hasta 750 px/s).
  - Silueta aerodinámica proyectil en el jugador y estela de corte en el suelo (`DECAL_TYPE.SLASH`).
  - Al expirar (`EVT.POWER_END`): chispas de frenado y polvo de desaceleración.
  - Banner "BLADE SURGE!".
- **Blink (`POWER_ID.BLINK`):**
  - *Salida (Departure):* Anillo de colapso cuántico implosivo y partículas absorbidas hacia el centro.
  - *Desplazamiento (Beam):* Rayo cuántico segmentado con motes enlazando origen y destino.
  - *Llegada (Arrival):* Anillo de expansión cuántica, destello en pantalla y micro-sismo de cámara.
  - Banner "BLINK!".

### 2.4. Firmas Visuales de Elementos y Reacciones (`qz_elements.gml` & `obj_vfx`)
- **Elementos Base:**
  - *Fuego:* Ascenso térmico con gravedad negativa (`ay = -160`), chispas naranjas/rojas y marcas de calcinado (`DECAL_TYPE.SCORCH`).
  - *Tierra:* Fragmentos minerales pesados (`VFX_SHAPE.SHARD`) con alta caída vertical (`ay = 400`), giro angular y grietas (`DECAL_TYPE.CRACK`).
  - *Agua:* Gotas fluidas (`VFX_SHAPE.DUST`, `ay = 200`), anillos de onda azul cerúleo.
  - *Viento:* Estelas verdes de vórtice de alta velocidad con giro espiral tangencial.
- **6 Reacciones Exclusivas:**
  1. *VAPORIZE (Fuego + Agua):* Nubes de vapor hirviente, anillo de choque concéntrico dual y banner naranja-dorado.
  2. *FREEZE (Agua + Viento):* Explosión de esquirlas de hielo cristalino, anillo congelado y flash cian.
  3. *SWIRL (Fuego + Viento):* Ciclón de fuego con estelas en rotación espiral angular (300 deg/s).
  4. *MAGMA (Fuego + Tierra):* Eyección volcánica de roca fundida con marcas de quemado duraderas.
  5. *MUD (Agua + Tierra):* Salpicaduras densas de fango con goteo gravitacional pronunciado.
  6. *EROSION (Tierra + Viento):* Detonación de polvo y escombros rocosos, doble onda expansiva y fractura en suelo.

### 2.5. Overdrive Completo
- **Aura Activa Continua:** Mientras `overdrive_active == true`, `obj_vfx` emite continuamente plasma radiante ascendente alrededor del jugador.
- **Renderizado del Jugador:** El pulso de energía de la armadura cicla entre oro y blanco; el sable láser dibuja una doble aura luminosa dorada ensanchada.
- **Finalización (`EVT.OVERDRIVE_END`):** Salida de vapor y humo disipado lateralmente desde los disipadores del chasis y banner "OVERDRIVE EXHAUSTED".

### 2.6. Persistencia y Control de Calcomanías (`VfxDecalPool`)
- Capacidad estricta vinculada al perfil de calidad (`max_decals: 24` en LOW, `64` en MEDIUM, `128` en HIGH).
- Vida útil dinámica configurada por perfil (`decal_life: 4.0s` en LOW, `7.0s` en MEDIUM, `12.0s` en HIGH).
- Desvanecimiento suave en el último 40% de vida. Cero fugas de memoria o crecimiento descontrolado.

### 2.7. Hooks de Audio y Trauma de Cámara
- `qz_audio.gml` conectado a `EVT.POWER`, `EVT.POWER_END`, `EVT.OVERDRIVE_END`, `EVT.ENTITY_KILLED`, `EVT.ELEMENT_CHANGED`, `EVT.ENERGY_FULL` con registro de auditoría en `global.audio.recent_log`.
- `obj_camera` configurado con trauma e impulso específico para `EVT.ELEMENT_REACTION` (trauma 0.22) y `EVT.ENTITY_KILLED` (trauma 0.28).

---

## 3. Presupuesto de Rendimiento por Perfil

| Parámetro | LOW (Intel HD 2500) | MEDIUM (PC Estándar) | HIGH (Entusiasta) |
| :--- | :--- | :--- | :--- |
| **Partículas Máximas** | 100 | 500 | 2000 |
| **Calcomanías Máximas** | 24 | 64 | 128 |
| **Vida de Calcomanías** | 4.0 seg | 7.0 seg | 12.0 seg |
| **Budget Multiplier VFX** | 0.5x | 1.0x | 1.5x |
| **Modo de Mezcla Additive**| Desactivado (`bm_normal`) | Activado (`bm_add`) | Activado (`bm_add`) |
| **Intensidad de Flashes** | Reducida (cap 0.3) | Completa | Completa |

---

## 4. Resultados de Compilación y Pruebas Automatizadas

```text
Compilation Target: Native Windows VM (Igor.exe)
Project File: Quazerium.yyp (34 Resources, 16 Folders)
Self-Test Result:
========================================
QUAZERIUM SELF-TEST SUITE: pass=40 fail=0
QZ_SELFTEST_RESULT pass=40 fail=0
========================================
Exit Code: 0 (SUCCESS)
```

### Resumen de Tests Nuevos en Fase 03:
- **Test 22:** Powers — Verificación de emisión de payload espacial en `EVT.POWER` para Shockwave, Blade Surge y Blink.
- **Test 23:** Presentation — Algoritmo anti-overlap de números de daño (espaciado vertical ascendente garantizado).
- **Test 24:** Presentation — Calcomanías respetando límite de vida del perfil de hardware LOW (4.0s).
- **Test 25:** Audio — Captura y registro de eventos de poderes en el despachador central de sonido.

---

## 5. Problemas Restantes y Recomendaciones para Fase 04
1. **Contenido de Enemigos (Fase 04):** Actualmente solo existen `obj_enemy_grunt` y `obj_enemy_dummy`. Se recomienda expandir a tipos con comportamientos diferenciados (tirador a distancia, bruto con escudo blindado, unidad rápida voladora).
2. **Audio Assets Físicos:** El despachador de audio cuenta con hooks síncronos listos con modulación de pitch; cuando se añadan archivos `.wav`/`.ogg` al proyecto, sonarán instantáneamente sin tocar código de gameplay.
3. **Shader de Distorsión Térmica:** En perfil HIGH, se puede añadir una superficie de refracción para el colapso cuántico del Blink y la explosión de vapor de Vaporize.
