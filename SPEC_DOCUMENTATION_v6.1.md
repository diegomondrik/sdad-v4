# SDAD v6.1 — Automatic Documentation System
## Spec-Driven AI Development: Documentation Automation Layer
**Version:** 6.1 | **Date:** 2026-06-29 | **Status:** ✅ Approved — Ready for $build

---

## §1 — Vision & Objective

Enable SDAD to automatically generate and maintain technical documentation for **any project type** (Pyplan dashboards, Python backends, Node/TypeScript apps, Go microservices) at the moment of $build completion, ensuring:

1. **Documentation is always in sync with code** — generated immediately after $qa passes, same atomic commit
2. **No manual overhead** — documentation is auto-extracted from code (docstrings, type hints, node descriptions)
3. **Client-ready deliverables** — README, API reference, architecture docs, setup guides, changelog
4. **Post-delivery audit capability** — SDAD can reconnect to a client project, detect code changes, and regenerate docs without overwriting client edits
5. **Works for A/B/C projects** — scales from 5k to 500k LOC without reconfiguration

### Success Criteria
- Developer runs `$build [increment]` → test + $qa → automatic `$doc_increment` → docs are complete, client-ready, committed
- Documentation debt = zero (every increment closes with current docs)
- Client can edit code post-delivery; SDAD can re-audit and suggest updates

---

## §2 — Users & Roles

| Role | Interaction | Outcome |
|------|-------------|---------|
| **SDAD Developer** | Runs $build → gets automatic docs per increment | Delivers code + current docs; no manual writing |
| **SDAD Project Lead** | Reviews $doc_increment quality per project type | Approves docs before client delivery |
| **Client (non-technical)** | Receives README + setup guides + architecture overview | Can understand what the system does, how to use it |
| **Client (IT)** | Receives API reference, CHANGELOG, architecture, module docs | Can maintain, extend, debug the system |
| **SDAD (post-delivery audit)** | Reconnects, runs `$doc_audit`, reviews flagged gaps | Keeps docs current when clients edit code |

---

## §3 — Functional Flows

### **Flow 1: During $build (Auto-Documentation)**

```
Developer: $build [increment N]
├─ Write code / modify nodes
├─ Run tests
├─ Run $qa [increment] ← PASSES
└─ SDAD: $doc_increment [auto]
   ├─ Detect: changed files (git diff)
   ├─ Extract: docstrings, type hints, node descriptions, signatures
   ├─ For Pyplan: read nodes via MCP
   │  ├─ Generate: NODE_REFERENCE.html (catalog of nodes)
   │  ├─ Generate: USER_GUIDE.html (how to use dashboard)
   │  └─ Generate: DASHBOARD_MAP.json (node→dashboard mapping)
   ├─ For Generic: read code
   │  ├─ Generate: API_REFERENCE.md (functions/endpoints)
   │  ├─ Update: ARCHITECTURE.md (new modules/structure)
   │  └─ Update: CHANGELOG.md (what changed)
   ├─ Commit: code + docs (atomic)
   └─ ✅ Increment closed with current documentation
```

### **Flow 2: Post-Delivery Audit (Client Edits Code)**

```
Months later: Client edits project in Pyplan/code directly (no SDAD)
↓
SDAD: $doc_audit [branch or current state]
├─ Read: client's changes (git log or Pyplan model state)
├─ Compare: old docs vs new code/nodes
├─ Detect:
│  ├─ New functions/nodes not in docs
│  ├─ Deleted code still documented
│  ├─ Breaking API changes
│  ├─ Inconsistencies
├─ Generate: updated docs with [REVIEW] tags on uncertain inferences
└─ Report: "X new items, Y breaking changes, Z needs human review"
```

### **Flow 3: Delivery Package**

