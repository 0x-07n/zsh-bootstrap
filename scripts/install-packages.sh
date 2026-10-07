#!/usr/bin/env bash

# ============================================================
# ZSH Bootstrap
# Package installation
# ============================================================

install_packages() {

    echo
    echo "==> Installation des dépendances"
    echo

    case "$PACKAGE_MANAGER" in

        apt)
            sudo apt-get update

            sudo apt-get install -y \
                zsh \
                git \
                curl \
                wget \
                unzip \
                fzf \
                bat \
                eza
            ;;

        dnf)
            sudo dnf install -y \
                zsh \
                git \
                curl \
                wget \
                unzip \
                fzf \
                bat \
                eza
            ;;

        pacman)
            sudo pacman -Syu --needed --noconfirm \
                zsh \
                git \
                curl \
                wget \
                unzip \
                fzf \
                bat \
                eza
            ;;

        zypper)
            sudo zypper --non-interactive install \
                zsh \
                git \
                curl \
                wget \
                unzip \
                fzf \
                bat \
                eza
            ;;

        *)
            echo "[ERROR] Gestionnaire de paquets non supporté."
            return 1
            ;;

    esac
}
