# Skill: Generic Documentation
# Activation: auto-triggered after every non-Pyplan $build increment ($qa passes)
# Scope: stack detection → docstring/JSDoc/comment extraction → API_REFERENCE.md, CHANGELOG.md, ARCHITECTURE.md
# Version: 6.1 | 2026

## Role

You are the Generic Documentation generator for Python, Node/TypeScript, and Go projects.
You run automatically after every non-Pyplan $build increment once $qa passes. You detect
the project stack, extract structured documentation from source code, and update three
artefacts: the API reference, the changelog, and the architecture document.

You do not modify source code. You read files and write documentation only.

## Activation

Auto-triggered at step 5 of every non-Pyplan $build increment (after $qa passes, before commit).
Also available on-demand: `$doc_increment` (current git diff scope) or `$doc_increment full`
(full project re-scan).

## Stack Detection

Read the repo root for stack indicators (in priority order):

| Indicator | Detected Stack |
|-----------|---------------|
| `requirements.txt` / `pyproject.toml` / `setup.py` | Python |
| `package.json` + `.ts` files | TypeScript / Node |
| `package.json` (no `.ts`) | JavaScript / Node |
| `go.mod` | Go |
| Multiple indicators | Multi-stack — document each under its own `docs/<stack>/` subdirectory |

If stack cannot be determined: flag `[STACK UNKNOWN — set PROJECT_STACK in CLAUDE.md]`
and skip doc generation for that increment.

## What You Generate

### API_REFERENCE.md
Append-only catalog of all public functions, classes, and endpoints.
Never overwrites existing entries — new items are appended at the bottom of the relevant section.
Deleted functions are marked `[REMOVED in Inc N]` (never deleted from the file — changelog value).

**Per-function entry (Python):**
```markdown
### function_name
**Module:** `path/to/module.py`
**Signature:** `function_name(arg1: Type, arg2: Type = default) -> ReturnType`
**Description:** [from docstring first line]
**Args:**
- `arg1` (Type): [from docstring args section]
**Returns:** [from docstring returns section]
**Raises:** [from docstring raises section, if present]
```

**Per-endpoint entry (Node/TS):**
```markdown
### METHOD /path
**File:** `src/routes/file.ts`
**Description:** [from JSDoc comment]
**Parameters:** [from JSDoc @param]
**Returns:** [from JSDoc @returns]
**Auth required:** [inferred from middleware, or [REVIEW]]
```

**Per-exported identifier (Go):**
```markdown
### FunctionName
**Package:** `pkg/name`
**Signature:** `FunctionName(arg Type) ReturnType`
**Description:** [from comment block above identifier]
```

Location: `docs/API_REFERENCE.md`

### CHANGELOG.md
Auto-generated per increment. Append-only (newest entry at top). Immutable after commit.

```markdown
## [Inc N] — YYYY-MM-DD
### Added
- function_name: [one-line description]
### Changed
- function_name: [what changed — parameter type, return type, behavior]
### Removed
- function_name: [marked REMOVED in API_REFERENCE.md]
### Breaking Changes
- [flagged if: parameter removed, return type changed, endpoint path changed]
```

Location: `docs/CHANGELOG.md`

### ARCHITECTURE.md
Semi-auto. New modules and structural changes are detected and flagged; descriptions require
manual review. Never overwrites hand-written sections — appends `[AUTO-DETECTED]` blocks
for new items.

Detects:
- New directories / packages (added to module list)
- Deleted directories (marked `[REMOVED in Inc N]`)
- New external dependencies (from `requirements.txt`, `package.json`, `go.mod` diff)
- New import relationships between existing modules (Python: `import` / `from` analysis)

Does NOT auto-generate (flags `[REVIEW — manual description needed]`):
- Architectural decisions or rationale
- Data flow diagrams (Mermaid template provided, content is manual)
- System context diagrams

Location: `docs/ARCHITECTURE.md`

## Extraction Rules by Stack

### Python
- Source: docstrings in Google or NumPy format (`"""..."""` immediately after `def` / `class`)
- Type hints: PEP 484 annotations on function signature
- Public API: all `def` and `class` at module level not prefixed with `_`
- Tool: Python `ast` module via inline script (`python -c "import ast; ..."`)
- Malformed docstrings: include what can be parsed, flag `[MALFORMED DOCSTRING]` on the entry

### TypeScript / Node
- Source: JSDoc comment blocks (`/** ... */`) immediately before exported functions/classes
- Type information: TypeScript type annotations in the signature
- Public API: all `export function`, `export class`, `export const` (arrow functions with JSDoc)
- Express/Fastify routes: detected via `.get(`, `.post(`, `.put(`, `.delete(`, `.patch(` patterns
- Tool: regex-based extraction (TypeScript Compiler API not required for basic extraction)

### Go
- Source: comment lines (`//`) immediately above exported identifiers (capitalized names)
- Public API: all exported identifiers (capitalized) at package level
- Tool: `go doc ./...` if Go is installed; fallback to regex comment association

## Breaking Change Detection

Auto-detect and flag `[BREAKING]` in CHANGELOG.md when:
- A function/method previously in `API_REFERENCE.md` has a parameter removed
- A parameter's type annotation changed (e.g., `str` → `int`)
- A function's return type changed
- An HTTP endpoint's path or method changed
- A function was removed entirely

Auto-detect confidence: HIGH for type annotation changes (static), MEDIUM for behavioral
changes (inferred from docstring diff). Always flag `[REVIEW]` on medium-confidence detections.

## Execution Steps

```
1. Run: git diff HEAD~1 --name-only → get changed file list
   (First run / $doc_increment full: scan all source files)
2. Detect stack (see Stack Detection above)
3. For each changed source file:
   a. Extract public identifiers + docstrings/comments
   b. Detect new vs modified vs removed (compare against API_REFERENCE.md)
   c. Flag breaking changes
4. Update API_REFERENCE.md (append new, mark removed)
5. Generate CHANGELOG.md entry for this increment
6. Run structural diff (new directories, new deps) → update ARCHITECTURE.md AUTO-DETECTED blocks
7. Report: "N new items, M updated, K breaking changes flagged"
```

## Quality Rules

- Public function with no docstring: flagged `[UNDOCUMENTED]` in API_REFERENCE.md
- Breaking change without `[REVIEW]` tag: never — always requires developer acknowledgment
- [REVIEW] tags left in committed docs: acceptable only if explicitly noted in DECISIONS.md
- Docs commit is atomic with code commit — never commit code without docs when this skill ran

## Integration with SDAD Increment Checklist

After running, confirm:
```
□ API_REFERENCE.md updated — new public functions/endpoints appended
□ CHANGELOG.md entry written for this increment
□ ARCHITECTURE.md AUTO-DETECTED blocks added for any new modules
□ Breaking changes flagged [BREAKING] and [REVIEW] where confidence is medium
□ No [UNDOCUMENTED] flags left unresolved (or intentionally deferred with DECISIONS.md note)
□ docs/ committed atomically with code
```
