# CHANGELOG — SDAD
# G7 AI Development Methodology
# Spec-Driven AI Development for Claude Code

All notable changes to the SDAD methodology are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [5.2] — 2026-06-24

### Overview

SDAD v5.2 adds `PROJECT_PLATFORM: board` as a first-class platform, mirroring the Pyplan
integration pattern introduced in v4.0. No changes to existing commands, SPEC.md format,
or harness. Fully backward-compatible with all v5.x and v4.x projects.

Core theme: Board BI & Planning projects now follow the same spec-first workflow as Pyplan,
with platform-specific $spec questions, gate sections (§E, §F), increment checklist,
QA Layer 5, and four on-demand skills. The harness fix (`assert-claude-md.ps1` dynamic
baseline) enables the +60 lines/release rule to accumulate correctly across releases.

**Upgrade note:** fresh installs use v5.2 automatically. Existing v5.x checkouts: pull
`main` to get the Board skill stack and harness fix. No migration script needed — additive.

---

### Added

**Board platform support (INC-1 to INC-7)**
- `PROJECT_PLATFORM: board` in CLAUDE.md and SPEC_blank.md activates four skills
- `.claude/skills/board/SKILL.md` — always-on mental model (Data Model / Capsule layers,
  BR-03/BR-04/BR-05 business rules, artefact types, sub-skill routing)
- `.claude/skills/board/spec-context/SKILL.md` — `$spec` flows (new vs existing),
  §E/§F generation, Layout XML/CFG/CSV/screenshot ingestion, Board API OAuth2
- `.claude/skills/board/data-model/SKILL.md` — Entities/Relationships/Cubes/Data Readers/
  Algorithms with CSV+SQL artefact templates and BR-05 creation order enforcement
- `.claude/skills/board/capsule/SKILL.md` — Screens/Procedures/Layouts/Masks/Selectors/
  Data Entry with Procedure placement rules and Layout XML artefact template
- `.claude/skills/board/qa-platform/SKILL.md` — 10 named Layer 5 checks:
  DM-01..06 (Data Model) and CP-01..05 (Capsule), SEC-01 (P0 credential check)

**SPEC_blank.md additions**
- §E (Board Data Model) — gate section with Entities/Relationships/Cubes tables + Status field
- §F (Board Capsule Structure) — informational section with Capsules/Screens/Procedures tables

**CLAUDE.md additions (+60 lines, at budget limit)**
- `PROJECT_PLATFORM: board` option in project declaration block
- §E gate rule in Core Rules
- 4 Board skill entries in Active Skills (on-demand, triggered by context)
- BOARD PROJECTS block in `$spec` — 7 lines
- §E and §F in `$specout` additional sections
- `$build` Board gate + BOARD INCREMENT CHECKLIST (Data Model, Capsule, Artefact, Discovery)
- Layer 5 extended to Board projects (10 named checks)
- `$docfinal` detects Board alongside Pyplan
- 5 Board behavior rules
- Header/footer version bump v5.0 → v5.2

**install.ps1 / install.sh**
- 5 Board skill folders and files added to the download manifest

### Fixed

**Harness: `assert-claude-md.ps1` dynamic baseline (INC-8)**
- Changed hardcoded `v4.3` baseline tag to `git describe --tags --abbrev=0`
- The `+60 lines per release` [LOCK] now accumulates from the most recent tag,
  not a fixed v4.3 ceiling — enabling correct enforcement across future releases
- Error message includes the resolved baseline tag for traceability

### QA

`$eval` 14/14 PASS after INC-8 fix.

---

## [5.1] — 2026-06-16

### Overview

SDAD v5.1 hardens the CI harness introduced in v5.0. No command surface or SPEC.md
format changes — fully backward-compatible with all v5.0 and v4.x projects.

Core theme: a control that runs from the PR's own checkout can be neutered by that same PR.
v5.1 moves the spec-gate policy to a shared base-ref-safe module and wires it into a
GitHub Actions workflow, closes the hermetic test gap found in `$eval`, and captures two
new lessons.

