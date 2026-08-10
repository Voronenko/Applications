#!/usr/bin/env bash
APP_NAME="Redis Insight"
FILE_PATTERN="Redis-Insight-linux-x86_64.AppImage"
REPO="RedisInsight/RedisInsight"

extract_version() {
    local filepath="$1"
    local tmpdir
    tmpdir=$(mktemp -d)
    (
        cd "$tmpdir"
        "$filepath" --appimage-extract >/dev/null 2>&1
    ) || true
    local version=""
    version=$(strings "$tmpdir/squashfs-root/resources/app.asar" 2>/dev/null | grep -m1 '"version"' | sed -E 's/.*"version": *"([^"]+)".*/\1/')
    rm -rf "$tmpdir"
    echo "$version"
}

get_latest_version() {
    github_latest "$REPO"
}

get_download_url() {
    # ponytail: RedisInsight's release asset list orders "linux-arm64.AppImage"
    # BEFORE "linux-x86_64.AppImage"; the generic "linux.*AppImage" filter +
    # head -1 in github_download_url picked the ARM64 build on x86_64 hosts
    # (confirmed: Redis-Insight-linux-arm64.AppImage got installed). Pin x86_64.
    github_download_url "$REPO" "$1" "linux-x86_64.*AppImage"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
run_updater
