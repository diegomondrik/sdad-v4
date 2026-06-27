# SDAD v6.0 — Installation Guide

**G7 AI Development Methodology · SDAD v6.0 "Pyplan Audit Edition"**

---

## 0. What you are installing

SDAD ships in two layers:

- **Methodology install** (`install.ps1` / `install.sh`) — places CLAUDE.md and the
  `.claude/` folder (skills, agents, hooks, settings) so Claude Code loads them automatically.
  Run once per machine, refreshed per version.
- **Project init** (`project-init.ps1` / `project-init.sh`) — scaffolds a single repo with
  `SPEC.md`, `LESSON_LIBRARY.md`, `DECISIONS.md`, and `.sdad/`. Run once per project.

v6 adds on top of v5: the `$audit` lifecycle, four new skills (pyplan-audit, business-alignment,
domain-finance, domain-supply-chain), eight new ratchet checks, 10 new eval scenarios (total 22),
and the `.sdad/audit/` evidence workspace.

---

## 1. Prerequisites

- **Node.js 18+** and **Claude Code** — the installer checks for both and installs if missing.
- **Git** — the installer checks for a git repo and initializes one if needed.
- **ccstatusline** — the context-budget status bar, configured once per machine (see section 5).
- **Windows with PowerShell** for the hook layer. The `.sh` variants work fully on macOS/Linux.

---

## 2. Install the methodology (fresh machine)

### Windows (PowerShell)

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

The installer places the SDAD skills, agents, hooks, `settings.json`, ratchet checks,
eval golden dataset, audit library, and Pyplan MCP registration. `settings.json` is never
overwritten if it already exists.

---

## 3. Apply the v6 migration (upgrading from v5.x)

Because `.claude/` is write-protected in Cowork mode, v6 changes ship as a one-shot,
idempotent, self-deleting script — same pattern as prior `apply-vX.*` scripts.

```powershell
# from the repo root, after pulling v6
git tag v5.2            # preserve prior state before upgrading
git pull                # fetch v6
powershell -ExecutionPolicy Bypass -File ".\apply-v6.ps1"
```

```bash
# Mac / Linux
git tag v5.2
git pull
bash apply-v6.sh
```

`apply-v6.*` is idempotent and self-deletes after a successful run. It:

- installs the four new skills (pyplan-audit, business-alignment, domain-finance, domain-supply-chain);
- installs the pyplan-mcp skill (previously documented but unbuilt);
- adds eight new ratchet checks to `checks/`;
- seeds `.sdad/audit/` with the evidence library and schema;
- seeds `.sdad/eval/` with scenarios 13-22 (audit behavioral coverage);
- refreshes updated agent and eval files.

If you are on a fresh machine, the updated `install.*` already includes the full v6 file set.
You only need `apply-v6.*` when upgrading an existing v5.x checkout.

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

Creates `SPEC.md`, `LESSON_LIBRARY.md`, `DECISIONS.md`, `.sdad/` (including `.sdad/audit/`),
and seeds the full v6 harness layer (checks, eval scenarios, audit library).

**Pyplan project flag:** add `-Pyplan` (Windows) or `--pyplan` (bash) to also scaffold
`.sdad/pyplan-snapshots/` for model version snapshots.

---

## 5. Configure the status bar (once per machine)

```bash
npx ccstatusline@latest
```

Enable the Model, Thinking Effort, Context %, Session Cost, and Git Branch widgets.
This writes `statusLine` into `~/.claude/settings.json` and renders the bar in every session.
Use it as your primary context-budget indicator — SDAD acts at the 50% and 65% thresholds.

---

## 6. What the hooks do

| Hook | Event | What it does |
|------|-------|--------------|
| `session-start.*` | SessionStart | Re-injects the COMPACT ANCHOR (locked decisions); guarded fast-forward `git pull`. Survives compaction. |
| `pre-compact.*` | PreCompact | Writes the anchor snapshot to disk so SessionStart can re-inject after compaction. |
| `session-end.*` | SessionEnd | Whitelisted autocommit of `DECISIONS.md` + `LESSON_LIBRARY.md` only. Skipped if `.sdad/HOLD_AUTOCOMMIT` exists. |
| `pre-tool-use-spec-gate.*` | PreToolUse | Refuses a code-file write/edit when `SPEC.md` is absent or unapproved. Allowlists docs, `.sdad/`, `$docfinal` path, and `$audit` path (`.sdad/AUDIT_ACTIVE`). Fails open (allows + logs) if the gate itself errors. |

To pause autocommit during an open finding or a failing increment, create `.sdad/HOLD_AUTOCOMMIT`;
delete it to resume.

---

## 7. Verify the install

Start `claude` in a project and check:

| Command | Expected |
|---------|----------|
| `$sdad` | All phases + active skills listed; version 6.0 |
| `$skills` | AI Architect and AI Engineer active; pyplan-audit, business-alignment, domain profiles available |
| `$spec` | First question asks project language (English/Spanish) |
| `$pause` | Session state including context budget % |
| `$eval` | 22 deterministic scenarios run; pass/fail report returned |

To confirm the spec-gate is live, in a repo with no approved `SPEC.md` ask Claude to write a
code file — it should be refused. Editing a doc under `docs/` should still be allowed.
To confirm the `$audit` path is open, check that `.sdad/AUDIT_ACTIVE` creation is not blocked.

---

## 8. Upgrading from v5.2

```powershell
git tag v5.2
git pull
powershell -ExecutionPolicy Bypass -File ".\apply-v6.ps1"
```

v5.x projects are compatible: existing `SPEC.md` files still load, all prior commands keep
working. New capabilities (pyplan-audit, business-alignment, domain profiles) activate when
their trigger matches — they do not change existing project behavior.

---

G7 AI Development Methodology | SDAD v6.0 Install Guide | 2026
