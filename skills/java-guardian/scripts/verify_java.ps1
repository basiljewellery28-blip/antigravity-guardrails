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

    $cmd = ""
    if (Test-Path "mvnw.cmd") {
        Write-Host "📦 Detected Maven Wrapper (mvnw)" -ForegroundColor Green
        $cmd = ".\mvnw.cmd test"
    } elseif (Test-Path "pom.xml") {
        Write-Host "📦 Detected Maven (pom.xml)" -ForegroundColor Green
        $cmd = "mvn test"
    } elseif (Test-Path "gradlew.bat") {
        Write-Host "📦 Detected Gradle Wrapper (gradlew)" -ForegroundColor Green
        $cmd = ".\gradlew.bat test"
    } elseif (Test-Path "build.gradle" -or (Test-Path "build.gradle.kts")) {
        Write-Host "📦 Detected Gradle (build.gradle)" -ForegroundColor Green
        $cmd = "gradle test"
    } else {
        Write-Host "❌ No pom.xml or build.gradle located in project root." -ForegroundColor Red
        exit 1
    }

    Write-Host "🚀 Executing build & test command: $cmd" -ForegroundColor Cyan
    $output = Invoke-Expression $cmd 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        Write-Host "✅ [Java Guardian] Build & tests passed with ZERO errors!" -ForegroundColor Green
        Write-Host $output
        exit 0
    } else {
        Write-Host "❌ [Java Guardian] Execution failed with exit code $exitCode:" -ForegroundColor Red
        Write-Host $output
        exit $exitCode
    }
}
finally {
    Pop-Location
}

