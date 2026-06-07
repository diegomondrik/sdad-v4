# SDAD v4.2 — Roadmap Final de Desarrollo

**Fecha:** 2026-06-05
**Estado:** spec de v4.2 — aprobado para ejecución en Claude Code
**Base:** roadmap v4.2 (draft) + revisión crítica ($S1e) aplicada
**Entorno de desarrollo:** Claude Code (no Cowork). Ver §0.

---

## §0 — Entorno y modo de trabajo

Este documento es el **spec de v4.2**. El desarrollo se ejecuta en **Claude Code**, sobre el repo `sdad-v4 github`, por las siguientes razones:

- Track B (hooks) debe testearse en Windows real — no es verificable fuera de Claude Code.
- `$build` / `$qa` / `$verify` / `$agent` son nativos de Claude Code y operan sobre el propio repo.
- Editar CLAUDE.md y `.claude/` desde un segundo entorno genera conflictos de estado/git.

Cowork se usó solo para producir este spec. A partir de acá: mover este archivo al repo (ya está), abrir Claude Code, y arrancar por Track A.

---

## §1 — Cambios respecto al draft (qué corrigió la revisión crítica)

Las siguientes correcciones están **incorporadas** a este documento. No son sugerencias: redefinen el alcance de v4.2.

| # | Hallazgo de la revisión | Resolución aplicada en este roadmap |
|---|---|---|
| 1 | C-007 Opción B no sobrevive a la compactación (la controla el harness) y duplica `$pause compress`. | C-007 **rebajado**: no es comando nuevo. Se fusiona como extensión de `$pause compress` + convención `[LOCK]`. El mecanismo real (PreCompact hook) queda en Track B, no en CLAUDE.md-only. |
| 2 | v4.2 agranda el CLAUDE.md de SDAD y empeora el problema de contexto que GAP 4 quiere resolver. | **Nuevo requisito transversal (§2.0):** medir el costo de contexto del propio CLAUDE.md antes y después. Presupuesto: +0 líneas netas o justificación explícita. |
| 3 | Límite de 200 líneas (C-012) es arbitrario. | Se reemplaza por criterio cualitativo ("qué excluir") + número como guía blanda, no como regla dura. |
| 4 | C-011 reduce MCP-vs-CLI a tokens e ignora seguridad. | La regla cruza ahora con Layer 1 (Security) de $qa, no solo con §D. Se agrega cláusula de seguridad. |
| 5 | C-014 transcribe nombres de features inestables → rot garantizado. | C-014 apunta a docs externas vivas; no transcribe nombres/fechas de features sin verificar. |
| 6 | Autocommit de PostToolUse es peligroso y subespecificado. | Se agregan salvaguardas obligatorias (§Track B). Sin ellas, el hook no se activa. |
| 7 | DoD usa marco de QA de código (P0) para cambios de prosa. | DoD reescrito con criterios verificables para una release de documentación/metodología. |
| 8 | Escepticismo desigual: solo C-011/C-012 marcados como "validar fuente única". | Validación de fuente única exigida para **todos** los ítems derivados del video (§2.1). |

**Claims marcados como no-hechos** (no usar como verdad sin verificar):
- ❓ "CLI consume 35x menos tokens / 28% más precisión" — dato de video, sin estudio controlado. **[verificar antes de citar]**
- ❓ Nombres/fechas de features Claude Code en C-014 (`/recap`, `/ultra review`, "dynamic workflows Opus 4.8", "Plan mode = Shift+Tab") **[verificar contra docs oficiales antes de documentar]**

---

## §2 — Requisitos transversales

### §2.0 — Presupuesto de contexto (gate de release)
**DECISIÓN FIJADA (2026-06-05): delta neto ≤ +40 líneas.** Cada ítem que agregue texto a CLAUDE.md debe declarar cuántas líneas agrega. Al cierre de v4.2, el delta neto de CLAUDE.md debe ser ≤ +40 líneas. Regla de asignación: reglas cortas y críticas (MCP vs CLI, `[LOCK]`, paso 5.5, `$verify audit`) pueden vivir en CLAUDE.md; lo voluminoso (Dev Setup C-014, AGENT HANDOFF C-010, retrieval C-006) va a skill on-demand en `.claude/skills/`. Si el delta proyectado supera +40, mover el siguiente ítem más voluminoso a skill antes de cerrar.

### §2.1b — Modelo y esfuerzo por ítem (tabla de ruteo)

