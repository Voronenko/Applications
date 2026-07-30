#!/usr/bin/env bash
APP_NAME="Buzz"
FILE_PATTERN="Buzz_*.AppImage"
REPO="block/buzz"

extract_version() {
    basename "$1" | sed -E 's/Buzz_([0-9.]+)_amd64\.AppImage/\1/'
}

get_latest_version() {
    github_latest "$REPO"
}

get_download_url() {
    github_download_url "$REPO" "$1" "amd64.*AppImage"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
run_updater
