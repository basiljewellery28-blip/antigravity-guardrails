#!/usr/bin/env bash
# verify_codebase_slop.sh - Automated codebase slop verification
set -euo pipefail

TARGET_DIR="${1:-.}"

echo "=========================================================="
echo "   Codebase Deslop & Anti-Boilerplate Gate"
echo "=========================================================="

echo -e "\n[1/2] Scanning source files for slop patterns and stubs in: ${TARGET_DIR}..."
VIOLATIONS=0

EMPTY_CATCH=$(grep -rE "catch\s*(\([^)]*\))?\s*\{\s*\}" "$TARGET_DIR" --exclude-dir={node_modules,.git,vendor,dist,research,brain} 2>/dev/null | wc -l || echo 0)
if [ "$EMPTY_CATCH" -gt 0 ]; then
    echo "  [FAIL] Empty catch blocks detected: $EMPTY_CATCH"
    VIOLATIONS=$((VIOLATIONS + EMPTY_CATCH))
fi

STUBS=$(grep -rEI "\b(TODO|FIXME|XXX)\b\s*:" "$TARGET_DIR" --exclude-dir={node_modules,.git,vendor,dist,research,brain} 2>/dev/null | wc -l || echo 0)
if [ "$STUBS" -gt 0 ]; then
    echo "  [FAIL] Unimplemented TODO/FIXME stubs detected: $STUBS"
    VIOLATIONS=$((VIOLATIONS + STUBS))
fi

echo -e "\n[2/2] Evaluating Codebase Slop Gate Status..."
if [ "$VIOLATIONS" -gt 0 ]; then
    echo "=========================================================="
    echo "   Deslop Verification: FAILED ($VIOLATIONS violations)"
    echo "=========================================================="
    exit 1
else
    echo "  Codebase is clean. Zero empty catches, stubs, or slop detected."
    echo "=========================================================="
    echo "   Deslop Verification Gate Complete: PASS"
    echo "=========================================================="
    exit 0
fi
