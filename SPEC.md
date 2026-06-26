# SPEC — SDAD v5.2 Pyplan Model Versioning Patch

> SPEC STATUS: APPROVED (2026-06-25, developer: Diego Mondrik)
> Project: SDAD methodology repo (self-referential — SDAD builds SDAD)
> Tier: 2 Business · Platform: generic · PROJECT_LANGUAGE: es (interaction) / en (documents)
> Date: 2026-06-25 · Developer: Diego Mondrik
> Input: SDAD_pyplan_versioning_brief.md (sections 0-6) + $spec anchor validation 2026-06-25
> Predecessor: v5.1 "CI Foundation" (preserved in git history; v5.0 at tag v5.0)
> Version impact: NONE — behavior patch to v5.2, no version bump.

---

## §1 Vision & Objective

When working with Pyplan MCP, SDAD manages two separate state layers. **Methodology
state** (SPEC.md, DECISIONS.md, LESSON_LIBRARY.md) is versioned in git by the SessionEnd
hook — well covered. **Pyplan application state** (nodes, interfaces, model logic) lives
in Pyplan's cloud workspace, is modified directly by the MCP, and is NOT in git.

The gap: after a Build-via-AI increment, git holds the *record* of the change
(DECISIONS.md, §13) but not the *artifact* (the model itself). If the Pyplan workspace is
corrupted or lost, there is no recovery path from the repo.

The fix is a single convention: export the Pyplan model after each Build-via-AI increment
and commit the `.ppl` export alongside DECISIONS.md. The committed `.ppl` files become the
local backup and the model's version history. No GitHub required — local git commits are
sufficient for recovery; a remote (if configured) is a second copy.

This is a behavior patch to SDAD v5.2 — it does not bump the version number.

---

## §2 Users & Roles

| Role | Description | Access |
|------|-------------|--------|
| SDAD developer (Pyplan project) | Runs Build-via-AI increments against a Pyplan instance; exports and commits the model snapshot per increment | Full repo + Pyplan workspace |
| SDAD maintainer (this repo) | Applies this patch to the methodology artefacts | Full repo |

The patch changes methodology behavior only — no end-user-facing software surface.

---

## §3 Functional Flows

### Flow 1 — Build-via-AI increment with model snapshot (Pyplan projects)

After each Build-via-AI increment closes:

1. MCP modifies the model (increment announced and approved per existing protocol).
2. `$qa` on the increment — must pass before export.
3. **Export the Pyplan model** — via MCP export endpoint if available (D-1), otherwise
   manually from the Pyplan UI → save as
   `.sdad/pyplan-snapshots/YYYYMMDD-incN-slug.ppl`.
4. **Atomic commit:** DECISIONS.md + §13 update + the `.ppl` snapshot — one commit per
   increment.
5. *(Optional — only with a remote configured)* `git push`.

Recovery: load the corresponding `.ppl` in Pyplan; git history gives the restore timeline.

### Flow 2 — Project initialization scaffolds the snapshots folder (Pyplan projects)

`project-init` detects a Pyplan project (CLAUDE.md contains uncommented
`PROJECT_PLATFORM: pyplan`, OR `--pyplan` flag passed) and creates
`.sdad/pyplan-snapshots/.gitkeep` so the folder exists and is tracked from day one.
Non-Pyplan projects: skip silently.

---

## §4 Data Model

| Artefact | Location | Format | Tracked in git |
|----------|----------|--------|----------------|
| Model snapshot | `.sdad/pyplan-snapshots/YYYYMMDD-incN-slug.ppl` | Pyplan binary `.ppl` | Yes (new exception in .gitignore) |
| Folder keeper | `.sdad/pyplan-snapshots/.gitkeep` | empty | Yes |

**Naming convention (deterministic, sortable):** `YYYYMMDD-incN-slug.ppl`
e.g. `20260625-inc03-revenue-nodes.ppl` — date `YYYYMMDD` · `inc` + zero-padded number ·
short feature slug.

---

## §5 Technical Architecture

