# Harness Engineering (video) vs SDAD v5 — Análisis comparativo
**Fecha:** 2026-06-15  
**Fuente video:** transcript "Qué es esto del Harness Engineering" (español)  
**Referencia SDAD:** CLAUDE.md v5.0 + SDAD_v5_Thesis.md

---

## TL;DR

El video define Harness Engineering con 4 componentes (Contexto, Herramientas, Memoria, Validación) y 3 pilares (Repo como sistema, Orquestación multiagente, Verificación). SDAD v5 cubre los 4 componentes e implementa los 3 pilares, pero con mayor profundidad formal. Hay **dos gaps reales** y **tres conceptos del video que SDAD trata diferente** (no peor, pero distinto). También hay **cuatro áreas donde SDAD va considerablemente más lejos** que lo planteado en el video.

---

## 1. El modelo del video vs el modelo de SDAD

### Lo que propone el video

```
              CONTEXTO
                 │
HERRAMIENTAS ── [MODELO IA] ── (output)
                 │
              MEMORIA   VALIDAR
```

Cuatro elementos que rodean al modelo. La metáfora es el "arnés": riendas que controlan al caballo desbocado. El video luego los convierte en 3 pilares operacionales:

1. **El repo como el sistema** — el arnés vive en los ficheros del repositorio
2. **Orquestación multiagente** — orquestador + subagentes con contexto aislado
3. **Verificación** — el agente debe *demostrar* que algo funciona, no solo *declararlo*

### Lo que tiene SDAD v5

SDAD formaliza el arnés como H = (E, T, C, S, L, V):

| Componente video | Componente H= | Implementación SDAD |
|---|---|---|
| Contexto | **C** — Context Manager | Context Budget 50%/65%, $pause compress, COMPACT ANCHOR, markitdown |
| Herramientas | **T** — Tool Registry | §D Pyplan-MCP (Annotated, scope mínimo), CLI-vs-MCP rule §7 |
| Memoria | **S** — State Store | SPEC.md + DECISIONS.md + LESSON_LIBRARY.md + git |
| Validar | **V** — Evaluation Interface | $qa 4 capas, $eval golden dataset, sub-agente reviewer |
| (implícito) | **E** — Execution Loop | Delegado a Claude Code + .sdad/lib/agent-run (timeout 600s) |
| (implícito) | **L** — Lifecycle Hooks | SessionStart, PreCompact, SessionEnd + PreToolUse (v5) |

SDAD no solo nombra los 4 componentes del video: los descompone 6 formas con responsabilidades diferenciadas.

---

## 2. Los 3 pilares del video y cómo aparecen en SDAD

### Pilar 1 — El repo como el sistema

**Video:** Todo el arnés vive en ficheros del repo (agents.md, featurelist.json, progress/, etc.). El modelo lee los ficheros para saber qué hacer. El contexto de la IA se construye desde el repo, no desde la conversación.

**SDAD:** Implementado y expandido. CLAUDE.md, SPEC.md, DECISIONS.md, LESSON_LIBRARY.md y `.claude/` son todos ficheros del repo. La regla "leer archivos reales antes de preguntar" garantiza que Phase 0 es lectura del repo. Los hooks también viven como scripts en el repo. Lo que SDAD agrega: **la Spec como contrato formal** (no solo lista de tareas) y **la Decision Log** (no solo estado de progreso).

**Diferencia notable:** el video usa un `featurelist.json` con criterios de aceptación y status. SDAD usa SPEC.md (contrato completo de 13 secciones). SDAD es más formal pero más pesado de iniciar.

### Pilar 2 — Orquestación multiagente

**Video:** Un agente orquestador (líder) lanza subagentes especializados. Los subagentes escriben resultados en carpeta `progress/` (memoria externa) para evitar "el teléfono descompuesto" — que el orquestador le pase todo su contexto al subagente.

