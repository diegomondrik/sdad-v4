# G7 SDAD v5.2 — "Board Edition"
## Spec-Driven AI Development for Claude Code

SDAD is G7's development methodology for teams using Claude Code as their
primary AI development tool. It brings spec-first discipline, vertical
increments, integrated QA, compliance tiers, and a shared Lesson Library
to AI-assisted development. As of v5, the rules that matter most are enforced
in code — not merely requested in a prompt.

---

## What's new in v5.2

v5.2 adds `PROJECT_PLATFORM: board` as a first-class platform, mirroring the existing
Pyplan integration pattern. No changes to existing commands, SPEC.md format, or harness.
Fully backward-compatible with all v5.x and v4.x projects.

- **Board platform** — `PROJECT_PLATFORM: board` activates a four-skill stack
  (spec-context, data-model, capsule, qa-platform) automatically. Board-specific
  `$spec` questions, §E (Board Data Model) and §F (Board Capsule Structure) sections
  in SPEC.md, Board increment checklist in `$build`, and Board Layer 5 in `$qa`.
- **Existing project ingestion** — `$spec` on an existing Board project accepts
  Layout XML, CFG, CSV exports, and screenshots; auto-populates §E/§F marking
  inferred fields `[inferred]`. Optional Board Public API ingestion via OAuth2.
- **`$build` generates Board artefacts** — SQL Data Readers, Entity/Cube CSVs,
  Layout XML specs, and Procedure specs instead of generic code files.
- **Board QA Layer 5** — 10 named checks (DM-01..06, CP-01..05) covering Entity
  creation order, Algorithm syntax, Procedure placement, Step type misclassification,
  Cube sparsity, naming conventions, and API credential exposure (P0).
- **Harness fix** — `assert-claude-md.ps1` line-budget baseline changed from
  hardcoded `v4.3` to the most recent git tag. Enables the `+60 per release` rule
  to accumulate correctly across releases instead of hitting a fixed ceiling.

---

## What's new in v5.1

v5.1 hardens the CI harness introduced in v5.0. All changes are backward-compatible —
no command surface or SPEC.md format changes.

- **Server-side spec-gate (INC-1)** — the `checks/spec-gate-policy.{ps1,sh}` module
  extracts the gate logic into a shared policy file tested independently of the hook.
  `checks/spec-gate-ci.sh` runs it from the **base branch** ref on every pull request via
  `.github/workflows/sdad-gates.yml` — a PR can no longer neuter the gate it is being
  checked against (L-05 guardrail).
- **POSIX hardening (INC-2a)** — CI workflow, `ascii-ps1.sh`, and `spec-gate-ci.sh`
  hardened for strict POSIX shells; `gate-from-base` pattern wired into the workflow.
- **Hermetic eval scenarios (INC-2b)** — scenario 07 (pre-commit block) no longer
  depends on an installed `.git/hooks/pre-commit`; it constructs its own fixture, so the
  full suite passes on a clean CI runner (L-06 guardrail).
- **14 deterministic eval scenarios** — up from 12 in v5.0; scenarios 13
  (`claude-md-case`) and 14 (`ci-spec-gate-policy`) added.
- **Lessons L-05 and L-06** — CI gate self-neutering pattern and hermetic test
  requirement captured in `LESSON_LIBRARY.md`.

---

## What's new in v5.0

v5 is an identity change: from *prompt methodology* to *prompt + enforced
harness*. A v4.3 audit against harness-engineering theory (H = E, T, C, S, L, V)
found SDAD governing critical gates by instruction in the prompt rather than
enforcement in code. v5 moves them into code. **v4.x projects stay fully
compatible** — run `git tag v4.3` before pulling, then `apply-v5.ps1`.

- **Spec gate enforced in code (I1)** — a `PreToolUse` hook
  (`pre-tool-use-spec-gate`) refuses a code-file write/edit when `SPEC.md` is
  absent or unapproved. Allowlists docs, `.sdad/`, `.claude/`, and the
  `$docfinal` path; fails open (allow + log) on its own error. "Code without an
  approved Spec" becomes structurally impossible, not just discouraged.
- **Lesson-to-guardrail ratchet (I2)** — a captured lesson with a mechanically
  verifiable pattern now generates a check in `checks/`, not only a prose rule.
  First check: `ascii-ps1` (L-01), wired into `session-end` and a git
  `pre-commit` hook.
