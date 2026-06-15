# SDAD v5 -- PreToolUse spec gate (Windows / PowerShell 5.1)
# Denies Write/Edit on code files when SPEC.md is absent or not approved.
# Registered via run-hook.sh dispatcher: sh run-hook.sh pre-tool-use-spec-gate
# Exit codes: 0 = allow, 2 = deny (stderr message is fed back to the model).
# Fail-open: any internal error allows the action and logs to .sdad/gate.log
# (a broken guard never freezes the developer). Parse-level failures also fail
# open at the harness layer: exit codes other than 0/2 do not block the tool.
# L-01: this file is pure ASCII.

$ErrorActionPreference = "Stop"

try {
    $raw = [Console]::In.ReadToEnd()
    if (-not $raw) { exit 0 }
    $json = $raw | ConvertFrom-Json
    $target = $json.tool_input.file_path
    if (-not $target) { exit 0 }

    $proj = $env:CLAUDE_PROJECT_DIR
    if (-not $proj) { $proj = (Get-Location).Path }
    $proj = ($proj -replace '\\', '/').TrimEnd('/')
    $t = $target -replace '\\', '/'

    # Path relative to the project root, lowercase for comparison
    $rel = $t
    if ($rel.ToLower().StartsWith($proj.ToLower())) {
        $rel = $rel.Substring($proj.Length).TrimStart('/')
    }
    $relLow = $rel.ToLower()
    $name = [System.IO.Path]::GetFileName($relLow)
    $ext  = [System.IO.Path]::GetExtension($relLow)

    # SPEC R1 -- allowlist: methodology state and docs are never blocked
    $allowNames = @('spec.md', 'spec_retroactive.md', 'decisions.md',
                    'lesson_library.md', 'changelog.md', 'readme.md')
    if ($allowNames -contains $name) { exit 0 }
    if ($ext -eq '.md') { exit 0 }
    foreach ($prefix in @('docs/', '.sdad/', '.claude/', 'hub/')) {
        if ($relLow.StartsWith($prefix)) { exit 0 }
    }

    # $docfinal legitimately runs without a Spec (sentinel file)
    if (Test-Path (Join-Path $proj '.sdad/DOCFINAL_ACTIVE')) { exit 0 }

    # SPEC R2 -- code-file denylist; unknown extensions default to allow
    $codeExt = @('.py', '.js', '.ts', '.jsx', '.tsx', '.ps1', '.psm1', '.sh',
                 '.bat', '.cmd', '.sql', '.html', '.css', '.json', '.yaml',
                 '.yml', '.toml', '.ini', '.cs', '.java', '.go', '.rs',
                 '.rb', '.php')
    if ($codeExt -notcontains $ext) { exit 0 }

    # The gate itself
    $specPath = Join-Path $proj 'SPEC.md'
    if (-not (Test-Path $specPath)) {
        [Console]::Error.WriteLine("SDAD gate: no SPEC.md in this project -- code writes are blocked until a Spec is approved. Run `$spec (or `$docfinal for retroactive documentation).")
        exit 2
    }
    $spec = Get-Content $specPath -Raw -Encoding UTF8
    if ($spec -notmatch 'SPEC STATUS: APPROVED') {
        [Console]::Error.WriteLine("SDAD gate: SPEC.md is not approved (missing 'SPEC STATUS: APPROVED' marker). Get developer approval before writing code.")
        exit 2
    }
    exit 0
}
catch {
    # Fail-open path: allow the action, leave a trace
    try {
        $proj2 = $env:CLAUDE_PROJECT_DIR
        if (-not $proj2) { $proj2 = (Get-Location).Path }
        $logDir = Join-Path $proj2 '.sdad'
        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
        $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        Add-Content -Path (Join-Path $logDir 'gate.log') -Encoding UTF8 -Value "$stamp WARN spec-gate failed open: $($_.Exception.Message)"
    } catch { }
    exit 0
}
