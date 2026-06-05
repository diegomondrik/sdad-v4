# SDAD v4.1 — CLAUDE.md
# Spec-Driven AI Development for Claude Code
# G7 AI Development Methodology
# Version 4.1 | 2026
#
# INSTALLATION: Place this file at the root of your project repository.
# The .claude/ folder (skills, agents, hooks) is installed by the SDAD installer.
# Run: install.ps1 (Windows) or install.sh (Mac/Linux)

---

## Project Declaration

# ── REQUIRED: set PROJECT_PLATFORM if applicable ──────────────────────────
# PROJECT_PLATFORM: pyplan       ← uncomment for Pyplan projects
# PROJECT_PLATFORM: generic      ← default (no platform-specific skills)
# ──────────────────────────────────────────────────────────────────────────
#
# When PROJECT_PLATFORM: pyplan is set, the following activate automatically:
#   · $spec    → adds §0 (platform), §A (data architecture), §B (discovery log),
#                §D (MCP Tools Catalog — conditional, only when @mcp_tool nodes declared)
#   · $build   → adds Pyplan checklist at increment close (includes MCP surface)
#   · $qa      → adds Platform layer (Layer 5) to QA run (includes MCP tool checks)
#   · Skills   → pyplan-diagram, pyplan-interfaces, pyplan-qa-platform,
#                pyplan-spec-context, pyplan-mcp load on-demand by trigger
#                decision-architecture and data-discovery load on-demand by trigger

---

## Core Rules

- Never write production code before the developer approves a Spec.
  Exception: $docfinal operates without a Spec — it generates one retroactively.
- Always follow: Context Analysis → Requirements → Spec → Build → QA.
- Claude Code has direct filesystem and terminal access — use it.
  Read actual files. Run actual tests. Write directly to the repo.
  Never simulate what you can execute.
- §A (Data Architecture) must be complete before $build is allowed on Pyplan projects.
  Same gate logic as §9 Security on Tier 3 projects.
- §D (MCP Tools Catalog) must be complete before $build is allowed on Pyplan projects
  that declare at least one @mcp_tool node. Same gate logic as §A.

---

## Environment

DIRECT WRITE: yes — always. Claude Code writes files directly to the repo.
State is always the actual filesystem + SPEC.md + git log.

---

## Active Skills

# Skills load from .claude/skills/ using SKILL.md progressive disclosure.
# Two loading modes:

### Always-on (loaded every session, declared here)
- **AI Architect** (.claude/skills/ai-architect/SKILL.md)
  Architecture decisions, LLM integration patterns, cost modeling, red flags.
  Active in all phases. Adds Architecture layer to QA.

- **AI Engineer** (.claude/skills/ai-engineer/SKILL.md)
  Implementation quality, tooling setup, developer experience, UI detection, docs standards.
  Active in all phases. Detects UI in Phase 0.

### On-demand (loaded when description trigger matches task)
- **Security Reviewer** — trigger: security, API keys, PII, auth, vulnerabilities (Phases 3–4)
- **QA Engineer** — trigger: QA, testing, code review, Phase 4, coverage
- **Compliance Reviewer** — trigger: auto-activated on Tier 2/3 confirmation
- **Frontend / UI** — trigger: user interface, components, React, Vue, dashboard, screen design
- **Pyplan Diagram** — trigger: nodes, influence diagram, result=, module, wizard, xarray (Pyplan projects)
- **Pyplan Interfaces** — trigger: interface, component, dashboard, filter, index, chart, KPI (Pyplan projects)
- **Pyplan QA Platform** — trigger: auto-activated by $qa on Pyplan projects (Layer 5)
- **Pyplan Spec Context** — trigger: auto-activated by $spec / $specout on Pyplan projects
- **Pyplan MCP** — trigger: @mcp_tool, MCP tools, dynamic tools, OAuth MCP, §D, mcp_tool decorator (Pyplan projects)
- **Decision Architecture** — trigger: data architecture, DW, staging, data sources, §A
- **Data Discovery** — trigger: data delta, field mismatch, source discrepancy, data gap

Use $skills to view details or activate additional skills manually.

---

## Compliance Tiers

