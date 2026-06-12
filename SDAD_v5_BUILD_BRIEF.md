# SDAD v5 — Build Brief (Spec Input for Claude Code)

**Status:** ready to drive `$spec` → `$specout` → `$build` in Claude Code.
**Author:** prepared in Cowork on 2026-06-12, based on `ANALISIS_HARNESS_ENGINEERING_SDAD_v4.3.md`.
**Target version:** 5.0 — "Harness Edition".
**Source of truth for the changes:** the harness-engineering analysis in this repo (R1–R8).

> How to use this file: open Claude Code in the `sdad-v4` repo root and run `$spec`.
> Paste the path to this brief when asked for context. Treat it as the requirements
> input — Claude will ask one question at a time, then `$specout` writes `SPEC.md`,
> then `$build` executes the increments below one at a time, each with tests + `$qa`.
> This brief is the *input*; SPEC.md is the *output* SDAD itself produces.

---

## 0. Why v5 (one paragraph)

A v4.3 audit against harness-engineering theory (H = E, T, C, S, L, V) found SDAD
strong where it owns the layer — Context (C) and State (S) — but governing almost
everything else by **instruction in the prompt** rather than **enforcement in code**.
The theory's central axiom: *structural constraints belong in code; natural-language
"pleading" in a prompt is only a suggestion.* v5 moves SDAD's critical gates from
prompt to code, adds the one component it genuinely lacks (V — evaluation/regression
of the methodology itself), and reanchors the lesson "ratchet" so a fixed failure
mode cannot recur. This is an identity change — from *prompt methodology* to
*prompt + enforced harness* — which is why it is a major version, not a 4.x.

**Versioning decision: 5.0.** Backward-compatible with v4.x projects (no SPEC.md or
command surface breaks), but the shift from governance-by-instruction to
governance-by-code is a conceptual leap that the major number should signal.
Upgrade note pattern (follow prior releases): `git tag v4.3` before pulling v5.

---

## 1. Hard constraints (read before building)

These are repo facts confirmed on 2026-06-12. Do not violate them.

1. **`.claude/` is write-protected in Cowork mode.** Any change to files under
   `.claude/` (hooks, skills, agents, `settings.json`) must ship as a one-shot,
   idempotent, self-deleting `apply-v5.ps1` run once from the repo root — the same
   pattern as `apply-v4.3.ps1`. Do not assume direct writes to `.claude/` will persist.
2. **All `.ps1` files must be pure ASCII** (L-01, confirmed twice). No em-dashes,
   accents, or smart quotes. PowerShell 5.1 misreads UTF-8 without BOM and breaks.
3. **Hooks are Windows/PowerShell only.** The macOS/bash port is already a tracked
   follow-up (`docs/TASK_HOOKS_MACOS_PORT.md`); v5 hooks extend the Windows set and
   add their bash port to that same deferred task — do not block v5 on it.
4. **Hooks must never hard-block the session unexpectedly.** Existing hooks always
   exit 0. The new gate hook (I1) is the deliberate exception — it exits non-zero to
   *deny a tool call* — so it must be surgically scoped (see I1) and fail-open on its
   own internal errors (if the gate script itself errors, allow the action and log).
5. **CLAUDE.md net line budget per release: +60 lines** ([LOCK], DECISIONS.md).
   Voluminous content goes to on-demand skills, not inline. v5 adds a Control Layer
   section and an `$eval` command — keep the inline footprint within budget; push
   detail into a new skill if needed.
6. **Avoid CRITICAL/MUST/NEVER absolutes** in CLAUDE.md instruction prose — the
   models over-trigger on them. Use plain instruction + embedded rationale.

---

## 2. Increments (ordered build plan)

Each is a vertical increment: announce → confirm model/effort → write → run tests →
`$qa` → DECISIONS.md entry → §13 update. Increments are ordered by dependency and
value. I1–I3 are the high-priority changes; I4–I8 are supporting; I9–I10 close the release.

### I1 — PreTool spec-gate hook (R3) — HIGH
**Component:** L (Lifecycle) enforcing E/T boundaries.
**Problem:** "no production code before an approved Spec", the `$build` block on
Context 65% / §A / §D / §9 — today these are instructions a model can drift past.
`.claude/settings.json` registers only SessionStart / PreCompact / SessionEnd. There
is no PreToolUse gate.
**Build:**
- New hook `pre-tool-use-spec-gate.ps1` registered on `PreToolUse` with matcher for
  `Write` and `Edit`.
