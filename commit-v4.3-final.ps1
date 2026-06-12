## SDAD v4.3 - commit + push final
## Run from repo root:
##   powershell -ExecutionPolicy Bypass -File .\commit-v4.3-final.ps1
## Pure ASCII (L-01 compliance)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repoRoot

Write-Host ""
Write-Host "=== SDAD v4.3 - Final commit ===" -ForegroundColor Cyan
Write-Host ""

## Show pending changes
Write-Host "Changed files:" -ForegroundColor Yellow
git status --short
Write-Host ""

$commitMsg = @"
feat(v4.3): Pyplan HTML interfaces, markitdown, ccstatusline fixes

Pyplan HTML Interfaces
- CLAUDE.md: HTML interface surface checklist in increment close;
  `$qa Layer 5 HTML checks; Build-via-AI block (HTML = default);
  2 new behavior rules
- Skills patched via apply-v4.3-pyplan-html.ps1 (already applied):
  pyplan/interfaces ss11, qa-platform 7.6, spec-context Q5 + ss5 field,
  mcp step 7
- Docs: DEVELOPER_MANUAL (HTML interfaces subsection),
  ONBOARDING_PYPLAN (surface + checklist + Build-via-AI), README,
  CHANGELOG [4.3]

MarkItDown integration
- CLAUDE.md: DOCUMENT INGESTION rule under `$spec (binary -> Markdown,
  local trusted files only, copies to .sdad/ingest/), behavior rule,
  Complementary Tools entry
- Docs: DEVELOPER_MANUAL, CHANGELOG

ccstatusline fix
- Corrected package name (cc-status-line -> ccstatusline) and usage
  model (one-time TUI setup, not a running monitor) across:
  CLAUDE.md, README, INSTALL_GUIDE, USAGE_AND_SHORTCUTS,
  DEVELOPER_GUIDE, DEVELOPER_MANUAL

ccstatusline: add Thinking Effort widget
- Added Thinking Effort to recommended widget list (supports `$build
  MODEL+effort routing verification) in:
  CLAUDE.md, README, INSTALL_GUIDE, USAGE_AND_SHORTCUTS,
  DEVELOPER_GUIDE, DEVELOPER_MANUAL
"@

Write-Host "Commit message preview:" -ForegroundColor Yellow
Write-Host $commitMsg
Write-Host ""

$confirm = Read-Host "Proceed with git add -A, commit, and push? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Aborted." -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "Running git add -A ..." -ForegroundColor Cyan
git add -A

Write-Host "Running git commit ..." -ForegroundColor Cyan
git commit -m $commitMsg

Write-Host "Running git push ..." -ForegroundColor Cyan
git push

Write-Host ""
Write-Host "Done. SDAD v4.3 pushed." -ForegroundColor Green
Write-Host ""

## Self-delete
Remove-Item -Path $MyInvocation.MyCommand.Path -Force
Write-Host "Script auto-deleted." -ForegroundColor DarkGray
