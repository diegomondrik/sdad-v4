# SPEC — SDAD v6.0 Pyplan Audit Edition

> SPEC STATUS: APPROVED (2026-06-26, developer: Diego Mondrik)
> Project: SDAD methodology repo (self-referential — SDAD builds SDAD)
> Tier: 2 Business · Platform: generic · PROJECT_LANGUAGE: es (interaction) / en (documents)
> Date: 2026-06-26 · Developer: Diego Mondrik
> Input: SDAD_v6_PYPLAN_AUDIT_BRIEF.md (2026-06-26) + $spec Q&A session 2026-06-26
> Predecessor: v5.2 "Pyplan Model Versioning Patch" (preserved in git history)
> Version: 6.0 — "Pyplan Audit Edition"

---

## §1 Vision & Objective

SDAD v5 can build a Pyplan model correctly but has no first-class way to judge one it did
not build, and no specialist for business value and alignment — only technical and delivery
roles. As a result, audits of existing client Pyplan implementations require manual judgment
outside the methodology, with no repeatable structure, no evidence trail, and no client-ready
deliverable.

v6 adds three capabilities to the v5 harness — additive, backward-compatible, ships before v7:

1. **`$audit` lifecycle** — a standalone command for auditing existing Pyplan models. Sibling
   of `$docfinal` (which documents retroactively; `$audit` judges and recommends). Delivers a
   five-dimension, client-facing audit report with a declared evidence manifest.

2. **Business dimension** — a `business-alignment` skill (I3a) shared by `$build` and `$audit`
   that enforces measurable objectives and traceable business rules, plus a domain-profile
   library (I3b) that makes domain correctness assessable where a profile exists and explicitly
   not-assessable where it does not. Starter profiles: `domain-finance` (FP&A) and
   `domain-supply-chain`.

3. **`pyplan-mcp` skill** — closes a documented gap: CLAUDE.md references the skill in
   multiple sections but it does not exist. Covers `@mcp_tool` producer rules and MCP read-access
   for the evidence acquisition layer.

**Measurable success criteria (DoD-linked):**
- `$audit` on a fixture → five-dimension report + evidence manifest, no Spec required.
- `$eval` v5 core + new audit scenarios → clean pass on final v6 state.
- No documentation file left at v4/v4.3/v5.
- CLAUDE.md within +60-line net budget; version and footer = 6.0.

---

## §2 Users & Roles

| Role | Description | Interaction with v6 |
|------|-------------|---------------------|
| SDAD developer (Pyplan project) | Runs `$build` increments on Pyplan models | Sees `business-alignment` on-demand; `domain-*` profile loads if `PROJECT_DOMAIN` is set |
| SDAD auditor | Runs `$audit` on an existing Pyplan client model | Primary user of the new lifecycle; drives evidence acquisition, domain detection, report generation |
| SDAD maintainer | Applies v6 to the methodology repo | Runs `apply-v6.ps1` / `.sh`; controls which domain profiles exist |
| End client (Pyplan owner) | Provides elicitation input for business-alignment and domain confirmation | Passive — receives the audit report; queried by the auditor for elicitation |

---

## §3 Functional Flows

### Flow 1 — `$audit` full lifecycle

