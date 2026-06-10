# G7 SDAD v4.3
## Spec-Driven AI Development for Claude Code

SDAD is G7's development methodology for teams using Claude Code as their
primary AI development tool. It brings spec-first discipline, vertical
increments, integrated QA, compliance tiers, and a shared Lesson Library
to AI-assisted development.

---

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
- **Installer fixes** — `install.ps1` / `install.sh` now install `dev-setup` and
  `brand-design` skills, the agent HANDOFF template, and (Windows) the hook
  scripts + `settings.json` registration that v4.2 declared active but never
  shipped through the installer. Hooks remain Windows-only (PowerShell).
- **Brand Design skill discoverable** — now listed in CLAUDE.md on-demand skills
  and `$skills`.

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

## Before every session

```bash
npx ccstatusline@latest   # terminal 1 — context %, model, cost, git branch
claude                    # terminal 2 — start Claude Code
```

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

## Pyplan projects

Skills activate automatically when `PROJECT_PLATFORM: pyplan` is declared
in SPEC.md §0:

| Skill | Activates when |
|-------|----------------|
| `pyplan/spec-context` | Always on Pyplan projects |
| `pyplan/diagram` | Node diagrams and data flow work |
| `pyplan/interfaces` | Input/output interfaces, forms, dashboards |
| `pyplan/qa-platform` | Pyplan-specific QA checks |
| `pyplan/mcp` | `@mcp_tool`, MCP tools, §D, dynamic tools |

SDAD does not depend on Pyplan's native Analyst Agent. All methodology
features work standalone.

---

## Repo structure

```
sdad-v4/
├── Claude.md                          # Core Claude Code config
├── SPEC_blank.md                      # Blank spec template
├── install.sh                         # Mac/Linux methodology installer
├── install.ps1                        # Windows methodology installer
├── project-init.sh                    # Mac/Linux project initializer
├── project-init.ps1                   # Windows project initializer
├── apply-v4.3.ps1                     # One-shot v4.3 migration (self-deletes)
├── README.md                          # This file
├── CHANGELOG.md                       # Version history
├── .claude/
│   ├── settings.json                  # Hook registration
│   ├── skills/
│   │   ├── ai-architect/SKILL.md
│   │   ├── ai-engineer/SKILL.md
│   │   ├── security-reviewer/SKILL.md
│   │   ├── compliance/SKILL.md
│   │   ├── qa-engineer/SKILL.md
│   │   ├── frontend/SKILL.md
│   │   ├── brand-design/SKILL.md
│   │   ├── dev-setup/SKILL.md
│   │   ├── decision-architecture/SKILL.md
│   │   ├── data-discovery/SKILL.md
│   │   └── pyplan/
│   │       ├── spec-context/SKILL.md
│   │       ├── diagram/SKILL.md
│   │       ├── interfaces/SKILL.md
│   │       ├── qa-platform/SKILL.md
│   │       └── mcp/SKILL.md
│   ├── agents/
│   │   ├── code-reviewer.md
│   │   ├── test-generator.md
│   │   ├── security-auditor.md
│   │   └── HANDOFF_TEMPLATE.md
│   └── hooks/
│       ├── README.md                  # Hooks active since v4.2 (Windows/PowerShell)
│       ├── session-start.ps1
│       ├── pre-compact.ps1
│       └── session-end.ps1
└── docs/
    ├── DEVELOPER_MANUAL_v4.3.html     # Didactic manual — SDAD + Pyplan + usage
    ├── INSTALL_GUIDE_v4.html
    ├── USAGE_AND_SHORTCUTS_v4.html
    ├── DEVELOPER_GUIDE_v4.html
    └── ONBOARDING_PYPLAN_v4.html
```

---

## Verification

After installing, start `claude` and verify:

| Command | Expected |
|---------|----------|
| `$sdad` | All phases + active skills listed |
| `$skills` | AI Architect, AI Engineer, Security Reviewer, QA Engineer active |
| `$spec` | First requirements question with proposed default |
| `$pause` | Session state including context budget |
| `$SM hello` | ⚡ SIMPLE MODE — prompt returned immediately |

---

## Documentation

| File | Contents |
|------|----------|
| `docs/DEVELOPER_MANUAL_v4.3.html` | **Start here** — didactic manual: SDAD, SDAD for Pyplan, day-to-day usage |
| `docs/INSTALL_GUIDE_v4.html` | Full installation guide |
| `docs/USAGE_AND_SHORTCUTS_v4.html` | All commands and workflows |
| `docs/DEVELOPER_GUIDE_v4.html` | Full methodology reference |
| `docs/ONBOARDING_PYPLAN_v4.html` | Pyplan project onboarding guide |

---

G7 AI Development Methodology | SDAD v4.3
