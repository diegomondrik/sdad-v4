#!/usr/bin/env bash
# SDAD v4.0 — Installer for Mac / Linux
# Spec-Driven AI Development — G7 AI Development Methodology
# Version: 4.0 | 2026
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
echo "  SDAD v4.0 — Installer"
echo "============================================"
echo ""

# ─── STEP 1: Check prerequisites ─────────────────────────────────────────────

echo -e "${YELLOW}[ 1/6 ] Checking prerequisites...${NC}"

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
echo -e "${YELLOW}[ 2/6 ] Creating .claude/ folder structure...${NC}"

mkdir -p \
    .claude/skills/ai-architect \
    .claude/skills/ai-engineer \
    .claude/skills/pyplan/diagram \
    .claude/skills/pyplan/interfaces \
    .claude/skills/pyplan/qa-platform \
    .claude/skills/pyplan/spec-context \
    .claude/skills/decision-architecture \
    .claude/skills/data-discovery \
    .claude/hooks

echo -e "${GREEN}  OK     Folder structure created${NC}"

# ─── STEP 3: Download and install skill files ─────────────────────────────────

echo ""
echo -e "${YELLOW}[ 3/6 ] Downloading skill files...${NC}"

download_skill() {
    local dest="$1"
    local url="$REPO/$dest"
    if curl -fsSL "$url" -o "$dest" 2>/dev/null; then
        echo -e "${GREEN}  OK     $dest${NC}"
    else
        echo -e "${RED}  ERROR  Could not download $dest${NC}"
        echo -e "${RED}         Check connection or download manually from: $url${NC}"
    fi
}

download_skill ".claude/skills/ai-architect/SKILL.md"
download_skill ".claude/skills/ai-engineer/SKILL.md"
download_skill ".claude/skills/pyplan/diagram/SKILL.md"
download_skill ".claude/skills/pyplan/interfaces/SKILL.md"
download_skill ".claude/skills/pyplan/qa-platform/SKILL.md"
download_skill ".claude/skills/pyplan/spec-context/SKILL.md"
download_skill ".claude/skills/decision-architecture/SKILL.md"
download_skill ".claude/skills/data-discovery/SKILL.md"

# ─── STEP 4: Install CLAUDE.md ───────────────────────────────────────────────

echo ""
echo -e "${YELLOW}[ 4/6 ] Installing CLAUDE.md...${NC}"

if [ -f "CLAUDE.md" ]; then
    if grep -q "SDAD v4.0" CLAUDE.md 2>/dev/null; then
        echo -e "${CYAN}  SKIP   SDAD v4.0 block already present in CLAUDE.md${NC}"
    else
        echo -e "${YELLOW}  WARNING  Existing CLAUDE.md found. Appending SDAD block.${NC}"
        echo "" >> CLAUDE.md
        curl -fsSL "$REPO/Claude.md" >> CLAUDE.md
        echo -e "${GREEN}  OK     SDAD v4.0 block appended to CLAUDE.md${NC}"
    fi
else
    curl -fsSL "$REPO/Claude.md" -o CLAUDE.md
    echo -e "${GREEN}  OK     CLAUDE.md installed${NC}"
fi

# ─── STEP 5: Initialize project files ────────────────────────────────────────

echo ""
echo -e "${YELLOW}[ 5/6 ] Initializing project files...${NC}"

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
    if ! grep -q "SDAD v4.0" .gitignore 2>/dev/null; then
        printf "\n# SDAD v4.0\n.claude/.session_tmp\n*.tmp\n" >> .gitignore
        echo -e "${GREEN}  OK     .gitignore updated${NC}"
    else
        echo -e "${CYAN}  SKIP   .gitignore already has SDAD entries${NC}"
    fi
else
    printf "# SDAD v4.0\n.claude/.session_tmp\n*.tmp\n" > .gitignore
    echo -e "${GREEN}  OK     .gitignore created${NC}"
fi

# ─── STEP 6: Summary ─────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}[ 6/6 ] Installation complete${NC}"
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  SDAD v4.0 installed successfully${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Files installed:"
echo "  CLAUDE.md                                — core instructions"
echo "  .claude/skills/ai-architect/SKILL.md    — always active"
echo "  .claude/skills/ai-engineer/SKILL.md     — always active"
echo "  .claude/skills/pyplan/*/SKILL.md        — Pyplan layer (4 skills)"
echo "  .claude/skills/decision-architecture/   — transversal skill"
echo "  .claude/skills/data-discovery/          — transversal skill"
echo "  SPEC.md                                  — blank template (if new)"
echo "  LESSON_LIBRARY.md                        — blank template (if new)"
echo ""
echo -e "${CYAN}Next step:${NC}"
echo "  Start Claude Code: claude"
echo "  Then run: \$spec  (to begin requirements for a new project)"
echo "        or: \$docfinal  (to document an existing project)"
echo ""