- **`$eval` — methodology self-evaluation (I3)** — the V component SDAD lacked.
  A `.sdad/eval/` golden dataset (12 deterministic scenarios + an LLM smoke)
  replays the methodology and flags regressions before release. Runs on any
  CLAUDE.md/skill change and as the release gate; SessionStart reminds when
  CLAUDE.md drifts from the last green run.
- **`$agent` liveness (I4)** — delegation goes through `.sdad/lib/agent-run`
  with a 600s timeout and an empty-output guard; it fails loud, never silent.
- **Typed §13 + error-recovery + atomic commits (I5, I6, I8)** — §13 rows use an
  8-column schema; a tool/test error sets `.sdad/HOLD_AUTOCOMMIT` and stops the
  increment cleanly; DECISIONS.md + §13 + SPEC.md commit atomically.
- **Harness skill** — a new on-demand `harness` skill carries the Control Layer
  detail (the H mapping, the Governance Axiom, `$eval`) so CLAUDE.md stays lean.
- **bash hooks (merged)** — the three session hooks now have POSIX `.sh` ports
  behind a `run-hook.sh` dispatcher; the new spec-gate ships a `.sh` variant too
  (macOS testing tracked in `docs/TASK_HOOKS_MACOS_PORT.md`).

## What's new in v4.3

- **Model & Effort Routing** — new CLAUDE.md section with a per-phase routing
  table using model-agnostic tiers (FRONTIER / STANDARD / ECONOMY). The 🧠 MODEL
  announcement line now fires at the start of `$spec`, `$specout`, `$qa full`,
  and `$docfinal` — not just `$build`. Only `$build` blocks on mismatch; other
  phases flag once and continue. The session never auto-switches — the developer
  runs `/model` + `/effort`.
- **Agent model pinning (Vía B)** — `code-reviewer` and `security-auditor` pin
  `model: opus · effort: high`; `test-generator` pins `model: sonnet · effort:
  medium` via agent frontmatter. Override per project as needed. Applied by
  running `apply-v4.3.ps1` once from the repo root.
- **security-reviewer skill** — referenced since v4.0 but never shipped; now a
  real SKILL.md (secrets, injection, auth, PII, severity discipline).
- **Developer Manual** — `docs/DEVELOPER_MANUAL_v4.3.html`: didactic guide to
  SDAD, SDAD for Pyplan, and day-to-day usage.
- **Project language** — the first `$spec` question asks English or Spanish;
  the answer (`PROJECT_LANGUAGE`) governs all interaction and generated
  documents for that project. Code stays in English.
- **Installer fixes** — `install.ps1` / `install.sh` now install `dev-setup` and
  `brand-design` skills, the agent HANDOFF template, and (Windows) the hook
  scripts + `settings.json` registration that v4.2 declared active but never
  shipped through the installer. Hooks remain Windows-only (PowerShell).
- **Brand Design skill discoverable** — now listed in CLAUDE.md on-demand skills
  and `$skills`.
- **Pyplan HTML Interfaces** — Pyplan's new full-page web interfaces (an
  `HTMLInterface` Python class with `@callback` methods + the `window.pyplan`
  bridge) are now covered across SDAD: increment checklist block, `$qa` Layer 5
  checks, Build-via-AI guardrails (AI-built interfaces default to HTML and are
  treated as increments), `pyplan/interfaces` skill section 11, `qa-platform`
  7.6, and a `$spec` interface-strategy question. Skill patches apply via
  `apply-v4.3-pyplan-html.ps1` (one-shot, self-deletes).
- **Document ingestion via MarkItDown** — binary client documents (PDF, docx,
  xlsx, pptx) are converted to Markdown with Microsoft MarkItDown before
  reading during `$spec`, §A diagnosis, and `$docfinal`. Local trusted files
  only; converted copies live in `.sdad/ingest/`.

## What's new in v4.2

- **Hooks activated** — `SessionStart`, `PreCompact`, and `SessionEnd` hooks are
  now live. Session state is auto-restored on resume; anchor snapshots survive
  compaction; whitelisted autocommit runs at session end.
- **COMPACT ANCHOR + `[LOCK]` convention** — `$pause compress` now emits a
  COMPACT ANCHOR with `[LOCK]`-tagged decisions that survive compaction and are
  re-injected at session start. Non-reopenable architectural decisions persist
  across sessions without developer intervention.
