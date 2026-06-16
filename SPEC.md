# SPEC — SDAD v5.1 "CI Foundation"

> SPEC STATUS: APPROVED (2026-06-15, developer: Diego Mondrik)
> Project: SDAD methodology repo (self-referential — SDAD builds SDAD v5.1)
> Tier: 2 Business · Platform: generic · PROJECT_LANGUAGE: es (interaction) / en (documents)
> Date: 2026-06-15 · Developer: Diego Mondrik
> Input: SDAD_v6_BUILD_BRIEF.md (sections 0, 2, I1-I3, 5) + decisions confirmed in $spec 2026-06-15
> Predecessor: v5.0 "Harness Edition" (preserved at git tag v5.0)

---

## §1 Vision & Objective

SDAD v5.0 moved the spec gate and the lesson ratchet from prompt into code — but only
on **one correctly-configured machine**. The confirmed deployment context (4-5 developers
per project, many client projects, mixed Windows/macOS/Linux, cloud delivery) breaks that
guarantee the moment a second developer, a second OS, or a non-installer commit path
appears. `.git/hooks` is unversioned; a developer who never runs the installer, or who
commits via web/CI/another tool, bypasses every v5 gate silently.

v5.1 is the **CI Foundation**: the prerequisite the v6 brief identified (section 0.5 / 5.1)
when it confirmed that **no shared CI exists today across client projects**. Rather than
fold the pipeline into v6, this release stands it up as its own shippable, independently
adoptable artifact, so the whole v6 portfolio layer (I4-I11) can ride on a proven base.

Three moves, all relocation (not reinvention) of v5 mechanisms from machine to pipeline:

1. **Gates as a server-side guarantee (I1).** A GitHub Actions workflow re-runs the v5
   gates on every pull request — spec gate, ascii-ps1 ratchet, claude-md-case ratchet,
   `$eval` deterministic core — reusing the existing `checks/` scripts and
   `run-eval.ps1` (via `pwsh`) as the single source of truth. Local hooks stay as fast
   pre-PR feedback; CI is the authoritative blocker on merge.
2. **Symmetric cross-OS enforcement (I2).** The `.sh` spec-gate (shipped untested in v5)
   is finished and tested on macOS and Linux; `$eval` runs on a Windows/macOS/Linux
   matrix; the deferred live PreCompact verification on POSIX is closed.
3. **Versioned distribution (I3-versioning).** A `.sdad/VERSION` stamp, an installer
   pinned to a release tag instead of `main`, drift detection (does a client repo lag the
   central source?), and an idempotent update path that never clobbers project state.

**Versioning: 5.1** — minor, backward-compatible with v5.0 (no SPEC.md or command-surface
breaks). The identity change to portfolio governance is reserved for v6.0; v5.1 is the
load-bearing step that makes v6 possible.
Upgrade note: `git tag v5.0` already exists; tag `v5.1` on release.

## §2 Users & Roles

| Role | Who | Interaction |
|---|---|---|
| Methodology owner | Diego (Windows 11, PowerShell 5.1) | Approves Spec, runs `$build`, reviews PRs, tags releases |
| Contributing devs | Mixed Windows / macOS / Linux, 4-5 per project | Open PRs; CI gate is authoritative on their merges |
| Downstream developers | Consumers of `install.*` / `project-init.*` in client repos | Receive the CI workflow + versioned installer; adopt per repo |
| CI runner (GitHub Actions) | Automated, non-human | Re-runs the gates server-side on every PR; blocks merge on failure |

## §3 Functional Flows

### F1 — Server-side spec gate on pull request (I1)
1. A PR is opened or updated against a protected branch.
2. `sdad-gates.yml` runs. A gate job computes the PR's changed files (`git diff`).
3. For each changed path, it applies the **shared spec-gate policy** (the same
   allowlist / code-file denylist / `$docfinal` sentinel / SPEC-approval logic the local
   hook uses — see §5 single-source-of-truth design).
4. If any changed path is a code file AND `SPEC.md` is absent OR not marked
   `SPEC STATUS: APPROVED` → the job fails the PR with a message naming `$spec` / `$docfinal`.
5. Otherwise the gate passes. The ratchet jobs (F2) and `$eval` (F3-eval) also run; any
   failure fails the PR. All green → merge is allowed.

