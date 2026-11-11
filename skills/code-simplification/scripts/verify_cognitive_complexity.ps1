<#
.SYNOPSIS
    Cognitive complexity and indentation checker for Code Simplification.
.DESCRIPTION
    Scans project source files for excessive nesting depth and unflattened logic.
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = ".",
    [int]$MaxIndentationSpaces = 16
)

$ErrorActionPreference = "Stop"

Write-Host "🔍 [Code Simplifier] Scanning for deep nesting and excessive complexity..." -ForegroundColor Cyan

$sourceExtensions = @("*.ts", "*.tsx", "*.js", "*.jsx", "*.py", "*.cs", "*.java", "*.go", "*.rs")
$files = Get-ChildItem -Path $ProjectPath -Include $sourceExtensions -Recurse -File |
    Where-Object { $_.FullName -notmatch 'node_modules|\.git|obj|bin|dist|vendor|research' }

$flagged = 0

foreach ($file in $files) {
    $lines = [System.IO.File]::ReadAllLines($file.FullName)
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]
        
        # Check indentation depth (4 levels = 16 spaces or 4 tabs)
        if ($line.Trim().Length -gt 0) {
            $leadingSpaces = $line.Length - $line.TrimStart().Length
            if ($leadingSpaces -gt $MaxIndentationSpaces) {
                Write-Host "  ⚠️ $($file.Name):$($i + 1) -> Deep nesting detected ($leadingSpaces spaces). Consider early returns." -ForegroundColor Yellow
                $flagged++
                break # Flag once per file to avoid output spam
            }
        }
    }
}

if ($flagged -eq 0) {
    Write-Host "✅ [Code Simplifier] All files maintain clean, shallow nesting depth!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "💡 Found $flagged file(s) with deep nesting. Consider refactoring with guard clauses." -ForegroundColor Yellow
    exit 0
}
