#!/usr/bin/env bash
APP_NAME="Aider"
FILE_PATTERN="aider-desk-*.AppImage"
REPO="hotovo/aider-desk"

extract_version() {
    basename "$1" | sed -E 's/aider-desk-([0-9.]+)-x86_64\.AppImage/\1/'
}

get_latest_version() {
    github_latest "$REPO"
}

get_download_url() {
    github_download_url "$REPO" "$1" "x86_64.*AppImage"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
run_updater
