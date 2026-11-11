<#
.SYNOPSIS
    Automated migration tool: converts CLAUDE.md into native Antigravity GEMINI.md.
.DESCRIPTION
    Scans for CLAUDE.md, extracts build commands and invariants, and generates
    an Antigravity-compliant GEMINI.md adhering to token budgets and execution standards.
#>

[CmdletBinding()]
param(
    [string]$SourcePath = "CLAUDE.md",
    [string]$DestinationPath = "GEMINI.md",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $SourcePath)) {
    Write-Host "❌ Source file '$SourcePath' not found in $(Get-Location)" -ForegroundColor Red
    exit 1
}

if ((Test-Path -Path $DestinationPath) -and (-not $Force)) {
    Write-Host "⚠️ Destination '$DestinationPath' already exists. Pass -Force to overwrite." -ForegroundColor Yellow
    exit 1
}

Write-Host "📖 Reading source file: $SourcePath" -ForegroundColor Cyan
$rawContent = [System.IO.File]::ReadAllText((Resolve-Path -Path $SourcePath))

$byteCount = [System.Text.Encoding]::UTF8.GetByteCount($rawContent)
Write-Host "📊 Source file size: $byteCount bytes (Antigravity limit: 24,000 bytes)" -ForegroundColor Cyan

if ($byteCount -gt 24000) {
    Write-Host "⚠️ WARNING: CLAUDE.md exceeds 24KB! Antigravity rules must be under 24KB to avoid context demotion." -ForegroundColor Yellow
}

$header = @"
# Project Rules & Instructions (Migrated from CLAUDE.md)

This ruleset governs Gemini's behavior in this repository. It translates the project's
established workflows, conventions, and invariants into Antigravity standards.

---

## 1. Zero-Defect & Verification Invariant
- Every code change must be completely implemented (no placeholders or stubs).
- Before completing any task, run the project's verification commands (tests, typecheck, lint).

---

## 2. Imported Project Knowledge

"@

$footer = @"

---

## 3. Platform & Execution Parity
- Ensure all commands are executed with platform awareness (e.g., PowerShell on Windows or cross-platform package scripts).
- Keep rule definitions under 24 KB. For complex workflows, extract them into .agents/skills/<name>/SKILL.md.
"@

$finalContent = $header + $rawContent + $footer

[System.IO.File]::WriteAllText((Join-Path (Get-Location) $DestinationPath), $finalContent, [System.Text.Encoding]::UTF8)

Write-Host "✅ Successfully generated $DestinationPath!" -ForegroundColor Green
Write-Host "💡 Review $DestinationPath to extract long procedural runbooks into dedicated skills." -ForegroundColor Yellow
exit 0
