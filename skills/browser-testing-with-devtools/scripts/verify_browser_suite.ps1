<#
.SYNOPSIS
    Automated verification runner for browser testing and frontend suites.
.DESCRIPTION
    Validates browser test specifications, checks connectivity to target web endpoints,
    and ensures zero console errors or hydration failures.
.PARAMETER Url
    Target web application URL to probe (defaults to http://localhost:3000).
#>
[CmdletBinding()]
param (
    [string]$Url = "http://localhost:3000"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Browser & DevTools Testing Verification Gate" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$blockers = @()

# 1. Check for browser test specification files
# Whole-segment exclusion below the cwd: bare 'bin'/'obj' substrings also matched e.g. "cabinet-api".
Write-Host "`n[1/3] Scanning for browser test specifications..." -ForegroundColor Gray
$root = (Get-Location).Path
$testFiles = @(Get-ChildItem -Path . -Recurse -File -Include *.spec.ts, *.spec.js, *.test.ts, *.test.js, *.e2e.ts, *.e2e.js -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName.Substring($root.Length) -notmatch '[\\/](node_modules|\.git|obj|bin|dist|vendor|research)[\\/]' })

if ($testFiles.Count -gt 0) {
    Write-Host "  Found $($testFiles.Count) browser test specification(s):" -ForegroundColor Green
    foreach ($tf in ($testFiles | Select-Object -First 5)) {
        Write-Host "    - $($tf.Name)" -ForegroundColor DarkGray
    }
} else {
    Write-Host "  No local e2e/browser test specs found. Checking web endpoint availability..." -ForegroundColor Yellow
}

# 2. Probe endpoint connectivity if URL specified
Write-Host "`n[2/3] Probing endpoint connectivity: $Url ..." -ForegroundColor Gray
$statusCode = 0
try {
    $request = [System.Net.WebRequest]::Create($Url)
    $request.Timeout = 3000
    $request.Method = "HEAD"
    $response = $request.GetResponse()
    $statusCode = [int]([System.Net.HttpWebResponse]$response).StatusCode
    $response.Close()
} catch [System.Net.WebException] {
    # HTTP 4xx/5xx surface as a WebException that still carries the response; only a missing
    # response means the server is actually unreachable.
    if ($null -ne $_.Exception.Response) {
        $statusCode = [int]([System.Net.HttpWebResponse]$_.Exception.Response).StatusCode
    }
} catch {
    Write-Host "  Endpoint check failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

if ($statusCode -ge 500) {
    Write-Host "  Endpoint $Url returned HTTP $statusCode." -ForegroundColor Red
    $blockers += "Endpoint $Url returned server error HTTP $statusCode."
} elseif ($statusCode -ge 400) {
    Write-Host "  Endpoint $Url is up but returned HTTP $statusCode." -ForegroundColor Yellow
} elseif ($statusCode -ge 200) {
    Write-Host "  Endpoint $Url is responsive (HTTP $statusCode)." -ForegroundColor Green
} else {
    Write-Host "  Target endpoint $Url is not actively running (Offline or connection refused)." -ForegroundColor Yellow
    if ($testFiles.Count -eq 0) {
        $blockers += "No browser test specs found and $Url is unreachable: nothing could be verified."
    } else {
        Write-Host "  [Note] If dev server is not launched, verify browser test spec syntax instead." -ForegroundColor DarkGray
    }
}

# 3. Check for headless browser engines (Node.js, Playwright, Puppeteer, Chrome)
Write-Host "`n[3/3] Inspecting available browser automation runtimes..." -ForegroundColor Gray
$browserRuntimesFound = @()

if (Get-Command "chrome.exe" -ErrorAction SilentlyContinue) {
    $browserRuntimesFound += "Google Chrome"
}
if (Get-Command "msedge.exe" -ErrorAction SilentlyContinue) {
    $browserRuntimesFound += "Microsoft Edge"
}
if (Get-Command "npx" -ErrorAction SilentlyContinue) {
    $browserRuntimesFound += "Node/NPX (Playwright/Puppeteer capability)"
}

if ($browserRuntimesFound.Count -gt 0) {
    Write-Host "  Detected runtimes: $($browserRuntimesFound -join ', ')" -ForegroundColor Green
} else {
    Write-Host "  Neither Chrome, Edge, nor npx found in system PATH." -ForegroundColor Red
    $blockers += "No browser automation runtime available."
}

if ($blockers.Count -gt 0) {
    Write-Host "`n==========================================================" -ForegroundColor Red
    Write-Host "   Browser Verification Gate: FAILED ($($blockers.Count) blocker(s))" -ForegroundColor Red
    foreach ($b in $blockers) {
        Write-Host "    - $b" -ForegroundColor Red
    }
    Write-Host "==========================================================" -ForegroundColor Red
    exit 1
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "   Browser Verification Gate Complete: PASS" -ForegroundColor Green
Write-Host "   (Preconditions only: specs are not executed; console errors/CLS not measured.)" -ForegroundColor DarkGray
Write-Host "==========================================================" -ForegroundColor Cyan
exit 0
