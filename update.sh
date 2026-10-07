#!/usr/bin/env bash

set -Eeuo pipefail

INSTALL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh-bootstrap"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RESET='\033[0m'


info() {
    echo -e "${CYAN}[INFO]${RESET} $1"
}

success() {
    echo -e "${GREEN}[ OK ]${RESET} $1"
}


echo
echo "======================================"
echo "         ZSH Bootstrap Update"
echo "======================================"
echo


if [[ ! -d "$INSTALL_DIR/.git" ]]; then
    echo "[ERROR] Repository local introuvable :"
    echo
    echo "    $INSTALL_DIR"
    exit 1
fi


info "Mise à jour de zsh-bootstrap"

git -C "$INSTALL_DIR" pull --ff-only


if [[ -d "$HOME/.oh-my-zsh/.git" ]]; then

    info "Mise à jour de Oh My Zsh"
    git -C "$HOME/.oh-my-zsh" pull --ff-only || true

fi


for plugin in \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    zsh-completions

do

    PLUGIN_DIR="$HOME/.oh-my-zsh/custom/plugins/$plugin"

    if [[ -d "$PLUGIN_DIR/.git" ]]; then

        info "Mise à jour $plugin"
        git -C "$PLUGIN_DIR" pull --ff-only || true

    fi

done


info "Réinstallation des configurations"

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"

cp \
    "$INSTALL_DIR/config/zshrc" \
    "$HOME/.zshrc"

cp \
    "$INSTALL_DIR/config/starship.toml" \
    "$HOME/.config/starship.toml"

ln -sf \
    "$INSTALL_DIR/bin/zsh-bootstrap" \
    "$HOME/.local/bin/zsh-bootstrap"


success "Mise à jour terminée."

echo
echo "Recharge le shell avec :"
echo
echo "    exec zsh"
echo
