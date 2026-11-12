#!/usr/bin/env bash
# verify_performance.sh - Automated performance budget and anti-pattern verification script
# Usage: verify_performance.sh [MAX_ASSET_SIZE_KB]   (default 512, same as the .ps1 -MaxAssetSizeKb)
set -euo pipefail

MAX_ASSET_SIZE_KB="${1:-512}"

echo "=========================================================="
echo "   Performance Optimization & Budget Gate"
echo "=========================================================="

echo -e "\n[1/3] Inspecting compiled bundle and asset budgets..."
VIOLATIONS=0

for dir in dist build out public/build target; do
    if [ -d "$dir" ]; then
        while IFS= read -r file; do
            [ -z "$file" ] && continue
            size_kb=$(du -k "$file" | cut -f1)
            if [ "$size_kb" -gt "$MAX_ASSET_SIZE_KB" ]; then
                echo "  [FAIL] Asset budget exceeded: $file (${size_kb}KB > ${MAX_ASSET_SIZE_KB}KB)"
                VIOLATIONS=$((VIOLATIONS + 1))
            fi
        done < <(find "$dir" -type f \( -name "*.js" -o -name "*.css" -o -name "*.wasm" \) 2>/dev/null | grep -Ev '/(node_modules|\.git|vendor)/' || true)
    fi
done

echo -e "\n[2/3] Scanning source code for synchronous hot-loop anti-patterns..."
# Same three patterns, file types and exclusions as the .ps1. -Pz lets [^}]* span lines like .NET does.
if ! echo x | grep -P x >/dev/null 2>&1; then
    echo "  Warning: grep -P is unavailable; anti-pattern scan SKIPPED (not verified)."
else
    declare -a PATTERN_NAMES=("Sync I/O in Loop" "N+1 Query in Loop" "Regex Recompilation in Loop")
    declare -a PATTERNS=(
        '(?i)for\s*\(.*\)\s*\{[^}]*fs\.read(?:File)?Sync'
        '(?i)for\s*\(.*\)\s*\{[^}]*(?:SELECT\s+\*|\.findById|\.findOne)'
        '(?i)for\s*\(.*\)\s*\{[^}]*new\s+RegExp\('
    )
    SOURCE_FILES=()
    while IFS= read -r f; do
        SOURCE_FILES+=("$f")
    done < <(find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.cs" \) 2>/dev/null | grep -Ev '/(node_modules|\.git|obj|bin|dist|vendor|research)/' || true)

    FLAGGED=0
    for f in ${SOURCE_FILES[@]+"${SOURCE_FILES[@]}"}; do
        for i in "${!PATTERNS[@]}"; do
            if grep -Pzq "${PATTERNS[$i]}" "$f" 2>/dev/null; then
                echo "  [FAIL] Performance Anti-Pattern (${PATTERN_NAMES[$i]}) detected in: $f"
                FLAGGED=$((FLAGGED + 1))
            fi
        done
    done
    echo "  Scanned ${#SOURCE_FILES[@]} source file(s). Found ${FLAGGED} anti-pattern flag(s)."
    VIOLATIONS=$((VIOLATIONS + FLAGGED))
fi

echo -e "\n[3/3] Evaluating Performance Gate Status..."
if [ "$VIOLATIONS" -gt 0 ]; then
    echo "=========================================================="
    echo "   Performance Verification: FAILED ($VIOLATIONS violations)"
    echo "=========================================================="
    exit 1
else
    echo "  All performance checks passed cleanly."
    echo "=========================================================="
    echo "   Performance Verification Gate: PASS"
    echo "=========================================================="
    exit 0
fi
