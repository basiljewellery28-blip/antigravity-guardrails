<#
.SYNOPSIS
    Static Application Security Testing (SAST) pattern checker for Antigravity.
.DESCRIPTION
    Scans project source files for common OWASP Top 10 vulnerabilities like
    SQL injection string concatenation, eval/exec execution, raw innerHTML assignments,
    and weak cryptographic hash functions.
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

Write-Host "🔍 [OWASP Sentinel] Scanning codebase for insecure code patterns..." -ForegroundColor Cyan

$sastRules = @{
    'SQL Injection (String Concatenation)' = '(SELECT|INSERT|UPDATE|DELETE)\s+.*\s*(\+|`.*?\$\{)'
    'Dangerous Dynamic Code Execution'     = '\b(eval|exec)\s*\('
    'Raw DOM Injection (XSS Vector)'       = '(\.innerHTML\s*=|dangerouslySetInnerHTML)'
    'Obsolete / Weak Hash Function'        = '\b(crypto\.createHash\([''"]md5[''"]\)|hashlib\.md5\b|MD5\.Create\(\))'
    'Insecure HTTP URL in Code'            = '\bhttp:\/\/(?!localhost|127\.0\.0\.1|0\.0\.0\.0)[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
}

$sourceExtensions = @("*.ts", "*.tsx", "*.js", "*.jsx", "*.py", "*.cs", "*.java", "*.go", "*.rs")
$violations = @()

$files = Get-ChildItem -Path $ProjectPath -Include $sourceExtensions -Recurse -File |
    Where-Object { $_.FullName -notmatch "node_modules|\.git|obj|bin|dist|vendor|research" }

foreach ($file in $files) {
    $lines = [System.IO.File]::ReadAllLines($file.FullName)
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]

        # Ignore comments and docs
        if ($line.Trim().StartsWith("//") -or $line.Trim().StartsWith("#") -or $line.Trim().StartsWith("*")) {
            continue
        }

        foreach ($ruleName in $sastRules.Keys) {
            $pattern = $sastRules[$ruleName]
            if ($line -match $pattern) {
                $violations += [PSCustomObject]@{
                    File    = $file.Name
                    Line    = $i + 1
                    Rule    = $ruleName
                    Snippet = $line.Trim()
                }
            }
        }
    }
}

Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor Cyan
if ($violations.Count -eq 0) {
    Write-Host "✅ [OWASP Sentinel] ZERO insecure code patterns detected!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "❌ [OWASP Sentinel] Found $($violations.Count) potential security risk(s):" -ForegroundColor Red
    foreach ($v in $violations) {
        Write-Host "  ⚠️ $($v.File):$($v.Line) -> [$($v.Rule)]" -ForegroundColor Yellow
        Write-Host "     Code: $($v.Snippet)" -ForegroundColor DarkGray
    }
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    exit 1
}
