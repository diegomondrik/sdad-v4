# TASK — Port SDAD hooks to bash (macOS/Linux)
# SDAD v4.3 · known gap documented in CHANGELOG [4.3]
# Assignable to: a dev with macOS · Estimate: 1 session

## Context (read this first)

SDAD v4.3 ships 3 Claude Code hooks that are currently **Windows/PowerShell only**:
`.claude/hooks/session-start.ps1`, `pre-compact.ps1` and `session-end.ps1`.
Your task is to port them to bash (`.sh`) and test them on macOS, following the
SDAD methodology itself (this is an increment — announce it, get approval, test it,
record it in DECISIONS.md).

Mandatory reference reading before touching anything:
- `.claude/hooks/README.md` — what each hook does and its safeguards
- The 3 `.ps1` scripts — they are the exact functional spec for the port
- https://code.claude.com/docs/en/hooks — stdin JSON format and exit codes

## Setup

```bash
git clone https://github.com/diegomondrik/sdad-v4.git
cd sdad-v4
git checkout -b hooks-bash-port        # NEVER work on main (hooks README rule)
claude                                  # verify $sdad responds with v4.3
```

## What to port (the logic is small — a 1:1 mirror of the .ps1 files)

| New script | Mirrors | Required behavior |
|---|---|---|
| `session-start.sh` | `session-start.ps1` | 1) If `.sdad/compact_anchor.md` exists, emit its content as `additionalContext` in the output JSON. 2) `git pull --ff-only` ONLY if the tracked tree is clean. 3) Never block session start: always `exit 0`. |
| `pre-compact.sh` | `pre-compact.ps1` | Write the anchor snapshot ([LOCK] entries from DECISIONS.md) to `.sdad/compact_anchor.md`. Never `exit 2`. Always `exit 0`. |
| `session-end.sh` | `session-end.ps1` | Batch autocommit of ONLY `DECISIONS.md` + `LESSON_LIBRARY.md` (whitelist — never code). Skip if `.sdad/HOLD_AUTOCOMMIT` exists. No empty commits. Standardized message (copy it from the .ps1 version). |

## settings.json registration (part of the design — think before coding)

The current `.claude/settings.json` invokes `powershell ...` hardcoded, so on a Mac the
hooks never fire. You must solve cross-platform registration.
Options to evaluate (pick one and document why in DECISIONS.md):
  a) A single wrapper per hook that detects the platform and delegates to .ps1 or .sh.
  b) settings.json invokes `sh` and Windows overrides via settings.local.json.
  c) Anything better you find in the Claude Code hooks docs.
Constraint: the solution must NOT break Diego's existing Windows setup.

## Lessons that already cost us (do not repeat them)

- **L-01 (encoding):** the .ps1 files are pure ASCII because non-ASCII characters broke
  the PowerShell parser TWICE. In bash: use explicit UTF-8, test with accented characters
  and em-dashes in DECISIONS.md content, and verify the anchor re-injects without mojibake.
- **PreCompact does NOT survive compaction by itself** (verified against the docs):
  the durable mechanism is PreCompact-writes-to-disk + SessionStart-re-injects.
  Do not "improve" this design — it is intentional.
- Read hooks (start/pre-compact) NEVER mutate the repo.

## Test gate (same standard as the Windows port — no merge without it)

Run each script as a child process with mock JSON on stdin (see the format in the hooks
docs) and verify:

- [ ] `session-start.sh` emits valid JSON (validate with `jq`)
- [ ] An anchor containing accents/ñ/em-dashes re-injects without mojibake
- [ ] `git pull` does NOT run on a dirty tree; runs `--ff-only` only on a clean tree
- [ ] `pre-compact.sh` writes `.sdad/compact_anchor.md` and always exits 0
- [ ] `session-end.sh` with `.sdad/HOLD_AUTOCOMMIT` present: does NOT commit
- [ ] `session-end.sh` without the hold: commits ONLY whitelisted files (test with a
      deliberately modified code file — it must stay out of the commit)
- [ ] No changes in whitelisted files: NO empty commit is created
- [ ] Integration test: a real Claude Code session in a scratch repo — open, force a
      compaction, close — and verify all 3 hooks fired

## Closing (SDAD discipline)

1. Update `.claude/hooks/README.md` (Platform section) and `install.sh`
   (download the new .sh files; it currently carries a "Windows-only" note — remove it).
2. DECISIONS.md entry with the cross-platform registration decision.
3. Lesson candidate if you found a macOS hooks quirk.
4. PR to main — Diego reviews and merges. Do NOT push to main directly.
