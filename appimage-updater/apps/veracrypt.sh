#!/usr/bin/env bash
APP_NAME="VeraCrypt"
FILE_PATTERN="VeraCrypt-*.AppImage"
REPO="veracrypt/VeraCrypt"

extract_version() {
    basename "$1" | sed -E 's/VeraCrypt-([0-9.]+)-x86_64_[a-f0-9]+\.AppImage/\1/'
}

# veracrypt/VeraCrypt tags releases as "VeraCrypt_X.Y.Z". Strip the prefix so
# the latest version compares equal to the installed "X.Y.Z"; re-add it for the
# GitHub tag lookup so the download URL resolves. (ponytail: assumes
# veracrypt/VeraCrypt keeps the VeraCrypt_ tag scheme; if they switch, update
# both lines.)
get_latest_version() {
    github_latest "$REPO" | sed -E 's/^VeraCrypt_//'
}

get_download_url() {
    github_download_url "$REPO" "VeraCrypt_$1" "x86_64.*AppImage"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
run_updater
