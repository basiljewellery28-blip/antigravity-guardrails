<#
.SYNOPSIS
    API Surface & Schema verification runner for Antigravity.
.DESCRIPTION
    Scans API route definitions and public exports for contract-first adherence,
    explicit parameter types, and structured error responses.
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

Write-Host "🔍 [API Surface] Checking interface contracts and route definitions..." -ForegroundColor Cyan

$routeFiles = Get-ChildItem -Path $ProjectPath -Include @("*.ts", "*.js", "*.py", "*.cs", "*.go") -Recurse -File |
    Where-Object { 
        $_.FullName -notmatch 'node_modules|\.git|obj|bin|dist|vendor|research' -and
        ($_.FullName -match 'routes|controllers|endpoints|api|handlers')
    }

if ($routeFiles.Count -eq 0) {
    Write-Host "ℹ️ No dedicated API/route files detected in current path." -ForegroundColor Yellow
    exit 0
}

Write-Host "📊 Located $($routeFiles.Count) API/route file(s) to verify." -ForegroundColor Cyan
$warnings = 0

foreach ($f in $routeFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName)
    
    # Check 1: Untyped any in route handler
    if ($content -match ':\s*any\b|\bRequest\s*,\s*any\b') {
        Write-Host "  ⚠️ $($f.Name): Found unconstrained 'any' in route signature." -ForegroundColor Yellow
        $warnings++
    }

    # Check 2: Raw string throwing
    if ($content -match 'throw\s+["''][^"'']+["'']') {
        Write-Host "  ⚠️ $($f.Name): Found raw string thrown instead of structured Error object." -ForegroundColor Yellow
        $warnings++
    }
}

if ($warnings -eq 0) {
    Write-Host "✅ [API Surface] All API signatures and route boundaries passed cleanly!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠️ [API Surface] Found $warnings potential interface design warning(s). Review above." -ForegroundColor Yellow
    exit 0
}
