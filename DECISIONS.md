# DECISIONS — SDAD v4.2 Development

Decision log for the v4.2 roadmap execution (spec: `SDAD_v42_ROADMAP_FINAL.md`).
Each `[LOCK]`-prefixed decision must not be reopened without explicit developer override.

## [LOCK] decisions (carried into every COMPACT ANCHOR)
- [LOCK] MCP-vs-CLI: security is a hard gate — never reduce it to a token/cost choice (C-011).
- [LOCK] CLAUDE.md stays lean: short critical rules inline, voluminous content → on-demand skills (§2.0).
- [LOCK] CLAUDE.md net line budget for v4.2 ≤ +40 (§2.0).
- [LOCK] Anchor survival = PreCompact writes to disk + SessionStart re-injects after compaction; PreCompact's own injection does NOT survive (verified vs docs).

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

**§2.1 — single-source validation evidence:** 🧠 [verificar — pendiente workflow G7]
Reasoned conjecture (NOT yet validated against a real G7 workflow): in G7 Pyplan/FP&A
engagements, sessions frequently run multiple consumer MCPs simultaneously, which the
roadmap (§3 C-011) flags as degrading context and cost. A single-endpoint CLI wrapper
would reduce that footprint — *provided* it does not move credentials into argv/env or
introduce shell-injection/parsing fragility. Diego to replace this line with one concrete
G7 case (which MCP, which task, observed context/cost impact) to close DoD §2.1 for C-011.

**DoD status (roadmap §6):**
- [x] Rule drafted; security clause present.
- [x] Reviewed against §D (producer context excluded) and $qa Layer 1 (no contradiction).
- [ ] §2.1 single-source validation — OPEN (placeholder above; awaiting real G7 workflow line).

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
§2.1 evidence: 🧠 [verificar — pendiente workflow G7]. DoD §2.1 OPEN.

## Increment 4 — C-013: $verify audit (proactive mode)

Date: 2026-06-05 · Model: opus · effort low
Decision: Add `$verify audit` proactive mode (reads package.json / requirements.txt / dep tree,
verifies each against current docs via Context 7 MCP or WebSearch). Trigger: Phase 0 when >30
days since last $build (date source: last §13 entry / git log) or on demand; not per session.
Rationale: $verify was reactive only; existing deps deprecated between sessions went unaudited.
Impact: CLAUDE.md $verify + Behavior Rule. Reactive default behavior unchanged.
§2.1 evidence: 🧠 [verificar — pendiente workflow G7]. DoD §2.1 OPEN.

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
Impact: new skill file + CLAUDE.md Active Skills (+1) + $sdad pointer (+1).
§2.1 evidence: 🧠 [verificar — pendiente workflow G7]. DoD §2.1 OPEN.

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

## §13 — AI Authorship Log (v4.2)

| Increment | Feature | Model | Date | Notes |
|---|---|---|---|---|
| 1 | C-011 MCP vs CLI rule | claude-opus-4-8 · effort high | 2026-06-05 | CLAUDE.md $specout §7 + $qa Layer 1 + Behavior Rules. Δ +15 net lines. §2.1 evidence pending [verificar]. |
| 2 | C-015 model notice in announcement | claude-opus-4-8 · effort low | 2026-06-05 | CLAUDE.md $build announcement + Behavior Rules. Δ +6 net lines. Templated [model]/[effort], generic. |
| 3 | C-012 project CLAUDE.md protocol | claude-opus-4-8 · effort low | 2026-06-05 | CLAUDE.md $build step 5.5 + $pause + Behavior Rules. §2.1 pending [verificar]. |
| 4 | C-013 $verify audit | claude-opus-4-8 · effort low | 2026-06-05 | CLAUDE.md $verify + Behavior Rule. §2.1 pending [verificar]. |
| 5 | C-014 dev-setup skill | claude-opus-4-8 · effort low | 2026-06-07 | New .claude/skills/dev-setup/ + CLAUDE.md registration. Links verified live. §2.1 pending [verificar]. |
| 6 | C-007 [LOCK] + COMPACT ANCHOR | claude-opus-4-8 · effort low | 2026-06-07 | CLAUDE.md $pause compress + Behavior Rule + DECISIONS.md [LOCK] section. |
| 7 | Track B hooks (SessionStart/PreCompact/SessionEnd) | claude-opus-4-8 · effort high | 2026-06-07 | 3 PowerShell hooks + settings.json. Tested on Windows; encoding bug fixed. Design corrected vs docs. |
| 8 | C-004 caching boundary (doc only) | claude-opus-4-8 · effort medium | 2026-06-07 | Documented cacheable vs volatile; no API (cost/reach). Implementation deferred (access-gated). |

---

## Context budget tracker (roadmap §2.0 — cap +40 net for all of v4.2)

| Item | Δ net lines | Running total |
|---|---|---|
| C-011 | +15 | +15 |
| C-015 | +6 | +21 |
| C-012 | ~+10 | ~+31 |
| C-013 | ~+7 | ~+38 |
| C-014 | +2 (skill holds the rest) | ~+40 |

**Measured net delta (CLAUDE.md, 547 − 509 = +38)** — within the §2.0 cap of +40, ~+2 margin.
Track A complete. Track B should claw back margin via skills if it adds volume.
