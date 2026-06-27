# What is SDAD — and why use it

**G7 AI Development Methodology · SDAD v6.0 "Pyplan Audit Edition"**
*An extended explainer for developers, analysts, and decision-makers.*

---

## The one-sentence version

SDAD (Spec-Driven AI Development) is a methodology that turns Claude Code from a fast
but unpredictable code generator into a disciplined engineering process — spec first,
small verified increments, integrated quality assurance, persistent memory across
sessions, and hard rules enforced in code rather than merely requested in a prompt.

---

## 1. The problem SDAD exists to solve

An AI coding agent is extraordinarily capable and extraordinarily willing. Ask it to
build something and it will start typing immediately — before anyone has decided what
"done" means, what the data really looks like, what must not happen, or how it will be
tested. The result is the failure pattern every team using these tools recognizes:
plausible code that solves the wrong problem, silent assumptions baked into a thousand
lines, no record of why a decision was made, and a model that cheerfully forgets all of
it when the session ends.

The instinct is to fix this by writing a better prompt — "always write tests", "ask
before assuming", "don't touch the database". That helps, but it has a ceiling. A prompt
is a suggestion to a probabilistic system. On a good day the model follows it. Under
pressure, or in a long session, it drifts. You cannot build reliability on a foundation
that is, by construction, optional.

SDAD's answer is process plus structure: decide before you build, build in small
verifiable steps, review every step, and remember everything. The governance axiom states
that hard gates live in code (hooks, ratchet checks, pre-commit guards); prompt rules are
the fallback, not the guarantee.

---

## 2. How SDAD works, in practice

SDAD runs as commands inside Claude Code, structured as phases. You answer questions and
approve steps — no programming required.

The core loop is **Context -> Requirements -> Spec -> Build -> QA**.

- `$spec` walks through requirements one question at a time, always proposing a sensible
  default, and reads the repo first so it never asks what it can already infer.
  The first question sets project language (English or Spanish), which governs every
  document and interaction.
- `$specout` writes a complete, 13-section specification to `SPEC.md`. This is the
  contract. Nothing gets built until it is approved.
- `$build` implements the spec in vertical increments — one small, complete feature at a
  time — and runs the project's real tests after each one. It announces what it will do
  before doing it, including the recommended model and reasoning effort.
- `$qa` reviews each increment across security, structure, efficiency, and best-practice
  layers (plus a platform layer for Pyplan and Board projects), and never silently changes
  security or compliance code without explicit approval.

Around that loop sit supporting capabilities: compliance tiers that escalate rigor for
customer-facing or regulated work; a Lesson Library that captures recurring patterns so
the same mistake is not made twice; sub-agents that do expensive reviews in isolated
context; and session continuity so you can stop and resume without re-explaining anything.

---

## 3. The v6 addition: auditing models you did not build

v6 adds a standalone audit lifecycle for existing Pyplan models: `$audit`.

Where `$docfinal` retroactively documents a codebase SDAD did not build, `$audit` judges
it and recommends. The deliverable is a five-dimension client-facing report:

1. **Development / Architecture** — node design, result= discipline, index synchronization,
   circular dependency check, data source alignment
2. **Security** — API key exposure, MCP token handling, @mcp_tool parameter validation,
   minimum-scope enforcement
3. **Usability** — navigation clarity, cognitive load, task success, empty/error states;
   requires a live-app walkthrough (convention-only when the app is unavailable)
4. **Quality / Maintainability** — code clarity, duplication, naming, docs coverage
5. **Business** — two sub-dimensions:
   - 5a) Alignment: is the objective measurable, do rules trace to a business reason
     (domain-agnostic; requires elicitation from the model owner)
   - 5b) Domain correctness: is the finance formula right, is the safety-stock model sound
     (domain-specific; requires a matching domain profile)

**Evidence-first principle:** the auditor never assumes it can read a Pyplan model as files.
Pyplan applications are server-side. Evidence is acquired from `.ppl` model exports, Pyplan
MCP read endpoints, or manual artifacts supplied by the developer. Un-acquirable areas are
declared "not assessable" with a gap explanation — never silently skipped or fabricated.

