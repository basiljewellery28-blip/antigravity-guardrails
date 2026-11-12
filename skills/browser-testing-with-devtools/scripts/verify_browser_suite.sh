#!/usr/bin/env bash
# verify_browser_suite.sh - Automated verification for browser testing suites
# Usage: verify_browser_suite.sh [--url URL | URL]   (default http://localhost:3000)
set -euo pipefail

URL="http://localhost:3000"
while [ $# -gt 0 ]; do
    case "$1" in
        --url) URL="${2:?--url requires a value}"; shift 2 ;;
        --url=*) URL="${1#--url=}"; shift ;;
        *) URL="$1"; shift ;;
    esac
done

BLOCKERS=()

echo "=========================================================="
echo "   Browser & DevTools Testing Verification Gate"
echo "=========================================================="

echo -e "\n[1/3] Scanning for browser test specifications..."
# Same spec globs and whole-segment exclusions as the .ps1.
TEST_COUNT=$(find . -type f \( -name "*.spec.ts" -o -name "*.spec.js" -o -name "*.test.ts" -o -name "*.test.js" -o -name "*.e2e.ts" -o -name "*.e2e.js" \) 2>/dev/null | grep -Evc '/(node_modules|\.git|obj|bin|dist|vendor|research)/' || true)
echo "  Found ${TEST_COUNT} browser test specification(s)."

echo -e "\n[2/3] Probing endpoint connectivity: ${URL} ..."
# curl prints 000 when no HTTP response was received; any real status code means the server is up.
STATUS=$(curl -s -o /dev/null -I -w '%{http_code}' --connect-timeout 3 --max-time 5 "${URL}" 2>/dev/null || true)
STATUS="${STATUS:-000}"
if [ "$STATUS" -ge 500 ]; then
    echo "  Endpoint ${URL} returned HTTP ${STATUS}."
    BLOCKERS+=("Endpoint ${URL} returned server error HTTP ${STATUS}.")
elif [ "$STATUS" -ge 400 ]; then
    echo "  Endpoint ${URL} is up but returned HTTP ${STATUS}."
elif [ "$STATUS" -ge 200 ]; then
    echo "  Endpoint ${URL} is responsive (HTTP ${STATUS})."
else
    echo "  Target endpoint ${URL} is not currently responding (Server offline or pending)."
    if [ "$TEST_COUNT" -eq 0 ]; then
        BLOCKERS+=("No browser test specs found and ${URL} is unreachable: nothing could be verified.")
    fi
fi

echo -e "\n[3/3] Inspecting available browser automation runtimes..."
RUNTIMES=()
command -v google-chrome >/dev/null 2>&1 && RUNTIMES+=("Google Chrome")
command -v chromium >/dev/null 2>&1 && RUNTIMES+=("Chromium")
command -v npx >/dev/null 2>&1 && RUNTIMES+=("Node/NPX (Playwright/Puppeteer)")

if [ ${#RUNTIMES[@]} -gt 0 ]; then
    echo "  Detected runtimes: ${RUNTIMES[*]}"
else
    echo "  No default browser runtime detected in PATH."
    BLOCKERS+=("No browser automation runtime available.")
fi

if [ ${#BLOCKERS[@]} -gt 0 ]; then
    echo -e "\n=========================================================="
    echo "   Browser Verification Gate: FAILED (${#BLOCKERS[@]} blocker(s))"
    for b in "${BLOCKERS[@]}"; do
        echo "    - $b"
    done
    echo "=========================================================="
    exit 1
fi

echo -e "\n=========================================================="
echo "   Browser Verification Gate Complete: PASS"
echo "   (Preconditions only: specs are not executed; console errors/CLS not measured.)"
echo "=========================================================="
exit 0
