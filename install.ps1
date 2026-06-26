# SDAD v5.2 -- Installer for Windows (PowerShell)
# Spec-Driven AI Development -- G7 AI Development Methodology
# Version: 5.2 | 2026
#
# L-01 rule: this file is pure ASCII -- no em-dashes, accents, arrows, or section symbols.
#
# Run from inside the project repo where you want SDAD installed:
#
#   Option A -- paste directly (recommended):
#   $sdad = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/install.ps1" -UseBasicParsing).Content
#   Invoke-Expression $sdad
#
#   Option B -- download first, then run:
#   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/install.ps1" -OutFile "install-sdad.ps1"
#   powershell -ExecutionPolicy Bypass -File ".\install-sdad.ps1"

$ErrorActionPreference = "Stop"
$REPO = "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  SDAD v5.2 -- Installer" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ---- STEP 1: Check prerequisites ------------------------------------------

Write-Host "[ 1/7 ] Checking prerequisites..." -ForegroundColor Yellow

# Node.js
try {
    $nodeVersion = (node --version 2>&1)
    $nodeMajor = [int]($nodeVersion -replace 'v(\d+).*', '$1')
    if ($nodeMajor -lt 18) {
        Write-Host "  ERROR  Node.js $nodeVersion found -- v18 or higher required." -ForegroundColor Red
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

# ---- STEP 2: Create .claude/ folder structure -----------------------------

Write-Host ""
Write-Host "[ 2/7 ] Creating folder structure..." -ForegroundColor Yellow

$folders = @(
    ".claude/skills/ai-architect",
    ".claude/skills/ai-engineer",
    ".claude/skills/harness",
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
    ".claude/skills/dev-setup",
    ".claude/skills/brand-design",
    ".claude/skills/security-reviewer",
    ".claude/skills/board",
    ".claude/skills/board/spec-context",
    ".claude/skills/board/data-model",
    ".claude/skills/board/capsule",
    ".claude/skills/board/qa-platform",
    ".claude/agents",
    ".claude/hooks",
    "checks",
    ".sdad/lib",
    ".sdad/eval"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
}

Write-Host "  OK     Folder structure created" -ForegroundColor Green

# ---- STEP 3: Download and install methodology files -----------------------

Write-Host ""
Write-Host "[ 3/7 ] Downloading methodology files..." -ForegroundColor Yellow

# Paths are repo-relative; the same relative path is the destination on disk.
# The v5 harness layer (gate hook, checks ratchet, .sdad/eval seed, .sdad/lib
# wrapper, harness skill) ships alongside the v4.x skills/agents/hooks.
$files = @(
    # Skills
    ".claude/skills/ai-architect/SKILL.md",
    ".claude/skills/ai-engineer/SKILL.md",
    ".claude/skills/harness/SKILL.md",
    ".claude/skills/qa-engineer/SKILL.md",
    ".claude/skills/compliance/SKILL.md",
    ".claude/skills/frontend/SKILL.md",
    ".claude/skills/pyplan/diagram/SKILL.md",
    ".claude/skills/pyplan/interfaces/SKILL.md",
    ".claude/skills/pyplan/qa-platform/SKILL.md",
    ".claude/skills/pyplan/spec-context/SKILL.md",
    ".claude/skills/pyplan/mcp/SKILL.md",
    ".claude/skills/decision-architecture/SKILL.md",
    ".claude/skills/data-discovery/SKILL.md",
    ".claude/skills/dev-setup/SKILL.md",
    ".claude/skills/brand-design/SKILL.md",
    ".claude/skills/security-reviewer/SKILL.md",
    ".claude/skills/board/SKILL.md",
    ".claude/skills/board/spec-context/SKILL.md",
    ".claude/skills/board/data-model/SKILL.md",
    ".claude/skills/board/capsule/SKILL.md",
    ".claude/skills/board/qa-platform/SKILL.md",
    # Agents
    ".claude/agents/code-reviewer.md",
    ".claude/agents/security-auditor.md",
    ".claude/agents/test-generator.md",
    ".claude/agents/HANDOFF_TEMPLATE.md",
    # Hooks (cross-platform: dispatcher + .ps1 + .sh, plus the v5 spec-gate)
    ".claude/hooks/README.md",
    ".claude/hooks/run-hook.sh",
    ".claude/hooks/session-start.ps1",
    ".claude/hooks/pre-compact.ps1",
    ".claude/hooks/session-end.ps1",
    ".claude/hooks/session-start.sh",
    ".claude/hooks/pre-compact.sh",
    ".claude/hooks/session-end.sh",
    ".claude/hooks/pre-tool-use-spec-gate.ps1",
    ".claude/hooks/pre-tool-use-spec-gate.sh",
    # Lesson ratchet (checks)
    "checks/ascii-ps1.ps1",
    "checks/ascii-ps1.sh",
    # $agent liveness wrapper
    ".sdad/lib/agent-run.ps1",
    ".sdad/lib/agent-run.sh",
    # $eval golden-dataset seed
    ".sdad/eval/run-eval.ps1",
    ".sdad/eval/llm-smoke.ps1",
    ".sdad/eval/lib/assert-claude-md.ps1",
    ".sdad/eval/scenarios/01-gate-deny-no-spec/run.ps1",
    ".sdad/eval/scenarios/02-gate-allow-approved/run.ps1",
    ".sdad/eval/scenarios/03-gate-allow-docs/run.ps1",
    ".sdad/eval/scenarios/04-gate-allow-docfinal/run.ps1",
    ".sdad/eval/scenarios/05-gate-fail-open/run.ps1",
    ".sdad/eval/scenarios/06-ascii-check/run.ps1",
    ".sdad/eval/scenarios/07-precommit-blocks/run.ps1",
    ".sdad/eval/scenarios/08-claude-md-structural/run.ps1",
    ".sdad/eval/scenarios/09-eval-detects-regression/run.ps1",
    ".sdad/eval/scenarios/10-agent-timeout/run.ps1",
    ".sdad/eval/scenarios/11-typed-section13/run.ps1",
    ".sdad/eval/scenarios/12-hold-autocommit/run.ps1"
)

foreach ($dest in $files) {
    $url = "$REPO/$dest"
    $parent = Split-Path $dest -Parent
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        Write-Host "  OK     $dest" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR  Could not download $dest" -ForegroundColor Red
        Write-Host "         $url" -ForegroundColor Red
    }
}

# .claude/settings.json -- hook registration (incl. the v5 PreToolUse gate).
# Never overwrite an existing one.
if (-not (Test-Path ".claude/settings.json")) {
    try {
        Invoke-WebRequest -Uri "$REPO/.claude/settings.json" -OutFile ".claude/settings.json" -UseBasicParsing
        Write-Host "  OK     .claude/settings.json (hooks registered)" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR  Could not download .claude/settings.json -- hooks will be inactive." -ForegroundColor Red
    }
} else {
    Write-Host "  SKIP   .claude/settings.json already exists -- merge hook registration manually (see .claude/hooks/README.md)" -ForegroundColor Cyan
}

# Install the git pre-commit ratchet. .git/hooks is not versioned by git, so it
# is written inline here (a deliberate hard stop that blocks a non-ASCII .ps1).
try {
    $gitDir = (git rev-parse --git-dir 2>$null)
    if ($gitDir) {
        $hookDir = Join-Path $gitDir "hooks"
        if (-not (Test-Path $hookDir)) { New-Item -ItemType Directory -Path $hookDir -Force | Out-Null }
        $pcDst = Join-Path $hookDir "pre-commit"
        $alreadyInstalled = (Test-Path $pcDst) -and ((Get-Content $pcDst -Raw) -match 'SDAD v5 -- pre-commit ratchet')
        if ($alreadyInstalled) {
            Write-Host "  SKIP   git pre-commit ratchet already installed" -ForegroundColor Cyan
        } else {
            if (Test-Path $pcDst) { Copy-Item $pcDst "$pcDst.backup-pre-sdad" -Force }
            $preCommit = @'
#!/bin/sh
# SDAD v5 -- pre-commit ratchet (.git/hooks is not versioned by git itself).
# Blocks commits that stage a non-ASCII .ps1 or .sh (L-01). Bypass: --no-verify.
staged=$(git diff --cached --name-only --diff-filter=ACM -- '*.ps1' '*.sh' 2>/dev/null)
[ -n "$staged" ] || exit 0
repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
check="$repo_root/checks/ascii-ps1.sh"
[ -f "$check" ] || exit 0
if ! sh "$check" $staged; then
  echo "pre-commit: blocked by SDAD L-01 ratchet (non-ASCII .ps1/.sh staged)." >&2
  echo "Fix the offending bytes (see output above) or use --no-verify if intentional." >&2
  exit 1
fi
exit 0
'@
            # Shell hook must use LF line endings -- a CRLF shebang breaks sh on
            # Windows ("bad interpreter"). Write bytes directly, normalized to LF.
            $preCommit = $preCommit -replace "`r`n", "`n"
            $pcFull = [System.IO.Path]::GetFullPath($pcDst)
            [System.IO.File]::WriteAllText($pcFull, $preCommit, (New-Object System.Text.UTF8Encoding($false)))
            Write-Host "  OK     git pre-commit ratchet installed" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "  WARNING  Could not install git pre-commit ratchet (non-fatal)." -ForegroundColor Yellow
}

# ---- STEP 4: Install CLAUDE.md --------------------------------------------

Write-Host ""
Write-Host "[ 4/7 ] Installing CLAUDE.md..." -ForegroundColor Yellow

# GitHub raw is case-sensitive: the tracked file is CLAUDE.md (upper case).
$claudeMdUrl = "$REPO/CLAUDE.md"

if (Test-Path "CLAUDE.md") {
    $existing = Get-Content "CLAUDE.md" -Raw
    if ($existing -match "SDAD v") {
        Write-Host "  SKIP   SDAD block already present in CLAUDE.md" -ForegroundColor Cyan
    } else {
        Write-Host "  WARNING  Existing CLAUDE.md found. Appending SDAD block." -ForegroundColor Yellow
        $sdadBlock = (Invoke-WebRequest -Uri $claudeMdUrl -UseBasicParsing).Content
        Add-Content "CLAUDE.md" "`n`n$sdadBlock"
        Write-Host "  OK     SDAD v5.2 block appended to CLAUDE.md" -ForegroundColor Green
    }
} else {
    Invoke-WebRequest -Uri $claudeMdUrl -OutFile "CLAUDE.md" -UseBasicParsing
    Write-Host "  OK     CLAUDE.md installed" -ForegroundColor Green
}

# ---- STEP 5: Initialize project files -------------------------------------

Write-Host ""
Write-Host "[ 5/7 ] Initializing project files..." -ForegroundColor Yellow

# SPEC.md
if (-not (Test-Path "SPEC.md")) {
    Invoke-WebRequest -Uri "$REPO/SPEC_blank.md" -OutFile "SPEC.md" -UseBasicParsing
    Write-Host "  OK     SPEC.md initialized (blank template)" -ForegroundColor Green
} else {
    Write-Host "  SKIP   SPEC.md already exists -- not overwritten" -ForegroundColor Cyan
}

# LESSON_LIBRARY.md
if (-not (Test-Path "LESSON_LIBRARY.md")) {
    @"
# LESSON_LIBRARY.md
# Project lesson library -- entries added automatically after each `$`qa run.
# Format: L-XX | Category | Title | Signal | Principle

## Entries

_No entries yet. Run `$`qa on your first completed increment._
"@ | Out-File "LESSON_LIBRARY.md" -Encoding UTF8
    Write-Host "  OK     LESSON_LIBRARY.md created (blank)" -ForegroundColor Green
} else {
    Write-Host "  SKIP   LESSON_LIBRARY.md already exists -- preserved" -ForegroundColor Cyan
}

# .gitignore
$gitignoreEntries = @(
    "",
    "# SDAD v5.2",
    ".claude/.session_tmp",
    ".sdad/agent_output.tmp",
    ".sdad/gate.log",
    "*.tmp"
)

if (Test-Path ".gitignore") {
    $gitignoreContent = Get-Content ".gitignore" -Raw
    if ($gitignoreContent -notmatch "SDAD v") {
        Add-Content ".gitignore" ($gitignoreEntries -join "`n")
        Write-Host "  OK     .gitignore updated" -ForegroundColor Green
    } else {
        Write-Host "  SKIP   .gitignore already has SDAD entries" -ForegroundColor Cyan
    }
} else {
    $gitignoreEntries | Out-File ".gitignore" -Encoding UTF8
    Write-Host "  OK     .gitignore created" -ForegroundColor Green
}

# ---- STEP 6: Register Pyplan MCP server globally --------------------------

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

# ---- STEP 7: Summary ------------------------------------------------------

Write-Host ""
Write-Host "[ 7/7 ] Installation complete" -ForegroundColor Yellow
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  SDAD v5.2 installed successfully" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Files installed:" -ForegroundColor White
Write-Host "  CLAUDE.md                                core instructions (v5.2)" -ForegroundColor White
Write-Host "  .claude/skills/                          AI Architect, AI Engineer, harness + on-demand skills" -ForegroundColor White
Write-Host "  .claude/agents/                          code-reviewer, security-auditor, test-generator + HANDOFF" -ForegroundColor White
Write-Host "  .claude/hooks/                           session hooks + PreToolUse spec-gate (.ps1 + .sh)" -ForegroundColor White
Write-Host "  .claude/settings.json                    hook registration (if new)" -ForegroundColor White
Write-Host "  checks/ascii-ps1                         lesson-to-guardrail ratchet (L-01)" -ForegroundColor White
Write-Host "  .git/hooks/pre-commit                    ASCII ratchet hard stop" -ForegroundColor White
Write-Host "  .sdad/lib/agent-run                      `$agent liveness wrapper (600s timeout)" -ForegroundColor White
Write-Host "  .sdad/eval/                              `$eval golden dataset + runner" -ForegroundColor White
Write-Host "  Pyplan MCP                               registered globally (dev.pyplan.com)" -ForegroundColor White
Write-Host "  SPEC.md / LESSON_LIBRARY.md              blank templates (if new)" -ForegroundColor White
Write-Host ""
Write-Host "Next step:" -ForegroundColor Cyan
Write-Host "  Start Claude Code: claude" -ForegroundColor Cyan
Write-Host "  Then run: `$spec  (to begin requirements for a new project)" -ForegroundColor Cyan
Write-Host "        or: `$docfinal  (to document an existing project)" -ForegroundColor Cyan
Write-Host ""
