#!/bin/sh
# SDAD v5 -- PreToolUse spec gate (POSIX port of pre-tool-use-spec-gate.ps1)
# STATUS: PENDING macOS TEST -- see docs/TASK_HOOKS_MACOS_PORT.md (L-01 principle:
# never declare a hook tested on a platform it has not run on).
# Exit codes: 0 = allow, 2 = deny (stderr fed back to the model).
# Fail-open: internal errors allow the action and log to .sdad/gate.log.

proj="${CLAUDE_PROJECT_DIR:-$(pwd)}"

log_warn() {
  mkdir -p "$proj/.sdad" 2>/dev/null
  echo "$(date '+%Y-%m-%d %H:%M:%S') WARN spec-gate failed open: $1" >> "$proj/.sdad/gate.log" 2>/dev/null
}

raw=$(cat 2>/dev/null) || { log_warn "stdin read failed"; exit 0; }
[ -n "$raw" ] || exit 0

if command -v jq >/dev/null 2>&1; then
  target=$(printf '%s' "$raw" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
  [ $? -eq 0 ] || { log_warn "jq parse failed"; exit 0; }
else
  target=$(printf '%s' "$raw" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
fi
[ -n "$target" ] || exit 0

rel=$(printf '%s' "$target" | sed "s|^$proj/||" 2>/dev/null) || rel="$target"
rel_low=$(printf '%s' "$rel" | tr 'A-Z' 'a-z')
name=$(basename "$rel_low")

# SPEC R1 -- allowlist: methodology state and docs are never blocked
case "$name" in
  spec.md|spec_retroactive.md|decisions.md|lesson_library.md|changelog.md|readme.md) exit 0 ;;
esac
case "$rel_low" in
  *.md) exit 0 ;;
  docs/*|.sdad/*|.claude/*|hub/*) exit 0 ;;
esac

# $docfinal legitimately runs without a Spec (sentinel file)
[ -f "$proj/.sdad/DOCFINAL_ACTIVE" ] && exit 0

# SPEC R2 -- code-file denylist; unknown extensions default to allow
case "$rel_low" in
  *.py|*.js|*.ts|*.jsx|*.tsx|*.ps1|*.psm1|*.sh|*.bat|*.cmd|*.sql|*.html|*.css|*.json|*.yaml|*.yml|*.toml|*.ini|*.cs|*.java|*.go|*.rs|*.rb|*.php) ;;
  *) exit 0 ;;
esac

# The gate itself
if [ ! -f "$proj/SPEC.md" ]; then
  echo "SDAD gate: no SPEC.md in this project -- code writes are blocked until a Spec is approved. Run \$spec (or \$docfinal for retroactive documentation)." >&2
  exit 2
fi
if ! grep -q "SPEC STATUS: APPROVED" "$proj/SPEC.md" 2>/dev/null; then
  echo "SDAD gate: SPEC.md is not approved (missing 'SPEC STATUS: APPROVED' marker). Get developer approval before writing code." >&2
  exit 2
fi
exit 0