```
Project folder structure:
├─ README.md ← auto-generated from docstrings + manual polish
├─ docs/
│  ├─ ARCHITECTURE.md ← module structure + data flow
│  ├─ API_REFERENCE.md ← all functions/endpoints (auto-generated)
│  ├─ SETUP.md ← dependencies, environment, how to run
│  ├─ CHANGELOG.md ← per-increment summary (auto-generated)
│  ├─ pyplan/ (if Pyplan project)
│  │  ├─ NODE_REFERENCE.html ← node catalog
│  │  ├─ USER_GUIDE.html ← dashboard usage guide
│  │  └─ DASHBOARD_MAP.json
│  ├─ python/ (if Python project)
│  │  └─ CONVENTIONS.md
│  ├─ typescript/ (if Node/TS project)
│  │  ├─ COMPONENTS.md
│  │  └─ API_ENDPOINTS.md
│  └─ decisions.md ← SDAD decisions per increment
├─ .sdad/
│  ├─ docs-manifest.json ← which docs are auto-generated
│  └─ docs-snapshots/ ← version history of key docs
└─ Source code (with inline comments)
```

---

## §4 — Data Model

### **Documentation Artefacts**

| Artefact | Scope | Generation | Stack Agnostic? | Client Editable? |
|----------|-------|-----------|-----------------|-----------------|
| **README.md** | Overview, quick start, key files | Mostly auto (template) + manual | ✅ Yes | ✅ Yes |
| **API_REFERENCE.md** | Functions, endpoints, signatures | ✅ Fully auto (from code) | ✅ Yes | ⚠️ Risky (auto-regen overwrites) |
| **ARCHITECTURE.md** | Modules, data flow, design patterns | Partial auto (detect new modules) + manual | ✅ Yes | ✅ Yes |
| **SETUP.md** | Dependencies, environment, build | Mostly manual + auto helpers | ✅ Yes | ✅ Yes |
| **CHANGELOG.md** | Per-increment changes | ✅ Fully auto (git diff) | ✅ Yes | ❌ No (append only) |
| **NODE_REFERENCE.html** (Pyplan) | Catalog of nodes + properties | ✅ Fully auto (MCP read) | ❌ Pyplan only | ⚠️ Risky |
| **USER_GUIDE.html** (Pyplan) | Dashboard usage, how to use inputs | Partial auto (extract from nodes) + manual | ❌ Pyplan only | ✅ Yes |
| **DASHBOARD_MAP.json** | Node → Dashboard mapping | ✅ Fully auto (MCP + HTML parse) | ❌ Pyplan only | ⚠️ Risky |

### **Stack-Specific Extraction**

**Python:**
- Source: docstrings (Google/NumPy format), type hints (PEP 484)
- Extract: function name, args, return type, description
- Tool: AST parsing (ast module) + regular expressions

**Node/TypeScript:**
- Source: JSDoc comments, TypeScript type definitions
- Extract: function name, parameters, return type, description
- Tool: TypeScript Compiler API / comment regex

**Go:**
- Source: comment lines above exported identifiers
- Extract: function name, signature, brief description
- Tool: go/parser + comment association

**Pyplan:**
- Source: node descriptions (text field), type, inputs, outputs
- Extract: via MCP read_node endpoint
- Tool: Pyplan MCP server

---

## §5 — Technical Architecture

### **Components**

```
SDAD (existing)
├─ $build [increment] ← calls $doc_increment after $qa passes
├─ git diff [tracking changes] ← input to documentation generator
└─ Skills:
   ├─ pyplan-node-documentation [NEW]
   │  ├─ Reads: Pyplan nodes via MCP
   │  ├─ Generates: NODE_REFERENCE.html, USER_GUIDE.html, DASHBOARD_MAP.json
   │  ├─ Supports: Tier A/B/C projects
   │  └─ Triggers: After every Pyplan $build increment
   │
   ├─ generic-documentation [NEW]
   │  ├─ Reads: git diff + source files
   │  ├─ Detects: Python / Node / Go (stack inference)
   │  ├─ Stack handlers:
   │  │  ├─ python-doc-extractor → docstrings + type hints
   │  │  ├─ typescript-doc-extractor → JSDoc + types
   │  │  └─ go-doc-extractor → comments
   │  ├─ Generates: API_REFERENCE.md, ARCHITECTURE.md updates, CHANGELOG.md
   │  └─ Triggers: After every non-Pyplan $build increment
   │
   └─ doc-audit-skill [NEW]
      ├─ Reads: current code state (git or MCP)
      ├─ Compares: against last-known-docs
      ├─ Detects: changes, gaps, inconsistencies
      ├─ Generates: updated docs with [REVIEW] tags
      └─ Triggers: On-demand or post-delivery reconnection

Execution flow:
$qa passes → $doc_increment [auto]
           → detect_stack()
           → if Pyplan: call pyplan-node-documentation
           → else: call generic-documentation
           → update docs/
           → git commit (atomic with code)
```