**Neutral framing:** the report presents intent vs. delivered factually and
evidence-based. It is never accusatory. The audience is a client who commissioned the model.

---

## 4. Business alignment and domain correctness

Two new dimensions SDAD had not addressed before v6.

**Alignment (domain-agnostic):** most SDAD projects are technically correct but never asked
whether the objective is measurable or whether the business rules trace to a real business
reason. The `business-alignment` skill adds that check in `$build` (before code is written)
and in `$audit` (after the fact). If the model owner is unavailable for elicitation, the
alignment dimension is declared "not assessable" — not invented.

**Domain correctness (domain-specific):** a generic LLM cannot reliably judge whether a
COGS formula double-counts intercompany sales, or whether a safety-stock model uses the
right service-level factor. Domain profiles give the auditor bounded, declared knowledge:

- `domain-finance`: FP&A (consolidation, working capital, FX, NPV/IRR, driver-based planning)
- `domain-supply-chain`: SC operations (safety stock, MEIO, service level, S&OP, bullwhip)

Profiles load on-demand by `PROJECT_DOMAIN`. A model with no matching profile is marked
"not assessable — no domain profile", which is a finding: the client needs a domain SME.
Every domain-correctness finding states a confidence level — an LLM profile raises the floor;
it does not replace the client's subject-matter expert for high-stakes validation.

---

## 5. The harness architecture (v5 onward)

The intellectual foundation of SDAD v5+ is harness engineering — the discipline that says the
harness (the software layer governing an AI agent's execution loop, tools, context, and state)
is the binding constraint on reliability, more than the model's raw intelligence. A frontier
model inside a weak harness is a brilliant engine with no guardrails; a modest model inside a
strong harness is dependable.

SDAD's harness decomposes into six governance functions (E T C S L V):

- **E — Execution Loop:** the observe-think-act cycle, with defined error handling and the
  `.sdad/HOLD_AUTOCOMMIT` escape hatch for mid-increment failures.
- **T — Tool Surface:** which tools the model can call, with the `PreToolUse` spec-gate
  refusing code writes before a Spec is approved.
- **C — Context:** COMPACT ANCHOR injection at session start and compaction; context budget
  monitoring at 50% and 65% thresholds.
- **S — State:** persistent state via `SPEC.md`, `DECISIONS.md`, `LESSON_LIBRARY.md`, and
  the `.sdad/` workspace; session snapshots via `$pause compress`.
- **L — Lessons:** the Lesson Library converting recurring patterns into ratchet checks in
  `checks/` that the git pre-commit hook enforces.
- **V — Verification:** the `$eval` golden dataset (22 deterministic scenarios) that runs
  on every CLAUDE.md/skill change and as the release gate.

---

## 6. What changed in v6

**$audit lifecycle.** Pyplan models built outside of SDAD can now be formally audited.
Five-dimension report, evidence-first, neutral framing. Sibling of `$docfinal`.

**pyplan-mcp skill.** The rules for building and consuming MCP tools in Pyplan models
were documented in CLAUDE.md but had no backing skill file. v6 delivers it.

**business-alignment skill.** Objective measurability and rule traceability are now
checked in `$build` (specification phase) and `$audit` (post-facto). No fabrication
when elicitation input is unavailable.

**Domain profiles.** `domain-finance` and `domain-supply-chain` give the auditor bounded
domain knowledge. Load on-demand by `PROJECT_DOMAIN`. Missing profiles surface as findings.

**22 eval scenarios.** 10 new scenarios (13-22) cover the audit behavioral surface:
fabrication detection, gap surfacing, severity determinism, and usability-no-app.

**apply-v6.* upgrade path.** Existing v5.x checkouts upgrade with a single script — no
manual file management.

---

G7 AI Development Methodology | SDAD v6.0 Developer Guide | 2026
