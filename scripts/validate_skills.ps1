<#
.SYNOPSIS
    Automated validator for Antigravity skill definitions and frontmatter schemas.
.DESCRIPTION
    Scans all SKILL.md files in 'skills' and 'suites' to ensure valid YAML frontmatter,
    non-empty descriptions, valid naming conventions, and presence of necessary docs.
#>
[CmdletBinding()]
param(
    [string]$RootDirectory = "."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Antigravity Skills Schema & Frontmatter Validator" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$searchPaths = @("skills", "suites")
$invalidCount = 0
$validCount = 0

foreach ($sp in $searchPaths) {
    $fullPath = Join-Path $RootDirectory $sp
    if (-not (Test-Path $fullPath)) {
        continue
    }

    $skillFiles = @(Get-ChildItem -Path $fullPath -Filter "SKILL.md" -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch 'node_modules|\.git|vendor|research' })

    foreach ($file in $skillFiles) {
        $content = [System.IO.File]::ReadAllText($file.FullName)
        
        # Check for YAML frontmatter block
        $hasFrontmatter = $content -match '(?s)^---\r?\n.+?\r?\n---'
        $hasName = $content -match '(?m)^name:\s*[a-zA-Z0-9_-]+'
        $hasDescription = $content -match '(?m)^description:\s*.+'

        if ($hasFrontmatter -and $hasName -and $hasDescription) {
            Write-Host "  [VALID]   $($file.Directory.Name)" -ForegroundColor Green
            $validCount++
        } else {
            Write-Host "  [INVALID] $($file.FullName) (Missing or malformed frontmatter/name/description)" -ForegroundColor Red
            $invalidCount++
        }
    }
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
if ($invalidCount -gt 0) {
    Write-Host "   Validation FAILED: $invalidCount invalid skill(s), $validCount valid" -ForegroundColor Red
    Write-Host "==========================================================" -ForegroundColor Red
    exit 1
} else {
    Write-Host "   Validation PASSED: All $validCount skill(s) conform to schema" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Cyan
    exit 0
}
