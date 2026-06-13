# SDAD $eval -- LLM replay smoke (v5 I3, SPEC F3.2, resolves OD-1).
# Release gate ONLY (run via run-eval.ps1 -Release before tagging) -- never a
# daily gate: LLM output is non-deterministic, so matching is deliberately lax.
# Each scenario copies the methodology CLAUDE.md into a temp fixture, runs
# `claude --print "<prompt>"` there, and requires every regex to match
# (case-insensitive). Exit 0 = all scenarios pass. Pure ASCII (L-01).
$ErrorActionPreference = "Stop"
$repo = (Resolve-Path "$PSScriptRoot\..\..").Path
$timeoutSec = 300   # per call; generous -- a hung CLI must not hang the gate

# OD-1 resolution: wording + regex set, one row per smoke scenario.
$scenarios = @(
    @{ name = "spec-language";  prompt = '$spec'
       # Fixture has no PROJECT_LANGUAGE -> the FIRST question must be the language one.
       patterns = @('(language|idioma)', '(English|Spanish|ingl|espa)') }
    @{ name = "build-gate";     prompt = '$build'
       # Fixture has no SPEC.md -> must redirect to $spec / $docfinal, never code.
       patterns = @('\$spec', '\$docfinal') }
    @{ name = "sdad-surface";   prompt = '$sdad'
       # Overview must surface the phase/command spine.
       patterns = @('spec', 'build', 'qa') }
)

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "FAIL llm-smoke: claude CLI not found -- release gate cannot run"
    exit 1
}

$failed = 0
foreach ($s in $scenarios) {
    $tmp = Join-Path $env:TEMP ("sdad-llm-" + $s.name + "-$PID")
    New-Item -ItemType Directory -Path $tmp -Force | Out-Null
    $outFile = Join-Path $tmp "out.txt"
    $errFile = Join-Path $tmp "err.txt"
    try {
        Copy-Item (Join-Path $repo "CLAUDE.md") (Join-Path $tmp "CLAUDE.md")

        $p = Start-Process -FilePath "claude" -ArgumentList @("--print", $s.prompt) `
            -WorkingDirectory $tmp -NoNewWindow -PassThru `
            -RedirectStandardOutput $outFile -RedirectStandardError $errFile
        if (-not $p.WaitForExit($timeoutSec * 1000)) {
            try { $p.Kill() } catch {}
            Write-Host "FAIL llm:$($s.name) (timeout after $timeoutSec s)"
            $failed++
            continue
        }

        $reply = ""
        if (Test-Path $outFile) { $reply = Get-Content $outFile -Raw -Encoding UTF8 }
        $missing = @()
        foreach ($rx in $s.patterns) {
            if ($reply -notmatch "(?i)$rx") { $missing += $rx }
        }
        if ($missing.Count -eq 0) {
            Write-Host "PASS llm:$($s.name)"
        } else {
            Write-Host "FAIL llm:$($s.name) (no match: $($missing -join ', '))"
            $failed++
        }
    }
    finally {
        Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if ($failed -eq 0) { Write-Host "=== llm smoke: all pass ==="; exit 0 }
Write-Host "=== llm smoke: $failed failed ==="
exit 1
