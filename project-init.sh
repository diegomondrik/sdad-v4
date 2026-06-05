#!/usr/bin/env bash
# SDAD v4.0 — Project Initializer (Mac / Linux)
# Run from inside the project repo you want to initialize.
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/project-init.sh)

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}======================================"
echo -e "  SDAD v4.1 — Project Initializer"
echo -e "======================================${NC}"
echo ""

# ── 1. Verify Claude Code is installed ────────────────────────────────────────

echo -e "${YELLOW}Checking Claude Code...${NC}"
if command -v claude &> /dev/null; then
    CLAUDE_VER=$(claude --version 2>&1 || true)
    echo -e "  ${GREEN}Claude Code found: $CLAUDE_VER${NC}"
else
    echo -e "  Claude Code not found. Running methodology installer first..."
    echo ""
    bash <(curl -fsSL https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/install.sh)
fi

# ── 2. Verify git repo ────────────────────────────────────────────────────────

echo -e "${YELLOW}Checking git repository...${NC}"
if git status &> /dev/null; then
    echo -e "  ${GREEN}Git repository detected.${NC}"
else
    echo -e "  No git repository found. Initializing..."
    git init
    echo -e "  ${GREEN}Git initialized.${NC}"
fi

# ── 3. Collect project info ───────────────────────────────────────────────────

echo ""
echo -e "${CYAN}Project setup"
echo -e "─────────────────────────────────────${NC}"

# Project name — infer from folder name as default
FOLDER_NAME=$(basename "$PWD")
read -p "Project name [$FOLDER_NAME]: " PROJECT_NAME_INPUT
PROJECT_NAME="${PROJECT_NAME_INPUT:-$FOLDER_NAME}"

# Developer name
read -p "Your name: " DEV_NAME
DEV_NAME="${DEV_NAME:-Developer}"

# Client name (optional)
read -p "Client name (leave blank if internal project): " CLIENT_NAME

# Compliance tier
echo ""
echo -e "${CYAN}Compliance tier:${NC}"
echo "  1  Tier 1 — Standard   (internal tools, POCs, scripts)"
echo "  2  Tier 2 — Business   (SaaS, customer-facing, user data)"
echo "  3  Tier 3 — Enterprise (regulated environments, corporate IT)"
echo ""
read -p "Select tier [1]: " TIER_INPUT

case "$TIER_INPUT" in
    2) TIER="Tier 2 — Business" ;;
    3) TIER="Tier 3 — Enterprise" ;;
    *) TIER="Tier 1 — Standard" ;;
esac

TODAY=$(date +%Y-%m-%d)

# ── 4. Create SPEC.md ─────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}Creating project files...${NC}"

if [ -f "SPEC.md" ]; then
    echo -e "  ${YELLOW}SPEC.md already exists — skipping.${NC}"
else
    cat > SPEC.md << SPECEOF
# SPEC.md — $PROJECT_NAME
**Version:** 1.0
**Date:** $TODAY
**Developer:** $DEV_NAME
**Compliance Tier:** $TIER
**Status:** Draft — run \$spec to fill in requirements

---

## §1 — Vision & Objective

**Problem:**
[Describe the problem this project solves]

**Solution:**
[Describe the proposed solution]

**Success criteria:**
- [Criterion 1]
- [Criterion 2]

---

## §2 — Users & Roles

| Role | Description | Access |
|------|-------------|--------|
| [Role 1] | [Description] | [Permissions] |

---

## §3 — Functional Flows

### Flow 1 — [Name]
[Step-by-step flow description]

---

## §4 — Data Model

[Entities, data structures, key files]

---

## §5 — Technical Architecture

**Stack:**
- [Language / Framework]
- [Key dependencies]

**Components:**
| Component | Role |
|-----------|------|
| [name] | [description] |

---

## §6 — Business Rules

1. [Business rule 1]
2. [Business rule 2]

---

## §7 — Integrations & APIs

| Integration | Endpoint | Usage |
|-------------|----------|-------|
| [name] | [endpoint] | [usage] |

---

## §8 — Testing Strategy

| Test | Type | Trigger |
|------|------|---------|
| [description] | [unit/integration/E2E/manual] | [trigger] |

---

## §9 — Security & Compliance ($TIER)

**Assets to protect:**
- [asset 1]

**Controls:**
- [control 1]

---

## §10 — Definition of Done

An increment is complete when:
- [ ] All acceptance criteria from SPEC.md met
- [ ] Tests pass without errors
- [ ] No regressions introduced
- [ ] README or RUNBOOK updated if behavior changed
- [ ] SPEC.md §13 AI Authorship Log entry delivered

---

## §11 — Out of Scope

