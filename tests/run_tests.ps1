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
# $ForbiddenMessage catches a right verdict for a wrong reason, e.g. flagging an excluded folder.
function Assert-GateFailure([string]$Name, $Result, [string]$ExpectedMessage, [string]$ForbiddenMessage = "") {
    if ($Result.ExitCode -ne 0 -and $Result.Output -match $ExpectedMessage -and
        -not ($ForbiddenMessage -and $Result.Output -match $ForbiddenMessage)) {
        Write-Host "PASS  $Name (exit $($Result.ExitCode))"
    } else {
        $why = "expected non-zero with /$ExpectedMessage/"
        if ($ForbiddenMessage) { $why += " and without /$ForbiddenMessage/" }
        Write-Host "FAIL  $Name (exit $($Result.ExitCode); $why)"
        Write-Host ($Result.Output.Trim() -replace '(?m)^', '      ')
        $script:failures++
    }
}

# Guards against false positives: a clean fixture must pass.
function Assert-GatePass([string]$Name, $Result) {
    if ($Result.ExitCode -eq 0) {
        Write-Host "PASS  $Name (exit 0)"
    } else {
        Write-Host "FAIL  $Name (exit $($Result.ExitCode); expected 0 on a clean fixture)"
        Write-Host ($Result.Output.Trim() -replace '(?m)^', '      ')
        $script:failures++
    }
}

