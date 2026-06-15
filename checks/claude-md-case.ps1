# SDAD v5 -- L-04 ratchet check: the methodology file is CLAUDE.md (all caps).
# Flags the wrong-case form in code/config, where it is a real path or URL and
# breaks on case-sensitive surfaces (GitHub raw, git ls-tree, Linux FS).
# Mirror: checks/claude-md-case.sh -- keep the two in sync.
# Usage:
#   powershell -File checks/claude-md-case.ps1                 -> scan tracked code/config
#   powershell -File checks/claude-md-case.ps1 f1.ps1 f2.ps1   -> scan specific files
# Scans only executable/config files (.ps1 .sh .psm1 .json .bat .cmd .yml .yaml);
# prose (.md, .html) legitimately names the bug, so it is not scanned.
# The needle is built by concatenation so this script never contains it contiguous.
# Exit 0 = clean, 1 = violation or check error (fails CLOSED, like ascii-ps1).
param([string[]]$Files)
$ErrorActionPreference = "Stop"
try {
    $pre = "Claude"
    $needle = "$pre.md"      # the wrong-case form; CLAUDE.md (all caps) is correct
    if (-not $Files -or $Files.Count -eq 0) {
        $globs = @('*.ps1','*.psm1','*.sh','*.json','*.bat','*.cmd','*.yml','*.yaml')
        $Files = @(git ls-files -- $globs 2>$null)
    }
    $bad = 0
    foreach ($f in $Files) {
        if (-not (Test-Path $f)) { continue }
        $hits = Select-String -Path $f -SimpleMatch -CaseSensitive -Pattern $needle -ErrorAction SilentlyContinue
        foreach ($h in $hits) {
            Write-Host "CASE VIOLATION: $f line $($h.LineNumber) -- use CLAUDE.md (all caps)"
            $bad++
        }
    }
    if ($bad -gt 0) {
        Write-Host "claude-md-case: $bad reference(s) use the wrong case (L-04)"
        exit 1
    }
    exit 0
}
catch {
    Write-Host "claude-md-case: check error: $($_.Exception.Message)"
    exit 1
}
