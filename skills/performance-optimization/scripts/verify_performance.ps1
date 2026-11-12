<#
.SYNOPSIS
    Automated performance budget and anti-pattern verification script.
.DESCRIPTION
    Scans project assets for bundle size limits and scans source files for known
    performance bottlenecks (e.g. sync I/O in hot loops, unbuffered streams).
.PARAMETER MaxAssetSizeKb
    Maximum allowed asset file size in KB (default: 512 KB).
#>
[CmdletBinding()]
param (
    [int]$MaxAssetSizeKb = 512
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Performance Optimization & Budget Gate" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$violations = @()

# 1. Check asset and bundle sizes in build directories if present
Write-Host "`n[1/3] Inspecting compiled bundle and asset budgets..." -ForegroundColor Gray
$buildDirs = @("dist", "build", "out", "public/build", "target")
$checkedAssets = 0
# Whole-segment match on the path below the project root: bare 'bin'/'obj'/'research' substrings
# also matched e.g. "cabinet-api", excluding every file and passing vacuously.
$root = (Get-Location).Path
$excludeRe = '[\\/](node_modules|\.git|obj|bin|dist|vendor|research)[\\/]'

foreach ($dir in $buildDirs) {
    if (Test-Path $dir) {
        $assets = @(Get-ChildItem -Path $dir -Recurse -File -Include *.js, *.css, *.wasm -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName.Substring($root.Length) -notmatch '[\\/](node_modules|\.git|vendor)[\\/]' })
        
        foreach ($asset in $assets) {
            $checkedAssets++
            $sizeKb = [math]::Round($asset.Length / 1KB, 2)
            if ($sizeKb -gt $MaxAssetSizeKb) {
                $violations += "Asset budget exceeded: $($asset.FullName) ($sizeKb KB > $MaxAssetSizeKb KB limit)"
            }
        }
    }
}

if ($checkedAssets -gt 0) {
    Write-Host "  Checked $checkedAssets compiled asset(s)." -ForegroundColor Green
} else {
    Write-Host "  No compiled build directories found (dist/build/out). Skipping static asset size check." -ForegroundColor Yellow
}

# 2. Scan source code for synchronous I/O and performance anti-patterns
Write-Host "`n[2/3] Scanning source code for synchronous hot-loop anti-patterns..." -ForegroundColor Gray

$antiPatterns = @(
    @{ Name = "Sync I/O in Loop"; Pattern = 'for\s*\(.*\)\s*\{[^}]*fs\.read(?:File)?Sync' },
    @{ Name = "N+1 Query in Loop"; Pattern = 'for\s*\(.*\)\s*\{[^}]*(?:SELECT\s+\*|\.findById|\.findOne)' },
    @{ Name = "Regex Recompilation in Loop"; Pattern = 'for\s*\(.*\)\s*\{[^}]*new\s+RegExp\(' }
)

$sourceFiles = @(Get-ChildItem -Path . -Recurse -File -Include *.ts, *.js, *.py, *.go, *.rs, *.cs -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName.Substring($root.Length) -notmatch $excludeRe })

$flaggedFiles = 0
foreach ($file in $sourceFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    foreach ($ap in $antiPatterns) {
        if ($content -match $ap.Pattern) {
            $violations += "Performance Anti-Pattern ($($ap.Name)) detected in: $($file.FullName)"
            $flaggedFiles++
        }
    }
}
Write-Host "  Scanned $($sourceFiles.Count) source file(s). Found $flaggedFiles anti-pattern flag(s)." -ForegroundColor Gray

# 3. Report Results
Write-Host "`n[3/3] Evaluating Performance Gate Status..." -ForegroundColor Gray
if ($violations.Count -gt 0) {
    Write-Host "  FAILED: Performance violations detected:" -ForegroundColor Red
    foreach ($v in $violations) {
        Write-Host "    - $v" -ForegroundColor Red
    }
    Write-Host "`n==========================================================" -ForegroundColor Red
    Write-Host "   Performance Verification: FAILED ($($violations.Count) violations)" -ForegroundColor Red
    Write-Host "==========================================================" -ForegroundColor Red
    exit 1
} else {
    Write-Host "  All performance checks passed cleanly." -ForegroundColor Green
    Write-Host "`n==========================================================" -ForegroundColor Cyan
    Write-Host "   Performance Verification Gate: PASS" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Cyan
    exit 0
}
