#!/bin/sh
# SDAD v4.3 -- SessionStart hook (macOS/Linux, POSIX sh)
# 1:1 port of session-start.ps1.
# Purpose:
#   1) Inject the COMPACT ANCHOR ([LOCK] decisions from DECISIONS.md) into context.
#      Because SessionStart fires AFTER compaction (source=compact), this is what makes
#      the anchor SURVIVE compaction -- PreCompact's own injection does not persist.
#   2) Guarded fast-forward git pull.
# Safety: must NEVER block session start. Always exits 0. All git ops are guarded.

raw=$(cat 2>/dev/null) || raw=''

src='startup'
if [ -n "$raw" ]; then
  if command -v jq >/dev/null 2>&1; then
    s=$(printf '%s' "$raw" | jq -r '.source // empty' 2>/dev/null)
  else
    s=$(printf '%s' "$raw" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
  fi
  [ -n "$s" ] && src=$s
fi

root=${CLAUDE_PROJECT_DIR:-$(pwd)}

notes=''
append_note() {
  if [ -n "$notes" ]; then notes="$notes; $1"; else notes="$1"; fi
}

# --- Guarded git pull: fast-forward only, and only if no TRACKED files are modified ---
if cd "$root" 2>/dev/null; then
  porcelain=$(git status --porcelain 2>/dev/null)
  tracked_dirty=$(printf '%s\n' "$porcelain" | grep -v '^??' | grep -c .)
  if [ "$tracked_dirty" -gt 0 ] 2>/dev/null; then
    append_note 'git pull skipped (tracked files modified)'
  else
    if git pull --ff-only >/dev/null 2>&1; then
      append_note 'git pull ok (up-to-date or fast-forwarded)'
    else
      append_note 'git pull skipped (no upstream or not fast-forwardable)'
    fi
  fi
else
  append_note 'git pull skipped (error)'
fi

# --- Build the anchor: prefer PreCompact snapshot on compact, else DECISIONS.md [LOCK] ---
anchor=''
snap="$root/.sdad/compact_anchor.md"
if [ "$src" = 'compact' ] && [ -f "$snap" ]; then
  anchor=$(cat "$snap" 2>/dev/null)
fi
if [ -z "$anchor" ] && [ -f "$root/DECISIONS.md" ]; then
  anchor=$(awk '
    /^##[[:space:]]+\[LOCK\] decisions/ { inlock = 1; next }
    inlock && (/^##[[:space:]]/ || /^---/) { exit }
    inlock {
      line = $0
      gsub(/^[[:space:]]+/, "", line)
      gsub(/[[:space:]]+$/, "", line)
      if (line != "") print line
    }' "$root/DECISIONS.md" 2>/dev/null)
fi

ctx="SDAD session restored (source=$src). $notes."
if [ -n "$anchor" ]; then
  ctx=$(printf '%s\n\n%s\n%s' "$ctx" \
    'COMPACT ANCHOR - [LOCK] decisions that must not be reopened:' "$anchor")
fi

# --- Emit hook JSON (jq when available, manual escaping as fallback) ---
if command -v jq >/dev/null 2>&1; then
  jq -cn --arg ctx "$ctx" \
    '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$ctx}}'
else
  esc=$(printf '%s' "$ctx" | awk 'BEGIN { ORS = "" } {
    gsub(/\\/, "\\\\"); gsub(/"/, "\\\""); gsub(/\t/, "\\t"); gsub(/\r/, "\\r")
    if (NR > 1) printf "\\n"
    printf "%s", $0
  }')
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$esc"
fi
exit 0