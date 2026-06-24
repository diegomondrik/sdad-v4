# SPEC.md — SDAD Board Extension v1.0
**Version:** 1.0
**Date:** 2026-06-24
**Compliance Tier:** Tier 1 — Standard
**Status:** Approved for $build

---

## §0 — Platform & Context

**PROJECT_PLATFORM:** general

> This project extends the SDAD methodology itself — it is not a Board project.
> It adds `PROJECT_PLATFORM: board` as a new platform option inside SDAD,
> mirroring the existing Pyplan integration pattern.

**Runtime environment:**
Claude Code running against the `sdad-v4` repository root. All deliverables are
plain text files (`.md`, `.ps1`, `.sh`) written directly to the repo filesystem.
No build step, no compilation — the "build" is authoring correctly-structured
SKILL.md files and updating Claude.md and SPEC_blank.md.

**Reference repositories:**
- SDAD repo: `https://github.com/diegomondrik/sdad-v4`
- Board docs: `https://help.board.com` (llms.txt index available)
- Board API: `https://help.board.com/docs/board-public-apis`

---

## §A — Delta Log

| # | Date | Section | Change | Reason |
|---|------|---------|--------|--------|
| — | 2026-06-24 | — | Initial version | — |
| 1 | 2026-06-24 | §E, §12 | OD-01 closed: §E soft gate for existing projects | Developer confirmed — Draft allows $build in analysis mode, Approved enables full $build |
| 2 | 2026-06-24 | §5, §12 | OD-02 closed: Board skills stay separate (data-model/ + capsule/) | Developer confirmed — activation triggers differ, keep focused |
| 3 | 2026-06-24 | §6, §12 | OD-03 closed: Algorithm validation in $build (blocking) + $qa Layer 5 (catch) | Developer confirmed — both layers active |
| 4 | 2026-06-24 | §3, §12 | OD-04 closed: Board API as optional question in $spec | Developer confirmed — not all clients have API enabled; skill asks once, skips gracefully if unavailable |

---

## §B — Open Questions

| # | Question | Owner | Status |
|---|----------|-------|--------|
| Q-01 | Should the Board skill support the Board API (OAuth) actively in $spec, or only document it as optional? | developer | Open |
| Q-02 | Does the installer (install.ps1 / install.sh) need to be updated to copy board/ skill folder, or is this covered by the existing `.claude/skills/` copy mechanism? | developer | Open |
| Q-03 | Should §E be a hard gate (blocks $build) for ALL Board projects, or only for new ones (existing projects may have partial info)? | developer | Open |

---

## §1 — Vision & Objective

**Problem:**
SDAD v4.3/v5.0 supports `pyplan` as a specialized platform but has no equivalent
for Board (Board International BI & Planning platform). Developers working on Board
projects using SDAD must use the generic `general` platform, which gives them no:
- Board-specific $spec questions (Data Model, Capsule structure, existing project detection)
- Board-aware SPEC sections (Entities, Cubes, Relationships, Screens, Procedures)
- Board increment checklist ($build)
- Board QA Layer 5 ($qa)
- Guidance on what artefacts Claude can generate for Board (SQL, CSV, Layout XML)

**Solution:**
Add `PROJECT_PLATFORM: board` as a first-class platform in SDAD, with a full skill
stack under `.claude/skills/board/`, updates to `Claude.md` and `SPEC_blank.md`,
and optional integration with the Board Public API for existing project introspection.

**Success criteria:**
- A developer running `$spec` on a Board project gets Board-specific questions
  (new vs existing, Data Model name, Capsule structure) without manual prompting.
- §E (Board Data Model) and §F (Board Capsule Structure) appear automatically in
  the generated SPEC.md when `PROJECT_PLATFORM: board`.
- `$build` generates correct Board artefacts (SQL, CSV, Layout XML, Procedure specs)
  instead of generic code files.
- `$qa` runs a Board-specific Layer 5 that catches common Board anti-patterns
  (sparsity, wrong Procedure level, client/server-side Step misclassification,
  Algorithm syntax errors).
- An existing Board project can be ingested via uploaded files (XML, CFG, CSV,
  screenshots) and the skill reconstructs §E and §F automatically.

