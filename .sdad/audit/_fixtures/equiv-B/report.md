# Pyplan Audit Report -- equiv-B

Stamp: SDAD v6 . Model: claude-sonnet-4-6 . Date: 2026-06-26

## Executive Summary

Audit of equiv-B (4 nodes, manual acquisition). The model has a circular dependency
that blocks deterministic evaluation -- this is the top-priority issue. One node
lacks a result= assignment and will be silently skipped at runtime. Interface screens
were not available, so usability is evaluated by convention only. Business alignment
assessment requires an elicitation session with the model owner.

## Evidence Manifest

| Field | Value |
|-------|-------|
| Project | equiv-B |
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
| interfaces | interface screens not available during this audit engagement | not_assessable |

## Dimension 1 -- Development / Architecture

HIGH . [ratchet:circular-deps] . [D1-01] The nodes `revenue_calc` and `margin_calc`
  form a circular dependency -- each references the other as a dependency. This
  prevents the scheduler from resolving a valid evaluation order. The cycle must be
  broken by extracting a shared input or intermediate node.

MEDIUM . [ratchet:missing-result-assign] . [D1-02] The node `tax_rate` does not
  assign its result (no result = _fn line). The Pyplan scheduler will skip this node
  at runtime, silently producing stale or empty output wherever `tax_rate` is consumed.

## Dimension 2 -- Security

No security findings. Node snippets contain no exposed credentials, tokens, or PII.
No MCP-decorated nodes present in this model.

## Dimension 3 -- Usability

Usability: convention-only -- live walkthrough not performed.

Interface screens were not available for this engagement. Usability is assessed by
convention only (node graph inspection); all findings carry confidence: low and are
capped at MEDIUM per BR-03.

MEDIUM . [platform:pyplan] . [D3-01] No interface screens were available for review.
  Usability can only be verified through a live walkthrough. Recommend scheduling a
  session with the owner once interface screens are accessible. (confidence: low)

## Dimension 4 -- Quality / Maintainability

No findings beyond Dimension 1 items. Node identifiers (revenue_calc, margin_calc,
tax_rate, base_price) are readable and follow naming conventions.

## Dimension 5 -- Business

### 5a -- Alignment (domain-agnostic)

Business alignment (5a): not assessable - no elicitation input

An elicitation session with the model owner was not conducted prior to this audit.
Without a declared and confirmed business objective, alignment cannot be evaluated.
The audit cannot confirm that the model's outputs serve the intended business purpose.

### 5b -- Domain Correctness

not assessable - no domain profile

The project domain was not declared or reliably inferred from the supplied evidence.
Without a domain profile, formula logic, KPI definitions, and domain-specific
assumptions cannot be verified for correctness.

## Improvement Backlog

HIGH . [D1-01] . Circular dependency revenue_calc / margin_calc -- Dimension 1 --
  Extract shared logic into an independent input node to break the evaluation cycle.

MEDIUM . [D1-02] . result= missing on tax_rate -- Dimension 1 --
  Add result = _fn so the scheduler evaluates this node.

MEDIUM . [D3-01] . Usability unverifiable without live access -- Dimension 3 --
  Provide interface screens and arrange a live-walkthrough session.

LOW . [gap:interfaces] . Supply interface export to enable full usability assessment --
  interfaces not_assessable currently.

LOW . [gap:5a] . Conduct owner elicitation to enable business alignment (5a) assessment --
  5a not assessable currently.

LOW . [gap:5b] . Declare PROJECT_DOMAIN and create a matching domain profile --
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
