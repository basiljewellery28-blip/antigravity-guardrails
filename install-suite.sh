#!/usr/bin/env bash
# install-suite.sh - Installs modular domain skill suites into global Antigravity directory
set -euo pipefail

SUITE="${1:-all}"
TARGET_DIR="${2:-$HOME/.gemini/config/skills}"

echo "=========================================================="
echo "   Antigravity Modular Suite Installer"
echo "=========================================================="

mkdir -p "$TARGET_DIR"

install_from_dir() {
    local src_dir="$1"
    if [ ! -d "$src_dir" ]; then
        return
    fi
    for skill in "$src_dir"/*; do
        if [ -d "$skill" ]; then
            skill_name=$(basename "$skill")
            echo "Installing: ${skill_name} -> ${TARGET_DIR}/${skill_name}"
            rm -rf "${TARGET_DIR}/${skill_name}"
            cp -R "$skill" "${TARGET_DIR}/"
        fi
    done
}

case "$SUITE" in
    core)
        install_from_dir "skills"
        ;;
    document)
        install_from_dir "suites/document-suite"
        ;;
    founder)
        install_from_dir "suites/founder-suite"
        ;;
    cloud)
        install_from_dir "suites/cloud-suite"
        ;;
    all)
        install_from_dir "skills"
        install_from_dir "suites/document-suite"
        install_from_dir "suites/founder-suite"
        install_from_dir "suites/cloud-suite"
        ;;
    *)
        echo "Unknown suite: $SUITE. Options: all, core, document, founder, cloud."
        exit 1
        ;;
esac

echo "=========================================================="
echo "   Suite [${SUITE}] Successfully Installed to ${TARGET_DIR}"
echo "=========================================================="
exit 0

