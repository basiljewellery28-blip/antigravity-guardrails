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
    'SQL Injection (String Concatenation)' = '(?:SELECT\s+.+\s+FROM|INSERT\s+INTO|UPDATE\s+\w+\s+SET|DELETE\s+FROM)\b.*(?:["'']\s*\+|\$\{|\{\w|\.format\(|["'']\s+%\s+[\w(])'
    'Dangerous Dynamic Code Execution'     = '(?<![.\w])(?:eval|exec)\s*\(|\bchild_process\.exec\s*\('
    'Raw DOM Injection (XSS Vector)'       = '(\.innerHTML\s*\+?=(?!=)|dangerouslySetInnerHTML)'
    'Obsolete / Weak Hash Function'        = '\b(crypto\.createHash\([''"]md5[''"]\)|hashlib\.md5\b|MD5\.Create\(\)|MessageDigest\.getInstance\([''"]MD5[''"]\)|\bmd5\.(New|Sum)\()'
    'Insecure HTTP URL in Code'            = '\bhttp:\/\/(?!localhost|127\.0\.0\.1|0\.0\.0\.0|www\.w3\.org|schemas\.openxmlformats\.org|schemas\.microsoft\.com|schemas\.xmlsoap\.org|openoffice\.org|purl\.org|json-schema\.org)[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
}

$sourceExtensions = @("*.ts", "*.tsx", "*.js", "*.jsx", "*.py", "*.cs", "*.java", "*.go", "*.rs")
$violations = @()
$root = (Resolve-Path $ProjectPath).Path

# Match whole path segments below the scan root, so a parent folder like "cabinet" cannot hide files
# and a repo under e.g. /work/bin/ is still scanned.
$files = Get-ChildItem -Path $root -Include $sourceExtensions -Recurse -File |
    Where-Object { $_.FullName.Substring($root.Length) -notmatch '(^|[\\/])(node_modules|\.git|obj|bin|dist|vendor|research)[\\/]' }

foreach ($file in $files) {
    $lines = [System.IO.File]::ReadAllLines($file.FullName)
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]

        # Ignore comments and docs
        if ($line.Trim().StartsWith("//") -or $line.Trim().StartsWith("#") -or $line.Trim().StartsWith("*") -or $line.Trim().StartsWith("/*")) {
            continue
        }

        foreach ($ruleName in $sastRules.Keys) {
            $pattern = $sastRules[$ruleName]
            if ($line -match $pattern) {
                $violations += [PSCustomObject]@{
                    File    = $file.FullName.Substring($root.Length).TrimStart('\', '/')
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
