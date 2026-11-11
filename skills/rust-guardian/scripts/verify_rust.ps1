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

    # Step 1: cargo check
    Write-Host "🔨 Running cargo check --all-targets..." -ForegroundColor Cyan
    $checkOutput = cargo check --all-targets 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ cargo check failed:" -ForegroundColor Red
        Write-Host $checkOutput
        exit $LASTEXITCODE
    }
    Write-Host "✅ Syntax & type check passed!" -ForegroundColor Green

    # Step 2: cargo clippy with zero warnings
    Write-Host "🔬 Running cargo clippy --all-targets --all-features -- -D warnings..." -ForegroundColor Cyan
    $clippyOutput = cargo clippy --all-targets --all-features -- -D warnings 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ cargo clippy found linter violations:" -ForegroundColor Red
        Write-Host $clippyOutput
        exit $LASTEXITCODE
    }
    Write-Host "✅ cargo clippy passed with ZERO warnings!" -ForegroundColor Green

    # Step 3: cargo test
    Write-Host "🧪 Running cargo test..." -ForegroundColor Cyan
    $testOutput = cargo test 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Cargo tests failed:" -ForegroundColor Red
        Write-Host $testOutput
        exit $LASTEXITCODE
    }

    Write-Host "✅ All Cargo test suites passed cleanly!" -ForegroundColor Green
    Write-Host $testOutput
    exit 0
}
finally {
    Pop-Location
}
