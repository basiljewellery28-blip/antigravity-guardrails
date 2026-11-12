<#
.SYNOPSIS
    Automated codebase slop and redundant boilerplate verification gate.
.DESCRIPTION
    Scans source files across TypeScript, JavaScript, Python, Go, Rust, and C#
    for empty catch blocks, placeholder comments (TODO/FIXME), and empty function stubs.
#>
[CmdletBinding()]
param (
    [string]$TargetDirectory = "."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Codebase Deslop & Anti-Boilerplate Gate" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$violations = @()

if (-not (Test-Path -LiteralPath $TargetDirectory -PathType Container)) {
    Write-Host "  FAILED: Target directory not found: $TargetDirectory" -ForegroundColor Red
    exit 1
}
$root = (Resolve-Path -LiteralPath $TargetDirectory).Path

# 1. Scan source files for AI slop anti-patterns
Write-Host "`n[1/2] Scanning source files for slop patterns and stubs..." -ForegroundColor Gray

# Exclusions match whole path segments below the scan root so a parent folder name cannot hide every file.
$sourceFiles = @(Get-ChildItem -LiteralPath $root -Recurse -File -Include *.ts, *.tsx, *.js, *.jsx, *.py, *.go, *.rs, *.cs -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName.Substring($root.Length) -notmatch '(^|[\\/])(node_modules|\.git|obj|bin|dist|vendor|research)[\\/]' })

$slopChecks = @(
    @{ Name = "Empty Exception Catch"; Pattern = 'catch\s*(?:\([^)]*\))?\s*\{\s*(?:/\*(?:(?!\*/)[\s\S])*\*/|//[^\r\n]*)?\s*\}|\.catch\(\s*(?:\(\s*\w*\s*\)|\w+)\s*=>\s*\{\s*\}\s*\)' },
    @{ Name = "Empty Except Block (Python)"; Pattern = 'except(?:\s+[^:\r\n]+)?:\s*pass\b' },
    @{ Name = "Unimplemented Stub (TODO/FIXME)"; Pattern = '\b(?:TODO|FIXME|XXX)\b\s*:' },
    @{ Name = "Placeholder Logic Stub"; Pattern = '(?i)/\*\s*(?:implement|logic)\s+here\s*\*/' }
)

$flaggedCount = 0
foreach ($file in $sourceFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    foreach ($chk in $slopChecks) {
        # Case-sensitive: "todo: Todo[]" is a field name, not a stub marker.
        if ($content -cmatch $chk.Pattern) {
            $violations += "Slop Detected ($($chk.Name)) in: $($file.FullName)"
            $flaggedCount++
        }
    }
}

Write-Host "  Scanned $($sourceFiles.Count) source file(s). Found $flaggedCount violation(s)." -ForegroundColor Gray

# 2. Evaluate Results
Write-Host "`n[2/2] Evaluating Codebase Slop Gate Status..." -ForegroundColor Gray
if ($violations.Count -gt 0) {
    Write-Host "  FAILED: Codebase slop violations detected:" -ForegroundColor Red
    foreach ($v in $violations) {
        Write-Host "    - $v" -ForegroundColor Red
    }
    Write-Host "`n==========================================================" -ForegroundColor Red
    Write-Host "   Deslop Verification: FAILED ($($violations.Count) violations)" -ForegroundColor Red
    Write-Host "==========================================================" -ForegroundColor Red
    exit 1
} else {
    Write-Host "  Codebase is clean. Zero empty catches, stubs, or slop detected." -ForegroundColor Green
    Write-Host "`n==========================================================" -ForegroundColor Cyan
    Write-Host "   Deslop Verification Gate Complete: PASS" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Cyan
    exit 0
}

