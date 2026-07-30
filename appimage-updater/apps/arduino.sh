#!/usr/bin/env bash
APP_NAME="Arduino IDE"
FILE_PATTERN="arduino-ide_*.AppImage"
REPO="arduino/arduino-ide"

extract_version() {
    basename "$1" | sed -E 's/arduino-ide_([0-9.]+)_Linux_64bit\.AppImage/\1/'
}

get_latest_version() {
    github_latest "$REPO"
}

get_download_url() {
    github_download_url "$REPO" "$1" "Linux.*AppImage"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
run_updater
