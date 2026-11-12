<#
.SYNOPSIS
    Automated Java verification script for Antigravity skills.
.DESCRIPTION
    Detects Maven (mvnw/mvn) or Gradle (gradlew/gradle) and executes compile and test suites.
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

Push-Location $ProjectPath
try {
    Write-Host "🔍 [Java Guardian] Inspecting Java project at: $(Resolve-Path .)" -ForegroundColor Cyan

    $isWin = [System.IO.Path]::DirectorySeparatorChar -eq '\'
    $mvnw = if ($isWin) { "mvnw.cmd" } else { "mvnw" }
    $gradlew = if ($isWin) { "gradlew.bat" } else { "gradlew" }

    $exe = ""
    if (Test-Path $mvnw) {
        Write-Host "📦 Detected Maven Wrapper (mvnw)" -ForegroundColor Green
        $exe = (Resolve-Path $mvnw).Path
    } elseif (Test-Path "pom.xml") {
        Write-Host "📦 Detected Maven (pom.xml)" -ForegroundColor Green
        $exe = "mvn"
    } elseif (Test-Path $gradlew) {
        Write-Host "📦 Detected Gradle Wrapper (gradlew)" -ForegroundColor Green
        $exe = (Resolve-Path $gradlew).Path
    } elseif ((Test-Path "build.gradle") -or (Test-Path "build.gradle.kts")) {
        Write-Host "📦 Detected Gradle (build.gradle)" -ForegroundColor Green
        $exe = "gradle"
    } else {
        Write-Host "❌ No pom.xml or build.gradle located in project root." -ForegroundColor Red
        exit 1
    }

    if (-not (Get-Command $exe -ErrorAction SilentlyContinue)) {
        Write-Host "❌ '$exe' not found on PATH. Install it or add a build wrapper." -ForegroundColor Red
        exit 1
    }

    Write-Host "🚀 Executing build & test command: $exe test" -ForegroundColor Cyan
    # Continue: under Stop, Windows PowerShell 5.1 throws on any native stderr line.
    $ErrorActionPreference = "Continue"
    $output = & $exe test 2>&1
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = "Stop"

    # Maven exits 0 with "No tests to run." — a pass that verified nothing.
    if ($exitCode -eq 0 -and $exe -notmatch 'gradle' -and -not ($output -match 'Tests run: [1-9]')) {
        Write-Host "❌ [Java Guardian] Build succeeded but no tests were executed. Add tests before claiming the work is verified." -ForegroundColor Red
        $output | ForEach-Object { "$_" } | Write-Host
        exit 1
    }

    if ($exitCode -eq 0) {
        Write-Host "✅ [Java Guardian] Build & tests passed with ZERO errors!" -ForegroundColor Green
        $output | ForEach-Object { "$_" } | Write-Host
        exit 0
    } else {
        Write-Host "❌ [Java Guardian] Execution failed with exit code ${exitCode}:" -ForegroundColor Red
        $output | ForEach-Object { "$_" } | Write-Host
        exit $exitCode
    }
}
finally {
    Pop-Location
}

