<#
.SYNOPSIS
    Automated Rust verification script for Antigravity skills.
.DESCRIPTION
    Runs cargo check, cargo clippy with warnings treated as errors, 
    and executes all cargo test suites.
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

Push-Location $ProjectPath
try {
    Write-Host "🔍 [Rust Guardian] Inspecting Rust crate at: $(Resolve-Path .)" -ForegroundColor Cyan

    if (-not (Test-Path "Cargo.toml")) {
        Write-Host "❌ No Cargo.toml found in project root." -ForegroundColor Red
        exit 1
    }

    if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
        Write-Host "❌ 'cargo' not found on PATH. Cannot verify." -ForegroundColor Red
        exit 1
    }

    # Continue: cargo writes all progress to stderr, which Windows PowerShell 5.1 turns into
    # terminating errors under Stop (false failure on a clean build).
    $ErrorActionPreference = "Continue"

    # Step 1: cargo check
    Write-Host "🔨 Running cargo check --all-targets..." -ForegroundColor Cyan
    $checkOutput = cargo check --all-targets 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ cargo check failed:" -ForegroundColor Red
        $checkOutput | ForEach-Object { "$_" } | Write-Host
        exit $LASTEXITCODE
    }
    Write-Host "✅ Syntax & type check passed!" -ForegroundColor Green

    # Step 2: cargo clippy with zero warnings
    Write-Host "🔬 Running cargo clippy --all-targets --all-features -- -D warnings..." -ForegroundColor Cyan
    $clippyOutput = cargo clippy --all-targets --all-features -- -D warnings 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ cargo clippy found linter violations:" -ForegroundColor Red
        $clippyOutput | ForEach-Object { "$_" } | Write-Host
        exit $LASTEXITCODE
    }
    Write-Host "✅ cargo clippy passed with ZERO warnings!" -ForegroundColor Green

    # Step 3: cargo test
    Write-Host "🧪 Running cargo test..." -ForegroundColor Cyan
    $testOutput = cargo test 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Cargo tests failed:" -ForegroundColor Red
        $testOutput | ForEach-Object { "$_" } | Write-Host
        exit $LASTEXITCODE
    }

    Write-Host "✅ All Cargo test suites passed cleanly!" -ForegroundColor Green
    $testOutput | ForEach-Object { "$_" } | Write-Host
    exit 0
}
finally {
    Pop-Location
}

