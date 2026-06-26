# SDAD — Pyplan Model Versioning Patch
# Build Brief for Claude Code
# G7 AI Development Methodology
# Version: patch on SDAD v5.2 (no version bump)
# Date: 2026-06-25
# Author: prepared from workflow analysis session

---

## 0. Context and motivation

When working with Pyplan MCP, SDAD manages two separate state layers:

- **Methodology state** (SPEC.md, DECISIONS.md, LESSON_LIBRARY.md) — versioned in git
  by the SessionEnd hook. Well covered.
- **Pyplan application state** (nodes, interfaces, model logic) — lives in Pyplan's
  cloud workspace. Modified directly by the MCP. NOT in git.

The gap: after a Build-via-AI increment, git has the *record* of the change
(DECISIONS.md, §13) but not the *artifact* (the model itself). If the Pyplan workspace
is corrupted or lost, there is no recovery path from the repo.

The fix is a single convention: export the Pyplan model after each Build-via-AI
increment and commit the export file alongside DECISIONS.md. The `.ppl` files committed
to git become the local backup. No GitHub required for this protection.

> Scenario without GitHub: steps 1-4 below; the committed `.ppl` files are the backup.
> Scenario with personal GitHub: add step 5 (push); the remote is a second copy.

This patch touches: `.gitignore`, `project-init` scripts, `CLAUDE.md`,
`pyplan/mcp SKILL.md`, `SDAD_v5_USER_GUIDE.md`, and `SDAD_v6_BUILD_BRIEF.md`.
It does NOT bump the SDAD version number — it is a behavior patch to v5.2.

---

## 1. Hard constraints

All constraints from SDAD v5.2 CLAUDE.md carry forward. Patch-specific:

1. All `.ps1` and `.sh` scripts must be pure ASCII (L-01, ratcheted in `checks/ascii-ps1`).
2. CLAUDE.md net line budget: this patch must stay within the existing +60 per release
   budget. Target delta for this patch: +10 lines maximum inline; the rest goes into the
   skill file.
3. The pyplan-snapshots folder lives under `.sdad/` — the .gitignore currently ignores
   `.sdad/*` with exceptions only for `eval/` and `lib/`. This patch adds a third
   exception: `pyplan-snapshots/`.
4. The export step is conditional on PROJECT_PLATFORM: pyplan. Do not add it to the
   general $build flow.
5. The export filename convention must be deterministic and sortable:
   `YYYYMMDD-incN-slug.ppl` (e.g. `20260625-inc3-revenue-nodes.ppl`).
6. Do not break the v5.2 eval golden dataset. Run `$eval` after I3 closes.

---

## 2. New workflow (what the developer does)

After each Build-via-AI increment closes ($qa passed):

1. MCP modifies the model (increment announced and approved per existing protocol)
2. `$qa` on the increment — must pass before export
3. **Export the Pyplan model** from the Pyplan UI or via MCP if the endpoint exists
   → save as `.sdad/pyplan-snapshots/YYYYMMDD-incN-slug.ppl`
4. **Atomic commit:** DECISIONS.md + §13 update + the `.ppl` snapshot — one commit per
   increment
5. *(Optional — only with a remote configured)* `git push`

The `.ppl` files committed in `.sdad/pyplan-snapshots/` are the version history of the
model. Any prior increment's model state is recoverable by loading its `.ppl` in Pyplan.

**Note on export mechanism (v1 server):** Pyplan MCP v1 may not expose an export
endpoint. If it does not, the export is a manual step in the Pyplan UI. The CLAUDE.md
rule and skill documentation must reflect this uncertainty — "export via MCP if available,
otherwise via the Pyplan UI."

---

## 3. Increments (ordered build plan)

Each increment: announce -> confirm model/effort -> write -> run `$eval` where noted ->
`$qa` -> DECISIONS.md entry -> §13 update -> atomic commit.

---

### I1 — .gitignore: enable pyplan-snapshots tracking

**Files:** `.gitignore`

**Change:** add a third exception under the `.sdad/*` rule so that
`.sdad/pyplan-snapshots/` is tracked by git.

```
# .gitignore — add after !.sdad/lib/
!.sdad/pyplan-snapshots/
```

**Tests:** after the change, create `.sdad/pyplan-snapshots/test.ppl` and confirm
`git status` shows it as an untracked file (i.e. not ignored). Delete the test file.