---

## §2 — Users & Roles

| Role | Description | Access |
|------|-------------|--------|
| Board Developer | Builds Data Models, Capsules, Screens, Procedures in Board UI | Full — uses all Board skill modes |
| Board Analyst/Planner | End-user of Board applications; uses SDAD to document/optimize existing Capsules | Read + analysis mode; limited $build |
| SDAD Maintainer | Extends the methodology; runs $eval after changes | Full — writes skill files |

---

## §3 — Functional Flows

### Flow 1 — New Board Project ($spec → $build)

```
Developer runs $spec
  → Phase 0: Claude detects PROJECT_PLATFORM: board (or asks)
  → Board-specific question: "New project or existing?"
  → Answer: NEW
  → $spec asks Board questions in order:
      1. Board version (default: v15)
      2. Cloud or on-premises?
      3. Data Model name(s)
      4. Entities needed (dimensions)
      5. Relationships (hierarchies) between Entities
      6. Cubes needed (measures + dimensions)
      7. Capsule structure (Screens, navigation)
      8. Procedures needed (type: Capsule-level vs Data Model-level)
      9. Data sources (SQL, CSV, SAP, API)
      10. Board API available? (URL + credentials for later use)
  → $specout generates SPEC.md with §E and §F prepended
  → §E gate: must be approved before $build
  → Developer approves → $build available

$build (Board):
  → Announce increment with Board artifact type
  → Generate: SQL for Data Readers / CSV for Entity loading /
              Layout XML definition / Procedure logic spec
  → Run Board Increment Checklist
  → Update §13 AI Authorship Log
```

### Flow 2 — Existing Board Project (ingestion → analysis)

```
Developer runs $spec
  → Phase 0: PROJECT_PLATFORM: board detected
  → Board-specific question: "New project or existing?"
  → Answer: EXISTING
  → Skill asks what files are available:
      - Layout XMLs (Export Layout to XML from Board UI)
      - Screenshots of Screens
      - CFG files (Data Reader configurations)
      - CSV/TXT exports (Entity or Cube data)
  → Developer uploads files
  → Skill reads and parses:
      - XML: extracts Cube names, Entity names, Data Blocks, Algorithms
      - CFG: extracts Data Reader type, source parameters
      - CSV/TXT: infers Entity structure and data volume
      - Screenshots: describes Screen layout and objects (visual context)
  → Optional: if Board API credentials provided, call:
      GET /public/{dbName}/schema/Entities
      GET /public/{dbName}/schema/Cubes
      GET /public/capsules/{capsuleName}
  → Skill auto-populates §E and §F with inferred content
  → Marks fields as [inferred] vs [confirmed by developer]
  → Asks targeted questions only for what could not be inferred
  → Generates SPEC_RETROACTIVE.md (uses $docfinal pattern)
  → Developer corrects / approves
  → $build available for extensions or optimizations
```

### Flow 3 — $qa on Board Project

```
$qa runs after $build increment
  → Layers 1–4: standard SDAD
  → Layer 5 (Board Platform) activates automatically:
      - Data Model checks (Entity order, sparsity, Relationship integrity)
      - Capsule checks (Procedure level, Screen-DataModel binding)
      - Algorithm syntax checks (block letters, Board functions)
      - Naming convention checks
  → Findings reported with Board-specific remediation guidance
  → Security: Board API credentials never logged in Procedures (P0)
```

---

## §4 — Data Model (Skill File Structure)

The "data model" for this project is the set of files produced:

```
sdad-v4/
└── .claude/
    └── skills/
        └── board/
            ├── SKILL.md                  # Main skill — always on for Board projects
            ├── spec-context/
            │   └── SKILL.md              # Board-specific $spec questions and §E/§F generation
            ├── data-model/
            │   └── SKILL.md              # Entities, Relationships, Cubes design expertise
            ├── capsule/
            │   └── SKILL.md              # Screens, Procedures, Layouts, Masks expertise
            └── qa-platform/
                └── SKILL.md              # Board Layer 5 QA checks
```

**Changes to existing files:**