- Deny the call (exit 2 with a message) when the target is a code file AND
  `SPEC.md` is absent OR not marked approved.
- Allowlist that must NOT be blocked: `SPEC.md`, `DECISIONS.md`, `LESSON_LIBRARY.md`,
  everything under `docs/`, `.sdad/`, `.md` working files, and the `$docfinal` path
  (which legitimately runs without a Spec — detect via an env flag or a sentinel file
  like `.sdad/DOCFINAL_ACTIVE`).
- Fail-open: if the gate script itself errors, allow the action and write a warning to
  `.sdad/gate.log`. A broken guard must never freeze the developer.
- Ship via `apply-v5.ps1` (write-protected `.claude/`). ASCII only.
**Tests:** create a temp repo with no SPEC.md → attempt a code Write → expect denial.
Add an approved SPEC.md → expect allow. Edit a `docs/*.md` with no Spec → expect allow.
Break the script deliberately → expect fail-open (allow + log).
**Advantage:** "code written without an approved Spec" becomes structurally impossible,
independent of model compliance — the core promise of SDAD stops being a request.

### I2 — Lesson-to-Guardrail code ratchet (R2) — HIGH
**Component:** the Ratchet mechanism, moved from Construction Layer to Control Layer.
**Problem:** captured lessons become a sentence in CLAUDE.md. L-01 is "confirmed twice"
— proof the instructional ratchet failed at least once.
**Build:**
- New CLAUDE.md protocol (in the Lesson Capture section): when a captured lesson has a
  *mechanically verifiable* pattern, generate a check (a hook, a lint rule, or a test)
  in a new `checks/` directory — not only a prose rule.
- Ship a first real check derived from L-01: `checks/ascii-ps1.ps1` (or a pre-commit
  hook) that fails if any `.ps1` contains non-ASCII bytes. This both implements the
  ratchet and proves it on the exact lesson that already recurred.
- Wire it into the SessionEnd autocommit path or a pre-commit hook so it runs without
  the developer remembering.
**Tests:** introduce a non-ASCII char into a throwaway `.ps1` → expect the check to fail
the commit/run. Clean file → passes.
**Advantage:** a fixed failure mode cannot silently recur; the ratchet enforces, not reminds.

### I3 — Methodology evaluation harness / Golden Dataset (R1) — HIGH
**Component:** V (Evaluation) — the component SDAD lacks entirely.
**Problem:** SDAD edits itself every release with zero regression detection. A change to
CLAUDE.md or a skill is only "tested" when a real project later fails.
**Build:**
- `.sdad/eval/` golden dataset: a small set of canonical scenarios with expected
  behavior, e.g. (a) a `$spec` opening that must ask the PROJECT_LANGUAGE question first;
  (b) a `$build` attempt with no approved Spec that must be refused; (c) a `$qa` run over
  a fixture with known planted findings that must be reported at the right severity.
- A runner (`$eval` command in CLAUDE.md + a script) that replays the scenarios against
  the current methodology and diffs actual vs expected, emitting a pass/fail report.
- Trigger: run `$eval` when CLAUDE.md or any skill changes (and as a release gate before
  tagging). Document it; optionally wire a reminder into SessionStart.
**Tests:** the runner itself is tested by introducing a deliberate regression (e.g.
remove the language-first rule) and confirming `$eval` catches it.
**Advantage:** "did this edit to the methodology break it?" becomes observable before
release instead of in a client project. This is indisputably SDAD's own responsibility.

### I4 — `$agent` heartbeat / liveness (R4) — MEDIUM
**Component:** L (heartbeat).
**Problem:** `claude --print` delegation only checks for empty output. A zombie sub-agent
(running, zero progress) is not detected.
**Build:** add a timeout and a liveness check around the delegation call; on timeout,
surface a clear error and do not proceed silently (consistent with the existing
"agent_output.tmp empty/missing -> surface error" rule).
**Tests:** simulate a hanging delegation → expect timeout + surfaced error.
**Advantage:** long delegations fail fast and visibly instead of stalling.

