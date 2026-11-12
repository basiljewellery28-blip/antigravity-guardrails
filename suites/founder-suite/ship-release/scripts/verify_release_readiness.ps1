<#
.SYNOPSIS
    Automated pre-flight verification script for release readiness.
.DESCRIPTION
    Validates working tree cleanliness, checks versioning files, and ensures
    all automated quality checks pass before release.
#>
[CmdletBinding()]
param (
    [string]$TargetDirectory = "."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Pre-Flight Release Readiness Gate" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$blockers = @()

# 1. Working tree cleanliness
Write-Host "`n[1/4] Checking working tree cleanliness..." -ForegroundColor Gray
# -C: check the target project, not whatever the cwd happens to be. A failed git call (not a repo,
# git missing) must not be reported as "clean".
$uncommitted = @()
$gitOk = $false
if (Get-Command git -ErrorAction SilentlyContinue) {
    # Continue: under Stop, Windows PowerShell 5.1 turns git's "not a git repository" stderr into a crash.
    $ErrorActionPreference = "Continue"
    $uncommitted = @(git -C $TargetDirectory status --porcelain 2>$null)
    $gitOk = ($LASTEXITCODE -eq 0)
    $ErrorActionPreference = "Stop"
}
if (-not $gitOk) {
    Write-Host "  Warning: could not read git status for $TargetDirectory (not a git repo or git missing); cleanliness NOT verified." -ForegroundColor Yellow
} elseif ($uncommitted.Count -gt 0) {
    Write-Host "  Warning: Working tree has $($uncommitted.Count) uncommitted change(s)." -ForegroundColor Yellow
} else {
    Write-Host "  Working tree is completely clean." -ForegroundColor Green
}

# 2. Check for versioning files
Write-Host "`n[2/4] Verifying version declaration..." -ForegroundColor Gray
$versionFiles = @(Get-ChildItem -Path (Join-Path $TargetDirectory "*") -File -Include "package.json", "pyproject.toml", "Cargo.toml", "*.csproj", "VERSION" -ErrorAction SilentlyContinue)
if ($versionFiles.Count -gt 0) {
    Write-Host "  Found version manifest: $($versionFiles[0].Name)" -ForegroundColor Green
} else {
    Write-Host "  No standard version manifest found (package.json/Cargo.toml/VERSION)." -ForegroundColor Yellow
}

# 3. Check for changelog or release notes
Write-Host "`n[3/4] Verifying changelog documentation..." -ForegroundColor Gray
$changelogFiles = @(Get-ChildItem -Path (Join-Path $TargetDirectory "*") -File -Include "CHANGELOG.md", "RELEASES.md", "HISTORY.md" -ErrorAction SilentlyContinue)
if ($changelogFiles.Count -gt 0) {
    Write-Host "  Found changelog document: $($changelogFiles[0].Name)" -ForegroundColor Green
} else {
    Write-Host "  Note: CHANGELOG.md not found in root. Recommended to document release changes." -ForegroundColor Yellow
}

# 4. Security scan
Write-Host "`n[4/4] Running security pre-flight check..." -ForegroundColor Gray
# Look in the target project, then next to this suite (repo layout, then installed layout).
$scanScript = @(
    (Join-Path (Join-Path (Resolve-Path $TargetDirectory).Path "skills") "security-secret-sentinel/scripts/scan_secrets.ps1"),
    (Join-Path $PSScriptRoot "../../../../skills/security-secret-sentinel/scripts/scan_secrets.ps1"),
    (Join-Path $PSScriptRoot "../../security-secret-sentinel/scripts/scan_secrets.ps1")
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($scanScript) {
    $secExit = 0
    try {
        # Run in the current host: 'powershell' does not exist under pwsh on Linux/macOS.
        & (Get-Process -Id $PID).Path -NoProfile -ExecutionPolicy Bypass -File $scanScript -ProjectPath $TargetDirectory
        $secExit = $LASTEXITCODE
    } catch {
        $secExit = 1
    }
    if ($secExit -ne 0) {
        $blockers += "Security secret scan reported violations."
    }
} else {
    # Shipping without the secret check would be a false "ready"; install the security-secret-sentinel skill.
    Write-Host "  Security scan script not found; secret check NOT verified." -ForegroundColor Red
    $blockers += "Secret scan could not run: security-secret-sentinel scanner not found."
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
if ($blockers.Count -gt 0) {
    Write-Host "   Release Readiness Gate: BLOCKED ($($blockers.Count) blocker(s))" -ForegroundColor Red
    foreach ($b in $blockers) {
        Write-Host "    - $b" -ForegroundColor Red
    }
    Write-Host "==========================================================" -ForegroundColor Red
    exit 1
} else {
    Write-Host "   Release Readiness Gate: READY TO SHIP" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Cyan
    exit 0
}
