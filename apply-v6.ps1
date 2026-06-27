# SDAD v6.0 -- Upgrade script for Windows (PowerShell)
# Spec-Driven AI Development -- G7 AI Development Methodology
# Version: 6.0 | 2026
#
# L-01 rule: this file is pure ASCII -- no em-dashes, accents, arrows, or section symbols.
#
# PURPOSE: idempotent, self-deleting script that ships the .claude/ delta from v5 to v6.
# Run from the repo root AFTER pulling v6:
#
#   git tag v5.2            (preserve prior state)
#   git pull                (fetch v6)
#   powershell -ExecutionPolicy Bypass -File ".\apply-v6.ps1"
#
# If you are doing a fresh install on a new machine, run install.ps1 instead --
# it already includes the full v6 file set.

$ErrorActionPreference = "Stop"
$REPO = "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  SDAD v6.0 -- Upgrade from v5.x" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ---- STEP 1: Verify prerequisites ------------------------------------------

Write-Host "[ 1/5 ] Checking prerequisites..." -ForegroundColor Yellow

try {
    $claudeVersion = & claude --version 2>&1
    Write-Host "  OK     Claude Code $claudeVersion" -ForegroundColor Green
} catch {
    Write-Host "  ERROR  Claude Code not found. Run install.ps1 first." -ForegroundColor Red
    exit 1
}

try {
    git rev-parse --git-dir 2>&1 | Out-Null
    Write-Host "  OK     git repo detected" -ForegroundColor Green
} catch {
    Write-Host "  ERROR  Not inside a git repo." -ForegroundColor Red
    exit 1
}

# ---- STEP 2: Create new directories ----------------------------------------

Write-Host ""
Write-Host "[ 2/5 ] Creating new directories..." -ForegroundColor Yellow

$newFolders = @(
    ".claude/skills/pyplan-audit",
    ".claude/skills/business-alignment",
    ".claude/skills/domain-finance",
    ".claude/skills/domain-supply-chain",
    ".sdad/audit/lib",
    ".sdad/audit/_fixtures",
    ".sdad/eval/scenarios/13-claude-md-case",
    ".sdad/eval/scenarios/14-ci-spec-gate-policy",
    ".sdad/eval/scenarios/15-audit-evidence-schema",
    ".sdad/eval/scenarios/16-mcp-tool-audit",
    ".sdad/eval/scenarios/17-missing-result-assign",
    ".sdad/eval/scenarios/18-circular-deps",
    ".sdad/eval/scenarios/19-gate-allow-audit",
    ".sdad/eval/scenarios/20-audit-usability-no-app",
    ".sdad/eval/scenarios/21-audit-report-integrity",
    ".sdad/eval/scenarios/22-severity-determinism"
)

foreach ($folder in $newFolders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "  OK     $folder" -ForegroundColor Green
    } else {
        Write-Host "  SKIP   $folder (exists)" -ForegroundColor Cyan
    }
}

# ---- STEP 3: Download new v6 files -----------------------------------------

Write-Host ""
Write-Host "[ 3/5 ] Downloading v6 files..." -ForegroundColor Yellow

$v6Files = @(
    # New skills
    ".claude/skills/pyplan-audit/SKILL.md",
    ".claude/skills/pyplan-audit/report-template.md",
    ".claude/skills/business-alignment/SKILL.md",
    ".claude/skills/domain-finance/SKILL.md",
    ".claude/skills/domain-supply-chain/SKILL.md",
    ".claude/skills/pyplan/mcp/SKILL.md",
    # New checks
    "checks/audit-evidence.ps1",
    "checks/audit-evidence.sh",
    "checks/mcp-tool-audit.ps1",
    "checks/mcp-tool-audit.sh",
    "checks/missing-result-assign.ps1",
    "checks/missing-result-assign.sh",
    "checks/circular-deps.ps1",
    "checks/circular-deps.sh",
    "checks/spec-gate-policy.ps1",
    "checks/spec-gate-policy.sh",
    "checks/audit-report-integrity.ps1",
    "checks/audit-report-integrity.sh",
    # Audit library
    ".sdad/audit/lib/acquire-evidence.ps1",
    ".sdad/audit/lib/acquire-evidence.sh",
    ".sdad/audit/SCHEMA.md",
    # New eval scenarios
    ".sdad/eval/scenarios/13-claude-md-case/run.ps1",
    ".sdad/eval/scenarios/14-ci-spec-gate-policy/run.ps1",
    ".sdad/eval/scenarios/15-audit-evidence-schema/run.ps1",
    ".sdad/eval/scenarios/16-mcp-tool-audit/run.ps1",
    ".sdad/eval/scenarios/17-missing-result-assign/run.ps1",
    ".sdad/eval/scenarios/18-circular-deps/run.ps1",
    ".sdad/eval/scenarios/19-gate-allow-audit/run.ps1",
    ".sdad/eval/scenarios/20-audit-usability-no-app/run.ps1",
    ".sdad/eval/scenarios/21-audit-report-integrity/run.ps1",
    ".sdad/eval/scenarios/22-severity-determinism/run.ps1"
)

