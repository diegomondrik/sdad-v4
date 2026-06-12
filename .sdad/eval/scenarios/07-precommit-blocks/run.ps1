# Eval scenario 07 -- pre-commit ratchet blocks a commit staging a dirty .ps1
# in a temp git repo, and allows it once clean. Exit 0 = pass, 1 = fail. ASCII.
$ErrorActionPreference = "Stop"
$repo = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path
$preCommitSrc = Join-Path $repo "_staging_v5\git-hooks\pre-commit"
if (-not (Test-Path $preCommitSrc)) { $preCommitSrc = Join-Path $repo ".git\hooks\pre-commit" }
$checkShSrc = Join-Path $repo "checks\ascii-ps1.sh"

$tmp = Join-Path $env:TEMP "sdad-eval-07-$PID"
New-Item -ItemType Directory -Path (Join-Path $tmp "checks") -Force | Out-Null
try {
    Push-Location $tmp
    git init --quiet 2>$null
    git config user.email "eval@sdad.local" 2>$null
    git config user.name "SDAD Eval" 2>$null
    Copy-Item $checkShSrc (Join-Path $tmp "checks\ascii-ps1.sh")
    Copy-Item $preCommitSrc (Join-Path $tmp ".git\hooks\pre-commit")

    # dirty .ps1 (UTF-8 em dash E2 80 94)
    $bytes = [byte[]](36, 120, 32, 61, 32, 49, 32, 35, 32, 226, 128, 148)
    [System.IO.File]::WriteAllBytes((Join-Path $tmp "script.ps1"), $bytes)

    $ErrorActionPreference = "Continue"   # L-03: native stderr expected on block
    git add script.ps1 2>$null
    git commit -m "dirty" --quiet 2>$null
    $blocked = ($LASTEXITCODE -ne 0)

    Set-Content -Path (Join-Path $tmp "script.ps1") -Value '$x = 1 # clean' -Encoding ASCII
    git add script.ps1 2>$null
    git commit -m "clean" --quiet 2>$null
    $allowed = ($LASTEXITCODE -eq 0)
    $ErrorActionPreference = "Stop"

    if ($blocked -and $allowed) { Write-Host "PASS 07-precommit-blocks"; exit 0 }
    Write-Host "FAIL 07-precommit-blocks (blocked=$blocked expected True; allowed=$allowed expected True)"; exit 1
}
finally {
    Pop-Location
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
