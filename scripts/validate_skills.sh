#!/usr/bin/env bash
# validate_skills.sh - Automated validator for skill definitions and frontmatter schemas
set -euo pipefail

ROOT_DIR="${1:-.}"

echo "=========================================================="
echo "   Antigravity Skills Schema & Frontmatter Validator"
echo "=========================================================="

VALID=0
INVALID=0

# Prints the frontmatter body; fails if line 1 is not '---' or it is never closed.
frontmatter() {
    tr -d '\r' < "$1" | awk '
        NR == 1 { if ($0 !~ /^(\xef\xbb\xbf)?---$/) exit; next }
        /^---$/ { closed = 1; exit }
        { print }
        END { exit !closed }'
}

for sp in "skills" "suites"; do
    TARGET="${ROOT_DIR}/${sp}"
    if [ ! -d "$TARGET" ]; then
        continue
    fi

    while IFS= read -r file; do
        [ -z "$file" ] && continue
        skill_name=$(basename "$(dirname "$file")")

        # Only look inside the frontmatter: a "name:" line in the body must not satisfy the check.
        if fm="$(frontmatter "$file")" \
            && grep -Eq '^name:[[:space:]]*[a-zA-Z0-9_-]+' <<< "$fm" \
            && grep -Eq '^description:[[:space:]]*[^[:space:]]' <<< "$fm"; then
            echo "  [VALID]   ${skill_name}"
            VALID=$((VALID + 1))
        else
            echo "  [INVALID] ${file}"
            INVALID=$((INVALID + 1))
        fi
    done < <(find "$TARGET" \( -name node_modules -o -name .git -o -name vendor -o -name research \) -prune -o -type f -name SKILL.md -print)
done

echo "=========================================================="
if [ $((VALID + INVALID)) -eq 0 ]; then
    echo "   Validation FAILED: no SKILL.md files found under ${ROOT_DIR}"
    exit 1
fi
if [ "$INVALID" -gt 0 ]; then
    echo "   Validation FAILED: $INVALID invalid skill(s), $VALID valid"
    exit 1
else
    echo "   Validation PASSED: All $VALID skill(s) conform to schema"
    exit 0
fi
