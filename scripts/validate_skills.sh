#!/usr/bin/env bash
# validate_skills.sh - Automated validator for skill definitions and frontmatter schemas
set -euo pipefail

ROOT_DIR="${1:-.}"

echo "=========================================================="
echo "   Antigravity Skills Schema & Frontmatter Validator"
echo "=========================================================="

VALID=0
INVALID=0

for sp in "skills" "suites"; do
    TARGET="${ROOT_DIR}/${sp}"
    if [ ! -d "$TARGET" ]; then
        continue
    fi

    while IFS= read -r file; do
        [ -z "$file" ] && continue
        skill_name=$(basename "$(dirname "$file")")

        if grep -q "^name:" "$file" && grep -q "^description:" "$file"; then
            echo "  [VALID]   ${skill_name}"
            VALID=$((VALID + 1))
        else
            echo "  [INVALID] ${file}"
            INVALID=$((INVALID + 1))
        fi
    done < <(find "$TARGET" -type f -name "SKILL.md" 2>/dev/null | grep -Ev "node_modules|\.git|vendor|research" || true)
done

echo "=========================================================="
if [ "$INVALID" -gt 0 ]; then
    echo "   Validation FAILED: $INVALID invalid skill(s), $VALID valid"
    exit 1
else
    echo "   Validation PASSED: All $VALID skill(s) conform to schema"
    exit 0
fi