| File | Change |
|------|--------|
| `Claude.md` | Add `PROJECT_PLATFORM: board` option + activation rules + Board increment checklist + Board QA Layer 5 entry + Board routing in $spec |
| `SPEC_blank.md` | Add §E (Board Data Model) and §F (Board Capsule Structure) as conditional sections |
| `install.ps1` | Add board/ skill folder to copy list |
| `install.sh` | Add board/ skill folder to copy list |

**§E — Board Data Model** (new SPEC section template):
```markdown
## §E — Board Data Model
**Applies to:** PROJECT_PLATFORM: board projects.
**Gate:** §E must be approved before $build is allowed.

**Board version:** [15 / 14 / other]
**Environment:** [Cloud / On-premises]
**Data Model name(s):** [name1, name2]
**Time Range:** [start year – end year, granularity: Monthly / Weekly / Daily]

### Entities
| Entity name | Description | Members (approx.) | Source |
|-------------|-------------|-------------------|--------|
| [Month] | Time dimension | 12/year | Board time entity |
| [Product] | Product catalog | [N] | [SQL table / CSV] |

### Relationships (Hierarchies)
| Hierarchy name | Base Entity → Parent → ... → Top |
|----------------|-----------------------------------|
| [ProductHierarchy] | Product → Category → Division |

### Cubes
| Cube name | Description | Dimensions | Data type | Source |
|-----------|-------------|------------|-----------|--------|
| [SalesValue] | Gross sales amount | Product, Customer, Month | Numeric | SQL Data Reader |

**§E Status:** Draft / Approved
```

**§F — Board Capsule Structure** (new SPEC section template):
```markdown
## §F — Board Capsule Structure
**Applies to:** PROJECT_PLATFORM: board projects.

### Capsules
| Capsule name | Purpose | Primary Data Model | Screens (approx.) |
|--------------|---------|-------------------|-------------------|
| [SalesDashboard] | Sales analysis | SalesModel | 5 |

### Screens (per Capsule)
| Screen name | Type | Objects | Data Model |
|-------------|------|---------|------------|
| [Overview] | Dashboard | DataView, Chart x2, Selector | SalesModel |

### Procedures
| Procedure name | Location | Type | Steps summary | Scheduleable |
|----------------|----------|------|---------------|--------------|
| [LoadSales] | Data Model | Server-side | SQL Data Reader → Dataflow | Yes |
| [NavigateToDetail] | Capsule | Client-side | Go to Screen + Apply Selection | No |

### Masks
| Mask name | Applied to Screens | Contents |
|-----------|-------------------|----------|
| [NavMask] | All Screens | Menu Object, Logo |

**§F Status:** Draft / Approved
```

---

## §5 — Technical Architecture

**Stack:**
- Claude Code (file read/write, no build step)
- Markdown (SKILL.md files — progressive disclosure format)
- PowerShell / Bash (installer scripts)
- Board Public REST API (optional, read-only: OAuth2 + Bearer token)

**Skill architecture (progressive disclosure pattern, same as Pyplan):**

| Skill file | Always-on or on-demand | Trigger |
|------------|------------------------|---------|
| `board/SKILL.md` | Always-on when `PROJECT_PLATFORM: board` | Platform declaration |
| `board/spec-context/SKILL.md` | Auto on $spec / $specout for Board projects | Same trigger as pyplan/spec-context |
| `board/data-model/SKILL.md` | On-demand | "entity", "cube", "relationship", "data model", "dimension", §E |
| `board/capsule/SKILL.md` | On-demand | "capsule", "screen", "procedure", "layout", "mask", §F |
| `board/qa-platform/SKILL.md` | Auto on $qa for Board projects | Same trigger as pyplan/qa-platform |

**Claude.md additions (mirroring Pyplan pattern):**

