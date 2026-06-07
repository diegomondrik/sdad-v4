# .claude/hooks/

Claude Code lifecycle scripts that run automatically at defined points in the workflow.

## Status in SDAD v4.2

**ACTIVE (Windows / PowerShell).** Three hooks are wired in `.claude/settings.json`:

| Hook | Script | What it does | Safeguards |
|---|---|---|---|
| `SessionStart` | `session-start.ps1` | Injects the COMPACT ANCHOR ([LOCK] decisions from `DECISIONS.md`) into context, and does a fast-forward `git pull`. Fires after compaction too — this is what makes the anchor survive compaction. | Pull only if no tracked file is modified and only `--ff-only`; never blocks session start; always exits 0. |
| `PreCompact` | `pre-compact.ps1` | Writes a compaction-time anchor snapshot to `.sdad/compact_anchor.md` so `SessionStart(compact)` can re-inject it. | Never blocks compaction (never exits 2); exits 0. |
| `SessionEnd` | `session-end.ps1` | Batch auto-commit of SDAD docs at session end. | Whitelist: ONLY `DECISIONS.md` + `LESSON_LIBRARY.md`, never code; skips if `.sdad/HOLD_AUTOCOMMIT` exists; no empty commit; standardized message. |

### Design note (verified against Claude Code docs)
A `PreCompact` hook **cannot** inject context that survives compaction — its `additionalContext`
is discarded by the compaction. The durable mechanism is `PreCompact` writing the anchor to disk +
`SessionStart` (matcher includes `compact`) re-injecting it **after** compaction. This corrects the
original roadmap assumption that PreCompact alone would persist the anchor.

### Autocommit hold
To pause autocommit (e.g. an open P0 QA finding or a failing increment), create an empty file
`.sdad/HOLD_AUTOCOMMIT`. Delete it to resume. `.sdad/` is gitignored (runtime state only).

## Platform
These hooks are **Windows/PowerShell** (the v4.2 test gate). macOS/Linux `.sh` equivalents are a
documented follow-up — the logic is small and mirrors these three scripts.

## Reference
Claude Code hooks: https://code.claude.com/docs/en/hooks
Any hook here activates for all developers using this repo. Test in a branch before merging to main.
