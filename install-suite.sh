#!/usr/bin/env bash
# install-suite.sh - Installs modular domain skill suites into global Antigravity directory
set -euo pipefail

SUITE="${1:-all}"
TARGET_DIR="${2:-$HOME/.gemini/config/skills}"
UNINSTALL="${3:-}"
# Not cwd-relative: must work when invoked from another directory (as install.sh does).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================="
echo "   Antigravity Modular Suite Installer"
echo "=========================================================="

if [ -n "$UNINSTALL" ] && [ "$UNINSTALL" != "--uninstall" ]; then
    echo "Usage: $0 [all|core|document|founder|cloud] [target-dir] [--uninstall]" >&2
    exit 2
fi

mkdir -p "$TARGET_DIR"

install_from_dir() {
    local src_dir="$1"
    if [ ! -d "$src_dir" ]; then
        echo "Warning: Source directory not found: $src_dir"
        return
    fi
    for skill in "$src_dir"/*; do
        if [ -d "$skill" ]; then
            skill_name=$(basename "$skill")
            rm -rf "${TARGET_DIR:?}/${skill_name:?}"
            if [ -z "$UNINSTALL" ]; then
                echo "Installing: ${skill_name} -> ${TARGET_DIR}/${skill_name}"
                cp -R "$skill" "${TARGET_DIR}/"
            else
                echo "Removed: ${skill_name} from ${TARGET_DIR}"
            fi
        fi
    done
}

case "$SUITE" in
    core)
        install_from_dir "${SCRIPT_DIR}/skills"
        ;;
    document)
        install_from_dir "${SCRIPT_DIR}/suites/document-suite"
        ;;
    founder)
        install_from_dir "${SCRIPT_DIR}/suites/founder-suite"
        ;;
    cloud)
        install_from_dir "${SCRIPT_DIR}/suites/cloud-suite"
        ;;
    all)
        install_from_dir "${SCRIPT_DIR}/skills"
        install_from_dir "${SCRIPT_DIR}/suites/document-suite"
        install_from_dir "${SCRIPT_DIR}/suites/founder-suite"
        install_from_dir "${SCRIPT_DIR}/suites/cloud-suite"
        ;;
    *)
        echo "Unknown suite: $SUITE. Options: all, core, document, founder, cloud."
        exit 1
        ;;
esac

echo "=========================================================="
echo "   Suite [${SUITE}] Done (${UNINSTALL:-install}) in ${TARGET_DIR}"
echo "=========================================================="
exit 0

