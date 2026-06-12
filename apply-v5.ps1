# SDAD v5 -- One-shot apply script
# Applies the v5 changes that Cowork mode cannot write into .claude/
# (.claude/ is write-protected in Cowork sessions).
#
# Run ONCE from the repo root:
#   powershell -ExecutionPolicy Bypass -File .\apply-v5.ps1
#
# What it does (idempotent -- safe to re-run):
#   1. Registers PreToolUse spec-gate hook in .claude/settings.json
#   2. Installs .claude/hooks/pre-tool-use-spec-gate.ps1
#   3. Creates checks/ directory and installs checks/ascii-ps1.ps1
#   4. Removes _staging_v5/ when all steps succeed
#   5. Self-deletes on success
#
# L-01 rule: this file is pure ASCII -- no em-dashes, accents, arrows, or section symbols.

$ErrorActionPreference = "Stop"
$ok = $true

Write-Host ""
Write-Host "=== SDAD v5 apply ===" -ForegroundColor Cyan

# ---- 1: Register PreToolUse hook in settings.json -------------------------

$settingsPath = ".claude\settings.json"

if (-not (Test-Path $settingsPath)) {
    Write-Host "  ERROR  $settingsPath not found" -ForegroundColor Red
    $ok = $false
} else {
    $settings = Get-Content $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json

    $hookAlreadyRegistered = $false
    if ($settings.hooks.PSObject.Properties.Name -contains "PreToolUse") {
        $hookAlreadyRegistered = $true
    }

    if ($hookAlreadyRegistered) {
        Write-Host "  SKIP   PreToolUse hook already registered in settings.json" -ForegroundColor Cyan
    } else {
        # Build the new PreToolUse entry as a hashtable so we can inject it cleanly
        $preToolEntry = @{
            matcher = "Write|Edit"
            hooks   = @(
                @{
                    type    = "command"
                    command = 'powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PROJECT_DIR}/.claude/hooks/pre-tool-use-spec-gate.ps1"'
                }
            )
        }

        # Add PreToolUse key -- PSCustomObject does not support Add(), so rebuild
        $newHooks = @{}
        foreach ($prop in $settings.hooks.PSObject.Properties) {
            $newHooks[$prop.Name] = $prop.Value
        }
        $newHooks["PreToolUse"] = @($preToolEntry)

        $settings.hooks = [PSCustomObject]$newHooks
        $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
        Write-Host "  OK     PreToolUse spec-gate registered in settings.json" -ForegroundColor Green
    }
}

# ---- 2: Install pre-tool-use-spec-gate.ps1 --------------------------------

$hookSrc = "_staging_v5\hooks\pre-tool-use-spec-gate.ps1"
$hookDst = ".claude\hooks\pre-tool-use-spec-gate.ps1"

if (Test-Path $hookDst) {
    Write-Host "  SKIP   $hookDst already exists" -ForegroundColor Cyan
} elseif (Test-Path $hookSrc) {
    Copy-Item $hookSrc $hookDst
    Write-Host "  OK     $hookDst installed" -ForegroundColor Green
} else {
    Write-Host "  ERROR  $hookSrc not found (staging missing)" -ForegroundColor Red
    $ok = $false
}

# ---- 3: Install checks/ascii-ps1.ps1 (I2 ratchet) ------------------------

$checksSrc = "_staging_v5\checks\ascii-ps1.ps1"
$checksDst = "checks\ascii-ps1.ps1"
$checksDir = "checks"

if (Test-Path $checksDst) {
    Write-Host "  SKIP   $checksDst already exists" -ForegroundColor Cyan
} elseif (Test-Path $checksSrc) {
    if (-not (Test-Path $checksDir)) {
        New-Item -ItemType Directory -Path $checksDir -Force | Out-Null
    }
    Copy-Item $checksSrc $checksDst
    Write-Host "  OK     $checksDst installed" -ForegroundColor Green
} else {
    Write-Host "  ERROR  $checksSrc not found (staging missing)" -ForegroundColor Red
    $ok = $false
}

# ---- 4+5: Cleanup ---------------------------------------------------------

if ($ok) {
    if (Test-Path "_staging_v5") {
        Remove-Item "_staging_v5" -Recurse -Force
        Write-Host "  OK     _staging_v5/ removed" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "=== SDAD v5 applied successfully ===" -ForegroundColor Green
    Write-Host "Suggested commit: git add -A; git commit -m 'v5: apply spec-gate hook + ascii ratchet'" -ForegroundColor Cyan
    Remove-Item $MyInvocation.MyCommand.Path -Force
} else {
    Write-Host ""
    Write-Host "=== Completed with errors -- staging kept. Fix and re-run. ===" -ForegroundColor Yellow
    exit 1
}
