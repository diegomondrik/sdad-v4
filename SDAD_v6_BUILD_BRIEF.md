# SDAD v6 — Build Brief (Spec Input for Claude Code)

**Status:** ready to drive `$spec` -> `$specout` -> `$build` in Claude Code.
**Author:** prepared 2026-06-15, based on Chapter 15 of `knowledge/SDAD_v5_thesis.md`
(Critical Assessment & Roadmap to Team & Portfolio Governance) and the deploying
organization's confirmed deployment context.
**Target version:** 6.0 — "Team & Portfolio Edition".
**Source of truth for the changes:** the critical assessment in Chapter 15 of the v5 thesis,
plus the deployment context confirmed by the developer (see section 0).

> How to use this file: open Claude Code in the `sdad-v4` repo root and run `$spec`.
> Paste the path to this brief when asked for context. Treat it as the requirements
> input — Claude asks one question at a time, then `$specout` writes `SPEC.md`, then
> `$build` executes the increments below one at a time, each with tests + `$qa`.
> This brief is the *input*; SPEC.md is the *output* SDAD itself produces.
> Before building, run `$verify audit` — v6 introduces a CI surface, so dependency
> and platform currency matters.

---

## 0. Deployment context (confirmed — do not re-derive)

These facts were confirmed by the deploying organization and drive every priority below.
They are the reason v6 exists.

1. **Multi-developer.** Each project runs with 4-5 developers, not one.
2. **Multi-project, multi-client.** SDAD is the standard methodology across many client
   projects simultaneously. **Governance across this portfolio is the stated top priority.**
3. **Mixed operating systems.** The team is NOT Windows-only — Windows, macOS, and Linux
   coexist. Asymmetric enforcement is a day-one defect, not a future concern.
4. **Cloud delivery.** Solutions are deployed to the cloud (Pyplan and otherwise), so the
   operational half of the lifecycle (deploy/operate) is in scope, not just build.
5. **Open question to resolve in `$spec`:** does a CI system already exist across client
   projects? If not, I1 implies standing one up first (a project in itself). See section 4.

---

## 1. Why v6 (one paragraph)

SDAD v5 "Harness Edition" solved the single-developer governance problem with real rigor:
it moved the spec gate and the lesson ratchet into code, added a self-evaluation harness
(`$eval`), and made critical rules binding rather than requested. But v5 was designed,
built, and tested as a **single-developer, single-machine, single-session, single-project,
Windows-first** methodology. The confirmed deployment violates all five assumptions at once.
The consequence is precise: v5's headline guarantee — "code without an approved spec is
structurally impossible" — is true only on one correctly-configured machine, and becomes
false the moment a second developer, a second OS, or a CI server appears. v6's job is
**relocation, not reinvention**: take the mechanisms v5 invented (gates as code,
golden-dataset evaluation, the lesson ratchet, typed provenance) and move them from the
developer's machine into the shared pipeline (CI) and a central, multi-project home
(portfolio governance). The one-line thesis: *a gate that lives on the developer's machine
is a suggestion; a gate that lives in the pipeline is a guarantee — and a methodology used
across many clients must be governed from one place, or it is not governed at all.*

**Versioning decision: 6.0.** Backward-compatible with v5 projects (no SPEC.md or command
surface breaks intended), but the shift from repo-local enforcement to pipeline + portfolio
governance is an identity change the major number should signal. Upgrade-note pattern:
`git tag v5.0` before pulling v6.

---

## 2. Hard constraints (read before building)

Carried from v5 and confirmed still binding, plus new v6 constraints.

1. **`.claude/` is write-protected in Cowork mode.** Any change under `.claude/` ships as a
   one-shot, idempotent, self-deleting `apply-v6.ps1` (and its `.sh` mirror, given the mixed
   team) run once from the repo root. Same pattern as `apply-v5.ps1`.