**Risk:** low. Additive only — no existing tracked files affected.

---

### I2 — project-init: scaffold pyplan-snapshots folder on Pyplan projects

**Files:** `project-init.ps1`, `project-init.sh`

**Change:** when the init script detects `PROJECT_PLATFORM: pyplan` (or receives a
`--pyplan` flag), create `.sdad/pyplan-snapshots/.gitkeep` so the folder exists and is
tracked from day one.

The detection heuristic: look for a CLAUDE.md in the repo root containing the string
`PROJECT_PLATFORM: pyplan` (uncommented). If not found, skip silently — do not create
the folder for non-Pyplan projects.

If the init script does not currently support platform detection, add a `--pyplan` flag
that the developer passes explicitly. Document it in the usage block at the top of the
script.

**Pure ASCII rule applies.** Both `.ps1` and `.sh` must pass the `checks/ascii-ps1`
ratchet.

**Tests:** run `project-init.ps1 --pyplan` (or `.sh`) in a scratch folder; confirm
`.sdad/pyplan-snapshots/.gitkeep` is created. Run without `--pyplan`; confirm the
folder is NOT created.

---

### I3 — CLAUDE.md: Build-via-AI Protocol + Pyplan checklist + QA Layer 5

**Files:** `CLAUDE.md`

**Change 1 — Build-via-AI Protocol (the 7-step block under "BUILD-VIA-AI GUARDRAILS"):**

Add a new step after the current step 5 (`Run $qa`):

```
5.5. PYPLAN MODEL SNAPSHOT: After $qa passes, export the current Pyplan model to
     .sdad/pyplan-snapshots/YYYYMMDD-incN-slug.ppl (via MCP export endpoint if
     available; otherwise via the Pyplan UI). Include the snapshot in the atomic
     commit for this increment alongside DECISIONS.md and the §13 update.
```

**Change 2 — Pyplan increment checklist (the block that runs after step 4 on Pyplan
projects):** add at the end of the checklist, under a new heading:

```
  Versioning:
    □ Model exported to .sdad/pyplan-snapshots/ with correct naming convention
    □ Snapshot included in this increment's atomic commit
```

**Change 3 — $qa Layer 5 MCP checks:** add one check at the end of the MCP surface
section:

```
    □ Pyplan model snapshot present in .sdad/pyplan-snapshots/ for this increment
      (filename matches YYYYMMDD-incN pattern; committed in the increment's atomic
      commit)
```

**Change 4 — Behavior Rules:** add one rule at the end of the Pyplan block:

```
- ON PYPLAN PROJECTS WITH MCP: after each Build-via-AI increment's $qa passes,
  export the model snapshot before committing — increment is not complete without it.
```

**Line budget check:** count the net delta before committing. Must be under the
remaining budget for this patch (target: ≤ +10 inline lines; move any explanatory
prose to the skill file if needed).

**Tests:** run `$eval`. All existing scenarios must pass. Inspect the CLAUDE.md diff
to confirm the four changes are present and no unintended lines were modified.

---

### I4 — pyplan/mcp SKILL.md: export convention + QA integration update

**Files:** `.claude/skills/pyplan/mcp/SKILL.md`

**Change 1 — Build-via-AI Protocol section:** expand step 5 to match the new CLAUDE.md
step 5.5. Add a new subsection:

```
### Model Snapshot Convention

After $qa passes on a Build-via-AI increment, export the Pyplan model:

  Path:    .sdad/pyplan-snapshots/YYYYMMDD-incN-slug.ppl
  Naming:  date in YYYYMMDD · inc + zero-padded number · short feature slug
  Example: .sdad/pyplan-snapshots/20260625-inc03-revenue-nodes.ppl

Export mechanism (Pyplan MCP v1):
  - If the MCP exposes an export/snapshot endpoint: use it and note the endpoint
    name in §7.
  - If not (v1 current behavior): export manually from the Pyplan UI before
    committing. The step is still mandatory.

The snapshot is committed in the same atomic commit as DECISIONS.md and the §13
update. One commit = one increment = one known model state.

Recovery: to restore a prior increment's model state, load the corresponding
.ppl file in Pyplan. Git history gives the full restore timeline.
```

**Change 2 — $qa Integration section:** add to Layer 5 checks:

```
- Snapshot: .sdad/pyplan-snapshots/ contains a .ppl file for this increment,
  named correctly, present in the staged commit
```

