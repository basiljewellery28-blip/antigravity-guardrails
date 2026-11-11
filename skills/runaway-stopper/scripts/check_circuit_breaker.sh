#!/usr/bin/env bash
# check_circuit_breaker.sh - Automated circuit breaker for runaway processes and logs
set -euo pipefail

MAX_LOG_SIZE_MB="${1:-10}"
MAX_BYTES=$((MAX_LOG_SIZE_MB * 1024 * 1024))

echo "=========================================================="
echo "   Runaway Stopper & Circuit Breaker Gate"
echo "=========================================================="

echo -e "\n[1/3] Checking for runaway output logs and oversized artifacts..."
TRIPPED=0

while IFS= read -r file; do
    [ -z "$file" ] && continue
    size_mb=$(du -m "$file" | cut -f1)
    echo "  [ALERT] Runaway log detected: $file (${size_mb}MB > ${MAX_LOG_SIZE_MB}MB)"
    TRIPPED=$((TRIPPED + 1))
done < <(find . -type f \( -name "*.log" -o -name "*.txt" -o -name "*.jsonl" \) -size +"${MAX_BYTES}c" 2>/dev/null | grep -Ev "node_modules|\.git|vendor|research" || true)

if [ "$TRIPPED" -eq 0 ]; then
    echo "  No oversized or runaway log files detected (all under ${MAX_LOG_SIZE_MB}MB)."
fi

echo -e "\n[2/3] Checking running development server processes..."
DEV_PROC_COUNT=$(pgrep -f "node|python|bash" 2>/dev/null | wc -l || echo 0)
echo "  Found ${DEV_PROC_COUNT} active runtime host process(es)."

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
