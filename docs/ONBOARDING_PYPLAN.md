# SDAD v6.0 — Pyplan Project Onboarding

**G7 AI Development Methodology · SDAD v6.0 "Pyplan Audit Edition"**
*For developers starting a new Pyplan project or auditing an existing one with SDAD.*

---

## 1. Activate Pyplan mode

In the project's CLAUDE.md, uncomment (or set) the platform line:

```
PROJECT_PLATFORM: pyplan
```

This single line activates the full Pyplan surface: Pyplan-specific `$spec` sections
(§0 platform context, §A data architecture, §B discovery log, §D MCP tools catalog),
the increment checklist, QA Layer 5, and all five Pyplan on-demand skills.

---

## 2. Set the project domain

During `$spec`, SDAD asks for `PROJECT_DOMAIN`. Set it to the model's primary business area:

- `finance` — loads `domain-finance` (FP&A: consolidation, FX, NPV/IRR, working capital,
  driver-based planning)
- `supply-chain` — loads `domain-supply-chain` (safety stock, MEIO, service level, S&OP,
  bullwhip effect)
- Other domain names — declared "not assessable — no domain profile" (a finding; a domain
  profile can be built via the `skill-creator` skill fed by SME elicitation)
- `none` — business domain-correctness dimension skipped with explanation

Domain profiles load on-demand only for the declared domain. Every domain finding states a
confidence level — an LLM profile raises the floor, it does not replace your client's SME.

---

## 3. New project: the spec-first path

```
$spec           → answers §0, §A, §D (if MCP), then standard sections
$specout        → writes SPEC.md (§A and §D are build gates)
$build [inc]    → builds one increment; closes with increment checklist
$qa             → reviews the increment; Layer 5 covers Pyplan platform checks
```

**§A gate (Data Architecture):** must be marked Approved in SPEC.md before `$build` allows
any code. This is intentional — Pyplan models are data-driven; the data contract must be
established before nodes are written.

**§D gate (MCP Tools Catalog):** applies only when the project exposes nodes as MCP tools
(`@mcp_tool` decorator). When present, §D must be Approved before `$build` proceeds.

**§B Discovery Log:** initialized empty and filled as `$build` progresses. Any data delta
(field mismatch, wrong granularity, missing source) is recorded here. Structural deltas
pause `$build` until the developer resolves them with the client.

---

## 4. Existing model: the audit path

When you need to assess a Pyplan model that was not built with SDAD, use `$audit`.

```
$audit          → opens evidence acquisition, then five-dimension assessment
$audit security → security dimension only
$audit report   → generate/regenerate the client-facing report
```

**Evidence acquisition:** `$audit` requests:
- The `.ppl` model export (preferred; parsed into a node-graph representation)
- Pyplan MCP read access (if the instance has it enabled)
- Prior discovery documents, sales materials, or POC descriptions

Evidence lands under `.sdad/audit/<project>/`. An evidence manifest is produced: what was
acquired, how, and what gaps exist. Un-acquirable areas are declared "not assessable" with a
clear explanation — the report never invents findings for areas it cannot inspect.

**Five dimensions of the audit:**

| # | Dimension | Primary evidence |
|---|-----------|-----------------|
| 1 | Development / Architecture | Node graph: result=, circular deps, data contract compliance |
| 2 | Security | @mcp_tool parameters, token handling, minimum scope |
| 3 | Usability | Live-app walkthrough (or convention-only if app unavailable) |
| 4 | Quality | Code clarity, duplication, naming, docs |
| 5a | Business alignment | Elicitation with model owner (not assessable without it) |
| 5b | Domain correctness | Matching `domain-*` profile (not assessable without a profile) |

**Neutral framing:** the report presents what the model *intends* vs. what it *delivers*.
It is evidence-based, liability-aware, and never accusatory. The audience is often the client
who commissioned the model.

---

## 5. MCP tools on Pyplan models

When a Pyplan model exposes nodes as MCP tools, two surfaces are in play:

**Producer context (building the tools — §D):**
- Each `@mcp_tool` node must have `result = _fn` (function assigned, not called).
- All parameters must use `Annotated[type, 'description']` — no untyped parameters.
- Return values must be serializable (no raw xarray, no bare DataFrames).
- OAuth tokens are never logged or exposed in node results.
- `$qa` Layer 5 checks all of the above automatically.

**Consumer context (`$audit` assessing exposed tools):**
- `$audit` Dimension 2 (Security) includes MCP tool checks at the same severity as the
  producer rules.
- §D of the spec-gate allowlist is verified by the `audit-evidence` ratchet check.

**Pyplan MCP server:** registered as a v1 external dependency in §7. API may change across
Pyplan updates. Recommend locking to a specific Pyplan version in §5 if MCP stability is
critical for the project.

---

## 6. Model snapshots

After each completed increment on a Pyplan project, export the model to:

```
.sdad/pyplan-snapshots/YYYYMMDD-incN-slug.ppl
```

Include the snapshot in the increment's atomic commit. This is a mandatory checklist item —
an increment is not complete without its snapshot. The auditor in `$audit` can consume these
snapshots as primary evidence.

---

## 7. Increment checklist (quick reference)

After writing code for a Pyplan increment, the following are checked before closing:

**Diagram surface:**
- All new nodes have `result=` assigned and calculate without error
- No circular dependencies introduced
- Data source of read nodes matches §A data contract

**Interface surface:**
- All new indexes are synchronized
- Inputs have type and range validations configured
- Visualization components display calculated data (not empty)

**HTML interface surface (when applicable):**
- All page-to-model traffic goes through `window.pyplan.callback` — no direct fetch/XHR
- Getters return JSON-friendly data; mutators return `get_nodes_to_refresh()` lists
- State persists via callbacks, not cookies/localStorage

**MCP surface (when project has §D):**
- Each new `@mcp_tool` node: docstring explains the business action precisely
- All parameters use `Annotated[type, 'description']` — no untyped parameters
- Return value is serializable
- `result = _fn` assigned (not called)
- §D entry created or updated

**Discovery:**
- Any data deltas found during this increment recorded in §B and DECISIONS.md

**Versioning:**
- Model exported to `.sdad/pyplan-snapshots/YYYYMMDD-incN-slug.ppl`
- Snapshot included in this increment's atomic commit

---

## 8. QA Layer 5 — Pyplan platform checks

`$qa` runs Layer 5 automatically on Pyplan projects:

- Nodes missing `result=`
- Unsynchronized indexes
- Inputs without validations
- Circular dependencies
- HTML interface traffic bypassing `window.pyplan.callback`
- MCP tools (when §D present): serialization, Annotated parameters, docstrings,
  model-snapshot presence, build-via-AI snapshot check

---

G7 AI Development Methodology | SDAD v6.0 Pyplan Onboarding | 2026