**Change 3 — $verify section:** update the Pyplan MCP dependency note to add:

```
  Export capability: check whether the installed Pyplan version exposes a model
  export endpoint via MCP. If yes, document it in §7 and use it in the snapshot
  step. If not, the export is manual (UI).
```

**Tests:** read the updated SKILL.md; confirm the three sections are consistent with
CLAUDE.md I3 changes. No automated test for skill files — review is the gate.

---

### I5 — docs/SDAD_v5_USER_GUIDE.md: add Pyplan model versioning section

**Files:** `docs/SDAD_v5_USER_GUIDE.md`

**Change:** add a new section after the current section 6 ("Good habits"), before
section 7 ("If something feels stuck"). Renumber section 7 to section 8.

New section content:

```
## 7. Pyplan projects — keeping your model in version control

On Pyplan projects, every Build-via-AI increment changes the application logic
directly inside your Pyplan instance. SDAD tracks *what* changed in DECISIONS.md,
but the actual model file lives in Pyplan's workspace — not in git — until you
export it.

After $qa passes on each increment, export the model and commit it:

1. Export the model from the Pyplan UI (or via the MCP export endpoint if your
   Pyplan version supports it).
2. Save the file to `.sdad/pyplan-snapshots/` using the naming convention SDAD
   proposes: `YYYYMMDD-incN-slug.ppl`.
3. Include it in the atomic commit for the increment.

The committed `.ppl` files are your version history of the model. If the Pyplan
workspace is lost or corrupted, you can restore any prior increment's state by
loading its `.ppl` file. No GitHub required — local git commits are sufficient.

If you do have a remote (GitHub, GitLab, or a backup remote), push after each
session for an off-machine copy.
```

**Tests:** read the updated file; confirm section numbering is consistent, the
Pyplan section is Pyplan-specific (no mention of general $build flow), and the
content matches I3 and I4.

---

### I6 — SDAD_v6_BUILD_BRIEF.md: add Ix and update I4 / I9 notes

**Files:** `SDAD_v6_BUILD_BRIEF.md`

**Change 1 — add new increment Ix** after I3 (before I4), as a P0-equivalent for
Pyplan portfolio deployments:

```
### Ix — Pyplan model versioning as first-class git convention — P0 (Pyplan)
**Component:** S (state management) for Pyplan platform layer.
**Problem:** v5.2 documents Build-via-AI increments in DECISIONS.md and §13 but
does not commit the Pyplan model file to git. In a multi-developer team (I9),
there is no shared, versioned model state — each developer works from whatever is
live in the shared instance. Combined with I9's lock requirement, the absence of
a committed model snapshot means "I have the lock" does not answer "from what base
am I building?" The v5.2 patch introduces the convention locally; v6 lifts it to
CI and portfolio governance.
**Build:**
- CI gate (builds on I1): fail a PR that closes a Build-via-AI increment without a
  `.ppl` snapshot committed in `.sdad/pyplan-snapshots/` matching the increment's
  naming convention. Same gate logic as the spec gate — enforced in the pipeline,
  not only locally.
- `$verify` extension: check whether the installed Pyplan version exposes a model
  export MCP endpoint; update §7 with the finding. Flag if the export is still
  manual-only (v1 limitation) so the team knows the step cannot be automated yet.
- `.gitattributes` merge strategy for `.ppl` files: binary format → set
  `*.ppl merge=ours` with a documented team decision on conflict resolution
  (recorded in DECISIONS.md). Without this, parallel branches with different
  snapshots produce unresolvable merge conflicts.
**Tests:** a PR closing a Build-via-AI increment without a snapshot → CI fails.
With snapshot → CI passes. Two branches with different `.ppl` files → merge
resolves via declared strategy with no corruption.
**Advantage:** model state is reproducible from git on any machine; CI enforces the
discipline across the team; the merge strategy prevents silent binary corruption.
```

**Change 2 — update I4 note:** after the existing I4 description, add:

```
Note (Ix dependency): I4 restructures DECISIONS.md and §13 for parallel increments.
Extend the same restructuring to `.sdad/pyplan-snapshots/` naming — the per-increment
file convention (decisions/NNN-feature.md) maps naturally to snapshots/NNN-feature.ppl,
so the branch-per-increment pattern works cleanly for both.
```

**Change 3 — update I9 note:** after the existing I9 description, add:

