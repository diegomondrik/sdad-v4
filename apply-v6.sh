#!/usr/bin/env bash
# SDAD v6.0 -- Upgrade script for Mac / Linux
# Spec-Driven AI Development -- G7 AI Development Methodology
# Version: 6.0 | 2026
#
# L-01 rule: this file is pure ASCII -- no em-dashes, accents, arrows, or section symbols.
#
# PURPOSE: idempotent script that ships the .claude/ delta from v5 to v6.
# Run from the repo root AFTER pulling v6:
#
#   git tag v5.2            (preserve prior state)
#   git pull                (fetch v6)
#   bash apply-v6.sh
#
# If you are doing a fresh install on a new machine, run install.sh instead --
# it already includes the full v6 file set.

set -e

REPO="https://raw.githubusercontent.com/diegomondrik/sdad-v4/main"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
GRAY='\033[0;37m'
NC='\033[0m'

echo ""
echo "============================================"
echo "  SDAD v6.0 -- Upgrade from v5.x"
echo "============================================"
echo ""

# ---- STEP 1: Verify prerequisites ------------------------------------------

echo -e "${YELLOW}[ 1/5 ] Checking prerequisites...${NC}"

if command -v claude &>/dev/null; then
    echo -e "${GREEN}  OK     Claude Code $(claude --version 2>&1 || true)${NC}"
else
    echo -e "${RED}  ERROR  Claude Code not found. Run install.sh first.${NC}"
    exit 1
fi

if git rev-parse --git-dir &>/dev/null 2>&1; then
    echo -e "${GREEN}  OK     git repo detected${NC}"
else
    echo -e "${RED}  ERROR  Not inside a git repo.${NC}"
    exit 1
fi

# ---- STEP 2: Create new directories ----------------------------------------

echo ""
echo -e "${YELLOW}[ 2/5 ] Creating new directories...${NC}"

mkdir -p \
    .claude/skills/pyplan-audit \
    .claude/skills/business-alignment \
    .claude/skills/domain-finance \
    .claude/skills/domain-supply-chain \
    .sdad/audit/lib \
    .sdad/audit/_fixtures \
    .sdad/eval/scenarios/13-claude-md-case \
    .sdad/eval/scenarios/14-ci-spec-gate-policy \
    .sdad/eval/scenarios/15-audit-evidence-schema \
    .sdad/eval/scenarios/16-mcp-tool-audit \
    .sdad/eval/scenarios/17-missing-result-assign \
    .sdad/eval/scenarios/18-circular-deps \
    .sdad/eval/scenarios/19-gate-allow-audit \
    .sdad/eval/scenarios/20-audit-usability-no-app \
    .sdad/eval/scenarios/21-audit-report-integrity \
    .sdad/eval/scenarios/22-severity-determinism

echo -e "${GREEN}  OK     directories ready${NC}"

# ---- STEP 3: Download new v6 files -----------------------------------------

echo ""
echo -e "${YELLOW}[ 3/5 ] Downloading v6 files...${NC}"

download_file() {
    local dest="$1"
    local url="$REPO/$dest"
    mkdir -p "$(dirname "$dest")"
    if curl -fsSL "$url" -o "$dest" 2>/dev/null; then
        echo -e "${GREEN}  OK     $dest${NC}"
    else
        echo -e "${YELLOW}  WARN   Could not download $dest${NC}"
        echo -e "${YELLOW}         $url${NC}"
    fi
}

# New skills
download_file ".claude/skills/pyplan-audit/SKILL.md"
download_file ".claude/skills/pyplan-audit/report-template.md"
download_file ".claude/skills/business-alignment/SKILL.md"
download_file ".claude/skills/domain-finance/SKILL.md"
download_file ".claude/skills/domain-supply-chain/SKILL.md"
download_file ".claude/skills/pyplan/mcp/SKILL.md"

