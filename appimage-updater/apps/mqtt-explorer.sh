#!/usr/bin/env bash
APP_NAME="MQTT Explorer"
FILE_PATTERN="MQTT-Explorer-*.AppImage"
REPO="thomasnordquist/MQTT-Explorer"

extract_version() {
    basename "$1" | sed -E 's/MQTT-Explorer-(.+)_[a-f0-9]+\.AppImage/\1/'
}

get_latest_version() {
    github_latest "$REPO"
}

get_download_url() {
    github_download_url "$REPO" "$1" "AppImage"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
run_updater