### I5 — Typed §13 AI Authorship Log (R5) — MEDIUM
**Component:** V (trajectory capture).
**Problem:** §13 is a free-form ledger; not comparable across projects.
**Build:** define a structured schema for §13 rows (increment, feature, model, effort,
files touched, test result, QA findings count/severity, date). Update `$specout` §13
template and the `$build` post-increment write to emit the structured form.
**Tests:** run a mock increment close → §13 row matches schema.
**Advantage:** enables causal attribution across projects ("which model/effort produced
more QA findings"), HAL-style.

### I6 — E-termination on tool error in `$build` (R6) — MEDIUM
**Component:** E (execution loop).
**Problem:** no defined recovery state when a test command or tool errors mid-increment.
**Build:** add a `$build` rule: on tool/test error, transition to a named recovery state
(report error, stop the increment cleanly, do not autocommit, set `.sdad/HOLD_AUTOCOMMIT`),
never enter an undefined retry loop.
**Tests:** force a failing test command → expect clean stop + hold, not a loop.
**Advantage:** removes the ReAct-style undefined-transition runaway risk in automated runs.

### I7 — Determinism: model-version pin (R7) — LOW
**Build:** extend `$verify` / §5 guidance to record the exact model string used per
release and recommend pinning where reproducibility matters (already partial for Pyplan MCP).
**Advantage:** reproducible methodology behavior across model releases.

### I8 — Atomic state commits (R8) — LOW
**Build:** formalize that DECISIONS.md + §13 + SPEC.md updates for one increment are
written as a unit (single commit), so a crash mid-write cannot leave inconsistent state
(the AutoGPT failure mode from the analysis).
**Advantage:** state survives partial failure consistently.

### I9 — CLAUDE.md v5 reframe + Control Layer section — HIGH (closes methodology)
**Build:**
- New CLAUDE.md section "Control Layer & Harness Model": one compact table mapping
  H = (E, T, C, S, L, V) to where SDAD enforces each (code vs prompt), and the Governance
  Axiom as a behavior rule ("hard gates live in hooks/checks; prompt rules are the
  fallback, not the guarantee").
- Register the new `$eval` command in the Commands section and `$sdad` overview.
- New behavior rules for I1–I3 enforcement. Bump footer + version to 5.0. Respect the
  +60-line budget — push detail to a new on-demand `harness` skill if it overflows.
**Tests:** `$eval` golden case confirms the language-first rule and the build gate still
trigger after the edit.

### I10 — Docs, CHANGELOG, README, migration — HIGH (closes release)
**Build:**
- Finalize the three v5 docs (this brief's siblings) to HTML per ADR-005
  (human-readable -> HTML5; machine-readable -> MD): INSTALL, USER GUIDE, WHAT-IS-SDAD.
- CHANGELOG `[5.0]` entry (Keep a Changelog format) with Added/Changed/Fixed and the
  `git tag v4.3` upgrade note.
- README "What's new in v5" + repo-structure update (new hook, `checks/`, `.sdad/eval/`).
- `apply-v5.ps1` performs the `.claude/` changes (new hook, settings.json registration,
  skill if added), idempotent + self-deleting + ASCII.
- Update `install.ps1` / `install.sh` and `project-init.*` to ship the new hook, the
  `checks/` scaffold, and the `.sdad/eval/` seed.

---

## 3. Definition of Done (release gate for v5)

- I1 gate denies code-write without approved Spec, and fails open on its own error (tested on Windows).
- I2 ASCII check blocks a non-ASCII `.ps1` commit (tested).
- I3 `$eval` catches a deliberately planted methodology regression (tested).
- `$eval` passes clean on the final v5 state.
- All `.ps1` are pure ASCII; `apply-v5.ps1` is idempotent and self-deletes.
- CLAUDE.md stays within the +60-line release budget; version + footer = 5.0.
- CHANGELOG `[5.0]`, README "what's new", and the three HTML docs are updated and consistent.
- v4.3 project compatibility verified: an existing SPEC.md still loads and `$pause` reports correctly.

---

## 4. What this brief deliberately does NOT decide (for `$spec` to resolve)

- Exact `$eval` scenario list and expected-output format (golden dataset design).
- Whether the harness mapping lives inline in CLAUDE.md or in a new `harness` skill
  (depends on the +60-line budget after I9).
- Whether I2's ratchet uses a pre-commit hook vs the SessionEnd path.
- macOS/bash timing for the new hook (default: defer to `TASK_HOOKS_MACOS_PORT.md`).

---

## 5. Recommended model / effort for the build

Per SDAD's own routing table: `$spec`/`$specout` and `$qa full` → FRONTIER (Opus 4.8) ·
high. Per-increment `$build`: I1, I2, I3, I9 carry open decisions / medium risk →
FRONTIER · high; I4–I8 are specified execution → STANDARD · low is acceptable. Run
`$eval` (I3) and `$qa full` at FRONTIER · high before tagging 5.0.

---

G7 AI Development Methodology | SDAD v5 Build Brief | prepared 2026-06-12
