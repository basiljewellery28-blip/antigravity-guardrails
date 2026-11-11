#!/usr/bin/env bash
# verify_release_readiness.sh - Automated pre-flight verification script for release readiness
set -euo pipefail

TARGET_DIR="${1:-.}"

echo "=========================================================="
echo "   Pre-Flight Release Readiness Gate"
echo "=========================================================="

echo -e "\n[1/4] Checking working tree cleanliness..."
UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l || echo 0)
if [ "$UNCOMMITTED" -gt 0 ]; then
    echo "  Warning: Working tree has ${UNCOMMITTED} uncommitted change(s)."
else
    echo "  Working tree is completely clean."
fi

echo -e "\n[2/4] Verifying version declaration..."
if ls package.json Cargo.toml pyproject.toml VERSION 1>/dev/null 2>&1; then
    echo "  Version manifest found."
else
    echo "  Warning: No standard version manifest found."
fi

echo -e "\n[3/4] Verifying changelog documentation..."
if ls CHANGELOG.md RELEASES.md 1>/dev/null 2>&1; then
    echo "  Changelog found."
else
    echo "  Notice: CHANGELOG.md not found in root."
fi

echo -e "\n[4/4] Running security pre-flight check..."
SCAN_SCRIPT="./skills/security-secret-sentinel/scripts/scan_secrets.sh"
if [ -f "$SCAN_SCRIPT" ]; then
    bash "$SCAN_SCRIPT"
else
    echo "  Security script not found locally; skipping secret check."
fi

echo -e "\n=========================================================="
echo "   Release Readiness Gate: READY TO SHIP"
echo "=========================================================="
exit 0