Tier is detected in Phase 0 and confirmed in Phase 1.
Claude recommends a tier based on repo context — developer confirms or overrides.

TIER 1 — STANDARD
  For: internal tools, POCs, productivity scripts, personal projects
  Auto-activates: nothing additional
  DoD additions: none

TIER 2 — BUSINESS
  For: customer-facing products, SaaS, apps handling user data
  Auto-activates: Compliance Reviewer
  DoD additions: audit logging present, PII handling documented, auth reviewed, sanitized errors
  SPEC.md additions: §9 expanded with data classification and retention policy

TIER 3 — ENTERPRISE / REGULATED
  For: cloud deployments to corporate IT, healthcare, finance, government, ISO/SOC2
  Auto-activates: Compliance Reviewer (full profile) + regulation-specific skill
  DoD additions: threat model documented, data flow diagram present, control matrix in SPEC.md
  SPEC.md additions: §9 mandatory — must be complete and approved before $build
  $build is blocked until SPEC.md §9 is complete and approved.
  External skills: add gdpr-compliance / hipaa-compliance / soc2-compliance as applicable

TIER DETECTION (Phase 0, automatic):
  Payment integration, health data, government → recommend Tier 3
  User accounts, external data, client deployment → recommend Tier 2
  Internal script, no user data, no external exposure → recommend Tier 1
  Always confirm with developer in Phase 1 before locking tier.

---

## Context Budget

MONITORING: Estimate context usage after every response, starting from Phase 0.

AT 50% — ⚠️ SOFT WARNING (informational, continue normally):
  "⚠️ CONTEXT ~50% — Extended session. Consider starting a new session after
   completing the current increment."

AT 65% — 🔴 HARD WARNING (action required):
  "🔴 CONTEXT ~65% — Blocking $build after current increment.
   When done: run $pause compress, save state, start a new session."
  → Finish the current increment fully (including tests and $qa).
  → Block any new $build until session is restarted.
  → $pause, $spec, $verify, $lesson, $doc, $flow remain available.

RULES:
  Emit context warnings only at the defined thresholds — never otherwise.
  Hard warning never interrupts mid-increment — always finish cleanly.
  Sub-agents run in isolated context — they do not consume the main session budget.

---

## Sub-Agent Delegation ($agent — automatic)

Delegate automatically when ALL three conditions are true:
  1. The task operates on files already committed to the filesystem.
  2. The task does not require knowledge of decisions made in this session.
  3. The task is expensive in context (doc generation, architectural review, test suite).

Always delegate:  $doc (all variants) · $agent review · $agent test · $agent audit
Never delegate:   $qa after $build · $spec / $specout · $build

EXECUTION:
  Agent files live in .claude/agents/ (code-reviewer.md, test-generator.md, security-auditor.md)
  claude --print "[system context + isolated task]" > .sdad/agent_output.tmp
  Read .sdad/agent_output.tmp and incorporate the result. Delete temp file after.
  WHEN agent_output.tmp is empty or missing → surface error to developer, do not proceed silently.
  Developer sees only the final result — sub-agent mechanics are silent.

---

## Commands

**$sdad** — Show SDAD v4.1 methodology overview: phases, descriptions, command list.

**$spec** (or $spec [section]) — Phase 1: Guided Requirements.
ONE question at a time with proposed default.
Standard order: scope, user flows, data model, integrations, business rules,
performance, security, compliance tier, testing.
Before asking, read existing files in the repo — infer what is already defined.

PYPLAN PROJECTS (when PROJECT_PLATFORM: pyplan):
  Run §0 (platform context) first, then §A (data architecture) before standard sections.
  §A gate: flag explicitly when §A is incomplete — $build is blocked until approved.
  §B (discovery log) is initialized empty — it fills during $build.
  §D gate (conditional): ask "Does this project expose any nodes as MCP tools (@mcp_tool)?"
    If yes: run §D (MCP Tools Catalog) before moving to standard sections.
    §D gate: flag explicitly when §D is incomplete — $build is blocked until approved.
    If no: skip §D entirely — do not create the section.

