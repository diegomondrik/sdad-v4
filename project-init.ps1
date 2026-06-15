# SDAD v5.0 -- Project Initializer (Windows PowerShell)
# Run from inside the project repo you want to initialize.
#
# L-01 rule: this file is pure ASCII. The section sign used in the generated
# SPEC template is emitted via [char]0x00A7 so this source stays ASCII-clean
# while the produced SPEC.md keeps SDAD's section notation.
#
# Usage (Option A -- paste directly, recommended):
#   $init = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/project-init.ps1" -UseBasicParsing).Content
#   Invoke-Expression $init
#
# Usage (Option B -- download first):
#   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/project-init.ps1" -OutFile "project-init.ps1"
#   powershell -ExecutionPolicy Bypass -File ".\project-init.ps1"

$ErrorActionPreference = "Stop"
$REPO = "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main"

# Section sign, kept out of the source bytes (L-01). Used only in generated docs.
$S = [char]0x00A7

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  SDAD v5.0 -- Project Initializer" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# ---- 1. Verify Claude Code is installed -----------------------------------

Write-Host "Checking Claude Code..." -ForegroundColor Yellow
try {
    $claudeVersion = & claude --version 2>&1
    Write-Host "  Claude Code found: $claudeVersion" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "  Claude Code not found. Running methodology installer first..." -ForegroundColor Yellow
    Write-Host ""
    $install = (Invoke-WebRequest -Uri "$REPO/install.ps1" -UseBasicParsing).Content
    Invoke-Expression $install
}

# ---- 2. Verify git repo ---------------------------------------------------

Write-Host "Checking git repository..." -ForegroundColor Yellow
try {
    $gitStatus = & git status 2>&1
    if ($LASTEXITCODE -ne 0) { throw "not a git repo" }
    Write-Host "  Git repository detected." -ForegroundColor Green
} catch {
    Write-Host "  No git repository found. Initializing..." -ForegroundColor Yellow
    & git init
    Write-Host "  Git initialized." -ForegroundColor Green
}

# ---- 3. Collect project info ----------------------------------------------

Write-Host ""
Write-Host "Project setup" -ForegroundColor Cyan
Write-Host "-------------------------------------"

# Project name -- infer from folder name as default
$folderName = (Get-Item -Path ".").Name
$projectNameInput = Read-Host "Project name [$folderName]"
if ([string]::IsNullOrWhiteSpace($projectNameInput)) {
    $projectName = $folderName
} else {
    $projectName = $projectNameInput
}

# Developer name
$devName = Read-Host "Your name"
if ([string]::IsNullOrWhiteSpace($devName)) {
    $devName = "Developer"
}

# Client name (optional)
$clientName = Read-Host "Client name (leave blank if internal project)"

# Compliance tier
Write-Host ""
Write-Host "Compliance tier:" -ForegroundColor Cyan
Write-Host "  1  Tier 1 - Standard   (internal tools, POCs, scripts)"
Write-Host "  2  Tier 2 - Business   (SaaS, customer-facing, user data)"
Write-Host "  3  Tier 3 - Enterprise (regulated environments, corporate IT)"
Write-Host ""
$tierInput = Read-Host "Select tier [1]"
switch ($tierInput) {
    "2" { $tier = "Tier 2 - Business" }
    "3" { $tier = "Tier 3 - Enterprise" }
    default { $tier = "Tier 1 - Standard" }
}

$today = Get-Date -Format "yyyy-MM-dd"

# ---- 4. Create SPEC.md ----------------------------------------------------

Write-Host ""
Write-Host "Creating project files..." -ForegroundColor Yellow

