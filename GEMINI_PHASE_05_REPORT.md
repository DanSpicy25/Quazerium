# QUAZERIUM — GEMINI PHASE 05 REPORT
**Action Game HUD, Dynamic Combo Ranks, UI & Visual Polish**  
**Runtime:** GameMaker LTS 2026 (GML)  
**Target:** Native Windows PC (Validated for Intel Core i5-3470 / Intel HD Graphics 2500 / HDD)  
**Status:** **BUILD = PASS · SELFTEST = 44/44 PASS (0 FAILURES)**

---

## 1. Misión de Fase 05 y Filosofía de Diseño

El objetivo principal de la Fase 05 fue transformar la interfaz de usuario de Quazerium en un **Heads-Up Display (HUD) táctil y de alta legibilidad**, diseñado específicamente para un juego de acción frenética en 2D (inspirado en la claridad arcade y la contundencia visual de títulos como *Devil May Cry*, *Hades*, *Katana Zero* y *Guilty Gear*).

### Reglas Clave Aplicadas:
- **Cero Estética SaaS / Dashboard:** Eliminadas todas las tarjetas suaves, transparencias genéricas y recuadros ofimáticos. Cada elemento posee un propósito cinético y táctico.
- **Resolución Virtual Responsiva:** Todo el renderizado de interfaz ocurre dentro del evento GUI (`Draw_64.gml`) configurado a un lienzo canónico de $1280 \times 720$ mediante `display_set_gui_size(1280, 720)`. Esto garantiza proporciones idénticas en 720p, 1080p, 1440p y 4K sin desalineación de coordenadas ni distorsión de relación de aspecto.
- **Cero Asignación Dinámica por Frame:** Todo el HUD se dibuja mediante primitivas directas de GML, trazos de líneas e invocaciones de texto sin instanciar structs, arrays ni objetos temporales en tiempo de ejecución, preservando los 60 FPS estables en GPUs integradas antiguas (Intel HD Graphics 2500).

---

## 2. Componentes del HUD Implementados

### 2.1. Motor de Vitalidad y Energía (`obj_hud/Draw_64.gml`)
- **Marco Chamfered Táctico (Top-Left):**
  - Carcasa de carbono obsidiana oscura (`RGB 12, 16, 22`) con bisel de titanio (`RGB 42, 54, 72`) y corchetes angulares en las esquinas.
  - Etiqueta de grado militar: `CHASSIS INTEGRITY // QZ-CORE`.
- **Barra de Vitalidad (HP):**
  - **Bandeja de Daño Retardado (`hp_lag`):** Barra roja carmesí (`RGB 215, 45, 45`) que muestra la pérdida reciente de salud y se contrae suavemente hacia el HP real mediante interpolación asintótica.
  - **Barra Activa:** Relleno esmeralda cibernético brillante (`RGB 40, 230, 130`) cuando la salud es $>30\%$. Al caer por debajo del $30\%$, cambia dinámicamente a escarlata crítico (`RGB 255, 45, 65`) y pulsa mediante oscilación senoidal.
  - **Segmentación de Blindaje:** 10 divisiones verticales que permiten al jugador calcular con exactitud los umbrales de daño recibido.
  - **Alerta de Emergencia:** Etiqueta parpadeante `CRITICAL` cuando la salud está en niveles de riesgo.
- **Medidor de Energía & Overdrive:**
  - Acumula energía de combate hasta el límite de 100 puntos en cian eléctrico (`RGB 0, 230, 255`).
  - Dividido en 4 cuadrantes correspondientes a los costes de los módulos de poderes tácticos.
  - **Estado Overdrive Listo:** Al llegar al 100%, parpadea en oro radiante con la indicación `[R] OVERDRIVE READY`.
  - **Estado Overdrive Activo:** La barra se transforma en un medidor dorado de drenaje continuo con temporizador numérico exacto en tiempo real (`OVERDRIVE ACTIVE // 7.4s`).

---

### 2.2. Motor Dinámico de Rango de Combo (Mid-Left)
Se activa de forma reactiva al registrar impactos exitosos (`p.combo_count > 0`):
- **Escala de Rangos Arcade:**
  - **Rango D (1–4 impactos):** `DISRUPTOR` — Acero Pizarra (`RGB 165, 180, 195`).
  - **Rango C (5–9 impactos):** `CHARGED` — Azul Neón Azur (`RGB 45, 185, 255`).
  - **Rango B (10–14 impactos):** `BRUTAL` — Verde Esmeralda Viridián (`RGB 40, 240, 130`).
  - **Rango A (15–19 impactos):** `ANARCHY` — Ámbar Solar Dorado (`RGB 255, 205, 30`).
  - **Rango S (20+ impactos):** `SUPREME` — Magenta Hipercinético (`RGB 255, 45, 95`).
- **Insignia Angular y Tipografía:**
  - La letra del rango (`D, C, B, A, S`) se proyecta centrada dentro de una insignia táctica con escalado de rebote dinámico (`combo_scale`) que salta a $1.35\times$ en impactos estándar y $1.55\times$ en golpes críticos, interpolándose suavemente de vuelta a $1.0\times$.
- **Multiplicador de Daño:** Indicador numérico explícito en cian (`+N% DMG`) informando la ventaja acumulada sobre los ataques.
- **Medidor de Desintegración Lineal:** Barra horizontal que representa la ventana de tiempo restante (`combo_timer / combo_window`). Si restan menos de 0.35 segundos para perder la racha, la barra parpadea en blanco para alertar al jugador antes de la desconexión.

---