COMPLIANCE QUESTION (always ask, never skip):
  "What's the deployment context?
   (1) Internal tool / POC — Tier 1 Standard
   (2) Customer-facing product / SaaS — Tier 2 Business
   (3) Regulated environment / corporate IT / cloud enterprise — Tier 3 Enterprise
   Based on what I see in this repo, I recommend: [Tier N — reason]"
  Lock the tier on confirmation. Activate tier-specific skills and DoD immediately.
Suggest $specout when all areas are covered.

**$specout** — Phase 2: Generate full Spec Document.

Standard sections (all projects):
  §1  Vision & Objective
  §2  Users & Roles
  §3  Functional Flows
  §4  Data Model
  §5  Technical Architecture
  §6  Business Rules
  §7  Integrations & APIs
  §8  Testing Strategy
  §9  Security & Compliance (depth depends on tier)
  §10 Definition of Done
  §11 Out of Scope
  §12 Open Decisions
  §13 AI Authorship Log (Increment / Feature / Model / Date / Notes)

Additional sections for Pyplan projects (prepended before §1):
  §0  Platform Context (Pyplan version, workspace, permissions, data types, conventions)
  §A  Data Architecture (client diagnosis, architecture decision, data contract per source)
  §B  Discovery Log (initialized empty — updated during $build when data deltas are found)
  §D  MCP Tools Catalog (conditional — include only when the project declares at least one
      @mcp_tool node. Documents each tool: node identifier, tool name, description,
      parameter names + types + Annotated descriptions, return type, serialization notes.
      §D is a gate section: must be approved before $build when present.)

After generating, write the Spec to SPEC.md in the repo root automatically.
For Tier 2/3: §9 is mandatory and must be complete before approval.
For Tier 3 and Pyplan: respective gate sections (§9 / §A) block $build until approved.
For Pyplan projects with MCP tools: §D blocks $build until approved.
Ask for developer approval before allowing $build.

**$build** (or $build [feature]) — Phase 3: Guided Development.
Requires approved SPEC.md.
WHEN SPEC.md not found: read the repo, then offer $spec or $docfinal — do not proceed.
WHEN no test command found: flag before writing code.
Blocked if Context Budget hard warning (65%) was triggered.
ON PYPLAN PROJECTS: blocked if §A is not marked as approved in SPEC.md.
ON PYPLAN PROJECTS: blocked if §D is present and not marked as approved in SPEC.md.

Before each increment announce:

  🔨 INCREMENT [N]: [feature name]
  Files: [list of files to create or modify]
  Tests: [unit / integration / E2E — will be executed after writing]
  Docs: [README update / API doc / inline comments required]
  Dependencies: [what must be done first]
  ──────────────────────────────────────────────────────
  [Wait for developer approval, then write code, then run tests immediately]

After writing code for an increment:
  1. Run the project's test command. Report actual result — pass count, failures, errors.
  2. Run $qa on the increment.
  3. Write DECISIONS.md entry for this increment (see HUB BLOCK below).
  4. Update SPEC.md §13 AI Authorship Log.
  5. ON PYPLAN PROJECTS: run Pyplan increment checklist (see below).

PYPLAN INCREMENT CHECKLIST (runs after step 4 on Pyplan projects):
  Diagram surface:
    □ All new nodes have result= assigned and calculate without error
    □ No circular dependencies introduced
    □ Data source of read nodes matches §A data contract
  Interface surface:
    □ All new indexes are synchronized
    □ Inputs have type and range validations configured
    □ Visualization components display calculated data (not empty)
  Discovery:
    □ Any data deltas found during this increment recorded in §B and DECISIONS.md
    □ If structural delta found: $build paused, data gap report generated for consultant
  MCP surface (only when project has §D):
    □ Each new @mcp_tool node: docstring explains the business action precisely
    □ All parameters use Annotated[type, 'description'] — no untyped parameters
    □ Return value is serializable (no raw xarray, no bare DataFrames — use .to_dict())
    □ result = _fn assigned — not result = _fn() (function assigned, not called)
    □ Tool does not depend on interactive agent behavior or session state
    □ §D entry created or updated for this tool (identifier, name, description, parameter schema)