```
1. Pre-audit ingestion
   a. Acquire model evidence via I1 (primary: .ppl export; enhancement: MCP read endpoints;
      fallback: manual export/screenshots)
   b. Ingest prior sales/discovery docs, blueprints, POCs via markitdown
      → declared-intent / claims-to-verify, timestamped, NOT ground truth
   c. Emit evidence manifest: acquisition path, timestamp, Pyplan version if available,
      declared gaps ("not assessable")

2. Domain detection + confirmation
   a. Infer PROJECT_DOMAIN from data sources, node/KPI naming, interfaces, ingested docs
   b. Confirm with owner
   c. Load matching domain-* profile(s); multi-domain = multiple profiles
   d. If no profile exists: mark dimension "not assessable - no domain profile" → backlog entry

3. Business elicitation (business-alignment skill, on-demand)
   a. Structured elicitation of declared business objective from the owner
   b. If owner unavailable: mark "not assessable - no elicitation input"; no fabrication

4. Five-dimension audit run
   (1) Development/architecture  → code-reviewer agent + ratchet output
   (2) Security                  → security-auditor agent (QA Layer 1)
   (3) Usability                 → live walkthrough + screenshots if app available;
                                   convention-compliance only if not (declared in report)
   (4) Quality/maintainability   → pyplan-qa-platform layer + ratchet output
   (5) Business                  → (5a) alignment (business-alignment skill)
                                   (5b) domain correctness (domain-* profile, if loaded)

5. Severity reconciliation → unified 4-band scheme (see BR-03)

6. Report generation ($audit report)
   → executive summary, evidence manifest, one section per dimension,
     prioritized improvement backlog
   → English output, evidence-based, intent vs delivered, never accusatory
   → Stamped with SDAD version + exact model string
```

### Flow 2 — `$build` with business-alignment (on-demand activation)

```
Trigger: $spec detects vague §1 objective OR §6 rule without traceable business reason
→ business-alignment skill activates automatically
→ enforces measurable §1, traceable §6, value-vs-cost surfacing in §12
→ domain-* profile loads if PROJECT_DOMAIN is set and a profile exists
```

### Flow 3 — Domain profile creation (missing profile path)

```
1. Detection: PROJECT_DOMAIN inferred/declared; no matching profile in .claude/skills/
2. In $build: pause only the increment that depends on domain judgment
   (same pattern as structural data delta — code not requiring domain judgment continues)
3. Guided creation: skill-creator scaffolds .claude/skills/domain-<x>/SKILL.md
   → SME elicitation (client or G7 consultant)
   → Without SME: profile born marked "provisional / LLM-seeded / low confidence"
   → Mark propagates to every finding that uses the profile
4. Materialization: profile ships via apply-v6 pattern (.claude/ is write-protected in Cowork)
   OR as a project-level skill outside .claude/
5. In $audit: domain without profile → "not assessable" + backlog recommendation
   → auditor NEVER fabricates a profile mid-audit
6. Persistence: profile committed to repo; v7 will distribute to portfolio
```

### Flow 4 — Evidence acquisition (I1 detail)

```
Acquisition paths (priority order):
  (a) .ppl export → parsed to node-graph.json + manifest.md
  (b) Pyplan MCP read endpoints (when enabled on the instance)
  (c) Manual fallback: developer supplies exports/screenshots

Parsed node graph per node:
  id, type (data/function/interface/input), has_result_assigned (bool),
  dependencies[], code_snippet (first 10 lines), mcp_decorated (bool)

Output location: .sdad/audit/<project>/evidence/
  manifest.md  — evidence manifest (human-readable)
  node-graph.json — compact JSON for ratchet consumption
```

**Build-time decision (2026-06-26, BR-17 — hybrid I1):** no `.ppl` sample exists in the repo
and the `.ppl` binary format is unverified. Writing a parser against a guessed format would
violate epistemic honesty. I1 therefore ships: (1) the acquisition PROTOCOL + manifest/node-graph
SCHEMAS, (2) a deterministic check that VALIDATES a node-graph.json against the schema, and
(3) a documented parser STUB explicitly marked "not tested until a real .ppl fixture exists".
The auditor populates the schema via MCP read / Pyplan UI / manual until the stub is validated.

---

## §4 Data Model (Artifacts)

