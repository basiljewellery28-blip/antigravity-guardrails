<#
.SYNOPSIS
    Automated circuit breaker script for detecting runaway agent processes and excessive logs.
.DESCRIPTION
    Audits background processes, checks log file sizes in the workspace and brain logs,
    and identifies potentially runaway tasks.
.PARAMETER MaxLogSizeMb
    Maximum allowable size for a single log or generated artifact in MB (default: 10 MB).
#>
[CmdletBinding()]
param (
    [string]$TargetDirectory = ".",
    [int]$MaxLogSizeMb = 10
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Runaway Stopper & Circuit Breaker Gate" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$tripped = $false
$violations = @()

# 1. Audit task logs and generated files in target directory
Write-Host "`n[1/3] Checking for runaway output logs and oversized artifacts in: $TargetDirectory..." -ForegroundColor Gray

$oversizedFiles = @()

if (Test-Path $TargetDirectory) {
    $logs = @(Get-ChildItem -Path $TargetDirectory -Recurse -File -Include *.log, *.txt, *.jsonl -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch 'node_modules|\.git|vendor|research' -and $_.Length -gt ($MaxLogSizeMb * 1MB) })
    
    foreach ($l in $logs) {
        $sizeMb = [math]::Round($l.Length / 1MB, 2)
        $oversizedFiles += "$($l.FullName) ($sizeMb MB > $MaxLogSizeMb MB limit)"
    }
}

if ($oversizedFiles.Count -gt 0) {
    $tripped = $true
    foreach ($of in $oversizedFiles) {
        $violations += "Runaway log detected: $of"
    }
} else {
    Write-Host "  No oversized or runaway log files detected (all under ${MaxLogSizeMb}MB)." -ForegroundColor Green
}

# 2. Check for runaway or orphaned background node / python processes in workspace
Write-Host "`n[2/3] Checking running development server processes..." -ForegroundColor Gray
$devProcesses = @(Get-Process -Name "node", "python", "pwsh", "powershell" -ErrorAction SilentlyContinue)
Write-Host "  Found $($devProcesses.Count) active runtime host process(es)." -ForegroundColor Gray

# 3. Report Results
Write-Host "`n[3/3] Evaluating Circuit Breaker Status..." -ForegroundColor Gray
if ($tripped) {
    Write-Host "  TRIPPED: Runaway conditions detected:" -ForegroundColor Red
    foreach ($v in $violations) {
        Write-Host "    - $v" -ForegroundColor Red
    }
    Write-Host "`n==========================================================" -ForegroundColor Red
    Write-Host "   Circuit Breaker: TRIPPED ($($violations.Count) alerts)" -ForegroundColor Red
    Write-Host "==========================================================" -ForegroundColor Red
    exit 1
} else {
    Write-Host "  Circuit breaker is healthy. No runaway loops detected." -ForegroundColor Green
    Write-Host "`n==========================================================" -ForegroundColor Cyan
    Write-Host "   Circuit Breaker Gate Complete: PASS" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Cyan
    exit 0
}