```
# In Project Declaration section:
# PROJECT_PLATFORM: board   ← uncomment for Board projects

# When PROJECT_PLATFORM: board is set:
#   · $spec    → adds §E (Board Data Model — gate) and §F (Board Capsule Structure)
#                asks "new vs existing project" before standard sections
#                if existing: file ingestion flow (XML, CFG, CSV, screenshots)
#   · $build   → adds Board increment checklist at increment close
#                generates Board artefacts (SQL, CSV, Layout XML, Procedure specs)
#                instead of standard code files
#   · $qa      → adds Platform layer (Layer 5 — Board) to QA run
#   · Skills   → board-spec-context, board-data-model, board-capsule,
#                board-qa-platform load on-demand by trigger

# Active Skills (On-demand additions):
# - **Board Spec Context**   — trigger: auto on $spec/$specout on Board projects
# - **Board Data Model**     — trigger: entity, cube, relationship, dimension, §E
# - **Board Capsule**        — trigger: capsule, screen, procedure, layout, mask, §F
# - **Board QA Platform**    — trigger: auto by $qa on Board projects (Layer 5)
```

---

## §6 — Business Rules

**BR-01 — §E gate applies only to new projects by default.**
For existing projects ingested via files, §E can be marked "Draft / Pending confirmation"
and $build is available in analysis/optimization mode. Gate enforced strictly only
when §E Status is explicitly "Open" (empty).

**BR-02 — Board artefacts are not executable code.**
$build for Board generates specification documents and importable files (SQL, CSV, XML).
There are no unit tests in the traditional sense. The DoD replaces test execution
with "artefact validated against Board syntax rules by the skill."

**BR-03 — Algorithm formulas must use Board syntax exclusively.**
Formulas use block letters (a, b, c...), not variable names.
Board-specific functions: `dt()`, `rt()`, `gt()`, `@DATE`, `@MONTH`, `@YEAR`.
The skill must validate Algorithm syntax before marking an increment complete.

**BR-04 — Procedure placement rules are enforced.**
- Data Model Procedure: can be scheduled, can be called from multiple Capsules.
- Capsule Procedure: cannot be scheduled, cannot be called externally.
- The skill flags a violation if a scheduleable Procedure is placed at Capsule level (P1).

**BR-05 — Entity creation order is enforced.**
Correct order: Entities → Relationships → Cubes. The skill blocks increments
that violate this order and explains why (downstream Cube dimension errors).

**BR-06 — Board API credentials are never logged or stored in SPEC.md.**
If API credentials are used (OAuth Bearer token), they are used in-session only.
The skill instructs the developer to use environment variables for any persistent use.

**BR-07 — Existing project ingestion marks inferred data explicitly.**
All fields in §E and §F populated from file ingestion are tagged `[inferred]`.
The developer must confirm or correct before §E is approved.

**BR-08 — The Board skill does not cover Board administration.**
Out of scope: user management, licensing, SCIM API, server configuration,
add-ins (Power BI, Excel), XBRL, clustering (R), BEAM/Predictive Analysis.

---

## §7 — Integrations & APIs

| Integration | Endpoint | Usage | Notes |
|-------------|----------|-------|-------|
| Board Public API — Schema | `GET /public/{dbName}/schema/Entities` | Read Entity list for existing project ingestion | Requires OAuth2 Bearer token |
| Board Public API — Schema | `GET /public/{dbName}/schema/Cubes` | Read Cube list for existing project ingestion | Requires OAuth2 Bearer token |
| Board Public API — Capsule | `GET /public/capsules/{capsuleName}` | Read Capsule tree for existing project ingestion | Requires OAuth2 Bearer token |
| Board Public API — Procedure | `POST /public/{dbName}/procedure/Execute/{procedureName}` | Execute Data Model Procedures (optional, advanced) | Data Model Procedures only |
| Board Public API — Search | `GET /public/search/{text}` | Full-text search across platform | Optional |
| help.board.com | `https://help.board.com/llms.txt` | Live documentation index for skill to reference | Read-only, no auth |

**API rate limits:** 500 requests/day, 10 requests/second, 100s timeout.
**Auth:** OAuth 2.0 PKCE flow. Token valid 1 day. Credentials never stored in SPEC.md.

**MCP vs CLI evaluation (per SDAD §7 rule):**
The Board API is consumed by the skill (Claude) directly via WebFetch — no CLI wrapper
needed. A Board MCP connector does not exist officially. If one is created in the future,
evaluate per the SDAD MCP-vs-CLI gate.

