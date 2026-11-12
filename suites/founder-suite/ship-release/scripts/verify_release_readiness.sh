#!/usr/bin/env bash
# verify_release_readiness.sh - Automated pre-flight verification script for release readiness
# Usage: verify_release_readiness.sh [TARGET_DIR]   (default ., same as the .ps1 -TargetDirectory)
set -euo pipefail

TARGET_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLOCKERS=()

echo "=========================================================="
echo "   Pre-Flight Release Readiness Gate"
echo "=========================================================="

echo -e "\n[1/4] Checking working tree cleanliness..."
# A failed git call (not a repo, git missing) must not be reported as "clean".
if STATUS_OUT=$(git -C "$TARGET_DIR" status --porcelain 2>/dev/null); then
    if [ -n "$STATUS_OUT" ]; then
        UNCOMMITTED=$(printf '%s\n' "$STATUS_OUT" | wc -l | tr -d ' ')
        echo "  Warning: Working tree has ${UNCOMMITTED} uncommitted change(s)."
    else
        echo "  Working tree is completely clean."
    fi
else
    echo "  Warning: could not read git status for ${TARGET_DIR} (not a git repo or git missing); cleanliness NOT verified."
fi

# `ls a b c` fails if ANY name is missing, so test each file on its own.
first_existing() {
    local f
    for f in "$@"; do
        if [ -f "$TARGET_DIR/$f" ]; then echo "$f"; return 0; fi
    done
    return 1
}

echo -e "\n[2/4] Verifying version declaration..."
if manifest=$(first_existing package.json pyproject.toml Cargo.toml VERSION); then
    echo "  Found version manifest: ${manifest}"
elif compgen -G "$TARGET_DIR/*.csproj" >/dev/null; then
    echo "  Found version manifest: .csproj"
else
    echo "  Warning: No standard version manifest found."
fi

echo -e "\n[3/4] Verifying changelog documentation..."
if changelog=$(first_existing CHANGELOG.md RELEASES.md HISTORY.md); then
    echo "  Found changelog document: ${changelog}"
else
    echo "  Notice: CHANGELOG.md not found in root."
fi

echo -e "\n[4/4] Running security pre-flight check..."
# Look in the target project, then next to this suite (repo layout, then installed layout).
SCAN_SH=""
SCAN_PS=""
for base in "$TARGET_DIR/skills" "$SCRIPT_DIR/../../../../skills" "$SCRIPT_DIR/../.."; do
    d="$base/security-secret-sentinel/scripts"
    [ -z "$SCAN_SH" ] && [ -f "$d/scan_secrets.sh" ] && SCAN_SH="$d/scan_secrets.sh"
    [ -z "$SCAN_PS" ] && [ -f "$d/scan_secrets.ps1" ] && SCAN_PS="$d/scan_secrets.ps1"
done
if [ -n "$SCAN_SH" ]; then
    bash "$SCAN_SH" "$TARGET_DIR" || BLOCKERS+=("Security secret scan reported violations.")
elif [ -n "$SCAN_PS" ] && command -v pwsh >/dev/null 2>&1; then
    pwsh -NoProfile -File "$SCAN_PS" -ProjectPath "$TARGET_DIR" || BLOCKERS+=("Security secret scan reported violations.")
else
    echo "  Security scan script (or pwsh to run its .ps1) not found; secret check SKIPPED (not verified)."
fi

echo -e "\n=========================================================="
if [ ${#BLOCKERS[@]} -gt 0 ]; then
    echo "   Release Readiness Gate: BLOCKED (${#BLOCKERS[@]} blocker(s))"
    for b in "${BLOCKERS[@]}"; do
        echo "    - $b"
    done
    echo "=========================================================="
    exit 1
fi
echo "   Release Readiness Gate: READY TO SHIP"
echo "=========================================================="
exit 0