### F2 — Ratchets and eval on the CI matrix (I1 + I2)
1. The workflow runs a matrix: `ubuntu-latest`, `windows-latest`, `macos-latest`.
2. Each OS installs `pwsh` if not present, then runs, reusing existing scripts (no
   reimplementation): `checks/ascii-ps1`, `checks/claude-md-case`, and
   `pwsh .sdad/eval/run-eval.ps1` (deterministic core).
3. Any non-ASCII `.ps1`, any wrong-case `CLAUDE.md` reference, or any failing eval
   scenario fails the PR on that OS leg.
4. Platform deltas (if any leg behaves differently) are recorded in DECISIONS.md.

### F3 — Versioned install / drift / update (I3-versioning)
1. **Install:** `install.*` / `project-init.*` fetch files from a **pinned release tag**
   (e.g. `.../sdad-v4/v5.1/...`) rather than `main`, and write `.sdad/VERSION` (`5.1`).
   The CI workflow ships as one of the fetched files.
2. **Drift check:** `$verify` (drift mode) reads local `.sdad/VERSION`, fetches the
   central version marker from the source, and reports if the repo lags
   (e.g. "this repo is on SDAD 5.0; central is 5.1 — run the updater").
3. **Update:** re-running the installer pinned to a newer tag is idempotent — it refreshes
   methodology files and `.sdad/VERSION` while preserving `SPEC.md`, `DECISIONS.md`,
   `LESSON_LIBRARY.md`, and `.sdad/project.md` untouched.

### F4 — Local-CI parity (the v6 thesis, enforced)
The local PreToolUse hook and the CI gate consume the **same** decision module, so a path
that is allowed/denied locally is allowed/denied identically in CI. Divergence between
local and server enforcement is the failure mode v5.1 exists to prevent; the shared module
makes it structurally impossible to drift.

## §4 Data Model (artifacts produced / consumed)

| Artifact | Status | Role |
|---|---|---|
| `.github/workflows/sdad-gates.yml` | new | CI workflow: PR gate + ratchets + eval matrix |
| `checks/spec-gate-policy.{sh,ps1}` | new | Shared spec-gate decision module (consumed by local hook + CI) |
| `.claude/hooks/pre-tool-use-spec-gate.{ps1,sh}` | refactor | Local hook delegates the decision to the shared policy module |
| `checks/ascii-ps1.{ps1,sh}` | reuse | L-01 ratchet — run by CI unchanged |
| `checks/claude-md-case.{ps1,sh}` | reuse | L-04 ratchet — run by CI unchanged |
| `.sdad/eval/run-eval.ps1` + scenarios | reuse | Deterministic core — run by CI via `pwsh` |
| `.sdad/VERSION` | new | Version stamp (`5.1`); read by drift check, written by installer |
| `install.{ps1,sh}`, `project-init.{ps1,sh}` | modify | Pin to release tag, write VERSION, ship workflow, idempotent update |
| `apply-v5.1.{ps1,sh}` | new | One-shot, idempotent, self-deleting; applies `.claude/` hook refactor |
| CLAUDE.md, CHANGELOG.md, README.md, docs/ | modify | Version bump, behavior rules, what's-new (release close) |

No end-user data, no database, no persistent runtime state. The "data" of this project is
methodology source files and CI configuration.

## §5 Technical Architecture

