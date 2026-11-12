<#
.SYNOPSIS
    Automated secret scanner for Antigravity Security Sentinel.
.DESCRIPTION
    Scans project source files and configuration for leaked API keys, tokens,
    private certificates, and unignored .env files.
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

Write-Host "🔍 [Secret Sentinel] Scanning project for exposed credentials..." -ForegroundColor Cyan

$secretPatterns = @{
    'AWS Access Key ID'       = '\bAKIA[0-9A-Z]{16}\b'
    'GitHub Token'            = '\bgh[pousr]_[0-9a-zA-Z]{36}\b'
    'Google API Key'          = '\bAIza[0-9A-Za-z_-]{35}\b'
    'Generic Private Key'     = '-----BEGIN ((RSA|EC|OPENSSH|PGP|DSA|ENCRYPTED) )?PRIVATE KEY( BLOCK)?-----'
    'Slack Webhook'           = 'https://hooks\.slack\.com/services/T[0-9a-zA-Z_]+/B[0-9a-zA-Z_]+/[0-9a-zA-Z_]+'
    'JWT Token (Bearer/Raw)'  = '\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b'
    'Stripe Secret Key'       = '\bsk_(live|test)_[0-9a-zA-Z]{24,}\b'
}

$findings = @()
$root = (Resolve-Path $ProjectPath).Path

# Check 1: Verify .env in .gitignore
if (Test-Path (Join-Path $root ".env")) {
    $isIgnored = $false
    if (Test-Path (Join-Path $root ".gitignore")) {
        $gitignore = Get-Content (Join-Path $root ".gitignore")
        if ($gitignore -match '^\s*/?\*?\.env\*?\s*$') {
            $isIgnored = $true
        }
    }
    if (-not $isIgnored) {
        $findings += [PSCustomObject]@{
            File    = ".env"
            Line    = 1
            Type    = "CRITICAL: .env file exists on disk but is NOT listed in .gitignore!"
            Snippet = "Untracked .env file"
        }
    }
}

# Check 2: Scan source files
$scanExtensions = @("*.ts", "*.tsx", "*.js", "*.jsx", "*.py", "*.cs", "*.java", "*.go", "*.rs", "*.json", "*.yaml", "*.yml", "*.toml", "*.sh", "*.ps1", ".env", ".env.*", "*.env.example")

# -Force: dotfiles like .env are hidden. Exclusions match whole path segments below the scan root,
# so a parent folder like "cabinet" or ".github" cannot hide files.
$files = Get-ChildItem -Path $root -Include $scanExtensions -Recurse -File -Force |
    Where-Object { $_.FullName.Substring($root.Length) -notmatch '(^|[\\/])(node_modules|\.git|obj|bin|dist|vendor|research)[\\/]' }

foreach ($file in $files) {
    $lines = [System.IO.File]::ReadAllLines($file.FullName)
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]
        
        foreach ($patternName in $secretPatterns.Keys) {
            $regex = $secretPatterns[$patternName]
            # Case-sensitive: key prefixes are. Skip documented dummy tokens (AKIAIOSFODNN7EXAMPLE),
            # judged on the token itself so "example" elsewhere on the line cannot hide a real key.
            if ($line -cmatch $regex -and $Matches[0] -cnotmatch 'EXAMPLE|PLACEHOLDER|REDACTED') {
                $redacted = $line.Replace($Matches[0], "<REDACTED>").Trim()
                $redacted = $redacted.Substring(0, [math]::Min(60, $redacted.Length))
                $findings += [PSCustomObject]@{
                    File    = $file.FullName.Substring($root.Length).TrimStart('\', '/')
                    Line    = $i + 1
                    Type    = $patternName
                    Snippet = $redacted
                }
            }
        }
    }
}

Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor Cyan
if ($findings.Count -eq 0) {
    Write-Host "✅ [Secret Sentinel] ZERO exposed credentials or untracked .env files detected!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "❌ [Secret Sentinel] CRITICAL: Found $($findings.Count) potential secret exposure(s):" -ForegroundColor Red
    foreach ($item in $findings) {
        Write-Host "  ⚠️ $($item.File):$($item.Line) -> [$($item.Type)]" -ForegroundColor Yellow
        Write-Host "     Snippet: $($item.Snippet)" -ForegroundColor DarkGray
    }
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    exit 1
}
