<#
.SYNOPSIS
    Automated C# (.NET) verification script for Antigravity skills.
.DESCRIPTION
    Runs dotnet build with warnings treated as errors and executes all xUnit/NUnit/MSTest suites.
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

Push-Location $ProjectPath
try {
    Write-Host "🔍 [C# Guardian] Inspecting .NET project at: $(Resolve-Path .)" -ForegroundColor Cyan

    # Locate solution or project
    $targets = Get-ChildItem -Filter "*.sln" -Recurse -Depth 2 -ErrorAction SilentlyContinue
    if ($targets.Count -eq 0) {
        $targets = Get-ChildItem -Filter "*.csproj" -Recurse -Depth 2 -ErrorAction SilentlyContinue
    }

    if ($targets.Count -eq 0) {
        Write-Host "❌ No .sln or .csproj found in directory." -ForegroundColor Red
        exit 1
    }

    if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
        Write-Host "❌ 'dotnet' not found on PATH. Cannot verify." -ForegroundColor Red
        exit 1
    }

    $targetFile = $targets[0].FullName
    Write-Host "🎯 Target solution/project: $targetFile" -ForegroundColor Green

    # Continue: under Stop, Windows PowerShell 5.1 throws on any native stderr line.
    $ErrorActionPreference = "Continue"

    # Step 1: Build with WarnAsError
    Write-Host "🔨 Compiling with dotnet build --warnaserror..." -ForegroundColor Cyan
    $buildOutput = dotnet build $targetFile --warnaserror 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Build failed:" -ForegroundColor Red
        $buildOutput | ForEach-Object { "$_" } | Write-Host
        exit $LASTEXITCODE
    }
    Write-Host "✅ Build succeeded with ZERO warnings!" -ForegroundColor Green

    # Step 2: Test Execution
    Write-Host "🧪 Running dotnet test..." -ForegroundColor Cyan
    $testOutput = dotnet test $targetFile --no-build --logger "console;verbosity=normal" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Test run failed:" -ForegroundColor Red
        $testOutput | ForEach-Object { "$_" } | Write-Host
        exit $LASTEXITCODE
    }

    Write-Host "✅ All tests passed cleanly!" -ForegroundColor Green
    $testOutput | ForEach-Object { "$_" } | Write-Host
    exit 0
}
finally {
    Pop-Location
}

