# G7 SDAD v4.1
## Spec-Driven AI Development for Claude Code

SDAD is G7's development methodology for teams using Claude Code as their
primary AI development tool. It brings spec-first discipline, vertical
increments, integrated QA, compliance tiers, and a shared Lesson Library
to AI-assisted development.

---

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

## Active skills (always on)

| Skill | Role |
|-------|------|
| 🏗️ AI Solutions Architect | Architecture decisions, LLM patterns, cost modeling |
| 🔧 AI Engineer | Implementation quality, UI detection, docs standards |
| 🔐 Security Reviewer | API key exposure, injection, PII, auth vulnerabilities |
| ✅ QA Engineer | Test coverage, DoD compliance, acceptance criteria |

Auto-activated by tier: 🔒 Compliance Reviewer (Tier 2/3).

On-demand: Frontend Engineer (suggested when UI detected in Phase 0).

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
├── README.md                          # This file
├── CHANGELOG.md                       # Version history
├── .claude/
│   ├── skills/
│   │   ├── ai-architect/SKILL.md
│   │   ├── ai-engineer/SKILL.md
│   │   ├── compliance/SKILL.md
│   │   ├── qa-engineer/SKILL.md
│   │   ├── frontend/SKILL.md
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
│   │   └── security-auditor.md
│   └── hooks/
│       └── README.md                  # Inactive in v4.0
└── docs/
    ├── INSTALL_GUIDE_v4.md
    ├── USAGE_AND_SHORTCUTS_v4.md
    ├── DEVELOPER_GUIDE_v4.docx
    └── ONBOARDING_PYPLAN_v4.md
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
| `docs/INSTALL_GUIDE_v4.md` | Full installation guide |
| `docs/USAGE_AND_SHORTCUTS_v4.md` | All commands and workflows |
| `docs/DEVELOPER_GUIDE_v4.docx` | Full methodology reference |
| `docs/ONBOARDING_PYPLAN_v4.md` | Pyplan project onboarding guide |

---

G7 AI Development Methodology | SDAD v4.1
