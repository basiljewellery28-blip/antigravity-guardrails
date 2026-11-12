<#
.SYNOPSIS
    Automated reproduction and flakiness tester for Bug Hunter.
.DESCRIPTION
    Executes a test or reproduction command N times, tracking pass/fail rates,
    execution duration, and output traces for intermittent bugs.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Command,

    [ValidateRange(1, [int]::MaxValue)]
    [int]$Iterations = 20,

    [switch]$StopOnFirstFailure
)

$ErrorActionPreference = "Continue"

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " 🎯 [Bug Hunter] Running Repro Loop ($Iterations iterations)" -ForegroundColor Cyan
Write-Host " Command: $Command" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan

$passes = 0
$failures = 0
$executed = 0
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

for ($i = 1; $i -le $Iterations; $i++) {
    $iterStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    # $Command is a free-form shell string by design. Clear $LASTEXITCODE so a stale value from a
    # previous run is never mistaken for this run's result; fall back to $? only if no native process ran.
    $global:LASTEXITCODE = $null
    $output = Invoke-Expression $Command 2>&1
    $ok = $?
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) { $exitCode = if ($ok) { 0 } else { 1 } }
    $iterStopwatch.Stop()
    $executed++

    $durationMs = [math]::Round($iterStopwatch.Elapsed.TotalMilliseconds)

    if ($exitCode -eq 0) {
        $passes++
        Write-Host "  Run #${i}: " -NoNewline
        Write-Host "PASS " -ForegroundColor Green -NoNewline
        Write-Host "(${durationMs}ms)" -ForegroundColor DarkGray
    } else {
        $failures++
        Write-Host "  Run #${i}: " -NoNewline
        Write-Host "FAIL " -ForegroundColor Red -NoNewline
        Write-Host "(Exit: $exitCode, ${durationMs}ms)" -ForegroundColor DarkGray
        $output | ForEach-Object { "$_" } | Select-Object -Last 20 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }

        if ($StopOnFirstFailure) {
            Write-Host "🛑 Stopped on first failure as requested." -ForegroundColor Yellow
            break
        }
    }
}

$stopwatch.Stop()
$totalSeconds = [math]::Round($stopwatch.Elapsed.TotalSeconds, 2)

Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor Cyan
Write-Host "📊 Results Summary:" -ForegroundColor Cyan
Write-Host "   Total Executions: $executed of $Iterations"
Write-Host "   Passes:   $passes" -ForegroundColor Green
Write-Host "   Failures: $failures" -ForegroundColor Red
if ($executed -gt 0) {
    $failRate = [math]::Round(($failures / $executed) * 100, 1)
    Write-Host "   Failure Rate: $failRate%" -ForegroundColor Yellow
}
Write-Host "   Total Time: ${totalSeconds}s"
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan

if ($failures -gt 0) {
    exit 1
} else {
    exit 0
}

