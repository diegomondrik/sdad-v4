# DECISIONS — SDAD v4.2 → v5.0 Development

Decision log for the v4.2 roadmap and the v5.0 "Harness Edition" build
(specs: `SDAD_v42_ROADMAP_FINAL.md`, `SDAD_v5_BUILD_BRIEF.md`).
Each `[LOCK]`-prefixed decision must not be reopened without explicit developer override.

## [LOCK] decisions (carried into every COMPACT ANCHOR)
- [LOCK] MCP-vs-CLI: security is a hard gate — never reduce it to a token/cost choice (C-011).
- [LOCK] CLAUDE.md stays lean: short critical rules inline, voluminous content → on-demand skills (§2.0).
- [LOCK] CLAUDE.md net line budget ≤ +60 per release (raised from +40 in v4.3 — the
  Model & Effort Routing table gates every phase and belongs inline; the "stays lean"
  rule above is unchanged: voluminous content still goes to on-demand skills) (§2.0).
- [LOCK] Anchor survival = PreCompact writes to disk + SessionStart re-injects after compaction; PreCompact's own injection does NOT survive (verified vs docs).
- [LOCK] No API dependency in the methodology — prompt caching is documentation + structure only (cost/team-reach) (C-004).

---

## Increment 1 — C-011: MCP vs CLI rule

════════════════════════════════════════════════════════
📋 HUB BLOCK — DECISIONS_SDAD-v4.md
════════════════════════════════════════════════════════
Date: 2026-06-05
Increment: 1 — C-011 MCP vs CLI rule
Model: opus (claude-opus-4-8) · effort high
Decision: Add a consumer-context CLI-vs-MCP evaluation rule to $specout §7, cross-referenced from $qa Layer 1 (Security), with security as a hard gate (condition c).
Rationale: Many active third-party MCPs degrade context/cost during $build; a CLI wrapper can be cheaper for single-endpoint tasks — but only when it adds no greater security risk. Producer context (Pyplan §D / @mcp_tool) is excluded because there MCP is the correct architecture.
Alternatives considered: (a) token-only rule with no security clause — rejected per roadmap §1 finding #4 (ignores security); (b) blanket "prefer CLI" — rejected, contradicts §D producer context.
Impact: CLAUDE.md edited in 3 places ($specout §7 subsection, $qa Layer 1 line, Behavior Rules line). Δ +15 net lines. No code surface. DECISIONS.md created.
════════════════════════════════════════════════════════

**§2.1 — single-source validation evidence (validated with Diego, 2026-06-07):**
G7 environments today run FEW simultaneous third-party MCPs, so the video's original "many MCPs
degrade context/cost" driver barely applies to G7. The rule's real value for G7 is its SECURITY
gate — clause (c): if a CLI wrapper adds shell-injection / credentials-in-argv / fragile-parsing
risk, keep the vetted MCP. Token saving is secondary/future-proofing. This matches how the rule
is built (security-primary), so no change needed — the single-source premise was corrected, not
the rule.

**DoD status (roadmap §6):**
- [x] Rule drafted; security clause present.
- [x] Reviewed against §D (producer context excluded) and $qa Layer 1 (no contradiction).
- [x] §2.1 single-source validation — CLOSED: validated with Diego (few MCPs in G7; value is the security gate).

---

## Increment 2 — C-015: Model notice in increment announcement

════════════════════════════════════════════════════════
📋 HUB BLOCK — DECISIONS_SDAD-v4.md
════════════════════════════════════════════════════════
Date: 2026-06-05
Increment: 2 — C-015 model notice in $build announcement
Model: opus (claude-opus-4-8) · effort low
Decision: Add a 🧠 MODEL line to the $build increment announcement block + a Behavior Rule; the main session does not auto-switch models, so each increment recommends model+effort and waits for the dev to switch if the active session differs.
Rationale: The §2.1b routing logic only helps if surfaced in the flow, not left to the dev's memory. Templated with [model]/[effort] + the heuristic (low = already-specified work, high = risk/open decision) so it serves any SDAD project, not just opus-only v4.2 dev.
Alternatives considered: Hardcode "opus" (as the roadmap literal block does) — rejected; CLAUDE.md is the generic methodology and would mis-serve sonnet-based projects.
Impact: CLAUDE.md edited in 2 places ($build announcement block, Behavior Rules). Δ +6 net lines. No code surface. No §2.1 gate (C-015 is internally derived, not from the source video).
════════════════════════════════════════════════════════

**DoD status (roadmap §6):**
- [x] Announcement emits the 🧠 MODEL line.
- [x] Blocks code-writing when active model/effort differs from the recommendation (Behavior Rule + announcement closing instruction).
- [n/a] §2.1 single-source validation — not applicable (C-015 not derived from the video).

---

## Increment 3 — C-012: Project CLAUDE.md update protocol

Date: 2026-06-05 · Model: opus · effort low
Decision: Add $build step 5.5 (project CLAUDE.md sync on structural increments), a PROJECT
CLAUDE.md PROTOCOL block (contains / excludes / when / soft length), a $pause "last modified"
line, and a Behavior Rule. Explicitly scoped to the developer's own repo CLAUDE.md — not the
SDAD methodology file (avoids self-reference confusion).
Rationale: SDAD managed SPEC/DECISIONS/LESSON but not the project's own CLAUDE.md; it rotted
without a protocol. "What to exclude" (no SPEC.md duplication) is the main control, per roadmap.
Impact: CLAUDE.md $build + $pause + Behavior Rules. No code surface.
§2.1 evidence (validated with Diego, 2026-06-07): With Diego as the sole CLAUDE.md maintainer today,
the multi-author drift risk does NOT apply yet. Validated value = an automatic reminder to update the
project CLAUDE.md right after a structural change (so it is not forgotten), which also scales as G7's
dev team grows (see C-014). Low-cost safety net, kept deliberately. DoD §2.1 CLOSED.

## Increment 4 — C-013: $verify audit (proactive mode)

Date: 2026-06-05 · Model: opus · effort low
Decision: Add `$verify audit` proactive mode (reads package.json / requirements.txt / dep tree,
verifies each against current docs via Context 7 MCP or WebSearch). Trigger: Phase 0 when >30
days since last $build (date source: last §13 entry / git log) or on demand; not per session.
Rationale: $verify was reactive only; existing deps deprecated between sessions went unaudited.
Impact: CLAUDE.md $verify + Behavior Rule. Reactive default behavior unchanged.
§2.1 evidence (validated with Diego, 2026-06-07): G7 projects do get resumed after gaps AND get edited
manually outside SDAD, so dependencies can drift regardless of how the code changed; a proactive Phase-0
audit catches deprecations either way. Scope note: $verify audit checks dependency currency — it does not
generate code. DoD §2.1 CLOSED.