**Stack:** PowerShell 5.1 (`.ps1`) + Bash (`.sh`) for init scripts; Markdown for
methodology artefacts (CLAUDE.md, skills, guides, briefs); git for versioning.

**Components touched by this patch:**

| Component | Role | Change |
|-----------|------|--------|
| `.gitignore` | Ignore rules | Add `!.sdad/pyplan-snapshots/` exception |
| `project-init.ps1` / `.sh` | Project bootstrap | Add Pyplan detection (hybrid) + snapshots scaffold; `.sh` sanitized to pure ASCII |
| `install.sh` | Installer | Sanitize to pure ASCII (I2b) — runs on fresh machines |
| `checks/ascii-ps1.ps1` / `.sh` | ASCII ratchet | Extend scan glob from `*.ps1` to `*.ps1` + `*.sh` (I2b) |
| `CLAUDE.md` | Methodology control | Build-via-AI step 5.5, Pyplan checklist, QA Layer 5, Behavior rule |
| `.claude/skills/pyplan/mcp/SKILL.md` | MCP skill | Snapshot convention, QA integration, $verify note |
| `docs/SDAD_v5_USER_GUIDE.md` | User guide | New §7 Pyplan versioning (renumber old §7→§8) |
| `SDAD_v6_BUILD_BRIEF.md` | v6 plan | New increment Ix + I4/I9 dependency notes |
| `DECISIONS.md` | Decisions log | HUB BLOCK entry for this patch |

**Model string (reproducibility):** this patch built with `claude-opus-4-8` (FRONTIER) for
I3; `claude-sonnet-4-6` (STANDARD) acceptable for I1/I2/I4-I7 per §6.

---

## §6 Business Rules

- **BR-1** The export/snapshot step is conditional on `PROJECT_PLATFORM: pyplan`. It must
  NOT be added to the general (non-Pyplan) `$build` flow.
- **BR-2** Snapshot filename must follow `YYYYMMDD-incN-slug.ppl` exactly — deterministic
  and sortable.
- **BR-3** The snapshot is committed in the SAME atomic commit as DECISIONS.md and the §13
  update. One commit = one increment = one known model state.
- **BR-4** CLAUDE.md net inline delta for this patch: target ≤ +10 lines; overflow prose
  goes to the skill file. (Hard ceiling remains the release budget ≤ +60.)
- **BR-5** `project-init` detection is hybrid: automatic via CLAUDE.md
  `PROJECT_PLATFORM: pyplan` (uncommented) as default; `--pyplan` flag as explicit
  override. Non-Pyplan: scaffold skipped silently.
- **BR-6** L-01 ASCII rule (EXTENDED): ALL `.ps1` AND `.sh` scripts MUST be pure ASCII.
  Rationale: `install.sh` and `project-init.sh` run on fresh cross-platform machines and
  non-ASCII bytes break them — the same failure class L-01 documented for `.ps1` (confirmed
  by developer from field experience). I2b sanitizes the two non-ASCII `.sh` files
  (`install.sh`, `project-init.sh`) and extends `checks/ascii-ps1` (both the `.ps1` and the
  `.sh` mirror) to scan `*.sh` as well, so the rule is ratcheted in code — not just a
  convention. The check is NOT renamed (kept `ascii-ps1` to preserve hook/eval/install
  references); only the scan glob and header comment change.

---

## §7 Integrations & APIs

| Integration | Endpoint | Usage |
|-------------|----------|-------|
| Pyplan MCP server | `/ai/mcp` (model export endpoint: UNKNOWN — D-1) | Model export during snapshot step IF the endpoint exists; v1 (first release, API may change). Lock Pyplan version in §5 of consuming project if MCP stability is critical. |
| git | local + optional remote | Atomic commit of snapshot + DECISIONS.md + §13; optional push |

No MCP-vs-CLI tradeoff applies: the export is producer-side state capture, not a consumer
integration SDAD wraps during build.

---

## §8 Testing Strategy

