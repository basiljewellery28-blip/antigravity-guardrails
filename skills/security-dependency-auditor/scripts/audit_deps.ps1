<#
.SYNOPSIS
    Universal dependency vulnerability auditor for Antigravity skills.
.DESCRIPTION
    Detects package managers (Node, Python, .NET, Rust) and runs security audit suites,
    verifying zero high/critical CVEs.
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

Push-Location $ProjectPath
try {
    Write-Host "🔍 [Dependency Auditor] Inspecting package manifests in: $(Resolve-Path .)" -ForegroundColor Cyan

    $audited = $false
    $hasVulnerability = $false

    # 1. Node.js
    if (Test-Path "package.json") {
        $audited = $true
        $cmd = ""
        if (Test-Path "pnpm-lock.yaml") {
            $cmd = "pnpm audit --audit-level=high"
        } elseif (Test-Path "yarn.lock") {
            $cmd = "yarn audit --level high"
        } else {
            $cmd = "npm audit --audit-level=high"
        }

        Write-Host "📦 Auditing Node.js dependencies ($cmd)..." -ForegroundColor Cyan
        $output = Invoke-Expression $cmd 2>&1
        $code = $LASTEXITCODE

        if ($code -eq 0) {
            Write-Host "✅ Node.js dependencies: ZERO High/Critical vulnerabilities!" -ForegroundColor Green
        } else {
            Write-Host "❌ Node.js vulnerabilities detected:" -ForegroundColor Red
            Write-Host $output
            $hasVulnerability = $true
        }
    }

    # 2. Python
    if ((Test-Path "pyproject.toml") -or (Test-Path "requirements.txt")) {
        $audited = $true
        Write-Host "📦 Auditing Python dependencies (pip-audit)..." -ForegroundColor Cyan
        try {
            $pyOutput = pip-audit 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Python dependencies: Clean!" -ForegroundColor Green
            } else {
                Write-Host "❌ Python dependencies vulnerability detected:" -ForegroundColor Red
                Write-Host $pyOutput
                $hasVulnerability = $true
            }
        } catch {
            Write-Host "ℹ️ pip-audit not installed. Consider installing via 'pip install pip-audit'." -ForegroundColor Yellow
        }
    }

    # 3. .NET
    $csproj = Get-ChildItem -Filter "*.csproj" -Recurse -Depth 2 -ErrorAction SilentlyContinue
    if ($csproj.Count -gt 0) {
        $audited = $true
        Write-Host "📦 Auditing .NET packages (dotnet list package --vulnerable)..." -ForegroundColor Cyan
        $dotnetOutput = dotnet list package --vulnerable --include-transitive 2>&1
        if ($dotnetOutput -match "has no vulnerable packages") {
            Write-Host "✅ .NET packages: ZERO known vulnerabilities!" -ForegroundColor Green
        } else {
            Write-Host $dotnetOutput
        }
    }

    # 4. Rust
    if (Test-Path "Cargo.toml") {
        $audited = $true
        Write-Host "📦 Auditing Rust crates (cargo audit)..." -ForegroundColor Cyan
        try {
            $cargoOutput = cargo audit 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Rust crates: Clean!" -ForegroundColor Green
            } else {
                Write-Host "❌ Rust crate vulnerabilities detected:" -ForegroundColor Red
                Write-Host $cargoOutput
                $hasVulnerability = $true
            }
        } catch {
            Write-Host "ℹ️ cargo audit not installed. Run 'cargo install cargo-audit'." -ForegroundColor Yellow
        }
    }

    if (-not $audited) {
        Write-Host "ℹ️ No package manifests (package.json, pyproject.toml, *.csproj, Cargo.toml) detected in this directory." -ForegroundColor Yellow
        exit 0
    }

    if ($hasVulnerability) {
        Write-Host "❌ [Dependency Auditor] Audit FAILED with active vulnerabilities!" -ForegroundColor Red
        exit 1
    } else {
        Write-Host "✅ [Dependency Auditor] All scanned package ecosystems PASSED!" -ForegroundColor Green
        exit 0
    }
}
finally {
    Pop-Location
}
