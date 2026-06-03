# CHANGELOG — SDAD
# G7 AI Development Methodology
# Spec-Driven AI Development for Claude Code

All notable changes to the SDAD methodology are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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

G7 AI Development Methodology | SDAD v4.0
