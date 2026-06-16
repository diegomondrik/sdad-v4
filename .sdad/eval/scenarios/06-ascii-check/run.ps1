# Eval scenario 06 -- L-01 ratchet check: dirty .ps1 fails, clean .ps1 passes,
# on BOTH engines (ps1 and sh mirror). Exit 0 = pass, 1 = fail. ASCII (L-01).
$ErrorActionPreference = "Stop"
$repo = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path
$checkPs = Join-Path $repo "checks\ascii-ps1.ps1"
$checkSh = Join-Path $repo "checks\ascii-ps1.sh"

$tmp = Join-Path $env:TEMP "sdad-eval-06-$PID"
New-Item -ItemType Directory -Path $tmp -Force | Out-Null
try {
    # dirty fixture: 'x = 1 <em-dash> comment' with UTF-8 em dash bytes E2 80 94
    $dirty = Join-Path $tmp "dirty.ps1"
    $bytes = [byte[]](36, 120, 32, 61, 32, 49, 32, 35, 32, 226, 128, 148, 32, 99)
    [System.IO.File]::WriteAllBytes($dirty, $bytes)
    $clean = Join-Path $tmp "clean.ps1"
    Set-Content -Path $clean -Value '$x = 1 # plain ascii' -Encoding ASCII

    $fails = 0
    & powershell -NoProfile -ExecutionPolicy Bypass -File $checkPs $dirty | Out-Null
    if ($LASTEXITCODE -ne 1) { Write-Host "  ps1 engine dirty: exit $LASTEXITCODE (expected 1)"; $fails++ }
    & powershell -NoProfile -ExecutionPolicy Bypass -File $checkPs $clean | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Host "  ps1 engine clean: exit $LASTEXITCODE (expected 0)"; $fails++ }

    if (Get-Command sh -ErrorAction SilentlyContinue) {
        $dirtyU = $dirty -replace '\\', '/'
        $cleanU = $clean -replace '\\', '/'
        & sh $checkSh $dirtyU | Out-Null
        if ($LASTEXITCODE -ne 1) { Write-Host "  sh engine dirty: exit $LASTEXITCODE (expected 1)"; $fails++ }
        & sh $checkSh $cleanU | Out-Null
        if ($LASTEXITCODE -ne 0) { Write-Host "  sh engine clean: exit $LASTEXITCODE (expected 0)"; $fails++ }
    } else {
        Write-Host "  NOTE sh not available -- sh engine subcases skipped"
    }

    if ($fails -eq 0) { Write-Host "PASS 06-ascii-check"; exit 0 }
    Write-Host "FAIL 06-ascii-check ($fails subcases)"; exit 1
}
finally {
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
