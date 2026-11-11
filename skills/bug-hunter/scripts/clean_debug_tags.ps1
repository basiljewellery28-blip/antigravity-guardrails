<#
.SYNOPSIS
    Automated debug tag cleaner for Bug Hunter.
.DESCRIPTION
    Scans project source files for temporary [DEBUG-xxxx] tags and removes them
    to prevent instrumentation pollution in production code.
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = ".",
    [switch]$Remove
)

$ErrorActionPreference = "Stop"

$sourceExtensions = @("*.ts", "*.tsx", "*.js", "*.jsx", "*.py", "*.cs", "*.java", "*.go", "*.rs")
$filesWithTags = @()

Write-Host "🔍 [Bug Hunter] Scanning for temporary debug tags ([DEBUG-*])..." -ForegroundColor Cyan

$files = Get-ChildItem -Path $ProjectPath -Include $sourceExtensions -Recurse -File -Exclude "clean_debug_tags.ps1" |
    Where-Object { $_.FullName -notmatch 'node_modules|\.git|obj|bin|dist|vendor' }

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllLines($file.FullName)
    $hasTag = $false
    $newLines = @()

    for ($lineNum = 0; $lineNum -lt $content.Length; $lineNum++) {
        $line = $content[$lineNum]
        if ($line -match "\[DEBUG-[a-zA-Z0-9_-]+\]") {
            $hasTag = $true
            Write-Host "  Found tag in $($file.Name):$($lineNum + 1) -> " -NoNewline -ForegroundColor Yellow
            Write-Host $line.Trim() -ForegroundColor DarkGray
        } else {
            $newLines += $line
        }
    }

    if ($hasTag) {
        $filesWithTags += $file.FullName
        if ($Remove) {
            [System.IO.File]::WriteAllLines($file.FullName, $newLines, [System.Text.Encoding]::UTF8)
            Write-Host "  🧹 Removed debug statements from $($file.Name)" -ForegroundColor Green
        }
    }
}

if ($filesWithTags.Count -eq 0) {
    Write-Host "✅ Zero temporary [DEBUG-*] tags found. Codebase is clean!" -ForegroundColor Green
    exit 0
} else {
    if (-not $Remove) {
        Write-Host "⚠️ Found $($filesWithTags.Count) file(s) containing temporary debug tags." -ForegroundColor Yellow
        Write-Host "💡 Run with -Remove switch to automatically purge them: powershell -File clean_debug_tags.ps1 -Remove" -ForegroundColor Cyan
        exit 1
    } else {
        Write-Host "✅ All temporary debug tags successfully purged!" -ForegroundColor Green
        exit 0
    }
}