**Upgrade note:** fresh installs use v5.1 automatically. Existing v5.0 checkouts: pull
`v5` (or `main` after merge) to get the new `checks/` files and workflow. No migration
script needed — all changes are additive.

---

### Added

**Server-side spec-gate + shared policy module (INC-1)**
- `checks/spec-gate-policy.ps1` and `checks/spec-gate-policy.sh` — the allowlist/deny
  logic extracted from the hook into a standalone testable module. Single source of truth
  for what the gate permits.
- `checks/spec-gate-ci.sh` — CI runner that checks out the policy file from the **base
  branch** ref and runs it against the PR diff. A PR cannot modify the policy that
  evaluates it.
- `.github/workflows/sdad-gates.yml` — GitHub Actions workflow: runs `ascii-ps1`,
  `claude-md-case`, and `spec-gate-ci` on every push and pull request. Provides the
  server-side enforcement layer (L-05 guardrail: base-ref isolation).

**Hermetic eval scenario 07 (INC-2b)**
- Scenario `07-precommit-blocks` now constructs its own `.git/hooks/pre-commit` fixture
  instead of depending on an installed one. Passes on a clean CI runner without any
  prior `install.ps1` run.

**Lessons L-05 and L-06**
- L-05 — A CI gate that runs repo-resident scripts from the PR checkout can be neutered
  by the same PR. Fix: run from base ref or protect via CODEOWNERS.
- L-06 — Self-tests must be hermetic: never depend on installed or machine state.
  A clean CI runner is itself the ratchet.

### Changed

- `checks/ascii-ps1.sh` and `checks/spec-gate-ci.sh` POSIX-hardened for strict shells
  (INC-2a): removed bashisms, fixed quoting, replaced `[[` with `[`.
- `.github/workflows/sdad-gates.yml` adds `gate-from-base` pattern to the CI step
  (INC-2a): checks out `$GITHUB_BASE_REF` before running `spec-gate-ci.sh`.
- `$eval` golden dataset grows from 12 to 14 deterministic scenarios:
  scenario 13 (`claude-md-case`) and 14 (`ci-spec-gate-policy`).

---

## [5.0] — 2026-06-13

### Overview

SDAD v5.0 "Harness Edition" is an identity change: from *prompt methodology* to
*prompt + enforced harness*. A v4.3 audit against harness-engineering theory
(H = E, T, C, S, L, V) found SDAD strong where it owns the layer — Context (C)
and State (S) — but governing critical gates by **instruction in the prompt**
rather than **enforcement in code**. v5 moves the rules that matter into code.

Three core moves:
- **Governance by code (I1, I2):** the Spec gate and the lesson ratchet become
  executable checks — a `PreToolUse` hook and a `checks/` directory — instead of
  prose a model can drift past.
- **Self-evaluation (I3):** SDAD gains the V component it lacked entirely — a
  golden dataset + `$eval` runner that detects methodology regressions before
  release instead of in a client project.
- **Hardening (I4–I9):** sub-agent liveness, typed §13, formal `$build`
  error-recovery state, model pinning, atomic state commits, and a CLAUDE.md
  reframe with a Control Layer skill.

**Upgrade note:** v4.x projects are fully compatible — no SPEC.md or command
surface breaks; an existing SPEC.md still loads and `$pause` reports correctly.
The only behavioral change is the new build gate, which is the point of v5.
Run `git tag v4.3` before pulling v5 to preserve prior state, then run
`apply-v5.ps1` (idempotent, ASCII, self-deleting) to apply the `.claude/` changes.

---

### Added

**PreTool spec-gate hook — governance by code (I1)**
- `pre-tool-use-spec-gate.ps1` / `.sh` registered on `PreToolUse` (matcher
  `Write|Edit`). Denies a code-file write/edit (exit 2 + message) when `SPEC.md`
  is absent or not marked `SPEC STATUS: APPROVED`. Allowlists `*.md`, `docs/`,
  `.sdad/`, `.claude/`, `hub/`, and the `$docfinal` path (`.sdad/DOCFINAL_ACTIVE`
  sentinel). Fails open (allow + `.sdad/gate.log` entry) on its own internal
  error — a broken guard never freezes the developer.
