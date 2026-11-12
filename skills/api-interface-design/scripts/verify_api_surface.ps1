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

$root = (Resolve-Path $ProjectPath).Path

# Judge the path below the scan root, by whole segments / dotted name parts: a parent folder such as
# "my-api" must not make every file a route file, nor "cabinet" hide them all.
$routeFiles = @(Get-ChildItem -Path $root -Include @("*.ts", "*.js", "*.py", "*.cs", "*.go") -Recurse -File |
    Where-Object {
        $rel = $_.FullName.Substring($root.Length)
        $rel -notmatch '(^|[\\/])(node_modules|\.git|obj|bin|dist|vendor|research)[\\/]' -and
        ($rel -match '(^|[\\/._-])(routes?|controllers?|endpoints?|api|handlers?)([\\/._-]|$)')
    })

if ($routeFiles.Count -eq 0) {
    # Nothing found means nothing was verified; usually -ProjectPath points at the wrong folder.
    Write-Host "❌ No API/route files detected under $root; API surface NOT verified. Pass -ProjectPath pointing at your API code." -ForegroundColor Red
    exit 1
}

Write-Host "📊 Located $($routeFiles.Count) API/route file(s) to verify." -ForegroundColor Cyan
$warnings = 0

foreach ($f in $routeFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName)
    
    # Check 1: Untyped any in route handler
    if ($content -match ':\s*any\s*[,)=;>\]]|\bRequest\s*,\s*any\b') {
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
    Write-Host "❌ [API Surface] Found $warnings interface design violation(s). Fix them above and re-run." -ForegroundColor Red
    exit 1
}