2. **All `.ps1` and `.sh` files must be pure ASCII** (L-01, confirmed twice; ratcheted in
   `checks/ascii-ps1`). No em-dashes, accents, smart quotes, arrows, section signs in script
   source. Read/write data with explicit UTF-8.
3. **Reference `CLAUDE.md` by exact case everywhere** (L-04, ratcheted in
   `checks/claude-md-case`). CI runs on case-sensitive Linux — this constraint becomes
   load-bearing in v6, not cosmetic.
4. **CLAUDE.md net line budget per release: +60 lines** ([LOCK]). v6 adds substantial surface
   (CI, portfolio, deploy phase); push detail into new on-demand skills, keep inline footprint
   within budget. A `team` and/or `portfolio` skill is the expected escape hatch.
5. **Avoid CRITICAL/MUST/NEVER absolutes** in CLAUDE.md prose — models over-trigger on them.
6. **Do not break v5 enforcement.** The local hooks (spec gate, ratchet, `$eval`) stay; CI is
   added as the authoritative layer ON TOP, not as a replacement. Local = fast feedback,
   CI = guarantee. The v5 eval golden dataset must still pass after every v6 increment.
7. **Mixed-OS parity is a first-class requirement, not a follow-up.** Every gate or check v6
   adds must be tested on Windows AND at least one POSIX OS before its increment closes. The
   v5 pattern of "ship `.sh` untested, defer to a macOS task" is explicitly NOT acceptable in
   v6 — the team is mixed today.

---

## 3. Increments (ordered build plan)

Each is a vertical increment: announce -> confirm model/effort -> write -> run tests -> `$qa`
-> DECISIONS.md entry -> typed §13 update -> atomic commit. Ordered by the Chapter 15
priority (P0 first). I1-I3 are P0 (block the use case); I4-I7 are P1; I8-I9 are P2; I10-I11
are P3.

### I1 — Server-side (CI) enforcement of the gates — P0 (HIGHEST)
**Component:** T + L, relocated from machine to pipeline.
**Problem:** the spec gate (`PreToolUse` hook) and the ratchet (`.git/hooks/pre-commit`) live
on each developer's machine. `.git/hooks` is unversioned. A developer who never runs the
installer, or commits via CI/web/another tool, bypasses every gate silently. v5's central
guarantee is per-machine, not per-repo.
**Build:**
- A CI workflow (platform chosen in `$spec` — GitHub Actions assumed default; see section 4)
  that runs on every pull request and re-implements the gates server-side, OS-independently:
  (a) **spec gate** — fail the PR if it adds/modifies code files while `SPEC.md` is absent or
  not marked `SPEC STATUS: APPROVED` (honor the same allowlist + `$docfinal` sentinel as the
  local hook); (b) **ascii-ps1 ratchet** and (c) **claude-md-case ratchet** — fail on
  violations; (d) **`$eval` deterministic core** — fail if any scenario fails.
- The CI logic should reuse the existing `checks/` scripts and `.sdad/eval/run-eval.ps1`
  (via `pwsh` on the Linux runner) rather than reimplementing them — single source of truth.
- The local hooks stay as fast pre-PR feedback. CI is the authoritative blocker on merge.
**Tests:** a fixture PR adding code with no approved spec -> CI fails. With approved spec ->
CI passes. A PR with a non-ASCII `.ps1` -> CI fails. Run the CI logic locally in a scratch
repo on Windows and on a POSIX OS to prove parity.
**Advantage:** the v5 guarantee becomes true for a team — no developer, OS, or tool can route
around the gate, because it lives where all code converges.

### I2 — Cross-platform parity + CI matrix — P0
**Component:** L parity (mixed team confirmed).
**Problem:** the `.sh` spec-gate shipped untested in v5; the `$eval` core is PowerShell-based
and unproven on a Linux runner. A mixed team has asymmetric enforcement today.
**Build:**
- Finish and test `pre-tool-use-spec-gate.sh` against the five gate scenarios on macOS and
  Linux (mirror eval scenarios 01-05). Resolve the two known P2 edge cases (BSD `sed` path
  extraction, word-splitting on paths with spaces) from `docs/TASK_HOOKS_MACOS_PORT.md`.