**Capacidad verificada en Claude Code (2026-06-05):**
- ✅ `model:` y `effort:` (low/medium/high/xhigh/auto) se pueden fijar por sesión (`/model`, `/effort`) y en frontmatter de subagentes `.claude/agents/*.md`.
- ❌ La sesión principal **no** auto-conmuta modelo por tarea según el spec/CLAUDE.md. Cambia solo con `/model` + `/effort` manual.
- ⚠️ Regla SDAD: `$build` no se delega → corre en sesión principal → cambio manual. Solo trabajo delegable (`$agent`, $doc) corre en subagente con modelo pinneado.

**Ejecución (dos vías):**
- **Vía A (manual, default):** Diego corre `/model` + `/effort` al empezar cada track según la tabla. Funciona hoy, sin infraestructura.
- **Vía B (delegada):** para ítems delegables, pinnear `model:` + `effort:` en el frontmatter del agente en `.claude/agents/`.

| Ítem | Modelo | Esfuerzo | Razón | Vía |
|---|---|---|---|---|
| C-011 MCP vs CLI | opus | high | Juicio de seguridad; no debe contradecir §D ni Layer 1 $qa | A ($build) |
| C-012 protocolo CLAUDE.md | opus | low | Edición de regla ya decidida | A ($build) |
| C-013 $verify audit | opus | low | Extensión especificada | A ($build) |
| C-014 Dev Setup (skill) | opus | low | Texto + links, sin juicio | A ($build) |
| C-007 [LOCK] + $pause compress | opus | low | Convención + filtro, mecánico | A ($build) |
| Hooks (Session/PostTool/PreCompact) | opus | high | Riesgo alto, cross-platform Windows, salvaguardas | A ($build) |
| C-006 lesson retrieval | opus | medium | Diseño de filtrado | A ($build) |
| C-004 caching boundary | opus | medium | Verificación + doc | A ($build) |
| C-010 handoff pattern | opus | high | Diseño; evaluar dynamic workflows | B ($agent delegable) |
| $agent review/test/audit | opus | high | Delegable — pinnear en frontmatter | B |

Regla práctica: **low para ejecutar lo ya especificado; high para riesgo medio/alto o decisión abierta.**

**Aviso de modelo al iniciar tarea (regla para Claude Code):**
Al anunciar cada increment nuevo (bloque de announcement de $build), agregar antes de pedir aprobación una línea de modelo:

```
🧠 MODELO REQUERIDO: opus · effort [low|high] — [razón en 4 palabras]
   Cambiar ahora si no coincide:  /model opus   y   /effort [low|high]
   (modelo/effort actual no se conmuta solo — confirmá antes de aprobar)
```

Regla: si el modelo/effort activo no coincide con la tabla de ruteo del ítem, Claude Code lo señala y espera a que Diego lo cambie antes de escribir código. Si ya coincide, lo confirma en una línea y sigue.

### §2.1 — Validación de fuente única
Los 10 gaps provienen de un solo dev / un solo video. Antes de cerrar cada ítem derivado de esa fuente (C-011, C-012, C-013, C-014, C-006), validar contra al menos un workflow real de G7. Una línea de evidencia por ítem en DECISIONS.md.

---

## §3 — Candidatos v4.2

### Track A — Patches de CLAUDE.md (bajo riesgo, shipear primero)

#### C-011 — Regla MCP vs CLI
**Tipo:** subsección en §7 de $specout + 1 línea en Behavior Rules.
**Problema:** sin guía sobre cuándo usar MCP vs envolver un CLI; muchos MCPs activos degradan contexto y costo.
**Diseño (corregido):** distinguir contexto **productor** (Pyplan §D / @mcp_tool — MCP es la arquitectura correcta, no aplica preferencia CLI) de contexto **consumidor** (MCPs de terceros durante $build).
**Regla propuesta:**
> En contexto consumidor, evaluar CLI wrapper sobre invocación directa de MCP cuando: (a) la tarea usa un único endpoint, (b) el contexto está cerca de umbral, **y (c)** el CLI no introduce riesgo de seguridad mayor que el MCP (inyección de shell, credenciales en argv/env, parsing frágil). Si (c) no se cumple, preferir el MCP vetado. Registrar la decisión y su justificación de seguridad en §7 de SPEC.md.
> No aplica en contexto productor (§D activo).
**Cruce obligatorio:** Layer 1 (Security) de $qa, además de §D.
**Esfuerzo:** bajo. **Riesgo:** medio (no debe contradecir §D ni Layer 1). **Validación:** §2.1.