- "Code written without an approved Spec" becomes structurally impossible,
  independent of model compliance.

**Lesson-to-guardrail code ratchet (I2)**
- New `checks/` directory: a captured lesson with a mechanically verifiable
  pattern now generates a check, not only a prose rule.
- First check `checks/ascii-ps1.ps1` / `.sh` — fails when any tracked `.ps1`
  contains non-ASCII bytes (L-01, recurred twice). Wired into `session-end`
  (skip autocommit + warn on failure, fail-open) and `.git/hooks/pre-commit`
  (block the commit, deliberate hard stop).

**Methodology evaluation harness — the V component (I3, `$eval`)**
- `.sdad/eval/` golden dataset: a deterministic core of 12 scenarios (gate
  allow/deny/fail-open, ASCII check, pre-commit block, CLAUDE.md structural
  asserts, `$eval` self-regression, `$agent` timeout, typed §13, HOLD_AUTOCOMMIT)
  plus an LLM replay smoke (`llm-smoke.ps1`, release-gate only).
- `$eval` runner replays the dataset and emits a pass/fail report per scenario.
  Runs on any CLAUDE.md/skill change and as the release gate.
- SessionStart prints a non-blocking `$eval` reminder when `git hash-object
  CLAUDE.md` differs from the `.sdad/eval/last-run` stamp.

**`$agent` liveness wrapper (I4)**
- `.sdad/lib/agent-run.ps1` / `.sh` wraps `claude --print` with a 600s timeout
  and an empty/missing-output guard — on timeout exit 2, on empty output exit 1,
  never proceeds silently.

**Harness skill — Control Layer detail (I9)**
- `.claude/skills/harness/SKILL.md`: the H = (E, T, C, S, L, V) mapping of where
  SDAD enforces each function (code vs prompt), the Governance Axiom, and the
  `$eval` / ratchet / gate detail kept out of CLAUDE.md to respect the line budget.

**Hooks ported to bash — macOS/Linux support (merged into v5)**
- `session-start.sh`, `pre-compact.sh`, `session-end.sh` — 1:1 POSIX sh ports of
  the three PowerShell hooks, same safeguards (guarded ff-only pull, anchor
  snapshot, autocommit whitelist + HOLD sentinel, no empty commits).
- `run-hook.sh` — cross-platform dispatcher. `settings.json` registers one
  shell-form command per hook; on Windows it runs under Git Bash and delegates
  to the `.ps1` scripts, on macOS/Linux it runs the `.sh` ports.
- Test gate passed on macOS for the three legacy hooks: valid JSON (`jq`),
  unicode round-trip without mojibake, pull guard, hold sentinel, whitelist
  isolation, no empty commits, real-session integration.

**v5 documentation**
- Three new docs in Markdown (machine-readable) and HTML5 (human-readable) per
  ADR-005: `SDAD_v5_INSTALL`, `SDAD_v5_USER_GUIDE`, `SDAD_v5_WHAT_IS_SDAD`.

### Changed

