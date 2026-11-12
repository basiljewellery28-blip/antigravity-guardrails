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
# Windows PowerShell 5.1 turns any native stderr output into a terminating error under "Stop"
# (even with 2>&1), which would abort the audit or be mistaken for "tool not installed".
$ErrorActionPreference = "Continue"
try {
    Write-Host "🔍 [Dependency Auditor] Inspecting package manifests in: $(Resolve-Path .)" -ForegroundColor Cyan

    $audited = $false
    $hasVulnerability = $false

    # 1. Node.js
    if (Test-Path "package.json") {
        $audited = $true
        if (Test-Path "pnpm-lock.yaml") {
            $tool = "pnpm"; $toolArgs = @("audit", "--audit-level=high")
        } elseif (Test-Path "yarn.lock") {
            $tool = "yarn"; $toolArgs = @("audit", "--level", "high")
        } else {
            $tool = "npm"; $toolArgs = @("audit", "--audit-level=high")
        }

        Write-Host "📦 Auditing Node.js dependencies ($tool $($toolArgs -join ' '))..." -ForegroundColor Cyan
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            # A gate that could not run must not pass.
            Write-Host "❌ $tool not found in PATH; Node.js dependencies were NOT audited." -ForegroundColor Red
            $hasVulnerability = $true
        } else {
            $output = & $tool @toolArgs 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Node.js dependencies: ZERO High/Critical vulnerabilities!" -ForegroundColor Green
            } else {
                Write-Host "❌ Node.js vulnerabilities detected:" -ForegroundColor Red
                Write-Host ($output | Out-String)
                $hasVulnerability = $true
            }
        }
    }

    # 2. Python
    if ((Test-Path "pyproject.toml") -or (Test-Path "requirements.txt")) {
        $audited = $true
        Write-Host "📦 Auditing Python dependencies (pip-audit)..." -ForegroundColor Cyan
        if (-not (Get-Command pip-audit -ErrorAction SilentlyContinue)) {
            Write-Host "❌ pip-audit not installed; Python dependencies were NOT audited. Install via 'pip install pip-audit'." -ForegroundColor Red
            $hasVulnerability = $true
        } else {
            # Bare pip-audit audits the active environment, not the project's manifest.
            if (Test-Path "requirements.txt") { $pyArgs = @("-r", "requirements.txt") } else { $pyArgs = @(".") }
            $pyOutput = & pip-audit @pyArgs 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Python dependencies: Clean!" -ForegroundColor Green
            } else {
                Write-Host "❌ Python dependencies vulnerability detected:" -ForegroundColor Red
                Write-Host ($pyOutput | Out-String)
                $hasVulnerability = $true
            }
        }
    }

    # 3. .NET
    $csproj = @(Get-ChildItem -Filter "*.csproj" -Recurse -Depth 2 -ErrorAction SilentlyContinue)
    if ($csproj.Count -gt 0) {
        $audited = $true
        Write-Host "📦 Auditing .NET packages (dotnet list package --vulnerable)..." -ForegroundColor Cyan
        if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
            Write-Host "❌ dotnet not found in PATH; .NET packages were NOT audited." -ForegroundColor Red
            $hasVulnerability = $true
        } else {
            # dotnet exits 0 even when vulnerable packages exist, so the report text decides.
            # Targeting each project also works when the .csproj is not in the current directory.
            foreach ($proj in $csproj) {
                $dotnetOutput = (& dotnet list $proj.FullName package --vulnerable --include-transitive 2>&1 | Out-String)
                if ($LASTEXITCODE -ne 0) {
                    Write-Host "❌ $($proj.Name): dotnet could not complete the audit (restore the project first):" -ForegroundColor Red
                    Write-Host $dotnetOutput
                    $hasVulnerability = $true
                } elseif ($dotnetOutput -match '(?m)^\s*>.*\b(High|Critical)\b') {
                    Write-Host "❌ $($proj.Name): High/Critical vulnerable packages:" -ForegroundColor Red
                    Write-Host $dotnetOutput
                    $hasVulnerability = $true
                } else {
                    Write-Host "✅ $($proj.Name): ZERO High/Critical known vulnerabilities!" -ForegroundColor Green
                }
            }
        }
    }

    # 4. Rust
    if (Test-Path "Cargo.toml") {
        $audited = $true
        Write-Host "📦 Auditing Rust crates (cargo audit)..." -ForegroundColor Cyan
        $haveCargoAudit = $false
        if (Get-Command cargo -ErrorAction SilentlyContinue) {
            $null = & cargo audit --version 2>&1
            $haveCargoAudit = ($LASTEXITCODE -eq 0)
        }
        if (-not $haveCargoAudit) {
            Write-Host "❌ cargo-audit not installed; Rust crates were NOT audited. Run 'cargo install cargo-audit'." -ForegroundColor Red
            $hasVulnerability = $true
        } else {
            $cargoOutput = & cargo audit 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Rust crates: Clean!" -ForegroundColor Green
            } else {
                Write-Host "❌ Rust crate vulnerabilities detected:" -ForegroundColor Red
                Write-Host ($cargoOutput | Out-String)
                $hasVulnerability = $true
            }
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

