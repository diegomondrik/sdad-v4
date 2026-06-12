#!/bin/sh
# SDAD v4.3 -- SessionEnd hook (macOS/Linux, POSIX sh)
# 1:1 port of session-end.ps1.
# Purpose: batch auto-commit at session end of ONLY the SDAD doc files.
# Safeguards (all mandatory):
#   - Whitelist: commits ONLY DECISIONS.md and LESSON_LIBRARY.md. Never code, never `git add .`.
#   - Hold sentinel: if .sdad/HOLD_AUTOCOMMIT exists (open P0 / failing increment), do nothing.
#   - No empty commit: commits only if a whitelisted file actually changed.
#   - Standardized commit message.
# Safety: always exits 0.

cat >/dev/null 2>&1 || true

root=${CLAUDE_PROJECT_DIR:-$(pwd)}

# Guard: hold sentinel blocks all autocommit
[ -f "$root/.sdad/HOLD_AUTOCOMMIT" ] && exit 0

cd "$root" 2>/dev/null || exit 0

changed=''
for f in DECISIONS.md LESSON_LIBRARY.md; do
  if [ -f "$f" ]; then
    if [ -n "$(git status --porcelain -- "$f" 2>/dev/null)" ]; then
      changed="$changed $f"
    fi
  fi
done

if [ -n "$changed" ]; then
  # $changed is intentionally unquoted: whitelist names contain no spaces
  git add -- $changed >/dev/null 2>&1
  if ! git diff --cached --quiet -- $changed 2>/dev/null; then
    git commit -m 'docs: auto-commit SDAD docs at session end' -- $changed >/dev/null 2>&1
  fi
fi
exit 0