**CLAUDE.md v5.0 reframe (I9)**
- New `$eval` command registered in Commands and `$sdad` overview. Governance
  Axiom added as a behavior rule ("hard gates live in code; prompt rules are the
  fallback, not the guarantee"). New behavior rules for I3–I8 enforcement.
  Version + footer bumped to 5.0. Net footprint +55 of the +60 budget.

**Typed §13 AI Authorship Log (I5)**
- §13 rows are now a structured 8-column schema: Increment · Feature · Model ·
  Effort · Files · Tests (pass/fail/count) · QA findings (count/max severity) ·
  Date. Locked by an `$eval` structural assert. Enables causal attribution across
  projects.

**`$build` error-recovery contract (I6)**
- On a tool/test error mid-increment: report → stop the increment cleanly →
  create `.sdad/HOLD_AUTOCOMMIT` → never autocommit, never enter an undefined
  retry loop. Recovery clears when the developer resumes. `session-end` honors
  the sentinel (eval-locked).

**Determinism and atomic state (I7, I8)**
- `$verify` / §5 record the exact model string used per release when
  reproducibility matters. DECISIONS.md + §13 + SPEC.md updates for one increment
  are committed as a single atomic commit (R6).

**Installers**
- `install.ps1` / `install.sh` and `project-init.ps1` / `.sh` now ship the
  PreTool spec-gate hook, the `checks/` scaffold, the `.sdad/eval/` seed, the
  `.sdad/lib/` agent wrapper, the `harness` skill, and the git pre-commit hook.

### Fixed

- CLAUDE.md line-budget `$eval` assert resolved the methodology filename
  case-insensitively — on disk it is `CLAUDE.md` but the assert looked for
  `Claude.md`, so the budget gate had never actually run. Now enforced.
- `install.ps1` and `project-init.ps1` made pure ASCII (L-01): the section signs
  and em-dashes in the generated SPEC template were re-templated to ASCII, not
  blind-replaced. The `checks/ascii-ps1` ratchet now reports zero violations.

### Known gaps (deferred)

- macOS testing of the new `.sh` spec-gate variant: shipped untested alongside a
  live `/compact` PreCompact verification — both tracked in
  `docs/TASK_HOOKS_MACOS_PORT.md`. Porting without a test environment risks
  repeating the L-01 class of bugs — deliberately deferred, not forgotten.
- LLM replay smoke runs as a release gate only (non-deterministic by nature),
  never as a daily/per-change gate.

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

**Pyplan HTML Interfaces support**
- Pyplan now ships HTML interfaces: a full-page web interface (HTML/CSS/JS)
  driven by an `HTMLInterface` Python class with `@callback` methods and the
  `window.pyplan` bridge — the DEFAULT type when an AI agent builds a screen.
  SDAD methodology is unchanged (Spec → Build → QA); the Pyplan surfaces were
  extended to cover it:
  - CLAUDE.md: new "HTML interface surface" block in the Pyplan increment
    checklist; HTML interface checks added to $qa Layer 5; Build-via-AI
    guardrails now explicitly cover AI-generated interfaces (each one is an
    increment); new behavior rule.
  - `pyplan/interfaces` skill: new section 11 — anatomy (callbacks, getters/
    mutators, set_input / set_form_values / get_nodes_to_refresh), window.pyplan
    bridge, data-pyplan-nodes traceability, sandbox constraints (no cookies/
    localStorage/iframe — state persists via the model), common errors, and a
    dedicated QA checklist (11.8). Component-vs-HTML routing guidance.
  - `pyplan/qa-platform` skill: new Layer 7.6 HTML interface checks.
  - `pyplan/spec-context` skill: $spec question 5 (interface strategy) and
    "Interface types" field in §5 architecture.
  - `pyplan/mcp` skill: Build-via-AI protocol step 7 (HTML interface checklist).
  - `.claude/` is write-protected in Cowork mode — skill patches ship as
    `apply-v4.3-pyplan-html.ps1` (one-shot, idempotent, self-deleting, ASCII).
  Source: https://docs.pyplan.com/user-guide/interfaces/html-interfaces

**Document ingestion via MarkItDown (CLAUDE.md)**
- New DOCUMENT INGESTION rule under $spec: binary source documents (PDF, docx,
  xlsx, pptx, .msg, images) are converted to Markdown with Microsoft MarkItDown
  before reading — structure-preserving and token-efficient. Applies to $spec,
  §A client diagnosis, and $docfinal input gathering. Converted files live in
  `.sdad/ingest/` (working copies, not deliverables). Security rule: local
  trusted files only (convert_local) — MarkItDown performs I/O with process
  privileges. Added to Complementary Tools.
  Source: https://github.com/microsoft/markitdown

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
- Status bar tool: CLAUDE.md said `npx cc-status-line@latest` — the npm package
  is `ccstatusline` (no hyphens). Docs also described it as a monitor kept open
  in a separate terminal; it is actually a one-time TUI setup that writes
  `statusLine` into `~/.claude/settings.json` and renders inside Claude Code.
  Corrected in CLAUDE.md, README, INSTALL_GUIDE, USAGE_AND_SHORTCUTS,
  DEVELOPER_GUIDE and DEVELOPER_MANUAL.

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

G7 AI Development Methodology | SDAD v5.1