### 2.3. Capacitor de Armonización Elemental (Bottom-Left)
Ubicado en las coordenadas $(28, 618)$:
- **Módulo de Frecuencia:** Monitorea el elemento activo del jugador (`FIRE`, `WATER`, `EARTH`, `WIND`, `NONE`).
- **Glifos Geométricos Procedurales:**
  - **FIRE:** Doble chevrón ascendente en naranja ígneo (`RGB 255, 115, 35`).
  - **WATER:** Doble prisma de gota diamante en cian acuático (`RGB 40, 195, 255`).
  - **EARTH:** Bloque trapezoidal fortificado en topacio terrenal (`RGB 220, 160, 60`).
  - **WIND:** Cuchillas aerodinámicas diagonales en menta supersónica (`RGB 60, 255, 175`).
  - **NONE:** Retícula concéntrica neutral en titanio pálido.
- **Pips Capacitores:** 4 micro-indicadores luminosos en la base que muestran la sintonización actual con indicación de atajo `[TAB] CYCLE`.

---

### 2.4. Mazo Táctico Modular de Poderes (Bottom-Center)
Ubicado en la parte inferior central $(640, 628)$:
- **Ranuras de Poderes:**
  - Ranura 1: `[1] SHOCKWAVE` (Coste: 20E, CD: 2.0s).
  - Ranura 2: `[2] SURGE` (Coste: 25E, CD: 2.5s).
  - Ranura 3: `[3] BLINK` (Coste: 15E, CD: 1.2s).
- **Indicadores de Estado:**
  - **Selección Activa:** Corchete luminoso superior y resalte cian en la ranura seleccionada por el jugador (`p.selected_power_id`).
  - **Persiana de Cooldown en Tiempo Real:** Cuando el poder está en enfriamiento, una cortina translúcida oscura se desliza verticalmente en proporción exacta a `cd_obj.progress()`, mostrando la cuenta regresiva numérica en segundos (`1.4s`).
  - **Verificación de Batería/Energía:** Si el jugador no posee suficiente energía para ejecutar el poder, la ranura atenúa su opacidad y resalta el coste de energía en rojo con la advertencia `NO NRG`.
  - **Comando Táctico:** Leyenda inferior centrada: `[Q] CAST ACTIVE POWER | [1-3] SELECT`.

---

### 2.5. Overlays Contextuales y Notificaciones del Sistema
- **Banner de Perfil de Hardware (Top-Center):**
  - Al presionar **F2**, se despliega un banner táctico superior con desvanecimiento alfa automático informando el cambio instantáneo de perfil (`// HARDWARE PROFILE: HIGH / MEDIUM / LOW //`).
- **Protocolo de Fallo Crítico / Muerte del Jugador:**
  - Al agotarse la vitalidad del chasis (`hp <= 0`), la pantalla entra en penumbra cinematográfica con una banda de advertencia carmesí y una ventana táctica central:
    - Encabezado: `[ CRITICAL SYSTEM FAILURE ]`.
    - Subtítulo: `CHASSIS INTEGRITY COMPROMISED // VITALS EXTINGUISHED`.
    - Comando de reinicio: `PRESS [SPACE] OR [R] TO REBOOT PROTOCOL` con pulsación luminosa invitando al reinicio instantáneo de la sala.

---

### 2.6. Leyenda de Controles de Combate (Bottom-Right)
- Ubicada de forma no invasiva en $(1256, 696)$:
  `[A/D] MOVE  [SPACE] JUMP  [SHIFT] DASH  [J] ATK  [K] PARRY  [E] HOOK  [F1] DIAG  [F2] PROFILE`.

---

## 3. Validación Técnica y Pruebas Automatizadas

El ejecutable nativo de GameMaker fue compilado y ejecutado en modo headless mediante el compilador real **Igor LTS 2026**.

Se incorporaron dos pruebas de validación automatizadas adicionales al banco de pruebas en `qz_selftest.gml`:
- **Prueba 28 (HUD Combo Ranks):** Valida la progresión exacta de los rangos D, C, B, A, S según los recuentos de impacto a través de `combat_get_combo_rank()`.
- **Prueba 29 (Player Death Event Dispatch):** Valida que el daño letal infligido al jugador dispara exitosamente el evento `EVT.PLAYER_DIED` en el bus de eventos central.

### Registro Oficial de Ejecución de Pruebas:
```text
[gm_gen] resources=34 folders=16 changed=0
Saving IFF file... C:\Users\Valdez\AppData\Local\Temp\qz_build\out\Quazerium.win
Reading File C:\Users\Valdez\AppData\Local\Temp\qz_build\out\Quazerium.win took 0 ms
QZ_SELFTEST_RESULT pass=44 fail=0
###game_end###0
SELFTEST pass=44 fail=0
Exit Code: 0 (SUCCESS)
```

**Resultado:** **44 de 44 pruebas superadas satisfactoriamente con 0 fallos.**

---

## 4. Archivos Modificados / Creados
- `objects/obj_hud/Create_0.gml`: Inicialización de lienzo virtual $1280 \times 720$, suscripción a eventos de hardware, muerte y golpes críticos.
- `objects/obj_hud/Step_0.gml`: Interpolación de barra de lag de daño, temporizador de notificación de perfil y captura de reinicio por muerte.
- `objects/obj_hud/Draw_64.gml`: Renderizado completo del HUD táctil, barras de vitalidad y energía, rangos de combo, selector de poderes, capacitor elemental y overlay de reinicio.
- `scripts/qz_combat/qz_combat.gml`: Implementación del cálculo de rangos de combo (`combat_get_combo_rank`) y emisión de `EVT.PLAYER_DIED`.
- `scripts/qz_selftest/qz_selftest.gml`: Integración de pruebas automatizadas 28 y 29.
