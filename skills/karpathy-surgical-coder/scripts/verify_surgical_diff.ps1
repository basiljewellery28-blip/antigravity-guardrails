<#
.SYNOPSIS
    Surgical diff inspector for Karpathy Surgical Coder.
.DESCRIPTION
    Analyzes Git diff and working tree changes to ensure edits are surgical,
    contained, and free of accidental file churn.
#>

[CmdletBinding()]
param(
    [int]$MaxAllowedFiles = 10
)

$ErrorActionPreference = "Stop"

Write-Host "🔍 [Surgical Coder] Inspecting working tree for surgical precision..." -ForegroundColor Cyan

if (-not (Test-Path ".git")) {
    Write-Host "ℹ️ Not a git repository. Skipping git diff inspection." -ForegroundColor Yellow
    exit 0
}

$statusOutput = git status --porcelain 2>&1
if (-not $statusOutput) {
    Write-Host "✅ Working tree is completely clean. No pending diffs." -ForegroundColor Green
    exit 0
}

$modifiedFiles = @(git diff --name-only)
$stagedFiles = @(git diff --cached --name-only)
$allChanged = @($modifiedFiles + $stagedFiles | Select-Object -Unique | Where-Object { $_ })

Write-Host "📊 Modified file count: $($allChanged.Count)" -ForegroundColor Cyan
foreach ($f in $allChanged) {
    Write-Host "  📝 $f" -ForegroundColor DarkGray
}

if ($allChanged.Count -gt $MaxAllowedFiles) {
    Write-Host "⚠️ WARNING: Diff touches $($allChanged.Count) files (threshold: $MaxAllowedFiles)." -ForegroundColor Yellow
    Write-Host "💡 Check if unrelated files were modified or if the change should be decomposed into smaller commits." -ForegroundColor Yellow
}

$diffStat = git diff --shortstat
if ($diffStat) {
    Write-Host "📈 Diff Summary: $diffStat" -ForegroundColor Green
}

Write-Host "✅ [Surgical Coder] Surgical diff inspection completed." -ForegroundColor Green
exit 0
