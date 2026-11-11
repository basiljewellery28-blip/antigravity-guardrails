<#
.SYNOPSIS
    One-click global installer for Antigravity Polyglot Engineering Skills.
.DESCRIPTION
    Installs all language guardians, TDD seam runner, security sentinels, 
    and migration bridges directly into your Antigravity global configuration (~/.gemini/config/skills/).
#>

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$IncludeSuites
)

$ErrorActionPreference = "Stop"

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🚀 Installing Antigravity Polyglot Engineering Skills      " -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan

$globalSkillsDir = Join-Path $env:USERPROFILE ".gemini\config\skills"

if (-not (Test-Path $globalSkillsDir)) {
    Write-Host "📁 Creating global skills directory: $globalSkillsDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $globalSkillsDir -Force | Out-Null
}

$localSkillsDir = Join-Path (Get-Location) "skills"
if (-not (Test-Path $localSkillsDir)) {
    if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot "skills"))) {
        $localSkillsDir = Join-Path $PSScriptRoot "skills"
    }
}

if (-not (Test-Path $localSkillsDir)) {
    Write-Host "❌ Could not find local 'skills' directory in $(Get-Location)" -ForegroundColor Red
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
    if (Test-Path $suiteInstaller) {
        & powershell -ExecutionPolicy Bypass -File $suiteInstaller -Suite all
    }
}

Write-Host ""
Write-Host "✅ All $($skills.Count) skills installed globally with success!" -ForegroundColor Green
Write-Host "💡 Gemini / Antigravity will now automatically discover and use these skills across all projects on your machine." -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
exit 0
