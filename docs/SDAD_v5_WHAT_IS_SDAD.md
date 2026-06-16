# What is SDAD — and why use it

**G7 AI Development Methodology · SDAD v5 "Harness Edition"**
*An extended explainer for developers, analysts, and decision-makers.*

---

## The one-sentence version

SDAD (Spec-Driven AI Development) is a methodology that turns Claude Code from a fast
but unpredictable code generator into a disciplined engineering process — spec first,
small verified increments, integrated quality assurance, persistent memory across
sessions, and, as of v5, hard rules enforced in code rather than merely requested in a prompt.

---

## 1. The problem SDAD exists to solve

An AI coding agent is extraordinarily capable and extraordinarily willing. Ask it to
build something and it will start typing immediately — before anyone has decided what
"done" means, what the data really looks like, what must not happen, or how it will be
tested. The result is the failure pattern every team using these tools recognizes:
plausible code that solves the wrong problem, silent assumptions baked into a thousand
lines, no record of *why* a decision was made, and a model that cheerfully forgets all
of it when the session ends.

The instinct is to fix this by writing a better prompt — "always write tests", "ask
before assuming", "don't touch the database". That helps, but it has a ceiling. A prompt
is a *suggestion to a probabilistic system*. On a good day the model follows it. On a
long, token-heavy day, under pressure, it drifts. You cannot build reliability on a
foundation that is, by construction, optional.

SDAD's answer is process plus structure: decide before you build, build in small
verifiable steps, review every step, and remember everything. v5 adds the missing half
of that answer — make the rules that matter *binding*, not optional.

---

## 2. How SDAD works, in practice

SDAD runs as a set of commands inside Claude Code, structured as phases. You never have
to program to use it; you answer questions and approve steps.

The core loop is **Context -> Requirements -> Spec -> Build -> QA**.

- `$spec` walks you through requirements one question at a time, always proposing a
  sensible default, and reads your repo first so it never asks what it can already infer.
  The first question sets the project language (English or Spanish), which then governs
  every document and every interaction.
- `$specout` writes a complete, 13-section specification to `SPEC.md` in your repo. This
  is the contract. Nothing gets built until you approve it.
- `$build` implements the spec in *vertical increments* — one small, complete feature at
  a time — and runs the project's real tests after each one. It announces what it will do
  before doing it, including which model and reasoning effort it recommends.
- `$qa` reviews each increment across security, structure, efficiency, and best-practice
  layers (plus a platform layer for Pyplan projects), and never silently changes
  security or compliance code without your explicit approval.

Around that loop sit supporting capabilities: compliance tiers that escalate rigor for
customer-facing or regulated work; a Lesson Library that captures recurring patterns so
the same mistake is not made twice; sub-agents that do expensive reviews in isolated
context; and session continuity that lets you stop and resume without re-explaining
anything. Specialist "skills" (architecture, security, QA, frontend, Pyplan, and more)
load automatically when the work calls for them.

---

## 3. The architecture behind v5: harness engineering

The intellectual leap in v5 comes from harness engineering — the discipline that says
the *harness* (the software layer governing an AI agent's execution loop, tools, context,
and state) is now the binding constraint on reliability, more than the model's raw
intelligence. A frontier model inside a weak harness is a brilliant engine with no
guardrails; a modest model inside a strong harness is dependable.

Harness engineering decomposes a reliable agent system into six governance functions,
written H = (E, T, C, S, L, V):

- **E — Execution Loop:** the observe-think-act cycle and, crucially, what happens when
  something errors. A loop with undefined error handling can run away forever.
- **T — Tool Registry:** the typed, validated boundary between the model and the outside
  world. If an agent must not delete a database, that rule belongs *here, in code* — not
  as a polite sentence in a prompt.
- **C — Context Manager:** compaction, retrieval, and prioritization so the conversation
  never blows past the budget and cost stays linear.
- **S — State Store:** memory that survives across turns and sessions, committed safely so
  a crash cannot corrupt it.
- **L — Lifecycle Hooks:** the interception layer — approvals for dangerous actions,
  audit trails, and heartbeats that detect an agent stuck making zero progress.
- **V — Evaluation Interface:** instrumentation that captures what the agent actually did,
  with success signals, so you can tell whether a change made things better or worse.

### Where SDAD already stood (v4.3)

Measured against this framework, SDAD was already strong where it owns the layer:

