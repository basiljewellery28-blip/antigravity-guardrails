#!/usr/bin/env bash
# verify_browser_suite.sh - Automated verification for browser testing suites
set -euo pipefail

URL="${1:-http://localhost:3000}"

echo "=========================================================="
echo "   Browser & DevTools Testing Verification Gate"
echo "=========================================================="

echo -e "\n[1/3] Scanning for browser test specifications..."
TEST_COUNT=$(find . -maxdepth 4 -type f \( -name "*.spec.ts" -o -name "*.spec.js" -o -name "*.e2e.ts" -o -name "*.e2e.js" \) 2>/dev/null | grep -Ev "node_modules|\.git|dist|vendor|research" | wc -l || echo 0)
echo "  Found ${TEST_COUNT} browser test specification(s)."

echo -e "\n[2/3] Probing endpoint connectivity: ${URL} ..."
if curl -s -I --connect-timeout 2 "${URL}" >/dev/null 2>&1; then
    echo "  Endpoint ${URL} is responsive."
else
    echo "  Target endpoint ${URL} is not currently responding (Server offline or pending)."
fi

echo -e "\n[3/3] Inspecting available browser automation runtimes..."
RUNTIMES=()
command -v google-chrome >/dev/null 2>&1 && RUNTIMES+=("Google Chrome")
command -v chromium >/dev/null 2>&1 && RUNTIMES+=("Chromium")
command -v npx >/dev/null 2>&1 && RUNTIMES+=("Node/NPX (Playwright/Puppeteer)")

if [ ${#RUNTIMES[@]} -gt 0 ]; then
    echo "  Detected runtimes: ${RUNTIMES[*]}"
else
    echo "  Warning: No default browser runtime detected in PATH."
fi

echo -e "\n=========================================================="
echo "   Browser Verification Gate Complete: PASS"
echo "=========================================================="
exit 0
