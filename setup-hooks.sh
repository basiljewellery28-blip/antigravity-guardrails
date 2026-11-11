#!/usr/bin/env bash
#
# Installs Antigravity pre-commit guardrail hooks into the local Git repository (Linux / macOS).
#

set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}   🛡️ Installing Antigravity Git Pre-Commit Security Hook      ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"

if [ ! -d ".git" ]; then
    echo -e "${RED}❌ No .git directory found. Run 'git init' first.${NC}"
    exit 1
fi

HOOKS_DIR=".git/hooks"
mkdir -p "${HOOKS_DIR}"

SOURCE_HOOK="scripts/git-hooks/pre-commit"
TARGET_HOOK="${HOOKS_DIR}/pre-commit"

if [ ! -f "${SOURCE_HOOK}" ]; then
    echo -e "${RED}❌ Source hook '${SOURCE_HOOK}' not found.${NC}"
    exit 1
fi

cp "${SOURCE_HOOK}" "${TARGET_HOOK}"
chmod +x "${TARGET_HOOK}"

echo -e "${GREEN}✅ Pre-commit hook installed to: ${TARGET_HOOK}${NC}"
echo -e "${YELLOW}💡 Any 'git commit' will now automatically run Secret Sentinel & OWASP checks before completing.${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
