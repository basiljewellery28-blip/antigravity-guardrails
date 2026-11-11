<#
.SYNOPSIS
    Automated verification of Git repository hygiene and conventional commit formatting.
.DESCRIPTION
    Checks for uncommitted working tree clutter, verifies recent commit messages
    against Conventional Commits patterns, and ensures no stray debug artifacts exist.
#>
[CmdletBinding()]
param (
    [int]$CommitHistoryDepth = 5
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Git Workflow & Repository Hygiene Gate" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$violations = @()

# 1. Verify Git availability and working tree status
Write-Host "`n[1/3] Checking Git status and working directory hygiene..." -ForegroundColor Gray
if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    Write-Host "  Git command not found in PATH." -ForegroundColor Red
    exit 1
}

$statusOutput = @(git status --porcelain 2>$null)
$strayArtifacts = @($statusOutput | Where-Object {
    $_ -match '(?:\.env|\.log|Thumbs\.db|\.DS_Store|node_modules)'
})

if ($strayArtifacts.Count -gt 0) {
    foreach ($sa in $strayArtifacts) {
        $violations += "Stray unignored artifact in working tree: $sa"
    }
} else {
    Write-Host "  No sensitive unignored files in working tree." -ForegroundColor Green
}

# 2. Check recent commit messages for Conventional Commits formatting
Write-Host "`n[2/3] Validating recent commit messages (depth = $CommitHistoryDepth)..." -ForegroundColor Gray
$commitRegex = '^(?:feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(?:\([a-zA-Z0-9_\-\.\/]+\))?:\s+.+'

$recentCommits = @(git log "-n$CommitHistoryDepth" --pretty=format:"%h|%s" 2>$null)
if ($recentCommits.Count -gt 0) {
    foreach ($entry in $recentCommits) {
        if (-not [string]::IsNullOrWhiteSpace($entry)) {
            $parts = $entry.Split('|', 2)
            $hash = $parts[0]
            $subject = if ($parts.Length -gt 1) { $parts[1] } else { "" }

            # Ignore Merge commits or initial commit
            if ($subject -match '^Merge ' -or $subject -match '^Initial commit') {
                Write-Host "  [$hash] $subject (Allowed merge/init)" -ForegroundColor DarkGray
                continue
            }

            if ($subject -notmatch $commitRegex) {
                $violations += "Commit [$hash] does not follow Conventional Commits format: '$subject'"
            } else {
                Write-Host "  [$hash] $subject (Valid)" -ForegroundColor Green
            }
        }
    }
} else {
    Write-Host "  No commit history found (shallow or uninitialized repo)." -ForegroundColor Yellow
}

# 3. Report Results
Write-Host "`n[3/3] Evaluating Git Hygiene Gate Status..." -ForegroundColor Gray
if ($violations.Count -gt 0) {
    Write-Host "  FAILED: Git hygiene violations detected:" -ForegroundColor Red
    foreach ($v in $violations) {
        Write-Host "    - $v" -ForegroundColor Red
    }
    Write-Host "`n==========================================================" -ForegroundColor Red
    Write-Host "   Git Hygiene Verification: FAILED ($($violations.Count) violations)" -ForegroundColor Red
    Write-Host "==========================================================" -ForegroundColor Red
    exit 1
} else {
    Write-Host "  All git hygiene and commit format checks passed cleanly." -ForegroundColor Green
    Write-Host "`n==========================================================" -ForegroundColor Cyan
    Write-Host "   Git Hygiene Verification Gate: PASS" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Cyan
    exit 0
}
