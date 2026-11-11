<#
.SYNOPSIS
    Automated TypeScript verification script for Antigravity skills.
.DESCRIPTION
    Checks package manager, runs TypeScript compiler in --noEmit mode, 
    and validates zero-defect compilation.
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = "."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Push-Location $ProjectPath
try {
    Write-Host "🔍 [TypeScript Guardian] Inspecting project at: $(Resolve-Path .)" -ForegroundColor Cyan

    # Check for tsconfig.json
    if (-not (Test-Path "tsconfig.json")) {
        Write-Host "⚠️ No tsconfig.json found in current directory. Scanning subdirectories..." -ForegroundColor Yellow
        $tsConfigs = Get-ChildItem -Filter "tsconfig.json" -Recurse -Depth 3 -ErrorAction SilentlyContinue
        if ($tsConfigs.Count -eq 0) {
            Write-Host "❌ No tsconfig.json located. Cannot perform type verification." -ForegroundColor Red
            exit 1
        }
        $targetConfig = $tsConfigs[0].FullName
        Write-Host "📁 Located tsconfig at: $targetConfig" -ForegroundColor Green
    }

    # Determine execution runner (pnpm, yarn, bun, npx)
    $runner = "npx"
    if (Test-Path "pnpm-lock.yaml") {
        $runner = "pnpm exec"
    } elseif (Test-Path "yarn.lock") {
        $runner = "yarn"
    } elseif (Test-Path "bun.lockb") {
        $runner = "bun x"
    }

    Write-Host "🚀 Running TypeScript compiler check ($runner tsc --noEmit)..." -ForegroundColor Cyan

    $cmd = "$runner tsc --noEmit --pretty"
    $output = Invoke-Expression $cmd 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        Write-Host "✅ [TypeScript Guardian] Compilation succeeded with ZERO errors!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "❌ [TypeScript Guardian] Compilation failed with exit code $exitCode:" -ForegroundColor Red
        Write-Host $output
        exit $exitCode
    }
}
finally {
    Pop-Location
}