#### C-012 — Protocolo de actualización del CLAUDE.md de proyecto
**Tipo:** paso 5.5 en $build + línea en $pause + regla en Behavior Rules.
**Problema:** SDAD gestiona SPEC/DECISIONS/LESSON pero no el CLAUDE.md que el dev escribe para su repo; se desactualiza sin protocolo.
**Diseño (corregido):**
1. Qué debe contener (estructura mínima).
2. Cuándo actualizar (al cerrar increment estructural, al cierre de sesión).
3. **Qué excluir** (estado de increment, duplicados de SPEC.md). — criterio cualitativo, es el control principal.
4. Longitud: guía blanda ~150–200 líneas útiles; por encima, revisar qué mover a SPEC/DECISIONS. No es regla dura.
- $build paso 5.5: "¿El CLAUDE.md de proyecto refleja cambios estructurales de este increment? Si sí, proponer update."
- $pause: incluir fecha de última modificación del CLAUDE.md de proyecto.
**Esfuerzo:** bajo. **Riesgo:** bajo. **Validación:** §2.1.

#### C-013 — $verify modo proactivo (`$verify audit`)
**Tipo:** extensión de $verify.
**Problema:** $verify es reactivo; no audita dependencias existentes que se deprecaron entre sesiones.
**Diseño:**
```
$verify         → reactivo (actual)
$verify audit   → lee package.json / requirements.txt / árbol de deps y verifica
                  cada una contra docs actuales (Context 7 MCP o WebSearch)
```
**Trigger:** Phase 0 si el proyecto lleva >30 días sin $build (fuente de fecha: último entry de §13 / git log), o a pedido. No automático cada sesión.
**Esfuerzo:** bajo-medio. **Riesgo:** bajo. **Validación:** §2.1.

#### C-014 — Checklist de onboarding (Dev Setup)
**Tipo:** bloque "Dev Setup" en $sdad.
**Problema:** features nativos que potencian SDAD no son descubribles desde CLAUDE.md.
**DECISIÓN FIJADA (2026-06-05): solo links externos.** El bloque **apunta a docs oficiales vivas**, no transcribe nombres, comandos ni fechas de features (cero rot). Formato: "Para features de Claude Code que complementan SDAD (plan mode, recap, delegación dinámica, Context 7 MCP, cc-status-line), ver: <link a docs.claude.com>. Mapeo a SDAD: [1 línea por concepto estable]." Vive en skill on-demand (§2.0), no en CLAUDE.md.
**Esfuerzo:** bajo. **Riesgo:** bajo (sin rot si no transcribe). **Validación:** §2.1 + verificar links.

---

#### C-015 — Aviso de modelo en el announcement de increment
**Tipo:** línea en el bloque de announcement de $build + regla en Behavior Rules.
**Problema:** la tabla de ruteo §2.1b solo sirve si Diego se acuerda de mirarla. La sesión principal no auto-conmuta modelo, así que el aviso tiene que ser parte del flujo, no de la memoria del dev.
**Diseño:** al anunciar cada increment, antes de pedir aprobación, Claude Code emite:
```
🧠 MODELO REQUERIDO: opus · effort [low|high] — [razón en 4 palabras]
   Cambiar ahora si no coincide:  /model opus   y   /effort [low|high]
```
Si el modelo/effort activo no coincide con la tabla §2.1b → señalar y esperar el cambio antes de escribir código. Si coincide → confirmar en una línea y seguir.
**Dónde en CLAUDE.md:** $build (announcement de increment) + 1 línea en Behavior Rules.
**Dependencias:** ninguna. Idealmente se redacta junto con §2.1b.
**Esfuerzo:** bajo. **Riesgo:** bajo. **Δ líneas:** ~6 (cabe en presupuesto §2.0).

---

### Track B — Activación de infraestructura (núcleo de v4.2)

#### C-007 — Anclaje de sesión (rebajado a extensión, no comando nuevo)
**Corrección clave:** la Opción B original (comando $compact que "inyecta un bloque al siguiente turno") no sobrevive a la compactación automática y solaparía con `$pause compress`. Se descarta como comando independiente.
**Diseño final:**
- Convención `[LOCK]` en DECISIONS.md para decisiones que no deben reabrir.
- `$pause compress` (ya existe) incluye solo las decisiones `[LOCK]` en su anchor — esto es la mejora real, sin comando nuevo.
- El anclaje **automático** real es el hook `PreCompact` (abajo), que inyecta el anchor antes de compactar. Ese es el único mecanismo que sobrevive a la compactación.
**Bloque de anclaje** (lo emite `$pause compress` y `PreCompact`):
```
── COMPACT ANCHOR ─────────────────────────────────────────
Fase activa: [N] | Tier: [N] | Platform: [pyplan/generic]
Spec: [secciones aprobadas] | Increment activo: [N — nombre]
Decisiones [LOCK]: [una línea cada una]
QA abierto: [H-XX con severidad]
Restricciones activas: [las que no pueden perderse]
──────────────────────────────────────────────────────────
```
**Esfuerzo:** bajo. **Riesgo:** bajo.

