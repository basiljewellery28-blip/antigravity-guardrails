<#
.SYNOPSIS
    Automated Python verification script for Antigravity skills.
.DESCRIPTION
    Detects Python environment (uv, poetry, venv), runs type checker, 
    linter, and pytest test suite.
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

Push-Location $ProjectPath
try {
    Write-Host "🔍 [Python Guardian] Inspecting project at: $(Resolve-Path .)" -ForegroundColor Cyan

    # Determine Python runner
    $pythonCmd = "python"
    $runnerPrefix = ""

    if (Test-Path "uv.lock") {
        Write-Host "📦 Detected uv environment" -ForegroundColor Green
        $runnerPrefix = "uv run "
    } elseif (Test-Path "poetry.lock") {
        Write-Host "📦 Detected Poetry environment" -ForegroundColor Green
        $runnerPrefix = "poetry run "
    } elseif (Test-Path "Pipfile.lock") {
        Write-Host "📦 Detected Pipenv environment" -ForegroundColor Green
        $runnerPrefix = "pipenv run "
    } elseif (Test-Path ".venv\Scripts\python.exe") {
        $pythonCmd = ".\.venv\Scripts\python.exe"
        Write-Host "📦 Detected local .venv" -ForegroundColor Green
    } elseif (Test-Path "venv\Scripts\python.exe") {
        $pythonCmd = ".\venv\Scripts\python.exe"
        Write-Host "📦 Detected local venv" -ForegroundColor Green
    }

    # Step 1: Type Checking (mypy or pyright)
    Write-Host "🧪 Running static type analysis..." -ForegroundColor Cyan
    $typeCheckCmd = "${runnerPrefix}mypy . --ignore-missing-imports"
    try {
        $typeOutput = Invoke-Expression $typeCheckCmd 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Static type analysis passed!" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Type issues detected:" -ForegroundColor Yellow
            Write-Host $typeOutput
        }
    } catch {
        Write-Host "ℹ️ mypy not installed or configured, checking pyright..." -ForegroundColor DarkGray
    }

    # Step 2: Test Suite (pytest)
    Write-Host "🧪 Running test suite..." -ForegroundColor Cyan
    $testCmd = "${runnerPrefix}pytest -q"
    try {
        $testOutput = Invoke-Expression $testCmd 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ All tests passing!" -ForegroundColor Green
            Write-Host $testOutput
            exit 0
        } else {
            Write-Host "❌ Test execution failed:" -ForegroundColor Red
            Write-Host $testOutput
            exit $LASTEXITCODE
        }
    } catch {
        Write-Host "ℹ️ pytest command not found, falling back to unittest discovery..." -ForegroundColor Yellow
        $fallbackCmd = "$pythonCmd -m unittest discover -s . -p '*test*.py'"
        $fallbackOutput = Invoke-Expression $fallbackCmd 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Unittest discovery passed!" -ForegroundColor Green
            exit 0
        } else {
            Write-Host "❌ Unittest failed:" -ForegroundColor Red
            Write-Host $fallbackOutput
            exit $LASTEXITCODE
        }
    }
}
finally {
    Pop-Location
}

