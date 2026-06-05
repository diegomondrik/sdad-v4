# SPEC.md — [Project Name]
**Version:** 1.0
**Date:** [YYYY-MM-DD]
**Compliance Tier:** Tier [1/2/3] — [Standard / Business / Enterprise]
**Status:** Draft / Approved for $build

---

## §0 — Platform & Context

**PROJECT_PLATFORM:** [general | pyplan | other]

> Declare the deployment platform here. This activates the correct skill set.
> `pyplan` → activates Pyplan skills (diagram, interfaces, qa-platform, spec-context)
> `general` → activates standard AI Architect + AI Engineer only

**Runtime environment:**
[Description of where this project runs — cloud, local, embedded in platform, etc.]

---

## §A — Delta Log

> This section tracks meaningful changes to the Spec after initial approval.
> Small clarifications do not need an entry. Use for scope changes, architecture shifts,
> decisions that reverse an earlier choice, or additions that affect the build plan.

| # | Date | Section | Change | Reason |
|---|------|---------|--------|--------|
| — | — | — | Initial version | — |

---

## §B — Open Questions

> Questions that arose during requirements or build that are not yet resolved.
> Small deltas: resolve inline and log in §A. Structural deltas: pause and create a gap report.
> Close all entries before marking the Spec as "Approved for $build".

| # | Question | Owner | Status |
|---|----------|-------|--------|
| Q-01 | [description] | [developer / client] | Open |

---

## §C — Brand & Visual Identity
**Applies to:** projects with a client-facing UI. Omit this section for backend-only projects or internal tools with no brand requirements.

**Material available:** [Full brandbook (PDF/Figma) / Partial (colors + fonts) / Logo + basic colors / Website only / None]
**Source:** [filename / URL / "none"]
**Primary color:** [HEX or "TBD"]
**Primary font:** [name or "TBD"]
**Brand Token Sheet status:** [Not started / Draft / Approved]
**Client approval date:** [date or "pending"]
**Notes:** [any brand constraints or client preferences]

---

## §D — MCP Tools Catalog
**Applies to:** Pyplan projects that expose at least one node as an MCP tool (`@mcp_tool`).
Omit this section if no `@mcp_tool` nodes are declared.
**Gate:** §D must be approved before `$build` is allowed (same gate as §A).

| Node identifier | Tool name | Description | Parameters | Return type | Status |
|-----------------|-----------|-------------|------------|-------------|--------|
| [node_name] | [tool_name] | [What this tool does — written for an external LLM] | `param: Annotated[type, 'description']` per parameter | dict / list / scalar — JSON-serializable | Draft |

**MCP server:** Pyplan MCP v1 — document in §7 as external dependency (API may change across Pyplan updates).

**§D Status:** Draft / Approved

---

## §1 — Vision & Objective

**Problem:**
[Description of the problem this project solves]

**Solution:**
[Description of the proposed solution]

**Success criteria:**
- [Criterion 1 — measurable or verifiable]
- [Criterion 2 — measurable or verifiable]

---

## §2 — Users & Roles

| Role | Description | Access |
|------|-------------|--------|
| [Role 1] | [Description] | [Permissions] |

---

## §3 — Functional Flows

### Flow 1 — [Name]
```
[Step-by-step flow description]
```

---

## §4 — Data Model

[Description of entities, data structures, key files or tables]

---

## §5 — Technical Architecture

**Stack:**
- [Language / Framework]
- [Key dependencies]

**Components:**
| Component | Role |
|-----------|------|
| [name] | [description] |

---

## §6 — Business Rules

1. [Business rule 1]
2. [Business rule 2]

---

## §7 — Integrations & APIs

| Integration | Endpoint | Usage |
|-------------|----------|-------|
| [name] | [endpoint] | [usage] |

---

## §8 — Testing Strategy

| Test | Type | When |
|------|------|------|
| [description] | [unit / integration / E2E / manual] | [trigger] |

---

## §9 — Security & Compliance (Tier [N])

**Assets to protect:**
- [asset 1]

**Controls:**
- [control 1]

> Tier 1: fill in minimums (credentials handling, no exposed keys).
> Tier 2: add PII handling, auth review, audit logging, sanitized errors.
> Tier 3: add threat model, data flow diagram, control matrix. $build blocked until §9 approved.

---

## §10 — Definition of Done

An increment is complete when:
- [ ] [criterion 1]
- [ ] [criterion 2]
- [ ] Tests pass without errors
- [ ] README or RUNBOOK updated in this increment
- [ ] SPEC.md §13 updated
- [ ] §A updated if this increment changed scope or architecture

---

## §11 — Out of Scope

- [Out of scope item 1]
- [Out of scope item 2]

---

## §12 — Open Decisions

> Unresolved choices that must be closed before $build is allowed.
> Move resolved decisions to §A (Delta Log) once closed.

| # | Decision | Status |
|---|----------|--------|
| OD-01 | [description] | Open |

---

## §13 — AI Authorship Log

| Increment | Feature | Model | Date | Notes |
|-----------|---------|-------|------|-------|
| SPEC v1.0 | Initial spec | [model] | [date] | [$spec guided / $docfinal / manual] |