---

## §8 — Testing Strategy

Board skill files have no automated test runner. Validation is done via:

| Test | Type | When |
|------|------|------|
| $eval run after each skill file created | SDAD methodology self-eval | After each increment |
| $spec Board dry run — new project | Manual — run $spec with platform=board, new project, answer all questions | After spec-context SKILL.md |
| $spec Board dry run — existing project | Manual — upload sample XML Layout + CFG + screenshot, verify §E reconstruction | After spec-context SKILL.md |
| $build Board dry run — Data Reader SQL | Manual — run $build for a SQL Data Reader increment, verify SQL syntax | After data-model SKILL.md |
| $qa Board dry run | Manual — introduce a known anti-pattern (Entity without Relationship as Cube dimension), verify Layer 5 catches it | After qa-platform SKILL.md |
| Algorithm syntax validator | Manual — provide an Algorithm with `dt()` and verify skill accepts it; provide one with a wrong function and verify it flags it | After data-model SKILL.md |
| API ingestion test | Manual — provide a Board instance URL + credentials, verify `/schema/Entities` is called and §E is populated | After spec-context SKILL.md (optional) |

---

## §9 — Security & Compliance (Tier 1)

**Assets to protect:**
- Board API credentials (OAuth client secret, Bearer token)
- Board instance URL (may be internal/corporate)

**Controls:**
- API credentials used in-session only via Claude Code environment — never written to SPEC.md, DECISIONS.md, or any file in the repo.
- Skill instructs developer to provide credentials only when explicitly asked and confirms they are not persisted.
- Board instance URL is written to §7 of SPEC.md as a non-sensitive endpoint reference only (no credentials included).
- No credential storage, no `.env` file generation for credentials by this skill.

---

## §10 — Definition of Done

An increment is complete when:
- [ ] SKILL.md file is syntactically valid Markdown and follows the progressive disclosure pattern
- [ ] The skill activates correctly on its declared trigger (tested manually)
- [ ] Claude.md or SPEC_blank.md changes produce expected behavior in $spec / $build / $qa dry runs
- [ ] All Board-specific rules (BR-01 through BR-08) are covered in the relevant skill
- [ ] $eval passes without regressions on the SDAD golden dataset
- [ ] SPEC.md §13 updated
- [ ] §A updated if this increment changed scope or architecture

---

## §11 — Out of Scope

- Board administration: user management, licensing, SCIM API, server/cloud configuration
- Board add-ins: Power BI connector, Excel Add-in
- XBRL export functionality
- Clustering with R (Pyplan/R integration)
- BEAM / Predictive Analysis module
- Board Collaboration Services (chat, discussions, feed)
- Substitution Formulas full reference (pages are client-rendered; defer to documentation link)
- NEXEL formula editor full reference (same reason)
- Building a Board MCP connector (separate project; evaluated in a future SDAD version)
- SDAD v4.3 → v5.0 migration (already completed upstream)
- Updating the SDAD installer to create the Board project folder structure in project repos

---

## §12 — Open Decisions

| # | Decision | Status |
|---|----------|--------|
| OD-01 | §E gate behavior for existing projects: soft gate confirmed — Draft allows $build in analysis mode; Approved enables full $build; Open (empty) blocks $build. | **Closed** |
| OD-02 | Board skills stay as separate files: `data-model/` + `capsule/`. | **Closed** |
| OD-03 | Algorithm validation active in $build (blocks on error) + passive in $qa Layer 5 (catches misses). | **Closed** |
| OD-04 | Board API asked as optional question in $spec: "Do you have Board API access?" — if yes, use for ingestion; if no, use file ingestion only. Skips gracefully. | **Closed** |

---

## §13 — AI Authorship Log

