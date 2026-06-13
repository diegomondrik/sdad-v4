# SDAD v5 -- One-shot apply script
# Applies the v5 changes that Cowork mode cannot write into .claude/
# (.claude/ is write-protected in Cowork sessions).
#
# Run ONCE from the repo root:
#   powershell -ExecutionPolicy Bypass -File .\apply-v5.ps1
#
# What it does (idempotent -- safe to re-run):
#   1. Registers PreToolUse spec-gate hook in .claude/settings.json
#      (dispatcher form: sh run-hook.sh pre-tool-use-spec-gate -- cross-platform)
#   2. Installs .claude/hooks/pre-tool-use-spec-gate.ps1 (Windows, tested)
#      and .claude/hooks/pre-tool-use-spec-gate.sh (macOS/Linux, pending mac test)
#   3. Updates session hooks (marker-driven, v5 I2 + I3):
#      session-end .ps1/.sh (L-01 ratchet call), session-start .ps1/.sh
#      (OD-2 $eval reminder + ascii-clean), pre-compact.ps1 (ascii-clean)
#   4. Installs .git/hooks/pre-commit (ratchet hard stop -- .git/hooks is unversioned)
#   5. Removes _staging_v5/ when all steps succeed, then self-deletes
# Note: checks/ itself ships versioned at the repo root -- no staging needed.
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
        # Build the new PreToolUse entry as a hashtable so we can inject it cleanly.
        # Dispatcher form -- run-hook.sh detects the platform and delegates to
        # the .ps1 (Windows) or .sh (macOS/Linux) variant of the gate script.
        $preToolEntry = @{
            matcher = "Write|Edit"
            hooks   = @(
                @{
                    type    = "command"
                    command = 'sh "${CLAUDE_PROJECT_DIR}/.claude/hooks/run-hook.sh" pre-tool-use-spec-gate'
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

# ---- 2: Install pre-tool-use-spec-gate (.ps1 + .sh) -----------------------

$gateScripts = @("pre-tool-use-spec-gate.ps1", "pre-tool-use-spec-gate.sh")

foreach ($script in $gateScripts) {
    $hookSrc = "_staging_v5\hooks\$script"
    $hookDst = ".claude\hooks\$script"

    if (Test-Path $hookDst) {
        Write-Host "  SKIP   $hookDst already exists" -ForegroundColor Cyan
    } elseif (Test-Path $hookSrc) {
        Copy-Item $hookSrc $hookDst
        Write-Host "  OK     $hookDst installed" -ForegroundColor Green
    } else {
        Write-Host "  ERROR  $hookSrc not found (staging missing)" -ForegroundColor Red
        $ok = $false
    }
}

# ---- 3: Update session hooks (marker-driven: skip when marker present) ----

$hookUpdates = @(
    @{ file = "session-end.ps1";   marker = "v5 I2 ratchet wired" },
    @{ file = "session-end.sh";    marker = "v5 I2 ratchet wired" },
    @{ file = "session-start.ps1"; marker = "v5 I3 eval reminder" },
    @{ file = "session-start.sh";  marker = "v5 I3 eval reminder" },
    @{ file = "pre-compact.ps1";   marker = "v5 I3 ascii-clean" }
)
foreach ($u in $hookUpdates) {
    $src = "_staging_v5\hooks\$($u.file)"
    $dst = ".claude\hooks\$($u.file)"

    if (-not (Test-Path $src)) {
        Write-Host "  ERROR  $src not found (staging missing)" -ForegroundColor Red
        $ok = $false
        continue
    }
    $dstCurrent = $false
    if (Test-Path $dst) {
        $existing = Get-Content $dst -Raw -Encoding UTF8
        if ($existing -match [regex]::Escape($u.marker)) { $dstCurrent = $true }
    }
    if ($dstCurrent) {
        Write-Host "  SKIP   $dst already at marker '$($u.marker)'" -ForegroundColor Cyan
    } else {
        Copy-Item $src $dst -Force
        Write-Host "  OK     $dst updated ($($u.marker))" -ForegroundColor Green
    }
}

# ---- 4: Install .git/hooks/pre-commit (ratchet hard stop) -----------------

$pcSrc = "_staging_v5\git-hooks\pre-commit"
$pcDst = ".git\hooks\pre-commit"

if (-not (Test-Path $pcSrc)) {
    Write-Host "  ERROR  $pcSrc not found (staging missing)" -ForegroundColor Red
    $ok = $false
} elseif ((Test-Path $pcDst) -and ((Get-Content $pcDst -Raw -Encoding UTF8) -match 'SDAD v5 -- pre-commit ratchet')) {
    Write-Host "  SKIP   $pcDst already installed" -ForegroundColor Cyan
} else {
    if (Test-Path $pcDst) {
        Copy-Item $pcDst "$pcDst.backup-pre-v5"
        Write-Host "  NOTE   existing pre-commit backed up to pre-commit.backup-pre-v5" -ForegroundColor Yellow
    }
    Copy-Item $pcSrc $pcDst -Force
    Write-Host "  OK     $pcDst installed" -ForegroundColor Green
}

# ---- 5: Cleanup -----------------------------------------------------------

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