if (Test-Path "SPEC.md") {
    Write-Host "  SPEC.md already exists -- skipping." -ForegroundColor Yellow
} else {
    $specContent = @"
# SPEC.md -- $projectName
**Version:** 1.0
**Date:** $today
**Developer:** $devName
**Compliance Tier:** $tier
**Status:** Draft -- run ``$``spec to fill in requirements

---

## ${S}1 - Vision & Objective

**Problem:**
[Describe the problem this project solves]

**Solution:**
[Describe the proposed solution]

**Success criteria:**
- [Criterion 1]
- [Criterion 2]

---

## ${S}2 - Users & Roles

| Role | Description | Access |
|------|-------------|--------|
| [Role 1] | [Description] | [Permissions] |

---

## ${S}3 - Functional Flows

### Flow 1 - [Name]
[Step-by-step flow description]

---

## ${S}4 - Data Model

[Entities, data structures, key files]

---

## ${S}5 - Technical Architecture

**Stack:**
- [Language / Framework]
- [Key dependencies]

**Components:**
| Component | Role |
|-----------|------|
| [name] | [description] |

---

## ${S}6 - Business Rules

1. [Business rule 1]
2. [Business rule 2]

---

## ${S}7 - Integrations & APIs

| Integration | Endpoint | Usage |
|-------------|----------|-------|
| [name] | [endpoint] | [usage] |

---

## ${S}8 - Testing Strategy

| Test | Type | Trigger |
|------|------|---------|
| [description] | [unit/integration/E2E/manual] | [trigger] |

---

## ${S}9 - Security & Compliance ($tier)

**Assets to protect:**
- [asset 1]

**Controls:**
- [control 1]

---

## ${S}10 - Definition of Done

An increment is complete when:
- [ ] All acceptance criteria from SPEC.md met
- [ ] Tests pass without errors
- [ ] No regressions introduced
- [ ] README or RUNBOOK updated if behavior changed
- [ ] SPEC.md ${S}13 AI Authorship Log entry delivered

---

## ${S}11 - Out of Scope

- [Out of scope item 1]

---

## ${S}12 - Open Decisions

| # | Decision | Status |
|---|----------|--------|
| OD-01 | [description] | Open |

---

## ${S}13 - AI Authorship Log

| Increment | Feature | Model | Effort | Files | Tests | QA findings | Date |
|-----------|---------|-------|--------|-------|-------|-------------|------|
| SPEC v1.0 | Initial spec | n/a | n/a | n/a | n/a | n/a | $today |
"@
    Set-Content -Path "SPEC.md" -Value $specContent -Encoding UTF8
    Write-Host "  SPEC.md created." -ForegroundColor Green
}

# ---- 5. Create LESSON_LIBRARY.md ------------------------------------------

if (Test-Path "LESSON_LIBRARY.md") {
    Write-Host "  LESSON_LIBRARY.md already exists -- preserving." -ForegroundColor Yellow
} else {
    $lessonContent = @"
# LESSON_LIBRARY.md -- $projectName
# Transferable patterns captured during development.
# Entries are proposed by Claude after ``$``qa runs and added with your approval.
# Version: 5.0 | Created: $today

---

## How to use

- ``$``lesson             -- show all entries grouped by category
- ``$``lesson [keyword]   -- filter by keyword, category, or stack
- ``$``lesson [L-XX]      -- show full entry
- ``$``lesson new         -- guided entry creation

---

## Entries

*(No entries yet -- they will appear here after your first ``$``qa run)*
"@
    Set-Content -Path "LESSON_LIBRARY.md" -Value $lessonContent -Encoding UTF8
    Write-Host "  LESSON_LIBRARY.md created." -ForegroundColor Green
}

# ---- 6. Create DECISIONS.md -----------------------------------------------

if (Test-Path "DECISIONS.md") {
    Write-Host "  DECISIONS.md already exists -- preserving." -ForegroundColor Yellow
} else {
    $decisionsContent = @"
# DECISIONS.md -- $projectName
# Design decisions log. Written automatically by ``$``build after each increment.
# Version: 5.0 | Created: $today

---

| # | Date | Decision | Rationale | Status |
|---|------|----------|-----------|--------|
| D-001 | $today | Project initialized with SDAD v5.0 | $tier | Active |
"@
    Set-Content -Path "DECISIONS.md" -Value $decisionsContent -Encoding UTF8
    Write-Host "  DECISIONS.md created." -ForegroundColor Green
}

# ---- 7. Create .sdad/ structure -------------------------------------------