## Increment 5 — C-014: Dev Setup (skill, external links only)

Date: 2026-06-07 · Model: opus · effort low
Decision: Create `.claude/skills/dev-setup/SKILL.md` (on-demand) mapping stable Claude Code
concepts → SDAD with verified live links; register it in CLAUDE.md Active Skills + a $sdad
pointer. Content lives in the skill (per §2.0), not CLAUDE.md.
Rationale: native features that boost SDAD were not discoverable; links-only avoids rot
(roadmap decision 2026-06-05). No transcribed feature names/commands/dates.
Verification: ✅ docs host migrated docs.claude.com → code.claude.com (301), confirmed live
2026-06-07. Concept deep-links (memory, skills, hooks, mcp, sub-agents, routines, cli-reference,
settings) verified against the live overview page.
Impact: new skill file + CLAUDE.md Active Skills (+1) + $sdad pointer (+1; later reclaimed in C-006).
§2.1 evidence (validated with Diego, 2026-06-07): G7 developers are just starting with AI / SDAD /
Claude Code / Pyplan; onboarding discoverability of native features is directly valuable — confirmed
real need, "all help welcome." DoD §2.1 CLOSED.

---

## Increment 6 — C-007: [LOCK] convention + COMPACT ANCHOR

Date: 2026-06-07 · Model: opus · effort low
Decision: Establish the `[LOCK]` prefix in DECISIONS.md for non-reopenable decisions; $pause
compress emits a COMPACT ANCHOR carrying only [LOCK] decisions (plus phase/tier/platform,
approved spec, active increment, open QA, hard constraints) so they survive context compaction.
Rationale: Roadmap rebajó C-007 de "comando nuevo" a extensión de $pause compress (la Opción B
original no sobrevivía a la compactación). El anclaje automático real llega con el hook PreCompact
(Track B); esto es el mecanismo manual/v1.
Kept tight inline (anchor = 2 lines) and reclaimed 1 redundant line from the C-015 announcement
block (QA-driven), so the net CLAUDE.md delta stays within the §2.0 +40 cap.
Impact: CLAUDE.md $pause compress + Behavior Rule; DECISIONS.md [LOCK] section added. No code.
§2.1: not applicable (C-007 derives from the roadmap's own critical revision, not the video).

---

## Increment 7 — Track B Hooks (SessionStart + PreCompact + SessionEnd)

Date: 2026-06-07 · Model: opus · effort high
Decision: Activate three Windows/PowerShell hooks via .claude/settings.json.
- SessionStart: inject COMPACT ANCHOR ([LOCK] decisions) + guarded ff-only git pull.
- PreCompact: write anchor snapshot to .sdad/compact_anchor.md.
- SessionEnd: batch autocommit of whitelisted docs (DECISIONS.md, LESSON_LIBRARY.md) only.

Design corrections (both verified against official Claude Code docs via research subagent):
1. PreCompact CANNOT inject context that survives compaction. The durable mechanism is
   PreCompact-writes-to-disk + SessionStart(matcher includes `compact`)-re-injects-after.
   This fixes the roadmap's original premise and the unsatisfiable DoD §6 PreCompact criterion.
2. Autocommit moved from PostToolUse (per-edit, roadmap original) to SessionEnd (batched) per
   developer decision — cleaner git history, no race with manual commits.

Safeguards implemented: ff-only pull only on clean tracked tree, never blocks startup;
autocommit whitelist (never code), .sdad/HOLD_AUTOCOMMIT sentinel, no empty commit.

Testing on Windows (the §6 gate): all three scripts run as child PowerShell processes with
mock stdin JSON. Caught and fixed a Windows codepage encoding bug (non-ASCII em-dash broke the
parser; mojibake in anchor) — scripts are now pure-ASCII and read/write UTF-8 explicitly.
SessionStart emits valid JSON, anchor unicode clean, read hooks do not mutate the repo.
SessionEnd verified: sentinel-guard blocks; whitelist commits DECISIONS.md only.

Platform note: Windows-first (the test gate). macOS/Linux .sh ports are a documented follow-up.

---

## Increment 8 — C-004: Prompt caching boundary (documentation only)

Date: 2026-06-07 · Model: opus · effort medium
API-access status: NOT used. Decision driven by cost + team reach — Claude Code (the app, flat
subscription) already does prompt caching automatically; the API is pay-per-token and not every
developer has access. Requiring API would fragment the methodology and add variable cost. So
v4.2 scope = document the boundary; actual API-level caching deferred until/unless API access is
confirmed (explicitly NOT a v4.3 nice-to-have — it is access-gated, and the app makes it moot).

Caching boundary (structure context to maximize the app's automatic caching):
- CACHEABLE / stable across a session (keep early and contiguous, change rarely):
    SDAD CLAUDE.md · always-on skills (ai-architect, ai-engineer SKILL.md) · LESSON_LIBRARY.md.
- VOLATILE / not worth caching (changes within a session):
    SPEC.md · DECISIONS.md · the active increment's working state.
Practical rule: do not interleave volatile edits into the always-on layer; keep the stable layer
stable so the app's automatic cache keeps hitting. No code, no API calls, no per-dev cost.

[LOCK] No API dependency in the methodology — caching is documentation + structure only (cost/reach).

---

## Increment 9 — C-006: Lesson retrieval (keyword + tags)

Date: 2026-06-07 · Model: opus · effort medium
Decision: Created LESSON_LIBRARY.md (did not exist) with the `#stack`/`#phase` tag convention,
the L-XX format, and the retrieval note (no embeddings until ~50 entries). CLAUDE.md: renamed the
keyword filter to `$lesson search [kw]` (now tag-aware) and added a Phase 0 rule to surface 2-3
relevant lessons. Net CLAUDE.md delta: 0 — reclaimed the redundant $sdad Dev Setup pointer line
(the dev-setup skill stays discoverable via Active Skills + its trigger).
Seeded L-01 = the Windows PowerShell encoding lesson caught during Track B QA (dogfooding the
Lesson Capture flow). §2.1 evidence (validated with Diego, 2026-06-07): CLOSED with a real case —
L-01 itself emerged in this real session and applies to any future G7 Windows/hooks work; concrete
proof that capturing and surfacing lessons across projects adds value. DoD §2.1 CLOSED.

## Increment 10 — C-010: Sub-agent handoff pattern

Date: 2026-06-07 · Model: opus · effort high
Dynamic-workflows evaluation (roadmap-required, done first): Claude Code already provides native
sub-agent delegation that RETURNS the sub-agent's final message, plus schema-based structured
output. So no custom orchestration/return infrastructure is needed — the real gap (the structured
return) is closed by a lightweight convention, not new machinery.
Decision: Created .claude/agents/HANDOFF_TEMPLATE.md (the AGENT HANDOFF block + rules) and pointed
$agent at it (extended the existing $agent header line — net CLAUDE.md delta 0).

---

## Increment 11 — v4.3: Model & Effort Routing + installer repair

════════════════════════════════════════════════════════
📋 HUB BLOCK — DECISIONS_SDAD-v4.md
════════════════════════════════════════════════════════
Date: 2026-06-10
Increment: 11 — v4.3 Model & Effort Routing + installer repair
Model: claude-fable-5 · effort medium
Decision: Add a Model & Effort Routing section to CLAUDE.md with model-agnostic
tiers (FRONTIER/STANDARD/ECONOMY) and a per-phase routing table; generalize the
🧠 MODEL announcement (C-015) from $build-only to $spec/$specout/$qa full/$docfinal
(only $build blocks on mismatch); pin model+effort in agent frontmatter (Vía B,
roadmap §2.1b). Repair installer drift: install.ps1/sh bumped from v4.1, now ship
dev-setup, brand-design, HANDOFF template, hooks + settings.json (Windows, guarded).
Rationale: Multi-model era (fable/opus/sonnet/haiku) — routing by tier survives
releases; the announcement-in-flow pattern (C-015) is the only mechanism that works
since the session never auto-switches. Installer had silently stopped matching the
declared v4.2 feature set.
Alternatives considered: hardcoding model names in the routing table — rejected
(same reason C-015 rejected hardcoded "opus"); putting the table in a skill —
kept inline because it gates every phase, but flagged vs the [LOCK] lean rule.
Impact: CLAUDE.md +~46 net lines (routing section + brand-design listing + 1
behavior rule) — within the §2.0 cap, raised to ≤ +60/release in v4.3 (developer
decision 2026-06-10; lean [LOCK] unchanged). Agents frontmatter + security-reviewer
skill apply via apply-v4.3.ps1 (one-shot, .claude/ write-protected in Cowork).
install.ps1/sh, README, CHANGELOG, DEVELOPER_MANUAL updated.
════════════════════════════════════════════════════════

---

## Increment 12 — Hooks bash port (macOS/Linux) + cross-platform registration

════════════════════════════════════════════════════════
📋 HUB BLOCK — DECISIONS_SDAD-v4.md
════════════════════════════════════════════════════════
Date: 2026-06-10
Increment: 12 — Hooks bash port (macOS/Linux)
Model: claude-fable-5 · effort high
Decision: Port the three hooks to POSIX sh (session-start.sh, pre-compact.sh,
session-end.sh — 1:1 mirrors of the .ps1 spec) and solve cross-platform
registration with option (a): a single run-hook.sh dispatcher registered in
settings.json as one shell-form command per hook.
Rationale: Verified against the Claude Code hooks docs — shell-form commands run
via `sh -c` on macOS/Linux and via Git Bash on Windows (when available). The
dispatcher detects Windows (MINGW/MSYS/CYGWIN) and delegates to the unchanged,
tested .ps1 scripts, so Diego's Windows setup keeps running the exact same
PowerShell command as before; macOS/Linux runs the .sh ports.
Alternatives considered: (b) settings.json invokes sh + Windows override via
settings.local.json — rejected: hooks from multiple settings files MERGE, so
Windows-with-Git-Bash would double-fire, and Windows breaks until the local
override is created manually. Dual entries in settings.json — rejected for the
same double-fire reason plus a powershell-not-found error on every Mac session.
Known limit (accepted): Windows WITHOUT Git for Windows falls back to PowerShell,
which cannot run `sh` — hooks fail non-blocking; Git Bash ships with Git for
Windows, already required by the SDAD workflow.
Impact: 4 new files in .claude/hooks/ (3 ports + dispatcher), settings.json
commands swapped to the dispatcher, hooks README Platform section rewritten,
install.sh ships all hook scripts + settings.json (guarded), CHANGELOG gap
closed. L-01 honored: .sh scripts tested with ñ/accents/em-dashes — round-trip
clean.
Testing (the task-brief gate, on macOS): 9/9 mock-stdin child-process checks
passed in a scratch repo (valid JSON via jq; unicode clean; pull skipped on
dirty tracked tree, ff-only pull on clean tree with real remote; untracked-only
tree still pulls; anchor snapshot written, exit 0; compact source prefers the
snapshot; HOLD_AUTOCOMMIT respected; only whitelisted files committed — a
deliberately modified code file stayed out; no empty commit). Integration:
real headless Claude Code session fired SessionStart + SessionEnd through the
dispatcher (autocommit landed; pull correctly skipped on dirty tree).
PENDING (manual, needs interactive session): force a /compact in a live session
to see PreCompact fire end-to-end — script + re-injection path already verified.
════════════════════════════════════════════════════════

---

## §13 — AI Authorship Log (v4.2)

| Increment | Feature | Model | Date | Notes |
|---|---|---|---|---|
| 1 | C-011 MCP vs CLI rule | claude-opus-4-8 · effort high | 2026-06-05 | CLAUDE.md $specout §7 + $qa Layer 1 + Behavior Rules. Δ +15 net lines. §2.1 validated 2026-06-07. |
| 2 | C-015 model notice in announcement | claude-opus-4-8 · effort low | 2026-06-05 | CLAUDE.md $build announcement + Behavior Rules. Δ +6 net lines. Templated [model]/[effort], generic. |
| 3 | C-012 project CLAUDE.md protocol | claude-opus-4-8 · effort low | 2026-06-05 | CLAUDE.md $build step 5.5 + $pause + Behavior Rules. §2.1 validated 2026-06-07. |
| 4 | C-013 $verify audit | claude-opus-4-8 · effort low | 2026-06-05 | CLAUDE.md $verify + Behavior Rule. §2.1 validated 2026-06-07. |
| 5 | C-014 dev-setup skill | claude-opus-4-8 · effort low | 2026-06-07 | New .claude/skills/dev-setup/ + CLAUDE.md registration. Links verified live. §2.1 validated 2026-06-07. |
| 6 | C-007 [LOCK] + COMPACT ANCHOR | claude-opus-4-8 · effort low | 2026-06-07 | CLAUDE.md $pause compress + Behavior Rule + DECISIONS.md [LOCK] section. |
| 7 | Track B hooks (SessionStart/PreCompact/SessionEnd) | claude-opus-4-8 · effort high | 2026-06-07 | 3 PowerShell hooks + settings.json. Tested on Windows; encoding bug fixed. Design corrected vs docs. |
| 8 | C-004 caching boundary (doc only) | claude-opus-4-8 · effort medium | 2026-06-07 | Documented cacheable vs volatile; no API (cost/reach). Implementation deferred (access-gated). |
| 9 | C-006 lesson retrieval | claude-opus-4-8 · effort medium | 2026-06-07 | LESSON_LIBRARY.md created (+ L-01) + $lesson search + Phase 0 surfacing. CLAUDE.md net 0. |
| 10 | C-010 agent handoff | claude-opus-4-8 · effort high | 2026-06-07 | HANDOFF_TEMPLATE.md + $agent pointer. Native delegation evaluated — no custom infra needed. CLAUDE.md net 0. |
| 11 | v4.3 Model & Effort Routing + installer repair | claude-fable-5 · effort medium | 2026-06-10 | CLAUDE.md routing section (+~44 net) + agent frontmatter (staged) + install.ps1/sh repair + README/CHANGELOG v4.3. |
| 12 | Hooks bash port (macOS/Linux) | claude-fable-5 · effort high | 2026-06-10 | 3 .sh ports + run-hook.sh dispatcher + settings.json. Test gate 9/9 on macOS + real-session integration. Live /compact check pending. |

---

## Context budget tracker (roadmap §2.0 — cap +40 net for all of v4.2)

| Item | Δ net lines | Running total |
|---|---|---|
| C-011 | +15 | +15 |
| C-015 | +6 | +21 |
| C-012 | ~+10 | ~+31 |
| C-013 | ~+7 | ~+38 |
| C-014 | +2 (skill holds the rest) | ~+40 |
| C-007 | +2 (−1 clawback) | ~+40 |
| Hooks | 0 (note flipped; logic in scripts) | ~+40 |
| C-004 | 0 (doc in DECISIONS) | ~+40 |
| C-006 | 0 (−1 clawback; content in LESSON_LIBRARY) | ~+40 |
| C-010 | 0 (content in HANDOFF_TEMPLATE) | ~+40 |

**FINAL measured net delta (CLAUDE.md): 549 − 509 = +40 — exactly at the §2.0 cap, not over.**
Voluminous content (C-014 dev-setup, C-010 handoff, hooks logic, C-004/C-006 detail) lives in
separate skill/hook/template/library files, per the [LOCK] "CLAUDE.md stays lean" decision.

---

## v4.2 Definition of Done (roadmap §6) — status

DONE: C-011, C-012, C-013, C-014, C-015, C-007, Hooks (tested on Windows), C-006, C-010,
PreCompact-survival design corrected, §2.0 budget within cap, CLAUDE.md v4.2 + §13 done,
branch pushed to origin.
§2.1 single-source validation: CLOSED 2026-06-07 — validated with Diego for C-011/C-012/C-013/
C-014/C-006. Premises "many simultaneous MCPs" (C-011) and "multi-author drift" (C-012) were
corrected against G7 reality; the rules stand on their real value (security gate, onboarding,
resume/manual-edit audit, lesson reuse). See each increment's evidence line.
DEFERRED (access-gated, not v4.3-by-choice): C-004 API-level caching implementation.
OUT OF v4.2 (agreed): C-009 git worktrees.
PENDING (developer): open the PR; live auto-compaction test of the anchor (verifiable only in real use).

## Increment 13 — v5 I1: PreToolUse spec-gate hook

════════════════════════════════════════════════════════
📋 HUB BLOCK — DECISIONS_SDAD-v5.md
════════════════════════════════════════════════════════
Date: 2026-06-12
Increment: 13 — v5 I1: PreToolUse spec-gate hook (R3)
Model: claude-fable-5 · effort high
Decision: Spec gate enforced in code — PreToolUse hook (ps1 + sh via dispatcher)
denies Write/Edit on code files when SPEC.md is absent or lacks the exact marker
'SPEC STATUS: APPROVED'. Allowlist (md/docs/.sdad/.claude/hub) and DOCFINAL_ACTIVE
sentinel exempt; unknown extensions allow (fail-open bias); internal errors
fail open with a gate.log trace.
Rationale: Governance Axiom — "no code before approved Spec" moves from prompt
instruction to structural guarantee, independent of model compliance.
Alternatives considered: JSON permissionDecision output instead of exit 2 —
rejected: exit-2-plus-stderr is the documented simple path and the brief's contract.
Impact: _staging_v5/hooks/ (2 scripts), 5 eval scenarios (.sdad/eval/scenarios/01-05,
doubling as the I3 golden dataset), apply-v5.ps1 already registers via dispatcher.
Known trade-off: each Write/Edit pays PowerShell startup latency (~200-500ms) —
accepted as the price of enforcement. Known limit: .sh variant pending macOS test.
Test result: 5/5 scenarios pass on Windows; ASCII check 7/7 files clean.
════════════════════════════════════════════════════════

## Increment 14 — v5 I2: Lesson-to-Guardrail ratchet (ASCII check)

════════════════════════════════════════════════════════
📋 HUB BLOCK — DECISIONS_SDAD-v5.md
════════════════════════════════════════════════════════
Date: 2026-06-12
Increment: 14 — v5 I2: Lesson-to-Guardrail code ratchet (R2)
Model: claude-fable-5 · effort high
Decision: L-01 becomes executable — checks/ascii-ps1.{ps1,sh} (mirrored pair,
one engine per platform context) wired into BOTH paths: session-end hooks warn
and skip autocommit on violation (visibility), .git/hooks/pre-commit blocks the
commit (enforcement — the deliberate hard stop). checks/ ships versioned at the
repo root; pre-commit installs via apply-v5.ps1 (.git/hooks is unversioned).
Rationale: the instructional ratchet failed (L-01 "confirmed twice") — a fixed
failure mode must be structurally unable to recur.
Alternatives considered: single canonical script called cross-context — rejected:
calling powershell from git's sh on every commit is fragile; mirrored pair follows
the established dispatcher precedent. SessionEnd-only wiring — rejected: L-01
recurred in manual commit flow, which only pre-commit covers.
Impact: checks/ (new, 2 files), _staging_v5/hooks/session-end.{ps1,sh} (patched,
idempotency marker 'v5 I2 ratchet wired'), _staging_v5/git-hooks/pre-commit,
apply-v5.ps1 steps 3-4, eval scenarios 06-07.
Known limit: unquoted file lists in sh loops split on spaces (P2, relative paths
make it moot for this repo). L-03 captured separately from I1.
Test result: 7/7 eval scenarios pass (5 I1 regression + 2 new); pre-commit
verified blocking dirty and allowing clean commits in a temp repo via git's sh.
════════════════════════════════════════════════════════

## Increment 15 -- v5 I3: $eval runner + golden dataset (V component)

================================================================
HUB BLOCK -- DECISIONS_SDAD-v5.md
================================================================
Date: 2026-06-12
Increment: 15 -- v5 I3: $eval runner + golden dataset
Model: claude-fable-5 . effort high
Decision: SDAD gains its V component. .sdad/eval/run-eval.ps1 aggregates every
scenario (one PASS/FAIL line each; exit 0 only on all-pass; stamps
.sdad/eval/last-run with the CLAUDE.md git blob hash). Structural asserts live
in shared lib/assert-claude-md.ps1, consumed by scenario 08 (real CLAUDE.md)
and 09 (planted-regression self-test per SPEC s8). OD-1 RESOLVED: three LLM
smoke scenarios (spec-language, build-gate, sdad-surface) as a data table in
llm-smoke.ps1 -- release gate only, via run-eval.ps1 -Release. OD-2 RESOLVED
(default yes): SessionStart appends one fail-open reminder line when the
CLAUDE.md hash differs from the last green stamp.
Rationale: methodology regressions must surface before release, not inside a
client project. Deterministic core on every CLAUDE.md/skill change; LLM replay
only at release because it is non-deterministic by nature (R8).
Alternatives considered: scenario-per-folder for the LLM smoke -- rejected, a
single data table keeps OD-1 wording/regex auditable at a glance; mtime-based
reminder -- rejected, the git blob hash survives checkout/pull mtime noise.
Impact: .sdad/eval/ (run-eval.ps1, llm-smoke.ps1, lib/assert-claude-md.ps1,
scenarios 08-09), _staging_v5/hooks/ (session-start .ps1+.sh with OD-2,
pre-compact.ps1 ascii-clean), apply-v5.ps1 step 3 now marker-driven (5 hooks),
.gitignore (last-run is machine state).
Finding surfaced (scoped): the repo-wide ratchet run exposed 5 pre-existing
L-01 violations (3 v4.2 .claude hooks + install.ps1 + project-init.ps1). The
3 hooks are fixed by this increment's staged ASCII copies; install.ps1 and
project-init.ps1 defer to I10 (their rework increment -- the 14 section signs
sit inside the generated SPEC template and need templating care, not a blind
replace). Interim degradation is visible, not silent: session-end skips
autocommit with a gate.log warning; pre-commit only blocks when a dirty .ps1
is actually staged.
Test result: eval core 9/9 (includes I1+I2 regression); OD-2 reminder 6/6
subcases (ps1 + sh engines, temp fixtures); -Release wiring verified
fail-closed (claude CLI absent on this machine -- full LLM replay pending,
runs at the I10 release gate after CLI install).
================================================================

## Increment 16 -- v5 I4: $agent liveness wrapper (heartbeat)

================================================================
HUB BLOCK -- DECISIONS_SDAD-v5.md
================================================================
Date: 2026-06-13
Increment: 16 -- v5 I4: $agent heartbeat / liveness (R4)
Model: claude-opus-4-8 . effort high
Decision: $agent delegation gains .sdad/lib/agent-run.{ps1,sh} -- a wrapper that
runs `claude --print` with a timeout (OD-3 RESOLVED: 600s / 10 min default) and
an empty-output check. Exit contract surfaced to the caller: 0 ok, 1 empty/
missing output, 2 timeout (process killed), 3 claude CLI absent. Never proceeds
silently on non-zero. The CLAUDE.md $agent protocol rewire to call the wrapper
is deferred to I9 (consolidated reframe, +60 budget).
Rationale: raw `claude --print` only detected empty output; a zombie sub-agent
(running, zero progress) stalled indefinitely. A timeout converts a hang into a
fast, visible failure -- consistent with the existing empty/missing rule.
Alternatives considered: true output-progress liveness (watch bytes over time)
-- rejected as overkill for SPEC F5, which requires only timeout + empty
detection; GNU `timeout(1)` dependency -- rejected, not portable to BSD/macOS,
so the sh port polls with kill -0 instead.
Location decision: .sdad/lib/ (methodology code, testable in-repo, not the
write-protected .claude/ harness namespace), versioned via a !.sdad/lib/
gitignore exemption mirroring the .sdad/eval/ precedent. agent_output.tmp stays
gitignored (runtime state).
Impact: .sdad/lib/agent-run.ps1+.sh (new), .sdad/eval/scenarios/10-agent-timeout
(new), .gitignore (lib exemption + agent_output.tmp). Testability hook:
SDAD_AGENT_EXE env override injects a self-contained stand-in; real callers
never set it.
Test result: eval core 10/10 on Windows (ps1 engine: timeout->2, empty->1);
sh engine verified directly via Git Bash (timeout->2, empty->1). ASCII clean.
================================================================

## Increment 17-18 -- v5 I5 (typed s13) + I6 (E-termination), eval-locked

================================================================
HUB BLOCK -- DECISIONS_SDAD-v5.md
================================================================
Date: 2026-06-13
Increment: 17-18 -- v5 I5 typed s13 (R5) + I6 E-termination on tool error (R6)
Model: claude-opus-4-8 . effort high
Decision: Both supporting increments lock their contract in code now; their
CLAUDE.md protocol text lands in the I9 consolidated reframe (respects the +60
budget -- no mid-build CLAUDE.md churn). I5: scenario 11 asserts SPEC.md s13
carries the 8-column schema (Increment, Feature, Model, Effort, Files, Tests,
QA findings, Date) in order with 8 cells per data row -- a free-form regression
now fails $eval. I6: scenario 12 proves the E-termination contract (SPEC F4) on
the staged session-end.ps1 -- autocommit is suppressed while .sdad/HOLD_AUTOCOMMIT
exists and resumes once removed.
Rationale: the typed log and the recovery sentinel already exist (the schema in
SPEC s4/s13, the sentinel honored by session-end since v4.2). v5's job is to make
them regression-proof before the I9 prose codifies the workflow. Test-first locks
the behavior so the I9 edit cannot silently break it.
Alternatives considered: write the CLAUDE.md protocol now per increment --
rejected, repeated CLAUDE.md edits churn the +60 budget and risk version-stamp
drift; I9 consolidates all I1-I6 prose in one controlled pass. Separate commits
per increment -- folded into one: both are the eval-assert halves of rules whose
prose ships together in I9; two s13 rows preserve per-increment traceability.
Impact: .sdad/eval/scenarios/11-typed-section13, 12-hold-autocommit (new);
SPEC.md s13 (two typed rows). No code surface beyond eval.
Test result: eval core 12/12. Scenario 12 needed EAP=Continue around git (L-03,
native stderr) and core.autocrlf=false in the temp repo.
================================================================

## Increment 19 -- v5 I9: CLAUDE.md v5.0 reframe + Control Layer (Harness skill)

================================================================
HUB BLOCK -- DECISIONS_SDAD-v5.md
================================================================
Date: 2026-06-13
Increment: 19 -- v5 I9: CLAUDE.md v5.0 reframe + Control Layer
Model: claude-opus-4-8 . effort high
Decision: CLAUDE.md becomes v5.0-coherent. Inline (net +12 this increment, +55
cumulative vs v4.3 baseline 589, within the +60 [LOCK], headroom 5): $eval
command registered; Harness added to the on-demand skill list; five behavior
rules added as single physical lines (Governance Axiom, $eval/ratchet trigger,
$agent liveness via agent-run, E-termination + HOLD_AUTOCOMMIT, atomic commit +
model pin); version + footer bumped to 5.0. The voluminous Control Layer detail
(the H=(E,T,C,S,L,V) enforcement table, the two hard stops, determinism, what
$eval checks) ships as a new on-demand skill .claude/skills/harness/ via
apply-v5.ps1 step 5 -- the R4 escape hatch, keeping the inline footprint lean.
Rationale: I1-I8 added machinery the methodology file did not yet describe; I9
makes CLAUDE.md describe and govern it without breaching the line budget. The
budget [LOCK] is the binding constraint, so detail goes to a skill, not inline.
Alternatives considered: full mapping table inline -- rejected, would blow the
+60 [LOCK] (~+30 lines); no skill, prose-only behavior rules -- rejected, loses
the conceptual frame the v5 identity change needs.
Side fix: the budget assert (.sdad/eval/lib/assert-claude-md.ps1, from I3) queried
'git show v4.3:CLAUDE.md' but the tag tracks 'Claude.md' -- the gate silently
no-opped. Now resolves the name via git ls-tree case-insensitively, so the +60
[LOCK] is actually enforced (it caught this increment at 651>649 mid-edit).
PROJECT_LANGUAGE: deliberately NOT hardcoded into the shippable template (would
force 'es' on every downstream install); this project's language stays recorded
in SPEC.md only.
Impact: CLAUDE.md (version, $sdad, $eval block, Harness skill line, 5 behavior
rules), _staging_v5/skills/harness/SKILL.md (new), apply-v5.ps1 (step 5 + header),
SPEC.md s13.
Test result: eval core 12/12; CLAUDE.md 644 lines (delta +55 of 60); version
stamp 5.0 header==footer; self-test scenarios 08 (asserts) + 09 (planted
regression) pass -- language-first rule and build gate still trigger post-edit.
================================================================

## Increment 20 -- v5 I10: docs, CHANGELOG, README, installers, L-01 debt (closes release)

================================================================
HUB BLOCK -- DECISIONS_SDAD-v5.md
================================================================
Date: 2026-06-15
Increment: 20 -- v5 I10: release-closer (docs + installers + L-01 debt)
Model: claude-opus-4-8 . effort high
Decision: ship the v5.0 release surface. (1) Three v5 docs rendered to
self-contained HTML5 from their MD sources, matching the v4 doc style
(INSTALL, USER_GUIDE, WHAT_IS_SDAD) -- ADR-005 (human-readable HTML, machine-
readable MD). (2) CHANGELOG [5.0] entry (Keep a Changelog: Overview, upgrade
note, Added/Changed/Fixed, Known gaps) folding the merged bash-hook port out of
[Unreleased]. (3) README reframed to v5.0: what's-new section, repo-structure
updated (checks/, .sdad/eval, .sdad/lib, harness skill, gate hook, apply-v5),
$eval in commands, verification + docs tables. (4) install.ps1/.sh and
project-init.ps1/.sh ship the harness layer (gate hook pair, checks/ ratchet,
.sdad/eval seed via auto-mkdir download loop, .sdad/lib wrapper, harness skill)
and install the git pre-commit inline. (5) L-01 debt closed: install.ps1 +
project-init.ps1 are now pure ASCII -- ratchet went 5->3 (the 3 remaining are the
.claude session hooks, ASCII-clean in staging, applied by apply-v5).
Rationale: I1-I9 built and governed the harness; I10 makes it installable by
downstream projects and consistent across every release artifact.
Alternatives considered: download the pre-commit from the repo -- rejected, its
staging source is deleted by apply-v5, so the installer writes it inline instead;
enumerate eval scenario dirs in a mkdir list -- rejected for an auto-mkdir
download loop (handles arbitrary nesting, no drift).
Templating note (careful L-01 fix, not blind replace): the 14 section signs in
project-init's generated SPEC template are emitted via [char]0x00A7 so the .ps1
source stays ASCII while the produced SPEC.md keeps SDAD's section notation;
em-dashes in generated content downgraded to ASCII '-'.
Side fixes found during the increment: (a) install.ps1/.sh fetched the
methodology file as '$REPO/Claude.md' but GitHub raw is case-sensitive and the
tracked file is CLAUDE.md -- it would 404 on a fresh install; corrected, and the
"SDAD v4" presence grep generalized to "SDAD v". (b) QA P1: the inline pre-commit
written by install.ps1 used Set-Content (CRLF) -- a CRLF shebang breaks sh on
Windows ("bad interpreter"); now written LF via [IO.File]::WriteAllText. (c)
SPEC_blank.md s13 aligned to the I5 typed 8-column schema (install.ps1 seeds
SPEC.md from it). (d) README verification table had a stale $SM line and listed
on-demand skills as always-on -- corrected.
Impact: docs/SDAD_v5_{INSTALL,USER_GUIDE,WHAT_IS_SDAD}.html (new),
docs/TASK_HOOKS_MACOS_PORT.md (rescoped to spec-gate.sh + live /compact),
CHANGELOG.md, README.md, install.ps1, install.sh, project-init.ps1,
project-init.sh, SPEC_blank.md, SPEC.md s13.
Residuals (honest, non-blocking): "all .ps1 ASCII" completes when the developer
runs apply-v5 (the 3 .claude hooks; .claude is write-protected in Cowork, staging
verified 0); live v4.x $pause is a runtime check (no schema break -- verified
structurally). Both documented.
Test result: eval core 12/12; ascii ratchet 5->3 (expected); install.ps1 +
project-init.ps1 ASCII-clean and parse with 0 errors.
================================================================

---

# DECISIONS - SDAD v5.1 "CI Foundation" (spec: SDAD_v6_BUILD_BRIEF.md I1-I3, SPEC.md)

## [LOCK] decisions (v5.1)
- [LOCK] D1 - CI platform is GitHub Actions (remote on GitHub; pwsh on all 3 runners reuses checks/ + run-eval.ps1 without reimplementation).
- [LOCK] D2 - The CI foundation ships as its own release (v5.1) BEFORE v6, self-hosted on this repo as the reference implementation.
- D3 (provisional, revisit in v6) - distribution stays the versioned installer (raw-download pinned to a tag), same shape as v5; reevaluate submodule/package at portfolio scale.

## Increment 1 - Shared spec-gate policy module + CI gate workflow (I1)

================================================================
HUB BLOCK - DECISIONS_SDAD-v4.md
================================================================
Date: 2026-06-15
Increment: 1 - shared spec-gate policy module + CI gate workflow (v5.1 I1)
Model: claude-opus-4-8 (FRONTIER) - effort high
Decision: Factor the spec-gate decision into one shared module (checks/spec-gate-policy.{sh,ps1}) consumed by BOTH the local PreToolUse hook (per tool call) and a new CI runner (checks/spec-gate-ci.sh, per changed file in a PR), plus a GitHub Actions workflow (.github/workflows/sdad-gates.yml) that re-runs the gate + ascii-ps1 + claude-md-case on ubuntu and the $eval core on windows for every pull request.
Rationale: A gate that lives only on each developer's machine is per-machine, not per-repo; moving it to the pipeline where all commits converge makes it a team guarantee. One shared policy module means local and server enforcement cannot drift (SPEC F4).
Alternatives considered: (a) reimplement gate logic in the workflow YAML - rejected (drift between local and CI); (b) keep the local hook's inline logic and add a conformance test - rejected (catches drift but does not prevent it structurally); (c) run $eval core on ubuntu in INC-1 - deferred: run-eval.ps1 + the 14 scenarios hardcode the Windows `powershell` host, so eval runs on windows-latest now and INC-2 ports it to pwsh + the 3-OS matrix (tested on real POSIX, not faked).
Impact: NEW checks/spec-gate-policy.sh, checks/spec-gate-policy.ps1, checks/spec-gate-ci.sh, .github/workflows/sdad-gates.yml, .sdad/eval/scenarios/14-ci-spec-gate-policy/. REFACTOR .claude/hooks/pre-tool-use-spec-gate.{ps1,sh} to delegate to the policy module (behavior-preserving). No CLAUDE.md change yet (version bump + behavior rules are INC-4). .claude written directly here (methodology repo is not Cowork write-protected); distribution to consumer repos via apply-v5.1 in INC-3/INC-4.
Test result: eval core 14/14 PASS (gate scenarios 01-05 unchanged after refactor); ascii-ps1 + claude-md-case clean on new files; spec-gate-ci.sh in a scratch repo denies code-without-approved-spec (exit 1) and allows it once SPEC.md is approved (exit 0).
Open QA finding: H-01 (C-P1) self-modifying-gate bypass - a PR can edit the gate scripts it runs under. Mitigation pending developer decision (CODEOWNERS/required-review on checks/ + .github/, and/or run the gate from the base ref). Proposed for INC-2.
================================================================

## Increment 2 - Cross-OS parity + CI matrix + H-01 fix (I2) [IN PROGRESS]

### INC-2a (done, committed 2b0eb87) - POSIX hardening + H-01 end-to-end
================================================================
HUB BLOCK - DECISIONS_SDAD-v4.md
================================================================
Date: 2026-06-15
Increment: 2a - POSIX hardening + H-01 gate-from-base (v5.1 I2, partial)
Model: claude-opus-4-8 (FRONTIER) - effort high
Decision: (1) Resolve the two known P2 POSIX edge cases - spec-gate-policy.sh
  uses POSIX parameter expansion instead of sed (BSD/GNU parity, spaces-safe);
  ascii-ps1.sh builds its file list as positional params with newline IFS.
  (2) Fix H-01 (L-05): the CI gate runs its decision logic from the TRUSTED base
  ref, not the PR checkout. spec-gate-ci.sh honors a SPEC_GATE_POLICY override;
  the workflow extracts the base-ref spec-gate-ci.sh + policy and runs them, with
  a bootstrap fallback for the PR that first introduces the gate.
Rationale: a control that runs from the PR's own checkout can be neutered by the
  same PR (L-05); running it from base closes that. CODEOWNERS (the other option)
  only enforces under a paid GitHub Org, which the team does not have yet (OD-6).
Impact: checks/spec-gate-policy.sh, checks/ascii-ps1.sh, checks/spec-gate-ci.sh,
  .github/workflows/sdad-gates.yml.
Test result: Windows + Git Bash - 9/9 hardening subcases (incl. spaced paths +
  base-policy override); eval core 14/14. True cross-OS proof is INC-2b (matrix).
================================================================

### INC-2b (REMAINING - resume here next session)
- Port the eval to pwsh: run-eval.ps1 (lines 38, 58) and the scenarios that spawn
  `powershell` (01,02,03,04,05,06,08,09,10,12,13,14) + pre-tool-use-spec-gate.ps1
  (the policy call) -> host-detected exe ($PSVersionTable.PSEdition Core -> pwsh).
  Also fix Windows-only constructs in scenarios for POSIX: `$env:TEMP` ->
  [IO.Path]::GetTempPath(); literal `.claude\hooks\...` backslash paths -> forward
  slashes. These only verify on the real matrix.
- Add the 3-OS eval matrix (ubuntu/windows/macos) to sdad-gates.yml.
- Open a PR to run the matrix; iterate to green; record platform deltas here.
- Live /compact PreCompact verification on a POSIX OS: INTERACTIVE manual test,
  not CI-automatable; needs a human on macOS/Linux (see TASK_HOOKS_MACOS_PORT.md).
- On INC-2 close: write the full DECISIONS entry + §13 row + re-run $eval.
Cost note: if the repo is private, the macOS leg burns Actions minutes (~10x);
  prefer public, or limit the macOS leg to release/schedule.
================================================================

### CI-failure reporting convention (decided 2026-06-15; ratify in CLAUDE.md/harness at INC-4)
- The GitHub Actions run is the primary, append-only audit trail (Tier 2 §9): no
  manual copying of pass/fail. The email is only a notification.
- A CI failure that reflects a real defect is registered as a QA finding H-XX in
  DECISIONS.md (same register as $qa) and noted in the §13 "QA findings" column.
- The fix lands in the increment that owns the failing surface; that increment's
  DECISIONS entry records the resolution + the green run.

### Open QA findings (v5.1)
- H-01 (C-P1) self-modifying-gate bypass -- RESOLVED in INC-2a (gate runs from base ref).
- H-02 (eval not hermetic) -- RESOLVED, confirmed green on GitHub CI (all 4 jobs pass on
  the re-run). Lesson L-06 captured (hermetic self-tests; the clean-runner CI is its own
  ratchet). Root cause (from the failing log): scenario 07-precommit-blocks copied an
  INSTALLED .git/hooks/pre-commit,
  which a clean runner lacks (Copy-Item PathNotFound). NOT scenario 10 (earlier guess was
  wrong). Fix: 07 now CONSTRUCTS the pre-commit hook itself (mirror of install.ps1's body)
  and is cross-platform (OS temp dir, forward-slash paths, exec bit on POSIX). Local: eval
  14/14, scenario 07 PASS. Expected to green the windows-latest eval leg on the next run.
  Remaining INC-2b (separate from H-02): pwsh host port for the other scenarios + run-eval
  + the .ps1 hook policy call, fix $env:TEMP / backslash paths, add the 3-OS matrix -- those
  surface when the macOS/Linux legs are added.
================================================================

---

## v5.2 — Inc 1+2: Board platform declaration (CLAUDE.md + SPEC_blank.md)

════════════════════════════════════════════════════════
📋 HUB BLOCK — DECISIONS_SDAD-v4.md
════════════════════════════════════════════════════════
Date: 2026-06-24
Increment: v5.2 Inc 1+2 — Board platform declaration
Model: claude-sonnet-4-6
Decision: PROJECT_PLATFORM: board added as first-class platform following the Pyplan
          pattern — declaration block, §E/§F gates, 4 on-demand skills, Board increment
          checklist in CLAUDE.md, Board Layer 5 in $qa.
Rationale: Reusing proven Pyplan infrastructure minimizes risk; consistent activation
           model reduces cognitive overhead for SDAD users switching between platforms.
Alternatives considered: single monolithic Board skill (rejected — spec-context,
           data-model, capsule, qa-platform have distinct triggers that warrant
           separate files); putting checklist entirely in skill (rejected for Inc 1 —
           kept in CLAUDE.md for parity with Pyplan; will move to board/SKILL.md once
           created in Inc 3).
Impact: CLAUDE.md +60 lines net (at budget limit); SPEC_blank.md +56 lines (§E+§F
        templates); assert-claude-md.ps1 baseline changed from hardcoded v4.3 to
        dynamic latest-tag (collateral fix: enables +60 per release, not +60 from v4.3 forever).
════════════════════════════════════════════════════════

════════════════════════════════════════════════════════
📋 HUB BLOCK — DECISIONS_SDAD-v4.md
════════════════════════════════════════════════════════
Date: 2026-06-25
Increment: Pyplan versioning patch — SDAD v5.2 (no version bump)
Model: claude-opus-4-8
Decision: Add a Pyplan model export + commit convention (.sdad/pyplan-snapshots/
          YYYYMMDD-incN-slug.ppl) to the Build-via-AI Protocol, Pyplan increment
          checklist, and $qa Layer 5. Wire it into .gitignore, project-init
          (hybrid CLAUDE.md/--pyplan detection + testable --scaffold-only mode),
          the pyplan/mcp skill, USER_GUIDE, and the v6 Build Brief (increment Ix).
          Collateral hardening (developer-directed): the L-01 ASCII ratchet, which
          only covered .ps1, now covers .sh too — install.sh and project-init.sh
          sanitized to pure ASCII, checks/ascii-ps1 (.ps1 + .sh mirror) and both
          installers' pre-commit glob extended to *.sh, eval scenarios 06/07 updated.
Rationale: Pyplan application state was not versioned in git; the committed .ppl
           files close the gap without requiring GitHub or any remote — local git
           history is sufficient for recovery. The .sh ASCII gap was a latent
           cross-platform installer failure (same class as L-01 for .ps1), confirmed
           from field experience; ratcheting it in code prevents recurrence.
Alternatives considered: (a) rely on Pyplan's internal version history — rejected:
           not developer-controlled, not linked to SDAD increments, not portable.
           (b) require a GitHub remote — rejected: unnecessary friction, the local
           .ppl files give the same recovery guarantee. (c) exempt .sh from the ASCII
           ratchet (claude's initial F-2 proposal) — rejected by developer: the
           installer breaks on fresh machines, so the rule must be enforced, not waived.
Impact: .gitignore (+3 lines); project-init.ps1/.sh (hybrid scaffold + .sh ASCII);
        install.sh (ASCII rewrite); install.ps1 + checks/ascii-ps1.ps1/.sh (pre-commit
        + scan glob extended to .sh); CLAUDE.md +10 lines net (at patch budget);
        pyplan/mcp SKILL.md (+3 sections); USER_GUIDE §7 (renumber old §7->§8);
        SDAD_v6_BUILD_BRIEF.md (+Ix increment + I4/I9 notes); SPEC.md regenerated.
        $eval PASS 14/14 (golden dataset caught a §13 header regression mid-build).
════════════════════════════════════════════════════════
