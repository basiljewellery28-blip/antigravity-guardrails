<#
.SYNOPSIS
    Installs modular domain skill suites into the user's global Antigravity skills directory.
.DESCRIPTION
    Provides granular control over domain-specific skills (e.g. document-suite, founder-suite,
    cloud-suite) without bloating the agent's core context window when unneeded.
.PARAMETER Suite
    The suite to install: 'all', 'document', 'founder', 'cloud', or 'core'. Defaults to 'all'.
.PARAMETER TargetSkillsDir
    Destination global skills folder (defaults to ~/.gemini/config/skills).
.PARAMETER Uninstall
    If specified, removes the specified suite from the global skills directory.
#>
[CmdletBinding()]
param (
    [ValidateSet("all", "document", "founder", "cloud", "core")]
    [string]$Suite = "all",
    [string]$TargetSkillsDir = (Join-Path $HOME ".gemini\config\skills"),
    [switch]$Uninstall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Antigravity Modular Suite Installer" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$scriptRoot = (Get-Location).Path
$suitesDir = Join-Path $scriptRoot "suites"
$coreSkillsDir = Join-Path $scriptRoot "skills"

# Map suite keys to folder paths
$suiteMap = @{
    "document" = @(Join-Path $suitesDir "document-suite")
    "founder"  = @(Join-Path $suitesDir "founder-suite")
    "cloud"    = @(Join-Path $suitesDir "cloud-suite")
    "core"     = @($coreSkillsDir)
}

$targetDirs = @()
if ($Suite -eq "all") {
    $targetDirs = @(
        $coreSkillsDir,
        (Join-Path $suitesDir "document-suite"),
        (Join-Path $suitesDir "founder-suite"),
        (Join-Path $suitesDir "cloud-suite")
    )
} else {
    $targetDirs = $suiteMap[$Suite]
}

if (-not (Test-Path $TargetSkillsDir)) {
    Write-Host "Creating target directory: $TargetSkillsDir" -ForegroundColor Gray
    New-Item -ItemType Directory -Path $TargetSkillsDir -Force | Out-Null
}

$installedCount = 0
$removedCount = 0

foreach ($srcParent in $targetDirs) {
    if (-not (Test-Path $srcParent)) {
        Write-Host "Warning: Source directory not found: $srcParent" -ForegroundColor Yellow
        continue
    }

    $subSkills = @(Get-ChildItem -Path $srcParent -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notmatch 'node_modules|\.git|vendor|research' })

    foreach ($sk in $subSkills) {
        $destPath = Join-Path $TargetSkillsDir $sk.Name

        if ($Uninstall) {
            if (Test-Path $destPath) {
                Write-Host "Removing: $($sk.Name) from $TargetSkillsDir" -ForegroundColor Yellow
                Remove-Item -Path $destPath -Recurse -Force
                $removedCount++
            }
        } else {
            Write-Host "Installing: $($sk.Name) -> $destPath" -ForegroundColor Green
            Copy-Item -Path $sk.FullName -Destination $destPath -Recurse -Force
            $installedCount++
        }
    }
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
if ($Uninstall) {
    Write-Host "   Suite [$Suite] Uninstalled ($removedCount skills removed)" -ForegroundColor Yellow
} else {
    Write-Host "   Suite [$Suite] Successfully Installed ($installedCount skills live)" -ForegroundColor Green
}
Write-Host "==========================================================" -ForegroundColor Cyan
exit 0

