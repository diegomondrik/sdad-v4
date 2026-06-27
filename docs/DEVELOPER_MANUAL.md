# SDAD v6.0 — Developer Manual

**G7 AI Development Methodology · SDAD v6.0 "Pyplan Audit Edition"**
*For everyday use. No programming required — you answer questions and approve steps.*

---

## 1. The mental model

You are the director. SDAD (running inside Claude Code) is the engineering team. You
decide *what* and *why*; it handles *how*, and shows its work at every step so you can
approve or redirect. The whole thing runs as a conversation in your language — the first
question SDAD asks sets English or Spanish for everything that follows.

The rhythm is always the same five beats: understand the context, agree on requirements,
write the spec, build in small steps, review each step.

---

## 2. A normal session, start to finish

**Start.** Open a terminal in your project folder and run `claude`. If you used the
project before, SDAD restores where you left off automatically — you do not re-explain
anything.

**Define what you want — `$spec`.** SDAD asks one question at a time, always proposing a
sensible default, and reads your existing files first so it never asks the obvious. It will
ask the deployment context to set a compliance tier (internal tool, customer-facing product,
or regulated environment) — this quietly raises the rigor when the work is riskier. It also
asks `PROJECT_DOMAIN` (finance, supply-chain, or other) so the right domain-correctness
profile loads. Answer in plain language; say "default" to accept a proposal.

**Get the contract — `$specout`.** SDAD writes a full specification to `SPEC.md`: vision,
users, flows, data, architecture, rules, testing, security, definition of done, and what is
explicitly out of scope. Read it. This is the moment to catch a misunderstanding — it is far
cheaper here than after code exists. Nothing is built until you approve it.

**Build — `$build`.** SDAD implements the spec one small, complete piece at a time. Before
each piece it announces what it will touch, what it will test, and which model and effort it
recommends. After writing, it runs your real tests and reports the actual result, then reviews
its own work.

**Review — `$qa`.** Runs automatically after each increment, checking security, structure,
efficiency, and best practices (plus a platform layer on Pyplan and Board projects). Security
and compliance issues are never fixed silently — SDAD flags them and waits for your go-ahead.

**Pause or stop — `$pause`.** Shows the current state: phase, spec status, compliance tier,
context budget, open findings, decisions logged. `$pause compress` produces a compact snapshot
so a fresh session picks up exactly where this one ended.

---

## 3. Auditing an existing Pyplan model — `$audit`

v6 adds a new starting point for projects SDAD did not build.

**When to use `$audit`:** you have an existing Pyplan model (from any source) and need a
structured, client-presentable assessment. `$audit` does not require an approved SPEC — it
infers from the model evidence.

**How it works:**

1. `$audit` opens an evidence acquisition phase. It requests the model's `.ppl` export
   (preferred), Pyplan MCP read access if available, and any prior discovery or sales documents.
2. An evidence manifest is produced: what was acquired, how, and what could not be acquired.
   Areas with no evidence are declared "not assessable" — never improvised.
3. Five-dimension assessment runs: development/architecture, security, usability, quality,
   and business (alignment + domain correctness).
4. A prioritized improvement backlog and a client-facing report are produced.

**Key boundary:** the report presents what the model *intends* vs. what it *delivers*,
factually and without accusation. The audience is often the client who commissioned the model.

**Modes:**

| Command | What it does |
|---------|--------------|
| `$audit` | Full five-dimension audit |
| `$audit [dimension]` | Single dimension only (e.g. `$audit security`) |
| `$audit report` | Generate or regenerate the client report from existing evidence |

---

## 4. What changed for you in v6

**`$audit` is now available.** [v6] You can assess any Pyplan model, even one you did
not build, and produce a structured five-dimension client report. SDAD acquires evidence
first and declares honestly what it could not access — it never fabricates findings.

**Business alignment is checked in `$build`.** [v6] When writing the spec, SDAD now
flags non-measurable objectives and business rules with no traceable reason. This catches
misaligned requirements before code exists, not after.