| Artifact | Path | Description |
|----------|------|-------------|
| Evidence manifest | `.sdad/audit/<project>/evidence/manifest.md` | Acquisition path, timestamp, Pyplan version, declared gaps |
| Node graph | `.sdad/audit/<project>/evidence/node-graph.json` | Parsed node representation for ratchet + LLM consumption |
| Audit report | `.sdad/audit/<project>/report-YYYYMMDD.md` | Client-facing five-dimension report |
| Domain profile (finance) | `.claude/skills/domain-finance/SKILL.md` | KPIs, formulas, trap assumptions, red flags for FP&A |
| Domain profile (supply chain) | `.claude/skills/domain-supply-chain/SKILL.md` | KPIs, formulas, trap assumptions, red flags for SC |
| pyplan-mcp skill | `.claude/skills/pyplan/mcp/SKILL.md` | @mcp_tool producer rules + MCP read-access for I1 |
| business-alignment skill | `.claude/skills/business-alignment/SKILL.md` | Alignment checks, elicitation protocol, not-assessable rules |
| pyplan-audit skill | `.claude/skills/pyplan-audit/SKILL.md` | Orchestration, five-dimension model, report template |
| AUDIT_ACTIVE sentinel | `.sdad/AUDIT_ACTIVE` | Spec-gate allowlist extension (mirrors DOCFINAL_ACTIVE) |
| Installer | `apply-v6.ps1` + `apply-v6.sh` | Ships .claude/ changes; idempotent, self-deleting, ASCII |

---

## §5 Technical Architecture

### New skills (v6)

```
.claude/skills/
  pyplan/mcp/SKILL.md          — I2: EXTEND existing v4.2 skill (read-access role)
  business-alignment/SKILL.md  — I3a: domain-agnostic alignment core (NEW)
  domain-finance/SKILL.md      — I3b: FP&A profile (checklist level, NEW)
  domain-supply-chain/SKILL.md — I3b: supply chain profile (checklist level, NEW)
  pyplan-audit/SKILL.md        — I4: five-dimension audit orchestrator (NEW)
```

**Build-time correction (2026-06-26, BR-16):** the brief's I2 claim that `pyplan-mcp` is
"absent from main, must be built, not recovered" is factually wrong. The skill EXISTS on main
(200 lines, v4.2, commit history from `6a6f233`), and 6 branches exist. I2 is therefore an
EXTENSION (add the MCP read-access role for I1 + audit/producer framing), not a from-scratch
build. Severity downgraded HIGH→MEDIUM.

### New command
`$audit` — registered in CLAUDE.md Commands and `$sdad`. Spec-gate allowlist extended with
`.sdad/AUDIT_ACTIVE` sentinel. Runs without an approved SPEC.md (same gate as `$docfinal`).

### Static ratchet extensions (checks/)
Mechanical Pyplan findings promoted from LLM detection to deterministic checks:
- `missing-result-assign` — nodes without `result=` assigned
- `circular-deps` — circular dependency detection in node graph
- `mcp-untyped-params` — `@mcp_tool` parameters without `Annotated[type, 'desc']`

The LLM auditor receives ratchet output as pre-computed evidence; it does not re-detect
what the ratchet already covers deterministically.

### Composition model
`pyplan-audit` composes existing skills — it does not rewrite them:
- `pyplan-qa-platform` → development/architecture + quality dimensions
- `security-auditor` agent → security dimension
- `code-reviewer` agent → structure checks
- `business-alignment` → business dimension (5a)
- `domain-*` profile(s) → domain correctness (5b, loaded per PROJECT_DOMAIN)

When a composed skill improves, the auditor improves automatically.

### Installer
`apply-v6.ps1` + `apply-v6.sh`: one-shot, idempotent, self-deleting, pure ASCII.
Ships new skills + agent roles under `.claude/`; updates `install.*` / `project-init.*`
to scaffold `.sdad/audit/` seed. Mirrors the apply-v5 pattern.

### Domain-profile loading rule
`PROJECT_DOMAIN` declared in `$spec` (developer) or inferred + confirmed in `$audit`
(from data sources, node/KPI naming, interfaces, discovery docs).
Multi-domain: load multiple profiles; flag cross-domain seams as high-risk.
Profile absent: "not assessable" — finding, not a skip.

---

## §6 Business Rules