### **Doc Generation Rules (by Project Type & Size)**

**Pyplan — Any Size (A/B/C):**
```
After $qa passes:
├─ Read changed nodes (via MCP: read_node per increment's node list)
├─ Extract: description, type, inputs, outputs, dependencies, dashboards using this node
├─ Update:
│  ├─ NODE_REFERENCE.html [auto]
│  ├─ USER_GUIDE.html [auto + optional polish]
│  └─ DASHBOARD_MAP.json [auto]
├─ Time: 10-20 min (mostly automated)
└─ Commit: code + HTML + JSON (atomic)
```

**Generic (Python / Node / Go) — Project A (small):**
```
After $qa passes:
├─ git diff HEAD~1 → list changed files
├─ Read changed files → extract docstrings + type hints
├─ Update:
│  ├─ API_REFERENCE.md [auto, append mode]
│  ├─ CHANGELOG.md [auto]
│  └─ README.md [auto template, manual polish optional]
├─ Time: 5 min (fully automated)
└─ Commit: code + docs (atomic)
```

**Generic (Python / Node / Go) — Project B (medium):**
```
After $qa passes:
├─ git diff → detect new modules, deleted files
├─ Extract docstrings + types → API_REFERENCE.md [auto]
├─ Detect structure changes → flag ARCHITECTURE.md [auto flag + manual review]
├─ Update CHANGELOG.md [auto]
├─ Time: 15-30 min (auto 10 min + optional 20 min polish)
└─ Commit: code + docs (atomic)
```

**Generic (Python / Node / Go) — Project C (large):**
```
After $qa passes:
├─ git diff → full analysis (new modules, breaking changes, deprecations)
├─ Extract: docstrings, types, component structure → API_REFERENCE.md [auto]
├─ Analyze: module imports + exports → generate ARCHITECTURE.md diagram (Mermaid) [auto]
├─ Stack-specific:
│  ├─ Python: generate module dependency graph
│  ├─ Node/TS: generate component tree (if React)
│  └─ Go: generate package interface overview
├─ Update: CHANGELOG.md, stack-specific guides
├─ Time: 45 min (auto 30 min + optional 15 min polish)
└─ Commit: code + docs (atomic)
```

### **Increment Checklist Updates (New)**

**After $qa passes, before commit:**

```
Documentation (required for all projects):
□ $doc_increment ran automatically
□ API_REFERENCE.md (or NODE_REFERENCE.html for Pyplan) updated with new items
□ CHANGELOG.md reflects what changed in this increment
□ README.md is still accurate (manual check, no edits needed usually)

Documentation (manual polish — do if time permits):
□ ARCHITECTURE.md descriptions reviewed and clarified
□ Setup.md has any new env vars documented
□ Stack-specific guides updated (if applicable)
□ All [REVIEW] tags addressed or intentionally left for client

Verification:
□ No contradictions between code comments ↔ API_REFERENCE ↔ ARCHITECTURE
□ All new public functions/nodes documented (no orphans)
□ Docs commit is atomic with code commit
```

---

## §6 — Business Rules

**Pyplan Projects:**
1. Node descriptions in Pyplan (text field) are the source of truth for node documentation
2. USER_GUIDE.html is auto-generated but can be polished manually — regeneration overwrites manual edits
3. NODE_REFERENCE.html is exhaustive catalog (technical); USER_GUIDE.html is business-facing narrative (readable)
4. DASHBOARD_MAP.json links every node used in any dashboard (traceable impact analysis)

