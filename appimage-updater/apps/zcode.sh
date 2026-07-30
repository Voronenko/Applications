#!/usr/bin/env bash
APP_NAME="ZCode"
FILE_PATTERN="ZCode-*.AppImage"
ZCODE_URL="https://zcode.z.ai/en"

extract_version() {
    basename "$1" | sed -E 's/ZCode-([0-9.]+)-linux-x64_[a-f0-9]+\.AppImage/\1/'
}

get_latest_version() {
    curl -sL "$ZCODE_URL" | \
        grep -oP 'cdn-zcode\.z\.ai/zcode/electron/releases/\K[0-9]+\.[0-9]+\.[0-9]+' | \
        sort -Vu | \
        tail -1
}

get_download_url() {
    local v="$1"
    curl -sL "$ZCODE_URL" | \
        grep -oP "https?://cdn-zcode\.z\.ai[^\"']+${v}[^\"']*linux-x64[^\"']*AppImage[^\"']*" | \
        head -1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
run_updater
