#!/usr/bin/env bash

# ============================================================
# ZSH Bootstrap
# Distribution detection
# ============================================================

detect_os() {

    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
    else
        echo "[ERROR] Impossible de détecter la distribution Linux."
        return 1
    fi

    DISTRO_ID="${ID:-unknown}"
    DISTRO_ID_LIKE="${ID_LIKE:-}"
    DISTRO_NAME="${PRETTY_NAME:-Linux}"

    if command -v apt-get >/dev/null 2>&1; then
        PACKAGE_MANAGER="apt"

    elif command -v dnf >/dev/null 2>&1; then
        PACKAGE_MANAGER="dnf"

    elif command -v pacman >/dev/null 2>&1; then
        PACKAGE_MANAGER="pacman"

    elif command -v zypper >/dev/null 2>&1; then
        PACKAGE_MANAGER="zypper"

    else
        PACKAGE_MANAGER="unknown"
    fi
}
