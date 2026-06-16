#!/bin/sh
# SDAD v5 -- L-01 ratchet check: every .ps1 must be pure ASCII (POSIX engine).
# Mirror of checks/ascii-ps1.ps1 -- keep the two in sync.
# Usage: sh checks/ascii-ps1.sh [files...]   (default: all git-tracked .ps1)
# Exit 0 = clean, 1 = violations (commit-time guard fails CLOSED, see SPEC R3).

# Build the file list as positional params so paths with spaces survive (INC-2 P2).
if [ $# -eq 0 ]; then
  oldIFS=$IFS
  IFS='
'
  set -- $(git ls-files -- '*.ps1' 2>/dev/null)
  IFS=$oldIFS
fi

bad=0
for f in "$@"; do
  [ -f "$f" ] || continue
  n=$(LC_ALL=C tr -d '\000-\177' < "$f" | wc -c | tr -d ' ')
  if [ "$n" -gt 0 ]; then
    echo "ASCII VIOLATION: $f ($n non-ASCII bytes)"
    bad=$((bad + 1))
  fi
done

if [ "$bad" -gt 0 ]; then
  echo "ascii-ps1: $bad file(s) violate L-01 (pure-ASCII .ps1)"
  exit 1
fi
exit 0
