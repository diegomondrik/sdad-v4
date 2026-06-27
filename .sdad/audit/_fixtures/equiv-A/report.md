# Pyplan Audit Report -- equiv-A

Stamp: SDAD v6 . Model: claude-sonnet-4-6 . Date: 2026-06-26

## Executive Summary

Point-in-time audit of the equiv-A model using a manually supplied node graph
(4 nodes). A circular dependency between two calculation nodes is the highest-risk
finding. One calculation node is missing its result= assignment. Interface screens
were not supplied; usability assessment is convention-only. Business alignment
cannot be assessed without an owner elicitation session.

## Evidence Manifest

| Field | Value |
|-------|-------|
| Project | equiv-A |
| Acquired At | 2026-06-26 |
| Acquisition Path | manual |
| Pyplan Version | unknown |
| Node Count | 4 |
| App Access | false |
| Usability | convention-only (no live walkthrough performed) |
| Elicitation | none |

### Declared Gaps (not_assessable)

| Area | Reason | Status |
|------|--------|--------|
| interfaces | no interface export was supplied by the owner | not_assessable |

## Dimension 1 -- Development / Architecture

HIGH . [ratchet:circular-deps] . [D1-01] Circular dependency detected between nodes
  `revenue_calc` and `margin_calc`. Each node depends on the other, preventing
  deterministic evaluation. Recommended action: break the cycle by introducing an
  intermediate input node.

MEDIUM . [ratchet:missing-result-assign] . [D1-02] Node `tax_rate` has no result=
  assignment. Without a result= the node will not be evaluated by the scheduler.
  Recommended action: assign result = _fn to the node.

## Dimension 2 -- Security

No findings. No credentials or PII exposure detected in the supplied node snippets.
No @mcp_tool decorators present; mcp-tool-audit ratchet not applicable.

## Dimension 3 -- Usability

Usability: convention-only -- live walkthrough not performed.

Convention checks (node graph only; confidence: low; capped at MEDIUM per BR-03):
- Interface nodes: not assessable -- interfaces gap declared (see manifest).
- Input validation metadata: not assessable -- interfaces gap declared.
- Node identifier quality: readable (revenue_calc, margin_calc, tax_rate, base_price).
- Dead interface nodes: not assessable -- interfaces gap declared.

MEDIUM . [platform:pyplan] . [D3-01] Interface node export not supplied. Usability
  assessment is convention-only. Recommend a live-walkthrough session to close the
  usability gap. (confidence: low)

## Dimension 4 -- Quality / Maintainability

No additional findings beyond those captured in Dimension 1.

## Dimension 5 -- Business

### 5a -- Alignment (domain-agnostic)

Business alignment (5a): not assessable - no elicitation input

No owner elicitation was performed. The alignment dimension cannot be assessed
without a declared business objective to evaluate against. This is itself a finding:
the audit cannot confirm the model serves its intended purpose.

### 5b -- Domain Correctness

not assessable - no domain profile

No PROJECT_DOMAIN was detected or confirmed. A domain profile is required to assess
formula correctness, KPI definitions, and domain-specific trap assumptions.

## Improvement Backlog

HIGH . [D1-01] . Circular dependency in revenue_calc / margin_calc -- Dimension 1 --
  Break the dependency cycle by introducing an intermediate input node.

MEDIUM . [D1-02] . Missing result= on tax_rate -- Dimension 1 --
  Add result = _fn to ensure the node is evaluated.

MEDIUM . [D3-01] . Convention-only usability (interfaces not supplied) -- Dimension 3 --
  Supply interface export and schedule a live-walkthrough session.

LOW . [gap:interfaces] . Supply interface export to enable usability assessment --
  interfaces not_assessable currently.

LOW . [gap:5a] . Run owner elicitation session to enable business alignment assessment --
  5a not assessable currently.

LOW . [gap:5b] . Declare PROJECT_DOMAIN and load a domain profile to enable 5b assessment --
  5b not assessable currently.

## Severity Reconciliation Reference (BR-03)

| Band | Maps from |
|------|-----------|
| CRITICAL | P0 security; wrong-objective or misleading-output alignment finding |
| HIGH | P1 security; non-measurable objective; circular dependency; domain red flag |
| MEDIUM | P2 security; untraceable business rule; missing result=; value-cost inversion |
| LOW | Style; cosmetic objective wording; minor traceability gap |
| not assessable | Evidence/elicitation/profile not supplied -- surfaced as gap, never silent |

---

G7 AI Development Methodology | SDAD v6 | Pyplan Audit Report (I8)