**Stack / surface.** GitHub Actions (chosen platform [LOCK] D1 — remote is on GitHub,
`pwsh` runs on all three GitHub-hosted runners, so existing `.ps1` checks and the eval
runner are reused rather than reimplemented). PowerShell 5.1 (Windows) + PowerShell Core
`pwsh` (POSIX runners) + POSIX `sh` for the `.sh` variants. No new runtime dependency, no
external registry, no API dependency (honors the [LOCK] "no API dependency in the
methodology").

**Single-source-of-truth gate design.** The spec-gate decision (allow/deny a given path
under the current SPEC state) is factored into `checks/spec-gate-policy.{sh,ps1}`. Two
entry points consume it:
- **Local** (`pre-tool-use-spec-gate.*`): reads one path from the PreToolUse stdin JSON,
  asks the policy, denies the single tool call. Per-tool-call, fast feedback.
- **CI** (`sdad-gates.yml`): iterates the PR's `git diff` changed paths, asks the policy
  per path, fails the PR. Per-PR, authoritative.
Refactoring the local hook to delegate to the shared module must be behavior-preserving:
eval scenarios 01-05 must still pass after the refactor.

**Apply-script scope.** Only changes under the write-protected `.claude/` ship via
`apply-v5.1.*` (the hook refactor). `.github/workflows/`, `checks/`, and `.sdad/VERSION`
are NOT under `.claude/` and are written directly by the installer / repo.

**Build plan (increments).**

- **INC-1 — Shared policy module + CI gate workflow (I1).** FRONTIER · high.
  Extract `spec-gate-policy.*`; refactor local hook to consume it (eval 01-05 unchanged).
  New `sdad-gates.yml` running PR spec gate + ascii-ps1 + claude-md-case + `$eval` core on
  `ubuntu-latest`. Fixtures prove deny/allow. Enable the workflow on this repo (self-hosting).
- **INC-2 — Cross-OS parity + matrix (I2).** STANDARD · medium (FRONTIER if edge cases bite).
  Test `pre-tool-use-spec-gate.sh` against scenarios 01-05 on macOS + Linux; resolve the
  two known P2 edge cases (BSD `sed` path extraction; word-splitting on paths with spaces,
  in the gate and `ascii-ps1.sh`). Expand `sdad-gates.yml` to the Windows/macOS/Linux
  matrix (`pwsh` on all). Close the deferred live `/compact` PreCompact verification on POSIX.
- **INC-3 — Versioned distribution + drift + update (I3-versioning).** FRONTIER · high.
  `.sdad/VERSION` stamp; pin installer/project-init to a release tag; idempotent update
  preserving project state; `$verify` drift mode; `apply-v5.1.*` for the `.claude/` refactor.
- **INC-4 — Release close.** STANDARD · low.
  CLAUDE.md → 5.1 (version + footer + behavior rules for the CI gate and drift check),
  within the +60-line budget (push CI detail into the existing `harness` skill, not inline);
  CHANGELOG `[5.1]`; README what's-new + repo-structure; installer ships the new files;
  `$eval` + `$qa full` green on the matrix; tag `v5.1`.

## §6 Business Rules

1. **CI is additive, never a replacement.** Local hooks stay (fast feedback); CI is the
   authoritative blocker on merge. Do not remove or weaken any v5 local enforcement.
2. **Single source of truth.** CI reuses the existing `checks/` scripts and `run-eval.ps1`;
   it does not reimplement gate logic. The local hook and CI share one policy module.
3. **The v5 eval golden dataset must pass after every increment** (no methodology regression).
4. **Cross-OS parity is first-class.** Every gate/check must be tested on Windows AND at
   least one POSIX OS before its increment closes — the v5 "ship `.sh` untested" pattern is
   not acceptable here (the team is mixed today).
5. **No SPEC.md or command-surface breaks.** v5.0 projects keep working; new surface is
   additive (a `$verify` mode, not a renamed command).
6. **Apply-script discipline.** `.claude/` changes ship via `apply-v5.1.*`: idempotent,
   self-deleting, pure ASCII.
7. **CLAUDE.md +60-line budget per release** ([LOCK]); voluminous CI detail → `harness` skill.

## §7 Integrations & APIs

| Integration | Role | Maturity / notes |
|---|---|---|
| GitHub Actions | CI host; runs the gate/ratchet/eval workflow on PRs | Standard; GitHub-hosted runners (Windows/macOS/Ubuntu) ship `pwsh` or install it cheaply. Assumes repo is public (installer uses unauthenticated `raw.githubusercontent` URLs) → free runner minutes. |
| `raw.githubusercontent.com/<repo>/<ref>/...` | Distribution channel for `install.*` / `project-init.*` | Existing mechanism; v5.1 changes the `<ref>` from `main` to a pinned release tag. Supply-chain integrity addressed in §9. |
| `pwsh` (PowerShell Core) | Runs `.ps1` checks + eval on POSIX runners | Cross-platform; the reuse path that avoids reimplementing checks per OS. |

No third-party MCP is consumed by this release (the §7 MCP-vs-CLI rule does not apply).

## §8 Testing Strategy

| Test | Type | Trigger |
|---|---|---|
| Fixture PR: code file + no approved SPEC → CI fails | integration (CI) | INC-1, every PR |
| Fixture PR: code file + approved SPEC → CI passes | integration (CI) | INC-1 |
| Fixture: non-ASCII `.ps1` → CI fails (ascii-ps1) | integration (CI) | INC-1 |
| Fixture: wrong-case `CLAUDE.md` ref → CI fails (claude-md-case) | integration (CI) | INC-1 |
| `pre-tool-use-spec-gate.sh` scenarios 01-05 on macOS + Linux | parity | INC-2 |
| Two P2 edge cases (BSD `sed`, space paths) confirmed/fixed | parity | INC-2 |
| `$eval` deterministic core green on Windows/macOS/Linux matrix | regression | INC-2, release gate |
| Live `/compact` PreCompact write + SessionStart re-inject on POSIX | manual | INC-2 |
| Install version N → bump central to N+1 → update brings repo to N+1, state intact | integration | INC-3 |
| `$verify` drift mode flags a lagging repo | integration | INC-3 |
| `apply-v5.1.*` idempotent + self-deleting + ASCII | manual + ascii check | INC-3 |
| `$qa full` + `$eval` green on final v5.1 state, all three OSes | release gate | INC-4 |

## §9 Security & Compliance (Tier 2 — Business)

This release introduces a real security surface even though it ships no end-user product:
it governs CI execution and a distribution channel that reaches many client repos.

**Data classification.** No end-user PII is collected or processed. Sensitive data in scope:
- **CI secrets / tokens** — `GITHUB_TOKEN` and any repo/org secrets available to the workflow.
- **Contributor identity** — PR author, commit author (already public in git history); the
  typed §13 log records model/effort/author per increment (not personal data beyond git).

**Controls (must hold before release):**
- **Token scope (least privilege).** The workflow declares minimal `permissions:`
  (`contents: read`, `pull-requests: read` — no write unless a specific job needs it).
  No secret is required for the gate/ratchet/eval jobs; do not grant secrets the gate
  does not need.
- **Workflow-injection hardening.** Trigger on `pull_request` (not `pull_request_target`)
  so untrusted PR code cannot run with elevated token/secret access. Never interpolate
  untrusted PR text (titles, branch names, file contents) into shell `run:` steps; pass
  via environment variables and quote. No checkout of untrusted code into a privileged job.
- **Secrets never in logs.** Gate/ratchet/eval output must not echo tokens or secrets;
  `gate.log` and CI logs carry decisions and paths, not credentials (mirrors the v5
  fail-open log discipline).
- **Supply-chain integrity of the installer.** Pinning the install `<ref>` to a release
  **tag** (not `main`) removes the "latest main is whatever was just pushed" exposure; the
  pinned tag is an auditable, immutable point. Document that consumers should install from a
  tag. (Stronger integrity — checksums / signed releases — is recorded as an open item, §12.)
- **Error sanitization.** CI failure messages are generic + actionable (name `$spec` /
  `$docfinal`, the offending file) and never include secret values or full environment dumps.

**Audit trail.** The PR + CI run history is the append-only audit log for "was the gate
enforced on this change" (actor = PR author, action = merge attempt, resource = changed
files, timestamp = run time) — GitHub retains it and application users cannot delete it.
The typed §13 log is the per-increment authorship record.

