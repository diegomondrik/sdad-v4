# SDAD v4.2 — SessionEnd hook (Windows / PowerShell)
# Purpose: batch auto-commit at session end of ONLY the SDAD doc files.
# Safeguards (all mandatory):
#   - Whitelist: commits ONLY DECISIONS.md and LESSON_LIBRARY.md. Never code, never `git add .`.
#   - Hold sentinel: if .sdad/HOLD_AUTOCOMMIT exists (open P0 / failing increment), do nothing.
#   - No empty commit: commits only if a whitelisted file actually changed.
#   - Standardized commit message.
# Safety: always exits 0.

$ErrorActionPreference = 'SilentlyContinue'
try { $null = [Console]::In.ReadToEnd() } catch {}

$root = $env:CLAUDE_PROJECT_DIR
if (-not $root) { $root = (Get-Location).Path }

# Guard: hold sentinel blocks all autocommit
if (Test-Path (Join-Path $root '.sdad/HOLD_AUTOCOMMIT')) { exit 0 }

Push-Location $root
try {
  $whitelist = @('DECISIONS.md', 'LESSON_LIBRARY.md')
  $changed = @()
  foreach ($f in $whitelist) {
    if (Test-Path $f) {
      $st = @(git status --porcelain -- $f 2>$null)
      if ($st.Count -gt 0) { $changed += $f }
    }
  }
  if ($changed.Count -gt 0) {
    git add -- $changed 2>$null
    git diff --cached --quiet -- $changed 2>$null
    if ($LASTEXITCODE -ne 0) {
      git commit -m "docs: auto-commit SDAD docs at session end" -- $changed 2>$null | Out-Null
    }
  }
} catch {}
finally { Pop-Location }
exit 0
