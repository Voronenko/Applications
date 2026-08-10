#!/usr/bin/env bash
set -euo pipefail

_COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPIMAGE_DIR="$(cd "$_COMMON_DIR/../.." && pwd)"
TMP_DIR="${TMPDIR:-/tmp}/appimage-updater"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

for cmd in curl jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${RED}Error: '$cmd' is required but not installed.${NC}" >&2
        exit 1
    fi
done

github_api() {
    local url="$1"
    local auth_args=()
    local resp
    if [ -n "${GITHUB_TOKEN:-}" ]; then
        auth_args=(-H "Authorization: Bearer $GITHUB_TOKEN")
    fi
    resp=$(curl -sL "${auth_args[@]}" "$url")

    if echo "$resp" | jq -e '.message | test("rate limit"; "i")' >/dev/null 2>&1; then
        echo -e "${RED}GitHub API rate limit exceeded. Set GITHUB_TOKEN to increase the limit.${NC}" >&2
        echo "null"
        return 1
    fi

    echo "$resp"
}

github_latest() {
    local resp
    resp=$(github_api "https://api.github.com/repos/$1/releases/latest")
    echo "$resp" | jq -r '.tag_name // "null"'
}

github_download_url() {
    local repo="$1" tag="$2" filter="${3:-AppImage}"
    local resp
    resp=$(github_api "https://api.github.com/repos/$repo/releases/tags/$tag")
    if [ "$resp" = "null" ]; then
        echo ""
        return
    fi
    echo "$resp" | jq -r --arg f "$filter" '.assets[] | select(.name | test($f; "i")) | .browser_download_url' | head -1
}

print_banner() {
    echo ""
    echo "========================================="
    echo "  $APP_NAME"
    echo "========================================="
    echo ""
}

find_installed() {
    local file
    # ponytail: sort -V | tail -1 picks the highest version (newest match),
    # not the lexicographically-first (oldest) -- matters when leftovers/partial
    # cleanups leave multiple FILE_PATTERN matches in APPIMAGE_DIR.
    file=$(find "$APPIMAGE_DIR" -maxdepth 1 -name "$FILE_PATTERN" 2>/dev/null | sort -V | tail -1)
    if [ -z "$file" ]; then
        return 1
    fi
    local version
    version=$(extract_version "$file")
    echo "$version|$file"
    return 0
}

compare_versions() {
    local v1="$1" v2="$2"
    local highest
    highest=$(printf '%s\n%s\n' "$v1" "$v2" | sort -V | tail -1)
    [ "$highest" = "$v2" ] && [ "$v1" != "$v2" ]
}

backup_file() {
    local file="$1"
    local backup_dir="$APPIMAGE_DIR/backup"
    mkdir -p "$backup_dir"
    local bak_file="$backup_dir/$(basename "$file").bak"
    if [ -f "$bak_file" ]; then
        rm -f "$bak_file"
    fi
    mv "$file" "$bak_file"
    echo "Backed up to backup/$(basename "$file").bak"
}

download_file() {
    local url="$1" dest="$2"
    echo "Downloading..."
    curl -fSL --progress-bar -o "$dest" "$url"
    echo ""
}

verify_sha256() {
    local file="$1" hash="$2"
    if [ -z "$hash" ]; then
        return 0
    fi
    echo "$hash  $file" | sha256sum -c --status
}

download_and_install() {
    local old_path="$1" raw_tag="$2"
    local download_url
    download_url=$(get_download_url "$raw_tag")

    if [ -z "$download_url" ]; then
        echo -e "${RED}Error: Could not determine download URL.${NC}"
        return 1
    fi

    mkdir -p "$TMP_DIR"

    local new_filename
    new_filename=$(basename "$download_url" | sed 's/[?#].*//')
    if [ -z "$new_filename" ]; then
        echo -e "${RED}Error: Could not determine filename from download URL.${NC}"
        return 1
    fi

    local tmp_file="$TMP_DIR/$new_filename"

    download_file "$download_url" "$tmp_file"

    if declare -f get_checksum >/dev/null 2>&1; then
        local checksum
        checksum=$(get_checksum "$raw_tag")
        if [ -n "$checksum" ]; then
            if ! verify_sha256 "$tmp_file" "$checksum"; then
                echo -e "${RED}SHA256 verification failed!${NC}"
                rm -f "$tmp_file"
                return 1
            fi
            echo "SHA256 verified."
        fi
    fi

    if [ -n "$old_path" ]; then
        backup_file "$old_path"
    fi
    mv "$tmp_file" "$APPIMAGE_DIR/$new_filename"
    chmod +x "$APPIMAGE_DIR/$new_filename"
    if [ -n "$old_path" ]; then
        echo -e "${GREEN}Updated to ${raw_tag#v}.${NC}"
    else
        echo -e "${GREEN}Installed ${new_filename} (${raw_tag#v}).${NC}"
    fi
}

run_updater() {
    print_banner

    local installed_version="" installed_file=""
    local installed_info

    if installed_info=$(find_installed); then
        installed_version="${installed_info%%|*}"
        installed_file="${installed_info#*|}"
        echo "Installed : $installed_version"
    else
        echo "Not installed"
    fi

    local latest_raw
    latest_raw=$(get_latest_version)
    local latest_version="${latest_raw#v}"

    if [ -z "$latest_version" ] || [ "$latest_version" = "null" ]; then
        echo "Latest    : unknown (skip)"
        echo ""
        echo -e "${YELLOW}Skipping: could not determine latest version.${NC}"
        return 0
    fi

    echo "Latest    : $latest_version"
    echo ""

    if [ -n "$installed_version" ] && ! compare_versions "$installed_version" "$latest_version"; then
        echo -e "${GREEN}Already up to date.${NC}"
        return 0
    fi

    if [ -n "$installed_version" ]; then
        echo -e "${YELLOW}Update available!${NC}"
    else
        echo -e "${YELLOW}Fresh install available.${NC}"
    fi
    echo ""

    # Require explicit Y/y. Empty input (non-TTY / EOF / just Enter) skips
    # instead of installing. ASSUME_YES=1 restores unattended/automation use
    # (cron, fresh-machine bootstrap) without prompting. (ponytail: was [Y/n]
    # with empty=consent; empty=skip prevents accidental reinstalls.)
    if [ "${ASSUME_YES:-}" = "1" ]; then
        answer="y"
        echo "Install $latest_version? [y/N] ASSUME_YES=1 -> yes"
    else
        # ponytail: || answer="" swallows read's nonzero on EOF so set -e
        # doesn't abort -- empty/EOF then falls through to the skip branch.
        read -r -p "Install $latest_version? [y/N] " answer || answer=""
        if [[ ! "$answer" =~ ^[Yy]$ ]]; then
            echo "Skipping..."
            return 0
        fi
    fi

    download_and_install "$installed_file" "$latest_raw"
}
