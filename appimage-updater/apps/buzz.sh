#!/usr/bin/env bash
APP_NAME="Buzz"
FILE_PATTERN="Buzz_*.AppImage"
REPO="block/buzz"

extract_version() {
    basename "$1" | sed -E 's/Buzz_([0-9.]+)_amd64\.AppImage/\1/'
}

# block/buzz tags releases as "desktop-vX.Y.Z". Strip the prefix so the latest
# version compares equal to the installed "X.Y.Z"; re-add it for the GitHub tag
# lookup so the download URL resolves. (ponytail: assumes block/buzz keeps the
# desktop-v tag scheme; if they switch, update both lines.)
get_latest_version() {
    github_latest "$REPO" | sed -E 's/^desktop-v//'
}

get_download_url() {
    github_download_url "$REPO" "desktop-v$1" "amd64.*AppImage"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
run_updater