#### Hooks (Windows primero)
```
SessionStart.sh    → git pull + cargar resumen de DECISIONS.md
PostToolUse.sh     → autocommit de DECISIONS.md / LESSON_LIBRARY.md
PreCompact.sh      → inyectar COMPACT ANCHOR antes de compactar (habilita C-007 real)
```
**Salvaguardas obligatorias (sin estas, no se activa el hook):**
- `SessionStart.sh`: abortar limpio si el working tree está sucio o el `git pull` da conflicto; nunca bloquear el arranque de sesión. Loguear y continuar.
- `PostToolUse.sh`: commitear **solo** DECISIONS.md y LESSON_LIBRARY.md (paths whitelisteados), nunca código; mensaje de commit estandarizado; **no** commitear si el increment está marcado en falla/QA abierto P0; respetar la regla "resolver commits pendientes antes de cerrar sesión" (no debe duplicar commits).
- Testear los tres en Windows antes de declarar Track B completo.
**Esfuerzo:** medio. **Riesgo:** medio-alto (cross-platform + autocommit). Testeo en Windows es gate.

---

### Track C — Arquitectura avanzada (ideal en v4.2, deferible a v4.3)

#### C-006 — Recuperación de Lesson Library (keyword matching)
Phase 0: leer LESSON_LIBRARY.md, filtrar por stack/fase, surfacear 2-3 relevantes. `$lesson search [keyword]`. Agregar tags `#stack` y `#phase`. Migrar a embeddings solo si supera 50 entradas. **Dep:** C-004. **Esfuerzo:** bajo. **Validación:** §2.1.

#### C-004 — Prompt caching (documentar boundary primero)
Pregunta gate: ¿Claude Code expone control de caching o es solo API? Si es solo API y Diego no tiene acceso, el alcance v4.2 es **documentar qué es cacheable** (CLAUDE.md SDAD, SKILL.md always-on, LESSON_LIBRARY.md) y qué no (SPEC, DECISIONS, increment activo). Implementación diferida a quien tenga acceso API. **Dep:** C-006. **Esfuerzo:** bajo (doc) → alto (API).

#### C-010 — Subagents + Handoff pattern
Evaluar primero "dynamic workflows" de Claude Code [verificar disponibilidad] antes de arquitectura custom. El gap real es el **retorno** (handoff), no la delegación.
```
── AGENT HANDOFF ───────────────────────────────────────
Agent: [nombre] | Tarea: [una línea]
Resultado: [máx. 5 líneas] | Archivos modificados: [lista]
Decisiones tomadas: [→ DECISIONS.md] | Hallazgos críticos: [P0/P1]
────────────────────────────────────────────────────────
```
`.claude/agents/HANDOFF_TEMPLATE.md` + sección $agent. **Esfuerzo:** medio.

#### C-009 — Git worktrees
**Deferred fuera de v4.2.** Requiere validación Windows + equipo multi-dev real.

---

## §4 — Secuencia de ejecución

```
TRACK A  (shipear primero — bajo riesgo, son texto/reglas)
├── C-011  MCP vs CLI (+ cláusula seguridad, validar vs §D)
├── C-012  Protocolo CLAUDE.md de proyecto
├── C-013  $verify audit
├── C-014  Dev Setup (links externos, no transcribir features)
└── C-015  Aviso de modelo en announcement (redactar junto con §2.1b)

TRACK B  (núcleo — después de Track A)
├── C-007  [LOCK] + extensión de $pause compress   (bajo)
└── Hooks  SessionStart + PostToolUse (Windows, con salvaguardas)
    └── PreCompact  (habilita el anclaje automático real de C-007)

TRACK C  (ideal v4.2, deferible a v4.3)
├── C-006  Lesson retrieval (keyword)
├── C-004  Caching (boundary doc primero)
├── C-010  Handoff pattern (evaluar dynamic workflows antes)
└── C-009  Git worktrees  → DIFERIDO fuera de v4.2
```

---

## §5 — Mapa de modificaciones en CLAUDE.md