**SDAD:** Implementado con las mismas ideas. `$agent review`, `$agent test`, `$agent audit` se delegan a sub-agentes con contexto aislado. Los subagentes retornan un HANDOFF BLOCK escrito en `.sdad/agent_output.tmp`. La regla explícita: "Sub-agents run in isolated context — they do not consume the main session budget." El video dice exactamente lo mismo con otras palabras.

Lo que SDAD agrega: `.sdad/lib/agent-run` con timeout de 600s y guard de output vacío. El video no menciona gestión de agentes zombie — SDAD sí (aunque está en MEDIO del backlog por R4).

### Pilar 3 — Verificación

**Video:** El agente de IA no puede simplemente *decir* que algo está hecho. Debe *demostrarlo* con herramientas: tests automatizados, browser testing (Puppeteer/Chrome DevTools). El reviewer puede modificar su propio .md para auto-mejorarse.

**SDAD:** `$qa` en 4 capas corre automáticamente después de cada `$build`. La regla es "Run actual tests after every $build increment — never skip execution." El sub-agente reviewer existe en `.claude/agents/`. Los hooks (SessionEnd) como mecanismo de verificación de estado del proyecto al cerrar.

Lo que el video menciona que SDAD **no enfatiza igual:** el video dice explícitamente que el reviewer puede modificar su propio `.md` (auto-mejora del arnés). SDAD propone actualizaciones al CLAUDE.md del proyecto (paso 5.5 post-increment) pero como sugerencia al developer, no como acción autónoma del agente.

---

## 3. Gaps reales — donde el video señala algo que SDAD no cubre bien

### Gap 1: El principio de herramientas simples

**Lo que dice el video:** Vercel eliminó el 80% de sus tools especializadas del agente D0. Resultado: 3x más rápido, 37% menos tokens. La conclusión: *cuanto más complejo haces el arnés, peor funciona.* "Equipar a los agentes con herramientas hiperespecializadas es contraproducente."

**Qué hace SDAD:** La regla CLI-vs-MCP en §7 toca esto, pero desde el ángulo de seguridad (shell injection, credentials-in-argv). No existe en SDAD ninguna regla explícita sobre **minimalismo de herramientas** como principio de rendimiento. El skills system (10+ skills on-demand) es la dirección opuesta: riqueza de herramientas especialistas disponibles.

**¿Es un problema real?** Probablemente no para el flujo principal, porque los skills se cargan on-demand y el modelo los procesa en contexto reducido. Pero el principio no está articulado y podría serlo: "activar solo los skills que el increment necesita."

**Recomendación:** Añadir una nota en el Behavior Rules o en el skill system: skills se cargan on-demand precisamente para mantener el prompt base lean. Citar el principio explícitamente.

### Gap 2: El umbral de degradación del contexto

**Lo que dice el video:** La degradación empieza alrededor del 20% de uso del contexto. A 40% ya se recomienda limpiar (según un issue en GitHub de Claude Code).

**Qué hace SDAD:** Los thresholds son 50% (soft warning) y 65% (hard warning). El video sugiere que ya a 40% hay degradación notable.

**¿Es un problema real?** Sí, con matices. El video cita un issue de GitHub — es evidencia anecdótica, no un paper de Anthropic. Pero si la degradación es real a partir del 20-40%, entonces el warning de SDAD al 50% llega tarde. La diferencia importa especialmente en sesiones largas de $build.

**Recomendación:** Bajar el soft warning a 40% o agregar un informational a 30% como "early heads-up". O documentar en la tesis por qué se eligió 50% (si hay razonamiento empírico propio).

---

## 4. Donde SDAD va considerablemente más lejos que el video