**Tier 2 DoD additions (mapped to this project):**
- [ ] No secret/token exposable in CI logs or `gate.log`.
- [ ] Workflow uses least-privilege `permissions:` and `pull_request` (not `_target`).
- [ ] No untrusted PR input interpolated into shell steps.
- [ ] Installer documented to pin to a release tag (supply-chain).
- [ ] CI failure messages sanitized (no stack/secret leakage).

## §10 Definition of Done (release gate for v5.1)

- A PR adding code without an approved SPEC is blocked **in CI**, OS-independently
  (proven on Windows + at least one POSIX OS).
- `$eval` and the gate scenarios pass on Windows, macOS, and Linux (matrix green).
- The `.sh` spec-gate passes scenarios 01-05 on macOS + Linux; the two P2 edge cases are
  resolved or recorded as resolved.
- Live `/compact` PreCompact verification confirmed on a POSIX OS (v5 deferred item closed).
- A SDAD version installs from a pinned tag, writes `.sdad/VERSION`, and updates idempotently
  to a newer tag without clobbering SPEC/DECISIONS/LESSON; `$verify` reports drift.
- Local hook + CI share one policy module; eval 01-05 still pass after the refactor.
- §9 Tier 2 controls all satisfied.
- All `.ps1`/`.sh` pure ASCII; `apply-v5.1.*` idempotent + self-deleting.
- CLAUDE.md within the +60-line budget; version + footer = 5.1.
- v5.0 compatibility verified: an existing v5.0 SPEC.md still loads and `$pause` reports
  correctly.
