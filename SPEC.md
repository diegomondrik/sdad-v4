# SPEC — SDAD v5.0 "Harness Edition"

> SPEC STATUS: APPROVED (2026-06-12, developer: Diego Mondrik)
> Project: SDAD methodology repo (self-referential — SDAD builds SDAD v5)
> Tier: 1 Standard · Platform: generic · PROJECT_LANGUAGE: es (interaction) / en (documents)
> Date: 2026-06-12 · Input: SDAD_v5_BUILD_BRIEF.md + ANALISIS_HARNESS_ENGINEERING_SDAD_v4.3.md

---

## §1 Vision & Objective

A v4.3 audit against harness-engineering theory (H = E, T, C, S, L, V) found SDAD
strong where it owns the layer — Context (C) and State (S) — but governing critical
gates by **instruction in the prompt** rather than **enforcement in code**. v5 is an
identity change: from *prompt methodology* to *prompt + enforced harness*.

Three core moves:
1. **Governance by code (I1, I2):** the Spec gate and the lesson ratchet become
   executable checks — a PreToolUse hook and a `checks/` directory — instead of
   prose a model can drift past.
2. **Self-evaluation (I3):** SDAD gains the V component it lacks entirely — a
   golden dataset + `$eval` runner that detects methodology regressions before
   release instead of in a client project.
3. **Hardening (I4–I8):** sub-agent liveness, typed §13, formal error-recovery
   state in `$build`, model pinning guidance, atomic state commits.

Versioning: **5.0** — backward-compatible with v4.x projects (no SPEC.md or command
surface breaks), but the governance shift warrants the major number.
Upgrade note: `git tag v4.3` before pulling v5 (already tagged).

## §2 Users & Roles

| Role | Who | Interaction |
|---|---|---|
| Methodology owner | Diego (Windows 11, PowerShell 5.1, Git Bash) | Approves Spec, runs `$build`, tags releases |
| Contributing devs | e.g. macOS porter (hooks-bash-port, merged) | Work on branches, follow SDAD increments |
| Downstream developers | Users of `install.ps1` / `install.sh` in their own projects | Consume the gate hook, checks, eval seed via installer |

## §3 Functional Flows

### F1 — Spec gate (PreToolUse, I1)
1. Claude Code intercepts every `Write` / `Edit` via PreToolUse → `run-hook.sh
   pre-tool-use-spec-gate` → platform dispatch (`.ps1` on Windows, `.sh` on POSIX).
2. Gate reads the tool-call JSON from stdin, extracts the target file path.
3. Decision tree (first match wins):
   a. Path in allowlist (see §6 R1) → **allow** (exit 0).
   b. `.sdad/DOCFINAL_ACTIVE` sentinel exists → **allow** ($docfinal runs spec-less).
   c. Target is not a code file (extension not in denylist, §6 R2) → **allow**.
   d. `SPEC.md` missing → **deny** (exit 2 + message "no SPEC.md — run $spec or $docfinal").
   e. `SPEC.md` present but no `SPEC STATUS: APPROVED` marker → **deny** (exit 2 + message).
   f. Approved → **allow**.
4. Any internal error in the gate script → **allow** + append warning to
   `.sdad/gate.log` (fail-open — a broken guard never freezes the developer).

### F2 — Lesson ratchet (I2)
1. `$qa` lesson capture: when a lesson has a mechanically verifiable pattern,
   propose a check in `checks/` alongside the prose entry (protocol added to CLAUDE.md).
2. First real check: `checks/ascii-ps1.ps1` — fails when any tracked `.ps1`
   contains non-ASCII bytes (L-01, recurred twice).
3. Wiring (dual, single source):
   a. `session-end.ps1` / `.sh` invoke the check before autocommit — on failure,
      **skip autocommit + warn** (session hooks stay fail-open).
   b. `.git/hooks/pre-commit` (installed by installer / apply-v5.ps1) invokes the
      same script — on failure, **block the commit** (deliberate hard stop).

### F3 — Methodology evaluation (`$eval`, I3)
1. Deterministic core (always; gate when CLAUDE.md or any skill changes):
   each scenario under `.sdad/eval/scenarios/NN-name/` is a plain ASCII `.ps1`
   that sets up a temp fixture, executes the unit (gate hook with mock stdin,
   ASCII check against a dirty fixture, structural asserts on CLAUDE.md rules),
   and exits 0/1. Runner aggregates → pass/fail report per scenario.
2. LLM replay smoke (release gate only, before tagging): 2–3 scenarios via
   `claude --print` matched with lax regex (e.g. `$spec` opener mentions the
   language question). Never a daily gate — non-deterministic by nature.
3. Structural asserts in the deterministic core include: language-first rule
   present, §A/§D/§9 gate rules present, version stamp, CLAUDE.md line budget.