DATA DELTA HANDLING (Pyplan projects):
  Small delta (format error, nulls, unexpected volume, wrong field name):
    → Resolve in the node.
    → Record in §B: what was assumed, what was found, how resolved, impact on other nodes.
    → $build continues.
  Structural delta (data does not exist, wrong granularity, source completely different):
    → Pause $build immediately.
    → Generate data gap report: assumption from §A, finding, decision needed.
    → Surface to developer — consultant takes report to client.
    → $build does not resume until consultant records approved resolution in §B.

BUILD-VIA-AI GUARDRAILS (Pyplan MCP — when using Pyplan MCP's build/modify capabilities):
  Pyplan MCP allows AI clients to modify application logic and interfaces directly in a
  running Pyplan instance. SDAD treats each AI-driven modification as an increment.
  Rules:
    1. Spec must be approved before any build/modify action — same gate as $build.
       If Spec is not approved, block the modification and redirect to $spec / $specout.
    2. Each AI-driven modification is announced as an increment before execution
       (same format as the $build increment announcement block).
    3. Wait for developer approval before executing the modification.
    4. After execution: write DECISIONS.md entry and update §13 AI Authorship Log.
    5. Run $qa on the modified increment — no increment is complete without QA.
    6. Run MCP surface checklist for any node modified or created via AI.
  Note: Pyplan MCP is a v1 server (first release). Document it as an external
  dependency in §7 and flag its maturity level in $verify.

**$qa** (or $qa [mode]) — Phase 4: Quality Assurance.

  $qa           → incremental QA on last $build increment (auto mode)
  $qa review    → manual QA — per-finding approval
  $qa full      → full project audit
  $QA           → full standalone audit (SDAD-Aware or Standalone)

QA LAYERS (run in priority order):
  Layer 1 — 🔐 Security: API key exposure, unprotected endpoints, PII in logs (P0),
            missing input sanitization, weak auth (P1), rate limiting, missing headers (P2)
            MCP (Pyplan projects with §D): OAuth token not logged or exposed in node results (P0),
            @mcp_tool parameters validated before use — no path to arbitrary code execution (P1),
            exposed tools have minimum necessary scope — no tool exposes more than its declared contract (P2)
  Layer 2 — 🏗️ Structure: architecture consistency, separation of concerns, error handling,
            context flow, tight coupling
  Layer 3 — ⚡ Efficiency: token usage, redundant calls, conversation history management,
            unbounded loops, latency bottlenecks
  Layer 4 — ✅ Best Practices: readability, maintainability, duplication, naming, docs gaps
  Layer 5 — 🟠 Platform (Pyplan projects only): nodes missing result=, unsynchronized indexes,
            inputs without validations, circular dependencies, Analyst Agent context gaps
            MCP tools (when §D present):
              □ All nodes registered in §D are decorated with @mcp_tool and have result = _fn
              □ All parameters have Annotated[...] with non-empty descriptions
              □ Docstrings are precise enough for an external LLM to invoke correctly
              □ Return values verified serializable — no DataFrames, no xarray without conversion
              □ No tool depends on interactive agent behavior or mutable session state

$qa auto never touches security, compliance, or Spec deviations without human approval.
Security and compliance findings always require explicit developer approval before any fix.

**$verify** — Check dependency documentation currency.
Runs automatically when $build introduces a new external dependency.
When Context 7 MCP is active, $verify uses it automatically.
ON PYPLAN PROJECTS WITH §D: $verify always includes the Pyplan MCP server as an external
dependency. Flag in §7: "Pyplan MCP server — v1 (first release, API may change across
Pyplan updates)." Recommend locking to a specific Pyplan version in §5 if MCP stability
is critical for the project.

**$pause** — Show current session state.
  Current Phase | Spec Status | Compliance Tier | Platform | Context Budget %
  Last increment + test result | Open QA findings (H-XX) | Active Skills
  Decisions log: [N entries — last entry title and date]
  Flows defined: [N] | Next step recommendation

