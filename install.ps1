# SDAD v4.1 — Installer for Windows (PowerShell)
# Spec-Driven AI Development — G7 AI Development Methodology
# Version: 4.1 | 2026
#
# Run from inside the project repo where you want SDAD installed:
#
#   Option A — paste directly (recommended):
#   $sdad = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/install.ps1" -UseBasicParsing).Content
#   Invoke-Expression $sdad
#
#   Option B — download first, then run:
#   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/install.ps1" -OutFile "install-sdad.ps1"
#   powershell -ExecutionPolicy Bypass -File ".\install-sdad.ps1"

$ErrorActionPreference = "Stop"
$REPO = "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main"
$SKILLS_BASE = ".claude/skills"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  SDAD v4.1 — Installer" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ─── STEP 1: Check prerequisites ─────────────────────────────────────────────

Write-Host "[ 1/7 ] Checking prerequisites..." -ForegroundColor Yellow

# Node.js
try {
    $nodeVersion = (node --version 2>&1)
    $nodeMajor = [int]($nodeVersion -replace 'v(\d+).*', '$1')
    if ($nodeMajor -lt 18) {
        Write-Host "  ERROR  Node.js $nodeVersion found — v18 or higher required." -ForegroundColor Red
        Write-Host "         Install from https://nodejs.org and re-run." -ForegroundColor Red
        exit 1
    }
    Write-Host "  OK     Node.js $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "  ERROR  Node.js not found. Install from https://nodejs.org and re-run." -ForegroundColor Red
    exit 1
}

# Claude Code
try {
    $claudeVersion = (claude --version 2>&1)
    Write-Host "  OK     Claude Code $claudeVersion" -ForegroundColor Green
} catch {
    Write-Host "  INSTALLING  Claude Code..." -ForegroundColor Yellow
    npm install -g @anthropic-ai/claude-code
    Write-Host "  OK     Claude Code installed" -ForegroundColor Green
}

# Git
try {
    git rev-parse --git-dir 2>&1 | Out-Null
    Write-Host "  OK     git repo detected" -ForegroundColor Green
} catch {
    Write-Host "  WARNING  Not inside a git repo. Initializing..." -ForegroundColor Yellow
    git init
    Write-Host "  OK     git initialized" -ForegroundColor Green
}

# ─── STEP 2: Create .claude/ folder structure ─────────────────────────────────

Write-Host ""
Write-Host "[ 2/7 ] Creating .claude/ folder structure..." -ForegroundColor Yellow

$folders = @(
    ".claude/skills/ai-architect",
    ".claude/skills/ai-engineer",
    ".claude/skills/qa-engineer",
    ".claude/skills/compliance",
    ".claude/skills/frontend",
    ".claude/skills/pyplan/diagram",
    ".claude/skills/pyplan/interfaces",
    ".claude/skills/pyplan/qa-platform",
    ".claude/skills/pyplan/spec-context",
    ".claude/skills/pyplan/mcp",
    ".claude/skills/decision-architecture",
    ".claude/skills/data-discovery",
    ".claude/agents",
    ".claude/hooks"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
}

Write-Host "  OK     Folder structure created" -ForegroundColor Green

# ─── STEP 3: Download and install skill files ─────────────────────────────────

Write-Host ""
Write-Host "[ 3/7 ] Downloading skill files..." -ForegroundColor Yellow

