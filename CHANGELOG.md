# CHANGELOG — SDAD
# G7 AI Development Methodology
# Spec-Driven AI Development for Claude Code

All notable changes to the SDAD methodology are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added

**Hooks ported to bash — macOS/Linux support (closes the [4.3] known gap)**
- `session-start.sh`, `pre-compact.sh`, `session-end.sh` — 1:1 POSIX sh ports of
  the three PowerShell hooks, same safeguards (guarded ff-only pull, anchor
  snapshot, autocommit whitelist + HOLD sentinel, no empty commits).
- `run-hook.sh` — cross-platform dispatcher. `settings.json` now registers one
  shell-form command per hook; on Windows it runs under Git Bash and delegates
  to the unchanged `.ps1` scripts, on macOS/Linux it runs the `.sh` ports.
- Test gate passed on macOS: valid JSON (`jq`), unicode (ñ/accents/em-dashes)
  round-trip without mojibake (L-01 regression content), pull guard, hold
  sentinel, whitelist isolation, no empty commits, real-session integration
  (SessionStart + SessionEnd fired through the dispatcher).
- `install.sh` now ships all hook scripts (.sh + .ps1) and `settings.json`
  (never overwritten if present); Windows-only note removed.

---

## [4.3] — 2026-06-10

### Overview

SDAD v4.3 adds Model & Effort Routing across all phases and repairs installer
drift found in a full v4.2 audit. Core focus: choosing the right model and
reasoning effort per SDAD phase (Fable/Opus/Sonnet/Haiku era), pinning models
for delegated agents, and making the installers actually ship everything v4.2
declared.

**Upgrade note:** v4.2 projects are fully compatible. Run `git tag v4.2`
before pulling v4.3 to preserve prior state.

---

### Added

**Model & Effort Routing (CLAUDE.md section)**
- Model-agnostic tiers: FRONTIER (best reasoning available, e.g. fable/opus),
  STANDARD (e.g. sonnet), ECONOMY (e.g. haiku) — survives model releases.
- Per-phase routing table: $spec/$specout → FRONTIER·high; $build per-increment
  (STANDARD·low executing / FRONTIER·high open decisions); $qa incremental →
  STANDARD·medium; $qa full/$QA/$docfinal → FRONTIER·high; $verify/$doc →
  ECONOMY–STANDARD·low; $pause/$lesson/$flow → current model, never switch.
- 🧠 MODEL announcement generalized: fires at the start of $spec, $specout,
  $qa full, and $docfinal (was $build-only via C-015). Only $build blocks on
  mismatch — other phases flag once and continue.
- Capability note locked in: main session never auto-switches; Vía A is manual
  /model + /effort; Vía B is agent frontmatter (roadmap §2.1b).

**Agent model pinning (Vía B)**
- Frontmatter for the three agents: code-reviewer opus·high, security-auditor
  opus·high, test-generator sonnet·medium. Applied via `apply-v4.3.ps1` (one-shot,
  idempotent, self-deleting — `.claude/` is write-protected in Cowork mode).

**security-reviewer skill** (`.claude/skills/security-reviewer/SKILL.md`)
- Was referenced in CLAUDE.md since v4.0 but never existed. Created: secrets/
  credentials (P0), injection & input handling (P1), auth (P1), PII (P0–P1),
  severity discipline, $qa Layer 1 + Tier 2/3 §9 integration. Installed by
  `apply-v4.3.ps1` and by the installers.

**Developer Manual** (`docs/DEVELOPER_MANUAL_v4.3.html`)
- Didactic manual covering SDAD core, SDAD for Pyplan, and day-to-day usage. In English.

**Project language selection (PROJECT_LANGUAGE)**
- New project declaration field `PROJECT_LANGUAGE: en | es`. The FIRST `$spec`
  question asks whether the project runs in English or Spanish; the answer is
  locked and governs all interaction and generated documents (SPEC.md,
  DECISIONS.md, QA reports, lessons, $doc output). Code identifiers and
  comments stay in English regardless.