- [Out of scope item 1]

---

## §12 — Open Decisions

| # | Decision | Status |
|---|----------|--------|
| OD-01 | [description] | Open |

---

## §13 — AI Authorship Log

| Increment | Feature | Model | Date | Notes |
|-----------|---------|-------|------|-------|
| SPEC v1.0 | Initial spec | — | $TODAY | project-init |
SPECEOF
    echo -e "  ${GREEN}SPEC.md created.${NC}"
fi

# ── 5. Create LESSON_LIBRARY.md ───────────────────────────────────────────────

if [ -f "LESSON_LIBRARY.md" ]; then
    echo -e "  ${YELLOW}LESSON_LIBRARY.md already exists — preserving.${NC}"
else
    cat > LESSON_LIBRARY.md << LESSONEOF
# LESSON_LIBRARY.md — $PROJECT_NAME
# Transferable patterns captured during development.
# Entries are proposed by Claude after \$qa runs and added with your approval.
# Version: 4.1 | Created: $TODAY

---

## How to use

- \$lesson             — show all entries grouped by category
- \$lesson [keyword]   — filter by keyword, category, or stack
- \$lesson [L-XX]      — show full entry
- \$lesson new         — guided entry creation

---

## Entries

*(No entries yet — they will appear here after your first \$qa run)*
LESSONEOF
    echo -e "  ${GREEN}LESSON_LIBRARY.md created.${NC}"
fi

# ── 6. Create DECISIONS.md ────────────────────────────────────────────────────

if [ -f "DECISIONS.md" ]; then
    echo -e "  ${YELLOW}DECISIONS.md already exists — preserving.${NC}"
else
    cat > DECISIONS.md << DECEOF
# DECISIONS.md — $PROJECT_NAME
# Design decisions log. Written automatically by \$build after each increment.
# Version: 4.1 | Created: $TODAY

---

| # | Date | Decision | Rationale | Status |
|---|------|----------|-----------|--------|
| D-001 | $TODAY | Project initialized with SDAD v4.1 | $TIER | Active |
DECEOF
    echo -e "  ${GREEN}DECISIONS.md created.${NC}"
fi

# ── 7. Create .sdad/ structure ────────────────────────────────────────────────

mkdir -p .sdad/flows
echo -e "  ${GREEN}.sdad/ structure created.${NC}"

CLIENT_LINE="${CLIENT_NAME:-Internal project}"

cat > .sdad/project.md << PROJEOF
# .sdad/project.md — $PROJECT_NAME
Created: $TODAY
Developer: $DEV_NAME
Client: $CLIENT_LINE
Compliance tier: $TIER
SDAD version: 4.1

## Session log

| Date | Phase | Summary |
|------|-------|---------|
| $TODAY | Init | Project initialized with project-init |
PROJEOF
echo -e "  ${GREEN}.sdad/project.md created.${NC}"

# ── 8. Update .gitignore ──────────────────────────────────────────────────────

IGNORE_ENTRY=".sdad/agent_output.tmp"

if [ -f ".gitignore" ]; then
    if grep -qF "$IGNORE_ENTRY" .gitignore; then
        echo -e "  ${YELLOW}.gitignore already up to date.${NC}"
    else
        printf "\n# SDAD v4.0\n%s\n" "$IGNORE_ENTRY" >> .gitignore
        echo -e "  ${GREEN}.gitignore updated.${NC}"
    fi
else
    printf "# SDAD v4.0\n%s\n" "$IGNORE_ENTRY" > .gitignore
    echo -e "  ${GREEN}.gitignore created.${NC}"
fi

# ── 9. Done ───────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}======================================"
echo -e "  Project initialized successfully"
echo -e "======================================${NC}"
echo ""
echo -e "${WHITE}  Project:   $PROJECT_NAME${NC}"
echo -e "${WHITE}  Developer: $DEV_NAME${NC}"
[ -n "$CLIENT_NAME" ] && echo -e "${WHITE}  Client:    $CLIENT_NAME${NC}"
echo -e "${WHITE}  Tier:      $TIER${NC}"
echo ""
echo "Files created:"
echo "  SPEC.md"
echo "  LESSON_LIBRARY.md"
echo "  DECISIONS.md"
echo "  .sdad/project.md"
echo "  .sdad/flows/"
echo ""
echo -e "${CYAN}Next step: open Claude Code and run${NC}"
echo -e "${WHITE}  claude${NC}"
echo ""
echo -e "${CYAN}Then start with:${NC}"
echo -e "${WHITE}  \$spec   — define requirements${NC}"
echo -e "${WHITE}  \$nuevo  — if describing a new project from scratch${NC}"
echo ""
