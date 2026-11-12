<#
.SYNOPSIS
    One-click global installer for Antigravity Polyglot Engineering Skills.
.DESCRIPTION
    Installs all language guardians, TDD seam runner, security sentinels, 
    and migration bridges directly into your Antigravity global configuration (~/.gemini/config/skills/).
#>

[CmdletBinding()]
param(
    [switch]$IncludeSuites
)

$ErrorActionPreference = "Stop"

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🚀 Installing Antigravity Polyglot Engineering Skills      " -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan

$globalSkillsDir = Join-Path (Join-Path (Join-Path $HOME ".gemini") "config") "skills"

if (-not (Test-Path $globalSkillsDir)) {
    Write-Host "📁 Creating global skills directory: $globalSkillsDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $globalSkillsDir -Force | Out-Null
}

# Not Get-Location: running from another directory must still install this repo.
$localSkillsDir = Join-Path $PSScriptRoot "skills"

if (-not (Test-Path $localSkillsDir)) {
    Write-Host "❌ Could not find local 'skills' directory in $PSScriptRoot" -ForegroundColor Red
    exit 1
}

$skills = @(Get-ChildItem -Path $localSkillsDir -Directory)

foreach ($skill in $skills) {
    $destination = Join-Path $globalSkillsDir $skill.Name
    Write-Host "📦 Installing skill: " -NoNewline -ForegroundColor Cyan
    Write-Host "$($skill.Name)" -ForegroundColor Yellow -NoNewline
    Write-Host " -> " -NoNewline
    Write-Host "$destination" -ForegroundColor DarkGray
    
    Copy-Item -Path $skill.FullName -Destination $globalSkillsDir -Recurse -Force
}

if ($IncludeSuites) {
    Write-Host "`n📦 Installing modular domain suites (Document, Founder, Cloud)..." -ForegroundColor Cyan
    $suiteInstaller = Join-Path $PSScriptRoot "install-suite.ps1"
    if (-not (Test-Path $suiteInstaller)) {
        Write-Host "❌ Could not find $suiteInstaller" -ForegroundColor Red
        exit 1
    }
    # In-process (not a child powershell.exe, which does not exist on Linux/macOS); -Suite all reinstalls core too, harmlessly.
    & $suiteInstaller -Suite all -TargetSkillsDir $globalSkillsDir
}

Write-Host ""
Write-Host "✅ All $($skills.Count) skills installed globally with success!" -ForegroundColor Green
Write-Host "💡 Gemini / Antigravity will now automatically discover and use these skills across all projects on your machine." -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
exit 0
