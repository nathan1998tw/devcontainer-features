#!/bin/bash
set -euo pipefail

GROK_INSTALLER_URL="https://x.ai/cli/install.sh"
INSTALL_DIR="/usr/local/bin"

echo "Installing Grok..."

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: this Feature's install.sh must run as root."
    exit 1
fi

VERSION="${VERSION:-latest}"
CHANNEL="${CHANNEL:-stable}"

install_packages() {
    if command -v apt-get >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y
        apt-get install -y --no-install-recommends "$@"
        rm -rf /var/lib/apt/lists/*
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache "$@"
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y "$@"
    elif command -v yum >/dev/null 2>&1; then
        yum install -y "$@"
    else
        echo "ERROR: unsupported package manager. Install these packages manually: $*"
        return 1
    fi
}

ensure_basics() {
    local missing=()

    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        missing+=("curl")
    fi

    if [ ! -d /etc/ssl/certs ] && [ ! -f /etc/ssl/cert.pem ]; then
        missing+=("ca-certificates")
    fi

    if [ "${#missing[@]}" -gt 0 ]; then
        install_packages "${missing[@]}"
    fi

    # Optional: the upstream installer prefers zstd-compressed artifacts.
    if ! command -v zstd >/dev/null 2>&1; then
        install_packages zstd 2>/dev/null || true
    fi
}

normalize_version() {
    case "$1" in
        "" | latest)
            echo ""
            ;;
        v*)
            echo "${1#v}"
            ;;
        *)
            echo "$1"
            ;;
    esac
}

download_installer() {
    local destination="$1"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$GROK_INSTALLER_URL" -o "$destination"
    else
        wget -q -O "$destination" "$GROK_INSTALLER_URL"
    fi
}

resolve_binary() {
    local source_path="$1"
    if command -v readlink >/dev/null 2>&1; then
        readlink -f "$source_path"
    else
        echo "$source_path"
    fi
}

ensure_basics

version="$(normalize_version "$VERSION")"
installer_path="$(mktemp)"
install_home="$(mktemp -d)"
trap 'rm -f "$installer_path"; rm -rf "$install_home"' EXIT

download_installer "$installer_path"
chmod 0755 "$installer_path"

echo "Running upstream Grok installer (version: ${version:-latest}, channel: ${CHANNEL})..."
if [ -n "$version" ]; then
    HOME="$install_home" GROK_CHANNEL="$CHANNEL" bash "$installer_path" "$version"
else
    HOME="$install_home" GROK_CHANNEL="$CHANNEL" bash "$installer_path"
fi

source_grok="${install_home}/.grok/bin/grok"
if [ ! -e "$source_grok" ]; then
    echo "ERROR: Grok installer did not produce ${source_grok}."
    exit 1
fi

resolved="$(resolve_binary "$source_grok")"
if [ ! -f "$resolved" ]; then
    echo "ERROR: could not resolve Grok binary from ${source_grok}."
    exit 1
fi

# Copy the real binary into PATH. The upstream installer leaves symlinks that
# point at $HOME/.grok/downloads, which is discarded after this Feature runs.
rm -f "${INSTALL_DIR}/grok" "${INSTALL_DIR}/agent"
install -m 0755 "$resolved" "${INSTALL_DIR}/grok"
ln -sf grok "${INSTALL_DIR}/agent"

echo "Grok installation completed."
"${INSTALL_DIR}/grok" --version
