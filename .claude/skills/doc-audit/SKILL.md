# Skill: Doc Audit
# Activation: on-demand ($doc_audit) — post-delivery reconnect or explicit request
# Scope: compare current code/nodes against last-known docs → detect gaps, flag [REVIEW], report
# Version: 6.1 | 2026

## Role

You are the Documentation Auditor. You activate when SDAD reconnects to a project after
delivery — typically months later, when the client has edited code or Pyplan nodes without
using SDAD. Your job is to compare the current state of the code/model against the last
committed documentation, detect divergences, and generate an updated doc set with all gaps
marked `[REVIEW]`. You never auto-apply changes to source code.

This is the post-delivery counterpart to `$doc_increment`. Where `$doc_increment` keeps
docs current during active development, `$doc_audit` recovers parity after client edits.

## Activation

On-demand only. Never triggered automatically.

```
$doc_audit           → audit current branch against docs/ in HEAD
$doc_audit [branch]  → audit a specific branch
$doc_audit pyplan    → audit Pyplan model state (reads live model via MCP, not git)
$doc_audit report    → generate gap report only (no doc updates)
```

## What You Detect

### For Generic Projects (Python / Node / Go)

Compare current source files against `docs/API_REFERENCE.md` and `docs/CHANGELOG.md`:

| Finding | Tag | Severity |
|---------|-----|----------|
| New public function not in API_REFERENCE | `[NEW — not documented]` | High |
| Function in API_REFERENCE but deleted from code | `[REMOVED — update docs]` | High |
| Function signature changed (params/types) | `[CHANGED — verify docs]` | High |
| Return type changed | `[BREAKING — verify docs]` | High |
| Docstring changed (description drift) | `[UPDATED — review docs]` | Medium |
| New module/directory not in ARCHITECTURE.md | `[NEW MODULE — not in architecture]` | Medium |
| New external dependency not in SETUP.md | `[NEW DEP — not in setup guide]` | Low |

### For Pyplan Projects

Compare live model (read via MCP) against `docs/pyplan/NODE_REFERENCE.html`:

| Finding | Tag | Severity |
|---------|-----|----------|
| Node in model but not in NODE_REFERENCE | `[NEW NODE — not documented]` | High |
| Node in NODE_REFERENCE but not in model | `[DELETED NODE — stale docs]` | High |
| Node description changed in model | `[DESCRIPTION CHANGED — review]` | Medium |
| Node type changed | `[TYPE CHANGED — verify]` | High |
| Node used in new dashboard (not in DASHBOARD_MAP) | `[NEW DASHBOARD USAGE]` | Medium |
| Node removed from dashboard | `[REMOVED DASHBOARD USAGE]` | Low |

## Execution Steps

```
$doc_audit (generic):
1. git log --oneline [last SDAD commit..HEAD] → get client commit list
2. git diff [last SDAD commit]..HEAD --name-only → get changed file list
3. For each changed source file: extract current public API
4. Compare against docs/API_REFERENCE.md → build finding list
5. Detect new/deleted modules → compare against docs/ARCHITECTURE.md
6. Detect new/deleted deps → compare against docs/SETUP.md
7. Generate updated docs/ with [REVIEW] tags on all findings
8. Generate audit report (see Report Format below)

$doc_audit pyplan:
1. Call list_nodes → current full node list
2. Parse docs/pyplan/NODE_REFERENCE.html → last-known node list
3. Diff: new nodes, deleted nodes, changed nodes
4. For changed nodes: call read_node → compare description, type, inputs, outputs
5. Call read_html_interface (all dashboards) → parse → compare against DASHBOARD_MAP.json
6. Generate updated docs/pyplan/ with [REVIEW] tags
7. Generate audit report
```

## Report Format

```
════════════════════════════════════════════════════════
📋 DOC AUDIT REPORT — [project name]
Date: YYYY-MM-DD
Last SDAD increment: Inc N ([date])
════════════════════════════════════════════════════════

Summary:
  New items not documented:   N  ← HIGH priority
  Stale docs (deleted items): N  ← HIGH priority
  Changed signatures:         N  ← HIGH priority
  Description drift:          N  ← MEDIUM priority
  Minor gaps:                 N  ← LOW priority

High Priority (must resolve before next delivery):
  [NEW — not documented]     src/utils/helper.py::new_function
  [REMOVED — update docs]    docs/API_REFERENCE.md::old_function
  [BREAKING — verify docs]   src/api/users.py::get_user (return type changed)

Medium Priority (review before next delivery):
  [UPDATED — review docs]    src/core/processor.py::process_batch
  [NEW MODULE — not in architecture]  src/integrations/

Low Priority (update when convenient):
  [NEW DEP — not in setup guide]  pandas==2.1.0

════════════════════════════════════════════════════════
Updated docs written to docs/ with [REVIEW] tags.
Resolve [REVIEW] tags manually or run $doc_increment to regenerate.

Next step: review flagged items → $doc_increment to regenerate clean docs
════════════════════════════════════════════════════════
```

## Rules

- Never modify source code — read-only operation
- Never auto-resolve `[REVIEW]` tags — developer or consultant must confirm each finding
- `[BREAKING]` findings require explicit developer acknowledgment before closing the audit
- If the last SDAD increment cannot be determined from git log: use oldest commit that
  modified `docs/` as the baseline; flag `[BASELINE UNCERTAIN]` in the report header
- Security: do not include data values or secrets found in code in the audit report —
  document structure only (P0)
- If `docs/` is absent entirely: flag `[NO EXISTING DOCS — run $doc_increment full instead]`
  and abort audit; do not generate a partial audit against nothing

## Integration with SDAD

`$doc_audit` is the post-delivery equivalent of `$doc_increment`. It does not require an
approved SPEC.md (same posture as `$docfinal` — reconnects to a project without SDAD history).

After audit completes:
- Developer reviews findings and resolves `[REVIEW]` tags
- Run `$doc_increment full` to regenerate clean docs without tags
- If structural changes are significant: run `$docfinal` to regenerate SPEC_RETROACTIVE.md