foreach ($dest in $v6Files) {
    $url = "$REPO/$dest"
    $parent = Split-Path $dest -Parent
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        Write-Host "  OK     $dest" -ForegroundColor Green
    } catch {
        Write-Host "  WARN   Could not download $dest" -ForegroundColor Yellow
        Write-Host "         $url" -ForegroundColor Yellow
    }
}

# Also refresh updated existing files (skills revised in v6)
$refreshFiles = @(
    ".claude/agents/HANDOFF_TEMPLATE.md",
    ".claude/agents/code-reviewer.md",
    ".claude/agents/security-auditor.md",
    ".sdad/eval/run-eval.ps1",
    ".sdad/eval/llm-smoke.ps1",
    ".sdad/eval/lib/assert-claude-md.ps1"
)

Write-Host ""
Write-Host "  Refreshing updated v6 files..." -ForegroundColor Yellow
foreach ($dest in $refreshFiles) {
    $url = "$REPO/$dest"
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        Write-Host "  OK     $dest (refreshed)" -ForegroundColor Green
    } catch {
        Write-Host "  WARN   Could not refresh $dest" -ForegroundColor Yellow
    }
}

# ---- STEP 4: Scaffold .sdad/audit/ for existing projects --------------------

Write-Host ""
Write-Host "[ 4/5 ] Scaffolding audit workspace..." -ForegroundColor Yellow

if (-not (Test-Path ".sdad/audit/.gitkeep")) {
    Set-Content -Path ".sdad/audit/.gitkeep" -Value "" -Encoding Ascii
    Write-Host "  OK     .sdad/audit/ ready (evidence goes here per $audit)" -ForegroundColor Green
} else {
    Write-Host "  SKIP   .sdad/audit/ already present" -ForegroundColor Cyan
}

# ---- STEP 5: Update CLAUDE.md version block ---------------------------------

Write-Host ""
Write-Host "[ 5/5 ] Checking CLAUDE.md..." -ForegroundColor Yellow

if (Test-Path "CLAUDE.md") {
    $content = Get-Content "CLAUDE.md" -Raw
    if ($content -match "SDAD v6") {
        Write-Host "  OK     CLAUDE.md already at v6.0" -ForegroundColor Green
    } elseif ($content -match "SDAD v5") {
        Write-Host "  INFO   CLAUDE.md still at v5 -- replace with the v6 CLAUDE.md from the repo." -ForegroundColor Yellow
        Write-Host "         Run: Invoke-WebRequest -Uri `"$REPO/CLAUDE.md`" -OutFile CLAUDE.md -UseBasicParsing" -ForegroundColor Yellow
        Write-Host "         (Only do this if CLAUDE.md is the unmodified SDAD block -- back it up first.)" -ForegroundColor Yellow
    } else {
        Write-Host "  INFO   CLAUDE.md found but no SDAD version marker detected." -ForegroundColor Yellow
    }
} else {
    Write-Host "  WARN   CLAUDE.md not found. Run: Invoke-WebRequest -Uri `"$REPO/CLAUDE.md`" -OutFile CLAUDE.md -UseBasicParsing" -ForegroundColor Yellow
}

# ---- Summary ----------------------------------------------------------------

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  SDAD v6.0 upgrade complete" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "What was added:" -ForegroundColor White
Write-Host "  .claude/skills/pyplan-audit/             5-dimension audit engine" -ForegroundColor White
Write-Host "  .claude/skills/business-alignment/       alignment + domain-agnostic core" -ForegroundColor White
Write-Host "  .claude/skills/domain-finance/           FP&A domain-correctness profile" -ForegroundColor White
Write-Host "  .claude/skills/domain-supply-chain/      supply-chain domain-correctness profile" -ForegroundColor White
Write-Host "  .claude/skills/pyplan/mcp/               @mcp_tool producer + consumer rules" -ForegroundColor White
Write-Host "  checks/audit-evidence + mcp-tool-audit   evidence + MCP ratchets" -ForegroundColor White
Write-Host "  checks/missing-result-assign + circular-deps  node-graph ratchets" -ForegroundColor White
Write-Host "  checks/spec-gate-policy + audit-report-integrity  policy ratchets" -ForegroundColor White
Write-Host "  .sdad/audit/                             evidence + report workspace" -ForegroundColor White
Write-Host "  .sdad/eval/ scenarios 13-22              extended golden dataset (22 total)" -ForegroundColor White
Write-Host ""
Write-Host "Next: run `$eval to verify the full 22-scenario golden dataset." -ForegroundColor Cyan
Write-Host ""

# Self-delete on success (the script removes itself -- common pattern for apply-vX scripts)
$myPath = $MyInvocation.MyCommand.Path
if ($myPath -and (Test-Path $myPath)) {
    Remove-Item $myPath -Force
    Write-Host "  (apply-v6.ps1 removed -- one-shot script)" -ForegroundColor DarkGray
}