**Documentation refresh**
- All four legacy HTML docs (INSTALL_GUIDE, USAGE_AND_SHORTCUTS,
  DEVELOPER_GUIDE, ONBOARDING_PYPLAN) re-stamped from v4.1 to v4.3; stale
  "hooks inactive" note corrected; feature-origin references normalized to
  "since v4.1". All repo documentation is in English.
- `apply-v4.3-stamps.ps1` — one-shot version-stamp bump for files inside
  `.claude/` (skills, agents, hooks README). Self-deletes.
- `docs/TASK_HOOKS_MACOS_PORT.md` — self-contained task brief for a macOS dev
  to port the three hooks to bash (setup, spec, test gate, SDAD discipline).

**Context budget cap raised**
- CLAUDE.md net line budget per release: +40 → +60 ([LOCK] updated in
  DECISIONS.md; the "stays lean" rule is unchanged — voluminous content still
  goes to on-demand skills). Rationale: the Model & Effort Routing table gates
  every phase and belongs inline.

---

### Fixed

- `install.ps1` / `install.sh` were still v4.1: missing `dev-setup` and
  `brand-design` skills, agent HANDOFF template, hook scripts, hooks README,
  and `settings.json` registration — v4.2 declared hooks active but the
  installer never shipped them. All added. `settings.json` is never overwritten
  if present; hooks remain Windows-only (PowerShell) — install.sh notes this.
- `brand-design` skill existed since v4.0 but was not listed in CLAUDE.md
  Active Skills or `$skills` — now discoverable (trigger: brand, visual
  identity, brand tokens, §C).
- README "Active skills (always on)" wrongly listed Security Reviewer and
  QA Engineer as always-on — both are on-demand per CLAUDE.md.

### Known gaps (deferred)

- Bash equivalents of the three PowerShell hooks (hooks remain Windows-only;
  porting without a test environment risks repeating the L-01 encoding class
  of bugs — deliberately deferred, not forgotten). → CLOSED in [Unreleased]:
  ported and tested on macOS.
- CHANGELOG [4.0] §A/§B section names and "Layer 7" reference don't match
  current CLAUDE.md naming — left as historical record.

---

## [4.2] — 2026-06-08

### Overview

SDAD v4.2 hardens session continuity and methodology robustness.
Core focus: hooks activation, cross-session anchor survival, MCP-vs-CLI
security gate, and structural quality improvements to `$build`, `$verify`,
and the Lesson Library. No new phases or commands — all changes deepen
existing capabilities.

**Upgrade note:** v4.1 projects are fully compatible. No existing files
need to change. Run `git tag v4.1` before pulling v4.2 to preserve prior state.

---

### Added

**Hooks (now active)**
- `SessionStart` hook — restores COMPACT ANCHOR after session resume or
  compaction; runs `git pull` (guarded fast-forward) on session open.
- `PreCompact` hook — writes COMPACT ANCHOR snapshot to disk before
  compaction so it survives context reduction.
- `SessionEnd` hook — whitelisted autocommit with safety guards
  (no force push, no untracked secrets, no main/master direct push).
- `.claude/settings.json` — hook registration and permission allowlist.

**COMPACT ANCHOR + `[LOCK]` convention**
- `$pause compress` now emits a COMPACT ANCHOR block with `[LOCK]`-tagged
  decisions that survive compaction and are re-injected at session start.
- `DECISIONS.md` entries marked `[LOCK]` are carried into the anchor;
  unlocked decisions are not.
- Non-reopenable architectural decisions persist across sessions without
  developer re-explanation.

**MCP-vs-CLI security gate** (§7 + QA Layer 1)
- The §7 CLI-vs-MCP evaluation now has a hard security gate: if a CLI
  wrapper introduces shell injection, credentials-in-argv/env, or fragile
  parsing risk, the vetted MCP is kept regardless of context cost.
- QA Layer 1 checks this explicitly (P1 finding).
- Rule is `[LOCK]` — cannot be reduced to a token/cost tradeoff.

**`$build` step 5.5 — Project CLAUDE.md protocol**
- After every structural increment, `$build` proposes an update to the
  project's own `CLAUDE.md`. Keeps project-level conventions in sync
  without duplicating SPEC.md content. Soft guide: ~150–200 lines.

