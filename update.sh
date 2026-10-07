#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


echo
echo "======================================"
echo "         ZSH Bootstrap Update"
echo "======================================"
echo


if [[ -d "$SCRIPT_DIR/.git" ]]; then

    echo "[+] Mise à jour du repository"

    git -C "$SCRIPT_DIR" pull --ff-only

fi


if [[ -d "$HOME/.oh-my-zsh" ]]; then

    echo "[+] Mise à jour Oh My Zsh"

    git -C "$HOME/.oh-my-zsh" pull --ff-only || true

fi


for plugin in \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    zsh-completions

do

    PLUGIN_DIR="$HOME/.oh-my-zsh/custom/plugins/$plugin"

    if [[ -d "$PLUGIN_DIR/.git" ]]; then

        echo "[+] Mise à jour $plugin"

        git -C "$PLUGIN_DIR" pull --ff-only

    fi

done


echo "[+] Réinstallation des configurations"

mkdir -p "$HOME/.config"

cp "$SCRIPT_DIR/config/zshrc" \
   "$HOME/.zshrc"

cp "$SCRIPT_DIR/config/starship.toml" \
   "$HOME/.config/starship.toml"


echo
echo "[OK] Mise à jour terminée."
echo
