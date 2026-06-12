# SDAD v4.3 frente a Harness Engineering — Informe final

**Fecha:** 2026-06-12
**Marco de referencia:** *The Architecture of Harness Engineering for LLM Agentic Systems* (H = E, T, C, S, L, V)
**Método:** análisis $S2 + interrogatorio de debilidades $S2e aplicado y corregido.

---

## 0. Reencuadre (corrección clave del $S2e)

La pregunta no es "¿SDAD es un buen harness?". SDAD **no es un harness**: es una metodología de la
*Construction Layer* (instrucciones en lenguaje natural) que orquesta a Claude Code, el cual aporta el
harness de runtime real. Evaluar SDAD con el rubro completo de un harness de runtime es, en parte, un
error de categoría. Por eso el análisis distingue tres casos:

- **Responsabilidad de Claude Code** (SDAD delega correctamente): el bucle de ejecución de bajo nivel (E),
  el registro de herramientas genérico (T), la captura de trayectoria de runtime (V parcial).
- **Responsabilidad compartida**: gestión de contexto (C), estado/persistencia (S), gates de ciclo de vida (L).
- **Responsabilidad indiscutible de SDAD** (acá no hay excusa de delegación): el mecanismo de trinquete y
  la evaluación de regresión **de la propia metodología**, y el hacer cumplir sus propias compuertas.

Con ese filtro, el veredicto severo "parcial" se ablanda donde SDAD delega bien, y se concentra donde
SDAD sí es dueño del problema.

---

## 1. Veredicto de adopción

**Adopción alta donde SDAD es dueño de la capa; delegación correcta donde no lo es; un hueco real y propio en evaluación.**

SDAD aplica pensamiento de harness de forma sustancial en contexto (C) y estado (S), tiene un registro de
herramientas legítimo en el contexto productor Pyplan-MCP (T), y gates de aprobación humana correctos (L).
Delega E y el T genérico a Claude Code — lo cual es arquitectónicamente correcto. El problema real y propio
es doble: (a) su mecanismo de trinquete codifica el aprendizaje como texto de prompt en vez de check de
código, contradiciendo el Axioma de Gobernanza; y (b) no tiene ningún arnés de regresión sobre sí misma,
pese a modificarse continuamente.

---

## 2. Estado por componente

| Componente | Estado | ¿De quién es la responsabilidad? | Evidencia |
|---|---|---|---|
| **E** Execution Loop | Delegado (OK) | Claude Code | Flujo de fases = bucle humano; runtime lo aporta Claude Code. |
| **T** Tool Registry | Sustancial (Pyplan) / Delegado (genérico) | Compartida / Claude Code | §D: `Annotated`, retornos serializables, scope mínimo; $qa Layer 5. |
| **C** Context Manager | **Sustancial** | SDAD | Context Budget 50/65%, $pause compress, COMPACT ANCHOR, contexto aislado de sub-agentes, markitdown. |
| **S** State Store | Sustancial / Parcial atomicidad | SDAD | filesystem + SPEC.md + git log; DECISIONS.md, §13, §B; patrón AGENTS.md/SOUL.md. |
| **L** Lifecycle Hooks | Sustancial gates / sin heartbeat | Compartida | Hooks v4.2; human-in-the-loop security/compliance; sin detección de zombie-state. |
| **V** Evaluation | **Ausente para la metodología** | **SDAD (indiscutible)** | $qa estático; §13 manual; sin Golden Dataset ni control de regresión. |

---

## 3. Recomendaciones (reordenadas tras el $S2e)

Orden por: lo que sobrevive al interrogatorio + es responsabilidad propia de SDAD + no depende de
supuestos sin verificar.

### ALTO — responsabilidad propia, robusta a la crítica

**R1. Arnés de regresión de la metodología (componente V para SDAD mismo).**
Golden Dataset chico: un $spec de ejemplo, un $build, un $qa con hallazgos conocidos, salidas esperadas.
Ejecutar al cambiar CLAUDE.md o un skill.
*Ventaja:* hoy un edit a SDAD tiene cero detección de regresión; la degradación se ve recién cuando un
proyecto real falla. Vuelve observable "¿este cambio rompió la metodología?". **Indiscutiblemente de SDAD,
no de Claude Code.**

