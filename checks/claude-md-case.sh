#!/bin/sh
# SDAD v5 -- L-04 ratchet check: the methodology file is CLAUDE.md (all caps).
# Flags the wrong-case form in code/config, where it is a real path or URL and
# breaks on case-sensitive surfaces (GitHub raw, git ls-tree, Linux FS).
# Mirror of checks/claude-md-case.ps1 -- keep the two in sync.
# Usage: sh checks/claude-md-case.sh [files...]  (default: tracked code/config)
# Prose (.md, .html) legitimately names the bug and is not scanned.
# The needle is built by concatenation so this script never contains it contiguous.
# Exit 0 = clean, 1 = violation (fails CLOSED, like ascii-ps1).

pre="Claude"
needle="${pre}.md"   # wrong-case form; CLAUDE.md (all caps) is correct

if [ $# -gt 0 ]; then
  files="$@"
else
  files=$(git ls-files -- '*.ps1' '*.psm1' '*.sh' '*.json' '*.bat' '*.cmd' '*.yml' '*.yaml' 2>/dev/null)
fi

bad=0
for f in $files; do
  [ -f "$f" ] || continue
  if grep -n -F "$needle" "$f" >/dev/null 2>&1; then
    n=$(grep -c -F "$needle" "$f")
    echo "CASE VIOLATION: $f ($n) -- use CLAUDE.md (all caps)"
    bad=$((bad + n))
  fi
done

if [ "$bad" -gt 0 ]; then
  echo "claude-md-case: $bad reference(s) use the wrong case (L-04)"
  exit 1
fi
exit 0