| Inc | Test | Type | Notes |
|-----|------|------|-------|
| I1 | Create `.sdad/pyplan-snapshots/test.ppl`, confirm `git status` shows it untracked (not ignored); delete it | manual | As specified in brief |
| I2 | Scaffold logic must be testable WITHOUT triggering interactive prompts or web downloads — see F-1 note below; `project-init.sh` passes the (extended) `checks/ascii-ps1` | manual/scripted | Brief's naive test is NOT runnable as written |
| I2b | After sanitizing, `checks/ascii-ps1` (extended to `.sh`) returns clean for all tracked `.ps1` + `.sh`; `$eval` scenario 06-ascii-check still passes | automated | High-risk: touches harness + eval |
| I3 | `$eval` — all golden scenarios pass; inspect CLAUDE.md diff for the 4 changes, no unintended lines | automated + review | `$eval` MANDATORY after I3 |
| I4 | Read updated SKILL.md; confirm 3 sections consistent with I3 | review | No automated test for skill files |
| I5 | Read updated guide; section numbering correct, Pyplan-specific, matches I3/I4 | review | |
| I6 | Read updated v6 brief; Ix positioned after I3 before I4; I4/I9 notes additive | review | |
| I7 | DECISIONS.md HUB BLOCK entry present | review | |

**I2 test redesign (F-1):** the existing `project-init` scripts are fully interactive
(`Read-Host` / `read -p`) and download from the repo. The brief's test
(`run project-init.ps1 --pyplan in a scratch folder`) would trigger all prompts and web
fetches — not runnable non-interactively. The scaffold logic must be added as a guarded
branch that can be exercised in isolation (e.g. an early flag/detection check that creates
the folder before the interactive section, or an extractable function), and tested by
asserting `.sdad/pyplan-snapshots/.gitkeep` is created with the flag and NOT created
without it.

---

## §9 Security & Compliance (Tier 2 Business)

**Assets to protect:** Pyplan model `.ppl` files (may embed business logic / data
structure), git history integrity.

**Controls:**
- `.ppl` snapshots are committed deliberately; developer is responsible for ensuring no
  secrets/credentials are embedded in an exported model before commit (manual review —
  surface in $qa Layer 1 when this convention is used on a real project).
- No new network surface, no new credentials handled by this patch.
- ASCII ratchet (L-01) protects the `.ps1` init script from Windows PowerShell 5.1 parse
  failures — enforced in `checks/ascii-ps1` (CI + pre-commit), fails CLOSED.

**Tier 2 note:** this patch adds no PII handling, no auth surface, no audit-logging
surface of its own. The §9 obligations of the base methodology are unchanged.

---

## §10 Definition of Done

- [ ] **I1** `.gitignore` has `!.sdad/pyplan-snapshots/`; a `.ppl` test file shows as
      untracked.
- [ ] **I2** `project-init` (both scripts) scaffolds `.sdad/pyplan-snapshots/.gitkeep` on
      Pyplan projects (CLAUDE.md detection OR `--pyplan`); skips on non-Pyplan. Scaffold
      logic is testable in isolation (F-1). `project-init.sh` is pure ASCII after the edit.
- [ ] **I2b** `install.sh` and `project-init.sh` are pure ASCII; `checks/ascii-ps1` (`.ps1`
      + `.sh` mirror) scans `*.sh` as well and returns clean for the whole repo; `$eval`
      passes (scenario 06-ascii-check green with the extended scope).
- [ ] **I3** CLAUDE.md has the four changes; net inline delta ≤ +10 lines (BR-4); `$eval`
      passes clean.
- [ ] **I4** `pyplan/mcp SKILL.md` has the three new sections, consistent with CLAUDE.md.
- [ ] **I5** `SDAD_v5_USER_GUIDE.md` has §7 Pyplan versioning; numbering correct.
- [ ] **I6** `SDAD_v6_BUILD_BRIEF.md` has Ix after I3, plus additive I4 + I9 notes.
- [ ] **I7** `DECISIONS.md` has the HUB BLOCK entry for this patch.
- [ ] **F-2 (RESOLVED — developer override):** ALL `.ps1` and `.sh` are pure ASCII and the
      ratchet now enforces it for both (I2b). My earlier proposal to exempt `.sh` was wrong
      — the installer breaks on fresh machines with non-ASCII bytes (developer field
      experience). The brief's original intent stands and is now ratcheted in code.
