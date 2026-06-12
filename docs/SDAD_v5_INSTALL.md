# SDAD v5 — Installation Guide

**G7 AI Development Methodology · SDAD v5 "Harness Edition"**

> This guide documents the v5 install target. Some v5 components (the PreTool spec-gate
> hook, the `checks/` ratchet, the `.sdad/eval/` harness) are produced by the v5 build
> driven by `SDAD_v5_BUILD_BRIEF.md`. Steps that depend on a not-yet-built artifact are
> marked **[built in v5]**. Until the build runs, the v4.3 installer remains valid.

---

## 0. What you are installing

SDAD ships in two layers, same as prior versions:

- **Methodology install** (`install.ps1` / `install.sh`) — places the SDAD config and the
  `.claude/` folder (skills, agents, hooks) so Claude Code loads them automatically. Run
  once per machine, refreshed per version.
- **Project init** (`project-init.ps1` / `project-init.sh`) — scaffolds a single repo with
  `SPEC.md`, `LESSON_LIBRARY.md`, `DECISIONS.md`, and `.sdad/`. Run once per project.

v5 adds three new pieces on top of v4.3: a `PreToolUse` spec-gate hook, a `checks/`
directory for the lesson ratchet, and a `.sdad/eval/` golden-dataset evaluation harness.

---

## 1. Prerequisites

- **Node.js 18+** and **Claude Code** — the installer checks for these and installs them
  if missing.
- **Windows with PowerShell** for the hook layer. Hooks are Windows/PowerShell only; the
  macOS/bash port is tracked in `docs/TASK_HOOKS_MACOS_PORT.md`. On macOS/Linux the
  methodology works fully; the hook-based enforcement (including the v5 spec-gate) waits
  on that port.
- **ccstatusline** — the context-budget status bar, configured once per machine.

---

## 2. Install the methodology

### Windows (PowerShell) — recommended

```powershell
$install = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/install.ps1" -UseBasicParsing).Content
Invoke-Expression $install
```

Or download first, then run:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/install.ps1" -OutFile "install-sdad.ps1"
powershell -ExecutionPolicy Bypass -File ".\install-sdad.ps1"
```

### Mac / Linux

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/install.sh)
```

The installer checks/installs Node.js 18+, Claude Code, and ccstatusline, and places the
SDAD skills, agents, the agent HANDOFF template, and the hook scripts plus their
`settings.json` registration. `settings.json` is never overwritten if it already exists.

---

## 3. Apply the v5 migration  **[built in v5]**

Because `.claude/` is write-protected in Cowork mode, v5's changes to hooks, skills, and
`settings.json` ship as a one-shot script — the same pattern as `apply-v4.3.ps1`.

```powershell
# from the repo root, after pulling v5
git tag v4.3            # preserve prior state before upgrading
powershell -ExecutionPolicy Bypass -File ".\apply-v5.ps1"
```

`apply-v5.ps1` is idempotent, pure ASCII, and self-deletes after a successful run. It:

- installs `pre-tool-use-spec-gate.ps1` and registers it on `PreToolUse` in `settings.json`;
- scaffolds the `checks/` directory and the first ratchet check (`ascii-ps1`);
- seeds `.sdad/eval/` with the golden-dataset scenarios and the `$eval` runner;
- bumps skill/agent version stamps to 5.0.

If you are on a fresh machine, the updated `install.ps1` / `install.sh` already include
these — you only need `apply-v5.ps1` when upgrading an existing v4.3 checkout.

---

## 4. Initialize a project

### Windows (PowerShell)

```powershell
$init = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/project-init.ps1" -UseBasicParsing).Content
Invoke-Expression $init
```

### Mac / Linux

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/project-init.sh)
```

Creates `SPEC.md`, `LESSON_LIBRARY.md`, `DECISIONS.md`, and `.sdad/` in the repo. In v5 it
also scaffolds the `checks/` directory and a `.sdad/eval/` seed so the ratchet and the
evaluation harness are available per project.

---

## 5. Configure the status bar (once per machine)

```bash
npx ccstatusline@latest
```

Enable the Model, Thinking Effort, Context %, Session Cost, and Git Branch widgets. This
is a one-time TUI setup that writes `statusLine` into `~/.claude/settings.json`; the bar
then renders inside every Claude Code session. Use it as your primary context-budget
indicator — it shows the 50% and 65% thresholds SDAD acts on.

---

## 6. What the new hooks do

| Hook | Event | What it does |
|---|---|---|
| `session-start.ps1` | SessionStart | Re-injects the COMPACT ANCHOR (locked decisions) and does a guarded fast-forward `git pull`. Survives compaction. |
| `pre-compact.ps1` | PreCompact | Writes the anchor snapshot to disk so SessionStart can re-inject it after compaction. |
| `session-end.ps1` | SessionEnd | Whitelisted autocommit of `DECISIONS.md` + `LESSON_LIBRARY.md` only — never code. Skipped if `.sdad/HOLD_AUTOCOMMIT` exists. |
| `pre-tool-use-spec-gate.ps1` **[built in v5]** | PreToolUse | Refuses a code-file write/edit when `SPEC.md` is absent or unapproved. Allowlists docs, `.sdad/`, the SDAD docs, and the `$docfinal` path. Fails open (allows + logs) if the gate itself errors. |

To pause autocommit during an open P0 finding or a failing increment, create an empty file
`.sdad/HOLD_AUTOCOMMIT`; delete it to resume.

---

## 7. Verify the install

Start `claude` in a project and check:

| Command | Expected |
|---|---|
| `$sdad` | All phases + active skills listed; version 5.0 |
| `$skills` | AI Architect and AI Engineer active; on-demand skills available |
| `$spec` | First question asks project language (English/Spanish) |
| `$pause` | Session state including context budget % |
| `$eval` **[built in v5]** | Golden-dataset scenarios run; pass/fail report returned |

To confirm the v5 gate is live, in a repo with no approved `SPEC.md` ask Claude to write a
code file — it should be refused by `pre-tool-use-spec-gate.ps1`. Editing a doc under
`docs/` should still be allowed.

---

## 8. Upgrading from v4.3

```powershell
git tag v4.3            # preserve prior state
git pull                # fetch v5
powershell -ExecutionPolicy Bypass -File ".\apply-v5.ps1"
```

v4.3 projects are compatible: existing `SPEC.md` files still load and all commands keep
working. The only behavioral change you will notice is the new build gate — which is the
point of v5.

---

G7 AI Development Methodology | SDAD v5 Install Guide | 2026
