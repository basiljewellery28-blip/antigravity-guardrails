<#
.SYNOPSIS
    Installs Antigravity pre-commit guardrail hooks into a Git repository.
.DESCRIPTION
    Copies the pre-commit security verification hook into .git/hooks/pre-commit
    to automatically block commits with exposed secrets or insecure code patterns.
#>

[CmdletBinding()]
param(
    [string]$TargetDirectory = "."
)

$ErrorActionPreference = "Stop"

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🛡️ Installing Antigravity Git Pre-Commit Security Hook      " -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan

$resolvedTarget = Resolve-Path $TargetDirectory
$gitDir = Join-Path $resolvedTarget ".git"

if (-not (Test-Path $gitDir)) {
    Write-Host "❌ No .git directory found in: $resolvedTarget" -ForegroundColor Red
    Write-Host "💡 Make sure you are inside your project folder before running this command," -ForegroundColor Yellow
    Write-Host "   or pass the path directly: setup-hooks.ps1 -TargetDirectory 'C:\path\to\your-project'" -ForegroundColor Yellow
    exit 1
}

$hooksDir = Join-Path $gitDir "hooks"
if (-not (Test-Path $hooksDir)) {
    New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
}

$scriptDir = $PSScriptRoot
if (-not $scriptDir) {
    $scriptDir = (Get-Location).Path
}

$sourceHook = Join-Path (Join-Path (Join-Path (Resolve-Path $scriptDir) "scripts") "git-hooks") "pre-commit"
$targetHook = Join-Path $hooksDir "pre-commit"

if (-not (Test-Path $sourceHook)) {
    Write-Host "❌ Source hook '$sourceHook' not found." -ForegroundColor Red
    exit 1
}

# Rewrite as LF: an autocrlf checkout gives the source CRLF, and "#!/usr/bin/env sh\r" breaks the hook.
$hookText = [System.IO.File]::ReadAllText($sourceHook) -replace "`r`n", "`n"
if ((Test-Path $targetHook) -and ([System.IO.File]::ReadAllText($targetHook) -ne $hookText)) {
    Copy-Item -Path $targetHook -Destination "$targetHook.bak" -Force
    Write-Host "💾 Existing pre-commit hook backed up to: $targetHook.bak" -ForegroundColor Yellow
}
[System.IO.File]::WriteAllText($targetHook, $hookText, (New-Object System.Text.UTF8Encoding($false)))
if ($PSVersionTable.PSEdition -eq "Core" -and -not $IsWindows) { chmod +x $targetHook }
Write-Host "✅ Pre-commit hook installed to: $targetHook" -ForegroundColor Green
Write-Host "💡 Any 'git commit' in '$resolvedTarget' will now automatically run Secret Sentinel & OWASP checks before completing." -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
exit 0
