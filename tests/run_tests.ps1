<#
.SYNOPSIS
    Regression tests for the verification gates: a gate that could not verify anything must not pass.
.DESCRIPTION
    Each case runs a gate as its own process, under the same PowerShell that runs this file,
    against a throwaway fixture, and asserts on the exit code. Run under both Windows PowerShell 5.1
    and pwsh 7 to cover both hosts.
#>
$ErrorActionPreference = "Stop"

$repo = Split-Path -Parent $PSScriptRoot
# Not the process path: a dotnet-tool pwsh reports dotnet.exe, which can't run -File.
if ($PSVersionTable.PSEdition -eq "Desktop") {
    $psHost = Join-Path $PSHOME "powershell.exe"
} else {
    $psHost = (Get-Command pwsh -CommandType Application | Select-Object -First 1).Source
}
$failures = 0
$fixtures = New-Object System.Collections.Generic.List[string]

function New-Fixture {
    $dir = Join-Path ([System.IO.Path]::GetTempPath()) ("gate-test-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $dir | Out-Null
    $fixtures.Add($dir)
    return $dir
}

# Runs a gate script in a fresh process with $WorkDir as its cwd.
function Invoke-Gate([string]$Script, [string]$WorkDir, [string[]]$GateArgs = @()) {
    # Continue: under Stop, 5.1 would turn a gate's stderr line into a runner crash instead of a result.
    $ErrorActionPreference = "Continue"
    Push-Location $WorkDir
    try {
        $output = & $psHost -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo $Script) @GateArgs 2>&1 | Out-String
        return [PSCustomObject]@{ ExitCode = $LASTEXITCODE; Output = $output }
    } finally {
        Pop-Location
    }
}

# The message check proves the gate itself refused; a crash or a bad launch also exits non-zero.
function Assert-GateFailure([string]$Name, $Result, [string]$ExpectedMessage) {
    if ($Result.ExitCode -ne 0 -and $Result.Output -match $ExpectedMessage) {
        Write-Host "PASS  $Name (exit $($Result.ExitCode))"
    } else {
        Write-Host "FAIL  $Name (exit $($Result.ExitCode); expected non-zero with /$ExpectedMessage/)"
        Write-Host ($Result.Output.Trim() -replace '(?m)^', '      ')
        $script:failures++
    }
}

Write-Host "Running gate tests under $psHost"

$dir = New-Fixture
# Stop git searching upward, in case the temp folder itself sits inside some repository.
$env:GIT_CEILING_DIRECTORIES = Split-Path $dir
try {
    Assert-GateFailure "surgical diff gate outside a git repo" `
        (Invoke-Gate "skills/karpathy-surgical-coder/scripts/verify_surgical_diff.ps1" $dir) `
        "Not a git repository"
} finally {
    Remove-Item Env:GIT_CEILING_DIRECTORIES
}

$dir = New-Fixture
Assert-GateFailure "API surface gate with no route files" `
    (Invoke-Gate "skills/api-interface-design/scripts/verify_api_surface.ps1" $dir @("-ProjectPath", $dir)) `
    "No API/route files detected"

# A stand-in python, first on PATH, that has no mypy but whose tests "pass": only the mypy path decides.
$dir = New-Fixture
$bin = New-Item -ItemType Directory -Path (Join-Path $dir "bin")
if ([System.IO.Path]::DirectorySeparatorChar -eq '\') {
    Set-Content -Path (Join-Path $bin "python.cmd") -Encoding Ascii -Value @(
        '@echo off'
        'if "%2"=="mypy" (echo No module named mypy 1>&2 & exit /b 1)'
        'exit /b 0')
} else {
    $fake = Join-Path $bin "python"
    Set-Content -Path $fake -Encoding Ascii -Value @(
        '#!/bin/sh'
        'if [ "$2" = mypy ]; then echo "No module named mypy" >&2; exit 1; fi'
        'exit 0')
    chmod +x $fake
}
$savedPath = $env:PATH
$env:PATH = "$bin$([System.IO.Path]::PathSeparator)$savedPath"
try {
    Assert-GateFailure "python gate with mypy not installed" `
        (Invoke-Gate "skills/python-guardian/scripts/verify_py.ps1" $dir @("-ProjectPath", $dir)) `
        "mypy not installed"
} finally {
    $env:PATH = $savedPath
}

# The hook is POSIX sh. On Windows use Git's own sh: a bare "bash" there can resolve to WSL.
if ([System.IO.Path]::DirectorySeparatorChar -eq '\') {
    # git.exe may live in Git\cmd or Git\mingw64\bin depending on PATH; walk up to the Git root.
    $sh = $null
    $dirUp = Split-Path (Get-Command git -CommandType Application | Select-Object -First 1).Source
    while ($dirUp -and -not $sh) {
        $sh = @("bin\sh.exe", "usr\bin\sh.exe") | ForEach-Object { Join-Path $dirUp $_ } |
            Where-Object { Test-Path $_ } | Select-Object -First 1
        $dirUp = Split-Path $dirUp
    }
    if (-not $sh) { throw "Git's sh.exe not found; it is needed to run the pre-commit hook tests." }
} else {
    # Absolute path: one test empties PATH before calling it.
    $sh = (Get-Command sh -CommandType Application | Select-Object -First 1).Source
}

# Runs the pre-commit hook from an empty project with an empty home, so no scanner can be found.
function Invoke-Hook([string]$PathOverride) {
    $ErrorActionPreference = "Continue"
    $dir = New-Fixture
    $saved = @{ PATH = $env:PATH; HOME = $env:HOME; USERPROFILE = $env:USERPROFILE }
    $env:HOME = $dir; $env:USERPROFILE = $dir
    if ($PathOverride) { $env:PATH = $PathOverride }
    Push-Location $dir
    try {
        $output = & $sh (Join-Path $repo "scripts/git-hooks/pre-commit") 2>&1 | Out-String
        return [PSCustomObject]@{ ExitCode = $LASTEXITCODE; Output = $output }
    } finally {
        Pop-Location
        $env:PATH = $saved.PATH; $env:HOME = $saved.HOME; $env:USERPROFILE = $saved.USERPROFILE
    }
}

Assert-GateFailure "pre-commit hook with no scanner scripts installed" (Invoke-Hook) "No scanner scripts found"
# An empty directory as PATH: neither pwsh nor powershell can be found.
Assert-GateFailure "pre-commit hook without PowerShell" (Invoke-Hook (New-Fixture)) "PowerShell not located"

foreach ($f in $fixtures) { Remove-Item -LiteralPath $f -Recurse -Force -ErrorAction SilentlyContinue }

if ($failures -gt 0) {
    Write-Host "$failures test(s) failed."
    exit 1
}
Write-Host "All tests passed."
exit 0
