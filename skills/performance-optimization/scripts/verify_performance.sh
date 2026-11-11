#!/usr/bin/env bash
# verify_performance.sh - Automated performance budget and anti-pattern verification script
set -euo pipefail

MAX_ASSET_SIZE_KB="${1:-512}"

echo "=========================================================="
echo "   Performance Optimization & Budget Gate"
echo "=========================================================="

echo -e "\n[1/3] Inspecting compiled bundle and asset budgets..."
VIOLATIONS=0

for dir in dist build out target; do
    if [ -d "$dir" ]; then
        while IFS= read -r file; do
            [ -z "$file" ] && continue
            size_kb=$(du -k "$file" | cut -f1)
            if [ "$size_kb" -gt "$MAX_ASSET_SIZE_KB" ]; then
                echo "  [FAIL] Asset budget exceeded: $file (${size_kb}KB > ${MAX_ASSET_SIZE_KB}KB)"
                VIOLATIONS=$((VIOLATIONS + 1))
            fi
        done < <(find "$dir" -type f \( -name "*.js" -o -name "*.css" -o -name "*.wasm" \) 2>/dev/null || true)
    fi
done

echo -e "\n[2/3] Scanning source code for synchronous hot-loop anti-patterns..."
SYNC_IO=$(grep -rE "for\s*\(.*\)\s*\{[^}]*fs\.read" . --exclude-dir={node_modules,.git,vendor,dist,research} 2>/dev/null | wc -l || echo 0)
if [ "$SYNC_IO" -gt 0 ]; then
    echo "  [FAIL] Sync I/O detected inside loops: $SYNC_IO occurrences"
    VIOLATIONS=$((VIOLATIONS + SYNC_IO))
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

