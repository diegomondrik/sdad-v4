# SDAD v6.0 — Usage and Shortcuts

**G7 AI Development Methodology · SDAD v6.0 "Pyplan Audit Edition"**
*All commands, tips, and daily-use patterns in one place.*

---

## 1. Full command reference

### Core workflow

| Command | Description |
|---------|-------------|
| `$sdad` | Show methodology overview: phases, active skills, command list |
| `$spec` | Start guided requirements (one question at a time) |
| `$spec [section]` | Resume a specific section (e.g. `$spec security`) |
| `$specout` | Generate and write the full SPEC.md (13 sections) |
| `$build` | Start the next increment |
| `$build [feature]` | Start a specific named increment |
| `$qa` | Incremental QA on the last `$build` increment (auto mode) |
| `$qa review` | Manual QA — per-finding approval |
| `$qa full` | Full project audit across all layers |
| `$QA` | Standalone full audit (SDAD-Aware or Standalone) |

### Audit lifecycle (v6)

| Command | Description |
|---------|-------------|
| `$audit` | Five-dimension audit of an existing Pyplan model (no Spec needed) |
| `$audit [dimension]` | Single dimension: `security`, `usability`, `business`, etc. |
| `$audit report` | Generate or regenerate the client-facing report from existing evidence |

### Documentation and verification

| Command | Description |
|---------|-------------|
| `$verify` | Check dependency documentation currency (auto after `$build` adds a dep) |
| `$verify audit` | Proactive: audit all dependencies against current docs |
| `$docfinal` | Retroactive documentation for projects built without SDAD |
| `$docfinal spec` | Step 1 only: retroactive SPEC |
| `$docfinal log` | Step 2 only: AI Authorship Log |
| `$docfinal qa` | Step 3 only: QA standalone audit |
| `$docfinal lessons` | Step 4 only: lesson candidates |
| `$doc` | Full documentation set (README, API, architecture, compliance) |
| `$doc readme` | Update README.md |
| `$doc api` | Generate or update API reference |
| `$doc arch` | Generate architecture document |
| `$doc compliance` | Compliance summary (Tier 2/3 only) |

### Session management

| Command | Description |
|---------|-------------|
| `$pause` | Show current session state |
| `$pause compress` | Generate compact snapshot for the next session |

### Sub-agents

| Command | Description |
|---------|-------------|
| `$agent review [module]` | Architectural review via sub-agent |
| `$agent test [module]` | Generate test suite via sub-agent |
| `$agent audit [path]` | Security audit via sub-agent |

### Methodology health

| Command | Description |
|---------|-------------|
| `$eval` | Run all 22 golden-dataset scenarios; report pass/fail |
| `$eval release` | Full release gate: deterministic + LLM smoke |

### Lessons and flows

| Command | Description |
|---------|-------------|
| `$lesson` | Show all entries grouped by category |
| `$lesson search [kw]` | Filter by keyword, category, or stack |
| `$lesson [L-XX]` | Show a specific entry |
| `$lesson new` | Guided entry creation |
| `$flow [name]` | Define a new flow |
| `$flow list` | List all flows |
| `$flow [name] run` | Execute a saved flow |
| `$flow [name] edit` | Update a flow |

### Skills

| Command | Description |
|---------|-------------|
| `$skills` | Show active and available AI specialist skills |

---

## 2. Always-active skills

These load every session:

| Skill | What it adds |
|-------|-------------|
| AI Architect | Architecture decisions, LLM integration patterns, cost modeling, red flags |
| AI Engineer | Implementation quality, tooling setup, docs standards, UI detection |

---

## 3. On-demand skills (load when trigger matches)

| Skill | Trigger |
|-------|---------|
| Security Reviewer | security, API keys, PII, auth, vulnerabilities |
| QA Engineer | QA, testing, code review, Phase 4, coverage |
| Compliance Reviewer | auto on Tier 2/3 confirmation |
| Frontend / UI | user interface, components, React, Vue, dashboard |
| Brand Design | brand, visual identity, brand tokens, logo, color palette |
| Pyplan Audit | auto on `$audit`; auditing existing Pyplan models |
| Pyplan Diagram | nodes, influence diagram, result=, module, wizard, xarray |
| Pyplan Interfaces | interface, component, dashboard, filter, index, chart, KPI |
| Pyplan QA Platform | auto on `$qa` on Pyplan projects (Layer 5) |
| Pyplan Spec Context | auto on `$spec` / `$specout` on Pyplan projects |
| Pyplan MCP | @mcp_tool, MCP tools, dynamic tools, OAuth MCP, §D |
| Business Alignment | measurable objective, traceable rule, value vs cost, §1/§6 |
| Domain Finance | PROJECT_DOMAIN: finance; FP&A correctness checks |
| Domain Supply Chain | PROJECT_DOMAIN: supply-chain; SC correctness checks |
| Decision Architecture | data architecture, DW, staging, data sources, §A |
| Data Discovery | data delta, field mismatch, source discrepancy |
| Dev Setup | onboarding, dev setup, Claude Code features complementing SDAD |
| Harness | control layer, harness model, governance axiom, E/T/C/S/L/V |
| Board Spec Context | auto on `$spec`/`$specout` on Board projects |
| Board Data Model | entity, cube, relationship, dimension, §E (Board) |
| Board Capsule | capsule, screen, procedure, layout, mask, §F (Board) |
| Board QA Platform | auto on `$qa` on Board projects (Layer 5) |

