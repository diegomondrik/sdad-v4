#!/usr/bin/env bash
# SDAD v5.0 — Installer for Mac / Linux
# Spec-Driven AI Development — G7 AI Development Methodology
# Version: 5.0 | 2026
#
# Run from inside the project repo where you want SDAD installed:
#
#   curl -fsSL https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/install.sh | bash

set -e

REPO="https://raw.githubusercontent.com/diegomondrik/sdad-v4/main"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "============================================"
echo "  SDAD v5.0 — Installer"
echo "============================================"
echo ""

# ─── STEP 1: Check prerequisites ─────────────────────────────────────────────

echo -e "${YELLOW}[ 1/7 ] Checking prerequisites...${NC}"

# Node.js
if command -v node &>/dev/null; then
    NODE_MAJOR=$(node --version | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_MAJOR" -lt 18 ]; then
        echo -e "${RED}  ERROR  Node.js $(node --version) found — v18+ required.${NC}"
        echo -e "${RED}         Install from https://nodejs.org and re-run.${NC}"
        exit 1
    fi
    echo -e "${GREEN}  OK     Node.js $(node --version)${NC}"
else
    echo -e "${YELLOW}  INSTALLING  Node.js via nvm...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 20
    echo -e "${GREEN}  OK     Node.js installed via nvm${NC}"
fi

# Claude Code
if command -v claude &>/dev/null; then
    echo -e "${GREEN}  OK     Claude Code $(claude --version)${NC}"
else
    echo -e "${YELLOW}  INSTALLING  Claude Code...${NC}"
    npm install -g @anthropic-ai/claude-code
    echo -e "${GREEN}  OK     Claude Code installed${NC}"
fi

# Git
if git rev-parse --git-dir &>/dev/null 2>&1; then
    echo -e "${GREEN}  OK     git repo detected${NC}"
else
    echo -e "${YELLOW}  WARNING  Not inside a git repo. Initializing...${NC}"
    git init
    echo -e "${GREEN}  OK     git initialized${NC}"
fi

# ─── STEP 2: Create .claude/ folder structure ─────────────────────────────────

echo ""
echo -e "${YELLOW}[ 2/7 ] Creating .claude/ folder structure...${NC}"

mkdir -p \
    .claude/skills/ai-architect \
    .claude/skills/ai-engineer \
    .claude/skills/harness \
    .claude/skills/qa-engineer \
    .claude/skills/compliance \
    .claude/skills/frontend \
    .claude/skills/pyplan/diagram \
    .claude/skills/pyplan/interfaces \
    .claude/skills/pyplan/qa-platform \
    .claude/skills/pyplan/spec-context \
    .claude/skills/pyplan/mcp \
    .claude/skills/decision-architecture \
    .claude/skills/data-discovery \
    .claude/skills/dev-setup \
    .claude/skills/brand-design \
    .claude/skills/security-reviewer \
    .claude/agents \
    .claude/hooks \
    checks \
    .sdad/lib \
    .sdad/eval

echo -e "${GREEN}  OK     Folder structure created${NC}"

# ─── STEP 3: Download and install skill files ─────────────────────────────────

echo ""
echo -e "${YELLOW}[ 3/7 ] Downloading skill files...${NC}"

download_skill() {
    local dest="$1"
    local url="$REPO/$dest"
    mkdir -p "$(dirname "$dest")"
    if curl -fsSL "$url" -o "$dest" 2>/dev/null; then
        echo -e "${GREEN}  OK     $dest${NC}"
    else
        echo -e "${RED}  ERROR  Could not download $dest${NC}"
        echo -e "${RED}         Check connection or download manually from: $url${NC}"
    fi
}

download_skill ".claude/skills/ai-architect/SKILL.md"
download_skill ".claude/skills/ai-engineer/SKILL.md"
download_skill ".claude/skills/harness/SKILL.md"
download_skill ".claude/skills/qa-engineer/SKILL.md"
download_skill ".claude/skills/compliance/SKILL.md"
download_skill ".claude/skills/frontend/SKILL.md"
download_skill ".claude/skills/pyplan/diagram/SKILL.md"
download_skill ".claude/skills/pyplan/interfaces/SKILL.md"
download_skill ".claude/skills/pyplan/qa-platform/SKILL.md"
download_skill ".claude/skills/pyplan/spec-context/SKILL.md"
download_skill ".claude/skills/pyplan/mcp/SKILL.md"
download_skill ".claude/skills/decision-architecture/SKILL.md"
download_skill ".claude/skills/data-discovery/SKILL.md"
download_skill ".claude/skills/dev-setup/SKILL.md"
download_skill ".claude/skills/brand-design/SKILL.md"
download_skill ".claude/skills/security-reviewer/SKILL.md"
download_skill ".claude/agents/code-reviewer.md"
download_skill ".claude/agents/security-auditor.md"
download_skill ".claude/agents/test-generator.md"
download_skill ".claude/agents/HANDOFF_TEMPLATE.md"
download_skill ".claude/hooks/README.md"
download_skill ".claude/hooks/run-hook.sh"
download_skill ".claude/hooks/session-start.sh"
download_skill ".claude/hooks/pre-compact.sh"
download_skill ".claude/hooks/session-end.sh"
download_skill ".claude/hooks/session-start.ps1"
download_skill ".claude/hooks/pre-compact.ps1"
download_skill ".claude/hooks/session-end.ps1"
# v5 PreToolUse spec-gate (both variants)
download_skill ".claude/hooks/pre-tool-use-spec-gate.ps1"
download_skill ".claude/hooks/pre-tool-use-spec-gate.sh"
chmod +x .claude/hooks/*.sh 2>/dev/null

# v5 harness layer: lesson ratchet, $agent wrapper, $eval golden-dataset seed
download_skill "checks/ascii-ps1.ps1"
download_skill "checks/ascii-ps1.sh"
download_skill ".sdad/lib/agent-run.ps1"
download_skill ".sdad/lib/agent-run.sh"
download_skill ".sdad/eval/run-eval.ps1"
download_skill ".sdad/eval/llm-smoke.ps1"
download_skill ".sdad/eval/lib/assert-claude-md.ps1"
for n in 01-gate-deny-no-spec 02-gate-allow-approved 03-gate-allow-docs \
         04-gate-allow-docfinal 05-gate-fail-open 06-ascii-check \
         07-precommit-blocks 08-claude-md-structural 09-eval-detects-regression \
         10-agent-timeout 11-typed-section13 12-hold-autocommit; do
    download_skill ".sdad/eval/scenarios/$n/run.ps1"
done
chmod +x checks/*.sh .sdad/lib/*.sh 2>/dev/null

# git pre-commit ratchet -- .git/hooks is not versioned by git, so write inline.
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null || true)
if [ -n "$GIT_DIR" ]; then
    PC="$GIT_DIR/hooks/pre-commit"
    if [ -f "$PC" ] && grep -q 'SDAD v5 -- pre-commit ratchet' "$PC" 2>/dev/null; then
        echo -e "${CYAN}  SKIP   git pre-commit ratchet already installed${NC}"
    else
        [ -f "$PC" ] && cp "$PC" "$PC.backup-pre-sdad"
        mkdir -p "$GIT_DIR/hooks"
        cat > "$PC" << 'PCEOF'
#!/bin/sh
# SDAD v5 -- pre-commit ratchet (.git/hooks is not versioned by git itself).
# Blocks commits that stage a non-ASCII .ps1 (L-01). Bypass: --no-verify.
staged=$(git diff --cached --name-only --diff-filter=ACM -- '*.ps1' 2>/dev/null)
[ -n "$staged" ] || exit 0
repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
check="$repo_root/checks/ascii-ps1.sh"
[ -f "$check" ] || exit 0
if ! sh "$check" $staged; then
  echo "pre-commit: blocked by SDAD L-01 ratchet (non-ASCII .ps1 staged)." >&2
  echo "Fix the offending bytes (see output above) or use --no-verify if intentional." >&2
  exit 1
fi
exit 0
PCEOF
        chmod +x "$PC"
        echo -e "${GREEN}  OK     git pre-commit ratchet installed${NC}"
    fi
fi

# settings.json registers the three hooks via the cross-platform dispatcher
# (.claude/hooks/run-hook.sh — .sh on macOS/Linux, .ps1 on Windows/Git Bash).
# Never overwritten if the project already has one.
if [ -f ".claude/settings.json" ]; then
    echo -e "${CYAN}  SKIP   .claude/settings.json already exists — not overwritten${NC}"
else
    download_skill ".claude/settings.json"
fi

# ─── STEP 4: Install CLAUDE.md ───────────────────────────────────────────────

echo ""
echo -e "${YELLOW}[ 4/7 ] Installing CLAUDE.md...${NC}"

if [ -f "CLAUDE.md" ]; then
    if grep -q "SDAD v" CLAUDE.md 2>/dev/null; then
        echo -e "${CYAN}  SKIP   SDAD block already present in CLAUDE.md${NC}"
    else
        echo -e "${YELLOW}  WARNING  Existing CLAUDE.md found. Appending SDAD block.${NC}"
        echo "" >> CLAUDE.md
        curl -fsSL "$REPO/CLAUDE.md" >> CLAUDE.md
        echo -e "${GREEN}  OK     SDAD v5.0 block appended to CLAUDE.md${NC}"
    fi
else
    curl -fsSL "$REPO/CLAUDE.md" -o CLAUDE.md
    echo -e "${GREEN}  OK     CLAUDE.md installed${NC}"
fi

# ─── STEP 5: Initialize project files ────────────────────────────────────────

echo ""
echo -e "${YELLOW}[ 5/7 ] Initializing project files...${NC}"

# SPEC.md
if [ ! -f "SPEC.md" ]; then
    curl -fsSL "$REPO/SPEC_blank.md" -o SPEC.md
    echo -e "${GREEN}  OK     SPEC.md initialized (blank template)${NC}"
else
    echo -e "${CYAN}  SKIP   SPEC.md already exists — not overwritten${NC}"
fi

# LESSON_LIBRARY.md
if [ ! -f "LESSON_LIBRARY.md" ]; then
    cat > LESSON_LIBRARY.md << 'EOF'
# LESSON_LIBRARY.md
# Project lesson library — entries added automatically after each $qa run.
# Format: L-XX | Category | Title | Signal | Principle

## Entries

_No entries yet. Run $qa on your first completed increment._
EOF
    echo -e "${GREEN}  OK     LESSON_LIBRARY.md created (blank)${NC}"
else
    echo -e "${CYAN}  SKIP   LESSON_LIBRARY.md already exists — preserved${NC}"
fi

# .gitignore
if [ -f ".gitignore" ]; then
    if ! grep -q "SDAD v" .gitignore 2>/dev/null; then
        printf "\n# SDAD v5.0\n.claude/.session_tmp\n.sdad/agent_output.tmp\n.sdad/gate.log\n*.tmp\n" >> .gitignore
        echo -e "${GREEN}  OK     .gitignore updated${NC}"
    else
        echo -e "${CYAN}  SKIP   .gitignore already has SDAD entries${NC}"
    fi
else
    printf "# SDAD v5.0\n.claude/.session_tmp\n.sdad/agent_output.tmp\n.sdad/gate.log\n*.tmp\n" > .gitignore
    echo -e "${GREEN}  OK     .gitignore created${NC}"
fi

# ─── STEP 6: Register Pyplan MCP server globally ─────────────────────────────

echo ""
echo -e "${YELLOW}[ 6/7 ] Registering Pyplan MCP server...${NC}"

if claude mcp list 2>/dev/null | grep -q "pyplan"; then
    echo -e "${CYAN}  SKIP   Pyplan MCP already registered globally${NC}"
else
    if claude mcp add pyplan https://dev.pyplan.com/ai/mcp --transport http 2>/dev/null; then
        echo -e "${GREEN}  OK     Pyplan MCP registered globally (dev.pyplan.com)${NC}"
        echo -e "${CYAN}         First use will prompt for Pyplan OAuth login in browser.${NC}"
    else
        echo -e "${YELLOW}  WARNING  Could not register Pyplan MCP automatically.${NC}"
        echo -e "${YELLOW}           Run manually: claude mcp add pyplan https://dev.pyplan.com/ai/mcp --transport http${NC}"
    fi
fi

# ─── STEP 7: Summary ─────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}[ 7/7 ] Installation complete${NC}"
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  SDAD v5.0 installed successfully${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Files installed:"
echo "  CLAUDE.md                                — core instructions (v5.0)"
echo "  .claude/skills/                          — AI Architect, AI Engineer, harness + on-demand skills"
echo "  .claude/agents/                          — code-reviewer, security-auditor, test-generator + HANDOFF"
echo "  .claude/hooks/                           — session hooks + PreToolUse spec-gate (.sh + .ps1)"
echo "  .claude/settings.json                    — hook registration (if new)"
echo "  checks/ascii-ps1                          — lesson-to-guardrail ratchet (L-01)"
echo "  .git/hooks/pre-commit                     — ASCII ratchet hard stop"
echo "  .sdad/lib/agent-run                       — \$agent liveness wrapper (600s timeout)"
echo "  .sdad/eval/                               — \$eval golden dataset + runner"
echo "  Pyplan MCP                               — registered globally (dev.pyplan.com)"
echo "  SPEC.md / LESSON_LIBRARY.md               — blank templates (if new)"
echo ""
echo -e "${CYAN}Next step:${NC}"
echo "  Start Claude Code: claude"
echo "  Then run: \$spec  (to begin requirements for a new project)"
echo "        or: \$docfinal  (to document an existing project)"
echo ""