$skillFiles = @{
    ".claude/skills/ai-architect/SKILL.md"               = "$REPO/.claude/skills/ai-architect/SKILL.md"
    ".claude/skills/ai-engineer/SKILL.md"                = "$REPO/.claude/skills/ai-engineer/SKILL.md"
    ".claude/skills/qa-engineer/SKILL.md"                = "$REPO/.claude/skills/qa-engineer/SKILL.md"
    ".claude/skills/compliance/SKILL.md"                 = "$REPO/.claude/skills/compliance/SKILL.md"
    ".claude/skills/frontend/SKILL.md"                   = "$REPO/.claude/skills/frontend/SKILL.md"
    ".claude/skills/pyplan/diagram/SKILL.md"             = "$REPO/.claude/skills/pyplan/diagram/SKILL.md"
    ".claude/skills/pyplan/interfaces/SKILL.md"          = "$REPO/.claude/skills/pyplan/interfaces/SKILL.md"
    ".claude/skills/pyplan/qa-platform/SKILL.md"         = "$REPO/.claude/skills/pyplan/qa-platform/SKILL.md"
    ".claude/skills/pyplan/spec-context/SKILL.md"        = "$REPO/.claude/skills/pyplan/spec-context/SKILL.md"
    ".claude/skills/pyplan/mcp/SKILL.md"                 = "$REPO/.claude/skills/pyplan/mcp/SKILL.md"
    ".claude/skills/decision-architecture/SKILL.md"      = "$REPO/.claude/skills/decision-architecture/SKILL.md"
    ".claude/skills/data-discovery/SKILL.md"             = "$REPO/.claude/skills/data-discovery/SKILL.md"
    ".claude/agents/code-reviewer.md"                    = "$REPO/.claude/agents/code-reviewer.md"
    ".claude/agents/security-auditor.md"                 = "$REPO/.claude/agents/security-auditor.md"
    ".claude/agents/test-generator.md"                   = "$REPO/.claude/agents/test-generator.md"
}

foreach ($dest in $skillFiles.Keys) {
    $url = $skillFiles[$dest]
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        Write-Host "  OK     $dest" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR  Could not download $dest" -ForegroundColor Red
        Write-Host "         Check your internet connection or download manually from:" -ForegroundColor Red
        Write-Host "         $url" -ForegroundColor Red
    }
}

# ─── STEP 4: Install CLAUDE.md ───────────────────────────────────────────────

Write-Host ""
Write-Host "[ 4/7 ] Installing CLAUDE.md..." -ForegroundColor Yellow

$claudeMdUrl = "$REPO/Claude.md"

if (Test-Path "CLAUDE.md") {
    $existing = Get-Content "CLAUDE.md" -Raw
    if ($existing -match "SDAD v4") {
        Write-Host "  SKIP   SDAD v4.1 block already present in CLAUDE.md" -ForegroundColor Cyan
    } else {
        Write-Host "  WARNING  Existing CLAUDE.md found. Appending SDAD block." -ForegroundColor Yellow
        $sdadBlock = (Invoke-WebRequest -Uri $claudeMdUrl -UseBasicParsing).Content
        Add-Content "CLAUDE.md" "`n`n$sdadBlock"
        Write-Host "  OK     SDAD v4.1 block appended to CLAUDE.md" -ForegroundColor Green
    }
} else {
    Invoke-WebRequest -Uri $claudeMdUrl -OutFile "CLAUDE.md" -UseBasicParsing
    Write-Host "  OK     CLAUDE.md installed" -ForegroundColor Green
}

# ─── STEP 5: Initialize project files ────────────────────────────────────────

Write-Host ""
Write-Host "[ 5/7 ] Initializing project files..." -ForegroundColor Yellow

# SPEC.md
if (-not (Test-Path "SPEC.md")) {
    Invoke-WebRequest -Uri "$REPO/SPEC_blank.md" -OutFile "SPEC.md" -UseBasicParsing
    Write-Host "  OK     SPEC.md initialized (blank template)" -ForegroundColor Green
} else {
    Write-Host "  SKIP   SPEC.md already exists — not overwritten" -ForegroundColor Cyan
}

# LESSON_LIBRARY.md
if (-not (Test-Path "LESSON_LIBRARY.md")) {
    @"
# LESSON_LIBRARY.md
# Project lesson library — entries added automatically after each `$`qa run.
# Format: L-XX | Category | Title | Signal | Principle

## Entries

_No entries yet. Run `$`qa on your first completed increment._
"@ | Out-File "LESSON_LIBRARY.md" -Encoding UTF8
    Write-Host "  OK     LESSON_LIBRARY.md created (blank)" -ForegroundColor Green
} else {
    Write-Host "  SKIP   LESSON_LIBRARY.md already exists — preserved" -ForegroundColor Cyan
}

