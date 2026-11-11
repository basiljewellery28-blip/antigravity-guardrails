#!/usr/bin/env bash
#
# Installs Antigravity pre-commit guardrail hooks into a Git repository (Linux / macOS).
#

set -euo pipefail

TARGET_DIR="${1:-.}"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}   🛡️ Installing Antigravity Git Pre-Commit Security Hook      ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"

RESOLVED_TARGET="$(cd "${TARGET_DIR}" && pwd)"
GIT_DIR="${RESOLVED_TARGET}/.git"

if [ ! -d "${GIT_DIR}" ]; then
    echo -e "${RED}❌ No .git directory found in: ${RESOLVED_TARGET}${NC}"
    echo -e "${YELLOW}💡 Make sure you are inside your project folder before running this command,${NC}"
    echo -e "${YELLOW}   or pass the path directly: ./setup-hooks.sh /path/to/your-project${NC}"
    exit 1
fi

HOOKS_DIR="${GIT_DIR}/hooks"
mkdir -p "${HOOKS_DIR}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_HOOK="${SCRIPT_DIR}/scripts/git-hooks/pre-commit"
TARGET_HOOK="${HOOKS_DIR}/pre-commit"

if [ ! -f "${SOURCE_HOOK}" ]; then
    echo -e "${RED}❌ Source hook '${SOURCE_HOOK}' not found.${NC}"
    exit 1
fi

cp "${SOURCE_HOOK}" "${TARGET_HOOK}"
chmod +x "${TARGET_HOOK}"

echo -e "${GREEN}✅ Pre-commit hook installed to: ${TARGET_HOOK}${NC}"
echo -e "${YELLOW}💡 Any 'git commit' in '${RESOLVED_TARGET}' will now automatically run Secret Sentinel & OWASP checks before completing.${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