**`$verify audit` — proactive mode**
- New trigger: Phase 0 when the project went >30 days without a `$build`
  (date source: last §13 entry / git log).
- Proactively audits all dependencies against current docs, not just
  newly introduced ones.

**Dev Setup skill** (on-demand, `.claude/skills/dev-setup/SKILL.md`)
- Links to live Claude Code docs for onboarding and tooling setup.
- Zero rot by design: no feature names or release dates transcribed inline
  (C-014 — links only, never transcribes unstable feature names).
- Trigger: "onboarding", "dev setup", "which Claude Code features complement SDAD".

**Agent HANDOFF template** (`.claude/agents/HANDOFF_TEMPLATE.md`)
- Structured return format for all `$agent` sub-agents.
- Fields: Agent, Task, Findings (H-XX), Recommended actions, Files reviewed,
  Delegated-safely confirmation.

**Lesson Library — L-02**
- L-02: Validate single-source rules against real workflows before locking.
  Category: Workflow. Added from v4.2 validation session.

---

### Changed

- `$build` announcement block — now includes model + effort recommendation
  with explicit flag-and-wait when active session differs.
- `$verify` — `$verify audit` split out as named proactive mode; `$verify`
  alone remains reactive (triggered by new dependency in `$build`).
- `$pause` — always includes Decisions log count, flows count, platform,
  and project CLAUDE.md last-modified date.
- `$pause compress` — COMPACT ANCHOR added to snapshot output.
- QA Layer 1 — MCP-vs-CLI security check added (P1).
- All skill and agent version stamps bumped to v4.2.
- README.md updated to v4.2 with "What's new in v4.2" section.
- `.claude/hooks/README.md` — hooks now active (were inactive in v4.0/v4.1).

---

### Notes

- Hooks require PowerShell (Windows) or bash (Mac/Linux). The installer
  registers them automatically via `.claude/settings.json`.
- `PreCompact` hook injection does NOT survive compaction by itself —
  survival relies on `SessionStart` re-injecting from disk after compaction.
  This is by design (verified against Claude Code docs).

---

## [4.1] — 2026-06-04

### Overview

SDAD v4.1 adds native support for the Pyplan MCP server (v1).
The Pyplan MCP allows AI clients to connect to a running Pyplan instance,
discover dynamic tools, and interact with application logic via natural language.
v4.1 integrates this capability into the existing SDAD methodology without
changing the core phases — it extends the Pyplan layer with a new gate section,
a new skill, and MCP-specific checklist and QA items.

**Upgrade note:** v4.0 projects are fully compatible. No existing files need to
change unless the project starts using `@mcp_tool` nodes. Run `git tag v4.0`
before pulling v4.1 to preserve the prior state.

---

### Added

**Pyplan MCP layer**
- `pyplan-mcp` skill (`.claude/skills/pyplan/mcp/SKILL.md`) — on-demand specialist
  for `@mcp_tool` node design, §D authoring, Build-via-AI guardrails, and MCP QA.
  Trigger: `@mcp_tool`, `MCP tools`, `dynamic tools`, `§D`, `mcp_tool decorator`.
- `§D — MCP Tools Catalog` — new conditional gate section in SPEC.md for Pyplan
  projects that expose at least one `@mcp_tool` node. Documents: node identifier,
  tool name, description, parameter contracts, return types. Gate: blocks `$build`
  until approved (same logic as §A). Added to `SPEC_blank.md`.
- MCP surface checklist in `$build` Pyplan Increment Checklist — 6 items covering
  decorator pattern, `Annotated` parameters, serializable returns, `result = _fn`
  assignment, agent independence, and §D entry update.
- Build-via-AI guardrails in `$build` — protocol for using Pyplan MCP's
  build/modify capabilities with SDAD discipline (Spec gate, increment announcement,
  approval, DECISIONS.md, $qa).
- MCP security checks in QA Layer 1 — OAuth token exposure (P0), parameter
  validation / code execution path (P1), minimum tool scope (P2).