- **MCP-vs-CLI security gate** — the §7 MCP-vs-CLI evaluation now has a hard
  security gate: if a CLI wrapper introduces shell injection, credentials-in-argv,
  or fragile parsing risk, the vetted MCP is kept. This is a `[LOCK]` decision.
- **Project CLAUDE.md protocol** — `$build` step 5.5 proposes an update to the
  project's own `CLAUDE.md` after every structural increment. Keeps project-level
  rules in sync without duplicating SPEC.md content.
- **`$verify audit` (proactive mode)** — new trigger: Phase 0 when the project
  went >30 days without a `$build`. Proactively audits all dependencies against
  current docs, not just new ones.
- **Dev Setup skill** (on-demand) — links to live Claude Code docs for onboarding.
  Zero rot by design: no feature names or release dates transcribed inline.
- **Agent HANDOFF template** — sub-agents return a structured HANDOFF block
  (`.claude/agents/HANDOFF_TEMPLATE.md`) for clean result incorporation.
- **DECISIONS.md `[LOCK]` tagging** — decisions marked `[LOCK]` in `DECISIONS.md`
  are carried into the COMPACT ANCHOR; unlocked decisions are not.

## What's new in v4.1

- **Pyplan MCP support** — native integration with the Pyplan MCP server (v1).
  New `pyplan-mcp` skill, `§D` gate section, Build-via-AI guardrails, and
  MCP-specific QA checks across Layer 1 (Security) and Layer 5 (Platform).
- **§D — MCP Tools Catalog** — new conditional Spec section for projects that
  expose `@mcp_tool` nodes. Gate section: blocks `$build` until approved.

## What's new in v4.0

- **Native Claude Code architecture** — skills and agents live in `.claude/`
  and are loaded automatically by Claude Code. No manual file copying.
- **Specialized agents** — `$agent review`, `$agent test`, and `$agent audit`
  run in isolated context via dedicated agent definitions.
- **Pyplan layer** — four Pyplan-specific skills activate automatically on
  Pyplan projects. No separate methodology repo needed.
- **Transversal skills** — `decision-architecture` and `data-discovery` apply
  across all project types.
- **Single repo** — everything in `sdad-v4`. The separate `g7-pyplan-hub`
  repo was merged here.

---

## Install

### Mac / Linux

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/install.sh)
```

### Windows (PowerShell)

**Option A — paste directly (recommended):**

```powershell
$install = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/install.ps1" -UseBasicParsing).Content
Invoke-Expression $install
```

**Option B — download first:**

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/install.ps1" -OutFile "install-sdad.ps1"
powershell -ExecutionPolicy Bypass -File ".\install-sdad.ps1"
```

The installer checks and installs Node.js 18+, Claude Code, and
`ccstatusline` (context budget monitor) if missing.

---

## Start a new project

After installing, initialize each project repo:

