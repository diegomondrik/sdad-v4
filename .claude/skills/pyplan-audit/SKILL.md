---
name: pyplan-audit
description: >
  Activate this skill to audit an existing Pyplan application and produce a
  client-facing audit report. Auto-activates on the $audit command. Use when the
  user says "audit this Pyplan model", "review this client app", "what is wrong
  with this model", "is this model production-ready", or asks for a structured,
  multi-dimension assessment of a model SDAD did not build. It orchestrates the
  five-dimension audit (development, security, usability, quality, business),
  composing existing SDAD skills and agents — it does not rewrite them. Consumes
  the I1 evidence layer and the deterministic ratchet checks as pre-computed
  evidence; reconciles severities into one 4-band scheme; declares not-assessable
  wherever evidence or elicitation is missing rather than fabricating findings.
---

# SKILL: pyplan-audit
# Version: 1.0 | SDAD v6
# Layer: Audit orchestrator -- the engine behind the $audit command
# Activation: auto on $audit; on-demand when an audit of an existing Pyplan model is requested

---

## Purpose

The technical engine for assessing a Pyplan model already exists across SDAD's
skills and agents. What was missing is the **orchestration**, the **five-dimension
model**, and the **client-facing report deliverable**. This skill is that
orchestrator. It composes existing capabilities; when a composed skill improves,
the audit improves for free (no rewrite, no duplication).

The audit is a point-in-time, evidence-based judgment of a model SDAD did not
necessarily build. It is liability- and relationship-aware: it reports intent
versus delivered **neutrally**, never accusatorially, and never fabricates.

This skill orchestrates; it owns no detection logic of its own. Detection lives in
the composed skills, agents, and ratchet checks listed below.

---

## The five-dimension model

| # | Dimension | What it judges | Composed from |
|---|-----------|----------------|---------------|
| 1 | Development / architecture | Node design, data flow, architecture consistency | `pyplan-qa-platform` (Layer 7) + `code-reviewer` agent (structure) |
| 2 | Security | Secrets, token/PII exposure, MCP tool surface | `security-auditor` agent + `mcp-tool-audit` ratchet |
| 3 | Usability | Navigation clarity, cognitive load, task success | `pyplan-qa-platform` 7.3 (convention-compliance) + I6 live-walkthrough sub-protocol |
| 4 | Quality / maintainability | Readability, duplication, naming, docs gaps | `pyplan-qa-platform` (Layers) + `code-reviewer` agent |
| 5 | Business | Does the model serve its declared objective, correctly for its domain? | 5a + 5b below |
| 5a | -- Alignment (domain-agnostic) | Measurable objective, traceable rules, value vs cost | `business-alignment` skill via the `business-analyst` agent |
| 5b | -- Domain correctness (domain-specific) | KPIs, formulas, trap assumptions, red flags | the `domain-*` profile(s) loaded for `PROJECT_DOMAIN` |

Dimension 5b runs only where a domain profile exists. No profile -> the dimension
is **"not assessable - no domain profile"** (a finding recommending profile
creation, never a silent skip). See `business-alignment` and the `domain-*` skills.

---

## Evidence inputs (consume, do not re-detect -- BR-04)

Before reasoning, the orchestrator gathers pre-computed evidence:

1. **Model representation** -- `.sdad/audit/<project>/evidence/node-graph.json`,
   acquired per `.sdad/audit/SCHEMA.md` (I1). Acquisition path: `.ppl` export
   (primary, stub in v6) / MCP read (enhancement) / manual (always available).
   Un-acquired areas are declared gaps with `status: not_assessable`.
2. **Deterministic ratchet output** -- run and read, do NOT re-detect by LLM:
   - `checks/audit-evidence` -- evidence is structurally valid before use
   - `checks/missing-result-assign` -- calculation nodes without `result=`
   - `checks/circular-deps` -- dependency cycles in the node graph
   - `checks/mcp-tool-audit` -- `@mcp_tool` defects (untyped params, called `result`, non-serializable return)