function Write-FixtureFile([string]$Path, [string]$Content) {
    New-Item -ItemType Directory -Force -Path (Split-Path $Path) | Out-Null
    [System.IO.File]::WriteAllText($Path, $Content)
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

# The hook is POSIX sh and the .sh twins need bash. On Windows use Git's own: a bare "bash" there
# can resolve to WSL.
if ([System.IO.Path]::DirectorySeparatorChar -eq '\') {
    # git.exe may live in Git\cmd or Git\mingw64\bin depending on PATH; walk up to the Git root.
    $gitRoot = Split-Path (Get-Command git -CommandType Application | Select-Object -First 1).Source
    while ($gitRoot -and -not (Test-Path (Join-Path $gitRoot "bin\bash.exe"))) { $gitRoot = Split-Path $gitRoot }
    if (-not $gitRoot) { throw "Git's bin\bash.exe not found; it is needed for the hook and .sh tests." }
    $sh = Join-Path $gitRoot "bin\sh.exe"
    $bash = Join-Path $gitRoot "bin\bash.exe"
} else {
    # Absolute paths: one test empties PATH before calling sh.
    $sh = (Get-Command sh -CommandType Application | Select-Object -First 1).Source
    $bash = (Get-Command bash -CommandType Application | Select-Object -First 1).Source
}

# Runs a bash twin of a gate with $WorkDir as its cwd.
function Invoke-BashGate([string]$Script, [string]$WorkDir, [string[]]$GateArgs = @()) {
    $ErrorActionPreference = "Continue"
    Push-Location $WorkDir
    try {
        $output = & $bash (Join-Path $repo $Script) @GateArgs 2>&1 | Out-String
        return [PSCustomObject]@{ ExitCode = $LASTEXITCODE; Output = $output }
    } finally {
        Pop-Location
    }
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

# --- Scanner detection ---------------------------------------------------------------------------
# Fake credentials are assembled here so this file never contains a token the scanner would flag.
$awsTail = "Z7Q2M4X9W1R8T3Y6"
$awsKey = "AKIA" + $awsTail
$ghToken = "ghp_" + ("Ab3dE6" * 6)

# "cabinet" contains "bin": the old substring exclusion skipped every file under such a path.
$proj = Join-Path (New-Fixture) "cabinet-app"
Write-FixtureFile (Join-Path $proj "src/keys.ts") "export const awsKey = `"$awsKey`";`n"
Write-FixtureFile (Join-Path $proj "node_modules/dep/index.js") "module.exports = `"$ghToken`";`n"
Write-FixtureFile (Join-Path $proj "src/clean.ts") "export const greeting = 'hello';`n"
Assert-GateFailure "secret scanner finds a key under a 'cabinet' path, skips node_modules, redacts it" `
    (Invoke-Gate "skills/security-secret-sentinel/scripts/scan_secrets.ps1" $proj @("-ProjectPath", $proj)) `
    "keys\.ts" "node_modules|$awsTail"

$proj = New-Fixture
Write-FixtureFile (Join-Path $proj "src/clean.ts") "export const greeting = 'hello';`n"
Assert-GatePass "secret scanner passes a clean project" `
    (Invoke-Gate "skills/security-secret-sentinel/scripts/scan_secrets.ps1" $proj @("-ProjectPath", $proj))

# Each clean line resembles a rule but is safe: regex .exec, a method named eval, a comparison, localhost.
$cleanJs = "const m = /a(b)/.exec(text);`nmodel.eval();`nif (el.innerHTML === '') {}`nconst url = 'http://localhost:3000/x';`n"
$proj = Join-Path (New-Fixture) "cabinet-app"
Write-FixtureFile (Join-Path $proj "src/danger.js") "eval(userInput);`n"
Write-FixtureFile (Join-Path $proj "src/clean.js") $cleanJs
Assert-GateFailure "SAST scanner flags eval() and not the look-alikes" `
    (Invoke-Gate "skills/owasp-secure-coding/scripts/verify_sast_patterns.ps1" $proj @("-ProjectPath", $proj)) `
    "danger\.js" "clean\.js"

$proj = New-Fixture
Write-FixtureFile (Join-Path $proj "src/clean.js") $cleanJs
Assert-GatePass "SAST scanner passes look-alike code" `
    (Invoke-Gate "skills/owasp-secure-coding/scripts/verify_sast_patterns.ps1" $proj @("-ProjectPath", $proj))

# --- .ps1 / .sh parity: both twins must reach the same verdict on the same fixture -----------------
$slopDir = New-Fixture
Write-FixtureFile (Join-Path $slopDir "src/slop.ts") "try { run(); } catch (e) {}`n"
Write-FixtureFile (Join-Path $slopDir "src/clean.ts") "export const todo: Todo[] = [];`n"
$cleanDir = New-Fixture
Write-FixtureFile (Join-Path $cleanDir "src/clean.ts") "export const todo: Todo[] = [];`n"
$deslop = "skills/deslop-codebase/scripts/verify_codebase_slop"
Assert-GateFailure "deslop .ps1 flags an empty catch" (Invoke-Gate "$deslop.ps1" $slopDir @("-TargetDirectory", $slopDir)) `
    "slop\.ts" "clean\.ts"
Assert-GateFailure "deslop .sh flags an empty catch" (Invoke-BashGate "$deslop.sh" $slopDir @(".")) "empty catch blocks: 1"
Assert-GatePass "deslop .ps1 passes clean code" (Invoke-Gate "$deslop.ps1" $cleanDir @("-TargetDirectory", $cleanDir))
Assert-GatePass "deslop .sh passes clean code" (Invoke-BashGate "$deslop.sh" $cleanDir @("."))

function New-RepoWithCommit([string]$Message) {
    $dir = New-Fixture
    git -C $dir init -q
    git -C $dir -c user.name=test -c user.email=test@example.invalid commit -q --allow-empty -m $Message
    return $dir
}
$badRepo = New-RepoWithCommit "bad message here"
$goodRepo = New-RepoWithCommit "feat: add greeting"
$hygiene = "skills/git-workflow-and-versioning/scripts/verify_git_hygiene"
Assert-GateFailure "git hygiene .ps1 rejects a non-conventional commit" (Invoke-Gate "$hygiene.ps1" $badRepo) "bad message here"
Assert-GateFailure "git hygiene .sh rejects a non-conventional commit" (Invoke-BashGate "$hygiene.sh" $badRepo) "bad message here"
Assert-GatePass "git hygiene .ps1 accepts a conventional commit" (Invoke-Gate "$hygiene.ps1" $goodRepo)
Assert-GatePass "git hygiene .sh accepts a conventional commit" (Invoke-BashGate "$hygiene.sh" $goodRepo)

$bigLogDir = New-Fixture
[System.IO.File]::WriteAllBytes((Join-Path $bigLogDir "runaway.log"), (New-Object byte[] (2MB)))
$smallLogDir = New-Fixture
Write-FixtureFile (Join-Path $smallLogDir "app.log") "started`n"
$breaker = "skills/runaway-stopper/scripts/check_circuit_breaker"
Assert-GateFailure "circuit breaker .ps1 trips on a 2MB log over a 1MB limit" `
    (Invoke-Gate "$breaker.ps1" $bigLogDir @("-TargetDirectory", $bigLogDir, "-MaxLogSizeMb", "1")) "runaway\.log"
Assert-GateFailure "circuit breaker .sh trips on a 2MB log over a 1MB limit" `
    (Invoke-BashGate "$breaker.sh" $bigLogDir @(".", "1")) "runaway\.log"
Assert-GatePass "circuit breaker .ps1 passes small logs" `
    (Invoke-Gate "$breaker.ps1" $smallLogDir @("-TargetDirectory", $smallLogDir, "-MaxLogSizeMb", "1"))
Assert-GatePass "circuit breaker .sh passes small logs" (Invoke-BashGate "$breaker.sh" $smallLogDir @(".", "1"))

foreach ($f in $fixtures) { Remove-Item -LiteralPath $f -Recurse -Force -ErrorAction SilentlyContinue }

if ($failures -gt 0) {
    Write-Host "$failures test(s) failed."
    exit 1
}
Write-Host "All tests passed."
exit 0