- MCP tool quality checks in QA Layer 5 — decorator + assignment correctness,
  Annotated parameters, docstring precision, serialization, agent independence.
- `$verify` extension for Pyplan MCP projects — flags Pyplan MCP server as v1
  external dependency in §7; recommends version lock in §5.
- 4 new Behavior Rules for Pyplan MCP (Spec gate, increment discipline, §D gate,
  v1 dependency flag).

**Project Declaration**
- `PROJECT_PLATFORM: pyplan` now also activates `pyplan-mcp` skill and §D gate.

---

### Changed

- `$sdad` command updated to report v4.1.
- `$skills` updated: Pyplan x5 (added `pyplan-mcp`).
- `$specout` Pyplan sections updated: §D added as conditional section.
- `$spec` Pyplan block updated: §D conditional question added.
- `.claude/hooks/README.md` note updated — "v4.1 feature" reference removed.
- Footer of `CLAUDE.md` updated to v4.1.

---

### Notes

- Pyplan MCP server is v1 (first release as of 2026-06-04). Treat as an external
  dependency with potential API changes across Pyplan updates. Flag in §7.
- `pyplan-mcp` SKILL.md is delivered as `pyplan-mcp-SKILL.md` in the repo root
  because `.claude/` is write-protected in Cowork mode. Move it manually to
  `.claude/skills/pyplan/mcp/SKILL.md` during installation.
  The `install.ps1` / `install.sh` scripts should be updated to handle this path.