foreach ($d in @(".sdad", ".sdad\flows")) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Path $d | Out-Null
        Write-Host "  $d/ directory created." -ForegroundColor Green
    }
}

# project.md -- project registry
$clientLine = if ([string]::IsNullOrWhiteSpace($clientName)) { "Internal project" } else { $clientName }

$projectMd = @"
# .sdad/project.md -- $projectName
Created: $today
Developer: $devName
Client: $clientLine
Compliance tier: $tier
SDAD version: 5.0

## Session log

| Date | Phase | Summary |
|------|-------|---------|
| $today | Init | Project initialized with project-init |
"@
Set-Content -Path ".sdad\project.md" -Value $projectMd -Encoding UTF8
Write-Host "  .sdad/project.md created." -ForegroundColor Green

# ---- 8. Seed the v5 harness layer (ratchet + eval + agent wrapper) --------
# Download-if-missing so a repo already carrying the methodology install is not
# re-fetched. Parent directories are created on demand.

Write-Host ""
Write-Host "Seeding the v5 harness layer..." -ForegroundColor Yellow

$harnessSeed = @(
    "checks/ascii-ps1.ps1",
    "checks/ascii-ps1.sh",
    ".sdad/lib/agent-run.ps1",
    ".sdad/lib/agent-run.sh",
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

$seeded = 0
foreach ($dest in $harnessSeed) {
    if (Test-Path $dest) { continue }
    $parent = Split-Path $dest -Parent
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    try {
        Invoke-WebRequest -Uri "$REPO/$dest" -OutFile $dest -UseBasicParsing
        $seeded++
    } catch {
        Write-Host "  WARNING  Could not fetch $dest (run install.ps1 to complete the harness)." -ForegroundColor Yellow
    }
}
if ($seeded -gt 0) {
    Write-Host "  OK     harness seed: $seeded file(s) fetched (checks/, .sdad/eval, .sdad/lib)." -ForegroundColor Green
} else {
    Write-Host "  SKIP   harness layer already present." -ForegroundColor Cyan
}

# ---- 9. Update .gitignore -------------------------------------------------

$gitignorePath = ".gitignore"
$ignoreEntries = @(".sdad/agent_output.tmp", ".sdad/gate.log")

if (Test-Path $gitignorePath) {
    $existing = Get-Content $gitignorePath -Raw
    if ($existing -notmatch [regex]::Escape($ignoreEntries[0])) {
        Add-Content -Path $gitignorePath -Value ("`n# SDAD v5.0`n" + ($ignoreEntries -join "`n"))
        Write-Host "  .gitignore updated." -ForegroundColor Green
    } else {
        Write-Host "  .gitignore already up to date." -ForegroundColor Yellow
    }
} else {
    Set-Content -Path $gitignorePath -Value ("# SDAD v5.0`n" + ($ignoreEntries -join "`n")) -Encoding UTF8
    Write-Host "  .gitignore created." -ForegroundColor Green
}

# ---- 10. Done -------------------------------------------------------------

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "  Project initialized successfully" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Project:   $projectName" -ForegroundColor White
Write-Host "  Developer: $devName" -ForegroundColor White
if (-not [string]::IsNullOrWhiteSpace($clientName)) {
    Write-Host "  Client:    $clientName" -ForegroundColor White
}
Write-Host "  Tier:      $tier" -ForegroundColor White
Write-Host ""
Write-Host "Files created:"
Write-Host "  SPEC.md"
Write-Host "  LESSON_LIBRARY.md"
Write-Host "  DECISIONS.md"
Write-Host "  .sdad/project.md"
Write-Host "  .sdad/flows/"
Write-Host "  checks/ + .sdad/eval/ + .sdad/lib/   (v5 harness seed)"
Write-Host ""
Write-Host "Next step: open Claude Code and run" -ForegroundColor Cyan
Write-Host "  claude" -ForegroundColor White
Write-Host ""
Write-Host "Then start with:" -ForegroundColor Cyan
Write-Host "  `$spec   -- define requirements" -ForegroundColor White
Write-Host ""
