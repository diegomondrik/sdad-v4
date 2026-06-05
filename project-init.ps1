# SDAD v4.0 — Project Initializer (Windows PowerShell)
# Run from inside the project repo you want to initialize.
#
# Usage (Option A — paste directly, recommended):
#   $init = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/project-init.ps1" -UseBasicParsing).Content
#   Invoke-Expression $init
#
# Usage (Option B — download first):
#   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/project-init.ps1" -OutFile "project-init.ps1"
#   powershell -ExecutionPolicy Bypass -File ".\project-init.ps1"

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  SDAD v4.1 — Project Initializer" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# ── 1. Verify Claude Code is installed ────────────────────────────────────────

Write-Host "Checking Claude Code..." -ForegroundColor Yellow
try {
    $claudeVersion = & claude --version 2>&1
    Write-Host "  Claude Code found: $claudeVersion" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "  Claude Code not found. Running methodology installer first..." -ForegroundColor Yellow
    Write-Host ""
    $install = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/diegomondrik/sdad-v4/main/install.ps1" -UseBasicParsing).Content
    Invoke-Expression $install
}

# ── 2. Verify git repo ────────────────────────────────────────────────────────

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

# ── 3. Collect project info ───────────────────────────────────────────────────

Write-Host ""
Write-Host "Project setup" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────"

# Project name — infer from folder name as default
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

# Client name (optional — used for DECISIONS_[CLIENT].md)
$clientName = Read-Host "Client name (leave blank if internal project)"

# Compliance tier
Write-Host ""
Write-Host "Compliance tier:" -ForegroundColor Cyan
Write-Host "  1  Tier 1 — Standard   (internal tools, POCs, scripts)"
Write-Host "  2  Tier 2 — Business   (SaaS, customer-facing, user data)"
Write-Host "  3  Tier 3 — Enterprise (regulated environments, corporate IT)"
Write-Host ""
$tierInput = Read-Host "Select tier [1]"
switch ($tierInput) {
    "2" { $tier = "Tier 2 — Business" }
    "3" { $tier = "Tier 3 — Enterprise" }
    default { $tier = "Tier 1 — Standard" }
}

$today = Get-Date -Format "yyyy-MM-dd"

# ── 4. Create SPEC.md ─────────────────────────────────────────────────────────

Write-Host ""
Write-Host "Creating project files..." -ForegroundColor Yellow

if (Test-Path "SPEC.md") {
    Write-Host "  SPEC.md already exists — skipping." -ForegroundColor Yellow
} else {
    $specContent = @"
# SPEC.md — $projectName
**Version:** 1.0
**Date:** $today
**Developer:** $devName
**Compliance Tier:** $tier
**Status:** Draft — run `$`spec to fill in requirements

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

## §9 — Security & Compliance ($tier)

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
| SPEC v1.0 | Initial spec | — | $today | project-init |
"@
    Set-Content -Path "SPEC.md" -Value $specContent -Encoding UTF8
    Write-Host "  SPEC.md created." -ForegroundColor Green
}

# ── 5. Create LESSON_LIBRARY.md ───────────────────────────────────────────────

if (Test-Path "LESSON_LIBRARY.md") {
    Write-Host "  LESSON_LIBRARY.md already exists — preserving." -ForegroundColor Yellow
} else {
    $lessonContent = @"
# LESSON_LIBRARY.md — $projectName
# Transferable patterns captured during development.
# Entries are proposed by Claude after $`qa runs and added with your approval.
# Version: 4.1 | Created: $today

---

## How to use

- `$`lesson             — show all entries grouped by category
- `$`lesson [keyword]   — filter by keyword, category, or stack
- `$`lesson [L-XX]      — show full entry
- `$`lesson new         — guided entry creation

---

## Entries

*(No entries yet — they will appear here after your first $`qa run)*
"@
    Set-Content -Path "LESSON_LIBRARY.md" -Value $lessonContent -Encoding UTF8
    Write-Host "  LESSON_LIBRARY.md created." -ForegroundColor Green
}

# ── 6. Create DECISIONS.md ────────────────────────────────────────────────────

if (Test-Path "DECISIONS.md") {
    Write-Host "  DECISIONS.md already exists — preserving." -ForegroundColor Yellow
} else {
    $decisionsContent = @"
# DECISIONS.md — $projectName
# Design decisions log. Written automatically by `$`build after each increment.
# Version: 4.1 | Created: $today

---

| # | Date | Decision | Rationale | Status |
|---|------|----------|-----------|--------|
| D-001 | $today | Project initialized with SDAD v4.1 | $tier | Active |
"@
    Set-Content -Path "DECISIONS.md" -Value $decisionsContent -Encoding UTF8
    Write-Host "  DECISIONS.md created." -ForegroundColor Green
}

# ── 7. Create .sdad/ structure ────────────────────────────────────────────────

if (-not (Test-Path ".sdad")) {
    New-Item -ItemType Directory -Path ".sdad" | Out-Null
    Write-Host "  .sdad/ directory created." -ForegroundColor Green
}

if (-not (Test-Path ".sdad\flows")) {
    New-Item -ItemType Directory -Path ".sdad\flows" | Out-Null
    Write-Host "  .sdad/flows/ directory created." -ForegroundColor Green
}

# project.md — project registry
$clientLine = if ([string]::IsNullOrWhiteSpace($clientName)) { "Internal project" } else { $clientName }

$projectMd = @"
# .sdad/project.md — $projectName
Created: $today
Developer: $devName
Client: $clientLine
Compliance tier: $tier
SDAD version: 4.1

## Session log

| Date | Phase | Summary |
|------|-------|---------|
| $today | Init | Project initialized with project-init |
"@
Set-Content -Path ".sdad\project.md" -Value $projectMd -Encoding UTF8
Write-Host "  .sdad/project.md created." -ForegroundColor Green

# ── 8. Update .gitignore ──────────────────────────────────────────────────────

$gitignorePath = ".gitignore"
$ignoreEntry = ".sdad/agent_output.tmp"

if (Test-Path $gitignorePath) {
    $existing = Get-Content $gitignorePath -Raw
    if ($existing -notmatch [regex]::Escape($ignoreEntry)) {
        Add-Content -Path $gitignorePath -Value "`n# SDAD v4.0`n$ignoreEntry"
        Write-Host "  .gitignore updated." -ForegroundColor Green
    } else {
        Write-Host "  .gitignore already up to date." -ForegroundColor Yellow
    }
} else {
    Set-Content -Path $gitignorePath -Value "# SDAD v4.0`n$ignoreEntry" -Encoding UTF8
    Write-Host "  .gitignore created." -ForegroundColor Green
}

# ── 9. Done ───────────────────────────────────────────────────────────────────

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
Write-Host ""
Write-Host "Next step: open Claude Code and run" -ForegroundColor Cyan
Write-Host "  claude" -ForegroundColor White
Write-Host ""
Write-Host "Then start with:" -ForegroundColor Cyan
Write-Host "  `$spec   — define requirements" -ForegroundColor White
Write-Host "  `$nuevo  — if describing a new project from scratch" -ForegroundColor White
Write-Host ""
