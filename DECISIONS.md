# DECISIONS — SDAD v4.2 Development

Decision log for the v4.2 roadmap execution (spec: `SDAD_v42_ROADMAP_FINAL.md`).
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
