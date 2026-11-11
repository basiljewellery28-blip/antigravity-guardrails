<#
.SYNOPSIS
    Installs Antigravity pre-commit guardrail hooks into the local Git repository.
.DESCRIPTION
    Copies the pre-commit security verification hook into .git/hooks/pre-commit
    to automatically block commits with exposed secrets or insecure code patterns.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🛡️ Installing Antigravity Git Pre-Commit Security Hook      " -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan

if (-not (Test-Path ".git")) {
    Write-Host "❌ No .git directory found. Run 'git init' first." -ForegroundColor Red
    exit 1
}

$hooksDir = Join-Path ".git" "hooks"
if (-not (Test-Path $hooksDir)) {
    New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
}

$sourceHook = Join-Path "scripts" "git-hooks\pre-commit"
$targetHook = Join-Path $hooksDir "pre-commit"

if (-not (Test-Path $sourceHook)) {
    Write-Host "❌ Source hook '$sourceHook' not found." -ForegroundColor Red
    exit 1
}

Copy-Item -Path $sourceHook -Destination $targetHook -Force
Write-Host "✅ Pre-commit hook installed to: $targetHook" -ForegroundColor Green
Write-Host "💡 Any 'git commit' will now automatically run Secret Sentinel & OWASP checks before completing." -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
exit 0

