#!/usr/bin/env bash
APP_NAME="Logseq"
FILE_PATTERN="Logseq-linux-x64-*.AppImage"
REPO="logseq/logseq"

extract_version() {
    basename "$1" | sed -E 's/Logseq-linux-x64-([0-9.]+)\.AppImage/\1/'
}

get_latest_version() {
    github_latest "$REPO"
}

get_download_url() {
    github_download_url "$REPO" "$1" "linux.*AppImage"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
run_updater