| Increment | Feature | Model | Effort | Files | Tests | QA findings | Date |
|-----------|---------|-------|--------|-------|-------|-------------|------|
| SPEC v1.0 | Initial spec | claude-sonnet-4-6 | n/a | n/a | n/a | n/a | 2026-06-24 |
| Inc 1 | CLAUDE.md — board platform declaration, gates, checklist, QA Layer 5, behavior rules | claude-sonnet-4-6 | low | Claude.md | $eval 14/14 PASS | none | 2026-06-24 |
| Inc 2 | SPEC_blank.md — §E Board Data Model + §F Board Capsule Structure templates | claude-sonnet-4-6 | low | SPEC_blank.md | visual verification | none | 2026-06-24 |
| Fix | assert-claude-md.ps1 — baseline dinámico (v4.3 hardcoded → latest git tag) | claude-sonnet-4-6 | low | .sdad/eval/lib/assert-claude-md.ps1 | $eval 14/14 PASS | none | 2026-06-24 |
| Inc 3 | board/SKILL.md — skill principal always-on: mental model, glossary, artefacts, sub-skill routing | claude-sonnet-4-6 | low | .claude/skills/board/SKILL.md | $eval 14/14 PASS | none | 2026-06-24 |
| Inc 4 | board/spec-context/SKILL.md — $spec flows (new + existing), §E/§F generation, file ingestion, API ingestion, §E gate | claude-sonnet-4-6 | low | .claude/skills/board/spec-context/SKILL.md | $eval 14/14 PASS | P0 fixed (token handling proximity) | 2026-06-24 |
| Inc 5 | board/data-model/SKILL.md — Entities, Relationships, Cubes, Data Readers, Algorithm syntax + functions, SQL generation, §E check | claude-sonnet-4-6 | low | .claude/skills/board/data-model/SKILL.md | $eval 14/14 PASS | none | 2026-06-24 |
| Inc 6 | board/capsule/SKILL.md — Screens, Procedures (placement rules, step types), Layouts, Masks, Selectors, Data Entry, §F check | claude-sonnet-4-6 | low | .claude/skills/board/capsule/SKILL.md | $eval 14/14 PASS | none | 2026-06-24 |
| Inc 7 | board/qa-platform/SKILL.md — Layer 5 checks DM-01..06, CP-01..05, NM-01, SEC-01; H-XX format; P0/P1/P2 severity; cross-layer notes | claude-sonnet-4-6 | low | .claude/skills/board/qa-platform/SKILL.md | $eval 14/14 PASS | none | 2026-06-24 |
| Inc 8 | install.ps1 + install.sh — board/ skill folders + files added; version bump 5.1→5.2; CLAUDE.md header/footer bumped to v5.2 | claude-sonnet-4-6 | low | install.ps1, install.sh, CLAUDE.md | $eval 14/14 PASS | none | 2026-06-24 |

---

## Build Plan (reference — not part of SPEC format)

Suggested increment order for `$build`:

| # | Increment | Files | Gate dependency |
|---|-----------|-------|-----------------|
| 1 | Update `Claude.md` — declare `board` platform, activation rules, increment checklist, QA Layer 5 | `Claude.md` | None |
| 2 | Update `SPEC_blank.md` — add §E and §F conditional sections | `SPEC_blank.md` | None |
| 3 | Create `board/SKILL.md` — main skill, always-on, Board mental model, glossary | `.claude/skills/board/SKILL.md` | Inc 1 |
| 4 | Create `board/spec-context/SKILL.md` — $spec questions (new + existing), §E/§F generation, file ingestion logic, API ingestion | `.claude/skills/board/spec-context/SKILL.md` | Inc 3 |
| 5 | Create `board/data-model/SKILL.md` — Entities, Relationships, Cubes, Data Readers, Algorithm syntax, SQL generation | `.claude/skills/board/data-model/SKILL.md` | Inc 3 |
| 6 | Create `board/capsule/SKILL.md` — Screens, Procedures (types, steps), Layouts, Masks, Selectors, Data Entry | `.claude/skills/board/capsule/SKILL.md` | Inc 3 |
| 7 | Create `board/qa-platform/SKILL.md` — Layer 5 checks: sparsity, Procedure level, step type, Algorithm syntax, naming | `.claude/skills/board/qa-platform/SKILL.md` | Inc 3, 5, 6 |
| 8 | Update installers — add board/ skill folder to copy list | `install.ps1`, `install.sh` | Inc 7 |
