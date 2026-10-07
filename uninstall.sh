#!/usr/bin/env bash

set -Eeuo pipefail


echo
echo "======================================"
echo "       ZSH Bootstrap Uninstall"
echo "======================================"
echo


BACKUP_DATE="$(date '+%Y%m%d-%H%M%S')"


if [[ -f "$HOME/.zshrc" ]]; then

    mv \
        "$HOME/.zshrc" \
        "$HOME/.zshrc.bootstrap-$BACKUP_DATE"

fi


if [[ -f "$HOME/.config/starship.toml" ]]; then

    mv \
        "$HOME/.config/starship.toml" \
        "$HOME/.config/starship.toml.bootstrap-$BACKUP_DATE"

fi


echo
echo "[OK] Configurations Bootstrap désactivées."
echo
echo "Oh My Zsh, Starship et les paquets installés"
echo "n'ont volontairement pas été supprimés."
echo
