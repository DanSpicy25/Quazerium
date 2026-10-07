"Basándote en este MASTER.md, estructúrame el plano técnico para [escribe aquí lo que quieres construir, ej: El sistema de cobro táctil POS]. Recuerda darme solo comandos directos y bloques XML quirúrgicos sin introducciones ni prosa de relleno".

# 🏢 CONTRATO MAESTRO DE AGENTES: CONFIGURACIÓN, SKILLS Y DIRECTIVAS DEL PROYECTO

> **NOTA PARA CHATGPT:** Este proyecto se desarrolla en una oficina técnica mediante programación asistida por agentes en Visual Studio Code. En este entorno están instaladas globalmente las suites de CodyMaster, OpenSpec (con jCodeMunch AST) y Markdown Memory. Cualquier especificación, instrucción o bloque de requerimientos que generes basándote en este documento DEBE ser hipercompacto, estructurado y libre de prosa o decoraciones conversacionales, usando etiquetas XML o Markdown directas para activar los disparadores (*triggers*) locales de los agentes.

---

## 🚀 1. PROTOCOLO DE INICIALIZACIÓN Y DESCARGA (Fase 1: Setup)
Cuando este proyecto se inicie en una nueva estación de trabajo (Laptop o PC de escritorio), el agente de VS Code debe ejecutar la preparación del entorno y la descarga de dependencias corriendo en la terminal integrada:

```powershell
# 1. Crear el puente estructural para el descubrimiento de habilidades locales
New-Item -ItemType Directory -Force -Path ".agent/skills", ".agents/skills"

# 2. Inicializar la persistencia del pasaporte de memoria compacta
/mm new

# 3. Descargar y clonar los archivos base del proyecto desde el repositorio
git clone https://github.com .
# Nota: Si el proyecto requiere el núcleo API o el CMS alternativo, inicializar:
# git clone https://github.com .

# 4. Instalar dependencias e iniciar el servidor de desarrollo local
npm install
npm run dev
```

---

## 💰 2. DIRECTIVAS DE AHORRO DE TOKENS (ESTRICTO)
*   **Recuperación Quirúrgica AST (jCodeMunch):** Queda estrictamente PROHIBIDO que el agente lea archivos completos o árboles de directorios para realizar modificaciones menores. Se debe invocar la indexación por árbol de símbolos para extraer únicamente la función, clase o componente de React/PHP/Python afectado. Las ediciones deben ser milimétricas.
*   **Aislamiento de Sesión (Markdown Memory):** Al iniciar el día de trabajo o cambiar de máquina, el agente debe ejecutar `/mm resume` para procesar el estado actual desde `passport.md` y `handoff.md`. Al terminar, debe ejecutar `/mm save` para consolidar el progreso sin arrastrar historiales de chat antiguos redundantes.

---

## ⚡ 3. ARQUITECTURA TÉCNICA, OPTIMIZACIÓN Y RENDIMIENTO (WEB & PWA)
Este proyecto opera bajo un enfoque desacoplado de alto rendimiento (Frontend modular + API pura), enfocado en la velocidad radical y la experiencia móvil:

*   **Optimización Estricta Core Web Vitals:** Todo desarrollo frontend en React debe ser optimizado para mitigar el LCP (Largest Contentful Paint) y el INP (Interaction to Next Paint).
*   **Control Total de Layout Shifts (Anti-CLS):** Queda prohibido renderizar imágenes, contenedores dinámicos o pautas publicitarias sin dimensiones estáticas o relaciones de aspecto explícitas (`aspect-*` en Tailwind) para evitar saltos visuales durante la carga.
*   **Estrategia Offline Avanzada:** Los manifiestos de la PWA y los Service Workers deben implementar almacenamiento estructurado (Cache-First para activos estáticos y Network-First con fallback offline suave para llamadas transaccionales asíncronas).

---

## 🎨 4. ACABADO VISUAL PREMIUM ("PÁGINA CARA")
*   **Consistencia Corporativa:** Estructura las vistas siguiendo las leyes de la experiencia de usuario (enforcado por `cm-ux-master`). Usa paletas de grises cálidos o piedra (`stone`/`zinc`) con un uso generoso del espacio en blanco, simulando interfaces de alta gama como Stripe o Linear.
*   **Jerarquía Tipográfica:** Aplica fuentes serif de alta gama (*Lora* o *Merriweather*) para secciones de contenido destacado o títulos editoriales, y fuentes sans-serif empresariales limpias (*Geist*, *Inter* o *Plus Jakarta Sans*) para paneles de control y elementos interactivos táctiles.
*   **Accesibilidad Móvil:** Todo elemento interactivo debe tener un área de pulsación mínima de 44x44px. Antes de dar por completado el módulo, el agente debe auditar la interfaz usando las guías locales de `a11y-debugging` y `playwright-test`.

---

## 🛡️ 5. CONTROL DE SEGURIDAD INTERNA
*   **Prevención de Pérdida de Datos:** Las directivas de `accidental-data-loss-prevention` están activas. Ante cualquier instrucción destructiva (DROP, TRUNCATE, borrado de buckets o scripts de base de datos), el agente debe detener la ejecución y solicitar confirmación manual ("Stop and Verify").
*   **Sanitización Obligatoria:** Toda entrada en formularios o expedientes abiertos debe sanitizarse estrictamente contra ataques XSS y asegurar consultas preparadas PDO en entornos backend para mitigar inyecciones SQL.

---

## 🎮 6. QUAZERIUM — GAMEMAKER (PRIORIDAD SOBRE §1, §3, §4 PARA ESTE PROYECTO)

> Decisión aprobada por el usuario (2026-10-06). Las secciones §1 (npm/git clone), §3 (Web & PWA) y §4 (UI web "página cara") son plantilla genérica y **NO aplican** a Quazerium. §2 (ahorro de tokens / `/mm`) y §5 (prevención de pérdida de datos) siguen vigentes.

<project name="Quazerium">
  <engine>GameMaker (GML) · nativo Windows PC</engine>
  <forbidden>web · Canvas · Electron · React · backend · RPG/inventario/multijugador/monetización inventados</forbidden>
  <hardware_min>i5-3470 · Intel HD 2500 · HDD</hardware_min>
  <quality_profiles>LOW · MEDIUM · HIGH — gameplay idéntico en todos</quality_profiles>
  <layers>
    CORE (gameplay, physics, combat, state, input, AI, interactions)
    PRESENTATION (camera, particles, VFX, animation, lighting, shaders, HUD)
    CONTENT (enemies, arenas, objects, abilities, encounters)
    QUALITY (LOW/MEDIUM/HIGH)
  </layers>
  <rule>Core emite eventos de gameplay; Presentation los escucha. El gameplay nunca depende de VFX.</rule>
  <ownership>Claude: core/gameplay/physics/arquitectura/debug · Gemini: visual/VFX/arte/polish</ownership>
  <save_system>NO requerido actualmente</save_system>
  <phases_authorized>01 Foundation · 02 Input · 03 Time · 04 Player FSM · 05 Physics · 16 Debug (F1)</phases_authorized>
  <phases_pending_authorization>06 Grapple · 07 Combat · 08 Parry · 09 Elements · 10 Powers · 11 Overdrive · 12 Enemies/AI · 13 Interaction · 14 Camera events · 15 Performance</phases_pending_authorization>
  <note>.agent/skills/gamedev/SKILLS.md apunta a Canvas/Pygame: usar solo sus principios (dt, update/draw separados, anti-tunneling), no su stack.</note>
</project>
