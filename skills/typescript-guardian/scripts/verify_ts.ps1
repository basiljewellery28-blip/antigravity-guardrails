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

$tscArgs = @()
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
        $tscArgs = @("-p", $targetConfig)
        Write-Host "📁 Located tsconfig at: $targetConfig" -ForegroundColor Green
    }

    # Determine execution runner (pnpm, yarn, bun, npx)
    # --no-install: bare `npx tsc` would download the unrelated "tsc" package and fail confusingly.
    $runner = "npx"
    $runnerArgs = @("--no-install")
    if (Test-Path "pnpm-lock.yaml") {
        $runner = "pnpm"; $runnerArgs = @("exec")
    } elseif (Test-Path "yarn.lock") {
        $runner = "yarn"; $runnerArgs = @()
    } elseif ((Test-Path "bun.lockb") -or (Test-Path "bun.lock")) {
        $runner = "bun"; $runnerArgs = @("x")
    }

    if (-not (Get-Command $runner -ErrorAction SilentlyContinue)) {
        Write-Host "❌ '$runner' not found on PATH. Cannot run tsc." -ForegroundColor Red
        exit 1
    }

    Write-Host "🚀 Running TypeScript compiler check ($runner $($runnerArgs -join ' ') tsc --noEmit)..." -ForegroundColor Cyan

    # Continue: under Stop, Windows PowerShell 5.1 throws on any native stderr line (e.g. npm warnings).
    $ErrorActionPreference = "Continue"
    $output = & $runner @runnerArgs tsc --noEmit --pretty @tscArgs 2>&1
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = "Stop"

    if ($exitCode -eq 0) {
        Write-Host "✅ [TypeScript Guardian] Compilation succeeded with ZERO errors!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "❌ [TypeScript Guardian] Compilation failed with exit code ${exitCode}:" -ForegroundColor Red
        $output | ForEach-Object { "$_" } | Write-Host
        exit $exitCode
    }
}
finally {
    Pop-Location
}

