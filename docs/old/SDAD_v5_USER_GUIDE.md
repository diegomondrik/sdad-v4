# SDAD v5 — User Guide

**G7 AI Development Methodology · SDAD v5.2 "Board Edition"**
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
sensible default, and reads your existing files first so it never asks the obvious. It
will ask the deployment context to set a compliance tier (internal tool, customer-facing
product, or regulated environment) — this quietly raises the rigor when the work is
riskier. Answer in plain language; say "default" to accept a proposal.

**Get the contract — `$specout`.** SDAD writes a full specification to `SPEC.md`: vision,
users, flows, data, architecture, rules, testing, security, definition of done, and what
is explicitly out of scope. Read it. This is the moment to catch a misunderstanding — it
is far cheaper here than after code exists. Nothing is built until you approve it.

**Build — `$build`.** SDAD implements the spec one small, complete piece at a time. Before
each piece it announces what it will touch, what it will test, and which model/effort it
recommends. After writing, it runs your real tests and reports the actual result, then
reviews its own work.

**Review — `$qa`.** Runs automatically after each increment, checking security, structure,
efficiency, and best practices (plus a platform layer on Pyplan and Board projects). Security and
compliance issues are never fixed silently — SDAD flags them and waits for your go-ahead.

**Pause or stop — `$pause`.** Shows the current state: phase, spec status, compliance tier,
context budget, open findings, decisions logged. `$pause compress` produces a compact
snapshot so a fresh session picks up exactly where this one ended.

---

## 3. What changed for you in v5

Three things are different in daily use, all in the direction of safety.

**The build gate is now real. [v5]** Previously, "don't write code before the spec is
approved" was a rule SDAD followed almost all the time. In v5 it is enforced in code: if
you (or the agent) try to write code in a project without an approved `SPEC.md`, the
action is simply refused. You will see a clear message telling you to run `$spec` first.
Editing documents, notes, and the spec itself is always allowed — the gate only guards
real code. If you genuinely need to document an existing codebase that has no spec, that
path (`$docfinal`) is recognized and not blocked.

*What to do when you hit the gate:* it means you skipped a step. Run `$spec` → `$specout`,
approve the spec, and the gate opens. It is protecting you from the most expensive mistake
in AI development — building the wrong thing fast.

**Lessons now become checks, not just notes. [v5]** When SDAD learns something that can be
checked mechanically (for example, an encoding rule that once caused a bug), it now creates
an actual automated check, not only a written reminder. You do not have to do anything —
the check runs on its own and prevents that specific mistake from recurring.

**You can test the methodology itself — `$eval`. [v5]** Mostly relevant when SDAD itself is
being updated: `$eval` replays a set of known scenarios and confirms the methodology still
behaves correctly. Think of it as a health check you can run after any change to the SDAD
configuration.

---

## 4. Command quick reference

| Command | When | What it does |
|---|---|---|
| `$spec` | Starting work | Guided requirements, one question at a time |
| `$specout` | After `$spec` | Writes the full `SPEC.md` contract |
| `$build [feature]` | After approving the spec | Builds one tested increment |
| `$qa` | After each build | Reviews the increment (auto) |
| `$qa full` | Milestones | Full-project audit |
| `$pause` | Anytime | Shows session state |
| `$pause compress` | Before stopping | Snapshot for the next session |
| `$lesson` | Anytime | View the Lesson Library |
| `$verify` | New dependency | Checks library docs are current |
| `$skills` | Anytime | View/activate specialist skills |
| `$docfinal` | Legacy code | Documents a project built without SDAD |
| `$eval` **[v5]** | After SDAD changes | Runs the methodology health check |

---

## 5. Compliance tiers (set once per project)

SDAD asks for your deployment context in `$spec` and recommends a tier:

- **Tier 1 — Standard:** internal tools, prototypes, personal scripts. No extra overhead.
- **Tier 2 — Business:** customer-facing products and anything handling user data.
  Auto-activates the Compliance Reviewer; adds audit logging, PII handling, and auth review.
- **Tier 3 — Enterprise / Regulated:** healthcare, finance, government, corporate IT. Adds
  a threat model and a data-flow diagram, and blocks the build until the security section
  is complete and approved.

You confirm or override the recommendation. The rigor scales to the risk automatically.

---

## 6. Good habits

Read the spec before approving — it is your main control point. Let increments stay small;
resist asking for everything at once. Watch the context-budget bar — at the 65% mark SDAD
will finish the current increment and ask you to start a fresh session, which keeps quality
high. When SDAD proposes a lesson worth capturing, accept it; that is how the system gets
safer over time. And when the v5 gate stops you, treat it as a reminder, not an obstacle —
it is enforcing the one discipline that matters most.

---

## 7. Pyplan projects — keeping your model in version control

On Pyplan projects, every Build-via-AI increment changes the application logic
directly inside your Pyplan instance. SDAD tracks *what* changed in DECISIONS.md,
but the actual model file lives in Pyplan's workspace — not in git — until you
export it.

After `$qa` passes on each increment, export the model and commit it:

1. Export the model from the Pyplan UI (or via the MCP export endpoint if your
   Pyplan version supports it).
2. Save the file to `.sdad/pyplan-snapshots/` using the naming convention SDAD
   proposes: `YYYYMMDD-incN-slug.ppl`.
3. Include it in the atomic commit for the increment.

The committed `.ppl` files are your version history of the model. If the Pyplan
workspace is lost or corrupted, you can restore any prior increment's state by
loading its `.ppl` file. No GitHub required — local git commits are sufficient.

If you do have a remote (GitHub, GitLab, or a backup remote), push after each
session for an off-machine copy.

---

## 8. If something feels stuck

- **"It refused to write code."** You are missing an approved spec. Run `$spec` →
  `$specout`, approve it. **[v5 gate]**
- **A long review seems frozen.** v5 adds a timeout to delegated sub-agent work; it will
  surface an error rather than hang silently. Re-run the command.
- **You want to resume an old project.** Just run `claude` in the folder — state restores
  automatically. If you compressed the last session, the snapshot is picked up.
- **You need to pause autocommit** (e.g., an open security finding): create an empty
  `.sdad/HOLD_AUTOCOMMIT` file; delete it to resume.

---

G7 AI Development Methodology | SDAD v5.2 User Guide | 2026