**Generic Projects (Python / Node / Go):**
1. Docstrings (Python), JSDoc (Node), comment blocks (Go) are the source of truth
2. API_REFERENCE.md is auto-generated and append-only (never overwrites)
3. ARCHITECTURE.md is semi-auto (new modules detected, structure flagged; descriptions are manual)
4. CHANGELOG.md is auto-generated per increment and immutable
5. README.md is auto-templated but manual polish is expected

**Cross-Project:**
1. Every increment that passes $qa MUST have updated documentation
2. Documentation and code are committed together (atomic commits)
3. No doc debt allowed — this is Definition of Done (§10)
4. Post-delivery, docs can diverge from code if client edits; `$doc_audit` detects gaps

---

## §7 — Integrations & APIs

### **Pyplan MCP**
- **Endpoint:** `read_node` (get node description, type, inputs, outputs) ✅ confirmed available
- **Endpoint:** `read_node_dependencies` (what feeds this node, what it feeds) ✅ confirmed available
- **Endpoint:** `list_nodes` (get all nodes in model) ✅ confirmed available
- **Endpoint:** `read_html_interface` (get HTML dashboard, parse for nodes used) ✅ confirmed available
- **Used by:** `pyplan-node-documentation` skill

### **Git API**
- **Command:** `git diff HEAD~1` (list changed files)
- **Command:** `git log --oneline` (get commit messages for changelog)
- **Used by:** `generic-documentation` skill

### **Stack-Specific APIs**
- **Python:** `ast` module (parse docstrings), `inspect` module (get signatures)
- **Node/TS:** TypeScript Compiler API (parse JSDoc, extract types)
- **Go:** `go/parser`, `go/doc` (standard library)

### **Output Format (for clients)**
- Markdown files (git-friendly, client-editable)
- HTML (Pyplan dashboards only; read-only, regenerable)
- JSON (Pyplan DASHBOARD_MAP; machine-readable)

---

## §8 — Testing Strategy

### **Unit Tests**
- Stack detector (Python vs Node vs Go detection accuracy)
- Docstring parser (extract description, args, returns correctly)
- Type hint extractor (handle optional, Union, generics)
- Git diff analyzer (detect new, deleted, modified files)

### **Integration Tests**
- End-to-end $doc_increment flow (code changed → docs updated → commit atomic)
- Pyplan MCP read_node → NODE_REFERENCE.html generation
- HTML parsing (extract nodes used from dashboard HTML)
- Doc regeneration (old docs + new code → merged correctly, no overwrites)

### **Manual Tests (per-project)**
- Developer: write code with docstrings → $doc_increment → verify API_REFERENCE.md is correct
- Pyplan: create 3 nodes with descriptions → $doc_increment → verify NODE_REFERENCE.html and USER_GUIDE.html
- Audit: client edits code → $doc_audit → verify [REVIEW] tags appear on gaps

---

## §9 — Security & Compliance

### **P0 (Critical)**
- ✅ No secrets in generated docs (check: docstrings, code comments do not contain API keys, passwords, tokens)
- ✅ No PII in generated docs (client data, user IDs, email addresses should not appear in function names or descriptions)
- ✅ Docstring extraction is read-only (no modification of source code during doc generation)

### **P1 (High)**
- Docstring parser: handle malformed input without crashing (robust to nested quotes, unicode, escape sequences)
- Git diff: only read files in current repo (no path traversal)
- MCP calls: authenticate and authorize correctly (Pyplan access control)

### **P2 (Medium)**
- HTML generation (Pyplan): sanitize user input from node descriptions (no script injection)
- Markdown generation: escape special characters (prevent markdown injection)

---

## §10 — Definition of Done

An increment is complete only when:

1. ✅ Code written and tested
2. ✅ $qa [increment] passes
3. ✅ **Documentation auto-generated and reviewed** (NEW)
   - API_REFERENCE.md / NODE_REFERENCE.html updated
   - CHANGELOG.md updated
   - ARCHITECTURE.md flagged (if structure changed)
