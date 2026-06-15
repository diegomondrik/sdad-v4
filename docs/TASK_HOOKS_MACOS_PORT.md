# TASK — macOS verification of the v5 hook layer (bash)
# SDAD v5.0 · reduced scope (the v4.3 session-hook port is DONE and merged)
# Assignable to: a dev with macOS · Estimate: < 1 session

## Status (what is already done)

The original v4.3 task — porting the three session hooks to bash — is **complete
and merged into v5**:
- `session-start.sh`, `pre-compact.sh`, `session-end.sh` are 1:1 POSIX ports of
  the `.ps1` hooks, behind the `run-hook.sh` cross-platform dispatcher.
- They passed the full macOS test gate (valid JSON via `jq`, unicode round-trip
  without mojibake, ff-only pull guard, HOLD sentinel, whitelist isolation, no
  empty commits, real-session integration). See CHANGELOG [5.0].

What v5 added on top — and what still needs macOS eyes — is the **PreToolUse
spec-gate** bash variant and a **live PreCompact verification**. Everything below
is the remaining work; nothing here blocks the v5.0 release (the gate ships
tested on Windows; the `.sh` variant ships untested per SPEC §5/§11).

## Remaining item 1 — test `pre-tool-use-spec-gate.sh` on macOS

The gate refuses a code-file `Write`/`Edit` when `SPEC.md` is absent or not
marked `SPEC STATUS: APPROVED`, and fails open (allow + `.sdad/gate.log`) on its
own error. The Windows `.ps1` is tested (eval scenarios 01–05). Mirror those five
on macOS against `pre-tool-use-spec-gate.sh`:

- [ ] No `SPEC.md` → code Write **denied** (exit 2 + message naming `$spec` / `$docfinal`).
- [ ] Approved `SPEC.md` → code Write **allowed** (exit 0).
- [ ] `docs/*.md` edit with no Spec → **allowed** (allowlist).
- [ ] `.sdad/DOCFINAL_ACTIVE` sentinel present → **allowed**.
- [ ] Gate script deliberately broken → **fail-open** (allow + `.sdad/gate.log` entry).

Two known macOS-suspect spots flagged during the Windows build (both P2,
pending this test) — confirm or fix while here:
- [ ] **sed path edge in the gate** — verify path extraction from the stdin JSON
      handles a path containing spaces and a leading `./` on macOS `sed`/BSD tools.
- [ ] **word-splitting in shell loops** — confirm staged-file loops quote correctly
      so a path with spaces is not split (affects the gate and `checks/ascii-ps1.sh`).

## Remaining item 2 — live `/compact` PreCompact verification

The anchor-survival design is PreCompact-writes-to-disk + SessionStart-re-injects
(PreCompact's own injection does NOT survive — verified vs docs; do not "improve").
Confirm it end-to-end on macOS:

- [ ] In a scratch repo, open `claude`, force a compaction (`/compact`), and verify
      `pre-compact.sh` wrote `.sdad/compact_anchor.md`.
- [ ] After compaction, `session-start.sh` re-injects the `[LOCK]` anchor as
      `additionalContext` — with accents/em-dashes intact (L-01 class).

## Optional — `$eval` on macOS

The deterministic eval core is PowerShell-based (`run-eval.ps1`); on macOS it
needs PowerShell Core (`pwsh`). Not required for this task, but if `pwsh` is
available, run `pwsh .sdad/eval/run-eval.ps1` and note any platform deltas.

## Closing (SDAD discipline)

1. Work on a branch (`hooks-macos-verify`), never on `main`.
2. DECISIONS.md entry with the results; flip the two P2 findings to resolved or
   record the fix.
3. Lesson candidate if a macOS-specific quirk surfaced.
4. PR to `main` — Diego reviews and merges.

## Mandatory reference reading

- `.claude/hooks/README.md` — what each hook does and its safeguards
- `.claude/hooks/pre-tool-use-spec-gate.ps1` — the functional spec for the `.sh` gate
- `.sdad/eval/scenarios/01-05` — the gate test cases to mirror
- https://code.claude.com/docs/en/hooks — stdin JSON format and exit codes