The LLM auditor reasons over what the ratchets could not mechanize (intent,
alignment, usability, domain judgment); it never re-checks what a ratchet already
covers deterministically.

---

## Orchestration (via the agent-run wrapper)

Specialist roles run in isolated context through `.sdad/lib/agent-run`
(`.ps1` / `.sh`, 600s timeout, fails loud on empty/timeout -- never proceeds
silently). Each role returns an AGENT HANDOFF block (see
`.claude/agents/HANDOFF_TEMPLATE.md`):

| Role | Agent file | Feeds dimension |
|------|-----------|-----------------|
| Security audit | `.claude/agents/security-auditor.md` | 2 |
| Structure / quality review | `.claude/agents/code-reviewer.md` | 1, 4 |
| Business alignment | `.claude/agents/business-analyst.md` (elicitation-fed) | 5a |

Domain correctness (5b) and the Pyplan platform checks (1, 3, 4) are applied by the
main auditor with the relevant skills loaded (`domain-*`, `pyplan-qa-platform`) --
they are knowledge, not isolated-context delegations.

Sub-agents run in isolated context and do not consume the main session budget.
Surface any `agent-run` non-zero exit to the developer; do not proceed silently.

---

## Domain detection and loading

`PROJECT_DOMAIN` is declared in `$spec` (developer) or inferred in `$audit` from
data sources, node/KPI naming, interfaces, and ingested discovery docs, then
**confirmed with the owner**. Load every matching `domain-*` profile.
- Multi-domain model -> load multiple profiles and flag cross-domain seams as
  high-risk (e.g. the finance <-> supply-chain COGS/inventory seam).
- No profile for a detected domain -> not-assessable finding + creation-path
  backlog entry (BR-07/08). Never improvise a profile mid-audit.

Ingested sales/discovery docs, blueprints, and POCs are **declared-intent /
claims-to-verify, timestamped -- not ground truth** (markitdown ingestion, local
trusted files only). The audit verifies claims against acquired evidence.

---

## Severity reconciliation (BR-03 -- detailed template in I8)

Findings arrive from heterogeneous sources (H-XX technical, PP-XX platform, domain,
alignment, ratchet exits). Reconcile them into ONE 4-band scheme. Each finding
shows `band + source label`:

| Band | Source mapping |
|------|----------------|
| CRITICAL | P0 security; wrong-objective/misleading-output alignment |
| HIGH | P1; non-measurable objective; circular dependency; domain red flag (CRITICAL/HIGH) |
| MEDIUM | P2; untraceable rule; missing `result=`; value-cost inversion |
| LOW | style; cosmetic objective wording; minor traceability gap |

The full reconciliation + report template lands in I8; this skill defines the
contract the report consumes.

---

## The not-assessable rule (epistemic honesty)

Every dimension that cannot be assessed is reported as such, with the reason:
- No evidence acquired -> "not assessable - evidence not acquired" (I1 gap).
- No elicitation input -> "not assessable - no elicitation input" (BR-09).
- No domain profile -> "not assessable - no domain profile" (BR-07).
- Live app unavailable -> usability "convention-only, live walkthrough not performed" (I6).

The audit never guesses, never fabricates, and never silently omits an un-assessed
area. A not-assessable verdict is itself a finding that tells the owner what to
supply to close the gap.

---

## External dependency

The Pyplan MCP server (used for the MCP read acquisition path) is a **v1 external
dependency -- API may change across Pyplan updates**. Flag its maturity in the
report when the MCP read path was used. See the `pyplan-mcp` skill.

---

## Report shape (full template -> I8)

Executive summary -> evidence manifest (acquisition path, gaps, SDAD version +
exact model string for reproducibility) -> one section per dimension (1, 2, 3, 4,
5a, 5b) -> prioritized improvement backlog (by band). Modes: `$audit` (full) /
`$audit [dimension]` / `$audit report`.

---

G7 AI Development Methodology | SDAD v6 | pyplan-audit (I4)