4. ✅ All docs committed atomically with code
5. ✅ No [REVIEW] tags left unaddressed (or intentionally marked for client)
6. ✅ SPEC.md §13 updated (AI Authorship Log)
7. ✅ DECISIONS.md entry written

**Blocker:** If docs are missing or out-of-sync, increment is not closed (increment stays in-progress until docs are complete).

---

## §11 — Out of Scope

- Auto-generation of **diagrams** (Mermaid can be auto-templated but requires manual refinement)
- Auto-generation of **UI mockups** or **wireframes**
- Auto-generation of **user training materials** (those are manual, client-specific)
- Auto-generation of **API SDKs** (OpenAPI/AsyncAPI can be auto-templated but code gen is separate)
- Version history UI (just file history in git)
- Multi-language documentation (English only in v6.1)

---

## §12 — Open Decisions

1. **Pyplan: regenerate NODE_REFERENCE.html on every increment, or only on major changes?**
   - ✅ **CLOSED:** Regenerate every increment (always in sync); optimize later if performance is an issue.

2. **Generic: detect breaking changes automatically, or always require manual review?**
   - Recommendation: Auto-detect (removed functions, parameter type changes, return type changes) and flag in [REVIEW]
   - Alternative: Manual review only (safer but slower)
   - **Decision needed:** Will auto-detect and flag; developer confirms before commit

3. **Post-delivery audit: automated or manual trigger?**
   - Recommendation: Manual trigger (SDAD runs `$doc_audit` on-demand)
   - Alternative: Webhook trigger (client commits → auto-audit runs) — requires client setup
   - **Decision needed:** Manual trigger in v6.1; webhook in v6.2 if client needs it

---

## §13 — AI Authorship Log

| Increment | Feature | Model | Date | Notes |
|-----------|---------|-------|------|-------|
| 1 | pyplan-node-documentation skill | claude-sonnet-4-6 | 2026-06-29 | MCP-backed node catalog; NODE_REFERENCE.html, USER_GUIDE.html, DASHBOARD_MAP.json |
| 2 | generic-documentation skill | claude-sonnet-4-6 | 2026-06-29 | Stack detection (Python/Node/Go); API_REFERENCE.md, CHANGELOG.md, ARCHITECTURE.md |
| 3 | doc-audit skill | claude-sonnet-4-6 | 2026-06-29 | Post-delivery gap detection; [REVIEW] flagging; $doc_audit command |
| 4 | CLAUDE.md v6.1 updates | claude-sonnet-4-6 | 2026-06-29 | $doc_increment + $doc_audit commands; Active Skills; increment checklists; behavior rules |

---

## DEPLOYMENT & HANDOFF

### **Upon Completion:**

This specification will be implemented as **SDAD v6.1** with the following deliverables:

1. **Skills (in .claude/skills/)**
   - `pyplan-node-documentation/SKILL.md`
   - `generic-documentation/SKILL.md`
   - `doc-audit/SKILL.md`

2. **CLAUDE.md Updates**
   - Add $doc_increment command
   - Add $doc_audit command
   - Update Increment Checklist (Documentation section)
   - Update Active Skills section (add three new skills)

3. **Repository Updates**
   - Add `.sdad/docs-manifest.json` template
   - Add `.sdad/docs-snapshots/` directory
   - Add examples/ directory with sample generated docs

4. **Manual Updates**
   - README.md: Document new $doc_increment and $doc_audit workflows
   - INSTALL.ps1 / install.sh: Include new skills in installation
   - LESSON_LIBRARY.md: Add lessons learned about documentation automation

5. **GitHub Sync**
   - Commit: All three skills + CLAUDE.md + examples + manuals
   - Tag: v6.1-documentation-alpha (for review)
   - Tag: v6.1 (when approved)
   - Update: Release notes with new features

---

**SPEC Status:** Ready for Developer Review → $build → Release