### F4 — `$build` error recovery (I6)
On tool/test error mid-increment: report → stop the increment cleanly → create
`.sdad/HOLD_AUTOCOMMIT` → never autocommit, never enter an undefined retry loop.
Recovery state clears when the developer explicitly resumes.

### F5 — `$agent` liveness (I4)
Delegation wraps `claude --print` with a timeout (default 10 min). On timeout or
empty/missing `agent_output.tmp` → surface the error, never proceed silently.

## §4 Data Model

| Artifact | Location | Format |
|---|---|---|
| Spec approval marker | `SPEC.md` line 3 | `> SPEC STATUS: APPROVED` (exact ASCII match; DRAFT until developer approves) |
| Gate log | `.sdad/gate.log` | append-only text: timestamp + warning |
| Docfinal sentinel | `.sdad/DOCFINAL_ACTIVE` | empty file; created/removed by `$docfinal` |
| Autocommit hold | `.sdad/HOLD_AUTOCOMMIT` | empty file (already honored by session-end hooks) |
| Checks | `checks/*.ps1` (+ future `.sh`) | plain scripts, exit 0 pass / non-zero fail |
| Eval scenarios | `.sdad/eval/scenarios/NN-name/run.ps1` + optional `fixture/` | plain scripts, exit 0 pass |
| Eval report | stdout of runner | one line per scenario: PASS/FAIL + name |
| Typed §13 row (I5) | SPEC.md §13 | columns: Increment · Feature · Model · Effort · Files · Tests (pass/fail/count) · QA findings (count/max severity) · Date |

## §5 Technical Architecture

- **Hook architecture (post-merge):** `settings.json` registers shell-form
  commands → `run-hook.sh <name>` dispatcher → `.ps1` (Windows/MINGW) or `.sh`
  (POSIX). v5 adds the `PreToolUse` entry (matcher `Write|Edit`) via `apply-v5.ps1`.
- **Delivery:** `.claude/` is write-protected in Cowork mode → all `.claude/`
  changes ship via `apply-v5.ps1` (idempotent, self-deleting, ASCII) reading from
  `_staging_v5/`. Scaffold already written and committed (`a65dd34`).
- **Platform matrix:** Windows = tested here (gate `.ps1`, checks, eval runner).
  macOS = `.sh` gate variant shipped **untested**, flagged in
  `docs/TASK_HOOKS_MACOS_PORT.md` (now reduced to: spec-gate.sh test + live
  `/compact` PreCompact verification).
- **Installers:** `install.ps1` / `install.sh` + `project-init.*` updated (I10) to
  ship the new hook pair, `checks/` scaffold, `.sdad/eval/` seed, and the git
  pre-commit hook.
- **Model pinning (I7):** §5 of generated SPECs and `$verify` record the exact
  model string per release when reproducibility matters. This release: built on
  `claude-fable-5` (spec) per routing table.

## §6 Business Rules

- **R1 Gate allowlist (never blocked):** `SPEC.md`, `SPEC_RETROACTIVE.md`,
  `DECISIONS.md`, `LESSON_LIBRARY.md`, `CHANGELOG.md`, `README.md`, any `*.md`,
  anything under `docs/`, `.sdad/`, `.claude/`, `hub/`.
- **R2 Code-file denylist (extensions):** `.py .js .ts .jsx .tsx .ps1 .psm1 .sh
  .bat .cmd .sql .html .css .json .yaml .yml .toml .ini .cs .java .go .rs .rb .php`
  — extendable; unknown extensions default to **allow** (fail-open bias).
- **R3 Fail-open:** session hooks and the gate's own internal errors never block;
  the only deliberate hard stops are the gate's deny (exit 2) and the git
  pre-commit ratchet.
- **R4 CLAUDE.md budget:** net ≤ +60 lines this release [LOCK]. Estimated I9
  footprint ~35–40 lines. Escape hatch: overflow migrates to an on-demand
  `harness` skill (decision recorded with this condition).
- **R5 ASCII:** every `.ps1` pure ASCII (L-01) — including all v5 deliverables;
  enforced by the very check this release ships.
- **R6 Atomic state (I8):** DECISIONS.md + §13 + SPEC.md updates for one increment
  are staged and committed as a single commit.
- **R7 Absolutes:** CLAUDE.md prose avoids CRITICAL/MUST/NEVER — plain instruction
  + embedded rationale.
- **R8 Eval gate:** `$eval` (deterministic core) runs on any CLAUDE.md/skill
  change and as release gate; LLM smoke only before tagging.

## §7 Integrations & APIs

- **Claude Code hooks API:** stdin JSON, exit codes (0 allow / 2 deny for
  PreToolUse), `hookSpecificOutput` JSON. Verified against current behavior; the
  dispatcher pattern was validated against the hooks docs (DECISIONS.md inc. 12).
- **git hooks:** `.git/hooks/pre-commit` — not versioned by git; installed by
  installer/apply script. Known bypass: `--no-verify` (accepted residual risk,
  documented).