- Make `$eval` run on a CI matrix across Windows / macOS / Linux (install `pwsh` on POSIX
  runners). Record any platform deltas.
- Live `/compact` PreCompact verification on a POSIX OS (the deferred v5 item).
**Tests:** eval green on all three OSes; gate scenarios pass on all three.
**Advantage:** enforcement is symmetric across the real team; closes the v5 deferred macOS gap.

### I3 — Central methodology distribution & versioning — P0
**Component:** the portfolio foundation (multi-project confirmed).
**Problem:** every client repo installs SDAD independently and drifts. A v6.x fix or a new
ratchet has no mechanism to reach 30 client repos. The methodology fragments the moment it is
deployed at scale.
**Build:**
- A single source-of-truth distribution mechanism (chosen in `$spec`: candidates — a git
  template repo, a versioned package, or a git submodule of `.claude/` + `checks/` +
  `.sdad/`). It must: (a) install a known, named SDAD version into a client repo; (b) report
  the installed version (`$pause` already shows version — extend to report drift vs. the
  central source); (c) update a client repo to a newer SDAD version idempotently.
- A `$verify` extension (or a new `$methodology-version` surface) that flags when a client
  repo's SDAD version lags the central source.
**Tests:** install version N into a fresh repo; bump the central source to N+1; confirm the
update mechanism brings the repo to N+1 without clobbering project state (SPEC/DECISIONS/
LESSON remain intact).
**Advantage:** the portfolio runs a governed, known version; fixes propagate; drift is visible.

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

### I4 — Merge-friendly collaborative state — P1
**Component:** S, restructured for concurrency.
**Problem:** DECISIONS.md and §13 are single appended files at the repo root. With parallel
increments across branches, every increment touches the same lines -> systematic merge
conflicts. The v5 atomic-commit-per-increment rule makes cross-branch merges worse.
**Build:**
- Restructure DECISIONS.md into one file per increment (e.g. `decisions/NNN-feature.md`); the
  root DECISIONS.md becomes a generated index. Same pattern for §13: per-increment records
  aggregated into the §13 table on demand. Same for lessons (one file per L-XX + generated
  index) — this also prepares the portfolio library (I5).
- Update `$build`'s post-increment write, the HUB BLOCK, and the typed §13 assert (eval
  scenario 11) to the new layout. Keep a migration that folds an existing single-file
  DECISIONS.md / §13 into the new structure (v5 compatibility).
**Tests:** two simulated parallel increments on two branches merge with no conflict; the
generated §13 table matches the 8-column schema; eval scenario 11 still passes.
**Advantage:** eliminates the daily merge friction of a 4-5 dev team.

Note (Ix dependency): I4 restructures DECISIONS.md and §13 for parallel increments.
Extend the same restructuring to `.sdad/pyplan-snapshots/` naming — the per-increment
file convention (decisions/NNN-feature.md) maps naturally to snapshots/NNN-feature.ppl,
so the branch-per-increment pattern works cleanly for both.

### I5 — Portfolio governance layer — P1
**Component:** the multi-client governance the org flagged as priority.
**Problem:** lessons, compliance defaults, and §13 telemetry are repo-local. A lesson from
client A never reaches client B; there is no per-client tier isolation; the cross-project
analytics the typed §13 was built for cannot be produced.
**Build:**
- A central Lesson Library that flows down into project repos (read) and collects new lessons
  back up (contribute), with a lightweight approval/dedup convention (owner defined in
  `$spec`). Builds on I4's per-lesson-file layout.
- Per-client compliance-tier defaults and isolation, so a Tier 1 internal tool and a Tier 3
  regulated deployment carry different governance baselines by default.
