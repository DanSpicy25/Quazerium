# 🎮 SKILL: DESARROLLO DE VIDEOJUEGOS 2D & FÍSICAS REATIVAS (STIKMAN GORE)

## 📌 OBJETIVO
Guiar la creación de bucles de juego (Game Loops) eficientes y el cálculo de vectores físicos para mecánicas de combate, desmembramiento por corte y sistemas de partículas persistentes en HTML5 Canvas (JS) o Python (Pygame).

## ⚡ 1. ARQUITECTURA DEL BUCLE (GAME LOOP)
*   **Gestión del Tiempo:** Todo movimiento de entidades, actualización de proyectiles o animaciones DEBE multiplicarse por un factor delta (`deltaTime` o `dt`) para desacoplar las físicas de la tasa de refresco (FPS) del monitor. Garantiza el mismo comportamiento en PC y Laptop.
*   **Separación de Estados:** Mantén una división estricta entre la función de actualización lógica (`update(dt)`) y la función de renderizado gráfico (`draw()` o `render()`).

## ⚔️ 2. LÓGICA DE COMBATE Y ATAQUE CARGADO
*   **Acumulador de Energía:** El estado del jugador debe incluir una variable `chargeTime`. Si la tecla de ataque está presionada, incrementa `chargeTime` multiplicando por `dt` hasta un tope máximo. Al soltarla, si supera el umbral crítico, dispara el flag `isChargedAttack = true`.
*   **Efecto Visual:** Modifica el color del stickman o escala el tamaño del arma de forma proporcional al nivel de carga (`chargeTime / maxChargeTime`).

## 🩸 3. MATEMÁTICAS DE DESMEMBRAMIENTO Y SANGRE (SISTEMA GORE)
*   **Corte por Dirección (Splitting):** Cuando un golpe cargado reduce la vida del enemigo a 0, toma el vector de velocidad del ataque (`attackVector`). Divide la entidad afectada en dos sub-objetos dinámicos independientes:
    *   **Parte Superior:** Hereda la caja de colisión recortada del torso/cabeza y recibe un impulso físico hacia arriba y en la dirección del corte (`attackVector.x * force`).
    *   **Parte Inferior:** Hereda la caja de las piernas y cae directamente por gravedad afectando su fricción con el suelo.
*   **Partículas de Sangre (Vectores):** Al generar un impacto, spawnea un array de partículas rojas. Cada partícula debe inicializarse con una posición `(x, y)` y un vector de velocidad aleatorio dentro del arco del corte. En cada iteración, aplica gravedad a la velocidad: `velocity.y += gravity * dt`.
*   **Manchas Permanentes:** Cuando una partícula de sangre colisione con el suelo (`y >= groundLevel`), desactiva su actualización lógica y píntala directamente de forma permanente sobre el buffer o canvas de fondo para no penalizar el rendimiento con miles de objetos dinámicos activos.

## 🛡️ 4. REGLAS DE CONTROL DE ERRORES (ANTI-BUG GATES)
*   **Piso Físico Fijo:** Evita que los personajes atraviesen el suelo debido a saltos de frames pesados. Si `position.y + height > groundLevel`, reubica la entidad exactamente en `groundLevel - height` y pon su velocidad vertical en 0.
*   **Edición Quirúrgica AST:** No modifiques scripts de físicas completos. Utiliza inserciones locales precisas por bloques para no romper el bucle principal.