**$pause compress** — Generate Session Snapshot for next session.
  Compact state block for pasting at the start of the next conversation.
  Includes: phase, spec status per section, compliance tier, platform,
  completed increments summary, open QA findings (H-XX), open decisions,
  AI Authorship Log summary, Lesson Library summary (N new entries),
  active skills, context budget %, flows defined, exact next step.
  When a Session Snapshot is detected at conversation start:
  acknowledge and restore all state without asking developer to re-explain.

**$docfinal** — Retroactive Documentation. For projects built without SDAD.
No Spec required. Infers everything from the codebase. Runs 4 steps in sequence.

  $docfinal         → run all 4 steps (default)
  $docfinal spec    → Step 1 only — retroactive SPEC
  $docfinal log     → Step 2 only — AI Authorship Log
  $docfinal qa      → Step 3 only — QA standalone audit
  $docfinal lessons → Step 4 only — lesson candidates

STEP 1 — RETROACTIVE SPEC: Read entire codebase. Write SPEC_RETROACTIVE.md to repo root.
  Never overwrite SPEC.md. Include only sections reliably inferred from code:
  §1, §2, §3, §4, §5, §9, §11, §12. Skip §6, §7, §8, §10.

STEP 2 — AI AUTHORSHIP LOG: Generate §13 table — one row per detected module or feature.
  Increment / Feature / Model: "Pre-SDAD / unknown" / Date from git log / Notes.
  Append to SPEC_RETROACTIVE.md.

STEP 3 — QA STANDALONE AUDIT: Full $QA Standalone mode. All layers including Platform
  if Pyplan is detected. Mark P0 findings with 🚨. Number H-01, H-02...
  Do NOT apply any fixes — report only.
  Close with: "Which fixes would you like me to apply? (H-XX, 'all', or 'none')"

STEP 4 — LESSON CANDIDATES: Evaluate findings and codebase. Propose up to 3 candidates.
  For each: title / Category / Signal / Principle / Add to Lesson Library? (yes/skip/edit)

**$agent** — Sub-Agent Delegation.

  $agent review [module]  → architectural review (uses .claude/agents/code-reviewer.md)
  $agent test [module]    → generate test suite (uses .claude/agents/test-generator.md)
  $agent audit [path]     → security audit (uses .claude/agents/security-auditor.md)

**$doc** — Technical Documentation Generator. Delegates to sub-agent automatically.

  $doc            → full documentation set
  $doc readme     → update README.md
  $doc api        → generate or update API reference
  $doc arch       → generate architecture document
  $doc compliance → compliance summary (Tier 2/3 only)

All $doc outputs written directly to /docs in the repo.

**$flow** — Project Flow Manager.

  $flow [name]       → define a new flow for this project
  $flow list         → list all flows in .claude/flows/
  $flow [name] run   → execute a saved flow
  $flow [name] edit  → update an existing flow

**$lesson** — Lesson Library management.

  $lesson            → show all entries grouped by category
  $lesson [keyword]  → filter by keyword, category, or stack
  $lesson [L-XX]     → show full entry
  $lesson new        → guided entry creation — writes to LESSON_LIBRARY.md on approval

**$skills** — Show active and available AI specialist skills.
  Always active: AI Architect, AI Engineer.
  On-demand: Security Reviewer, QA Engineer, Compliance Reviewer, Frontend,
             Pyplan x5 (diagram, interfaces, qa-platform, spec-context, mcp),
             Decision Architecture, Data Discovery.

---

## HUB BLOCK — auto-generated after each $build increment

After every completed increment, generate and display this block:

  ════════════════════════════════════════════════════════
  📋 HUB BLOCK — DECISIONS_[PROJECT].md
  ════════════════════════════════════════════════════════
  Date: [YYYY-MM-DD]
  Increment: [N] — [feature name]
  Model: [model used]
  Decision: [one-line summary of the main architectural or implementation decision]
  Rationale: [one-line rationale]
  Alternatives considered: [brief — or "none"]
  Impact: [files changed, dependencies added, patterns introduced]
  ════════════════════════════════════════════════════════
  → Copy this block to: hub/DECISIONS_[PROJECT].md

Also write the decision entry directly to DECISIONS.md in the repo root.

---

## Lesson Capture — triggered after $qa

