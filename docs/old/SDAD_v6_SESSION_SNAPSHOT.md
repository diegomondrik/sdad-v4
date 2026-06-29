# SDAD v6 -- SESSION SNAPSHOT ($pause compress)

> Working handoff artifact (NOT a v6 deliverable, NOT committed). Paste the
> COMPACT ANCHOR block into the next session to restore state without re-explaining.
> Generated 2026-06-26 after I1 + I2 closed on branch v6-audit.

```
===============================================================
COMPACT ANCHOR
===============================================================
Phase: $build (v6.0 "Pyplan Audit Edition")
Tier: 2 Business . Platform: generic . PROJECT_LANGUAGE: es (interaction) / en (docs)
Branch: v6-audit (off main; NOT merged yet)
Spec: SPEC.md APPROVED (2026-06-26) -- 10 increments I1-I10, all section-5 decisions
      resolved (SPEC section 12). No open decisions.
Active increment: NONE in progress. Next = I3.

[LOCK] decisions (inherited + v6):
- [LOCK] CLAUDE.md net <= +60 lines per release; voluminous content -> on-demand skills
- [LOCK] MCP-vs-CLI: security is a hard gate (not a token/cost choice)
- [LOCK] No API dependency in the methodology
- BR-01: .ppl export = I1 primary path; MCP read = enhancement; I2 parallel to I1
- BR-03: unified severities, 4 bands (CRITICAL/HIGH/MEDIUM/LOW) + source label
- BR-04: mechanical findings -> checks/ ratchet; LLM auditor consumes output
- BR-16: pyplan-mcp ALREADY EXISTED on main (brief was wrong) -> I2 was extend, not build
- BR-17: I1 hybrid -- .ppl parser is a documented STUB (format unverified, no sample)
- Skills under .claude/: edited DIRECTLY in this source repo; apply-v6 (I10) packages downstream

Constraints that must not be lost:
- All .ps1/.sh pure ASCII (L-01, ratchet checks/ascii-ps1)
- Reference CLAUDE.md by exact case (L-04)
- v5 $eval golden dataset must pass after each increment (ADD scenarios, do not alter 01-14)
- CLAUDE.md v6 wiring is DEFERRED to I9 (do not touch CLAUDE.md until then)
- DO NOT commit the pre-existing modified files (.claude/skills/*, hooks, agents,
  eval scenarios 01-14, .sdad/lib/agent-run.ps1, SDAD_v6_BUILD_BRIEF.md). They were
  already modified at session start and are NOT part of v6 work. Stage ONLY the
  current increment's files, by explicit path.

Open QA findings: none (H-XX empty)
===============================================================

COMPLETED INCREMENTS:
[done] I1 (commit 0b13ec3) -- Evidence acquisition layer (hybrid):
   .sdad/audit/SCHEMA.md . checks/audit-evidence.ps1+.sh (node-graph.json validator)
   .sdad/audit/lib/acquire-evidence.ps1+.sh (stub: declares not_assessable gap, no crash)
   .sdad/audit/_fixtures/{valid,invalid}-node-graph.json . eval scenario 15
   .gitignore: versions the methodology parts of .sdad/audit/, ignores .sdad/audit/<project>/
[done] I2 (commit 2198efd) -- Extend pyplan-mcp (MEDIUM, rescoped per BR-16):
   pyplan/mcp/SKILL.md +2 sections (read-access I1, auditing exposed tools + BR-03 map), -> v6
   .sdad/audit/lib/mcp_lint.py (AST: untyped/non-Annotated param, result=fn(),
     non-serializable return, weak docstring) . checks/mcp-tool-audit.ps1+.sh (python-or-skip)
   .sdad/audit/_fixtures/mcp_clean.py + mcp_defects.py . eval scenario 16

TEST STATE: $eval core 16/16 PASS (scenarios 01-16). python 3.13 available on the machine.

NEXT STEP -- I3 (HIGH): business dimension, two coupled pieces.
  I3a -- .claude/skills/business-alignment/SKILL.md (on-demand, BR-02): domain-agnostic core.
        $spec/$build: section-1 objective measurable, section-6 rules traceable, section-12
        value-vs-cost. $audit: elicit the declared objective, audit alignment; no elicitation
        -> "not assessable - no elicitation input" (BR-09).
  I3b -- on-demand domain-profile library: .claude/skills/domain-finance/SKILL.md +
        domain-supply-chain/SKILL.md (checklist level: KPIs, formulas to validate,
        trap assumptions, red flags -- BR-05). Deferred: retail/manufacturing/HR/sales ->
        "not assessable - no domain profile" (BR-06/07). PROJECT_DOMAIN: declared in $spec,
        inferred in $audit. Multi-domain: load several + flag cross-domain seams high-risk.
        Creation path (BR-08): domain with no profile -> pause ONLY the dependent increment
        (data-delta pattern) -> skill-creator + SME -> provisional/LLM-seeded/low-confidence
        until review -> commit via apply pattern. NEVER fabricate a profile mid-audit.
  Tests I3 (DoD): vague objective -> flagged non-measurable; no elicitation -> not-assessable;
        finance model -> domain-finance loads + catches a consolidation double-count; no profile
        -> not-assessable; finance+SC -> both profiles load + COGS seam flagged.
  Finance fixture: BUILD SYNTHETIC (developer confirmed "construilo vos" 2026-06-26) -- a small
        finance model fixture with a planted consolidation double-count; no real .ppl needed.
  Model: FRONTIER (Opus 4.8) . high.

AFTER I3: I4 (pyplan-audit orchestrator, 5 dimensions) . I5 ($audit command + AUDIT_ACTIVE
  sentinel + spec-gate allowlist) . I6 (usability sub-protocol) . I7 (eval audit scenarios) .
  I8 (report template + severity reconciliation) . I9 (CLAUDE.md v6 wiring, +60 budget) .
  I10 (docs regen to v6 + apply-v6.ps1/.sh installer). See SDAD_v6_PYPLAN_AUDIT_BRIEF.md sec 3.

LESSONS: L-08 "Verify a brief's claims against the real repo" WRITTEN to LESSON_LIBRARY.md
  (developer approved 2026-06-26). Origin BR-16.

ACTIVE SKILLS: AI Architect, AI Engineer (always-on). On-demand relevant to v6:
  pyplan-mcp (extended in I2), security-reviewer, qa-engineer, decision-architecture.
  business-alignment + domain-* are created in I3.

CONTEXT BUDGET: ~50-55% at compress time. Flows defined: 0.
===============================================================
```