- A `$portfolio` surface (or skill) that aggregates §13 telemetry across projects for the
  cross-project analytics (which model/effort yields more QA findings; which phases reveal the
  most structural deltas).
**Tests:** a lesson contributed from one repo appears (after approval) in the central library
and is retrievable from another; a §13 aggregation across two sample projects produces the
analytics table.
**Advantage:** governance across clients becomes real — knowledge compounds, compliance is
isolated per client, the portfolio is observable.

### I6 — Architecture gate for all cloud / Tier 2-3 projects — P1
**Component:** closing the §A asymmetry.
**Problem:** all projects define a technical architecture (§5), but only Pyplan gates `$build`
on architecture (§A). For cloud solutions, technical architecture (service boundaries,
environment topology, data residency, secrets, scaling/failure modes) is where an unexamined
decision is most expensive — yet `$build` proceeds regardless on standard projects.
**Build:**
- Generalize the §A gate discipline: a Technical Architecture gate (§5 marked approved) that
  blocks `$build` for any cloud-deployed or Tier 2/3 project. Same gate logic as §9 (Tier 3)
  and §A (Pyplan). Add a `$spec` question that detects cloud/Tier and sets the gate.
- Wire the gate into the spec-gate hook AND the CI gate (I1), so it is enforced both locally
  and server-side.
**Tests:** a Tier 2 cloud project with §5 not approved -> `$build` blocked (local + CI); §5
approved -> allowed. A Tier 1 internal tool -> not gated (no regression).
**Advantage:** architecture rigor matches risk for every project, not just Pyplan.

