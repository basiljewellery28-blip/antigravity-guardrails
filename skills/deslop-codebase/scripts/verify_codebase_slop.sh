#!/usr/bin/env bash
# verify_codebase_slop.sh - Automated codebase slop verification
set -euo pipefail

TARGET_DIR="${1:-.}"

echo "=========================================================="
echo "   Codebase Deslop & Anti-Boilerplate Gate"
echo "=========================================================="

if [ ! -d "$TARGET_DIR" ]; then
    echo "  [FAIL] Target directory not found: ${TARGET_DIR}"
    exit 1
fi

# Same source extensions and exclusions as verify_codebase_slop.ps1; one hit per file per check.
GREP_SCOPE=(--include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.py'
    --include='*.go' --include='*.rs' --include='*.cs'
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=obj --exclude-dir=bin
    --exclude-dir=dist --exclude-dir=vendor --exclude-dir=research)

# count_files <ERE> [extra grep flags]: -z makes each file one record so patterns can span lines
# (e.g. "except:\n    pass"); [[:space:]] instead of \s keeps it portable to BSD grep.
count_files() {
    local pattern="$1"; shift
    { grep -rElzZ "$@" -e "$pattern" "${GREP_SCOPE[@]}" "$TARGET_DIR" 2>/dev/null || true; } | tr -cd '\0' | wc -c
}

echo -e "\n[1/2] Scanning source files for slop patterns and stubs in: ${TARGET_DIR}..."
VIOLATIONS=0

EMPTY_CATCH=$(count_files 'catch[[:space:]]*(\([^)]*\))?[[:space:]]*\{[[:space:]]*(/\*([^*]|\*+[^*/])*\*+/|//[^[:cntrl:]]*)?[[:space:]]*\}|\.catch\([[:space:]]*(\([[:space:]]*[[:alnum:]_]*[[:space:]]*\)|[[:alnum:]_]+)[[:space:]]*=>[[:space:]]*\{[[:space:]]*\}[[:space:]]*\)')
if [ "$EMPTY_CATCH" -gt 0 ]; then
    echo "  [FAIL] Files with empty catch blocks: $EMPTY_CATCH"
    VIOLATIONS=$((VIOLATIONS + EMPTY_CATCH))
fi

EMPTY_EXCEPT=$(count_files 'except([[:space:]]+[^:[:cntrl:]]+)?:[[:space:]]*pass([^[:alnum:]_]|$)')
if [ "$EMPTY_EXCEPT" -gt 0 ]; then
    echo "  [FAIL] Files with empty Python except blocks: $EMPTY_EXCEPT"
    VIOLATIONS=$((VIOLATIONS + EMPTY_EXCEPT))
fi

STUBS=$(count_files '(^|[^[:alnum:]_])(TODO|FIXME|XXX)[[:space:]]*:')
if [ "$STUBS" -gt 0 ]; then
    echo "  [FAIL] Files with unimplemented TODO/FIXME stubs: $STUBS"
    VIOLATIONS=$((VIOLATIONS + STUBS))
fi

PLACEHOLDERS=$(count_files '/\*[[:space:]]*(implement|logic)[[:space:]]+here[[:space:]]*\*/' -i)
if [ "$PLACEHOLDERS" -gt 0 ]; then
    echo "  [FAIL] Files with placeholder logic stubs: $PLACEHOLDERS"
    VIOLATIONS=$((VIOLATIONS + PLACEHOLDERS))
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