### Mac / Linux

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/project-init.sh)
```

### Windows (PowerShell)

```powershell
$init = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/project-init.ps1" -UseBasicParsing).Content
Invoke-Expression $init
```

Creates `SPEC.md`, `LESSON_LIBRARY.md`, `DECISIONS.md`, and `.sdad/` in your repo.

---

## Status bar (once per machine)

```bash
npx ccstatusline@latest   # one-time TUI setup — enable Model, Thinking Effort, Context %, Cost, Git Branch
```

Writes `statusLine` into `~/.claude/settings.json`; the bar then renders
automatically inside every Claude Code session. After that, just run `claude`.

---

## Key commands

| Command | Phase | What it does |
|---------|-------|--------------|
| `$spec` | 1 | Guided requirements — one question at a time |
| `$specout` | 2 | Generate full 13-section Spec → writes SPEC.md |
| `$build [feature]` | 3 | Vertical increment with tests |
| `$qa` | 4 | Auto QA after each increment |
| `$qa review` | 4 | Manual QA — per-finding approval |
| `$qa full` | 4 | Full project audit |
| `$agent review [module]` | Any | Architectural review via isolated agent |
| `$agent test [module]` | Any | Test suite generation via isolated agent |
| `$agent audit [path]` | Any | Security audit via isolated agent |
| `$verify [lib]` | Any | Check dependency docs before coding |
| `$skills` | Any | View and activate specialist skills |
| `$lesson` | Any | View and manage the Lesson Library |
| `$pause` | Any | Session state — Spec, tier, budget, findings |
| `$pause compress` | Any | Generate snapshot for next session |
| `$eval` | Any | Methodology self-evaluation — replays the golden dataset (v5) |

---

## Compliance tiers

Detected in Phase 0, confirmed in Phase 1:

| Tier | For | Auto-activates |
|------|-----|----------------|
| Tier 1 — Standard | Internal tools, POCs, scripts | — |
| Tier 2 — Business | SaaS, customer-facing, user data | Compliance Reviewer |
| Tier 3 — Enterprise | Regulated environments, corporate IT | Compliance Reviewer (full) |

Tier 3 blocks `$build` until SPEC.md §9 is complete and approved.

---

## Active skills

Always on:

| Skill | Role |
|-------|------|
| 🏗️ AI Solutions Architect | Architecture decisions, LLM patterns, cost modeling |
| 🔧 AI Engineer | Implementation quality, UI detection, docs standards |

On-demand (loaded by trigger): 🔐 Security Reviewer, ✅ QA Engineer,
🎨 Frontend Engineer (suggested when UI detected in Phase 0), 🖌️ Brand Design,
Decision Architecture, Data Discovery, Dev Setup.

Auto-activated by tier: 🔒 Compliance Reviewer (Tier 2/3).

---

## Board projects

Skills activate automatically when `PROJECT_PLATFORM: board` is declared in SPEC.md §0:

| Skill | Activates when |
|-------|----------------|
| `board/spec-context` | Always on Board projects — drives $spec and §E/§F generation |
| `board/data-model` | Entity, Cube, Relationship, dimension, Algorithm, Data Reader work |
| `board/capsule` | Capsule, Screen, Procedure, Layout, Mask, Selector work |
| `board/qa-platform` | Board-specific QA checks (Layer 5) |

§E (Board Data Model) is a gate section: `$build` is blocked until §E is at least Draft.
Draft = analysis/optimization mode (existing projects). Approved = full `$build`.

---

## Pyplan projects

Skills activate automatically when `PROJECT_PLATFORM: pyplan` is declared
in SPEC.md §0:

| Skill | Activates when |
|-------|----------------|
| `pyplan/spec-context` | Always on Pyplan projects |
| `pyplan/diagram` | Node diagrams and data flow work |
| `pyplan/interfaces` | Input/output interfaces, forms, dashboards, HTML interfaces (callbacks + window.pyplan) |
| `pyplan/qa-platform` | Pyplan-specific QA checks |
| `pyplan/mcp` | `@mcp_tool`, MCP tools, §D, dynamic tools |

SDAD does not depend on Pyplan's native Analyst Agent. All methodology
features work standalone.

---

## Repo structure

```
sdad-v4/
├── CLAUDE.md                          # Core Claude Code config (v5.2)
├── SPEC_blank.md                      # Blank spec template
├── install.sh                         # Mac/Linux methodology installer
├── install.ps1                        # Windows methodology installer
├── project-init.sh                    # Mac/Linux project initializer
├── project-init.ps1                   # Windows project initializer
├── apply-v5.ps1                       # One-shot v5 migration (self-deletes)
├── README.md                          # This file
├── CHANGELOG.md                       # Version history
├── checks/                            # Lesson-to-guardrail ratchet (v5)
│   ├── ascii-ps1.ps1                  # L-01: tracked .ps1 must be pure ASCII
│   ├── ascii-ps1.sh
│   ├── spec-gate-policy.ps1           # L-05: shared gate policy (base-ref safe)
│   ├── spec-gate-policy.sh
│   ├── spec-gate-ci.sh                # CI runner — runs policy from base ref
│   └── claude-md-case.ps1 / .sh      # L-04: CLAUDE.md case check
├── .sdad/
│   ├── eval/                          # $eval golden dataset + runner (v5)
│   │   ├── run-eval.ps1
│   │   ├── llm-smoke.ps1              # release-gate only
│   │   └── scenarios/                 # 14 deterministic scenarios
│   └── lib/
│       └── agent-run.ps1 / .sh        # $agent liveness wrapper (600s timeout)
├── .claude/
│   ├── settings.json                  # Hook registration (incl. PreToolUse gate)
│   ├── skills/
│   │   ├── ai-architect/SKILL.md
│   │   ├── ai-engineer/SKILL.md
│   │   ├── harness/SKILL.md           # Control Layer detail (v5)
│   │   ├── security-reviewer/SKILL.md
│   │   ├── compliance/SKILL.md
│   │   ├── qa-engineer/SKILL.md
│   │   ├── frontend/SKILL.md
│   │   ├── brand-design/SKILL.md
│   │   ├── dev-setup/SKILL.md
│   │   ├── decision-architecture/SKILL.md
│   │   ├── data-discovery/SKILL.md
│   │   ├── pyplan/
│   │   │   ├── spec-context/SKILL.md
│   │   │   ├── diagram/SKILL.md
│   │   │   ├── interfaces/SKILL.md
│   │   │   ├── qa-platform/SKILL.md
│   │   │   └── mcp/SKILL.md
│   │   └── board/
│   │       ├── SKILL.md               # always-on for Board projects
│   │       ├── spec-context/SKILL.md  # $spec flows, §E/§F, file ingestion
│   │       ├── data-model/SKILL.md    # Entities, Cubes, Algorithms, SQL
│   │       ├── capsule/SKILL.md       # Screens, Procedures, Layouts, Masks
│   │       └── qa-platform/SKILL.md   # Layer 5 QA checks
│   ├── agents/
│   │   ├── code-reviewer.md
│   │   ├── test-generator.md
│   │   ├── security-auditor.md
│   │   └── HANDOFF_TEMPLATE.md
│   └── hooks/
│       ├── README.md                  # Hooks active since v4.2
│       ├── run-hook.sh                # Cross-platform dispatcher
│       ├── session-start.ps1 / .sh
│       ├── pre-compact.ps1 / .sh
│       ├── session-end.ps1 / .sh
│       └── pre-tool-use-spec-gate.ps1 / .sh   # Spec gate (v5)
└── docs/
    ├── SDAD_v5_WHAT_IS_SDAD.md / .html   # What SDAD is and why (v5)
    ├── SDAD_v5_INSTALL.md / .html         # v5 install guide
    ├── SDAD_v5_USER_GUIDE.md / .html      # v5 everyday-use guide
    ├── SDAD_Visual_Manual_v2.html         # Visual manual — diagrams + flows
    ├── sdad-harness-diagrams.html         # Harness engineering diagrams
    ├── DEVELOPER_MANUAL_v4.3.html
    ├── INSTALL_GUIDE_v4.html
    ├── USAGE_AND_SHORTCUTS_v4.html
    ├── DEVELOPER_GUIDE_v4.html
    └── ONBOARDING_PYPLAN_v4.html