| ID | Rule | Origin |
|----|------|--------|
| BR-01 | `.ppl` export is I1's primary acquisition path; MCP read is an enhancement, not a prerequisite. I2 runs in parallel to I1. | §5.1 decision 2026-06-26 |
| BR-02 | `business-alignment` is on-demand. Triggers: `$audit`; or vague §1/§6 detected in `$spec`/`$build`. | §5.2 decision 2026-06-26 |
| BR-03 | Audit severity uses 4 unified bands: CRITICAL / HIGH / MEDIUM / LOW. Each finding shows band + source (H-XX, PP-XX, domain, alignment). Mapping: P0→CRITICAL, P1→HIGH, P2→MEDIUM, style→LOW. | §5.2 decision 2026-06-26 |
| BR-04 | Mechanical findings (missing `result=`, circular deps, untyped MCP params) run as static ratchet checks. The LLM auditor consumes ratchet output as evidence. | §5.2 decision 2026-06-26 |
| BR-05 | Domain profiles are checklist-level in v6: KPIs/metrics, typical formulas to validate, trap assumptions, red flags. Not full methodology. | §5.2 decision 2026-06-26 |
| BR-06 | v6 starter profiles: `domain-finance` (FP&A) and `domain-supply-chain`. Deferred (not-assessable): retail/merchandising, manufacturing, HR/workforce, sales/revenue. | §5.2 decision 2026-06-26 |
| BR-07 | Domain without profile → "not assessable - no domain profile". This is a finding (auditor recommends creating the profile). Never improvise a profile mid-audit. | §5.2 decision 2026-06-26 |
| BR-08 | Domain profile creation path: pauses only the dependent increment (data-delta pattern) → skill-creator + SME → provisional/LLM-seeded/low-confidence until review → commit via apply pattern. Provisional mark propagates to each finding using that profile. | $spec Q&A 2026-06-26 |
| BR-09 | Business alignment without owner elicitation → "not assessable - no elicitation input". Never fabricate alignment findings. | I3 design |
| BR-10 | All domain-correctness findings carry a confidence level. LLM profile raises the floor; it does not replace the client's SME for high-stakes validation. | I3b design |
| BR-11 | Audit report is evidence-based and intent-vs-delivered neutral. Never accusatory. Liability/relationship aware. | I5 design |
| BR-12 | Usability dimension requires a live-app walkthrough. When unavailable: limited to convention-compliance; report declares the limitation explicitly. | I6 design |
| BR-13 | Every audit report is stamped with SDAD version + exact model string. Audits are point-in-time judgments and must be reproducible/traceable. | I7 design |
| BR-14 | `$audit` runs without an approved SPEC.md. Spec-gate extended with `.sdad/AUDIT_ACTIVE` sentinel. | I5 design |
| BR-15 | v5 `$eval` golden dataset must pass after every v6 increment. New audit scenarios are additions, not alterations. | Hard constraint #6 |
| BR-16 | `pyplan-mcp` already exists on main (v4.2, 200 lines). I2 EXTENDS it with the I1 read-access role + audit framing; it is not a from-scratch build. Brief I2 claim corrected. Severity HIGH→MEDIUM. | Build discovery 2026-06-26 |
| BR-17 | I1 is hybrid: acquisition protocol + manifest/node-graph schemas + a schema-validation check ship now; the `.ppl` parser is a documented stub marked not-tested until a real `.ppl` fixture exists. No parser is written against an unverified format. | Build decision 2026-06-26 |

---

## §7 Integrations & APIs

### Pyplan MCP (first-party, per-instance)
- **Role in v6:** enhancement to I1 evidence acquisition (MCP read endpoints); primary context
  for `pyplan-mcp` skill (producer rules).
- **Maturity:** v1 server — first release; API may change across Pyplan updates. Document as
  external dependency in `pyplan-audit` skill with maturity flag.
- **Availability:** per-instance; not guaranteed on every client deployment. `.ppl` export is
  primary precisely because MCP is not universal.
- **CLI vs MCP (consumer context):** N/A — Pyplan MCP is producer context (`@mcp_tool`
  decoration). No CLI preference applies here (§7 rule only applies to consumer context).

### markitdown (document ingestion)
- **Role:** converts sales/discovery docs (PDF, docx, xlsx, pptx) to Markdown for pre-audit
  ingestion. Output treated as "declared-intent / claims-to-verify", not ground truth.