- CHANGELOG `[5.1]`, README what's-new, and docs updated and consistent. Tag `v5.1`.

## §11 Out of Scope (this release)

- **The entire v6 portfolio layer:** central Lesson Library flow-down/up (I5), per-client
  compliance isolation, `$portfolio` telemetry aggregation, merge-friendly per-increment
  DECISIONS/§13 restructure (I4), architecture gate generalization (I6), Deploy/Operate
  Phase 5 (I7), product-level eval harness (I8), multi-dev coordination/locks (I9), team
  cost governance (I10), state compaction/embeddings (I11). All deferred to v6.0.
- **Rolling CI out to the ~30 client repos** (organizational adoption — this repo cannot
  write to them; v5.1 ships the capability + reference implementation + adoption path).
- **Choosing a different distribution mechanism** (submodule / package): see §12 OD-1.
- **GitLab CI / Azure DevOps** workflow variants (GitHub Actions only, [LOCK] D1).
- **Automated repo bootstrap** (detect new-vs-existing project, `gh repo create`, push,
  auto-enable branch protection via `gh`): deferred to v6. v5.1 keeps repo creation +
  branch-protection activation as a documented manual adoption step (OD-5).

## §12 Open Decisions

| # | Decision | Status |
|---|---|---|
| OD-1 | Distribution mechanism stays the **versioned installer** (raw-download pinned to a tag), same shape as v5 — confirmed for v5.1, but **revisit in v6** whether submodule / versioned package is better at portfolio scale. | Decided (provisional) |
| OD-2 | Drift detection surface: extend **`$verify`** (drift mode). | Decided 2026-06-15 |
| OD-3 | CI detail home in CLAUDE.md: fold into the existing **`harness`** skill (conserves +60 budget). | Decided 2026-06-15 |
| OD-4 | Stronger installer supply-chain integrity (checksums / signed releases) beyond tag-pinning. | Deferred to v6 |
| OD-5 | Branch protection: **enforce** it. On this reference repo, enable "require status checks to pass" so the CI gate actually blocks merges (not advisory). For downstream client repos this is a mandatory documented setup step (this repo cannot set their GitHub config remotely). Verified constraint: branch protection / rulesets are NOT enforced on **private** repos under a free plan — they require GitHub Pro/Team+ (see OD-6). On free private repos the CI gate runs and reports but cannot block merges. | Decided 2026-06-15 — implement at INC-1 |
| OD-6 | **Adoption prerequisite (organizational):** the team is on personal GitHub accounts today, with no corporate Organization. For OD-5 enforcement on private client repos, a corporate GitHub **Organization** + **Team plan** (US$4/user/mo, 3000 Actions min/mo; verified 2026-06) is required. Documented as a rollout prerequisite in the adoption guide (INC-4). CI-minute efficiency: full Windows/macOS/Linux matrix on release/schedule, Linux-only per PR (macOS/Windows runner-minute multipliers — verify exact factors in billing). | Recorded 2026-06-15 — adoption guidance, not a v5.1 code item |

## §13 AI Authorship Log

| Increment | Feature | Model | Effort | Files | Tests | QA findings | Date |
|---|---|---|---|---|---|---|---|
| SPEC v5.1 | CI Foundation spec (I1+I2+I3-versioning) | claude-opus-4-8[1m] | high | SPEC.md | n/a | n/a | 2026-06-15 |
| INC-1 | Shared spec-gate policy module + CI gate workflow (I1) | claude-opus-4-8[1m] | high | checks/spec-gate-policy.{sh,ps1}, checks/spec-gate-ci.sh, .github/workflows/sdad-gates.yml, .sdad/eval/scenarios/14-ci-spec-gate-policy, .claude/hooks/pre-tool-use-spec-gate.{ps1,sh} | eval 14/14; ascii+case clean; CI runner deny/allow verified | 1 open: H-01 C-P1 (self-modifying-gate) | 2026-06-15 |
| INC-2a | POSIX edge-case hardening + H-01 gate-from-base (I2 partial) | claude-opus-4-8[1m] | high | checks/spec-gate-policy.sh, checks/ascii-ps1.sh, checks/spec-gate-ci.sh, .github/workflows/sdad-gates.yml | Win+GitBash 9/9 (spaced paths + base-policy override); eval 14/14 | H-01 resolved; INC-2b (matrix) pending | 2026-06-15 |

---

G7 AI Development Methodology | SDAD v5.1 "CI Foundation" | SPEC.md