```

> Note: the git pre-commit ratchet is installed into `.git/hooks/pre-commit`
> by `apply-v5.ps1` / the installers — it is not tracked by git itself.

---

## Verification

After installing, start `claude` and verify:

| Command | Expected |
|---------|----------|
| `$sdad` | All phases + active skills listed; version 5.2 |
| `$skills` | AI Architect, AI Engineer always active; on-demand skills available |
| `$spec` | First requirements question with proposed default (language first) |
| `$pause` | Session state including context budget |
| `$eval` | Golden-dataset scenarios run; pass/fail report returned (v5) |

---

## Documentation

| File | Contents |
|------|----------|
| `docs/SDAD_v5_WHAT_IS_SDAD.html` | **Start here** — what SDAD is, harness engineering, why governance-by-code |
| `docs/SDAD_v5_INSTALL.html` | v5.2 installation + migration guide |
| `docs/SDAD_v5_USER_GUIDE.html` | v5.2 everyday-use guide (the gate, ratchet, `$eval`, CI harness) |
| `docs/SDAD_Visual_Manual_v2.html` | Visual manual — diagrams and flows |
| `docs/sdad-harness-diagrams.html` | Harness engineering diagrams |
| `docs/DEVELOPER_MANUAL_v4.3.html` | Didactic manual: SDAD, SDAD for Pyplan, day-to-day usage |
| `docs/INSTALL_GUIDE_v4.html` | Full installation guide (v4.3) |
| `docs/USAGE_AND_SHORTCUTS_v4.html` | All commands and workflows |
| `docs/DEVELOPER_GUIDE_v4.html` | Full methodology reference |
| `docs/ONBOARDING_PYPLAN_v4.html` | Pyplan project onboarding guide |

The Markdown sources (`SDAD_v5_*.md`) are the machine-readable copies; the
`.html` files are the human-readable renders (ADR-005).

---

G7 AI Development Methodology | SDAD v5.2 "Board Edition"