# .gitignore
$gitignoreEntries = @(
    "",
    "# SDAD v4.1",
    ".claude/.session_tmp",
    "*.tmp"
)

if (Test-Path ".gitignore") {
    $gitignoreContent = Get-Content ".gitignore" -Raw
    if ($gitignoreContent -notmatch "SDAD v4.1") {
        Add-Content ".gitignore" ($gitignoreEntries -join "`n")
        Write-Host "  OK     .gitignore updated" -ForegroundColor Green
    } else {
        Write-Host "  SKIP   .gitignore already has SDAD entries" -ForegroundColor Cyan
    }
} else {
    $gitignoreEntries | Out-File ".gitignore" -Encoding UTF8
    Write-Host "  OK     .gitignore created" -ForegroundColor Green
}

# ─── STEP 6: Register Pyplan MCP server globally ─────────────────────────────

Write-Host ""
Write-Host "[ 6/7 ] Registering Pyplan MCP server..." -ForegroundColor Yellow

$mcpList = & claude mcp list 2>&1
if ($mcpList -match "pyplan") {
    Write-Host "  SKIP   Pyplan MCP already registered globally" -ForegroundColor Cyan
} else {
    try {
        & claude mcp add pyplan https://dev.pyplan.com/ai/mcp --transport http 2>&1 | Out-Null
        Write-Host "  OK     Pyplan MCP registered globally (dev.pyplan.com)" -ForegroundColor Green
        Write-Host "         First use will prompt for Pyplan OAuth login in browser." -ForegroundColor Cyan
    } catch {
        Write-Host "  WARNING  Could not register Pyplan MCP automatically." -ForegroundColor Yellow
        Write-Host "           Run manually: claude mcp add pyplan https://dev.pyplan.com/ai/mcp --transport http" -ForegroundColor Yellow
    }
}

# ─── STEP 7: Summary ─────────────────────────────────────────────────────────

Write-Host ""
Write-Host "[ 7/7 ] Installation complete" -ForegroundColor Yellow
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  SDAD v4.1 installed successfully" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Files installed:" -ForegroundColor White
Write-Host "  CLAUDE.md                                — core instructions" -ForegroundColor White
Write-Host "  .claude/skills/ai-architect/SKILL.md    — always active" -ForegroundColor White
Write-Host "  .claude/skills/ai-engineer/SKILL.md     — always active" -ForegroundColor White
Write-Host "  .claude/skills/qa-engineer/SKILL.md     — on-demand" -ForegroundColor White
Write-Host "  .claude/skills/compliance/SKILL.md      — on-demand (auto Tier 2/3)" -ForegroundColor White
Write-Host "  .claude/skills/frontend/SKILL.md        — on-demand" -ForegroundColor White
Write-Host "  .claude/skills/pyplan/*/SKILL.md        — Pyplan layer (5 skills)" -ForegroundColor White
Write-Host "  .claude/skills/decision-architecture/   — transversal skill" -ForegroundColor White
Write-Host "  .claude/skills/data-discovery/          — transversal skill" -ForegroundColor White
Write-Host "  .claude/agents/                          — code-reviewer, security-auditor, test-generator" -ForegroundColor White
Write-Host "  Pyplan MCP                               — registered globally (dev.pyplan.com)" -ForegroundColor White
Write-Host "  SPEC.md                                  — blank template (if new)" -ForegroundColor White
Write-Host "  LESSON_LIBRARY.md                        — blank template (if new)" -ForegroundColor White
Write-Host ""
Write-Host "Next step:" -ForegroundColor Cyan
Write-Host "  Start Claude Code: claude" -ForegroundColor Cyan
Write-Host "  Then run: `$spec  (to begin requirements for a new project)" -ForegroundColor Cyan
Write-Host "        or: `$docfinal  (to document an existing project)" -ForegroundColor Cyan
Write-Host ""
