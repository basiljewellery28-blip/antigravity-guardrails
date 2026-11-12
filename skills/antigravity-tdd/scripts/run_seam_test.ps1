<#
.SYNOPSIS
    Automated multi-stack seam test runner for Antigravity TDD.
.DESCRIPTION
    Detects project type from file extension and package manifests, 
    running only the targeted test file for rapid Red-Green-Refactor cycles.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$TestFile
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $TestFile)) {
    Write-Host "❌ Test file not found: $TestFile" -ForegroundColor Red
    exit 1
}

$ext = [System.IO.Path]::GetExtension($TestFile).ToLower()
Write-Host "🎯 Running targeted seam test for: $TestFile" -ForegroundColor Cyan

$exe = ""
$cmdArgs = @()
$isWin = [System.IO.Path]::DirectorySeparatorChar -eq '\'

switch ($ext) {
    { $_ -in ".ts", ".tsx", ".js", ".jsx" } {
        if (-not (Test-Path "package.json")) {
            Write-Host "❌ No package.json in $(Get-Location); run from the project root." -ForegroundColor Red
            exit 1
        }
        if (Test-Path "pnpm-lock.yaml") {
            $exe = "pnpm"; $cmdArgs = @("test", "--", $TestFile)
        } elseif (Test-Path "yarn.lock") {
            $exe = "yarn"; $cmdArgs = @("test", $TestFile)
        } else {
            # --no-install: don't silently download vitest into a project that doesn't use it.
            $exe = "npx"; $cmdArgs = @("--no-install", "vitest", "run", $TestFile)
        }
    }
    ".py" {
        if (Test-Path "uv.lock") {
            $exe = "uv"; $cmdArgs = @("run", "pytest", $TestFile)
        } elseif (Test-Path "poetry.lock") {
            $exe = "poetry"; $cmdArgs = @("run", "pytest", $TestFile)
        } else {
            $exe = "pytest"; $cmdArgs = @($TestFile)
        }
    }
    ".go" {
        # go treats a bare "src/pkg" as an import path; it needs a ./ prefix to mean a directory.
        $dir = [System.IO.Path]::GetDirectoryName($TestFile)
        if ([string]::IsNullOrEmpty($dir)) { $dir = "." }
        elseif (-not [System.IO.Path]::IsPathRooted($dir)) { $dir = "./" + $dir.Replace('\', '/') }
        $exe = "go"; $cmdArgs = @("test", "-v", $dir)
    }
    ".cs" {
        $exe = "dotnet"; $cmdArgs = @("test")
    }
    ".java" {
        $mvnw = if ($isWin) { "mvnw.cmd" } else { "mvnw" }
        if (Test-Path $mvnw) {
            $exe = (Resolve-Path $mvnw).Path; $cmdArgs = @("test")
        } else {
            $exe = "mvn"; $cmdArgs = @("test")
        }
    }
    default {
        Write-Host "❌ Unsupported test file extension: $ext" -ForegroundColor Red
        exit 1
    }
}

if (-not (Get-Command $exe -ErrorAction SilentlyContinue)) {
    Write-Host "❌ '$exe' not found on PATH. Cannot run test." -ForegroundColor Red
    exit 1
}

Write-Host "🚀 Executing: $exe $($cmdArgs -join ' ')" -ForegroundColor Cyan
# Continue: under Stop, Windows PowerShell 5.1 throws on any native stderr line.
$ErrorActionPreference = "Continue"
$output = & $exe @cmdArgs 2>&1
$exitCode = $LASTEXITCODE

$output | ForEach-Object { "$_" } | Write-Host
if ($exitCode -eq 0) {
    Write-Host "🟢 [TDD Seam Runner] Test PASSED (GREEN)" -ForegroundColor Green
} else {
    Write-Host "🔴 [TDD Seam Runner] Test FAILED (RED)" -ForegroundColor Red
}

exit $exitCode

