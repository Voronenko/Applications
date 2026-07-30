#!/usr/bin/env bash
APP_NAME="DbGate"
FILE_PATTERN="dbgate-*.AppImage"
REPO="dbgate/dbgate"

extract_version() {
    basename "$1" | sed -E 's/dbgate-([0-9.]+)-linux_x86_64_[a-f0-9]+\.AppImage/\1/'
}

get_latest_version() {
    github_latest "$REPO"
}

get_download_url() {
    github_download_url "$REPO" "$1" "linux_x86_64.*AppImage"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
run_updater