**Domain correctness profiles.** [v6] If your project's domain is finance or supply chain,
SDAD loads the matching profile and checks domain-specific correctness. A COGS formula that
double-counts intercompany, a safety-stock model with the wrong service-level factor — these
are now assessable. The profile states its confidence level; it is a floor, not a substitute
for your domain expert.

**22 eval scenarios.** [v6] `$eval` now covers the full audit behavioral surface, including
fabrication detection and severity determinism, so methodology regressions are caught before
they reach a client.

---

## 5. Command quick reference

| Command | Phase | What it does |
|---------|-------|--------------|
| `$sdad` | Any | Methodology overview: phases, commands, active skills |
| `$spec` | 1 | Guided requirements: one question at a time |
| `$specout` | 2 | Generate and write `SPEC.md` |
| `$build` | 3 | Implement one increment, run tests, run `$qa` |
| `$qa` | 4 | Quality review: security, structure, efficiency, best practices, platform |
| `$audit` | Any | Five-dimension audit of an existing Pyplan model (no Spec needed) |
| `$verify` | Any | Check dependency documentation currency |
| `$pause` | Any | Show current session state |
| `$pause compress` | Any | Generate compact snapshot for the next session |
| `$docfinal` | Any | Retroactive documentation for a codebase built without SDAD |
| `$eval` | Any | Run the 22-scenario golden dataset to verify methodology health |
| `$agent review` | 3-4 | Architectural review via sub-agent |
| `$agent test` | 3-4 | Generate test suite via sub-agent |
| `$agent audit` | 3-4 | Security audit via sub-agent |
| `$doc` | Any | Generate documentation (README, API, architecture, compliance) |
| `$flow` | Any | Define, list, or run a project flow |
| `$lesson` | Any | Show, search, or add lesson library entries |
| `$skills` | Any | Show active and available AI specialist skills |

---

## 6. Sessions and context

**Context budget.** The status bar shows context usage in real time (ccstatusline).
SDAD acts at two thresholds:
- **50%** — soft warning: consider finishing the current increment and starting a new session.
- **65%** — hard warning: `$build` blocks after the current increment finishes cleanly.
  Use `$pause compress` to snapshot state, then resume in a new session.

**Session continuity.** `$pause compress` produces a compact state block — paste it at the
start of the next session. SDAD restores phase, spec status, compliance tier, open findings,
and the next step without re-explanation.

**Between sessions.** The hooks autocommit `DECISIONS.md` and `LESSON_LIBRARY.md` at
session end. The COMPACT ANCHOR (locked decisions) re-injects automatically at session start.

---

## 7. Compliance tiers

Tier is detected in Phase 0 and confirmed with you.

| Tier | For | Key additions |
|------|-----|---------------|
| Tier 1 — Standard | Internal tools, POCs, scripts | None |
| Tier 2 — Business | SaaS, customer-facing, user data | Audit logging, PII handling, auth review |
| Tier 3 — Enterprise | Regulated environments, corporate IT | Threat model, data flow diagram, §9 gate |

For Tier 3 projects, `$build` is blocked until §9 (Security & Compliance) is complete and
approved. The Compliance Reviewer skill activates automatically on Tier 2/3 confirmation.

---

## 8. Platform support

**Pyplan projects** (`PROJECT_PLATFORM: pyplan` in CLAUDE.md):
- `$spec` adds §0 (platform context) and §A (data architecture) — §A is a build gate.
- `$build` runs the Pyplan increment checklist (nodes, interfaces, MCP surface).
- `$audit` is available to assess existing models without a Spec.
- Snapshot exports to `.sdad/pyplan-snapshots/` after each increment.

**Board projects** (`PROJECT_PLATFORM: board` in CLAUDE.md):
- `$spec` adds §E (Board Data Model — gate) and §F (Board Capsule Structure).
- `$build` enforces entity creation order (Entities → Relationships → Cubes) and
  algorithm syntax (block letters, Board functions only).
- `$qa` Layer 5 covers 10 named Board checks (DM-01..06, CP-01..05, SEC-01).

---

G7 AI Development Methodology | SDAD v6.0 Developer Manual | 2026