- **`claude --print`:** `$agent` delegation + `$eval` LLM smoke. Pyplan MCP rules
  unchanged from v4.3 (not in this release's scope).
- No new external dependencies. `$verify` not triggered.

## §8 Testing Strategy

- **Tests ARE eval scenarios** — one artifact, not two. I1/I2 acceptance tests are
  written directly as `.sdad/eval/scenarios/` entries; I3's runner re-executes them
  forever after. No external framework (no Pester) — plain scripts + exit codes.
- **I1 scenarios:** temp repo, no SPEC.md → code Write denied (exit 2) · approved
  SPEC.md → allowed · `docs/*.md` with no Spec → allowed · DOCFINAL sentinel →
  allowed · gate script deliberately broken → fail-open (allow + gate.log entry).
- **I2 scenarios:** `.ps1` fixture with non-ASCII byte → check fails · clean → passes
  · pre-commit blocks a dirty commit in a temp repo.
- **I3 self-test:** plant a regression (remove the language-first rule from a
  CLAUDE.md copy) → `$eval` structural assert catches it.
- **Platform gate:** everything above runs and passes on Windows (this machine)
  before any increment closes. macOS variants ship marked untested (§5).
- **Compatibility:** a v4.x SPEC.md fixture still loads; `$pause` reports correctly.

## §9 Security & Compliance (Tier 1)

- Hooks and checks run with developer-process privileges on developer machines
  only — no network calls, no secrets handling, no PII.
- Gate deny messages and `gate.log` contain file paths only — no file contents.
- The gate's fail-open design favors availability over enforcement on its own
  errors; the threat model is developer-experience (frozen session), not adversary.
- Pre-commit `--no-verify` bypass: accepted for Tier 1; the SessionEnd path
  provides the second net.
- `$qa` Layer 1 reviews the gate hook (path parsing, no code-exec from stdin JSON).

## §10 Definition of Done (release gate for 5.0)

- [ ] I1 gate denies code-write without approved Spec; fails open on its own error (tested on Windows).
- [ ] I2 ASCII check blocks a non-ASCII `.ps1` commit (tested).
- [ ] I3 `$eval` catches a deliberately planted methodology regression (tested).
- [ ] `$eval` passes clean on the final v5 state.
- [ ] All `.ps1` pure ASCII; `apply-v5.ps1` idempotent and self-deletes.
- [ ] CLAUDE.md within +60-line budget; version + footer = 5.0; PROJECT_LANGUAGE recorded.
- [ ] CHANGELOG `[5.0]`, README "what's new", three HTML docs (per ADR-005) consistent.
- [ ] v4.3 compatibility verified (existing SPEC.md loads, `$pause` reports).
- [ ] `docs/TASK_HOOKS_MACOS_PORT.md` updated: spec-gate.sh test + live `/compact` check.

## §11 Out of Scope

- macOS testing of the new `.sh` gate variant (deferred to the task doc — shipped untested).
- Runtime E / generic T / runtime-V — Claude Code's layer (analysis §0 category-error correction).
- LLM replay as a daily/per-change gate (release-gate only).
- Any Pyplan-surface changes (v4.3 behavior carries over unchanged).
- Rewriting existing v4.x hooks (only extended: ratchet call in session-end).

## §12 Open Decisions

- OD-1: exact wording + regex set of the 2–3 LLM smoke scenarios (resolve in I3).
- OD-2: whether SessionStart prints an `$eval` reminder when CLAUDE.md changed
  since last run (resolve in I3 — default: yes, one line, non-blocking).
- OD-3: timeout default for `$agent` liveness — 10 min proposed (confirm in I4).

## §13 AI Authorship Log

| Increment | Feature | Model | Effort | Files | Tests | QA findings | Date |
|---|---|---|---|---|---|---|---|
| prep-1 | v5 brief + analysis + docs drafts + apply-v5 scaffold committed | claude-opus-4-8 | high | 7 files (091ca09) | n/a (docs) | — | 2026-06-12 |
| prep-2 | hooks-bash-port merged into v5; dispatcher verified on Windows (mock stdin → exit 0) | claude-opus-4-8 | high | 9 files (fb141fa) | 1/1 manual dispatcher check | — | 2026-06-12 |
| prep-3 | apply-v5.ps1 switched to dispatcher registration + dual gate variant | claude-opus-4-8 | high | apply-v5.ps1 (a65dd34) | ASCII check pass | — | 2026-06-12 |
| I1 | PreToolUse spec-gate hook (ps1+sh) + 5 eval scenarios | claude-fable-5 | high | _staging_v5/hooks/ (2), .sdad/eval/scenarios/01-05 (5) | 5/5 pass (Windows) | 1 P2 (sh sed path edge, pending mac test) | 2026-06-12 |

---

G7 AI Development Methodology | SDAD v5.0 SPEC | generated by $specout 2026-06-12
