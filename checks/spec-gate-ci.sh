#!/bin/sh
# SDAD v5.1 -- CI spec gate (server-side, authoritative). Applies the shared
# spec-gate policy (checks/spec-gate-policy.sh) to every code file changed in a
# pull request. Fails CLOSED: any denied path fails the job -- CI is the guarantee,
# unlike the local hook which fails open for fast feedback (SPEC F1/F4).
# Usage: sh checks/spec-gate-ci.sh [base_ref]
#   base_ref: branch to diff against (default: $GITHUB_BASE_REF, else 'main').
# Exit 0 = all changed paths allowed, 1 = at least one denied (or error).
#
# H-01 (L-05): the decision logic must come from a TRUSTED ref, not the PR's
# checkout, or a PR could edit the policy to pass itself. The workflow extracts
# the base-ref policy to a temp file and points SPEC_GATE_POLICY at it; the file
# LIST and the SPEC.md approval state still come from the PR (approving the spec
# is legitimately part of the PR). Falls back to the in-repo policy when the base
# predates the gate (the PR that first introduces it).
# L-01: pure ASCII.

repo=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "spec-gate-ci: not a git repo"; exit 1; }
cd "$repo" || exit 1

base=${1:-${GITHUB_BASE_REF:-main}}
policy=${SPEC_GATE_POLICY:-"$repo/checks/spec-gate-policy.sh"}
[ -f "$policy" ] || { echo "spec-gate-ci: missing policy $policy"; exit 1; }

baseref="$base"
if git rev-parse --verify --quiet "origin/$base" >/dev/null 2>&1; then
  baseref="origin/$base"
fi

mergebase=$(git merge-base "$baseref" HEAD 2>/dev/null)
# core.quotepath=false keeps non-ASCII / spaced paths verbatim (INC-2 P2).
if [ -z "$mergebase" ]; then
  echo "spec-gate-ci: cannot resolve merge-base with $baseref; scanning full HEAD tree"
  changed=$(git -c core.quotepath=false ls-files)
else
  changed=$(git -c core.quotepath=false diff --name-only --diff-filter=ACMR "$mergebase" HEAD)
fi

denied=0
# Iterate over newline-separated paths. (Paths containing spaces are hardened in INC-2.)
IFS='
'
for f in $changed; do
  [ -n "$f" ] || continue
  msg=$(sh "$policy" "$f" "$repo" 2>&1)
  code=$?
  if [ "$code" -eq 2 ]; then
    echo "DENY  $f"
    echo "      $msg"
    denied=$((denied + 1))
  fi
done
unset IFS

if [ "$denied" -gt 0 ]; then
  echo ""
  echo "spec-gate-ci: $denied changed code file(s) require an approved SPEC.md. Blocking merge."
  exit 1
fi
echo "spec-gate-ci: all changed paths cleared the spec gate."
exit 0