### I7 — Deploy / Operate phase (Phase 5+) — P1
**Component:** E + L extended past build into operations.
**Problem:** SDAD governs Context -> Spec -> Build -> QA and is silent on the operational half
of a cloud solution: environments (dev/staging/prod), CI/CD deploy gates, runtime secrets,
observability, rollback, incident response.
**Build:**
- A Phase 5 surface (`$deploy` or `$operate`, named in `$spec`) covering: environment model,
  deploy gates (tied to I1's CI), runtime secrets handling (cross-check `$qa` Layer 1),
  observability/monitoring expectations, rollback procedure, and a §-section in SPEC.md for
  operational requirements. Keep it as guidance + checklists where it cannot be a hard gate;
  make it a gate where it can (e.g. no deploy to prod without a passing CI gate).
- For Pyplan: a staging-instance concept so Build-via-AI does not modify a shared live
  instance (see I9).
**Tests:** a mock deploy flow honors the prod gate; the operational SPEC section is generated
by `$specout`.
**Advantage:** SDAD covers the full cloud lifecycle, not half of it.

### I8 — Product-level evaluation harness — P2
**Component:** V, generalized from methodology to product.
**Problem:** `$eval` evaluates the methodology. A built cloud product with its own AI features
(agents, MCP tools, LLM calls) has no harness to evaluate its own non-deterministic behavior.
**Build:**
- A project-level `evals/` convention + runner for the built product's AI behavior, runnable
  in CI (I1). Reuse the `$eval` golden-dataset pattern (scenarios + expected outcomes +
  pass/fail report) but pointed at the product, not the methodology.
**Tests:** a sample product eval with a planted regression is caught by the runner in CI.
**Advantage:** aligns SDAD with eval-driven development; products gain regression detection for
their AI behavior.

### I9 — Multi-developer coordination primitives — P2
**Component:** L coordination.
**Problem:** no concept of increment ownership; two developers can build overlapping
increments; for Pyplan, two developers can run Build-via-AI against the same live instance.
**Build:**
- An increment ownership/lock convention (lightweight — a tracked file or branch convention)
  and visibility into who is building what.
- For Pyplan: locking + the staging-instance concept from I7 for Build-via-AI against shared
  instances.
**Tests:** two developers cannot both claim the same increment; a Pyplan Build-via-AI lock
prevents concurrent live edits in a simulated scenario.
**Advantage:** removes the parallel-collision and live-instance-corruption risks.

Note (Ix dependency): increment locking (I9) and model snapshot versioning (Ix) are
complementary. The lock answers "who is building now"; the committed snapshot answers
"from what model state." Both are required for safe parallel Build-via-AI on a shared
Pyplan instance. Implement Ix before or alongside I9.

### I10 — Team cost & model governance — P3
**Build:** turn model routing from advisory into measured and optionally enforced — portfolio
budget alerts and aggregated cost attribution via the §13 telemetry from I5.
**Advantage:** model/cost discipline is observable and governable across the team.

### I11 — State compaction & embedding retrieval — P3
**Build:** archive aged SPEC/DECISIONS sections so persistent state does not erode the context
budget; adopt embedding-based lesson retrieval earlier than the ~50-entry threshold (a
multi-project library grows fast).
**Advantage:** state stays lean at scale; retrieval stays relevant.

---

## 4. Definition of Done (release gate for v6)

- I1: a PR adding code without an approved spec is blocked **in CI**, on a clean OS-independent
  run (tested Windows + at least one POSIX OS).
- I2: `$eval` and the gate scenarios pass on Windows, macOS, and Linux (the matrix is green).
- I3: a SDAD version can be installed into and updated across a sample of repos from one source;
  drift is reported.
- I4: two parallel increments merge with no DECISIONS.md / §13 conflict; typed §13 assert passes.
- I5: a lesson contributed from one repo is retrievable from another; §13 aggregates across
  projects.
- I6: architecture gate blocks `$build` for a Tier 2/3 cloud project with §5 unapproved.
- `$eval` (v5 core + any new v6 scenarios) passes clean on the final v6 state, on all three OSes.
- All `.ps1`/`.sh` pure ASCII; `apply-v6.ps1`/`.sh` idempotent and self-deleting.
- CLAUDE.md within the +60-line budget; version + footer = 6.0.
- v5 project compatibility verified: an existing v5 SPEC.md still loads and `$pause` reports
  correctly; the I4 migration folds existing single-file state without loss.

---

## 5. What this brief deliberately does NOT decide (for `$spec` to resolve)

These are the decision points from Chapter 15.7 — resolve them with the organization, do not
assume them.

1. **Does a CI system exist today across client projects?** If not, I1 implies standing up a
   pipeline first — a project in itself. The entire roadmap's foundation depends on this answer.
   This is the FIRST question `$spec` must ask for v6.
2. **CI platform.** GitHub Actions vs. GitLab CI vs. Azure DevOps vs. other — determines I1's
   implementation surface.
3. **Distribution mechanism for I3.** Git template repo vs. versioned package vs. submodule —
   needs a chosen home before it can be built.
4. **One Pyplan instance or many?** If client projects share a single live Pyplan instance,
   scenario 5 (concurrent Build-via-AI corruption) is a day-one risk needing immediate
   mitigation, possibly pulling I9 forward.
5. **Who owns cross-client lessons and compliance defaults?** Portfolio governance (I5) needs an
   accountable owner or it drifts.
6. **Inline vs. skill** for the team/portfolio/deploy surface — depends on the +60-line budget
   after I1-I7.

---

## 6. Recommended model / effort for the build

Per SDAD's own routing table: `$spec`/`$specout` and `$qa full` -> FRONTIER · high. Per
increment: I1, I3, I5, I6, I7 carry open decisions / high architectural risk -> FRONTIER ·
high; I2, I4, I8, I9 are largely specified execution -> STANDARD · low to medium acceptable;
I10, I11 -> STANDARD · low. Run `$eval` and `$qa full` at FRONTIER · high on the matrix before
tagging 6.0.

---

G7 AI Development Methodology | SDAD v6 Build Brief | prepared 2026-06-15