**R2. Reanclar el trinquete Lesson→Guardrail en código.**
Cuando una lección tiene patrón verificable (ej. L-01 ASCII), generar un check (hook/lint/test), no solo
una frase en CLAUDE.md.
*Ventaja:* elimina la recurrencia que el trinquete instruccional no evitó — L-01 está "confirmed twice".
Alinea con el Axioma de Gobernanza (§6): restricción estructural > ruego en el prompt.

### ALTO — supuesto confirmado (2026-06-12)

**R3. Migrar compuertas duras de prompt → hook PreToolUse.** ✅ CONFIRMADO: crear, no extender.
Verificado en `.claude/settings.json` — solo hay 3 hooks registrados (SessionStart, PreCompact,
SessionEnd). **No existe ningún PreToolUse.** Por lo tanto "no código antes del Spec", el bloqueo de
$build por §A/§D/§9 y el bloqueo por Context 65% viven hoy únicamente como instrucciones en CLAUDE.md:
nada los hace cumplir en código.
*Cambio:* agregar un hook PreToolUse que rechace Write/Edit sobre archivos de código cuando SPEC.md no
existe o no está aprobado (recordar: PowerShell 5.1, ASCII-only por L-01).
*Ventaja:* el fallo "se escribió código sin Spec aprobado" deja de ser posible independientemente del
cumplimiento del modelo — pasa de sugerencia a garantía estructural (Axioma de Gobernanza, §6).

### MEDIO

**R4. Heartbeat/liveness en $agent.** `claude --print` solo verifica output vacío; agregar timeout.
*Ventaja:* detecta sub-agentes zombie (cero progreso) en vez de esperar indefinidamente (§6.6).

**R5. Esquema tipado para §13.** AI Authorship Log como registro estructurado (incremento, modelo, effort,
archivos, tests, hallazgos QA).
*Ventaja:* atribución causal cross-proyecto (qué modelo/effort genera más hallazgos), estilo HAL.

**R6. Terminación formal de E ante error de tool en $build.** Definir estado de recuperación cuando un
test/tool falla a mitad de incremento.
*Ventaja:* previene runaway por δ indefinida (ReAct, §3) en contextos automatizados.

### BAJO

**R7.** Determinismo: pinear versiones de modelo en $verify/§5 (ya parcial en Pyplan MCP).
**R8.** Commits atómicos: escribir DECISIONS.md/§13/SPEC como unidad por incremento (evita el fallo
AutoGPT de §3 — historia corrupta por commit no atómico).

---

## 4. Lo que NO hay que cambiar

- **Context Budget + $pause compress + contexto aislado de sub-agentes** — componente C bien resuelto.
- **CLAUDE.md / SPEC.md / DECISIONS.md como memoria permanente** — patrón S correcto (AGENTS.md/SOUL.md).
- **Disciplina §D Pyplan-MCP** — registro T legítimo con validación de esquema.
- **Gates de aprobación humana en security/compliance** — diseño L correcto.

---

## 5. A verificar antes de decidir (cierre $S2e)

1. ~~Leer `.claude/hooks/`~~ ✅ HECHO (2026-06-12): solo SessionStart/PreCompact/SessionEnd, sin PreToolUse. R3 confirmada como "crear".
2. Los números del documento adjunto (Pi 10×, LangChain +26%, etc.) no están verificados contra fuente
   primaria — no citarlos en decisiones sin confirmar.
3. Confirmar el alcance declarado de SDAD: si se documenta explícitamente como "capa de método sobre Claude
   Code", E/T/V de runtime salen formalmente de scope y el foco queda en R1 y R2.

---

*Generado con protocolo $S2 + $S2e. Las recomendaciones R1 y R2 son las robustas a la crítica y de
responsabilidad indiscutible de SDAD. R3 es de alto valor pero condicionada a verificar los hooks existentes.*