# New checks
download_file "checks/audit-evidence.ps1"
download_file "checks/audit-evidence.sh"
download_file "checks/mcp-tool-audit.ps1"
download_file "checks/mcp-tool-audit.sh"
download_file "checks/missing-result-assign.ps1"
download_file "checks/missing-result-assign.sh"
download_file "checks/circular-deps.ps1"
download_file "checks/circular-deps.sh"
download_file "checks/spec-gate-policy.ps1"
download_file "checks/spec-gate-policy.sh"
download_file "checks/audit-report-integrity.ps1"
download_file "checks/audit-report-integrity.sh"
chmod +x checks/*.sh 2>/dev/null || true

# Audit library
download_file ".sdad/audit/lib/acquire-evidence.ps1"
download_file ".sdad/audit/lib/acquire-evidence.sh"
download_file ".sdad/audit/SCHEMA.md"
chmod +x .sdad/audit/lib/*.sh 2>/dev/null || true

# New eval scenarios
for n in 13-claude-md-case 14-ci-spec-gate-policy 15-audit-evidence-schema \
         16-mcp-tool-audit 17-missing-result-assign 18-circular-deps \
         19-gate-allow-audit 20-audit-usability-no-app \
         21-audit-report-integrity 22-severity-determinism; do
    download_file ".sdad/eval/scenarios/$n/run.ps1"
done

# Refresh updated existing files
echo ""
echo -e "${YELLOW}  Refreshing updated v6 files...${NC}"
for f in ".claude/agents/HANDOFF_TEMPLATE.md" \
          ".claude/agents/code-reviewer.md" \
          ".claude/agents/security-auditor.md" \
          ".sdad/eval/run-eval.ps1" \
          ".sdad/eval/llm-smoke.ps1" \
          ".sdad/eval/lib/assert-claude-md.ps1"; do
    if curl -fsSL "$REPO/$f" -o "$f" 2>/dev/null; then
        echo -e "${GREEN}  OK     $f (refreshed)${NC}"
    else
        echo -e "${YELLOW}  WARN   Could not refresh $f${NC}"
    fi
done

# ---- STEP 4: Scaffold .sdad/audit/ for existing projects --------------------

echo ""
echo -e "${YELLOW}[ 4/5 ] Scaffolding audit workspace...${NC}"

if [ ! -f ".sdad/audit/.gitkeep" ]; then
    : > .sdad/audit/.gitkeep
    echo -e "${GREEN}  OK     .sdad/audit/ ready (evidence goes here per \$audit)${NC}"
else
    echo -e "${CYAN}  SKIP   .sdad/audit/ already present${NC}"
fi

# ---- STEP 5: Check CLAUDE.md -----------------------------------------------

echo ""
echo -e "${YELLOW}[ 5/5 ] Checking CLAUDE.md...${NC}"

if [ -f "CLAUDE.md" ]; then
    if grep -q "SDAD v6" CLAUDE.md 2>/dev/null; then
        echo -e "${GREEN}  OK     CLAUDE.md already at v6.0${NC}"
    elif grep -q "SDAD v5" CLAUDE.md 2>/dev/null; then
        echo -e "${YELLOW}  INFO   CLAUDE.md still at v5 -- replace with the v6 CLAUDE.md from the repo.${NC}"
        echo -e "${YELLOW}         Run: curl -fsSL $REPO/CLAUDE.md -o CLAUDE.md${NC}"
        echo -e "${YELLOW}         (Only do this if CLAUDE.md is the unmodified SDAD block -- back it up first.)${NC}"
    else
        echo -e "${YELLOW}  INFO   CLAUDE.md found but no SDAD version marker detected.${NC}"
    fi
else
    echo -e "${YELLOW}  WARN   CLAUDE.md not found. Run: curl -fsSL $REPO/CLAUDE.md -o CLAUDE.md${NC}"
fi

# ---- Summary ----------------------------------------------------------------

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  SDAD v6.0 upgrade complete${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "What was added:"
echo "  .claude/skills/pyplan-audit/             5-dimension audit engine"
echo "  .claude/skills/business-alignment/       alignment + domain-agnostic core"
echo "  .claude/skills/domain-finance/           FP&A domain-correctness profile"
echo "  .claude/skills/domain-supply-chain/      supply-chain domain-correctness profile"
echo "  .claude/skills/pyplan/mcp/               @mcp_tool producer + consumer rules"
echo "  checks/audit-evidence + mcp-tool-audit   evidence + MCP ratchets"
echo "  checks/missing-result-assign + circular-deps  node-graph ratchets"
echo "  checks/spec-gate-policy + audit-report-integrity  policy ratchets"
echo "  .sdad/audit/                             evidence + report workspace"
echo "  .sdad/eval/ scenarios 13-22              extended golden dataset (22 total)"
echo ""
echo -e "${CYAN}Next: run \$eval to verify the full 22-scenario golden dataset.${NC}"
echo ""

# Self-delete on success
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
rm -f "$SCRIPT_PATH"
echo -e "${GRAY}  (apply-v6.sh removed -- one-shot script)${NC}"
