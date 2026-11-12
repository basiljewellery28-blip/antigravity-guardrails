#!/usr/bin/env bash
# check_circuit_breaker.sh - Automated circuit breaker for runaway processes and logs
# Usage: check_circuit_breaker.sh [TARGET_DIR] [MAX_LOG_SIZE_MB]   (same order as the .ps1 parameters)
set -euo pipefail

TARGET_DIR="${1:-.}"
MAX_LOG_SIZE_MB="${2:-10}"
MAX_BYTES=$((MAX_LOG_SIZE_MB * 1024 * 1024))

echo "=========================================================="
echo "   Runaway Stopper & Circuit Breaker Gate"
echo "=========================================================="

if [ ! -d "$TARGET_DIR" ]; then
    echo "  Target directory not found: $TARGET_DIR"
    exit 1
fi
# Relative find paths so only segments below the target are filtered.
cd "$TARGET_DIR"

echo -e "\n[1/3] Checking for runaway output logs and oversized artifacts in: ${TARGET_DIR}..."
TRIPPED=0

# Exclude whole path segments only: a bare 'research' or '.git' substring would also hide
# "my-research-app" or ".github".
while IFS= read -r file; do
    [ -z "$file" ] && continue
    size_mb=$(du -m "$file" | cut -f1)
    echo "  [ALERT] Runaway log detected: $file (${size_mb}MB > ${MAX_LOG_SIZE_MB}MB)"
    TRIPPED=$((TRIPPED + 1))
done < <(find . -type f \( -name "*.log" -o -name "*.txt" -o -name "*.jsonl" \) -size +"${MAX_BYTES}c" 2>/dev/null | grep -Ev '/(node_modules|\.git|vendor|research)/' || true)

if [ "$TRIPPED" -eq 0 ]; then
    echo "  No oversized or runaway log files detected (all under ${MAX_LOG_SIZE_MB}MB)."
fi

echo -e "\n[2/3] Checking running development server processes..."
DEV_PROC_COUNT=$(pgrep -f "node|python|bash" 2>/dev/null | wc -l) || DEV_PROC_COUNT=0
echo "  Found ${DEV_PROC_COUNT// /} active runtime host process(es)."

echo -e "\n[3/3] Evaluating Circuit Breaker Status..."
if [ "$TRIPPED" -gt 0 ]; then
    echo "=========================================================="
    echo "   Circuit Breaker: TRIPPED ($TRIPPED alerts)"
    echo "=========================================================="
    exit 1
else
    echo "  Circuit breaker is healthy. No runaway loops detected."
    echo "=========================================================="
    echo "   Circuit Breaker Gate Complete: PASS"
    echo "=========================================================="
    exit 0
fi
