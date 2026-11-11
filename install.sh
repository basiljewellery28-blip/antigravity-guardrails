#!/usr/bin/env bash
#
# One-click global installer for Antigravity Polyglot Engineering Skills (Linux / macOS / Git Bash).
#

set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}   🚀 Installing Antigravity Polyglot Engineering Skills      ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"

# Target global skills directory
GLOBAL_SKILLS_DIR="${HOME}/.gemini/config/skills"

if [ ! -d "${GLOBAL_SKILLS_DIR}" ]; then
    echo -e "${CYAN}📁 Creating global skills directory: ${GLOBAL_SKILLS_DIR}${NC}"
    mkdir -p "${GLOBAL_SKILLS_DIR}"
fi

# Locate skills directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SKILLS_DIR="${SCRIPT_DIR}/skills"

if [ ! -d "${LOCAL_SKILLS_DIR}" ]; then
    echo -e "\033[0;31m❌ Could not find local 'skills' directory in ${SCRIPT_DIR}\033[0m"
    exit 1
fi

COUNT=0
for skill in "${LOCAL_SKILLS_DIR}"/*; do
    if [ -d "${skill}" ]; then
        skill_name="$(basename "${skill}")"
        dest="${GLOBAL_SKILLS_DIR}/${skill_name}"
        echo -e "${CYAN}📦 Installing skill: ${YELLOW}${skill_name}${NC} -> ${GRAY}${dest}${NC}"
        cp -R "${skill}" "${GLOBAL_SKILLS_DIR}/"
        COUNT=$((COUNT + 1))
    fi
done

echo ""
echo -e "${GREEN}✅ All ${COUNT} skills installed globally with success!${NC}"
echo -e "${YELLOW}💡 Gemini / Antigravity will now automatically discover and use these skills across all projects on your machine.${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"

