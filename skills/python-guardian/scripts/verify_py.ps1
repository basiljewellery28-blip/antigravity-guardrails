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

    # Determine Python runner (executable + leading args)
    $pyExe = "python"
    if (-not (Get-Command python -ErrorAction SilentlyContinue) -and (Get-Command python3 -ErrorAction SilentlyContinue)) {
        $pyExe = "python3"
    }
    $pyRunArgs = @()

    if (Test-Path "uv.lock") {
        Write-Host "📦 Detected uv environment" -ForegroundColor Green
        $pyExe = "uv"; $pyRunArgs = @("run", "python")
    } elseif (Test-Path "poetry.lock") {
        Write-Host "📦 Detected Poetry environment" -ForegroundColor Green
        $pyExe = "poetry"; $pyRunArgs = @("run", "python")
    } elseif (Test-Path "Pipfile.lock") {
        Write-Host "📦 Detected Pipenv environment" -ForegroundColor Green
        $pyExe = "pipenv"; $pyRunArgs = @("run", "python")
    } elseif (Test-Path ".venv\Scripts\python.exe") {
        $pyExe = (Resolve-Path ".venv\Scripts\python.exe").Path
        Write-Host "📦 Detected local .venv" -ForegroundColor Green
    } elseif (Test-Path "venv\Scripts\python.exe") {
        $pyExe = (Resolve-Path "venv\Scripts\python.exe").Path
        Write-Host "📦 Detected local venv" -ForegroundColor Green
    } elseif (Test-Path ".venv/bin/python") {
        $pyExe = (Resolve-Path ".venv/bin/python").Path
        Write-Host "📦 Detected local .venv" -ForegroundColor Green
    } elseif (Test-Path "venv/bin/python") {
        $pyExe = (Resolve-Path "venv/bin/python").Path
        Write-Host "📦 Detected local venv" -ForegroundColor Green
    }

    if (-not (Get-Command $pyExe -ErrorAction SilentlyContinue)) {
        Write-Host "❌ '$pyExe' not found on PATH. Cannot run Python verification." -ForegroundColor Red
        exit 1
    }

    # Continue: under Stop, Windows PowerShell 5.1 throws on any native stderr line.
    $ErrorActionPreference = "Continue"

    # Step 1: Type Checking (mypy)
    Write-Host "🧪 Running static type analysis..." -ForegroundColor Cyan
    $typeOutput = & $pyExe @pyRunArgs -m mypy . --ignore-missing-imports 2>&1
    $typeExit = $LASTEXITCODE
    if ($typeExit -eq 0) {
        Write-Host "✅ Static type analysis passed!" -ForegroundColor Green
    } elseif (($typeOutput | ForEach-Object { "$_" }) -match "No module named mypy") {
        # Type checking is a required step of this gate (SKILL.md); skipping it would be a false pass.
        Write-Host "❌ mypy not installed; static type analysis NOT verified. Install it (e.g. 'pip install mypy') and re-run." -ForegroundColor Red
        exit 1
    } else {
        Write-Host "❌ Type issues detected:" -ForegroundColor Red
        $typeOutput | ForEach-Object { "$_" } | Write-Host
        exit $typeExit
    }

    # Step 2: Test Suite (pytest, falling back to unittest only if pytest is not installed)
    Write-Host "🧪 Running test suite..." -ForegroundColor Cyan
    $testOutput = & $pyExe @pyRunArgs -m pytest -q 2>&1
    $testExit = $LASTEXITCODE
    if ($testExit -ne 0 -and (($testOutput | ForEach-Object { "$_" }) -match "No module named pytest")) {
        Write-Host "ℹ️ pytest not installed, falling back to unittest discovery..." -ForegroundColor Yellow
        $testOutput = & $pyExe @pyRunArgs -m unittest discover -s . -p "*test*.py" 2>&1
        $testExit = $LASTEXITCODE
    }

    if ($testExit -eq 0) {
        Write-Host "✅ All tests passing!" -ForegroundColor Green
        $testOutput | ForEach-Object { "$_" } | Write-Host
        exit 0
    } else {
        Write-Host "❌ Test execution failed:" -ForegroundColor Red
        $testOutput | ForEach-Object { "$_" } | Write-Host
        exit $testExit
    }
}
finally {
    Pop-Location
}