```
Note (Ix dependency): increment locking (I9) and model snapshot versioning (Ix) are
complementary. The lock answers "who is building now"; the committed snapshot answers
"from what model state." Both are required for safe parallel Build-via-AI on a shared
Pyplan instance. Implement Ix before or alongside I9.
```

**Tests:** read the updated file; confirm Ix is correctly positioned (after I3,
before I4); confirm the I4 and I9 notes are additive (no original content removed).

---

### I7 — DECISIONS.md: log this patch

**Files:** `DECISIONS.md`

**Change:** append a standard HUB BLOCK entry for this patch.

```
════════════════════════════════════════════════════════
📋 HUB BLOCK — DECISIONS_SDAD-v4.md
════════════════════════════════════════════════════════
Date: [date of increment close]
Increment: Pyplan versioning patch — SDAD v5.2
Model: [model used]
Decision: Add Pyplan model export + commit convention (.sdad/pyplan-snapshots/)
  to the Build-via-AI Protocol, Pyplan increment checklist, and $qa Layer 5.
  Update .gitignore, project-init, pyplan/mcp skill, USER_GUIDE, and v6 Build
  Brief to reflect the new convention. No version bump.
Rationale: Pyplan application state was not versioned in git; the committed .ppl
  files close the gap without requiring GitHub or any remote — local git history
  is sufficient for recovery.
Alternatives considered: (a) rely on Pyplan's internal version history — rejected:
  not developer-controlled, not linked to SDAD increments, not portable outside
  Pyplan. (b) require GitHub remote — rejected: unnecessary friction, the local
  .ppl files provide the same recovery guarantee.
Impact: .gitignore (+1 line), project-init.ps1/.sh (conditional scaffold),
  CLAUDE.md (~+10 lines), pyplan/mcp SKILL.md (~+40 lines), USER_GUIDE (+20 lines),
  SDAD_v6_BUILD_BRIEF.md (+Ix increment + 2 notes). No code surface changed.
════════════════════════════════════════════════════════
```

---

## 4. Definition of Done

- `.gitignore` has `!.sdad/pyplan-snapshots/` and a `.ppl` test file shows as untracked.
- `project-init --pyplan` creates `.sdad/pyplan-snapshots/.gitkeep`; without the flag
  it does not.
- CLAUDE.md has the four changes from I3; net line delta ≤ +10.
- `$eval` passes clean after I3 closes.
- `pyplan/mcp SKILL.md` has the three new sections from I4, consistent with CLAUDE.md.
- `SDAD_v5_USER_GUIDE.md` has section 7 on Pyplan versioning; section numbering is
  correct.
- `SDAD_v6_BUILD_BRIEF.md` has increment Ix after I3, and the I4 + I9 dependency notes.
- `DECISIONS.md` has the HUB BLOCK entry for this patch.
- All `.ps1` and `.sh` files modified in I2 pass `checks/ascii-ps1`.

---

## 5. What this brief deliberately does NOT decide

1. **Does the installed Pyplan version expose a model export MCP endpoint?** This must
   be verified against the actual running instance before I3 closes. If yes, document
   the endpoint in §7 of any Pyplan project's SPEC.md. If no, the step is manual (UI).
   The CLAUDE.md language covers both cases — do not assume either.

2. **`.ppl` binary merge strategy for v6.** The `.gitattributes` rule (`*.ppl
   merge=ours`) is specified in Ix for v6. This patch does NOT add it — single-developer
   merges are not affected. Add it when I9 is built.

3. **Snapshot automation via hook.** A future `SessionEnd` extension could auto-trigger
   the export if the MCP endpoint exists. Out of scope for this patch — manual discipline
   first, then automate in v6 once the endpoint is confirmed.

---

## 6. Recommended model / effort

- I1, I2: STANDARD · low — mechanical, well-specified
- I3: FRONTIER · high — CLAUDE.md edits are high-stakes (gate logic), run `$eval` after
- I4, I5, I6, I7: STANDARD · low — documentation, well-specified

---

## How to use this brief

Open Claude Code in the `sdad-v4` repo root and run `$spec`.
Paste the path to this file when asked for context.
This brief is the *input* — SPEC.md is the *output* SDAD produces.
Build one increment at a time; `$eval` is mandatory after I3.

---

G7 AI Development Methodology | SDAD v5.2 Pyplan Versioning Patch
Build Brief prepared 2026-06-25