- **Security:** local trusted files only (`convert_local`). Never feed untrusted paths or URLs.
- **Ingestion path:** `.sdad/audit/<project>/ingest/` — working copies, not deliverables.

---

## §8 Testing Strategy

### Per-increment test gates (from brief §3)

| Increment | Test gate |
|-----------|-----------|
| I1 | Sample `.ppl` → parsed node-graph with `result=`/dependency flags; missing export path → declared gap (not crash) |
| I2 | Fixture model with planted MCP defect (untyped param, non-serializable return) → detected at correct severity |
| I3a | Vague §1 objective in `$spec` → flagged non-measurable; audit with no elicitation → not-assessable, not fabricated |
| I3b | Finance model → `domain-finance` loads + catches planted consolidation double-count; model with no profile → not-assessable; finance+SC model → both profiles + COGS seam flagged |
| I3b (creation path) | Domain without profile → creation path fires (detect → pause → skill-creator + SME → provisional → commit); does NOT hard-stop build or fabricate |
| I4 | Fixture with planted findings across all five dimensions → each surfaced under correct dimension and severity |
| I5 | `$audit` on fixture → five-dimension report + evidence manifest; runs without SPEC.md, allowed by spec-gate |
| I6 | Audit with no app access → usability marked "convention-only, live walkthrough not performed" |
| I7 | Runner catches deliberately weakened audit (fabricated business finding with no elicitation) |
| I8 | Two fixtures with equivalent findings → identical classification |

### Regression gate
`$eval` full suite (v5 core + new audit scenarios) must pass clean before tagging 6.0.

---

## §9 Security & Compliance

**Tier 2 Business** — SDAD is delivered to client engagements; audit reports contain
client model findings.

| Area | Control |
|------|---------|
| Document ingestion | markitdown local only (`convert_local`); no untrusted paths or URLs fed to parser |
| Evidence storage | `.sdad/audit/<project>/evidence/` stays local to the repo; no PII or credentials in manifest |
| MCP OAuth tokens | `pyplan-mcp` skill enforces: token never logged, never surfaced in node results (P0) |
| Audit report | Client-facing — no internal G7 annotations or system prompts in the deliverable |
| Domain profiles | Provisional/LLM-seeded profiles carry explicit confidence labels; no high-stakes validation without SME review |
| Installer scripts | `apply-v6.ps1` / `.sh` are pure ASCII, idempotent, self-deleting; no credentials in argv |

---

## §10 Definition of Done

Carried from brief §4 — v6 release gate:

- [ ] `$audit` produces a five-dimension report on a fixture, with declared evidence manifest,
      runs without a Spec (spec-gate allows `.sdad/AUDIT_ACTIVE`).
- [ ] I1 acquires `.ppl`/MCP model representation; un-acquirable areas declared as gaps.
- [ ] `pyplan-mcp` skill exists and detects a planted MCP defect at correct severity.
- [ ] `business-alignment` (I3a) flags non-measurable objective in `$build`; marks alignment
      not-assessable with no elicitation (no fabrication).
- [ ] `domain-finance` and `domain-supply-chain` each catch a planted domain-correctness defect.
- [ ] Model with no matching profile → marked not-assessable (finding, not skip).
- [ ] Multi-domain model → loads multiple profiles + flags cross-domain seam.
- [ ] Domain-without-profile creation path fires correctly (detect → pause → skill-creator →
      provisional → commit); does not hard-stop build or fabricate a profile.
- [ ] Severity reconciliation deterministic (two equivalent findings → identical classification).
- [ ] `$eval` v5 core + new audit scenarios → clean pass on final v6 state.
- [ ] All `.ps1`/`.sh` pure ASCII; `apply-v6.*` idempotent + self-deleting.
- [ ] CLAUDE.md within +60-line net budget; version + footer = 6.0.
- [ ] Full documentation set regenerated to v6 (no doc left at v4/v4.3/v5).
- [ ] v5.x project compatibility verified.