- [ ] **CORRECTED (F-3):** if the four I3 changes exceed +10 inline lines (estimated ~12),
      tighten wording or move prose to the skill file to land ≤ +10, per BR-4.

---

## §11 Out of Scope

- `.gitattributes` `*.ppl merge=ours` binary merge strategy — deferred to v6 (Ix / I9).
  Single-developer merges are unaffected.
- Snapshot automation via a SessionEnd hook — deferred to v6 once the export endpoint is
  confirmed (D-1).
- CI gate that fails a PR closing a Build-via-AI increment without a `.ppl` snapshot —
  this is v6 Ix, documented here as a forward reference only.
- Any version bump of SDAD.
- Fixing pre-existing drift unrelated to this patch (e.g. mcp SKILL.md header says "v4.2";
  `.gitignore` duplicate `.sdad/agent_output.tmp`) — noted, not in scope.

---

## §12 Open Decisions

| # | Decision | Status | Resolution path |
|---|----------|--------|-----------------|
| D-1 | Does the installed Pyplan version expose a model export MCP endpoint? | **OPEN** (per developer instruction) | Verify against a real running Pyplan instance when this patch is used on an actual Pyplan project. This repo is `generic` — no Pyplan instance available here. If yes: document the endpoint in §7 of the consuming project's SPEC and use it in the snapshot step. If no: the export is manual (UI). CLAUDE.md language covers both cases. |
| D-2 | I2 detection approach | **RESOLVED** | Hybrid: CLAUDE.md auto-detection (default) + `--pyplan` override (BR-5). |

---

## §13 AI Authorship Log

| Increment | Feature | Model | Effort | Files | Tests | QA findings | Date |
|-----------|---------|-------|--------|-------|-------|-------------|------|
| SPEC | Pyplan versioning patch spec | claude-opus-4-8 | high | SPEC.md | n/a | n/a | 2026-06-25 |
| I1 | .gitignore snapshots exception | claude-opus-4-8 | low | .gitignore | PASS (untracked confirmed) | clean | 2026-06-25 |
| I2 | project-init Pyplan scaffold (hybrid) + .sh ASCII | claude-opus-4-8 | high | project-init.ps1/.sh | PASS (8/8: 4 bash + 4 ps) | clean | 2026-06-25 |
| I2b | ASCII hardening + extend ratchet to .sh | claude-opus-4-8 | high | install.sh, install.ps1, checks/ascii-ps1.ps1/.sh, eval 06/07 | $eval PASS 14/14 | clean | 2026-06-25 |
| I3 | CLAUDE.md snapshot protocol (4 changes) | claude-opus-4-8 | high | Claude.md | $eval PASS 14/14 | clean (net +10) | 2026-06-25 |
| I4 | mcp SKILL.md snapshot convention | claude-opus-4-8 | low | pyplan/mcp/SKILL.md | review (consistent w/ I3) | clean | 2026-06-25 |
| I5 | USER_GUIDE Pyplan versioning §7 | claude-opus-4-8 | low | docs/SDAD_v5_USER_GUIDE.md | review (1-8 consecutive) | clean | 2026-06-25 |
| I6 | v6 brief Ix + I4/I9 notes | claude-opus-4-8 | low | SDAD_v6_BUILD_BRIEF.md | review (Ix after I3, 2 notes) | clean | 2026-06-25 |
| I7 | DECISIONS.md patch log (HUB BLOCK) | claude-opus-4-8 | low | DECISIONS.md | review | clean | 2026-06-25 |

---

G7 AI Development Methodology | SDAD v5.2 Pyplan Versioning Patch | SPEC.md