| Concepto | Video | SDAD v5 |
|---|---|---|
| **Gate formal pre-código** | No existe (el agente empieza a implementar) | Spec gate: código imposible sin SPEC.md aprobado (PreToolUse hook) |
| **Compliance y seguridad** | No mencionado | 3 tiers + Compliance Reviewer + §9 mandatory en Tier 3 |
| **Auditabilidad** | Log de progreso en carpetas | §13 AI Authorship Log: modelo, effort, archivos, tests, QA findings por increment |
| **Aprendizaje cross-proyecto** | No existe | LESSON_LIBRARY.md + knowledge ratchet + lesson→guardrail en código |
| **Routing de modelo/esfuerzo** | No mencionado | Tabla de routing FRONTIER/STANDARD/ECONOMY por fase |
| **Evaluación de la metodología** | No existe | $eval golden dataset — detecta regresiones en CLAUDE.md y skills |
| **Plataforma Pyplan** | No aplica | Extensión completa con §A, §D, MCP tools, checklist específico |
| **Auto-mejora gobernada** | Agente modifica su .md libremente | Propuesta al developer (paso 5.5) — no autónoma |

La última fila es una diferencia de filosofía, no de omisión. El video ve la auto-mejora autónoma del arnés como deseable. SDAD mantiene al developer en el loop — el agente *propone*, el developer *aprueba*. Es consistente con el Governance Axiom de SDAD: las decisiones estructurales requieren aprobación humana.

---

## 5. Cómo mejorar la explicación teórica de SDAD

El video comunica harness engineering en 25 minutos con una pizarra y tres conceptos. La tesis de SDAD tiene 1449 líneas de monografía académica. Ambos son necesarios pero para audiencias diferentes. La oportunidad es crear un nivel intermedio.

### 5.1 Reencuadre conceptual recomendado

En lugar de empezar con "SDAD es una metodología de 5 fases", empezar con la metáfora del video y luego mostrar cómo SDAD la implementa:

> "Un modelo de IA sin estructura es un caballo desbocado — capaz, rápido, pero difícil de controlar. SDAD es el arnés: el sistema de contexto, memoria, herramientas y verificación que convierte a Claude Code en un colaborador predecible. Pero a diferencia de un arnés genérico, SDAD agrega un contrato (el Spec) y un tribunal (el QA) — porque la velocidad sin accountability no es un avance."

### 5.2 Los 3 pilares de SDAD (adaptados del video)

| Pilar video | Pilar SDAD |
|---|---|
| El repo como sistema | **El Spec como contrato** — todo vive en SPEC.md, DECISIONS.md, LESSON_LIBRARY.md en el repo. El modelo lee, no inventa. |
| Orquestación multiagente | **Fases con gates** — el modelo no puede pasar de fase sin aprobación. Subagentes con contexto aislado para tareas costosas. |
| Verificación | **QA automático + $eval** — el agente demuestra que funciona (tests reales), y la metodología se evalúa a sí misma (golden dataset). |

### 5.3 La explicación de una frase

"SDAD impone un contrato antes de que empiece el código, registra cada decisión mientras se construye, y verifica cada resultado cuando termina — todo dentro del repositorio, todo atribuible a un modelo y un momento."

### 5.4 Qué agregar a los diagramas (ver archivo HTML adjunto)

1. **Diagrama del arnés** — el modelo central con los 4 componentes del video, mapeados a las herramientas de SDAD
2. **Pipeline de fases con gates** — las 5 fases como carril con compuertas de aprobación
3. **Los 3 pilares** — el Spec, las Fases, la Verificación como columnas
4. **La Governance Axiom** — el espectro prompt-rule → code-gate con ejemplos de SDAD en cada extremo

---

## 6. Veredicto final

**SDAD v5 es un superset del harness que describe el video.** Implementa los 4 componentes, los 3 pilares, y agrega compliance, auditabilidad, routing de modelos y auto-evaluación de la metodología. Los dos gaps reales son el principio de minimalismo de herramientas (no articulado explícitamente) y el umbral de degradación del contexto (probablemente demasiado conservador). Ninguno es un fallo de arquitectura — son oportunidades de documentación y calibración.

Lo que el video hace *mejor* que la tesis es la comunicación: una pizarra, una metáfora, tres pilares. Ese nivel de claridad es el que falta en la explicación pública de SDAD.
