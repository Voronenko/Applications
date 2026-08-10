#!/usr/bin/env bash
APP_NAME="Logseq"
# ponytail: logseq 2.0+ renamed assets from "Logseq-linux-x64-*" to
# "Logseq-linux-x86_64-*". "x*" matches both and excludes linux-arm64 so a
# wrongly-downloaded ARM64 build is never mistaken for an installed x86_64 one.
FILE_PATTERN="Logseq-linux-x*.AppImage"
REPO="logseq/logseq"

extract_version() {
    basename "$1" | sed -E 's/Logseq-linux-x(86_)?64-([0-9.]+)\.AppImage/\2/'
}

get_latest_version() {
    github_latest "$REPO"
}

get_download_url() {
    # ponytail: logseq's release asset list orders "linux-arm64" BEFORE
    # "linux-x86_64"; the generic "linux.*AppImage" filter + head -1 in
    # github_download_url picked the ARM64 build on x86_64 hosts (confirmed:
    # Logseq-linux-arm64-2.0.1.AppImage got installed). Pin x86_64 explicitly.
    github_download_url "$REPO" "$1" "linux-x86_64.*AppImage"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
run_updater
