<#
.SYNOPSIS
    Automated Go verification script for Antigravity skills.
.DESCRIPTION
    Runs go vet static analysis and go test with race detector enabled across all packages.
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

Push-Location $ProjectPath
try {
    Write-Host "🔍 [Go Guardian] Inspecting Go module at: $(Resolve-Path .)" -ForegroundColor Cyan

    if (-not (Test-Path "go.mod")) {
        Write-Host "❌ No go.mod found in project root." -ForegroundColor Red
        exit 1
    }

    # Step 1: go vet
    Write-Host "🔬 Running go vet ./..." -ForegroundColor Cyan
    $vetOutput = go vet ./... 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ go vet found issues:" -ForegroundColor Red
        Write-Host $vetOutput
        exit $LASTEXITCODE
    }
    Write-Host "✅ go vet passed cleanly!" -ForegroundColor Green

    # Step 2: go test with race detection
    Write-Host "🧪 Running go test -race ./..." -ForegroundColor Cyan
    $testOutput = go test -race ./... 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Go tests or race conditions detected:" -ForegroundColor Red
        Write-Host $testOutput
        exit $LASTEXITCODE
    }

    Write-Host "✅ All Go tests passed with race detector clean!" -ForegroundColor Green
    Write-Host $testOutput
    exit 0
}
finally {
    Pop-Location
}