Evaluate after every $qa run. Trigger only when the increment reveals:
  - a bug or failure pattern likely to recur in other projects
  - an integration quirk not documented in official docs
  - an architectural or prompt pattern that significantly simplified the solution
  - a Pyplan-specific pattern (node design, interface structure, data handling)

If triggered, propose ONE entry (most valuable finding only):

  📚 LESSON CANDIDATE — [short title]
  Category: [LLM Design | Architecture | Data & Debugging | Environment | Workflow | Pyplan]
  Signal: [one line — how would another developer recognize this applies to them?]
  Principle: [one transferable sentence]

  Add to Lesson Library? (yes / skip / edit)

If yes: write the full L-XX entry directly to LESSON_LIBRARY.md.
        Also generate HUB BLOCK for LESSONS_RAW.md (Google Drive).
Also evaluate: should this finding become a rule in this project's CLAUDE.md?
If nothing is lesson-worthy: skip silently — never mention it.

---

## Behavior Rules

- Read actual files before asking questions — never ask what you can infer.
- Run actual tests after every $build increment — never skip execution.
- Write SPEC.md to the repo on $specout — never keep the Spec only in chat.
- Write lesson entries to LESSON_LIBRARY.md directly — never ask developer to paste.
- Ask the compliance tier question in Phase 1 — never skip it.
- Activate Compliance Reviewer automatically on Tier 2/3 confirmation.
- Ask one question at a time in $spec — never present a questionnaire.
- Always propose a default — interrupt only when data cannot be inferred.
- Announce increments before coding — never skip the announcement.
- Include docs update in every $build increment announcement.
- Mark critical security issues with 🚨 regardless of current phase.
- Mark compliance violations with 🔒 regardless of current phase.
- Distinguish clearly: "must fix" / "should improve" / "style suggestion".
- Lesson capture is silent when nothing is worth capturing — never force an entry.
- $qa auto never touches security, compliance, or Spec deviations without human approval.
- Update SPEC.md §13 after every completed increment.
- In Phase 0, detect UI presence and suggest frontend skill if applicable.
- $agent delegation is automatic — never ask developer which tasks to delegate.
- $verify runs automatically when $build introduces a new external dependency.
- $pause always includes Context Budget status, Decisions log count, platform, and flows count.
- Write DECISIONS.md entry and HUB BLOCK after each completed increment.
- ON PYPLAN PROJECTS: run increment checklist before marking any increment complete.
- ON PYPLAN PROJECTS: never rely on the Pyplan Analyst Agent — SDAD is self-sufficient.
- ON PYPLAN PROJECTS: structural data deltas pause $build — never improvise a workaround.
- ON PYPLAN PROJECTS WITH MCP: Build-via-AI requires approved Spec — Pyplan MCP does not bypass the Spec gate.
- ON PYPLAN PROJECTS WITH MCP: each AI-driven modification via Pyplan MCP is announced and approved as an increment before execution.
- ON PYPLAN PROJECTS WITH MCP: §D is a gate section when present — $build blocked until §D is approved.
- ON PYPLAN PROJECTS WITH MCP: flag Pyplan MCP as a v1 external dependency in §7 — API may change across Pyplan updates.
- Before session end or $pause compress, resolve any pending commits using git log.

---

## Required Environment Tool

cc-status-line provides a real-time status bar: model, context %, session cost, git branch.
Install via the SDAD installer, or run manually:

  npx cc-status-line@latest

Use as primary context budget indicator — shows the 50% / 65% thresholds.

---

## Complementary Tools
# Developer reference — does not affect Claude behavior.
#
# Warp                    AI-native terminal                   https://warp.dev
# Context 7 MCP           Up-to-date API docs in session       /plugin → "Context 7"
# Sequential Thinking MCP Chain-of-thought reasoning           type "install sequential thinking MCP"
# Happy Engineering        Remote Claude Code control (mobile)  https://happy.engineering
#
# Note: when Context 7 MCP is active, $verify uses it automatically.
# Note: hooks (.claude/hooks/) are prepared but inactive in v4.1.
#       See .claude/hooks/README.md for developer setup instructions.

---

G7 AI Development Methodology | SDAD v4.1 | CLAUDE.md
Spec-Driven AI Development for Claude Code
