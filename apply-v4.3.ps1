# SDAD v4.3 — One-shot apply script
# Applies the v4.3 changes that Cowork mode could not write into .claude/
# (the .claude/ folder is write-protected in Cowork sessions).
#
# Run ONCE from the repo root:
#   powershell -ExecutionPolicy Bypass -File .\apply-v4.3.ps1
#
# What it does (idempotent — safe to re-run):
#   1. Prepends model/effort frontmatter to the 3 agent files (Via B, roadmap 2.1b)
#   2. Bumps agent Version lines 4.2 -> 4.3
#   3. Installs .claude/skills/security-reviewer/SKILL.md (was referenced but missing)
#   4. Deletes the _staging_v4.3/ folder when everything applied cleanly
#   5. Self-deletes on success

$ErrorActionPreference = "Stop"
$ok = $true

Write-Host ""
Write-Host "=== SDAD v4.3 apply ===" -ForegroundColor Cyan

# ── 1+2: Agent frontmatter ──────────────────────────────────────────────────
$agents = @{
    "code-reviewer"    = @("code-reviewer",    "Isolated architectural and code quality review of a specific module", "opus",   "high")
    "security-auditor" = @("security-auditor", "Isolated security audit of a file, module, or full codebase",         "opus",   "high")
    "test-generator"   = @("test-generator",   "Isolated test suite generation for an existing module",               "sonnet", "medium")
}

foreach ($key in $agents.Keys) {
    $path = ".claude/agents/$key.md"
    if (-not (Test-Path $path)) {
        Write-Host "  ERROR  $path not found" -ForegroundColor Red
        $ok = $false
        continue
    }
    $content = Get-Content $path -Raw -Encoding UTF8
    if ($content.TrimStart().StartsWith("---")) {
        Write-Host "  SKIP   $path already has frontmatter" -ForegroundColor Cyan
    } else {
        $a = $agents[$key]
        $fm = "---`nname: $($a[0])`ndescription: $($a[1])`nmodel: $($a[2])`neffort: $($a[3])`n---`n`n"
        $content = $fm + $content
        $content = $content -replace "# Version: 4\.\d+ \| 2026", "# Version: 4.3 | 2026"
        Set-Content -Path $path -Value $content -Encoding UTF8 -NoNewline
        Write-Host "  OK     $path — frontmatter ($($a[2]) / $($a[3])) + v4.3" -ForegroundColor Green
    }
}

# ── 3: security-reviewer skill ──────────────────────────────────────────────
$srcSkill = "_staging_v4.3/skills/security-reviewer/SKILL.md"
$dstDir   = ".claude/skills/security-reviewer"
$dstSkill = "$dstDir/SKILL.md"

if (Test-Path $dstSkill) {
    Write-Host "  SKIP   $dstSkill already exists" -ForegroundColor Cyan
} elseif (Test-Path $srcSkill) {
    New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    Copy-Item $srcSkill $dstSkill
    Write-Host "  OK     $dstSkill installed" -ForegroundColor Green
} else {
    Write-Host "  ERROR  $srcSkill not found (staging missing)" -ForegroundColor Red
    $ok = $false
}

# ── 4+5: Cleanup ────────────────────────────────────────────────────────────
if ($ok) {
    if (Test-Path "_staging_v4.3") {
        Remove-Item "_staging_v4.3" -Recurse -Force
        Write-Host "  OK     _staging_v4.3/ removed" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "=== v4.3 applied successfully ===" -ForegroundColor Green
    Write-Host "Suggested commit: git add -A; git commit -m 'v4.3: agent model pinning + security-reviewer skill'" -ForegroundColor Cyan
    Remove-Item $MyInvocation.MyCommand.Path -Force
} else {
    Write-Host ""
    Write-Host "=== Completed with errors — staging kept. Fix and re-run. ===" -ForegroundColor Yellow
    exit 1
}