- Build-via-AI (Pyplan MCP's natural-language edit capability) is allowed with
  guardrails — Spec gate + increment discipline. Not blocked, not unrestricted.

---

## [4.0] — 2026

### Overview

SDAD v4.0 is a full rebuild around the native Claude Code architecture.
Skills, agents, and hooks live in `.claude/` and are loaded automatically
by Claude Code — no manual file copying or separate skill repos required.

---

### Added

**Core architecture**
- `CLAUDE.md` as the single methodology instruction file — replaces all prior
  scattered instruction formats
- `.claude/skills/` folder as the canonical location for specialist skill files
- `.claude/agents/` folder for isolated sub-agent definitions
- `.claude/hooks/` folder for future automated session management (inactive in v4.0)
- `SPEC_blank.md` as a versioned blank spec template distributed with the repo

**Commands**
- `$sdad` — methodology overview command
- `$pause compress` — session snapshot for cross-session state continuity
- `$flow` — project flow manager (`$flow [name]`, `$flow list`, `$flow run`, `$flow edit`)
- `$agent review` / `$agent test` / `$agent audit` — explicit sub-agent delegation
- `$docfinal` — retroactive documentation for projects built without SDAD
  (4-step: retroactive SPEC, AI Authorship Log, QA audit, lesson candidates)

**Specialist skills (always-on)**
- `ai-architect` — architecture decisions, LLM integration patterns, cost modeling
- `ai-engineer` — implementation quality, UI detection, docs standards

**Specialist skills (on-demand)**
- `security-reviewer` — API key exposure, PII, auth, injection vulnerabilities
- `qa-engineer` — test coverage, DoD compliance, acceptance criteria
- `compliance-reviewer` — auto-activated on Tier 2/3, regulation-specific variants
- `frontend` — UI components, React, Vue, dashboard design
- `brand-design` — Brand Token Sheet production, visual identity application
- `decision-architecture` — data architecture decisions, DW, staging, source selection
- `data-discovery` — data delta detection, field mismatches, source discrepancies

**Pyplan layer (4 skills)**
- `pyplan-diagram` — influence diagram, nodes, result= convention, pandas/xarray
- `pyplan-interfaces` — components, index sync, inputs, brand token application
- `pyplan-qa-platform` — Layer 7 QA checks (PP-XX findings), delivery conventions
- `pyplan-spec-context` — §0/§A/§B structure, reading order, delta handling rules

**Sub-agent definitions**
- `.claude/agents/code-reviewer.md` — architectural review agent
- `.claude/agents/test-generator.md` — test suite generation agent
- `.claude/agents/security-auditor.md` — security audit agent

**Spec structure**
- `§0 — Platform & Context` — platform declaration, activates skill sets
- `§A — Delta Log` — post-approval change tracking (standard projects)
- `§B — Open Questions` — unresolved questions before build approval
- `§C — Brand & Visual Identity` — optional section for client UI projects
  (ADR-006: positioned between §B and §1, omitted for backend-only projects)
- Pyplan-specific additions: `§A — Build Gate`, `§B — Living Model State`
  (prepend to §1–§13 when `PROJECT_PLATFORM: pyplan`)

**Compliance tiers**
- Tier 1 — Standard: internal tools, POCs, scripts
- Tier 2 — Business: SaaS, customer-facing, user data (auto-activates Compliance Reviewer)
- Tier 3 — Enterprise: regulated environments (blocks `$build` until §9 approved)
- Tier detection in Phase 0, confirmation in Phase 1

**Context budget monitoring**
- Soft warning at 50% context usage (informational)
- Hard warning at 65% — blocks new `$build` after current increment
- `$pause` always includes context budget %
- cc-status-line (`npx ccstatusline@latest`) as primary budget indicator

**Project scaffolding**
- `install.sh` — Mac/Linux methodology installer (6 steps)
- `install.ps1` — Windows PowerShell installer (6 steps)
- `project-init.sh` — Mac/Linux project initializer
- `project-init.ps1` — Windows project initializer
  Creates: `SPEC.md`, `LESSON_LIBRARY.md`, `DECISIONS.md`, `.sdad/project.md`, `.sdad/flows/`

**HUB BLOCK**
- Auto-generated after every `$build` increment
- Written to `DECISIONS.md` in the repo root
- Fields: Date, Increment, Model, Decision, Rationale, Alternatives, Impact

**Lesson Library**
- `$lesson` command with filter and full-entry display
- `$lesson new` — guided entry creation
- Post-`$qa` lesson capture — one candidate proposed when increment reveals
  a pattern worth capturing; silent otherwise
- Entries written directly to `LESSON_LIBRARY.md`

**Documentation set (Phase 5)**
- `docs/INSTALL_GUIDE_v4.html` — full installation and project init guide
- `docs/USAGE_AND_SHORTCUTS_v4.html` — all commands, phases, context budget reference
- `docs/ONBOARDING_PYPLAN_v4.html` — Pyplan project onboarding guide
- `docs/DEVELOPER_GUIDE_v4.html` — full methodology reference (HTML)
- `CHANGELOG.md` — this file

**ADRs locked in v4.0**
- ADR-001 — infra-core
- ADR-002 — pyplan-layer
- ADR-003 — repo-structure (single `sdad-v4` repo; `g7-pyplan-hub` merged here)
- ADR-004 — brand-design (transversal skill, Option B split — skill separate from core)
- ADR-005 — documentation format (human-readable → HTML5; machine-readable → MD)
- ADR-006 — SPEC §C Brand (§C positioned between §B and §1; optional section)

---

### Changed

- Repo consolidated: `g7-pyplan-hub` merged into `sdad-v4` — single repo for all projects
- Skills loaded natively by Claude Code from `.claude/skills/` — no manual activation required
- `$qa` now runs 4 standard layers (Security, Structure, Efficiency, Best Practices)
  plus Layer 5 for Pyplan projects (Platform) via `pyplan-qa-platform`
- SPEC.md generated by `$specout` and written directly to repo root — no manual paste step
- Compliance tier detected automatically in Phase 0, confirmed in Phase 1

---

### Removed

- Separate `g7-pyplan-hub` repo (content merged into `.claude/skills/pyplan/`)
- Manual skill activation instructions (replaced by `.claude/` native loading)

---

### Notes

- Hooks (`.claude/hooks/`) are prepared but inactive in v4.0.
  Automated session management is planned for v4.1.
  See `.claude/hooks/README.md` for developer setup instructions.
- Pyplan's native Analyst Agent is not a dependency — SDAD is self-sufficient.
- `$SM` (Simple Mode) referenced in verification table — defined in `CLAUDE.md`
  but not a methodology command; it is a developer shortcut.

---

G7 AI Development Methodology | SDAD v4.3