---

## §11 Out of Scope

- Portfolio-level audit-lesson aggregation — deferred to v7 I5. In v6, auditor writes
  lessons locally only.
- Deep methodology-level domain profiles — v6 is checklist level only.
- Pre-built profiles beyond finance and supply chain — retail, manufacturing, HR/workforce,
  sales/revenue are deferred and marked not-assessable until a profile is created.
- `$audit` for non-Pyplan projects — the audit lifecycle is Pyplan-specific in v6.
- v7 features: CI gate relocation, portfolio governance, multi-OS parity, deploy phase.
- Automated `.ppl` parsing of all Pyplan node types — v6 parses the subset needed for the
  five-dimension model (id, type, result=, deps, code_snippet, mcp_decorated).

---

## §12 Open Decisions

All decisions from brief §5 were resolved in the $spec session on 2026-06-26:

| Decision | Resolution |
|----------|------------|
| §5.1 MCP as primary vs enhancement | `.ppl` export primary; MCP enhancement. I2 parallel to I1. |
| §5.2 Domain starter set and depth | finance + supply chain; checklist level (KPIs, formulas, trap assumptions, red flags). |
| §5.2 Deferred domains | retail, manufacturing, HR, sales — not-assessable until profile exists. |
| §5.2 Domain creation path | Detailed in BR-08 and Flow 3. Pauses dependent increment only; never hard-stops. |
| §5.2 business-alignment: always-on vs on-demand | On-demand. Triggers: `$audit`, or vague §1/§6. |
| §5.2 Severity reconciliation | 4 unified bands (CRITICAL/HIGH/MEDIUM/LOW) with explicit mapping and source label. |
| §5.2 Mechanical findings → ratchet | Static ratchet in `checks/`. LLM auditor consumes output. |
| §5.2 Evidence manifest schema | Node graph (id, type, has_result_assigned, deps, code_snippet, mcp_decorated) + manifest.md + node-graph.json under `.sdad/audit/<project>/evidence/`. |

No open decisions remain. All resolved before $specout.

---

## §13 AI Authorship Log

| Increment | Feature | Model | Effort | Files | Tests | QA findings | Date |
|-----------|---------|-------|--------|-------|-------|-------------|------|
| Spec | SDAD v6.0 SPEC.md | claude-opus-4-8 | high | SPEC.md | n/a (spec) | none | 2026-06-26 |
| I1 | Evidence acquisition layer (hybrid) | claude-opus-4-8 | high | SCHEMA.md, checks/audit-evidence.ps1+.sh, acquire-evidence.ps1+.sh, 2 fixtures, eval scenario 15 | eval 15 PASS; core 15/15 | none | 2026-06-26 |
| I2 | Extend pyplan-mcp (read-access + audit) | claude-opus-4-8 | high | pyplan/mcp/SKILL.md (+2 sections, v6), mcp_lint.py, checks/mcp-tool-audit.ps1+.sh, 2 py fixtures, eval scenario 16 | eval 16 PASS; core 16/16 | none | 2026-06-26 |
| I3 | Business dimension (alignment core + domain profiles) | claude-opus-4-8 | high | skills business-alignment/, domain-finance/, domain-supply-chain/ SKILL.md; fixture finance-double-count.node-graph.json | fixture valid (audit-evidence exit 0); core 16/16; behavioral tests -> llm-smoke/I7 | none | 2026-06-26 |
| I4 | pyplan-audit orchestrator (5 dimensions) + 2 ratchet checks | claude-opus-4-8 | high | skills/pyplan-audit/SKILL.md; agents/business-analyst.md; checks missing-result-assign + circular-deps (.ps1+.sh); 2 defect fixtures; eval scenarios 17, 18 | core 18/18 PASS; behavioral multi-dim test -> I7 | none | 2026-06-26 |

---

*G7 AI Development Methodology | SDAD v6.0 Pyplan Audit Edition | SPEC.md*
*Generated by $specout on 2026-06-26 — pending developer approval*