| Sección CLAUDE.md | Cambio | Ítem | Δ líneas (presupuesto §2.0) |
|---|---|---|---|
| $sdad | Bloque "Dev Setup" (links externos) | C-014 | declarar |
| $specout §7 | Subsección MCP vs CLI + cláusula seguridad | C-011 | declarar |
| $build | Paso 5.5 (CLAUDE.md de proyecto) | C-012 | declarar |
| $build (announcement) | Línea 🧠 MODELO REQUERIDO | C-015 | ~6 |
| $verify | Modo `audit` | C-013 | declarar |
| $pause compress | Filtro `[LOCK]` en anchor | C-007 | declarar |
| $pause | Fecha mod. CLAUDE.md de proyecto | C-012 | declarar |
| $agent | AGENT HANDOFF convention | C-010 | declarar |
| $lesson | `$lesson search` + tags | C-006 | declarar |
| Behavior Rules | C-011, C-012, C-013, [LOCK] | varios | declarar |
| Active Skills → hooks | Marcar hooks como activos | Track B | declarar |
| DECISIONS.md (convención) | Prefijo `[LOCK]` | C-007 | declarar |

**Nota §2.0:** sumar la columna Δ al final. Si excede +40 neto, mover ítems a skills on-demand.

---

## §6 — Definition of Done v4.2 (criterios verificables)

- [ ] C-011: regla redactada; cláusula de seguridad presente; revisada contra §D y Layer 1 $qa; sin conflicto con contexto productor; evidencia §2.1 en DECISIONS.md.
- [ ] C-012: paso 5.5 en $build y fecha en $pause; criterio "qué excluir" documentado; longitud como guía blanda (no regla dura).
- [ ] C-013: `$verify audit` implementado; trigger >30 días documentado con fuente de fecha definida.
- [ ] C-014: bloque Dev Setup apunta a docs externas; ningún nombre/fecha de feature transcrito sin verificar; links comprobados.
- [ ] C-007: convención `[LOCK]` en DECISIONS.md; `$pause compress` filtra solo `[LOCK]`; **no** se creó comando $compact redundante.
- [ ] Hooks: SessionStart + PostToolUse activos y **testeados en Windows**; salvaguardas presentes (working tree sucio, whitelist de paths, no commit en QA P0 abierto).
- [ ] PreCompact: inyecta COMPACT ANCHOR; verificado que el anchor persiste post-compactación.
- [ ] C-006: Phase 0 surfacea lecciones; `$lesson search` funcional; tags `#stack`/`#phase`.
- [ ] C-004: boundary de caché documentado en §5; estado de acceso API declarado.
- [ ] C-010: HANDOFF_TEMPLATE.md creado; $agent actualizado; dynamic workflows evaluado/verificado.
- [ ] C-015: announcement de increment emite línea 🧠 MODELO REQUERIDO; bloquea escritura de código si modelo/effort no coincide con §2.1b.
- [ ] §2.1b: cada track ejecutado con el modelo/esfuerzo de la tabla de ruteo (`/model`+`/effort` manual, o frontmatter en agentes delegables).
- [ ] §2.0: delta neto de líneas de CLAUDE.md calculado y dentro de presupuesto (o justificado).
- [ ] §2.1: evidencia de validación de fuente única registrada para cada ítem derivado del video.
- [ ] CLAUDE.md versión → 4.2; §13 AI Authorship Log actualizado.

---

## §7 — Fuera de v4.2

| Item | Razón |
|---|---|
| C-009 Git worktrees | Windows sin validar; sin equipo multi-dev real |
| Domain-specific skills (FP&A, Supply Chain) | Construir desde proyectos reales, no en abstracto |
| GAP 10 tareas recurrentes | Fuera del alcance de la metodología de desarrollo |
| Comando $compact independiente | Redundante con $pause compress; el mecanismo real es PreCompact hook |

---

## §8 — Decisiones abiertas (tu llamada antes de $build)

1. ~~**§2.0 presupuesto de líneas.**~~ ✅ RESUELTO (2026-06-05): delta neto ≤ +40 líneas. Reglas cortas en CLAUDE.md; lo voluminoso (C-014, C-010, C-006) a skills on-demand. Ver §2.0.
2. ~~**C-014 links vs transcribir.**~~ ✅ RESUELTO (2026-06-05): solo links externos a docs.claude.com + mapeo de 1 línea por concepto estable. Cero rot. Ver C-014.
3. **Track C en v4.2 o v4.3:** ¿entra completo en v4.2 o se difiere si Track B se demora?
4. **C-004:** ¿tenés acceso directo a la API para caching, o el alcance se limita a documentar el boundary?

---

*SDAD v4.2 — G7 AI Development Methodology · Spec generado 2026-06-05 · desarrollo en Claude Code*