- **Context (C):** genuinely well done. A context budget with a soft warning at 50% and a
  hard block on new builds at 65%; `$pause compress` that compacts a whole session into a
  portable snapshot carrying only the locked decisions; sub-agents that run in isolated
  context so they don't consume the main budget; binary documents converted to compact
  Markdown before reading.
- **State (S):** the trio of `CLAUDE.md` + `SPEC.md` + `DECISIONS.md` is exactly the
  "permanent project memory" pattern harness engineering prescribes, backed by git and
  session hooks.
- **Tools (T):** for Pyplan projects exposing MCP tools, the §D catalog enforces typed,
  documented, serializable tool contracts — a real, validated tool registry.

And it correctly *delegated* the low-level execution loop and generic tool plumbing to
Claude Code itself, rather than reinventing them.

### What v5 fixes

The audit found one philosophical gap and one genuine hole:

1. **Governance by instruction, not by code.** Almost every important rule in SDAD — "no
   code before an approved Spec", the build-blocking gates — lived only as prose in
   `CLAUDE.md`. By the field's own central axiom, that makes them suggestions. v5 moves
   the critical gate into a `PreToolUse` hook (code), so writing code without an approved
   spec becomes *structurally impossible*, not just discouraged.

2. **No evaluation of the methodology itself (V).** SDAD revises itself every release,
   yet had no way to detect whether a change quietly degraded it — regressions surfaced
   only when a real project later failed. v5 adds a small golden-dataset evaluation
   harness (`$eval`) that replays canonical scenarios and flags regressions before release.

3. **A ratchet on the wrong layer.** SDAD's Lesson Library learns from mistakes — but it
   encoded each lesson as a *sentence*. Lesson L-01 (a PowerShell encoding rule) is marked
   "confirmed twice," meaning the instructional ratchet already failed once. v5 reanchors
   the ratchet: a lesson with a checkable pattern now generates an actual check in code, so
   a fixed failure mode cannot recur.

This is why v5 is a major version. SDAD stops being *a very good prompt* and becomes
*a prompt plus an enforced harness.*

---

## 4. Why governance-by-code beats governance-by-prompt

The distinction is the whole point, so it is worth stating plainly. A prompt rule and a
code rule look similar on paper and behave completely differently under stress.

A prompt rule — "do not write code before the spec is approved" — depends on the model
choosing to comply on this particular turn, with this particular context window, after
this many tokens. It usually works. "Usually" is the problem.

A code rule — a hook that refuses the file-write tool unless an approved `SPEC.md` exists
— does not depend on the model's mood, context length, or compliance. The action is
simply not available. The failure mode is removed from the space of possible outcomes.

Harness engineering's governance axiom captures it: *structural constraints are
non-negotiable; natural-language pleading is merely a suggestion.* v5 applies this exactly
where it matters (the build gate, the recurring-lesson ratchet) while keeping prompt
instructions for everything that is guidance rather than a hard boundary. You don't put
everything in code — only the things that must never happen.

---

## 5. Why use it — even if you are not a developer

The most common worry is that a methodology like this is for hardcore engineers. The
opposite is true: SDAD exists so that someone who is *not* a developer can direct serious
software work safely.

You work by answering questions and approving steps, in your own language. SDAD does the
reading, the writing, the testing, and the reviewing. The spec gives you a plain-language
contract you can actually evaluate before any code exists. The increments are small enough
to follow. The QA layers catch the security and quality issues you wouldn't know to look
for. The compliance tiers automatically raise the bar when the work touches user data or
regulated environments. And the Lesson Library means the system gets a little smarter and a
little safer with every project, without you having to remember anything.

v5's enforcement makes this safer still. The build gate means the agent literally cannot
skip the spec and start improvising — the discipline no longer relies on you policing it.
For a non-developer automating real work, that is the difference between trusting a process
and hoping for one.

---

## 6. What you get, summarized

A spec-first contract before any code. Small, tested increments instead of large
unverifiable dumps. Integrated security and quality review. Persistent, portable memory
across sessions. Compliance rigor that scales with risk. A learning loop that prevents
repeat mistakes. And, in v5, the rules that matter enforced in code — plus a way to test
the methodology against itself before every release.

The short version: SDAD makes AI-assisted development *predictable*. v5 makes its most
important promises *binding*.

---

G7 AI Development Methodology | SDAD v5 "Harness Edition" | 2026