---

## 4. QA layers

`$qa` runs layers in priority order. Security and compliance findings always require
explicit approval before any fix.

| Layer | Focus |
|-------|-------|
| 1 — Security | API key exposure, unprotected endpoints, PII in logs (P0); missing sanitization, weak auth (P1); rate limiting, missing headers (P2); MCP token handling and scope |
| 2 — Structure | Architecture consistency, separation of concerns, error handling, coupling |
| 3 — Efficiency | Token usage, redundant calls, unbounded loops, latency bottlenecks |
| 4 — Best Practices | Readability, maintainability, duplication, naming, docs gaps |
| 5 — Platform | Pyplan: nodes, indexes, validations, MCP tools, HTML interfaces; Board: entity order, algorithm syntax, procedure placement |

---

## 5. Context budget thresholds

| Threshold | What happens |
|-----------|-------------|
| 50% | Soft warning — informational; consider finishing the increment and starting a new session |
| 65% | Hard warning — `$build` blocks after the current increment; run `$pause compress` before starting a new session |

Sub-agents run in isolated context and do not consume the main session budget.

---

## 6. Compliance tiers quick reference

| Tier | For | Activates |
|------|-----|-----------|
| Tier 1 — Standard | Internal tools, POCs | Nothing additional |
| Tier 2 — Business | SaaS, customer-facing, user data | Compliance Reviewer; §9 expanded |
| Tier 3 — Enterprise | Regulated, corporate IT, cloud | Compliance Reviewer (full); §9 mandatory gate; threat model required |

---

## 7. Model and effort routing

| Phase | Recommended | Reason |
|-------|-------------|--------|
| `$spec` / `$specout` | FRONTIER · high | Open decisions, requirements design |
| `$build` low-risk increment | STANDARD · low | Executing well-specified work |
| `$build` medium/high-risk | FRONTIER · high | Open decision or risk increment |
| `$qa` incremental | STANDARD · medium | Bounded review of one increment |
| `$qa full` / `$QA` / `$docfinal` | FRONTIER · high | Whole-codebase judgment |
| `$verify` / `$doc` | ECONOMY-STANDARD · low | Mechanical, delegable |
| `$audit` | FRONTIER · high | Client-facing judgment; evidence-based |
| `$pause` / `$lesson` / `$flow` | Current model · low | Never switch for these |

---

## 8. Daily use tips

**Starting a session after a pause:** paste the `$pause compress` output at the conversation
start. SDAD restores all state without re-explanation.

**Hitting the context limit:** `$pause compress` → start new session → paste snapshot.
The COMPACT ANCHOR (locked decisions) re-injects automatically via the SessionStart hook.

**When the spec-gate blocks you:** it means the Spec is missing or unapproved. Run `$spec`
then `$specout`, approve the spec, and the gate opens. For a codebase without a spec, use
`$docfinal` (documentation path) or `$audit` (Pyplan audit path) — both are allowlisted.

**When `$build` blocks mid-increment:** a `.sdad/HOLD_AUTOCOMMIT` file is created. Fix the
issue, delete the file, and resume. Never enter a retry loop — stop cleanly first.

**Running `$eval`:** run after any CLAUDE.md or skill change. The 22-scenario golden dataset
catches regressions before they reach a session or a client.

**Committing safely:** stage only explicit file paths — never `git add .`. DECISIONS.md +
SPEC.md §13 + SPEC.md changes for one increment form one atomic commit. The git pre-commit
hook blocks any non-ASCII bytes in `.ps1` or `.sh` files (L-01 ratchet).

---

G7 AI Development Methodology | SDAD v6.0 Usage and Shortcuts | 2026
