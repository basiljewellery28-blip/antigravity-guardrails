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

    if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
        Write-Host "❌ 'go' not found on PATH. Cannot verify." -ForegroundColor Red
        exit 1
    }

    # Continue: under Stop, Windows PowerShell 5.1 throws on any native stderr line
    # (go writes "FAIL"/package progress to stderr).
    $ErrorActionPreference = "Continue"

    # Step 1: go vet
    Write-Host "🔬 Running go vet ./..." -ForegroundColor Cyan
    $vetOutput = go vet ./... 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ go vet found issues:" -ForegroundColor Red
        $vetOutput | ForEach-Object { "$_" } | Write-Host
        exit $LASTEXITCODE
    }
    Write-Host "✅ go vet passed cleanly!" -ForegroundColor Green

    # Step 2: go test with race detection
    # -race needs cgo + a C compiler. Dropping it would be a false pass on a required
    # step, so fail with the cause instead of Go's terse "-race requires cgo" error.
    # Go itself sets CGO_ENABLED=0 by default when no C compiler is on PATH.
    if ((go env CGO_ENABLED) -ne "1") {
        Write-Host "❌ Cannot run the race detector: cgo is disabled (no C compiler found, or CGO_ENABLED=0)." -ForegroundColor Red
        Write-Host "   Fix: install gcc (e.g. MSYS2 mingw-w64 on Windows) and put it on PATH, set CGO_ENABLED=1, or run in WSL/Linux." -ForegroundColor Red
        exit 1
    }
    Write-Host "🧪 Running go test -race ./..." -ForegroundColor Cyan
    $testOutput = go test -race ./... 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Go tests or race conditions detected:" -ForegroundColor Red
        $testOutput | ForEach-Object { "$_" } | Write-Host
        exit $LASTEXITCODE
    }

    Write-Host "✅ All Go tests passed with race detector clean!" -ForegroundColor Green
    $testOutput | ForEach-Object { "$_" } | Write-Host
    exit 0
}
finally {
    Pop-Location
}

