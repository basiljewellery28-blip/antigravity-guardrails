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

$cmd = ""

switch ($ext) {
    { $_ -in ".ts", ".tsx", ".js", ".jsx" } {
        if (Test-Path "package.json") {
            if (Test-Path "pnpm-lock.yaml") {
                $cmd = "pnpm test -- $TestFile"
            } elseif (Test-Path "yarn.lock") {
                $cmd = "yarn test $TestFile"
            } else {
                $cmd = "npx vitest run $TestFile"
            }
        }
    }
    ".py" {
        if (Test-Path "uv.lock") {
            $cmd = "uv run pytest $TestFile"
        } elseif (Test-Path "poetry.lock") {
            $cmd = "poetry run pytest $TestFile"
        } else {
            $cmd = "pytest $TestFile"
        }
    }
    ".go" {
        $dir = [System.IO.Path]::GetDirectoryName($TestFile)
        $cmd = "go test -v $dir"
    }
    ".cs" {
        $cmd = "dotnet test"
    }
    ".java" {
        if (Test-Path "mvnw.cmd") {
            $cmd = ".\mvnw.cmd test"
        } else {
            $cmd = "mvn test"
        }
    }
    default {
        Write-Host "❌ Unsupported test file extension: $ext" -ForegroundColor Red
        exit 1
    }
}

Write-Host "🚀 Executing: $cmd" -ForegroundColor Cyan
$output = Invoke-Expression $cmd 2>&1
$exitCode = $LASTEXITCODE

Write-Host $output
if ($exitCode -eq 0) {
    Write-Host "🟢 [TDD Seam Runner] Test PASSED (GREEN)" -ForegroundColor Green
} else {
    Write-Host "🔴 [TDD Seam Runner] Test FAILED (RED)" -ForegroundColor Red
}

exit $exitCode

