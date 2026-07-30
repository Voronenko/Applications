#!/usr/bin/env bash
APP_NAME="VeraCrypt"
FILE_PATTERN="VeraCrypt-*.AppImage"
REPO="veracrypt/VeraCrypt"

extract_version() {
    basename "$1" | sed -E 's/VeraCrypt-([0-9.]+)-x86_64_[a-f0-9]+\.AppImage/\1/'
}

get_latest_version() {
    github_latest "$REPO" | sed 's/^VeraCrypt_//'
}

get_download_url() {
    github_download_url "$REPO" "VeraCrypt_$1" "x86_64.*AppImage"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
run_updater
