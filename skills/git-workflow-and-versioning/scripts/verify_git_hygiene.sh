#!/usr/bin/env bash
# verify_git_hygiene.sh - Automated verification of Git repository hygiene
set -euo pipefail

DEPTH="${1:-5}"

echo "=========================================================="
echo "   Git Workflow & Repository Hygiene Gate"
echo "=========================================================="

echo -e "\n[1/3] Checking Git status and working directory hygiene..."
VIOLATIONS=0

STRAY=$(git status --porcelain 2>/dev/null | grep -E '\.env|\.log|Thumbs\.db|\.DS_Store|node_modules' || true)
if [ -n "$STRAY" ]; then
    echo "  [FAIL] Stray unignored artifacts in working tree:"
    echo "$STRAY"
    VIOLATIONS=$((VIOLATIONS + 1))
else
    echo "  No sensitive unignored files in working tree."
fi

echo -e "\n[2/3] Validating recent commit messages (depth = $DEPTH)..."
COMMIT_REGEX='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-zA-Z0-9_\-\.\/]+\))?:\s+.+'

while IFS='|' read -r hash subject; do
    [ -z "$hash" ] && continue
    if [[ "$subject" =~ ^Merge ]] || [[ "$subject" =~ ^Initial\ commit ]]; then
        echo "  [$hash] $subject (Allowed merge/init)"
        continue
    fi
    if ! echo "$subject" | grep -Eq "$COMMIT_REGEX"; then
        echo "  [FAIL] Commit [$hash] invalid format: '$subject'"
        VIOLATIONS=$((VIOLATIONS + 1))
    else
        echo "  [$hash] $subject (Valid)"
    fi
done < <(git log -n "$DEPTH" --pretty=format:"%h|%s" 2>/dev/null || true)

echo -e "\n[3/3] Evaluating Git Hygiene Gate Status..."
if [ "$VIOLATIONS" -gt 0 ]; then
    echo "=========================================================="
    echo "   Git Hygiene Verification: FAILED ($VIOLATIONS violations)"
    echo "=========================================================="
    exit 1
else
    echo "  All git hygiene and commit format checks passed cleanly."
    echo "=========================================================="
    echo "   Git Hygiene Verification Gate: PASS"
    echo "=========================================================="
    exit 0
fi
